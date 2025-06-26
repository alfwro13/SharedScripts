[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$updateServer = "m4uksus3"
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($updateServer,$false,8530)

Write-Host 'To get started run: $wsus | gm'
write-host "then run for example: "
write-host '$wsus.GetComputerTargets() | select FullDomainName   - that will list all WSUS managed computers'
