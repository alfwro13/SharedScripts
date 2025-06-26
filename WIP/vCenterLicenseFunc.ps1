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

function Add-vLicense{
<#
.SYNOPSIS
Add New Licenses to the vCenter license manager
&nbsp;
.DESCRIPTION
Use this function to add licenses &nbsp;and assing to either the vcenter or the hosts
&nbsp;
.PARAMETER &nbsp;xyz&nbsp;
&nbsp;	
.NOTES
Author: Niklas Akerlund / RTS
Date: 2012-03-28
#>
param (
	$VMHost ,
	[Parameter(ValueFromPipeline=$True)]$License = $null,
	[string]$LicenseKey = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX",
	[switch]$AddKey
&nbsp; &nbsp; )
	$LicenseMgr = Get-View -Id 'LicenseManager-LicenseManager'
	$LicenseAssignMgr = Get-View -Id 'LicenseAssignmentManager-LicenseAssignmentManager'
	if($License){
		$LicenseKey = $License.LicenseKey
		$LicenseType = $LicenseMgr.DecodeLicense($LicenseKey)
	}else{
		$LicenseType = $LicenseMgr.DecodeLicense($LicenseKey)
	}
	
	if ($LicenseType) {
		if ($AddKey){
			$LicenseMgr.AddLicense($LicenseKey, $null)
		}else{
			if ($LicenseType.EditionKey -eq "vc"){
				#$servInst = Get-View ServiceInstance
				$Uuid = (Get-View ServiceInstance).Content.About.InstanceUuid
				$licenseAssignMgr.UpdateAssignedLicense($Uuid, $LicenseKey,$null)
			} else {
				$key = Get-vLicense -LicenseKey $LicenseKey
				if($key &nbsp;-and ($key.Total-$key.Used) -lt (get-vmhost $VMHost | get-view).Hardware.CpuInfo.NumCpuPackages){
					Write-Host "Not Enough licenses left"
				} else{
					$Uuid = (Get-VMhost $VMHost | Get-View).MoRef.Value
					$licenseAssignMgr.UpdateAssignedLicense($Uuid, $LicenseKey,$null)
				}
			}	
		}
	}	
}


function Remove-vLicense{
<#
.SYNOPSIS
Function to remove a licenses that is not in use in vCenter
&nbsp;
.DESCRIPTION
Use this function to remove a license
&nbsp;
.PARAMETER &nbsp;xyz&nbsp;
&nbsp;
.NOTES
Author: Niklas Akerlund / RTS
Date: 2012-03-28
#>
param (
	[Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$True, HelpMessage="Enter the key or keyobject to remove")]$License
	)
	$LicObj = Get-vLicense $License&nbsp;
	if($LicObj.Used -eq 0){
		$LicenseMgr = Get-View -Id 'LicenseManager-LicenseManager'
		$LicenseMgr.RemoveLicense($LicObj.LicenseKey)
	}else{
		Write-Host " The license is assigned and cannot be removed"
	}
}
