param (
    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [switch]$GridView
)

# Construct the full domain user
$userToCheck = "INTRANET.MACRO4.COM\$UserName"

Write-Host "Checking permissions for user: $userToCheck`n"

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
