    Function add-ADUser-to-Local-Group
    {
    [cmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]$computer,
    [Parameter(Mandatory=$True)]
    [string]$group,
    [Parameter(Mandatory=$True)]
    [string]$domain,
    [Parameter(Mandatory=$True)]
    [string]$user
    )
    $de = [ADSI]“WinNT://$computer/$Group,group”
    $de.psbase.Invoke(“Add”,([ADSI]“WinNT://$domain/$user”).path)
    } #end function add-ADUser-to-Local-Group