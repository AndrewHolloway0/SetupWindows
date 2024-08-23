$host.ui.RawUI.WindowTitle = "Profile Setup"

# Get Any Params
param (
  [string] $Client,
  [switch] $noInterrupt
)

$greenCheck = "$([char]0x1b)[92m$([char]8730) $([char]0x1b)[91x"

# Set Separator for script
$banner = "`n-----------------------------------`n"
Clear-Host

# Self-elevate the script if required
Write-Host "Elevating Script..."
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
} else {
  Write-Host "Script already running as Administrator"
}

# Install Chocolatey
Write-Host "Installing application manager (Chocolatey)..."
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


# Disable App Protections
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UCPD" -Name "Start" -Value 4 -PropertyType DWORD -Force
# Disable-ScheduledTask -TaskName "\Microsoft\Windows\AppxDeploymentClient\UCPD velocity"


# Set App Associations
## Get AppID - Need ProgID, not AppID
$extHttpVal = Get-StartApps | Where-Object -Property Name -like "Google Chrome" | %{$_.AppID}
$extPdfVal = Get-StartApps | Where-Object -Property Name -like "Adobe Reader" | %{$_.AppID}
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name ProgId -Value $extHttpVal
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name ProgId -Value $extHttpVal

choco install SetUserFTA -y #set install location? C:/temp

# Clear the screen
Clear-Host


cd "C:\ProgramData\chocolatey\lib\setuserfta\tools\SetUserFTA"
SetUserFTA.exe pdf appid
Write-Host "$greenCheck Default Apps Set"
#mailto, msg, http, https, html, htm, pdf,
# VivaldiHTM.RFV3KO7C2XXGW6YLORAWURBUAM - ProgID for Vivaldi Browser


# Taskbar Alignment to Left
Set-ItemProperty -Path HKCU:\software\microsoft\windows\currentversion\explorer\advanced -Name 'TaskbarAl' -Type 'DWord' -Value 0
Write-Host "$greenCheck Taskbar Alignment Set"

# Taskbar searchbar to small
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 1
Write-Host "$greenCheck Taskbar Searchbar Size Set"

# Taskbar Pins - https://learn.microsoft.com/en-us/windows/configuration/taskbar/pinned-apps
$taskbarPinXML = '<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:UWA AppUserModelID="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" />
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
    </defaultlayout:TaskbarLayout>
 </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>'

# New-Item -Path "C:\Windows\OEM\"
# Out-File -FilePath "C:\Windows\OEM\TaskbarLayoutModification.xml" -InputObject $taskbarPinXML

# cmd /c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ /v LayoutXMLPath /d C:\Windows\OEM\TaskbarLayoutModification.xml

# Sleep settings - Integer equals minutes
Powercfg /Change monitor-timeout-ac 45 # Set screen timeout on wall-power
Powercfg /Change monitor-timeout-dc 20 # Set screen timeout on battery
Powercfg /Change standby-timeout-ac 0 # Set device sleep on wall-power
Powercfg /Change standby-timeout-dc 60 # Set device sleep on battery
Write-Host "$greenCheck Sleep and Screen Timeout Settings Set" -ForegroundColor Green

# System Locale
Set-WinSystemLocale en-AU
Write-Host "$greenCheck System Locale Set" -ForegroundColor Green

# Keyboard Layout
$LangList = Get-WinUserLanguageList # Get current list of installed languages
$LangList.Add("en-AU") # Install en-US Keyboard layout
$MarkedLang = $LangList | Where-Object LanguageTag -notlike "*en-AU*" # Find all other Language Keyboards
$LangList.Remove($MarkedLang) | Out-Null # Remove all other Language Keyboards
Set-WinUserLanguageList $LangList -Force # Activate keyboard changes
Write-Host "$greenCheck Keyboard Layout Set"

# Timezone (regular)
tzutil /s "W. Australia Standard Time" # Set timezone to GMT+0800
Write-Host "$greenCheck Timezone Set"

# Date n Time format
$culture = Get-Culture
$culture.DateTimeFormat.ShortDatePattern = 'dd/MM/yyyy'
Set-Culture $culture