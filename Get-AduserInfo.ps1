param (
    [Parameter(Mandatory=$true)]
    [string]$UserName
)
$date = get-date
Write-Host "Current date and time:" $date -BackgroundColor Yellow -ForegroundColor Black

$details = get-aduser $UserName -Properties * 
$details | select DisplayName,Description,EmailAddress,CanonicalName,whenCreated,LastBadPasswordAttempt,badPwdCount,PasswordLastSet,PasswordNeverExpires,PasswordExpired,LastLogonDate,LockedOut,HomeDirectory,HomeDrive,homeMDB,LogonCount,Manager,Modified,ObjectSID,AccountExpirationDate,Enabled
""
write-host "Used by VPN, SonicWall VPN, Meraki WiFi:"
write-host "Allow Dial In (msNPAllowDialIn) option is set to: " $details.msNPallowDialIn -BackgroundColor Magenta -ForegroundColor Black
""
.\Get-ADUserPasswordExpirationDate.ps1 $UserName
write-host
Write-host "This users is a member of the following security groups:" -BackgroundColor Yellow -ForegroundColor Black
$details | select -ExpandProperty memberof | sort-object
""
