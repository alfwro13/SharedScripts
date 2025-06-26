$then = (Get-Date).AddDays(-360) # The 360 is the number of days from today since the last logon.

Get-ADuser -Property Name,lastLogonDate -Filter {lastLogonDate -lt $then} | FT Name,lastLogonDate
