"This script will create a credential file"
"File will be saved to U drive as: PowershellCreds.txt"
"That file can only be used by user account that created it"
pause

(get-credential).password | ConvertFrom-SecureString | set-content "Y:\Work\U_drive\creds\modify_this.txt"
