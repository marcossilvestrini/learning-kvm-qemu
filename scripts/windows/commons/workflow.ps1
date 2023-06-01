# Script for executin pipeline for build ant test


# Execute script as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process -Wait powershell -Verb runAs -WindowStyle Hidden -ArgumentList $arguments
  Break
}


# Script for executin pipeline for build and test
$scriptPath=$PSScriptRoot
$semafore="$scriptPath\vagrant-up.silvestrini"
$timeout=0
While( Test-Path $semafore ){    
    $timeout++
    Start-Sleep 1
    If($timeout -gt 300){break;}
}
$scriptPath=$PSScriptRoot
$file="$scriptPath\workflow.txt"
$repository=((($file | Split-Path -Parent)|Split-Path -Parent)|Split-Path -Parent) | Split-Path -Parent
New-Item -ItemType File -Path $file -Force >$null
Add-Content -Path $file -Value "Start Trigger Pipelines..."
$start = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
Add-Content -Path $file -Value $start
Set-Location $repository
git config --global --add safe.directory $repository
git config --global user.email "marcos.silvestrini@gmail.com"
git config --global user.name "marcos.silvestrini"
git pull origin main
git add .
git commit -m "Start Pepilines"
git push origin main
