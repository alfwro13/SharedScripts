cls
do {
    do {
        write-host "------------------------------------------------------------------------"
        write-host ""
        write-host ""
        write-host "---- Account bits:  ----------------------------------------------------"
        write-host "A - Check and UNLOCK User accounts"
        write-host "B - RESET User Password"
        write-host "C - FORCE USER TO CHANGE PASSWORD AT NEXT LOGON"
        write-host "D - Get USERNAME from NAME/Surname"
        write-host "E - Get User Account EXPIRATION Date"
		Write-Host "U - Get AD User INFO"
		write-host "K - Enumerate AD Group members"
		Write-host "F - Get User LOCKED OUT Location - *MUST run as Domain Admin"
		write-host ""
        Write-Host "----Exchange bits-------------------------------------------------------"
        Write-Host "M - Get Exchange Events"
        Write-Host "N - Get Exchange MAPI Events"
        Write-Host ""
		write-host "---- Other bits --------------------------------------------------------"
        write-host "H - Get System UP TIME"
        Write-Host "I - Get ComputerName from Name or Surname"
		write-host "J - Get Computers assigned to a User"
		write-host "W - Create TSGW Remote Access Group "
        write-host "------------------------------------------------------------------------"
        Write-Host ""
		write-host "----- VMWare stuff:  ---------------------------------------------------"
		write-host "G - Connect to Vcenter"
		write-host "L - Get VM name from username"
		write-host ""
		write-host ""
        Write-Host "1 - Run mmc as ZAMW"
        Write-Host "2 - Run PowerShell as ZAMW"
        write-host ""
        write-host "0 - Clean Screen"
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
        
        $ok = $choice -match '^[abcdefhijklmnuwg012x]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {
        "A"
        {
            U:\unlock-adaccounts.ps1
        }
        
        "B"
        {
            U:\Reset-ADUserPassword.ps1
        }

        "C"
        {
            U:\Change-ADpasswordAtNextLogon.ps1
        }

        "D"
        {
            U:\get-ADuserByName.ps1
        }

        "E"
        {
            u:\get-ADUserPasswordExpirationDate.ps1
        }
		
		"F"
        {
            Get-LockedOutLocation
        }
		
        "K"
        {
            u:\get-adgroup-enumerate-users.ps1
        }
        "H"
        {
            u:\get-SystemUpTime.ps1
        }
        "I"
        {
            u:\get-adcomputer-by-username.ps1
        }
        "J"
        {
            u:\get-adcomputer-assigned-user.ps1
        }		
        "U"
        {
            u:\Get-ADUserInfo.ps1
        }
		"W"
        {
            u:\create-AD-TSGW-group.ps1
        }
		"G"
        {
            u:\connect-vcenter.ps1
        }
		"L"
        {
            u:\Get-VMbyUsername.ps1
        }
        "M"
        {
            U:\get-ExchangeEvents.ps1
        }
        "N"
        {
            U:\get-ExchangeMAPIEvents.ps1
        }
        "1"
        {
            U:\mmc.ps1
        }
        "2"
        {
            U:\powershell.ps1
        }

        "0"
        {
            cls
        }

    }
} until ( $choice -match "X" )