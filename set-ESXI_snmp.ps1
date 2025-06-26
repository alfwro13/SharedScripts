#Script to enable and configure SNMP on ESXI host
$host_name = Read-Host "Host name:(i.e. m4ukbl11.intranet.macro4.com) "

$esxcli = get-esxcli -vmhost $host_name
$esxcli.system.snmp.set($null,"public","true",$null,$null,$null,$null,$null,$null,$null,$null,$null,"UK Crawley")

$esxcli.system.snmp.get()

Write-host "Now go to the host and start the service"
