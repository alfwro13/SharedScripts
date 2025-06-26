Import-Module ServerManager
Install-WindowsFeature -Name 'SNMP-Service','RSAT-SNMP'

$pollers = @("librenms.intranet.macro4.com","10.0.61.134")
$CommunityStr = @("DaptShjaXqFhnW28")

#test if SNMP-Service Feature is enabled
$test = Get-WindowsFeature -Name SNMP-Service

#Install/Enable SNMP-Service if it is not enabled
If ($test.Installed -ne "True") {
Write-Host "Enabling SNMP-Service Feature"
Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeManagementTools | Out-Null
}

#re-test if SNMP-Service Feature is enabled and update variable
$test = Get-WindowsFeature -Name SNMP-Service

#Setup reg keys to configure SNMP-Service if Feature is Enabled
If ($test.Installed -eq "True"){
Write-Host "Configuring SNMP-Services with your Community strings and Permitted pollers"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d localhost /f | Out-Null

Foreach ($String in $CommunityStr){
reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /f | Out-Null
reg delete ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /ve /f | Out-Null
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $String /t REG_DWORD /d 4 /f | Out-Null
$i = 2

Foreach ($Manager in $pollers){
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $i /t REG_SZ /d $manager /f | Out-Null
reg add ("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\" + $String) /v $i /t REG_SZ /d $manager /f | Out-Null
$i++
}
}
}