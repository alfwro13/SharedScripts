cls
do {
    do {
 ""
 write-host "Domain Account Permission Required" -BackgroundColor Yellow -ForegroundColor red
 Write-host "Current Username:" $(whoami) -BackgroundColor Yellow -ForegroundColor red
 ""
 $user = $(whoami)
 if ($user -like "isys\z*" ) {write-host "Permissions Verified - OK"
 }
 else {write-host "You do not have the necessary access rights to proceed further."
 write-host "Starting Your Admin powershell session" -BackgroundColor Yellow -ForegroundColor red
 .\powershell.ps1
 exit
 }

 "Current Exchange Sessions:"
 Get-PsSession
 ""
 "If the list above is empty open PS session:"
 "0 - Open Exchange Session to CAS1"
 "5 - Close All Open PS Sessions"
 ""
 "Mailbox Export Menu:"
 "┌--------------------------------------------------------"
 "| 1 - Create Export request for a specified mailbox"
 "| 2 - Check Status"
 "| 3 - Display completed requests"
 "| 4 - Remove ALL completed request"
 "└--------------------------------------------------------"
  "x- Exit"
 ""
        write-host "_________________________________________________________________________"
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[012345x]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {
        "1"
        {
            $mailboxname = read-host "Specify user name/maiblox name"
            $filepath = read-host "specify the name and location for the pst file i.e. \\m4ukcas1\pst\user.pst"
            
            write-host (get-aduser $mailboxname | select Name) "mailbox will be exported to: " $filepath
            Write-Host ""
            New-MailboxExportRequest -Mailbox $mailboxname -FilePath $filepath -confirm

            pause

		}
        
        "2"
        {
         Get-MailboxExportRequest | Get-MailboxExportRequestStatistics | select Filepath,SourceMailboxIdentity,EstimatedTransferSize,BytesTransferred,PercentComplete
         ""
         Get-MailboxExportRequest | ft

         pause
         ""
         "----------------------------------------------------------"
		}

        "3"
        {
         Get-MailboxExportRequest | where {$_.status -eq "Completed"} | select Mailbox,Status
         ""
         pause
         ""
         "----------------------------------------------------------"
		}

        "4"
        {
         Get-MailboxExportRequest | where {$_.status -eq "Completed"} | Remove-MailboxExportRequest
         ""
         pause
         ""
		}

        "5"
        {
         Get-PSSession | Remove-PSSession
         cls
		}

        "0"
        {
        $cas1 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://m4ukcas1/PowerShell/ -Authentication Kerberos
        $session = import-PSsession $cas1
        cls
        }

	}
} until ( $choice -match "X" )