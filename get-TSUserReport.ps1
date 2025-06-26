## TO DO
# 1. Make timing queries correct (without hard-coding the +6)

param
(
    [parameter(Mandatory=$true)]
    [DateTime]
    # Specifies date of information to be returned
    $QueryDate,

    [parameter(Mandatory=$true)]
    [String]
    # Specifies user to run report on
    $User,

    [String]
    # Specify server to query (default: TSSRV)
    $Server="m4uktsgw.intranet.macro4.com",

    [Switch]
    # Automatically view graph upon completion of command
    $ShowGraph
)

function constructQuery
{
    param
    (
        [DateTime]
        $date = $QueryDate,

        [string]
        $username = $User,

        [Parameter(Mandatory=$false)]
        [string]
        $TargetLogonId,

        [Parameter(Mandatory=$false)]
        [ValidatePattern("[0-3]")]
        [int]
        $queryType, # 0 = EventID4647, 1 = EventID4634, 2 = EventID4779, 3 = EventID4778

        [Parameter(Mandatory=$false)]
        [alias("LastEvent")]
        [int]
        $_lastEvent
    )

    [string]$ReturnQuery = "" #initialize blank query

    [string]$DateFormatString = "{0:yyyy'-'MM'-'dd'T'HH':'mm':'sss'Z'}"
    [string]$StartDateTimeString = $DateFormatString -f $date.AddHours(6) # add 6 stupid hours for timezone...
    [string]$EndDateTimeString = $DateFormatString -f ($date.AddDays(1)).AddHours(6) # add 6 stupid hours for timezone...

    [string]$TimeQueryString = "TimeCreated[@SystemTime&gt;='$StartDateTimeString' and @SystemTime&lt;'$EndDateTimeString']]] and "

    [string]$TargetLogonString = "*[EventData[Data[@Name=`'TargetLogonId`']=`'$TargetLogonId`']]"
    [string]$LogonIDString = "*[EventData[Data[@Name=`'LogonID`']=`'$TargetLogonId`']]"

    [string]$QueryHeader = "<QueryList><Query Id=`"0`" Path=`"Security`">"
    [string]$QueryFooter = "</Query></QueryList>"

    $ReturnQuery += $QueryHeader

    if(!$TargetLogonId) # Query for Logons
    {
        $ReturnQuery += "<Select Path=`"Security`">" + `
                            "*[System[(EventID=4624) and " + `
                            $TimeQueryString + `
                            "*[EventData[Data[@Name=`'LogonType`']=10]] and " + `
                            "*[EventData[Data[@Name=`'TargetUserName`']=`'$username`']]" + `
                        "</Select>" + `
                        "<Suppress Path=`"Security`">" + `
                            "*[EventData[Data[@Name=`'LogonGuid`']=`'{00000000-0000-0000-0000-000000000000}`']]" + `
                        "</Suppress>"
    }
    else
    {
        [string]$tempString = "<Select Path=`"Security`">" + `
                              "*[System[(EventID={0}) and " + `
                              $TimeQueryString

        switch ($queryType)
        {
            {$_ -eq 0 -or $_ -eq 1} { $tempString += $TargetLogonString }
            {$_ -eq 2 -or $_ -eq 3} { $tempString += $LogonIDString }
            default {Write-Host ERROR; exit}
        }

        $tempString += "{1}" + `
                      "</Select>"

        switch($queryType)
        {
            0 { $ReturnQuery += $tempString -f "4647", "" }
            1 { $ReturnQuery += $tempString -f "4634", "and *[EventData[Data[@Name=`'LogonType`']=10]]" }
            2 { $ReturnQuery += $tempString -f "4779", "and *[System[(EventRecordID&gt;$_lastEvent)]]" }
            3 { $ReturnQuery += $tempString -f "4778", "and *[System[(EventRecordID&gt;$_lastEvent)]]" }
            default {Write-Host ERROR; exit}
        }
    }

    $ReturnQuery += $QueryFooter    
    $ReturnQuery
}

function search
{
    param
    (
        [string]
        $_User = $User,

        [Parameter(Mandatory=$false)]
        [string]
        $_TargetLogonId,

        [ref]
        $_lastEvent,

        [ref]
        $_currentEvent,

        [int]
        $_queryType, # Logoff = 1, Disconnect = 2, Reconnect = 3

        [int]
        $_eventIDNumber
    )

    try
    {
        [string]$query = constructQuery -Date $QueryDate -username $User -TargetLogonId $_TargetLogonId -queryType $_queryType -LastEvent $_eventIDNumber
        $query | Out-File -Append c:\TEMP\queries.txt # DEBUG
        $_lastEvent.Value = $_currentEvent.Value # DEBUG
        $_currentEvent.Value = Get-WinEvent -ComputerName $Server -FilterXML $query -Oldest -ErrorAction Stop # DEBUG
        #"SUCCESS" | Out-File -Append c:\TEMP\queries.txt # DEBUG
        $true
    }
    catch
    {
        $false
    }
}

function eventURLBuilder
{
    param
    (
        [System.Diagnostics.Eventing.Reader.EventLogRecord]
        $_currentEvent,

        [System.Diagnostics.Eventing.Reader.EventLogRecord]
        $_lastEvent,

        [alias("Disconnected")]
        [switch]
        $_disconnected
    )

    $lastEventDT = Get-Date $_lastEvent.TimeCreated
    $dTimeStart = [decimal]$lastEventDT.ToString("HH") + [decimal]($lastEventDT.ToString("%m")/60)
    if($_disconnected) { $baseString = "B,$disconnectedColor,0," + ("{0:N2}" -f $dTimeStart) + ":" }
    else { $baseString = "B,$activeColor,0," + ("{0:N2}" -f $dTimeStart) + ":" }
    $currentEventDT = Get-Date $_currentEvent.TimeCreated
    $dTimeFinish = [decimal]$currentEventDT.ToString("HH") + [decimal]($currentEventDT.ToString("%m")/60)

    $baseString + ("{0:N2}" -f $dTimeFinish) + ",0|" # return string
}

## Public Variables ##
[int]$state = 0 # 0=Logged off, 1=Logged on, 2=Disconnected, 3=Reconnected 
[string]$eventsURL = "" # snippet of URL that will hold the data being charted
$totalDisconnectedTime = New-TimeSpan # will contain total disconnected time
$totalLogonTime = New-TimeSpan # will contain total logged on (not disconnected) time
[string]$activeColor = "4D7CFF" #76A4FB
[string]$disconnectedColor = "E86868" #990000
[int]$lastEventProcessed = 0
######################

try
{
    $LogonsQuery = constructQuery
    $LogonEvents = Get-WinEvent -ComputerName $Server -FilterXML $LogonsQuery -Oldest -ErrorAction Stop
}
catch
{
    Write-Host "No activity." -ForegroundColor Red
    exit
}

foreach ($LogonEvent in $LogonEvents)
{
    if($LogonEvent.RecordId -lt $lastEventProcessed)
    {
        continue
    }

    #Extract 'TargetLogonId' from $LogonEvent XML to match related session events
    [xml]$xmlEvent = $LogonEvent.ToXml()
    $xmlns = New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList $xmlEvent.NameTable
    $xmlns.AddNamespace("el", "http://schemas.microsoft.com/win/2004/08/events/event")
    [string]$TargetLogonId = $xmlEvent.SelectSingleNode("el:Event/el:EventData/el:Data[@Name = 'TargetLogonId']/text()", $xmlns).Value
    [int]$lastEventProcessed = $LogonEvent.RecordId

    $lastEvent = $LogonEvent    
    $currentEvent = $LogonEvent # initialize (value meaningless at this point)

    $state = 1 # Mark as "logged on"
    while ($state -ne 0)
    {
        if ($state -eq 1) #LOGGED ON
        {
            try
            {
                $hasEvent = search $User $TargetLogonId ([ref]$lastEvent) ([ref]$currentEvent) 2 $lastEventProcessed # 2 = disconnect
            }
            catch
            {
                Write-Host ERROR -ForegroundColor Red
                $_
                exit
            }
            if ($hasEvent)
            {
                try
                {
                    $totalLogonTime += (Get-Date $currentEvent.TimeCreated) - (Get-Date $lastEvent.TimeCreated)
                    $eventsURL += eventURLBuilder $currentEvent $lastEvent
                    $state = 2
                    $lastEventProcessed = $currentEvent.RecordId
                }
                catch
                {
                    Write-Host "ERROR" -ForegroundColor Red
                    $_
                    exit
                }
            }
            if ($state -ne 0 -and $state -ne 2)
            {
                try
                {
                    $hasEvent = search $User $TargetLogonId ([ref]$lastEvent) ([ref]$currentEvent) 1 $lastEventProcessed
                }
                catch
                {
                    Write-Host ERROR -ForegroundColor Red
                    $_
                    exit
                }
                if ($hasEvent)
                {
                    try
                    {
                        $totalLogonTime += (Get-Date $currentEvent.TimeCreated) - (Get-Date $lastEvent.TimeCreated)
                        $eventsURL += eventURLBuilder $currentEvent $lastEvent
                        $state = 0
                    }
                    catch
                    {
                        Write-Host "ERROR" -ForegroundColor Red
                        $_
                        exit
                    }
                }
            }
        }
        elseif ($state -eq 2) #DISCONNECTED
        {
            try
            {
                $hasEvent = search $User $TargetLogonId ([ref]$lastEvent) ([ref]$currentEvent) 3 $lastEventProcessed # 3 = reconnect
            }
            catch
            {
                Write-Host "ERROR" -ForegroundColor Red
                $_
                exit
            }
            if ($hasEvent)
            {
                try
                {
                    $totalDisconnectedTime += (Get-Date $currentEvent.TimeCreated) - (Get-Date $lastEvent.TimeCreated)
                    $eventsURL += eventURLBuilder $currentEvent $lastEvent -Disconnected
                    $state = 3
                    $lastEventProcessed = $currentEvent.RecordId
                }
                catch
                {
                    Write-Host "ERROR" -ForegroundColor Red
                    $_
                    exit
                }
            }
            if ($state -ne 0 -and $state -ne 3)
            {
                try
                {
                    $hasEvent = search $User $TargetLogonId ([ref]$lastEvent) ([ref]$currentEvent) 1 $lastEventProcessed
                }
                catch
                {
                    Write-Host "ERROR" -ForegroundColor Red
                    $_
                    exit
                }
                if ($hasEvent)
                {
                    try
                    {
                        $totalDisconnectedTime += (Get-Date $currentEvent.TimeCreated) - (Get-Date $lastEvent.TimeCreated)
                        $eventsURL += eventURLBuilder $currentEvent $lastEvent -Disconnected
                        $state = 0
                    }
                    catch
                    {
                        Write-Host "ERROR" -ForegroundColor Red
                        $_
                        exit
                    }
                }
            }
        }
        elseif ($state -eq 3) #RECONNECTED
        {
            try
            {
                $hasEvent = search $User $TargetLogonId ([ref]$lastEvent) ([ref]$currentEvent) 2 $lastEventProcessed # 2 = disconnect
            }
            catch
            {
                Write-Host ERROR -ForegroundColor Red
                $_
                exit
            }
            if ($hasEvent)
            {
                try
                {
                    $totalLogonTime += (Get-Date $currentEvent.TimeCreated) - (Get-Date $lastEvent.TimeCreated)
                    $eventsURL += eventURLBuilder $currentEvent $lastEvent
                    $state = 2
                    $lastEventProcessed = $currentEvent.RecordId
                }
                catch
                {
                    Write-Host "ERROR" -ForegroundColor Red
                    $_
                    exit
                }
            }
            if ($state -ne 0 -and $state -ne 2)
            {
                try
                {
                    $hasEvent = search $User $TargetLogonId ([ref]$lastEvent) ([ref]$currentEvent) 1 $lastEventProcessed
                }
                catch
                {
                    Write-Host "ERROR" -ForegroundColor Red
                    $_
                    exit
                }
                if ($hasEvent)
                {
                    try
                    {
                        $totalLogonTime += (Get-Date $currentEvent.TimeCreated) - (Get-Date $lastEvent.TimeCreated)
                        $eventsURL += eventURLBuilder $currentEvent $lastEvent
                        $state = 0
                    }
                    catch
                    {
                        Write-Host "ERROR" -ForegroundColor Red
                        $_
                        exit
                    }
                }
            }
        }
    }
}

$chartURL = "http://chart.googleapis.com/chart?cht=lc&chtt=" + `
            $User + `
            "+Remote+Access+for+" + `
            $QueryDate.ToShortDateString() + `
            "|Total%3A+" + ($totalDisconnectedTime + $totalLogonTime).Hours + "+hours+and+" + ($totalDisconnectedTime + $totalLogonTime).Minutes + "+minutes" + `
            "-- Active%3A+" + $totalLogonTime.Hours + "+hours+and+" + $totalLogonTime.Minutes + "+minutes" + `
            "&chm="
$chartURL += $eventsURL
$chartURL = $chartURL.Remove($chartURL.Length - 1) # remove the extraneous '|' character
$chartURL += "&chxl=0:|12%3A00|3%3A00|6%3A00|9%3A00|12%3A00|3%3A00|6%3A00|9%3A00|12%3A00|1:||AM|PM||2:|&chxtc=0,5&chdl=|Logged+On|Disconnected&chco=FFFFFF|" + `
             $activeColor + `
             "|" + `
             $disconnectedColor + `
             "&chs=800x240&chxt=x,x,y&chd=t:100&chls=FFFFFF&chfd=0,x,0,24,1,100"
$saveFolder = "c:\TEMP\chart.png"
$clnt = new-object System.Net.WebClient
$clnt.DownloadFile($chartUrl,$saveFolder)
if($ShowGraph)
{
    &"$saveFolder"
}
$chartURL | Out-File c:\TEMP\chartURL.txt # DEBUG
Write-Host Chart Generated at $saveFolder -ForegroundColor Green