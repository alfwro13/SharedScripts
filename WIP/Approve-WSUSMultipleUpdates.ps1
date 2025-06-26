[void][reflection.assembly]::LoadWithPartialName(“Microsoft.UpdateServices.Administration“)
$updateServer = “m4uksus2“
$machineName = Read-Host “Please enter the full DNS name of the computer you wish to approve updates for“
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($updateServer,$false)
$updateScope = new-object Microsoft.UpdateServices.Administration.UpdateScope
$updateScope.includedInstallationStates = “NotInstalled“
$com = $wsus.GetComputerTargetByName($machineName)

$groupid= Read-Host “Please enter the Computer Group Target ID“
$group = $wsus.GetComputerTargetGroup($groupid)
$action = [Microsoft.UpdateServices.Administration.UpdateApprovalAction]::Install
$updates = $com.GetUpdateInstallationInfoPerUpdate($updateScope)
$updates | foreach-object {$uid = $_.UpdateId; $u = $wsus.GetUpdate($uid); $u.Title; $u.Approve($action,$group);}