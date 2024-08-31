# Lets Skip the Boring Bit! 🤪
This is a collection of Windows scripts to make it easy to setup Windows. This includes application installation, taskbar settings, start menu changes, locale settings, default applications, and more coming soon!

## Prerequisites
You may not be able to run the `.ps1` script directly on the system due to your Execution Policy. You can run the `start.bat` file making it easy begin. It'll only run the `installApps.ps1` script by default.

Alternatively, you can run the following in an Administrator Powershell window to allow execution of scripts on your system permanently (Not Recommended).

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass
```

## Getting Started
1. Download the codebase as a `.ZIP`.
2. Run `start.bat` OR one or both of the below commands in a regular CMD window.

```batch
powershell -noexit -ExecutionPolicy Bypass -File installApps.ps1
```
```batch
powershell -noexit -ExecutionPolicy Bypass -File setupProfile.ps1
```

## Full Automation
The scripts accept two optional switch parameters which allow setting up 'sets' of programs to install and not asking the operator to confirm installation. They are `-AppSet` and `-NoInterrupt` respectively.

You can run the following command to install basic applications without prompting for the optional programs.

```batch
powershell -noexit -ExecutionPolicy Bypass -File installApps.ps1 -NoInterrupt
```

Alternatively, you can run the following to install basic applications, plus CustomSet1 (defined in the `appCollection.ps1` file), without interruptions.

```batch
powershell -noexit -ExecutionPolicy Bypass -File installApps.ps1 -NoInterrupt -AppSet CustomSet1
```

### Creating a Custom Application Set
Sets of optional applications are defined in the `appCollection.ps1` file. This file must be placed in the same root directory as the `installApps.ps1` script is being run. The format of the file must be a valid [Hash Table](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.4).

### Defining Applications
Application names and associated chocolatey package names are located in the `installApps.ps1` script. Simply add additional line or two with optional packages, the script will then ask if you want to install it on the next execution.

<hr/>

This script uses and depends on [Chocolatey](https://chocolatey.org/) for application installations, and [SetUserFTA](https://setuserfta.com/) for setting default applications.
