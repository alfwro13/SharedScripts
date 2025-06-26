$name = read-host "Enter user name or surname"
Get-ActiveSyncDevice | where identity -like "*$name*" | select DeviceOS,DeviceTelephoneNumber,DeviceModel,UserDisplayName,deviceid,FirstSyncTime