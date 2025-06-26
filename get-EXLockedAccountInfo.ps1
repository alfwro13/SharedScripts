#1. get exchange locked out ids: 4625
#2. get user devices
#3. get user logged in locations (if possible)
"Script WIP"
pause

$name = read-host "Enter user name or surname (NOT username)"
"List of User Devices:"
Get-ActiveSyncDevice | where identity -like "*$name*" | select DeviceOS,DeviceTelephoneNumber,DeviceModel,UserDisplayName,deviceid,FirstSyncTime
""
""
$date = [datetime]::today.adddays(-1)
$UserName = read-host "Enter username:"
write-host "List of locked events from CAS1:"
pause
"looking for locked events in the past 24h"
"working...."
Get-EventLog -ComputerName m4ukcas1 -LogName Security -InstanceId 4625 -after $date | select TimeGenerated,Message | select-string $username