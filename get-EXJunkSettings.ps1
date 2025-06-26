param (
	[Parameter(Mandatory=$true)]
	[string]$UserName
)
Get-MailboxJunkEmailConfiguration $username

$ask = read-host "Do you want to add Trusted Sender (T) or Block Sender (B) "
if ($ask -eq "T") {
	$trusted = read-host "Specify Trusted sender or Domain"
	Get-MailboxJunkEmailConfiguration $UserName | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains @{add=$trusted} 
	Get-MailboxJunkEmailConfiguration $UserName | select TrustedSendersAndDomains
}
if ($ask -eq "B") {
	$blocked = read-host "Specify Blocked Sender or Domain:"
	Get-MailboxJunkEmailConfiguration $UserName | Set-MailboxJunkEmailConfiguration -BlockedSendersAndDomains @{add=$blocked} 
	Get-MailboxJunkEmailConfiguration $UserName | select BlockedSendersAndDomains
}
else {"Job DONE"}