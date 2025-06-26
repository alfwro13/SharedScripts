$vmname = Read-Host "enter 3 letter user name"
get-VM "*$vmname*" | select Name,PowerState,Guest,NumCPU,MemoryGB,host,Folder,ResourcePool,VMResourceConfiguration