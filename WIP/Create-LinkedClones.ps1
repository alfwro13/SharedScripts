param (
 [parameter(Mandatory=$true)][string]$SourceName,
 [parameter(Mandatory=$true)][string]$CloneName
)
$vm = Get-VM $SourceName

# Create new snapshot for clone
$cloneSnap = $vm | New-Snapshot -Name "Clone Snapshot"

# Get managed object view
$vmView = $vm | Get-View

# Get folder managed object reference
$cloneFolder = $vmView.parent

# Build clone specification
$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
$cloneSpec.Snapshot = $vmView.Snapshot.CurrentSnapshot

# Make linked disk specification
$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking

# Create clone
$vmView.CloneVM( $cloneFolder, $cloneName, $cloneSpec )

# Write newly created VM to stdout as confirmation
Get-VM $cloneName