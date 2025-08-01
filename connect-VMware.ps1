# To create the creds
# create the key as follows:
#   $Key = New-Object Byte[] 32
#   [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
# Save the key:
#   [IO.File]::WriteAllBytes("Y:\NC\Work\U_drive\creds\my.key", $Key)
# Load the key: 
#   $key = [IO.File]::ReadAllBytes("Y:\NC\Work\U_drive\creds\my.key")
# Convert the password to a secure string:
#   $secure = ConvertTo-SecureString "PasswordHere" -AsPlainText -Force


# Load config from relative subfolder
$configPath = Join-Path $PSScriptRoot "PS_JSON_CONFIG\vcenter-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "Config file not found: $configPath" -ForegroundColor Red
    exit 1
}

# Load values from JSON
$config = Get-Content $configPath | ConvertFrom-Json
$vCenterIP = $config.vCenterIP
$username = $config.Username
$credsFolder = $config.CredsFolder

# Resolve credential file paths
$keyPath = Join-Path $credsFolder "my.key"
$encPath = Join-Path $credsFolder "enc.txt"

# Optional: enable verbose output
$VerbosePreference = "Continue"

# Function to load saved credentials
function Get-SavedCredential {
    param (
        [string]$Username,
        [string]$KeyFilePath,
        [string]$EncryptedPasswordFile
    )

    try {
        $key = [IO.File]::ReadAllBytes($KeyFilePath)
        $encrypted = Get-Content $EncryptedPasswordFile
        $securePassword = $encrypted | ConvertTo-SecureString -Key $key
        return New-Object System.Management.Automation.PSCredential($Username, $securePassword)
    } catch {
        Write-Host "Failed to load credentials. Please check file paths and encryption key." -ForegroundColor Red
        exit 1
    }
}

# Check if already connected to this vCenter
if ($defaultVIServer -and $defaultVIServer.Name -eq $vCenterIP) {
    Write-Output "Already connected to vCenter:" $($defaultVIServer.Name)
    return
}

# If not connected, proceed with login
Import-Module VMware.VumAutomation

try {
    $HostName = [System.Net.Dns]::GetHostByAddress($vCenterIP).HostName
} catch {
    Write-Host "Failed to resolve vCenter hostname from IP address." -ForegroundColor Red
    exit 1
}

$credential = Get-SavedCredential -Username $username -KeyFilePath $keyPath -EncryptedPasswordFile $encPath

Write-Output "Connecting to $HostName ($vCenterIP)..."

try {
    Connect-VIServer -Server $vCenterIP -Credential $credential
    Write-Output "OK - Connection to vCenter established."
} catch {
    Write-Output "ERROR - Failed to connect to vCenter."
    exit 1
}
