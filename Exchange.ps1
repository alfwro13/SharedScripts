cls
do {
    do {
 write-warning "------This script is Work In Progress -------------"
 ""
 write-host "Domain Account Permission Required" -BackgroundColor Yellow -ForegroundColor red
 Write-host "Current Username:" $(whoami) -BackgroundColor Yellow -ForegroundColor red
 ""
 $user = $(whoami)
 if ($user -like "isys\z*" ) {write-host "Permissions Verified - OK"
 }
 else {write-host "You do not have the necessary access rights to proceed further."
       write-host "Starting Your Admin powershell session" -BackgroundColor Yellow -ForegroundColor red
       U:\powershell.ps1
       exit
       }

"Current Exchange Sessions:"
 
 $pssessions = Get-PsSession
    if (!$pssessions) { Write-Host "There is currently no PS Sessions" }
    else {
        Get-PSSession | ft

 }
                   "Select one of the CAS servers to establish a PS Session:"
				   "          1 - Cas1    OR     2 - Cas2"
                   "Common Exchange Tasks:"
                   "┌--------------------------------------------------------"
                   "|  3 - Create Mailbox for an Existing AD Account"
                   "|  4 - Export Mailbox to a PST file"
                   "|  5 - Disable User's Mailbox"
                   "|  6 - Reassign Email address to another User"
                   "|  7 - Create and add users to distribution group"
                   "|  8 - Track emails/messages"
                   "└--------------------------------------------------------"
                   ""
                   "H - Helpful comands and general Help"
 		write-host "X - Exit" 
                   ""
        write-host "_________________________________________________________________________"
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[12345678hx]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {
        "h"
        {
           "┌--------------------------------------------------------------------------------------"
           "| NOTES: Curent setup uses import-PSsession ... other possibility enter-PSsession ...."
           "| in that scenario use get-PSsession"
           "|"
write-host "| Useful commands:" -BackgroundColor Cyan -ForegroundColor Black
           "| Set-MailboxAutoReplyConfiguration - Sets Autoreply for a mailbox"
           "| Get-MailboxFolderStatistics $mailbox - Get stats for a mailbox"
           "| Get-PSSession"
           "| Remove-PSsession -id X  - Use this to disconnect from EX session"
           "| Get-Command -Module MODULE_NAME"
           "| get-module - Run this to list available modules"
           "└--------------------------------------------------------------------------------------"
        pause
        cls
		}

        "1"
        {
         $cas1 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://m4ukcas1/PowerShell/ -Authentication Kerberos   
        import-PSsession $cas1
        cls
		}
        
        "2"
        {
         $cas2 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://m4ukcas2/PowerShell/ -Authentication Kerberos 
        import-PSsession $cas2
        cls
		}

        "3"
        {
         U:\create-EXMailbox.ps1
		}

        "4"
        {
         U:\export-EXUserMailbox.ps1
		}

        "5"
        {
         U:\Disable-EXMailbox.ps1
		}

        
        "6"
        {
        import-module U:\Add-EXEmailAddress.ps1
         $userid = read-host "Specify user user ID"
         $id6 = get-aduser $userid -prop *
         write-host "You have entered:" $id6.Name
         ""
         $emailaddress = read-Host "Specify email address that you wish to add to that ID"

         add-EmailAddress $userid $emailaddress
         
         "Job Done:"
         ""
         get-mailbox $userid | select -ExpandProperty EmailAddresses

         pause
         ""
         "------------------------------------------------------------"
		}

        "7"
        {
         U:\create-EXDistributionGroup.ps1
		}
        "8"
        {
         U:\track-EXemails.ps1
		}

	}
} until ( $choice -match "X" )