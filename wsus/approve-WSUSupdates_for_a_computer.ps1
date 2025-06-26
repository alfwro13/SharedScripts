[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")

$updateServer = "m4uksus3"

$machineName = Read-Host "enter DNS name of the computer you wish to approve updates for"

$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($updateServer,$false,8530)

$updateScope = new-object Microsoft.UpdateServices.Administration.UpdateScope

$updateScope.includedInstallationStates = "NotInstalled"

$com = $wsus.GetComputerTargetByName($machineName)
$wsus.GetComputerTargetGroups()

$groupname =  Read-Host "Enter target WSUS group name"
$Target = $wsus.GetComputerTargetGroups() | where {$_.Name -eq $groupname}

$action = [Microsoft.UpdateServices.Administration.UpdateApprovalAction]::Install

$updates = $com.GetUpdateInstallationInfoPerUpdate($updateScope)
$updates | foreach-object {$uid = $_.UpdateId; $u = $wsus.GetUpdate($uid); $u.Title; $u.Approve($action,$target);}