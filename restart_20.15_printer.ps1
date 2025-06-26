$SNMP = new-object -ComObject olePrn.OleSNMP
$snmp.open("10.0.20.15","private",1,6000)
$SNMP.Set(".1.3.6.1.2.1.43.5.1.1.3.1",4)