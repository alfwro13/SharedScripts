write-host "Use this to connect to other than ISYS domain"
write-host "Use IET for iET domain"
write-host "Use DETEC for Detec domain"
$domain = read-host "What domain do you want to connect to"
pause
Get-Credential
Add-PSSnapin Quest.ActiveRoles.ADManagement
Connect-QADservice $domain

write-host "You are now connected to" $domain "domain"
write-host "run   gcm *qad*   to see list of available commands for that domain"
""
write-host "To close the session run:   Disconnect-QADService" -BackgroundColor Yellow -ForegroundColor red
