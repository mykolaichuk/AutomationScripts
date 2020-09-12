#-------------------- Input Data -------------------#
$hostname = Read-Host "Enter hostname"
#----------------- Personalization -----------------#
Write-Host "Configuring system settings" -ForegroundColor Green

Write-Host "Applying Dark Theme" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Verbose

Write-Host "Applying small taskbar icons" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarSmallIcons -Value 1 -Verbose

Write-Host "Disabling theme transparency" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name EnableTransparency -Value 0 -Verbose

Write-Host "Enabling clipboard history" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Clipboard -Name EnableClipboardHistory -Value 1 -Verbose

Write-Host "Setting This PC as default location for Explorer" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1 -Verbose

Write-Host "Display file extensions" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0 -Verbose

Write-Host "Adding This PC icon to the desktop" -ForegroundColor Green
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Verbose

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name AUOptions -Value 3

#Only for this setting I had to check path
Write-Host "Changing Windows Update Pilicy" -ForegroundColor Green
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$Name = "AUOptions"
$value = "2"
IF(!(Test-Path $registryPath))
  {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null}
 ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null}

Write-Host "Restarting Explorer" -ForegroundColor Green
Stop-Process -ProcessName explorer

#----------------- Powerplan -----------------#
Write-Host "Disabling display turn off and sleep timeout" -ForegroundColor Green
powercfg -change -monitor-timeout-dc 0
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-dc 0
powercfg -change -standby-timeout-ac 0

Write-Host "Changing powerplan to High Performance" -ForegroundColor Green
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

#----------------- Hostname -----------------#
Write-Host "Changing hostname to $hostname"
Rename-Computer -NewName $hostname

#----------------- Installing software -----------------#
Write-Host "Installing software" -ForegroundColor Green

Write-Host "Installing Chocolatey" -ForegroundColor Green
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$software = 'Visual Studio Code', `
    'VirtualBox', `
    'VirtualBox Guest Additions', `
    'Google Chrome', `
    'Microsoft teams', `
    'Telegram', `
    'Viber', `
    'Vagrant', `
    'Terraform', `
    'Git', `
    'Windows Terminal', `
    'Azure PowerShell', `
    'Azure CLI', `
    'Keepass', `
    'Monosnap', `
    'Lightshot', `
    'WMI Explorer', `
    'Spotify', `
    'Microsoft .NET Core', `
    'Powertoys', `
    'WPS Office', `
    'Logitech Options', `
    'utorrent', `
    '7zip', `
    'Deskpins', `
    'Docker Desktop'
    
Write-Host "Current software is about to be installed:" -ForegroundColor Green; $software

Write-Host "Press `"Enter`" to continue or `"Ctrl-C`" to cancel"
do
{
$key = [Console]::ReadKey("noecho")
}
while($key.Key -ne "Enter")
Write-Host "Complete"

Write-Host "Continuing the installation" -ForegroundColor Green

choco install -y `
    microsoft-teams `
    telegram `
    viber `
    virtualbox `
    virtualbox-guest-additions-guest.install`
    googlechrome `
    vagrant `
    git `
    microsoft-windows-terminal `
    vscode `
    terraform `
    azure-cli `
    keepass `
    monosnap `
    lightshot `
    wmiexplorer `
    spotify `
    dotnetcore `
    powertoys `
    wps-office-free `
    logitech-options `
    utorrent `
    7zip `
    deskpins `
    docker-desktop

Install-Module -Name Az -AllowClobber -Scope AllUsers -Verbose

#----------------- Installing ELAN driver -----------------#
Invoke-WebRequest -Uri "https://download.lenovo.com/pccbbs/mobiles/r0hgf10w.exe" -OutFile $env:TEMP\r0hgf10w.exe -UseBasicParsing; Set-Location $env:TEMP; .\r0hgf10w.exe /SP-; rm $env:TEMP\r0hgf10w.exe
Write-Host -ForegroundColor Yellow "Now choose ETD.inf in Device settings"
Write-Host -ForegroundColor Yellow "Go to the https://www.youtube.com/watch?v=f2rfwR-IV-c to view the details"
Write-Host -ForegroundColor Yellow "To disallow driver update follow this guide: https://bit.ly/3igwfYc"

#----------------- VS Code extensions -----------------#
Write-Host "Installing VS Code extenstions" -ForegroundColor Green
code --install-extension ms-vscode.powershell
code --install-extension ms-azuretools.vscode-docker
code --install-extension hashicorp.terraform
code --install-extension bbenoist.vagrant
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension redhat.vscode-yaml
code --install-extension ms-azuretools.vscode-azureappservice

#----------------- Enable Telnet -----------------#
dism /online /Enable-Feature /FeatureName:TelnetClient

#----------------- Enable WSL -----------------#
Write-Host "Enabling WSL" -ForegroundColor Green
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Write-Host "Enabling Virtual Machine Platform" -ForegroundColor Green
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Host "WSL 2 kernel update" -ForegroundColor Green
Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -Outfile $env:TEMP\wslupdate.msi; Start-Process msiexec.exe -Verbose -Wait -ArgumentList "/I $env:TEMP\wslupdate.msi"; rm $env:TEMP\wslupdate.msi

Write-Host "Setting WSL2 as defaul" -ForegroundColor Green
wsl --set-default-version 2

Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2004" -OutFile $env:TEMP\Ubuntu.appx -UseBasicParsing; Add-AppxPackage $env:TEMP\Ubuntu.appx; rm $env:TEMP\Ubuntu.appx