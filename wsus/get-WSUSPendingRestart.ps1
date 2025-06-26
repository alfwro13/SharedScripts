[void][reflection.assembly]::LoadWithPartialName(“Microsoft.UpdateServices.Administration“)

$updateServer = “m4uksus3“

$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($updateServer,$false,8530)
 
$computerScope = new-object Microsoft.UpdateServices.Administration.ComputerTargetScope; 
$computerScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::InstalledPendingReboot; 
 
$updateScope = new-object Microsoft.UpdateServices.Administration.UpdateScope; 
$updateScope.IncludedInstallationStates = [Microsoft.UpdateServices.Administration.UpdateInstallationStates]::InstalledPendingReboot; 
 
$computers = $wsus.GetComputerTargets($computerScope); 
 
$computers | foreach-object { 
                $_.FullDomainName | write-host;
} 