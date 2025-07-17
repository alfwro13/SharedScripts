param (
    [Parameter(Mandatory=$true)]
    [string]$UserName
)
$date = get-date
Write-Host "Current date and time:" $date -BackgroundColor Yellow -ForegroundColor Black

try {
    $details = Get-ADUser $UserName -Properties * -ErrorAction Stop
} catch {
    Write-Error "User '$UserName' not found or cannot be retrieved."
    return
}


$details = get-aduser $UserName -Properties * 
$details | select DisplayName, Description, EmailAddress, CanonicalName, whenCreated, LastBadPasswordAttempt, badPwdCount, PasswordLastSet, PasswordNeverExpires, PasswordExpired, LastLogonDate, LockedOut, HomeDirectory, HomeDrive, homeMDB, LogonCount, Manager, Modified, ObjectSID, AccountExpirationDate, Enabled
""
write-host "Used by VPN, SonicWall VPN, Meraki WiFi:"
write-host "Allow Dial In (msNPAllowDialIn) option is set to: " $details.msNPallowDialIn -BackgroundColor Magenta -ForegroundColor Black
""

if (Test-Path ".\Get-ADUserPasswordExpirationDate.ps1") {
    .\Get-ADUserPasswordExpirationDate.ps1 $UserName
} else {
    Write-Warning "Password expiration script not found."
}

Write-Host ""
Write-Host "This user is a member of the following security groups:" -BackgroundColor Yellow -ForegroundColor Black

$details.memberof | ForEach-Object {
    (Get-ADGroup $_).Name
} | Sort-Object
