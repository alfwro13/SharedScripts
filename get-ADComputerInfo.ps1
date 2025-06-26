param (
    [Parameter(Mandatory=$true)]
    [string]$ComputerName
)

Get-ADComputer -id $ComputerName -Properties * | select name,description,operatingSystem,OperatingSystemVersion,CanonicalName,Enabled,ms-Mcs-AdmPwd | fl
