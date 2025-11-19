<#
.SYNOPSIS
Connects to a specified vCenter server using locally encrypted credentials.

.DESCRIPTION
This script securely connects to a vCenter server. 
To set up and run this script for the first time, follow these steps:
1. Generate Credentials: Use the commented-out steps in the script (in the 'Dynamic Manual Steps' section) to create 
   the 'my.key' and 'enc.txt' files in your configured CredsFolder.
2. Update Config: Fill in the required private details (vCenterIP, Username, CredsFolder) 
   in the 'vcenter-config.template.json' file (located in PS_JSON_CONFIG).
3. Rename Config: Rename the 'vcenter-config.template.json' file to 'vcenter-config.json'.
4. Run: Execute the script.

The script uses configuration from vcenter-config.json (in PS_JSON_CONFIG) 
and relies on files in the Credential Folder (my.key and enc.txt) to securely 
decrypt and load the password before connecting to vCenter.

If only vcenter-config.template.json is found, the script will prompt the user to 
rename and populate it.

.NOTES
*** IMPORTANT SECURITY NOTE: ***
This script should ONLY be used if Two-Factor Authentication (2FA) is enabled 
for the vCenter account used. Stored credentials should be treated with utmost care.

The sensitive files (vcenter-config.json, my.key, enc.txt) MUST NOT be committed 
to a public repository.
#>

# --- Config and Credential Setup ---

# Define the config directory and file names
$configDir = "PS_JSON_CONFIG"
$actualConfigFile = "vcenter-config.json"
$templateConfigFile = "vcenter-config.template.json"

# Set paths based on the script's root directory
$scriptRoot = $PSScriptRoot
$configPathRoot = Join-Path $scriptRoot $configDir
$actualConfigPath = Join-Path $configPathRoot $actualConfigFile
$templateConfigPath = Join-Path $configPathRoot $templateConfigFile


# --- Manual Steps required to create the cred files ---

# Manual Steps to create encrypted credentials:
# 1. Create the key:
#    $Key = New-Object Byte[] 32
#    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
# 2. Save the key:
#    [IO.File]::WriteAllBytes("$credsFolder\my.key", $Key)
# 3. Convert and encrypt the password (replace "PasswordHere"):
#    $secure = ConvertTo-SecureString "PasswordHere" -AsPlainText -Force
#    $secure | ConvertFrom-SecureString -Key ([IO.File]::ReadAllBytes("$credsFolder\my.key")) | Set-Content "$credsFolder\enc.txt"
# NOTE: The CredsFolder is currently defined in your config file as: '$credsFolder'

# --- End Dynamic Steps ---


# --- 1. Check for Config File ---

if (Test-Path $actualConfigPath) {
    # Load actual, populated config
    Write-Host "Loading actual config file: $actualConfigFile" -ForegroundColor Green
    $configPath = $actualConfigPath
} elseif (Test-Path $templateConfigPath) {
    # If only the template exists, prompt the user to set up their config
    Write-Host "Configuration setup required!" -ForegroundColor Yellow
    Write-Host "Template config found: '$templateConfigFile'" -ForegroundColor Yellow
    Write-Host "Please rename it to '$actualConfigFile' and populate it with your private details inside the '$configDir' folder." -ForegroundColor Yellow
    exit 1
} else {
    # Neither file found
    Write-Host "FATAL ERROR: No configuration file found in '$configDir' folder." -ForegroundColor Red
    Write-Host "Please create a config file named '$actualConfigFile' based on the required structure." -ForegroundColor Red
    exit 1
}

# --- 2. Load Configuration ---

try {
    # Load values from JSON
    $config = Get-Content $configPath | ConvertFrom-Json
    $vCenterIP = $config.vCenterIP
    $username = $config.Username
    $credsFolder = $config.CredsFolder
} catch {
    Write-Host "FATAL ERROR: Failed to load or parse $actualConfigFile." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

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

    if (-not (Test-Path $KeyFilePath)) {
        Write-Host "ERROR: Credential key file not found: $KeyFilePath" -ForegroundColor Red
        Write-Host "Please follow the credential creation steps in the script comments." -ForegroundColor Yellow
        exit 1
    }
    
    if (-not (Test-Path $EncryptedPasswordFile)) {
        Write-Host "ERROR: Encrypted password file not found: $EncryptedPasswordFile" -ForegroundColor Red
        Write-Host "Please follow the credential creation steps in the script comments." -ForegroundColor Yellow
        exit 1
    }

    try {
        $key = [IO.File]::ReadAllBytes($KeyFilePath)
        $encrypted = Get-Content $EncryptedPasswordFile
        $securePassword = $encrypted | ConvertTo-SecureString -Key $key
        return New-Object System.Management.Automation.PSCredential($Username, $securePassword)
    } catch {
        Write-Host "Failed to decrypt credentials. Check file contents and encryption key match." -ForegroundColor Red
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