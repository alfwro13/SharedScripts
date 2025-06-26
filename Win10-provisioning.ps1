function Pin-App {    param(
        [string]$appname,
        [switch]$unpin
    )
    try{
        if ($unpin.IsPresent){
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Start" lösen|Unpin from Start'} | %{$_.DoIt()}
            return "App '$appname' unpinned from Start"
        }else{
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Start" anheften|Pin to Start'} | %{$_.DoIt()}
            return "App '$appname' pinned to Start"
        }
    }catch{
        Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
    }
}

#
# Removing and unpining useless MS crapware
#

Pin-App "Mail" -unpin
Pin-App "Store" -unpin
Pin-App "Calendar" -unpin
Pin-App "Microsoft Edge" -unpin
Pin-App "Cortana" -unpin
Pin-App "Weather" -unpin
Pin-App "Phone Companion" -unpin
Pin-App "Skype Video" -unpin
Pin-App "Candy Crush Soda Saga" -unpin
Pin-App "xbox" -unpin
Pin-App "Groove music" -unpin
Pin-App "microsoft solitaire collection" -unpin
Pin-App "money" -unpin
Pin-App "get office" -unpin
Pin-App "onenote" -unpin
Pin-App "news" -unpin
Pin-App "Films & TV" -unpin
Pin-App "Photos" -unpin
Pin-App "Get Started" -unpin
Pin-App "This PC" -pin
Pin-App "Microsoft Outlook 2010" -pin
Pin-App "Internet Explorer" -pin
  

Get-AppxPackage *3dbuilder* | Remove-AppxPackage
Get-AppxPackage *alarms* | Remove-AppxPackage
Get-AppxPackage *calculator* | Remove-AppxPackage
Get-AppxPackage *communications* | Remove-AppxPackage
Get-AppxPackage *camera* | Remove-AppxPackage
Get-AppxPackage *candycrush* | Remove-AppxPackage
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *skypeapp* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *zunemusic* | Remove-AppxPackage
Get-AppxPackage *maps* | Remove-AppxPackage
Get-AppxPackage *solitairecollection* | Remove-AppxPackage
Get-AppxPackage *bingfinance* | Remove-AppxPackage
Get-AppxPackage *zunevideo* | Remove-AppxPackage
Get-AppxPackage *bingnews* | Remove-AppxPackage
Get-AppxPackage *onenote* | Remove-AppxPackage
Get-AppxPackage *office.sway* | Remove-AppxPackage
Get-AppxPackage *people* | Remove-AppxPackage
Get-AppxPackage *windowsphone* | Remove-AppxPackage
Get-AppxPackage *photos* | Remove-AppxPackage
Get-AppxPackage *bingsports* | Remove-AppxPackage
Get-AppxPackage *soundrecorder* | Remove-AppxPackage
Get-AppxPackage *bingweather* | Remove-AppxPackage
Get-AppxPackage *xbox* | Remove-AppxPackage

Get-AppxProvisionedPackage -online | ? PackageName -like *xboxapp* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *ZuneMusic* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *ZuneVideo* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *OfficeHub* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *sway* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *3dbuilder* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *bingNews* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *bingweather* | Remove-AppxProvisionedPackage -online
Get-AppxProvisionedPackage -online | ? PackageName -like *bingfinance* | Remove-AppxProvisionedPackage -online

#
# Enabling PS remoting
#
enable-psremoting -force


#
# Install .Net3.5
#

DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:d:\sources\sxs | write-output


#
#
#

compact.exe /compactos:always | write-output