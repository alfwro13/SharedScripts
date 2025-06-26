[void][reflection.assembly]::LoadWithPartialName(“Microsoft.UpdateServices.Administration“)
$updateServer = “m4uksus2“
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($updateServer,$false)
