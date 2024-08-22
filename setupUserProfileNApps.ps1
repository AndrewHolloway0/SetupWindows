# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Programs
choco install adobereader -y
choco install googlechrome -y
choco install firefox -y
choco install 7zip -y
choco install dotnet-8.0-runtime -y
# Optional Programs
$webex = Read-Host "Install Webex? (y/N)"
$googledrive = Read-Host "Install Google Drive? (y/N)"
$treesize = Read-Host "Install TreeSize? (y/N)"
$ipscan = Read-Host "Install IP Scanner? (y/N)"
$gotomeeting = Read-Host "Install GoToMeeting? (y/N)"
$gwsmo = Read-Host "Install GWSMO (Google Workspace for Outlook)? (y/N)"
if($webex -like "y") { choco install webex-meetings -y }
if($googledrive -like "y") { choco install googledrive -y }
if($treesize -like "y") { choco install treesizefree -y }
if($ipscan -like "y") { choco install advanced-ip-scanner -y }
if($gotomeeting -like "y") { choco install gotomeeting -y }
if($gwsmo -like "y") { choco install gsuite-sync-outlook -y }

# Disable App Protections
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UCPD" -Name "Start" -Value 4 -PropertyType DWORD -Force
Disable-ScheduledTask -TaskName "\Microsoft\Windows\AppxDeploymentClient\UCPD velocity"


# Set App Associations
## Get AppID - Need ProgID, not AppID
$extHttpVal = Get-StartApps | Where-Object -Property Name -like "Google Chrome" | %{$_.AppID}
$extPdfVal = Get-StartApps | Where-Object -Property Name -like "Adobe Reader" | %{$_.AppID}
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name ProgId -Value $extHttpVal
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name ProgId -Value $extHttpVal

choco install SetUserFTA -y #set install location? C:/temp
cd "C:\ProgramData\chocolatey\lib\setuserfta\tools\SetUserFTA"
SetUserFTA.exe pdf appid
#mailto, msg, http, https, html, htm, pdf,
# VivaldiHTM.RFV3KO7C2XXGW6YLORAWURBUAM - ProgID for Vivaldi Browser


# Taskbar Alignment

# Taskbar Pins

# 