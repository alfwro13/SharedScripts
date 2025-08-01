<#
.SYNOPSIS
    Lists all VMs where a specified user has permissions in vSphere.

.DESCRIPTION
    Connects to vCenter and retrieves permissions assigned directly on VMs
    for a given user within the INTRANET.MACRO4.COM domain.

.PARAMETER UserShortName
    The 3-letter username (e.g. 'amw') to check permissions for.

.PARAMETER GridView
    Optional switch to display output in an interactive grid view window.

.EXAMPLE
    .\get-VMs_With_User_Permission.ps1 -UserName amw

    Displays VM permissions for user INTRANET.MACRO4.COM\amw in the console.

.EXAMPLE
    .\get-VMs_With_User_Permission.ps1 -UserName amw -GridView

    Displays the same output in an Out-GridView window.

.NOTES
    Author: Andre Wroblewski
    Date: 2025-08-01
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [switch]$GridView
)

# Construct the full domain user
$userToCheck = "INTRANET.MACRO4.COM\$UserName"

Write-Host "Checking permissions for user: $userToCheck`n"
if($GridView) {
    Write-Host "Results will be displayed in an Out-GridView window."
} else {
    Write-Host "Results will be displayed in the console."
}

# Get all VMs
$vms = Get-VM

# Initialize result array
$results = @()

foreach ($vm in $vms) {
    $permissions = Get-VIPermission -Entity $vm
    foreach ($perm in $permissions) {
        if ($perm.Principal -eq $userToCheck) {
            $results += [PSCustomObject]@{
                VMName    = $vm.Name
                User      = $perm.Principal
                Role      = $perm.Role
                Propagate = $perm.Propagate
            }
        }
    }
}

# Output the results
if ($results.Count -gt 0) {
    if ($GridView) {
        $results | Out-GridView -Title "VM Permissions for $userToCheck"
    } else {
        $results | Format-Table -AutoSize
    }
} else {
    Write-Host "No VM permissions found for $userToCheck"
}
