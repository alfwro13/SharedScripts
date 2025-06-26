<#
.SYNOPSIS
Get-IPGeolocation.ps1 - Get IP address geolocation data
.DESCRIPTION 
This PowerShell script performs a REST API query to retrieve
geolocation information for an IP address.
.OUTPUTS
Results are output to the console.
.PARAMETER IP
Specifies the IP address to lookup.
.EXAMPLE
.\Get-IPGeolocation.ps1 -IP 8.8.8.8
Change Log
V1.00, 13/03/2015 - Initial version
#>

param (
	[Parameter( Mandatory=$true)]
	[string]$ip
)

function GetIPGeolocation() {
$wc = New-Object System.Net.WebClient
$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

    param($ipaddress)

    $resource = "http://freegeoip.net/xml/$ipaddress"

    $geoip = Invoke-RestMethod -Method Get -URI $resource

    $hash = @{
        IP = $geoip.Response.IP
        CountryCode = $geoip.Response.CountryCode
        CountryName = $geoip.Response.CountryName
        RegionCode = $geoip.Response.RegionCode
        RegionName = $geoip.Response.RegionName
        City = $geoip.Response.City
        ZipCode = $geoip.Response.ZipCode
        TimeZone = $geoip.Response.TimeZone
        Latitude = $geoip.Response.Latitude
        Longitude = $geoip.Response.Longitude
        MetroCode = $geoip.Response.MetroCode
        }

    $result = New-Object PSObject -Property $hash

    return $result

}

GetIPGeolocation $ip