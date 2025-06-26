echo "This script will set the setLastPwd to 0"
$user = read-host "Enter AD account that you want to expire"
$account = get-aduser $user -prop *
$account.pwdlastset = 0
set-aduser -instance $account

.\Get-ADUserPasswordExpirationDate.ps1 $user