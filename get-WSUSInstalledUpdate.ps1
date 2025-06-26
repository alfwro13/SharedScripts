Write-Host "Use this script to find out if the specified update has been installed"
$KB_article = Read-Host "What's your KB number (i.e.: KB3114878) "
$Session = New-Object -ComObject "Microsoft.Update.Session"
$Searcher = $Session.CreateUpdateSearcher()
$historyCount = $Searcher.GetTotalHistoryCount()
$Searcher.QueryHistory(0, $historyCount) | where {$_.title -like "*$KB_article*"}
