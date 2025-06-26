param (
[Parameter(Mandatory=$true)]
[string]$command
	)
""
runas /user:isys\zamw "powershell.exe -noExit -command $command"
