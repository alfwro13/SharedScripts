  param (
    [Parameter(Mandatory=$true)]
    [string]$Computer
)
  
    # Helper Function - convert WMI date to TimeDate object 
    function WMIDateStringToDate($Bootup) { 
        [System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup) 
    } 
     
    $computers = Get-WMIObject -class Win32_OperatingSystem -computer $computer 
     
    foreach ($system in $computers) { 
        $Bootup = $system.LastBootUpTime 
        $LastBootUpTime = WMIDateStringToDate($Bootup) 
        $now = Get-Date 
        $Uptime = $now - $lastBootUpTime 
        $d = $Uptime.Days 
        $h = $Uptime.Hours 
        $m = $uptime.Minutes 
        $ms= $uptime.Milliseconds 
     
        "System Up for: {0} days, {1} hours, {2}.{3} minutes" -f $d,$h,$m,$ms 
    }  