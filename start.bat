set ClientName=tempclient
start powershell -noexit -ExecutionPolicy Bypass -File installApps.ps1 -Client %ClientName% -NoInterrupt
start powershell -noexit -ExecutionPolicy Bypass -File setupProfile.ps1 -Client %ClientName% -NoInterrupt