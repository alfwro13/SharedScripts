param (
    [int]$DaysInactive = 180,
    [switch]$GridView
)

# Calculate the date threshold
$then = (Get-Date).AddDays(-$DaysInactive)

# Get users with lastLogonDate older than threshold
$users = Get-ADUser -Property Name, LastLogonDate, DisplayName, Description, ModifyTimeStamp `
    -Filter {LastLogonDate -lt $then} |
    Select-Object Name, LastLogonDate, Description, ModifyTimeStamp

# Output based on switch
if ($GridView) {
    $users | Out-GridView -Title "Inactive AD Users ($DaysInactive+ days)"
} else {
    $users | Format-Table -AutoSize
}
