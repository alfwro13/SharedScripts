param (
	[Parameter(Mandatory=$true)]
		[string]$IPaddress
		)
get-vm | where {$_.guest.IPaddress[0] -like "*$IPaddress*"}
