param (
    [Parameter(Mandatory=$true)]
    [string]$ComputerName
)

$ProcArray = @()
$Processes = get-process -computername $ComputerName | Group-Object -Property ProcessName
foreach($Process in $Processes)
{
    $prop = @(
            @{n='Count';e={$Process.Count}}
            @{n='Name';e={$Process.Name}}
            @{n='Memory';e={($Process.Group|Measure WorkingSet -Sum).Sum}}
            )
    $ProcArray += "" | select $prop  
}
$ProcArray | sort -Descending Memory | select Count,Name,@{n='Memory usage(Total)';e={"$(($_.Memory).ToString('N0')) Kb"}}