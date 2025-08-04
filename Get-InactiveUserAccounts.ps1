param (
    [int]$DaysInactive = 180,
    [ValidateSet("User", "Computer")]
    [string]$AccountType = "User",
    [switch]$GridView
)

# Calculate the date threshold
$then = (Get-Date).AddDays(-$DaysInactive)

# Get accounts based on type
if ($AccountType -eq "User") {
    $accounts = Get-ADUser -Property Name, LastLogonDate, DisplayName, Description, ModifyTimeStamp -Filter {LastLogonDate -lt $then} |
        Select-Object Name, LastLogonDate, Description, ModifyTimeStamp
}
elseif ($AccountType -eq "Computer") {
    $accounts = Get-ADComputer -Property Name, LastLogonDate, OperatingSystem, Description, Modified -Filter {LastLogonDate -lt $then} |
        Select-Object Name, LastLogonDate, OperatingSystem, Description, Modified
}

# Output based on switch
if ($GridView) {
    $accounts | Out-GridView -Title "$AccountType Accounts Inactive for $DaysInactive+ Days"
} else {
    $accounts | Format-Table -AutoSize
}
