param (
	[Parameter(Mandatory=$true)]
	[string]$UserName
)
$password = Read-Host -asSecureString "Enter the new password"

#$plainpassword = Read-Host "Enter the new password"
#$password = ConvertTo-SecureString -String $plainpassword -AsPlainText -Force
#Write-Host "you have entered the following username and password ISYS\"$username $plainpassword
Write-Host "press any key to reset the password" -BackgroundColor Yellow -ForegroundColor Black
pause
Set-ADAccountPassword $UserName -NewPassword $password -Reset
Write-Host "Password Set!!! " -BackgroundColor Yellow -ForegroundColor Black
Get-ADUser $username -Properties * | select DisplayName,Enabled,PasswordLastSet