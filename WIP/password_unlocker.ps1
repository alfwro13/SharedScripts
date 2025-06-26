Set-ExecutionPolicy Unrestricted
cls
do {
    do {
        write-host "------------------------------------------------------------------------"
        write-host ""
        write-host ""
        write-host ""
        write-host "A - Check and UNLOCK User accounts"
        write-host "B - RESET User Password"
        write-host "C - FORCE USER TO CHANGE PASSWORD AT NEXT LOGON"
        write-host ""
        write-host "X - Exit"
        write-host ""
        write-host ""
        write-host ""
        write-host -nonewline "Type your choice and press Enter: "
        write-host ""
        write-host "_________________________________________________________________________"
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[abcdehi012x]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {
        "A"
        {
            Write-host "Locked accounts:"
			Search-ADAccount -lockedout | select name
			Write-Host "Press any key to proceed to unlock"
			pause


			Search-ADAccount -lockedOut | unlock-ADAccount -confirm
			Pause
			cls
        }
        
        "B"
        {
		$username = Read-Host "Enter 3 letter username"
		$plainpassword = Read-Host "Enter the new password"
		$password = ConvertTo-SecureString -String $plainpassword -AsPlainText -Force
		Write-Host "you have entered the following username and password ISYS\"$username $plainpassword
		Write-Host "press any key to reset the password"
		pause
		Set-ADAccountPassword $username -NewPassword $password -Reset
		Write-Host "Password Set!!! "
		Get-ADUser $username -Properties * | select DisplayName,Enabled,PasswordLastSet
        cls
		}

        "C"
        {
            
			$username = read-host "3 letter username"

			Write-Host "you have entered the following username ISYS\"$username 
			Write-Host "press any key to FORCE THE USER TO CHANGE PASSWORD AT NEXT LOGON"
			pause

			Set-aduser $username -ChangePasswordAtLogon $True
			Write-Host "Option Set! "
			cls
			
			
			
        }

    }
} until ( $choice -match "X" )