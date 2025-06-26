#This script outputs current CPU percentage load and Free memory on a specified machine.
#Tested with Win7 and Win10 systems

param (
    [Parameter(Mandatory=$true)]
    [string]$ComputerName
)

$freemem = get-WMIObject -computername $ComputerName win32_OperatingSystem
$CPUload = get-wmiobject -computername $ComputerName win32_processor 
$cpuPercentageLoad = "CPU Load Percentage: " + $CPUload.LoadPercentage + " %"
$FreeMemoryGB = “Free Memory GB: ” + ([math]::round(($freemem.FreePhysicalMemory / 1024 / 1024), 2))

$cpuPercentageLoad
$FreeMemoryGB