#Write-host "Locked accounts:"
Search-ADAccount -lockedout | select name,SAMAccountName | ft

Write-Host "Press any key to proceed to unlock"
pause

Search-ADAccount -LockedOut | where name -NotLike "Administrator" | unlock-adaccount -confirm
Pause
