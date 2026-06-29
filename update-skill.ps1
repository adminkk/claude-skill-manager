$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Claude Skill Updater v2.1"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$ProjectDir = (Get-Location).Path
$SkillDir = Join-Path $ProjectDir ".claude\skills"

New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

$temp = Join-Path $env:TEMP ("claude-skill-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $temp | Out-Null

$Success = 0
$Failed = 0
$Skipped = 0

##################################################
# 下载 Github ZIP
##################################################

function Download-GitHubZip {

    param(
        [string]$Repo,
        [string]$Branch = "main",
        [string]$OutFile
    )

    $urls = @(
        "https://github.com/$Repo/archive/refs/heads/$Branch.zip",
        "https://ghfast.top/https://github.com/$Repo/archive/refs/heads/$Branch.zip",
        "https://ghproxy.com/https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    )

    foreach ($url in $urls) {

        Write-Host "Trying $url"

        try {

            Invoke-WebRequest `
                -Uri $url `
                -OutFile $OutFile `
                -UseBasicParsing

            return $true

        }
        catch {

            Write-Warning "Failed."

        }

    }

    return $false

}

##################################################
# Superpowers
##################################################

Write-Host ""
Write-Host "Updating Superpowers..." -ForegroundColor Cyan

try {

    $zip = Join-Path $temp "superpowers.zip"

    if (!(Download-GitHubZip `
        -Repo "obra/superpowers" `
        -OutFile $zip)) {

        throw "Download failed."

    }

    Expand-Archive `
        -Path $zip `
        -DestinationPath $temp `
        -Force

    $src = Join-Path $temp "superpowers-main\skills"

    if (!(Test-Path $src)) {

        throw "skills folder not found."

    }

    Copy-Item `
        "$src\*" `
        $SkillDir `
        -Force `
        -Recurse

    Write-Host "✓ Superpowers Updated." -ForegroundColor Green

    $Success++

}
catch {

    Write-Warning $_

    $Failed++

}

##################################################
# OpenSpec CLI
##################################################

Write-Host ""
Write-Host "Checking OpenSpec..." -ForegroundColor Cyan

$npm = Get-Command npm.cmd -ErrorAction SilentlyContinue

if ($null -eq $npm) {

    Write-Warning "npm not installed."

    $Skipped++

}
else {

    try {

        Write-Host "Updating OpenSpec CLI..."

        cmd /c "npm install -g @fission-ai/openspec@latest"

        if ($LASTEXITCODE -ne 0) {

            throw "npm install failed."

        }

        Write-Host "✓ OpenSpec CLI Updated." -ForegroundColor Green

        $Success++

    }
    catch {

        Write-Warning $_

        $Failed++

    }

}

##################################################
# OpenSpec Project
##################################################

Write-Host ""
Write-Host "Checking OpenSpec Project..." -ForegroundColor Cyan

$IsOpenSpecProject = $false

if (Test-Path (Join-Path $ProjectDir ".openspec")) {

    $IsOpenSpecProject = $true

}

if (Test-Path (Join-Path $ProjectDir "openspec")) {

    $IsOpenSpecProject = $true

}

if ($IsOpenSpecProject) {

    try {

        Push-Location $ProjectDir

        cmd /c "openspec update"

        Pop-Location

        if ($LASTEXITCODE -ne 0) {

            throw "openspec update failed."

        }

        Write-Host "✓ OpenSpec Project Updated." -ForegroundColor Green

        $Success++

    }
    catch {

        Write-Warning $_

        $Failed++

    }

}
else {

    try {

        Write-Host "Current directory is not an OpenSpec project."

        Write-Host "Initializing OpenSpec Project..."

        Push-Location $ProjectDir

        cmd /c "openspec init"

        Pop-Location

        if ($LASTEXITCODE -ne 0) {

            throw "openspec init failed."

        }

        Write-Host "✓ OpenSpec Project Initialized." -ForegroundColor Green

        $Success++

    }
    catch {

        Write-Warning $_

        $Failed++

    }

}

##################################################
# Cleanup
##################################################

try {

    Remove-Item `
        $temp `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

}
catch {

}

##################################################
# Result
##################################################

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Update Finished"
Write-Host "------------------------------------------"
Write-Host ("Success : {0}" -f $Success) -ForegroundColor Green
Write-Host ("Skipped : {0}" -f $Skipped) -ForegroundColor Yellow
Write-Host ("Failed  : {0}" -f $Failed) -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
