param (
    [Parameter(Mandatory=$true)]
    [string]$UserName
)

get-mailbox $UserName | Select DisplayName,SamAccountName,OrganizationalUnit,GrantSendOnBehalssListsEnabled,EmailAddressPolicyEnabled,PrimarySmtpAddress,Database,ServerName,RetentionPolicy,ForwardingAddress,IsMailboxEnabled,RetainDeletedItemsFor,ProhibitSendQuota,ProhibitSendReceiveQuota,UseDatabaseQuotaDefaults,IssueWarningQuota,IsLinked,LinkedMasterAccount
get-mailboxStatistics $UserName | select AssociatedItemCount,DeletedItemCount,DisconnectDate,DisconnectReason,ItemCount,LastLoggedOnUserAccount,LastLogoffTime,LastLogonTime,ObjectClass,StorageLimitStatus,TotalDeletedItemSize,TotalItemSize,DatabaseName,IsValid

pause
write-host "Auto Reply Config:" -BackgroundColor Yellow -ForegroundColor Black
Get-MailboxAutoReplyConfiguration $UserName | select AutoReplyState
write-host "Junk Mail Settings: " -BackgroundColor Yellow -ForegroundColor Black
Get-MailboxJunkEmailConfiguration $userName | select Enabled,TrustedListsOnly,ContactsTrusted,TrustedSendersAndDomains,BlockedSendersAndDomains
write-host "Email Message Settings:" -BackgroundColor Yellow -ForegroundColor Black
Get-MailboxMessageConfiguration $UserName | select AfterMoveOrDeleteBehavior,NewItemNotification,EmptyDeletedItemsOnLogoff,AutoAddSignature,SignatureText,DefaultFontName,DefaultFontSize,DefaultFontColor,DefaultFontFlags,AlwaysShowBcc,AlwaysShowFrom,DefaultFormat,ReadReceiptResponse,PreviewMarkAsReadBehavior,PreviewMarkAsReadDelaytime,ConversationSortOrder,ShowConversationAsTree,HideDeletedItems
write-host "Regional Settings: " -BackgroundColor Yellow -ForegroundColor Black
Get-MailboxRegionalConfiguration $UserName | select DateFormat,Language,DefaultFolderNameMatchingUserLanguage,TimeFormat,TimeZone
pause
write-host "Disk quota info:" -BackgroundColor Yellow -ForegroundColor Black
"-----------------------------------"
get-mailbox $UserName -ResultSize unlimited | Get-MailboxStatistics | Select DisplayName,StorageLimitStatus,@{name="TotalItemSize (MB)";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}},@{name="TotalDeletedItemSize (MB)";expression={[math]::Round((($_.TotalDeletedItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}},ItemCount,DeletedItemCount | Sort "TotalItemSize (MB)" -Descending
""
""
get-mailbox $UserName | format-list *quota

"-----------------------------------"
""
""
""
Write-Host "AD User Info:" -BackgroundColor Yellow -ForegroundColor Black
pause
.\Get-AduserInfo.ps1 $UserName