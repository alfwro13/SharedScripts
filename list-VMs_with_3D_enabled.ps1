get-vm | where name -like m4tc* | get-view -Property Name,Config.Hardware.Device |
 ForEach-Object {
 $VM = $_
 $VM.config.hardware.Device |
 where-object {$_.GetType().Name -eq "VirtualMachineVideoCard"} | `
     Select-Object -property @{N="VM";E={$VM.Name}},Enable3DSupport
   } | Where-Object {$_.Enable3DSupport}