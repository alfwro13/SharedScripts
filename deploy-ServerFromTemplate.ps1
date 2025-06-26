import-module activedirectory

function Get-FolderPath{
    <#
    .SYNOPSIS
        Returns the folderpath for a folder
    .DESCRIPTION
        The function will return the complete folderpath for
        a given folder, optionally with the "hidden" folders
        included. The function also indicats if it is a "blue"
        or "yellow" folder.
    .NOTES
        Authors:    Luc Dekens, AMW (modified a bit)
    .PARAMETER Folder
        On or more folders
    .PARAMETER ShowHidden
        Switch to specify if "hidden" folders should be included
        in the returned path. The default is $false.
    .EXAMPLE
        PS> Get-FolderPath -Folder (Get-Folder -Name "MyFolder")
    .EXAMPLE
        PS> Get-Folder | Get-FolderPath -ShowHidden:$true
    #>

        param(
        [parameter(valuefrompipeline = $true,
        position = 0,
        HelpMessage = "Enter a folder")]
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl[]]$Folder,
        [switch]$ShowHidden = $false
        )

        begin{
            $excludedNames = "Datacenters","vm","host"
        }
 
        process{

            $Folder | %{
                $fld = $_.Extensiondata
                $fldType = "yellow"
                if($fld.ChildType -contains "VirtualMachine"){
                    $fldType = "blue"
                }
                $path = $fld.Name
                $parentID = $fld.MoRef
                while($fld.Parent){
                    $fld = Get-View $fld.Parent
                    if((!$ShowHidden -and $excludedNames -notcontains $fld.Name) -or $ShowHidden){
                        $path = $fld.Name + "\" + $path
                    }
                }
                $row = "" | Select Name,Path,Type,FolderID
                $row.Name = $_.Name
                $row.Path = $path
                $row.Type = $fldType
                $row.FolderID = $parentID
                $row
            }

    }
}

$vmName = read-host "specify computer name"

Y:\NC\Work\U_drive\connect-VMware.ps1

Write-host "Select template"

$templates = get-template | where {$_.name -like 'M4UK*'}
$template = $templates | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$template | ft -auto
$myTemplate = read-host "select Template ID"
$template_selection = $templates[$myTemplate]

$owner = read-host "Specify owner of this VM"
$note = read-host "Enter notes for this VM"
$ticket = read-host "Sepcify service desk ticket number"

$ClusterQ = Read-Host "Is this a Production system (Y/N)"
if ($ClusterQ -eq "Y") { $cluster = get-cluster -name "UK Production Cluster"
"Selected Production Cluster"

#Datastore selector
write-host "Select Datastore"
$datastores = $cluster | get-datastore | where {$_.name -like 'FS5200_DEV*'}
$datastore = $datastores | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$datastore | ft -auto
$myDatastore = read-host "select Datastore ID"
$datastore_selection = $datastore[$myDatastore]

#Folder Selector
Write-host "Select folder"
write-host "Generating folder tree structure...."
$Folder = get-folder -type vm | where{$_.name -ne 'vm'} | get-folderpath | select FolderID,path,name | Sort path | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$folder | ft -AutoSize
$myFolder = read-host "select Folder ID"
$Folder_selection = $Folder[$myFolder]

#Resource Pool Selector
write-host "Select Resource Pool"
$ResourcePool = $cluster | get-ResourcePool | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$ResourcePool | ft -auto
$myResourcePool = read-host "select Resource Pool ID"
$ResPool_selection = $ResourcePool[$myResourcePool]

$ResPool = (Get-ResourcePool $ResPool_selection.name).id

 }
    else {  
    $cluster = get-cluster -name "UK Development Cluster"
   "Selected Development Cluster" 

#Datastore selector
write-host "Select Datastore"
$datastores = $cluster | get-datastore | where {$_.name -like 'FS5200_DEV_*'}
$datastore = $datastores | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$datastore | ft -auto
$myDatastore = read-host "select Datastore ID"
$datastore_selection = $datastore[$myDatastore]

#Folder Selector
Write-host "Select folder"
write-host "Generating folder tree structure...."
$Folder = get-folder -type vm | where{$_.name -ne 'vm'} | get-folderpath | select FolderID,path,name | Sort path | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$folder | ft -AutoSize
$myFolder = read-host "select Folder ID"
$Folder_selection = $Folder[$myFolder]

#Resource Pool Selector
write-host "Select Resource Pool"
$ResourcePool = $cluster | get-ResourcePool | select name | % {$counter = -1} {$counter++; $_ | Add-Member -Name Role_ID -Value $counter -MemberType NoteProperty -PassThru}
$ResourcePool | ft -auto
$myResourcePool = read-host "select Resource Pool ID"
$ResPool_selection = $ResourcePool[$myResourcePool]

$ResPool = ($cluster | Get-ResourcePool $ResPool_selection.name).id

    }
        Clear-Host
        Write-Host "Will deploy to" $datastore_selection.name
        Write-Host "There is" (get-datastore $datastore_selection.Name).FreeSpaceGB "GB of free space"
        Write-Host "Total size is:" (get-datastore $datastore_selection.Name).CapacityGB "GB"

        $template_hdd_size = get-template $template_selection | get-harddisk

        foreach ($drive in $template_hdd_size.capacitygb) {
		    $disk_space_required += $drive
		    }
        Write-Host "Required disk space:" $disk_space_required "GB"
        ""
        ""
"You have selected:"
""
"Template: " + $template_selection.Name
"Cluster: " + $cluster
"Datastore: " + $datastore_selection.Name
"Folder path: " + $folder_selection.path + "    Folder Name: " + $Folder_selection.name
"folder ID: " + $Folder_selection.FolderID
"Resource Pool: " + $ResPool_selection.name
"VM Name: " + $vmName
"Owner: " + $owner
"Ticket Number: " + $ticket
""
""
write-host "Do you want to go ahead?"
Write-Host "Press Ctrl-C to cancel"
pause

New-VM -name $vmName -ResourcePool (Get-ResourcePool -Id $ResPool) -Location (get-folder -id $Folder_selection.FolderID) -Datastore $datastore_selection.Name -Template $template_selection.Name

Write-host "Wait for VM to deply then proceed"
pause

"Powering VM On ...."
start-vm $vmName -Verbose:$false | out-null


write-host "setting vSphere Note and Owner"
set-vm $vmName -Description $note -Confirm:$false
get-VM $vmName | Set-Annotation -CustomAttribute "Owner" -Value $Owner
get-VM $vmName | Set-Annotation -CustomAttribute "Ticket Number" -Value $ticket