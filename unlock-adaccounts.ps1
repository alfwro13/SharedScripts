# --- Function to check for Domain Admin Group Membership using whoami ---
function Test-IsDomainAdmin {
    # Check current user's group membership for 'Domain Admins' using whoami /groups
    try {
        # whoami /groups returns a list of SIDs and group names
        $WhoAmIOutput = whoami /groups
        # We look for the Domain Admins group name in the output.
        if ($WhoAmIOutput -match "Domain Admins") {
            return $true
        } else {
            return $false
        }
    }
    catch {
        Write-Warning "Could not run 'whoami /groups' to determine status."
        return $false
    }
}

# --- Main Script Logic ---

$ScriptCredential = $null
$DomainAdminRequired = $false

# 1. Check if running with Domain Admin rights
if (Test-IsDomainAdmin) {
    Write-Host "Running with current credentials (Domain Admin detected)." -ForegroundColor Green
} else {
    Write-Host "Current user is NOT a Domain Admin." -ForegroundColor Yellow
    
    $DomainAdminRequired = $true
    
    # WORKAROUND: Force Graphical Credential Prompt to bypass console bug
    Write-Host "Forcing graphical credential prompt to appear. Please enter Domain Admin credentials." -ForegroundColor Yellow
    
    try {
        $ScriptCredential = $Host.UI.PromptForCredential(
            "Unlock Accounts", # Title of the credential window
            "Enter Domain Admin credentials to proceed with account unlocking.", # Message inside the window
            "", # Default username (blank)
            "" # Domain (blank)
        )
    }
    catch {
        Write-Host "ERROR: Could not launch credential prompt. Exiting script." -ForegroundColor Red
        exit 1
    }

    # CRITICAL CHECK: Check if the user hit Cancel/Esc
    # $Host.UI.PromptForCredential returns a PSCredential object, or $null if canceled.
    if (-not $ScriptCredential) {
        Write-Host "Credentials not provided (prompt canceled). Exiting script." -ForegroundColor Red
        exit 1
    }
}

# --- Execution Block ---

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Write-Host "`nLocked accounts (excluding 'Administrator'):"

try {
    $Params = @{
        'LockedOut' = $true
    }
    if ($ScriptCredential -ne $null) {
        $Params.Credential = $ScriptCredential
    }

    $LockedAccounts = Search-ADAccount @Params | 
        Where-Object { $_.Name -NotLike "Administrator" } | 
        Select-Object Name, SAMAccountName
}
catch {
    Write-Host "Failed to search Active Directory:" -ForegroundColor Red
    Write-Error $_.Exception.Message
    Write-Host "Exiting script." -ForegroundColor Red
    exit 1
}


if ($LockedAccounts) {
    $LockedAccounts | Format-Table -AutoSize
} else {
    Write-Host "No locked accounts found." -ForegroundColor Cyan
}

# Only proceed to unlock if there were locked accounts found
if ($LockedAccounts) {
    Write-Host ""
    Write-Host "Press any key to proceed to unlock" -ForegroundColor White
    Pause | Out-Null 

    Write-Host "Attempting to unlock accounts..." -ForegroundColor Yellow
    
    try {
        $UnlockParams = @{
            'Confirm' = $true
        }
        if ($ScriptCredential -ne $null) {
            $UnlockParams.Credential = $ScriptCredential
        }
        
        # --- THE FIX IS HERE ---
        # Iterate over each locked account and explicitly pass its SAMAccountName as the Identity parameter.
        $LockedAccounts | ForEach-Object {
            Write-Host "Unlocking $($_.SAMAccountName)..." -ForegroundColor Cyan
            Unlock-ADAccount -Identity $_.SAMAccountName @UnlockParams
        }
        # --- END OF FIX ---

        Write-Host "Unlock process complete." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to unlock accounts:" -ForegroundColor Red
        Write-Error $_.Exception.Message
    }
}

Pause