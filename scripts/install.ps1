# Installe les agents et skills de genai-toolkit dans ~/.claude (copie, idempotent).
#
# Usage : ./scripts/install.ps1 [-ClaudeDir <chemin>] [-WhatIf]

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ClaudeDir = (Join-Path $HOME '.claude')
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot

function Copy-Tree([string]$name) {
    $src = Join-Path $repo $name
    if (-not (Test-Path $src)) { return }
    $dst = Join-Path $ClaudeDir $name
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    foreach ($item in Get-ChildItem $src) {
        $target = Join-Path $dst $item.Name
        $verb = if (Test-Path $target) { 'Remplace' } else { 'Ajoute' }
        if ($PSCmdlet.ShouldProcess($target, $verb)) {
            if ($item.PSIsContainer -and (Test-Path $target)) { Remove-Item -Recurse -Force $target }
            Copy-Item -Recurse -Force $item.FullName $target
            Write-Host "$verb $name/$($item.Name)"
        }
    }
}

Copy-Tree 'agents'
Copy-Tree 'skills'
