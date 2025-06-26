$daysbeforeexpirytonotify = 0 
$now = (get-date).ToUniversalTime().ToFileTime()  
$threshold = (get-date).ToUniversalTime().adddays($daysbeforeexpirytonotify).ToFileTime()  
$users = Get-ADUser -Filter  "name -like '*'" -Properties "msDS-UserPasswordExpiryTimeComputed",mail |
    where { $_."msDS-UserPasswordExpiryTimeComputed" -lt $threshold } | Select-Object Name,SAMAccountName,mail,@{Name="ExpiryDate";Expression={
                        [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
                        }
                  } 

 $users | sort ExpiryDate
 
 