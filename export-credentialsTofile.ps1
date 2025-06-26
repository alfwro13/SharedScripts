$PathToFolderWithCredentials = "u:\"

#write-host "Enter login as domain\login:"
#read-host | out-file $PathToFolderWithCredentials\PowershellCreds_amw.txt

write-host "Enter password:"
read-host -assecurestring | convertfrom-securestring | out-file $PathToFolderWithCredentials\PowershellCreds_amw.txt

write-host "*** Credentials have been saved to $pathtofolder ***"