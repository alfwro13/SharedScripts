param (
    [Parameter(Mandatory=$true)]
    [string]$WiFi_User
        )

$ErrorActionPreference = "silentlycontinue"
$devices = get-aduser -prop * -filter "description -like '*$WiFi_User*'"  | select name,samaccountname,description

Write-host "Users last recorded location": 
sleep 2
foreach ($user in $devices)
{
$location = Get-WinEvent -computername M4UKRS01.intranet.macro4.com -FilterHashtable @{logName='Security';ID='6278';Data=$user.samaccountname} | select -First 1
Write-host ""
Write-host "Device:" $user.description
Write-host "Time:" $location.timecreated
Write-host "Last known AP:" $location.Properties[15].value
Write-Host ""
}
""
""
"AP1 - IS Office"
"AP2 - Training Room"
"AP3 - Swimming Pool"
"AP4 - GF - Jim"
"AP5 - GF - Coffe M"
"AP6 - 2nd F"
"AP7 - 1st F"
"AP8 - GF ?"
"AP9 - Take4"
""
"All user devices"
$devices