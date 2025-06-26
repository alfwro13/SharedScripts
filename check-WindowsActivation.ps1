param (
    [Parameter(Mandatory=$true)]
    [string]$computer
)

Get-CimInstance SoftwareLicensingProduct -computername $computer -Filter "Name like 'Windows%'" | where { $_.PartialProductKey } | select Description, LicenseStatus