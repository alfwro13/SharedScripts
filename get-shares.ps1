$remotecomputername = read-Host "Computer name"
$shareslist = gwmi -computer $remotecomputername -Class win32_share | select -ExpandProperty Name
foreach ($shareinstance in $shareslist) {
$acl = $null
Write-Host $('-' * $shareinstance.Length)
$SecuritySettings = Get-WMIObject -computername $remotecomputername -Class Win32_LogicalShareSecuritySetting -Filter "name='$Shareinstance'"
$SecurityDescriptor = $SecuritySettings.GetSecurityDescriptor().Descriptor
foreach($ace in $SecurityDescriptor.DACL){
$UserName = $ace.Trustee.Name
If ($ace.Trustee.Domain -ne $Null) {$UserName = "$($ace.Trustee.Domain)\$UserName"}
If ($ace.Trustee.Name -eq $Null) {$UserName = $ace.Trustee.SIDString }
[Array]$ACL += New-Object Security.AccessControl.FileSystemAccessRule($UserName, $ace.AccessMask, $ace.AceType)
}
$ACL
Write-Host $('=' * 50)
}