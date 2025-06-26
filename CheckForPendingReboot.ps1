    # Helper Function - convert WMI date to TimeDate object 
    function WMIDateStringToDate($Bootup) { 
        [System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup) 
    } 


$CSVPath = "u:\VDIs.txt"
$Computers = get-content $CSVPath 

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
     
        "System Up for: {0} days, {1} hours, {2}.{3} minutes" -f $system,$d,$h,$m,$ms 
    }

}