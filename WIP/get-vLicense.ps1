function Get-vLicense{
<#
.SYNOPSIS
Function to show all licenses &nbsp;in vCenter
&nbsp;
.DESCRIPTION
Use this function to get all licenses in vcenter
&nbsp;
.PARAMETER &nbsp;xyz&nbsp;
&nbsp;
.NOTES
Author: Niklas Akerlund / RTS
Date: 2012-03-28
#>
	param (
		[Parameter(ValueFromPipeline=$True, HelpMessage="Enter the license key or object")]$LicenseKey = $null,
		[Switch]$showUnused,
		[Switch]$showEval
		)
	$servInst = Get-View ServiceInstance
	$licenceMgr = Get-View $servInst.Content.licenseManager
	if ($showUnused -and $showEval){
		$licenses = $licenceMgr.Licenses | where {$_.EditionKey -eq "eval" -or $_.Used -eq 0}
	}elseif($showUnused){
		$licenses = $licenceMgr.Licenses | where {$_.EditionKey -ne "eval" -and $_.Used -eq 0}
	}elseif($showEval){
		$licenses = $licenceMgr.Licenses | where {$_.EditionKey -eq "eval"}
	}elseif ($LicenseKey -ne $null) {
		if (($LicenseKey.GetType()).Name -eq "String"){
			$licenses = $licenceMgr.Licenses | where {$_.LicenseKey -eq $LicenseKey}
		}else {
			$licenses = $licenceMgr.Licenses | where {$_.LicenseKey -eq $LicenseKey.LicenseKey}
		}
	}
	else {
		$licenses = $licenceMgr.Licenses | where {$_.EditionKey -ne "eval"}
	}
	
	$licenses
}