param (
    [Parameter(Mandatory=$true)]
    [string]$computerName
)

Write-Host "Targeting computer: $computerName" -ForegroundColor Cyan

# 1. Verification (Outside the remote block for quick feedback)
try {
    Get-ADComputer -Identity $computerName -Properties Description | Select-Object Name, Description
}
catch {
    Write-Warning "Could not retrieve AD information for $computerName."
}

# Define services to manage
$services = @("bits", "wuauserv", "cryptSvc", "msiserver")

# 2. Remote Command Block
Invoke-Command -ComputerName $computerName -ScriptBlock {
    param($servicesToStop)

    Write-Host "--- Stopping Windows Update Related Services ---" -ForegroundColor Yellow

    # Stop all necessary services forcefully and quietly handle if already stopped
    foreach ($service in $servicesToStop) {
        Write-Host "Attempting to stop $service..."
        try {
            Stop-Service $service -Force -ErrorAction Stop
            # Add a check to ensure it actually stopped
            $serviceState = Get-Service $service
            if ($serviceState.Status -ne 'Stopped') {
                Write-Warning "$service is still running, waiting 5 seconds..."
                Start-Sleep -Seconds 5
                Stop-Service $service -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-Host "Service $service either not found or failed to stop: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    Write-Host "--- Clearing Update Folders and Registry Keys ---" -ForegroundColor Yellow
    $foldersToDelete = @("C:\Windows\SoftwareDistribution", "C:\Windows\System32\Catroot2")

    foreach ($folder in $foldersToDelete) {
        if (Test-Path $folder) {
            try {
                Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
                Write-Host "$folder successfully removed." -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Could not remove $folder. $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "$folder not found, skipping." -ForegroundColor Yellow
        }
    }

    # Remove the WSUS Unique ID from the Registry
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate"
    if (Test-Path $regPath) {
        Remove-ItemProperty -Path $regPath -Name "AccountDomainSid", "PingID", "SusClientId", "SusClientIdValidation" -ErrorAction SilentlyContinue
        Write-Host "Cleaned WSUS ID registry keys." -ForegroundColor Green
    }

    Write-Host "--- Starting Services ---" -ForegroundColor Yellow
    # Restart services in a logical order
    $servicesToStart = @("cryptSvc", "msiserver", "wuauserv", "bits")

    foreach ($service in $servicesToStart) {
        try {
            Start-Service $service -ErrorAction Stop
            Write-Host "$service started." -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Could not start $service - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Trigger new ID registration and reporting
    Write-Host "--- Triggering New WSUS ID Registration and Reporting ---" -ForegroundColor Yellow
    # Force a new ID to be generated and reported immediately
    & "$env:SystemRoot\System32\wuauclt.exe" /resetauthorization /detectnow
    Start-Sleep -Seconds 5
    & "$env:SystemRoot\System32\wuauclt.exe" /reportnow

    Write-Host "--- Job Complete ---" -ForegroundColor Cyan
    Write-Host "DO NOT forget to remove '$($env:COMPUTERNAME)' from the WSUS console." -ForegroundColor Red

    # Optional: Log collection (removed from final output for cleaner remote block)
    # The original log collection is often better run locally with Invoke-Command -AsJob
    
} -ArgumentList $services