Import-Module .\DomainAdminUtils.psm1

# --- Main Script Logic ---

# 1. Get the required credentials (will be $null if current user is DA)
Write-Host "Starting credential check..." -ForegroundColor White
$ScriptCredential = Get-DomainAdminCredential

# If credentials were required but not returned (e.g., user canceled prompt), exit.
if (-not $ScriptCredential -and -not (Test-IsDomainAdmin)) {
    Write-Host "Exiting script due to lack of required Domain Admin credentials." -ForegroundColor Red
    exit 1
}

# 2. Proceed with the Active Directory operations using the retrieved credential

Import-Module ActiveDirectory -ErrorAction Stop

Write-Host "`nSearching for locked accounts..." -ForegroundColor Yellow

try {
    # Define parameters for the AD command
    $SearchParams = @{
        'LockedOut' = $true
        'ErrorAction' = 'Stop'
    }
    
    # Add the credential parameter if one was provided
    if ($ScriptCredential -ne $null) {
        $SearchParams.Credential = $ScriptCredential
    }

    $LockedAccounts = Search-ADAccount @SearchParams | 
        Where-Object { $_.Name -NotLike "Administrator" } | 
        Select-Object Name, SAMAccountName
}
catch {
    Write-Host "Failed to search Active Directory. Check if the Active Directory module is installed or if permissions are correct." -ForegroundColor Red
    Write-Error $_.Exception.Message
    exit 1
}

if ($LockedAccounts) {
    Write-Host "`n--- Locked Accounts Found ---" -ForegroundColor Yellow
    $LockedAccounts | Format-Table -AutoSize
    Write-Host "---------------------------" -ForegroundColor Yellow
} else {
    Write-Host "`nNo locked accounts found (excluding 'Administrator')." -ForegroundColor Cyan
}

# 3. Unlock Accounts
if ($LockedAccounts) {
    Write-Host ""
    Read-Host "Press ENTER to proceed to unlock accounts..." | Out-Null

    Write-Host "Attempting to unlock accounts..." -ForegroundColor Yellow
    
    try {
        $UnlockParams = @{
            'Confirm' = $false # Setting this to $false for demonstration, change to $true for interactive use
            'ErrorAction' = 'Stop'
        }
        
        # Add the credential parameter if one was provided
        if ($ScriptCredential -ne $null) {
            $UnlockParams.Credential = $ScriptCredential
        }
        
        # Iterate over each locked account and unlock
        $LockedAccounts | ForEach-Object {
            Write-Host "Unlocking $($_.SAMAccountName)..." -ForegroundColor Cyan
            Unlock-ADAccount -Identity $_.SAMAccountName @UnlockParams
        }

        Write-Host "`nUnlock process complete." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to unlock one or more accounts:" -ForegroundColor Red
        Write-Error $_.Exception.Message
    }
}
