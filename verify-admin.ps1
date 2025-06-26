 ""
 write-host "Domain Account Permission Required" -BackgroundColor Yellow -ForegroundColor red
 Write-host "Current Username:" $(whoami) -BackgroundColor Yellow -ForegroundColor red
 ""
 $user = $(whoami)
 if ($user -like "isys\z*" ) {write-host "Access Verified - OK"
 }
 else {write-host "You do not have the necessary access rights to proceed further."
 write-host "Starting Your Admin powershell session" -BackgroundColor Yellow -ForegroundColor red
 .\powershell.ps1
 exit
 }