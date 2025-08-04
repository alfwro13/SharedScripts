<#
.SYNOPSIS
    Lists inactive Active Directory user or computer accounts based on last logon date.

.DESCRIPTION
    This script queries Active Directory for user or computer accounts that have not logged on 
    in a specified number of days. You can choose between user or computer accounts and output 
    the results to the console or to a graphical Out-GridView window.

.PARAMETER DaysInactive
    Number of days since the last logon. Defaults to 180.

.PARAMETER AccountType
    Type of accounts to check. Accepts 'User' or 'Computer'. Defaults to 'User'.

.PARAMETER GridView
    Optional switch to output results in an Out-GridView window. If not specified, output is sent to the console.

.EXAMPLE
    .\Get-Inactive_AD_Objects.ps1
    Shows user accounts inactive for 180 days or more in the console.

.EXAMPLE
    .\Get-Inactive_AD_Objects.ps1 -DaysInactive 90
    Shows user accounts inactive for 90 days or more in the console.

.EXAMPLE
    .\Get-Inactive_AD_Objects.ps1 -AccountType Computer -DaysInactive 120 -GridView
    Shows computer accounts inactive for 120 days or more in an Out-GridView window.

.EXAMPLE
    Get-Help .\Get-Inactive_AD_Objects.ps1 -Full
    Displays full help for the script.

.NOTES
    Author: Andre Wroblewski
    Created: 2025-08-04
    Requires: ActiveDirectory module (RSAT)
#>


param (
    [int]$DaysInactive = 180,
    [ValidateSet("User", "Computer")]
    [string]$AccountType = "User",
    [switch]$GridView
)

Import-Module ActiveDirectory

# Calculate the date threshold
$then = (Get-Date).AddDays(-$DaysInactive)

# Get accounts based on type
if ($AccountType -eq "User") {
    $accounts = Get-ADUser -Property SamAccountName, LastLogonDate, DisplayName, Description, ModifyTimeStamp, Enabled, CanonicalName -Filter {LastLogonDate -lt $then} |
        Select-Object SamAccountName, LastLogonDate, Description, ModifyTimeStamp, Enabled, DisplayName, CanonicalName
}
elseif ($AccountType -eq "Computer") {
    $accounts = Get-ADComputer -Property Name, LastLogonDate, OperatingSystem, Description, Modified, Enabled, CanonicalName -Filter {LastLogonDate -lt $then} |
        Select-Object Name, LastLogonDate, OperatingSystem, Description, Modified, Enabled, CanonicalName
}

# Output based on switch
if ($GridView) {
    $accounts | Out-GridView -Title "$AccountType Accounts Inactive for $DaysInactive+ Days"
} else {
    $accounts | Format-Table -AutoSize
}
