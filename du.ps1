param (
    [Parameter(Mandatory=$true)]
    [string]$dir
)
write-host "Working...... "
get-childitem $dir |
 foreach-object {
	$f=$_
	get-ChildItem -Recurse $_.FullName | measure-object -property length -sum | select @{Name="Name"; Expression={$f}} , @{Name="Sum (MB)"; Expression={ "{0:N3}" -f ($_.sum / 1MB) }}, Sum 
		} | sort Sum -desc | format-table -Property Name,"Sum (MB)", Sum -autosize 
