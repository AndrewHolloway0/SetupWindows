# Get Passed Params
param (
  [string] $AppSet,
  [switch] $noInterrupt
)

$greenCheck = "$([char]0x1b)[92m$([char]8730) $([char]0x1b)[91x"

# Set Window Title
$host.ui.RawUI.WindowTitle = "App Installations"

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
    } else {
        Write-Host "Script already running as Administrator"
    }
}

# Install Chocolatey
Write-Host "Installing application manager (Chocolatey)..."
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Clear the screen
Clear-Host

# Create Chosen Apps Array - Add default Chocolatey-Package-ID's here
$chosenApps = 'adobereader','googlechrome','firefox','7zip','dotnet-8.0-runtime','treesizefree','imageresizerapp','seamonkey','microsoft-teams-new-bootstrapper', 'sysinternals'

# List of optional applications
$optAppCollection = @{ # [App Title] = [Chocolatey-Package-ID]
    "Webex" = "webex-meetings";
    "Keeper" = "keeper";
    "Zoom" = "zoom";
    "Jabra Direct" = "jabra-direct";
    "VLC" = "vlc";
    "GWSMO" = "gsuite-sync-outlook";
    "Google Drive" = "googledrive";
    "GoToMeeting" = "gotomeeting";
    "IP Scanner" = "advanced-ip-scanner";
    "Wireshark" = "wireshark usbpcap";
}

# Client List with required App Options - Format: @{ "[Client Name]" = "[App Title]" }
$appCollection = .\appCollection.ps1

# Manage App Installation Choices
if($AppSet -and @($appCollection.keys) -contains $AppSet) { # if -AppSet was provided AND -AppSet value is a valid option contained within $appCollection
    foreach ($app in $appCollection.$Client) { # Loop through -AppSet applications
        $chosenApps += $optAppCollection.$app # Add associated app Chocolatey-Package-ID to $chosenApps
    }
}
if(!$noInterrupt) { # If -NoInterrupt was not provided
    for ($i=0; $i -lt $optAppCollection.count; $i++) { # Loop through all app options
        if($chosenApps -notcontains @($optAppCollection.values)[$i]) { # Confirm app is not already in $chosenApps
            $installApp = Read-Host "Install" @($optAppCollection.keys)[$i]"? (Y/n)" # Ask operator to confirm install
            if ($installApp -like "y") { $chosenApps += @($optAppCollection.values)[$i] } # Add app to $chosenApps if response was yes
        }
    }
}

# Install Applications
Write-Host $banner
Write-Host "Application installation starts..."
foreach ($item in $chosenApps) { # Loop through every item in $chosenApps
    $switch = if($item -eq "googlechrome") { " --ignore-checksums" } # If Google Chrome is being installed, add "--ignore-checksums". Error in choco has old checksum.
    Write-Host "Installing $item!" -foregroundcolor "yellow" # Print to screen
    choco install $item -y # Initiate Chocolatey to install the application
}

# Download ScreenConnect installer
$SCdomain = .\SCdomain.ps1 # Get Domain URL
Write-Host "Installing ScreenConnect!" -ForegroundColor yellow
curl "https://$SCdomain/Bin/ScreenConnect.ClientSetup.exe?e=Access&y=Guest" -o "$env:userprofile\Downloads\screenconnect.clientsetup.exe"
Start-Process "$env:userprofile\Downloads\screenconnect.clientsetup.exe"
Write-Host "$greenCheck ScreenConnect Installed! - Find this device under the 'No Company' tab!" -ForegroundColor Green


# Install Chrome Extentions -#- IN PROGRESS DOES NOT WORK
# $chromeExtList = @{ # Chrome Extention IDs
#     "Keeper" = "bfogiafebfohielmmehodmfbbebbbpei";
# }
# $chromeExtRegKey = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist"
# foreach($extention in $chromeExtList) {
#     $extentionName = $extention.keys;
#     # Write-Host @($optAppCollection.values)[$extentionName]
#     # Write-Host $optAppCollection.values
#     Write-Host $optAppCollection[$extentionName]
#     Write-Host $optAppCollection[$extentionName][1] "is in ($chosenApps)"
#     if($chosenApps -contains $optAppCollection[$extentionName]) {
#         # Set-ItemProperty -Path $chromeExtRegKey -Name '1' -Type 'REG_SZ' -Value $extention.values
#         Write-Host "Adding" $extention.keys "to Chrome"
#     }
# }

# loop through chosenApps
# use optAppCollection to reverse the name to ID - $optAppCollection | Where-Object { $_.Keys -eq $extentionName }
# if selectedApp is in chromeExtList
# install extention

# loop through google extentions
# use optAppCollection to reverse the Name to ID - $optAppCollection[$extentionName]
# if selectedApp is in chromeExtList
# install extention