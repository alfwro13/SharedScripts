 Write-Host "the following commands are now available:"
 Write-Host "Get-ViSession - Lists vCenter Sessions."
 Write-Host "Get-VMHostPerfStat"
 Write-Host "Get-VMPerfStat"

 function Get-VMPerfStat { 
        param ( [string]$VMName, 
                [int]$Days = "30" 
        ) 
        Begin { 
            $PerfStat = New-Object PSObject 
            $vm = Get-VM $VMName 
            $todayMidnight = ( Get-Date -Hour 0 -Minute 0 -Second 0 ).AddMinutes( -1 ) 
            $cpustat = $vm | Get-Stat -Stat cpu.usage.average -Start $todayMidnight.AddDays( -$Days ) -Finish 
$todayMidnight.AddDays( -1 ) | where{ $_.Instance -eq "" } 
            $cpuuse = ( $cpustat | Measure-Object -Property Value -Maximum -Minimum -Average ) 
            $memstat = $vm | Get-Stat -Stat mem.usage.average -Start $todayMidnight.AddDays( -$Days ) -Finish 
$todayMidnight.AddDays( -1 ) | where{ $_.Instance -eq "" } 
            $memuse = ( $memstat | Measure-Object -Property Value -Maximum -Minimum -Average ) 
        } 
        Process { 
            $PerfStat | add-member -MemberType NoteProperty -name "VMName" -Value $VMName 
            $PerfStat | add-member -MemberType NoteProperty -name "CPUAv%" -Value ( [System.Math]::Round( $cpuuse.Average,2 ) 
) 
            $PerfStat | add-member -MemberType NoteProperty -name "CPUMax%" -Value ( [System.Math]::Round( $cpuuse.Maximum,2 
) ) 
            $PerfStat | add-member -MemberType NoteProperty -name "CPUMin%" -Value ( [System.Math]::Round( $cpuuse.Minimum,2 
) ) 
            $PerfStat | add-member -MemberType NoteProperty -name "MemAv%" -Value ( [System.Math]::Round( $memuse.Average,2 ) 
) 
            $PerfStat | add-member -MemberType NoteProperty -name "MemMax%" -Value ( [System.Math]::Round( $memuse.Maximum,2 
) ) 
            $PerfStat | add-member -MemberType NoteProperty -name "MemMin%" -Value ( [System.Math]::Round( $memuse.Minimum,2 
) ) 
        } 
        End { 
            $PerfStat 
        } 
    } 
 function Get-VMHostPerfStat { 
        param ( [string]$VMhostName, 
                [int]$Days = "30" 
        ) 
        Begin { 
            $PerfStat = New-Object PSObject 
            $VMhost = Get-VMhost $VMhostName 
            $todayMidnight = ( Get-Date -Hour 0 -Minute 0 -Second 0 ).AddMinutes( -1 ) 
            $cpustat = $VMhost | Get-Stat -Stat cpu.usage.average -Start $todayMidnight.AddDays( -$Days ) -Finish 
$todayMidnight.AddDays( -1 ) | where{ $_.Instance -eq "" } 
            $cpuuse = ( $cpustat | Measure-Object -Property Value -Maximum -Minimum -Average ) 
            $memstat = $VMhost | Get-Stat -Stat mem.usage.average -Start $todayMidnight.AddDays( -$Days ) -Finish 
$todayMidnight.AddDays( -1 ) | where{ $_.Instance -eq "" } 
            $memuse = ( $memstat | Measure-Object -Property Value -Maximum -Minimum -Average ) 
        } 
        Process { 
            $PerfStat | add-member -MemberType NoteProperty -name "VMhostName" -Value $VMhost.Name 
            $PerfStat | add-member -MemberType NoteProperty -name "CPUAv%" -Value ( [System.Math]::Round( $cpuuse.Average,2 ) 
) 
            $PerfStat | add-member -MemberType NoteProperty -name "CPUMax%" -Value ( [System.Math]::Round( $cpuuse.Maximum,2 
) ) 
            $PerfStat | add-member -MemberType NoteProperty -name "CPUMin%" -Value ( [System.Math]::Round( $cpuuse.Minimum,2 
) ) 
            $PerfStat | add-member -MemberType NoteProperty -name "MemAv%" -Value ( [System.Math]::Round( $memuse.Average,2 ) 
) 
            $PerfStat | add-member -MemberType NoteProperty -name "MemMax%" -Value ( [System.Math]::Round( $memuse.Maximum,2 
) ) 
            $PerfStat | add-member -MemberType NoteProperty -name "MemMin%" -Value ( [System.Math]::Round( $memuse.Minimum,2 
) ) 
        } 
        End { 
            $PerfStat 
        } 
    } 


Function Get-ViSession {
    <#
        .SYNOPSIS
            Lists vCenter Sessions.

        .DESCRIPTION
            Lists all connected vCenter Sessions.

        .EXAMPLE
            PS C:\> Get-VISession

        .EXAMPLE
            PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 5 }
    #>
    $SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
    $AllSessions = @()
    $SessionMgr.SessionList | Foreach {   
        $Session = New-Object -TypeName PSObject -Property @{
            Key = $_.Key
            UserName = $_.UserName
            FullName = $_.FullName
            LoginTime = ($_.LoginTime).ToLocalTime()
            LastActiveTime = ($_.LastActiveTime).ToLocalTime()
           
        }
            If ($_.Key -eq $SessionMgr.CurrentSession.Key) {
                $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Current Session"
            } Else {
                $Session | Add-Member -MemberType NoteProperty -Name Status -Value "Idle"
            }
            $Session | Add-Member -MemberType NoteProperty -Name IdleMinutes -Value ([Math]::Round(((Get-Date) – ($_.LastActiveTime).ToLocalTime()).TotalMinutes))
    $AllSessions += $Session
    }
    $AllSessions
}

