Add-PSSnapin Quest.ActiveRoles.ADManagement

$PROGRAM = "mstsc.exe"
$User= read-host "What is the firstname,lastname, or Username of the user?"
$ComputerName = Get-QADComputer -ManagedBy (Get-QADUser $User)

If (($ComputerName | Measure-Object).Count -gt 1){
$ComputerName | Select Name,ManagedBy,WhenChanged
$Computer = read-host "Type the correct Computer Name from list or press enter to exit."

if ($Computer -ne ""){
& $Program /v:$Computer
}
}

Else{
Get-QADComputer -ManagedBy (Get-QADUser $User) | Select-Object Name,Managedby

if ($Computer -ne ""){
& $Program /v:$Computer
}

If ($Computer -eq ""){exit}

}