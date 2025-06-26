param (
	[Parameter(Mandatory=$true)]
	[string]$vmName
)

Get-VM $vmName | select Name, @{N="CBT";E={(Get-View $_).Config.ChangeTrackingEnabled}}
