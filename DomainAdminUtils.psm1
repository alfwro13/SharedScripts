<#
.SYNOPSIS
Provides utility functions for checking Domain Admin status and retrieving necessary credentials.
#>

function Test-IsDomainAdmin {
    <#
    .SYNOPSIS
    Checks if the current user is a member of the 'Domain Admins' group.
    
    .DESCRIPTION
    Uses 'whoami /groups' to quickly check for the presence of the 'Domain Admins' group name in the output.
    #>
    [CmdletBinding()]
    param()

    # Check current user's group membership for 'Domain Admins'
    try {
        # whoami /groups returns a list of SIDs and group names
        $WhoAmIOutput = whoami /groups
        
        # We look for the 'Domain Admins' group name.
        if ($WhoAmIOutput -match "Domain Admins") {
            return $true
        } else {
            return $false
        }
    }
    catch {
        Write-Warning "Could not run 'whoami /groups' to determine status: $($_.Exception.Message)"
        return $false
    }
}

function Get-DomainAdminCredential {
    <#
    .SYNOPSIS
    Determines the necessary credential for a Domain Admin operation.
    
    .DESCRIPTION
    If Test-IsDomainAdmin is true, returns $null (use current user).
    If Test-IsDomainAdmin is false, prompts the user for a PSCredential object.
    
    .OUTPUTS
    PSCredential or $null
    #>
    [CmdletBinding()]
    param()

    # Check if the current user has the required rights
    if (Test-IsDomainAdmin) {
        Write-Host "Execution context is already Domain Admin. Using current user rights." -ForegroundColor Green
        return $null
    } else {
        Write-Host "Current user is NOT a Domain Admin. Credentials are required." -ForegroundColor Yellow
        
        $ScriptCredential = $null
        
        # Force Graphical Credential Prompt
        Write-Host "Forcing graphical credential prompt. Please enter Domain Admin credentials." -ForegroundColor Yellow
        
        try {
            $ScriptCredential = $Host.UI.PromptForCredential(
                "Domain Admin Credentials Required", # Title
                "Enter Domain Admin credentials to proceed.", # Message
                "", # Default username
                ""  # Default domain
            )
        }
        catch {
            Write-Host "ERROR: Could not launch credential prompt. Exiting privilege check." -ForegroundColor Red
            return $null # Return null on hard failure
        }

        # CRITICAL CHECK: Check if the user hit Cancel/Esc
        if (-not $ScriptCredential) {
            Write-Host "Credentials not provided (prompt canceled). Returning $null." -ForegroundColor Red
            return $null
        }

        Write-Host "Credentials successfully captured." -ForegroundColor Cyan
        return $ScriptCredential
    }
}