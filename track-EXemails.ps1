$sender = Read-Host "Specify sender"
$recipient = Read-Host "Specify recipient"

Get-MessageTrackingLog -sender $sender -recipients $recipient -eventID send | select TimeStamp,Sender,Recipients, MessageSubject,TotalBytes,EventID,RecipientStatus,ConnectorId,MessageId

exit