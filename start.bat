set AppSetName=CustomSet2
start powershell -noexit -ExecutionPolicy Bypass -File installApps.ps1 -Client %AppSetName% -NoInterrupt
start powershell -noexit -ExecutionPolicy Bypass -File setupProfile.ps1 -Client %AppSetName% -NoInterrupt