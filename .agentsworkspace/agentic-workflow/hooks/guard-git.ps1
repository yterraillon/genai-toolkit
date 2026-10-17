# Hook PreToolUse Claude Code : bloque les actions git/gh irréversibles ou réservées à l'humain.
# Entrée : JSON de l'appel d'outil sur stdin. Sortie : exit 2 + message sur stderr pour bloquer, exit 0 sinon.
#
# Bloque :
#   - git push vers la branche par défaut (default_branch de .claude/workflow.yml, main, master)
#   - git push --force / -f / --force-with-lease / +refspec / --all / --mirror
#   - gh pr merge, gh release create|delete|edit|upload, gh api .../merge(s)
#   - Edit/Write sur .github/workflows/** sauf si allow_workflow_edits: true dans .claude/workflow.yml
#
# Garde-fou best effort : ne remplace pas la protection de branche côté GitHub.

$ErrorActionPreference = 'Stop'

function Block([string]$reason) {
    [Console]::Error.WriteLine("Bloqué par guard-git : $reason. Cette action est réservée à l'humain (voir genai-toolkit/docs/workflow.md).")
    exit 2
}

try {
    $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
    exit 0   # entrée illisible : ne pas bloquer l'outil pour une erreur du hook
}

$tool = $payload.tool_name
$cwd = if ($payload.cwd) { $payload.cwd } else { (Get-Location).Path }

function Get-RepoRoot {
    $root = git -C $cwd rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0) { return $root }
    return $null
}

function Get-WorkflowConfigLine([string]$key) {
    $root = Get-RepoRoot
    if (-not $root) { return $null }
    $cfg = Join-Path $root '.claude/workflow.yml'
    if (-not (Test-Path $cfg)) { return $null }
    $line = Select-String -Path $cfg -Pattern "^\s*$key\s*:\s*[`"']?([^`"'#\s]+)" | Select-Object -First 1
    if ($line) { return $line.Matches[0].Groups[1].Value }
    return $null
}

# --- Édition de fichiers -------------------------------------------------------
if ($tool -in @('Edit', 'Write', 'MultiEdit', 'NotebookEdit')) {
    $path = $payload.tool_input.file_path
    if (-not $path) { $path = $payload.tool_input.notebook_path }
    if ($path -and ($path -match '[\\/]\.github[\\/]workflows[\\/]')) {
        if ((Get-WorkflowConfigLine 'allow_workflow_edits') -ne 'true') {
            Block "modification de $path (allow_workflow_edits n'est pas à true dans .claude/workflow.yml)"
        }
    }
    exit 0
}

if ($tool -notin @('Bash', 'PowerShell')) { exit 0 }

$command = [string]$payload.tool_input.command
if (-not $command) { exit 0 }

# --- gh ------------------------------------------------------------------------
if ($command -match '\bgh\s+pr\s+merge\b') { Block 'gh pr merge' }
if ($command -match '\bgh\s+release\s+(create|delete|edit|upload)\b') { Block 'gh release' }
if ($command -match '\bgh\s+api\b.*(/pulls/\d+/merge\b|/merges\b)') { Block 'merge via gh api' }

# --- git push ------------------------------------------------------------------
$protected = @('main', 'master')
$default = Get-WorkflowConfigLine 'default_branch'
if ($default) { $protected += $default }

# Découpe en commandes simples sur les séparateurs shell courants.
$segments = $command -split '(&&|\|\||;|\||\r?\n)'
foreach ($seg in $segments) {
    if ($seg -notmatch '\bgit\b(\s+-C\s+\S+)?\s+push\b(?<rest>.*)$') { continue }
    $rest = $Matches['rest'].Trim()
    $tokens = @($rest -split '\s+' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim('"', "'") })

    foreach ($t in $tokens) {
        if ($t -match '^(--force(-with-lease)?(=.*)?|-f|--force-if-includes|--all|--mirror)$' -or $t -match '^-[a-zA-Z]*f[a-zA-Z]*$') {
            Block "git push $t"
        }
    }

    $positional = @($tokens | Where-Object { $_ -notmatch '^-' })
    # positional[0] = remote, le reste = refspecs
    $refspecs = if ($positional.Count -gt 1) { $positional[1..($positional.Count - 1)] } else { @() }

    if ($refspecs.Count -eq 0) { $refspecs = @('HEAD') }
    foreach ($r in $refspecs) {
        if ($r.StartsWith('+')) { Block "git push $r (force via +refspec)" }
        $dst = if ($r.Contains(':')) { $r.Split(':')[-1] } else { $r }
        if ($dst -eq 'HEAD' -or $dst -eq '') {
            $dst = git -C $cwd branch --show-current 2>$null
        }
        $dst = $dst -replace '^refs/heads/', ''
        if ($protected -contains $dst) { Block "git push vers la branche protégée '$dst'" }
    }
}

exit 0
