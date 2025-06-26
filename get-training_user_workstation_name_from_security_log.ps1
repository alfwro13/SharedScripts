Get-EventLog -ComputerName m4uktsgw security -EntryType FailureAudit | where message -like *m4truser* | select -ExpandProperty message | findstr -i "Workstation Name:"
