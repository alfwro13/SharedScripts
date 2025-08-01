param (
    [switch]$GridView
)

# Import necessary modules
Import-Module UpdateServices
Import-Module ActiveDirectory

# Get WSUS computers and build name-based lookup
$wsusServer = Get-WsusServer -Name "m4ukwsus" -PortNumber 8530
$wsusComputers = $wsusServer | Get-WsusComputer -All

$wsusComputerLookup = @{}
foreach ($wsus in $wsusComputers) {
    $shortName = $wsus.FullDomainName.Split('.')[0].ToLower()
    if (-not $wsusComputerLookup.ContainsKey($shortName)) {
        $wsusComputerLookup[$shortName] = $wsus
    }
}

# Get AD computers with needed properties
$ADComputers = Get-ADComputer -Filter * -Properties OperatingSystem

# Prepare results
$results = foreach ($adComputer in $ADComputers) {
    $computerName = $adComputer.Name.ToLower()

    if ($wsusComputerLookup.ContainsKey($computerName)) {
        $wsusEntry = $wsusComputerLookup[$computerName]
        [PSCustomObject]@{
            ComputerName  = $adComputer.Name
            Status        = 'In WSUS'
            IPAddress     = $wsusEntry.IPAddress
            OS            = $adComputer.OperatingSystem
            LastReported  = $wsusEntry.LastReportedStatusTime
        }
    } else {
        [PSCustomObject]@{
            ComputerName  = $adComputer.Name
            Status        = 'Not in WSUS'
            IPAddress     = $null
            OS            = $adComputer.OperatingSystem
            LastReported  = $null
        }
    }
}

# Output to console or GridView
if ($GridView) {
    $results | Out-GridView -Title "WSUS Computer Audit"
} else {
    $results | Format-Table -AutoSize
}
