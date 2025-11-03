$AppList = "Microsoft.BingNews",
           "Microsoft.BingSports",
           "Microsoft.BingWeather",
		   "Microsoft.BingSearch",
	   "*bing*",
           "Microsoft.SkypeApp",
           "Microsoft.WindowsAlarms",
           "Microsoft.windowscommunicationsapps",
           "Microsoft.3DBuilder",
           "Microsoft.BingFinance",
           "Microsoft.Getstarted",
	   "Microsoft.GamingApp",
           "Microsoft.MicrosoftOfficeHub",
           "Microsoft.Office.OneNote",
           "Microsoft.WindowsMaps",
           "Microsoft.WindowsPhone",
           "Microsoft.XboxApp",
           "Microsoft.WindowsFeedbackHub",
           "Microsoft.MixedReality.Portal",
           "Microsoft.Messaging",
           "Microsoft.XboxGameCallableUI",
           "Microsoft.GetHelp",
           "Microsoft.Xbox.TCUI",
           "Microsoft.XboxGamingOverlay",
  	   "Microsoft.XboxGameOverlay",
           "Microsoft.XboxIdentityProvider",
	   "MicrosoftTeams",
	   "Microsoft.YourPhone",
           "Microsoft.XboxSpeechToTextOverlay",
	   "Microsoft.GamingApp",
	   "MicrosoftWindows.Client.WebExperience",
	   "*SpotifyAB.SpotifyMusic*",
	   "*SkypeApp*"

ForEach ($App in $AppList) {
   $AppxPackage = Get-AppxProvisionedPackage -online | Where {$_.DisplayName -eq $App}
   Remove-AppxProvisionedPackage -online -packagename ($AppxPackage.PackageName)
   Remove-AppxPackage -AllUsers ($AppxPackage.PackageName)
}

ps onedrive | Stop-Process -Force
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
rd "%UserProfile%\OneDrive" /s /q
rd "%LocalAppData%\Microsoft\OneDrive" /s /q
rd "%ProgramData%\Microsoft OneDrive" /s /q
rd "C:\OneDriveTemp" /s /q
del "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" /s /f /q

sc delete MapsBroker
sc delete lfsvc
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsUpdateTask" /disable
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /disable


sc delete XblAuthManager
sc delete XblGameSave
sc delete XboxNetApiSvc
sc delete XboxGipSvc
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /f
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /disable
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /disable
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f

