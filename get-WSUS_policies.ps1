    get-gpo -ALL | where displayname -like "*WSUS*"
    Get-GPOReport "WSUS VDI Policy" -ReportType html -Path u:\report.html
    Start-Process "C:\Program Files\internet explorer\iexplore.exe" U:\report.html
