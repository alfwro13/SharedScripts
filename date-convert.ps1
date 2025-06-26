$date = read-host "enter numbers that you want converted to date"
Write-host "your date is:"
[datetime]::FromFileTime($date)
write-host

pause