"This script generates CSV file of all VM that have a snapshot"

get-vm * | Get-Snapshot | select VM,Created,SizeMB,ID,Name,Description | Out-GridView