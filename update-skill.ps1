$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Claude Skill Updater v2.0"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$ProjectDir = Get-Location
$SkillDir = Join-Path $ProjectDir ".claude\skills"

New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

$temp = Join-Path $env:TEMP ("claude-skill-" + [guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $temp | Out-Null

##################################################
# 下载 GitHub ZIP（自动切换下载源）
##################################################
function Download-GitHubZip {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [string]$Branch = "main",

        [Parameter(Mandatory = $true)]
        [string]$OutFile
    )

    $urls = @(
        "https://github.com/$Repo/archive/refs/heads/$Branch.zip",
        "https://ghfast.top/https://github.com/$Repo/archive/refs/heads/$Branch.zip",
        "https://ghproxy.com/https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    )

    foreach ($url in $urls) {

        Write-Host "Trying: $url"

        try {

            Invoke-WebRequest `
                -Uri $url `
                -OutFile $OutFile `
                -UseBasicParsing

            Write-Host "Download Success." -ForegroundColor Green
            return $true
        }
        catch {

            Write-Warning "Failed."

        }
    }

    return $false
}

##################################################
# 更新 Superpowers
##################################################

Write-Host ""
Write-Host "Updating Superpowers..." -ForegroundColor Cyan

try {

    $zip = Join-Path $temp "superpowers.zip"

    $ok = Download-GitHubZip `
        -Repo "obra/superpowers" `
        -OutFile $zip

    if (-not $ok) {
        throw "Unable to download Superpowers."
    }

    Expand-Archive `
        -Path $zip `
        -DestinationPath $temp `
        -Force

    $skillSource = Join-Path $temp "superpowers-main\skills"

    if (!(Test-Path $skillSource)) {
        throw "skills directory not found."
    }

    Copy-Item `
        "$skillSource\*" `
        $SkillDir `
        -Recurse `
        -Force

    Write-Host "✓ Superpowers Updated." -ForegroundColor Green

}
catch {

    Write-Warning $_

}

##################################################
# 更新 OpenSpec
##################################################

Write-Host ""
Write-Host "Updating OpenSpec..." -ForegroundColor Cyan

try {

    $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue

    if ($null -eq $npm) {

        Write-Warning "npm not found. Skip OpenSpec."

    }
    else {

        Write-Host "Installing latest OpenSpec..."

        cmd /c "npm install -g @fission-ai/openspec@latest"

        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed."
        }

        Push-Location $ProjectDir

        Write-Host "Running openspec update..."

        cmd /c "openspec update"

        Pop-Location

        if ($LASTEXITCODE -ne 0) {
            throw "openspec update failed."
        }

        Write-Host "✓ OpenSpec Updated." -ForegroundColor Green

    }

}
catch {

    Write-Warning $_

}

##################################################
# 清理
##################################################

try {

    if (Test-Path $temp) {

        Remove-Item `
            $temp `
            -Recurse `
            -Force

    }

}
catch {

}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " All Skills Updated Successfully!"
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
