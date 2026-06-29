```powershell
$ErrorActionPreference = "Stop"

# ==============================
# Claude Skill Updater
# ==============================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Claude Skill Updater v1.0"
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
        [string]$Repo,
        [string]$Branch,
        [string]$OutFile
    )

    $urls = @(
        "https://github.com/$Repo/archive/refs/heads/$Branch.zip",
        "https://ghfast.top/https://github.com/$Repo/archive/refs/heads/$Branch.zip",
        "https://ghproxy.com/https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    )

    foreach($url in $urls){

        Write-Host "Trying: $url"

        try{
            Invoke-WebRequest `
                -Uri $url `
                -OutFile $OutFile `
                -UseBasicParsing

            Write-Host "Download Success" -ForegroundColor Green
            return
        }
        catch{
            Write-Warning "Failed."
        }
    }

    throw "Download failed from all mirrors."
}

##################################################
# 更新 Superpowers
##################################################

Write-Host ""
Write-Host "Updating Superpowers..." -ForegroundColor Cyan

$zip = Join-Path $temp "superpowers.zip"

Download-GitHubZip `
    -Repo "obra/superpowers" `
    -Branch "main" `
    -OutFile $zip

Expand-Archive `
    -Path $zip `
    -DestinationPath $temp `
    -Force

$skillSource = Join-Path $temp "superpowers-main\skills"

if(Test-Path $skillSource){

    Copy-Item `
        "$skillSource\*" `
        $SkillDir `
        -Recurse `
        -Force

    Write-Host "Superpowers Updated." -ForegroundColor Green
}
else{

    Write-Warning "Superpowers skills folder not found."

}

##################################################
# 更新 OpenSpec
##################################################

Write-Host ""
Write-Host "Updating OpenSpec..." -ForegroundColor Cyan

if(Get-Command npm -ErrorAction SilentlyContinue){

    npm install -g @fission-ai/openspec@latest

    if(Get-Command openspec -ErrorAction SilentlyContinue){

        Push-Location $ProjectDir

        openspec update

        Pop-Location

        Write-Host "OpenSpec Updated." -ForegroundColor Green

    }else{

        Write-Warning "OpenSpec command not found."

    }

}else{

    Write-Warning "npm not found, skip OpenSpec."

}

##################################################
# 清理
##################################################

Remove-Item `
    $temp `
    -Recurse `
    -Force

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host " All Skills Updated Successfully!"
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
```
