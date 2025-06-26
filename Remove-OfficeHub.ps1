Write-Host "Removing Apps..." -ForegroundColor Green
    Write-Host ""
    
    # Create array to hold list of apps to remove
    $appname = @(
        
 "*Microsoft.Desktop.Access*"
 "*Microsoft.Desktop.Excel*"
 "*Microsoft.Desktop.Outlook*"
 "*Microsoft.Desktop.Word*"
 "*Microsoft.Desktop.PowerPoint*"
 "*Microsoft.Desktop.Publisher*"
 "*Microsoft.MicrosoftOfficeHub*"
 "*Microsoft.Office.OneNote*"
 "*Microsoft.Office.Sway*"
 "*Office.Desktop*"
 "*Microsoft.MicrosoftOfficeHub*"
    )
    # Remove apps from current user
    ForEach($app in $appname){
    Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    # Remove apps from all users - may need to reboot after running above and run this again
    ForEach($app in $appname){
    Get-AppxPackage -Allusers -Name $app | Remove-AppxPackage -Allusers -ErrorAction SilentlyContinue
    }
    # Remove apps from provisioned apps list so they don't reinstall on new users
    ForEach($app in $appname){
    Get-AppxProvisionedPackage -Online | where {$_.PackageName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }