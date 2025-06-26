"This script will pull all VDIs from the VDI OU under Crawley and get ther uptimes"
pause
# Date convertion 
    function WMIDateStringToDate($Bootup) { 
        [System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup) 
    } 


$computers = Get-ADComputer -SearchBase 'OU=VDI,OU=Windows 10,OU=Desktops,OU=Computers,OU=UK Crawley,dc=intranet,dc=macro4,dc=com' -Filter '*' | Select -Exp Name | sort -Descending

ForEach ($Machine in $Computers)
{
    $PCs = Get-WMIObject -class Win32_OperatingSystem -computer $Machine 
     
    foreach ($system in $PCs) { 
        $Bootup = $system.LastBootUpTime 
        $LastBootUpTime = WMIDateStringToDate($Bootup) 
        $now = Get-Date 
        $Uptime = $now - $lastBootUpTime 
        $d = $Uptime.Days 
        $h = $Uptime.Hours 
        $m = $uptime.Minutes 
        $ms= $uptime.Milliseconds 
        $PCOwner = Get-ADComputer $Machine -prop * | select Description
     
       "Days: {0},hours: {1}, minutes: {2}.{3}, System name: {4}, {5}" -f $d,$h,$m,$ms,$Machine,$PCOwner
    }

}