# Execute script as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process -Wait powershell -Verb runAs -WindowStyle Hidden -ArgumentList $arguments
  Break
}

$scriptPath=$PSScriptRoot
$repository=(($scriptPath | Split-Path -Parent)|Split-Path -Parent)|Split-Path -Parent
Set-Location $repository
Get-Process -Name *git* | Stop-Process -Force
git checkout main
git pull
git status
$out = git status
$check = $null
$check = $out | Select-String -Pattern "untracked", "modified"
If ($null -ne $check ) {
    Get-Process -Name *git* | Stop-Process -Force
    Write-Host -ForegroundColor Red "Uncommitted files found"
    #$commit = Read-Host -Prompt "Enter comment for commit"
    $commit = "Update files for class today"
    git add .
    git commit -m $commit
    git push origin main
    $out = git status
    $check = $null
    $check = $out | Select-String -Pattern "untracked"
    If ($null -ne $check ) {
        Write-Host -ForegroundColor Red "Commit failed!!!"
    }
    Else {
        Write-Host -ForegroundColor Green "Commit Success!!!"
    }
}