Write-Host "This script enables CBT for a VM"
   $vm = read-host "Specify VM name"
Get-VM $vm | select Name, @{N="CBT";E={(Get-View $_).Config.ChangeTrackingEnabled}} 
write-host "Proceed ?"
pause
   $vmView = Get-vm $vm | get-view
   $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
   $vmConfigSpec.changeTrackingEnabled = $true
   $vmView.reconfigVM($vmConfigSpec)

Get-VM $vm | select Name, @{N="CBT";E={(Get-View $_).Config.ChangeTrackingEnabled}} 

Write-host "Done."
