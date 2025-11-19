<#
.SYNOPSIS
Retrieves BitLocker recovery keys for a specified computer, checking for Domain Admin credentials first.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$ComputerName
)

# --- 1. Load the Credential Utility Functions ---
# IMPORTANT: Ensure DomainAdminUtils.psm1 is in the same directory, 
# or change the path below to the correct location.

Import-Module .\DomainAdminUtils.psm1

# --- 2. Acquire Credentials ---
Write-Host "Starting Domain Admin credential check..." -ForegroundColor White
$ScriptCredential = Get-DomainAdminCredential

# Critical Check: If credentials were required but failed or were canceled, exit.
if (-not $ScriptCredential -and -not (Test-IsDomainAdmin)) {
    Write-Host "Exiting script: Cannot proceed without Domain Admin privileges." -ForegroundColor Red
    exit 1
}

# --- 3. Script Execution Block (Your Logic Goes Here) ---

Import-Module ActiveDirectory -ErrorAction Stop

# Define the base parameters that will be used for both AD commands.
# The ErrorAction is included for robust error handling.
$BaseADParams = @{
    'ErrorAction' = 'Stop'
}

# Apply the credential if one was provided by the user
if ($ScriptCredential -ne $null) {
    $BaseADParams.Credential = $ScriptCredential
}

Write-Host "`nAttempting to find computer object '$ComputerName' and retrieve BitLocker keys..." -ForegroundColor Yellow

try {
    # 1. Get the Computer Object
    # Splatting the $BaseADParams ensures the credential is used if provided.
    $objComputer = Get-ADComputer $ComputerName @BaseADParams
    
    # 2. Search for BitLocker Recovery Objects under the computer's distinguished name
    $Bitlocker_Object = Get-ADObject @BaseADParams -Filter "objectclass -eq 'msFVE-RecoveryInformation'" `
        -SearchBase $objComputer.DistinguishedName `
        -Properties 'msFVE-RecoveryPassword'

    # 3. Output the Results
    if ($Bitlocker_Object) {
        Write-Host "--- BitLocker Recovery Keys Found ---" -ForegroundColor Green
        
        # FIX: Explicitly select the necessary properties for clean, readable output
        $Bitlocker_Object | 
            Select-Object Name, msFVE-RecoveryPassword, DistinguishedName |
            Format-List 

        Write-Host "-------------------------------------" -ForegroundColor Green
    } else {
        Write-Host "No BitLocker recovery keys found for '$ComputerName'." -ForegroundColor Cyan
    }
}
catch {
    Write-Host "Failed to execute Active Directory commands:" -ForegroundColor Red
    Write-Error $_.Exception.Message
    exit 1
}

Write-Host "`nScript execution complete." -ForegroundColor White