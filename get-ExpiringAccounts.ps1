$daysbeforeexpirytonotify = 14
$now = (get-date).ToUniversalTime().ToFileTime()  
$threshold = (get-date).ToUniversalTime().adddays($daysbeforeexpirytonotify).ToFileTime()  
$users = Get-ADUser -Filter  "name -like '*'" -Properties "msDS-UserPasswordExpiryTimeComputed",mail |
    where { $_."msDS-UserPasswordExpiryTimeComputed" -lt $threshold -and `
            $_."msDS-UserPasswordExpiryTimeComputed" -gt $now } | Select-Object Name,SAMAccountName,mail,@{Name="ExpiryDate";Expression={
                        [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")
                        }
                  }, @{Name="DaysToExpiry";Expression={
                         [int](($_."msDS-UserPasswordExpiryTimeComputed" - $now) / 864000000000)
                         }
                  } | sort DaysToExpiry
 $users  | ft
 
 