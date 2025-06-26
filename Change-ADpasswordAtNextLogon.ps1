$username = read-host "3 letter username"

Write-Host "you have entered the following username ISYS\"$username 
Write-Host "press any key to FORCE THE USER TO CHANGE PASSWORD AT NEXT LOGON"
pause

Set-aduser $username -ChangePasswordAtLogon $True
Write-Host "Option Set! "
