$user = Read-Host "what is the user name"
Get-ADUser $user -properties *
pause
