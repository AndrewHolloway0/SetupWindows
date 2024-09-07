# Get Passed Params
param (
  [string] $AppSet,
  [switch] $noInterrupt
)

# Set Script Icons
$greenCheck = "$([char]8730)"

# Set Window Title
$host.ui.RawUI.WindowTitle = "PC Setup Script - Script by Andrew Holloway"

# Set user changeable printouts
$outputLocation = "C:\temp\windowsSetuplog.txt" # Script output file
$banner = "`n-----------------------------------`n" # Set Separator for script

# Clear the screen
Clear-Host

# Self-elevate the script if required
Write-Host "Testing if prompt is running as administrator..."
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
} else {
    Write-Host "Script already running as Administrator"
}

# Start writing script output to file
Start-Transcript -Path $outputLocation

# Advise user of output file and allow choosing to run apps
Write-Host $banner
Write-Host "System wide changes will apply..."
$continueWithProfSettings = Read-Host "Set profile settings as well? (Y/n)"

# Sleep settings - Integer equals minutes
Powercfg /Change monitor-timeout-ac 45 # Set screen timeout on wall-power
Powercfg /Change monitor-timeout-dc 20 # Set screen timeout on battery
Powercfg /Change standby-timeout-ac 0 # Set device sleep on wall-power
Powercfg /Change standby-timeout-dc 60 # Set device sleep on battery
Write-Host "$greenCheck Sleep and Screen Timeout Settings Set" -ForegroundColor Green

# Taskbar Alignment to Left
Set-ItemProperty -Path HKCU:\software\microsoft\windows\currentversion\explorer\advanced -Name 'TaskbarAl' -Type 'DWord' -Value 0
Write-Host "$greenCheck Taskbar Alignment Set" -ForegroundColor Green

# Taskbar searchbar to small
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 1
Write-Host "$greenCheck Taskbar Searchbar Size Set" -ForegroundColor Green

# Check if user is 
if($continueWithProfSettings -like "n" || !$noInterrupt) {
    Write-Host "Installing apps was not selected. Terminating."
    Return 0
}

Write-Host "Setting profile settings"

Stop-Transcript
pause