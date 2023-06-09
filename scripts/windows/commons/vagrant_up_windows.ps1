<#
.Synopsis
   Up lab for learning
.DESCRIPTION
   Set Vagrantfile for KVM server
   Set folder of virtualbox VM's
   Create a semafore for vagrant up
   Copy public key for vagrant shared folder
   This script is used for create a new lab with vagrant.
   Create all VM's in Vagrantfile  
   Copy all private key of VM's for F:\Projetos\vagrant_pk folder   
.EXAMPLE
   & vagrant_up_windows.ps1
#>

# Execute script as Administrator
# if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {  
#    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
#    Start-Process -Wait powershell -Verb runAs -WindowStyle Hidden -ArgumentList $arguments
#    Break
# }

# Clear screen
Clear-Host

#Stop vagrant process
Get-Process -Name *vagrant* | Stop-Process -Force
Get-Process -Name *ruby* | Stop-Process -Force

# Semafore for vagrant process
$scriptPath = $PSScriptRoot
$semafore = "$scriptPath\vagrant-up.silvestrini"
New-Item -ItemType File -Path $semafore -Force >$null

# SSH
$ssh_path = "$( (($scriptPath | Split-Path -Parent)| Split-Path -Parent) | Split-Path -Parent)\security"
Copy-Item -Force "$env:USERPROFILE\.ssh\id_ecdsa.pub" -Destination $ssh_path

# VM name
$vmName="rock-kvm-server01"

# Define environment for labs(notebook, desktop)
switch ($(hostname)) {
   "silvestrini" {
      # Variables
      $virtualboxFolder = "E:\Apps\VirtualBox"
      $virtualboxVMFolder = "E:\Servers\VirtualBox"
      $vagrantStorage="E:/Servers/Virtualbox/Storage/$vmName"
      $vagrantMemory=50000
      $vagrantCPU=24
      $vagranExtraDiskSize="100"      
      $vagrant = "E:\Apps\Vagrant\bin\vagrant.exe"
      $vagrantHome = "E:\Apps\Vagrant\vagrant.d"  
      $baseProject = "F:\Projetos\learning-kvm"          
      $baseVagrantfile = "$baseProject\vagrant\linux"                  
      $vagrantPK = "F:\Projetos\vagrant-pk"      
   }
   "silvestrini2" {      
      # Variables
      $virtualboxFolder = "C:\Program Files\Oracle\VirtualBox"
      $virtualboxVMFolder = "D:\Cloud\VirtualBox"
      $vagrantStorage="D:/Cloud/VirtualBox/Storage/$vmName"
      $vagrantMemory=27000
      $vagrantCPU=8
      $vagranExtraDiskSize="80"
      $vagrant = "D:\Cloud\Vagrant\bin\vagrant.exe"
      $vagrantHome = "D:\Cloud\Vagrant\.vagrant.d"             
      $baseProject = "F:\Projetos\learning-kvm"                
      $baseVagrantfile = "$baseProject\vagrant\linux"         
      $vagrantPK = "F:\Projetos\vagrant-pk"      
      
   }
   Default { Write-Host "This hostname is not available for execution this script!!!"; exit 1 }
}

# VirtualBox home directory.
Start-Process -Wait -NoNewWindow -FilePath "$virtualboxFolder\VBoxManage.exe" `
   -ArgumentList  @("setproperty", "machinefolder", "$virtualboxVMFolder")

# Vagrant home directory for downloadad boxes.
setx VAGRANT_HOME "$vagrantHome" >$null

# Set vagrant values for kvm server
$vagrantTemplateFile = "$baseVagrantfile\templates\kvm"      
$vagrantTemplate="$baseVagrantfile\Vagrantfile"   
Get-Content $vagrantTemplateFile | ForEach-Object{
   $_ -replace "VAGRANT_MEMORY",$vagrantMemory `
      -replace "VAGRANT_CPU",$vagrantCPU `
      -replace "PATH_STORAGE",$vagrantStorage `
      -replace "EXTRA_DISK_SIZE",$vagranExtraDiskSize
      
} | Set-Content $vagrantTemplate -Force

# Up kvm stack
$kvm = "$baseVagrantfile"
Set-Location $kvm
vagrant up
#Start-Process -Wait -WindowStyle Minimized -FilePath $vagrant -ArgumentList "up"  -Verb runAs
Copy-Item .\.vagrant\machines\rock-kvm-server01\virtualbox\private_key "$vagrantPK\$vmName"

# Fix powershell error
$Env:VAGRANT_PREFER_SYSTEM_BIN += 0

#Remove Semafore
Remove-Item -Force $semafore