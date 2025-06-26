$wc = New-Object System.Net.WebClient
$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
update-help
