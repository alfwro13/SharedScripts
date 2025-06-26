<#
.SYNOPSIS
Verify-Kerberos
.DESCRIPTION
Verify-Kerberos is used to pull the logon events from the event log of specific servers to determine what type of authentication mechanism is being used. Examples are NTLM and Kerberos.
.PARAMETER ComputerName
Specify remote server names to check. Default: The Local Computer
.PARAMETER Records
Specify the maximum number of events to be retrieved from each computer. Default: 10
.EXAMPLE
.\Verify-Kerberos.ps1 -ComputerName server1 | Format-Table -AutoSize
Retrieve 10 logon events from server1 and display them on the screen in a table.
.EXAMPLE
.\Verify-Kerberos.ps1 -ComputerName server1, server2 -Records 30 | Export-Csv -NoTypeInformation -Path d:\tmp\voyager-kerberos_test.csv
Retrieve 30 logon events from server1 and 30 from server2. Save the results as a CSV file located in the specified path.
.Notes
LastModified: 5/30/2012
Author: Mike F Robbins
#>
param (
$ComputerName = $Env:ComputerName,
$Records = 10
)
function Get-LogonTypeName {
Param($LogonTypeNumber)
switch ($LogonTypeNumber) {
0 {"System"; break;}
2 {"Interactive"; break;}
3 {"Network"; break;}
4 {"Batch"; break;}
5 {"Service"; break;}
6 {"Proxy"; break;}
7 {"Unlock"; break;}
8 {"NetworkCleartext"; break;}
9 {"NewCredentials"; break;}
10 {"RemoteInteractive"; break;}
11 {"CachedInteractive"; break;}
12 {"CachedRemoteInteractive"; break;}
13 {"CachedUnlock"; break;}
default {"Unknown"; break;}
}
}
$ComputerName | ForEach-Object {Get-Winevent -Computer $_ -MaxEvents $Records -FilterXPath "*[System[(EventID=4624)]]" |
select @{Name='Time';e={$_.TimeCreated.ToString('g')}},
@{l="Logon Type";e={Get-LogonTypeName $_.Properties[8].Value}},
@{l='Authentication';e={$_.Properties[10].Value}},
@{l='User Name';e={$_.Properties[5].Value}},
@{l='Client Name';e={$_.Properties[11].Value}},
@{l='Client Address';e={$_.Properties[18].Value}},
@{l='Server Name';e={$_.MachineName}}} |
Sort-Object @{e="Server Name";Descending=$false}, @{e="Time";Descending=$true}