# Import the Active Directory module
Import-Module ActiveDirectory

# Define the OUs
$ou1 = "OU=Mobile Device MACs - Company,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"
$ou2 = "OU=Mobile Device MACs - Employee,OU=Group IS,OU=Departments,OU=UK Crawley,DC=intranet,DC=macro4,DC=com"

# Set the cutoff date for 3 months
$cutoffDate = (Get-Date).AddMonths(-3)

# Function to get users from a specific OU who haven't logged in for 3 months
function Get-StaleUsersFromOU {
    param (
        [string]$ou
    )
    
    # Get all users from the OU
    $users = Get-ADUser -Filter * -SearchBase $ou -Properties LastLogonDate, Description
    
    # Filter users based on LastLogonDate (null or older than the cutoff date)
    $staleUsers = $users | Where-Object {
        ($_.'LastLogonDate' -eq $null) -or ($_.LastLogonDate -lt $cutoffDate)
    }
    
    return $staleUsers
}

# Get stale users from both OUs
$staleUsersOU1 = Get-StaleUsersFromOU -ou $ou1
$staleUsersOU2 = Get-StaleUsersFromOU -ou $ou2

# Combine the results
$staleUsers = $staleUsersOU1 + $staleUsersOU2

# Format the output
$report = $staleUsers | Select-Object Name, SamAccountName, LastLogonDate, Description

# Export to CSV (optional)
$report | Export-Csv -Path "Y:\StaleUsersReport.csv" -NoTypeInformation

# Display the report in console
$report | Format-Table -AutoSize
