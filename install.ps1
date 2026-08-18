<#
.SYNOPSIS
    Installs the whole Skills AI stack on this machine.
.DESCRIPTION
    Reads manifest.json and registers every marketplace, plugin and MCP server,
    then installs this repository itself as the `skills-ai` plugin (startup
    digest + /skills-brief). Safe to re-run: anything already present is skipped.
.EXAMPLE
    .\install.ps1
.EXAMPLE
    .\install.ps1 -SkipMcp
.EXAMPLE
    .\install.ps1 -Refresh   # after editing BRIEF.md
#>
[CmdletBinding()]
param(
    [switch]$SkipMcp,
    [switch]$SkipPlugins,
    # Re-copy this repo into Claude Code's plugin cache. Use after editing
    # BRIEF.md, hooks or commands -- `plugin update` is version-gated and
    # would not pick the change up.
    [switch]$Refresh
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "    --  $msg" -ForegroundColor DarkGray }
function Write-Warn2($msg){ Write-Host "    !!  $msg" -ForegroundColor Yellow }

function Get-ClaudeCli {
    $cmd = Get-Command claude -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # Desktop app ships the CLI outside PATH.
    $roots = @(
        (Join-Path $env:APPDATA  'Claude\claude-code'),
        (Join-Path $env:LOCALAPPDATA 'Claude\claude-code')
    )
    foreach ($root in $roots) {
        if (Test-Path $root) {
            $exe = Get-ChildItem -Path $root -Filter 'claude.exe' -Recurse -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime | Select-Object -Last 1
            if ($exe) { return $exe.FullName }
        }
    }
    return $null
}

$Claude = Get-ClaudeCli
if (-not $Claude) {
    Write-Error "Claude Code CLI not found. Install Claude Code first, then re-run this script."
    exit 1
}
Write-Step "Claude Code CLI: $Claude"
& $Claude --version | ForEach-Object { Write-Ok $_ }

$manifest = Get-Content (Join-Path $RepoRoot 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json

# ---------------------------------------------------------------- marketplaces
Write-Step 'Registering marketplaces'
$existingMarkets = (& $Claude plugin marketplace list 2>&1) -join "`n"
foreach ($p in $manifest.marketplaces.PSObject.Properties) {
    if ($existingMarkets -match [regex]::Escape($p.Name)) {
        Write-Skip "$($p.Name) already registered"
        continue
    }
    try {
        & $Claude plugin marketplace add $p.Value | Out-Null
        Write-Ok "$($p.Name)  <-  $($p.Value)"
    } catch {
        Write-Warn2 "$($p.Name): $($_.Exception.Message)"
    }
}

# this repository is its own marketplace
if ($existingMarkets -match 'skills-ai') {
    Write-Skip 'skills-ai already registered'
} else {
    try {
        & $Claude plugin marketplace add $RepoRoot | Out-Null
        Write-Ok "skills-ai  <-  $RepoRoot"
    } catch {
        Write-Warn2 "skills-ai: $($_.Exception.Message)"
    }
}

# -------------------------------------------------------------------- plugins
if ($Refresh) {
    Write-Step 'Refreshing the skills-ai plugin from this working copy'
    try { & $Claude plugin marketplace update skills-ai | Out-Null } catch { }
    try { & $Claude plugin uninstall skills-ai@skills-ai | Out-Null; Write-Ok 'cache cleared' } catch { Write-Skip 'nothing cached' }
}

if (-not $SkipPlugins) {
    Write-Step 'Installing plugins'
    $installed = (& $Claude plugin list 2>&1) -join "`n"
    $wanted = @($manifest.plugins) + @('skills-ai@skills-ai')
    foreach ($plugin in $wanted) {
        if ($installed -match [regex]::Escape($plugin)) {
            Write-Skip "$plugin already installed"
            continue
        }
        try {
            & $Claude plugin install $plugin | Out-Null
            Write-Ok $plugin
        } catch {
            Write-Warn2 "$plugin : $($_.Exception.Message)"
        }
    }
}

# ---------------------------------------------------------------- mcp servers
if (-not $SkipMcp) {
    Write-Step 'Registering MCP servers'
    $mcpList = (& $Claude mcp list 2>&1) -join "`n"
    foreach ($s in $manifest.mcpServers.PSObject.Properties) {
        $name = $s.Name
        $cfg  = $s.Value
        if ($mcpList -match "(?m)^\s*$([regex]::Escape($name))\s*:") {
            Write-Skip "$name already configured"
            continue
        }
        try {
            if ($cfg.transport -eq 'http') {
                & $Claude mcp add --transport http --scope user $name $cfg.url | Out-Null
            } else {
                $argv = @('mcp','add','--scope','user',$name,'--',$cfg.command) + @($cfg.args)
                & $Claude @argv | Out-Null
            }
            Write-Ok $name
        } catch {
            Write-Warn2 "$name : $($_.Exception.Message)"
        }
    }
}

Write-Host ''
Write-Host 'Done. Restart Claude Code to load the new skills, plugins and hooks.' -ForegroundColor Green
Write-Host 'The startup digest appears automatically; /skills-brief shows it again.' -ForegroundColor Green
