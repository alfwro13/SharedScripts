

"Checks:"
"1. Check and update u:\training_room_hostnames.csv file"
"2. Check and update u:\training_room_usernames.txt file"
pause
$userlist = ""
$complist = ""
$userlist = Get-Content u:\training_room_usernames.txt
write-host "Current Userlist:" $Userlist

$complist = Import-Csv -Path "u:\training_room_hostnames.csv" | ForEach-Object {$_.NetBIOSName}
foreach($comp in $complist){
     $comparray += ","+$comp
}
write-host "LogonWorkstations array:" $comparray

pause

foreach ($user in $userlist) {
Set-ADUser -Identity $user -LogonWorkstations $comparray
get-aduser -id $user -prop * | select Name,LogonWorkstations
}
