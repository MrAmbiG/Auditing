<#
.SYNOPSIS
    Audit report for cisco switches
.DESCRIPTION
    This will generate an audit report for N359K,n5k,n9k,avamar Switches
.NOTES
    File Name      : N359kAudit.ps1
    Author         : gajendra d ambi
    Date           : July 2016
    Prerequisite   : PowerShell v4+, Plink.exe over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: 
#>

#Start of the Report script
$filename  = "N359Kinfo.txt"
$N359Kinfo   = "$PSScriptRoot\$filename" #create text file

function N359ktext
{
#Get Plink
$PlinkLocation = $PSScriptRoot + "\Plink.exe" #http://www.virtu-al.net/2013/01/07/ssh-powershell-tricks-with-plink-exe/
If (-not (Test-Path $PlinkLocation)){
   Write-Host "Plink.exe not found, trying to download..."
   $WC = new-object net.webclient
   $WC.DownloadFile("http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe",$PlinkLocation)
   If (-not (Test-Path $PlinkLocation)){
      Write-Host "Unable to download plink.exe, please download and add it to the same folder as this script"
      Exit
   } Else {
      $PlinkEXE = Get-ChildItem $PlinkLocation
      If ($PlinkEXE.Length -gt 0) {
         Write-Host "Plink.exe downloaded, continuing script"
      } Else {
      Write-Host "Unable to download plink.exe, please download and add it to the same folder as this script"
         Exit
      }
   }  
}

if ((Test-Path $PlinkLocation) -ne "True") {
do {
Write-Host "Plink should be present in the same folder as this script" -BackgroundColor Red -ForegroundColor White
Read-Host "!"
} while ((Test-Path $PlinkLocation) -ne "True") }

#X server's credentials
Write-Host N359K Address?  -ForegroundColor Black -BackgroundColor White
$N359K  = Read-Host " "
Write-Host N359K Username? -ForegroundColor Black -BackgroundColor White
$user = Read-Host " "
Write-Host N359K password? -ForegroundColor Black -BackgroundColor White
$pass = Read-Host " "

#start timer
$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

if ((Test-Path $N359Kinfo) -eq "True") {ri $N359Kinfo -Force -Confirm:$false } #remove old text report file
ni -ItemType file $N359Kinfo -Force
 
#copy plink to c:\ for now
Copy-Item $PSScriptRoot\plink.exe C:\

    $commands = @(
"show feature                      "
"show banner motd                  "
"sh run | inc route                "
"sh int desc                       "
"show license usage                "
"show version                      "
"show inventory                    "
"show vpc brief                    "
"sh hsrp brief                     "
"show environment                  "
"show port-channel summary         "
"show vlan                         "
"show module                       "
"show redundancy status            "
"show int counters errors          "
"show int brief                    "
"show ip interface vrf management  "
"show int transceiverrs errors     "
"show ip arp                       "
"show mac address-table            "
"show log last 10                  "
"show run                          "
"show license host-id              "
"show vrf                          "
"show ip int brief vrf all         "
"sh run vpc                        "
    )


    [int]$n="0"
    foreach ($command in $commands)
    {
    echo y | C:\plink.exe -ssh $user@$N359K -pw $pass "exit"
    "Section$n"                                                      >> $N359Kinfo
    $n++
    "start "+$command                                                >> $N359Kinfo
    "============================"                                   >> $N359Kinfo
    C:\plink.exe -ssh -v -noagent $N359K -l $user -pw $pass $command >> $N359Kinfo
    ""                                                               >> $N359Kinfo
    ""                                                             >> $N359Kinfo
    "end "+$command                                                  >> $N359Kinfo
    $n++
    }
    
ac $N359Kinfo "end of text report"
}

function N359kreport {
$N359Kinfo = gc $N359Kinfo
#Start of the Report script
$report    = "N359Kaudit"
$N359Kaudit  = "$PSScriptRoot\$report.txt" #create text file
$html      = "$PSScriptRoot\$report.html" #html file
if ((Test-Path $html) -eq "True") {ri $html -Force -Confirm:$false } #remove old html report file
ni -ItemType file $N359Kaudit -Force

#title
ac $N359Kaudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#005a9c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>Cisco N359K Audit</b></left></td></tr></table><br><br>"
ac $N359Kaudit '<!DOCTYPE html>'
ac $N359Kaudit '<html>'
ac $N359Kaudit '<head>'
ac $N359Kaudit '<title>N359KAudit</title>'
ac $N359Kaudit '</head>'
ac $N359Kaudit '<body bgcolor="white">'
ac $N359Kaudit '<table border=1px width="100%" cellspacing="0">'

#Section: show banner motd
Write-Host "Section : Banner"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Banner</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers

###Section: show banner motd###
$from =  ($N359Kinfo | Select-String -pattern "start show banner motd" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show banner motd" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$banner = $a | Where-Object { ($_.length -gt 0) -and ( $_ -notmatch "=====" ) }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$banner</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show version
Write-Host "Section : version"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : version</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">BIOS</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">kickstart</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">system</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Hardware</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Processor Board ID Date</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Device name</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">PSU Redundancy</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Default Route</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">DNS</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Domain</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">NTP Distribute</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">NTP Commit</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">NTP Master</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">NTP Hosts</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">HostID</font></th>'

###Section: show version ###
$from =  ($N359Kinfo | Select-String -pattern "start show version" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo  | Select-String -pattern "end show version" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

#bios
$b = $a | Where-Object { $_ -match 'BIOS:' }
$b = $b.split(":")[-1] -replace "version"
$bios = $b.trim()

#kickstart
$b = $a | Where-Object { $_ -match 'kickstart:' }
$b = $b.split(":")[-1] -replace "version"
$ks = $b.trim()

#system
$b = $a | Where-Object { $_ -match 'system:' }
$b = $b.split(":")[-1] -replace "version"
$sys = $b.trim()

#Hardware
$b = $a | Where-Object { $_ -match 'Chassis' }
$b = $b.split(' ') | Where-Object { $_.length -gt 0 }
$model = $b[2]

#Processor Board ID
$b = $a | Where-Object { $_ -match 'Processor Board ID' }
$b = $b -replace "Processor Board ID"
$pbid = $b.trim()

#Device name
$b = $a | Where-Object { $_ -match 'Device name' }
$b = $b -replace "Device name:"
$device = $b.trim()

#Power Supply redundancy mode
if (($N359Kinfo | Where-Object {$_ -match "Power Supply redundancy mode:"}) -ne $null) 
{
$b = $N359Kinfo | Where-Object {$_ -match "Power Supply redundancy mode:"}
$b = $b -replace "Power Supply redundancy mode:"
$redundancy = $b.trim()
} else
{
$b = $N359Kinfo | Where-Object {$_ -match "Power Supply redundancy mode"}
$b = $b -replace "Power Supply redundancy mode"
if ($b -match "PS-Redundant") { $redundancy = "PS-Redundant" }
}

#domain
$a = $N359Kinfo | Where-Object { $_ -match 'ip domain-name' }
$a = $a -replace 'ip domain-name'
$domain = $a.trim()

#dns
$a = $N359Kinfo | Where-Object { $_ -match 'ip name-server' }
$a = $a -replace 'ip name-server'
$a = $a.trim()
$dns = $a -replace " ",", "

#ntp distribute
if ($N359Kinfo -match "ntp distribute") { $NtpDistr = "true" }

#ntp commit
if ($N359Kinfo -match "ntp commit") { $NtpCom = "true" }

#ntp master
$a = $N359Kinfo | Where-Object { $_ -match "ntp master" }
$a = $a -replace 'ntp master '
$NtpMaster = $a

#ntp servers
$a = $N359Kinfo | Where-Object { ($_ -match "ntp server ") }
$a = $a -replace 'ntp server' -replace 'use-vrf default'
$Ntps = $a.trim()

#host id
$a = $N359Kinfo | Select-String "License hostid:" | Where-Object { $_.length -gt 0 }
$a = $a -replace "License hostid:"
$HostID = $a.trim()

###Section: sh run | inc route###
$from =  ($N359Kinfo | Select-String -pattern "start sh run \| inc route" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end sh run \| inc route" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$c = $array
$c = $c | Where-Object { ($_ -notmatch "====") -and ($_ -notmatch "source-route" ) }
$DRoute = $c -replace "ip route" | Where-Object { ($_.length -gt 0) }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$bios</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$ks</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$sys</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$model</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$pbid</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$device</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$redundancy</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$DRoute</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$dns</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$domain</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$NtpDistr</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$NtpCom</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$NtpMaster</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Ntps</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$HostID</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh feature
Write-Host "Section : Enabled Features"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Enabled Features</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Feature Name</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Instance</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">State</font></th>'

###Section: sh feature ###
$from =  ($N359Kinfo | Select-String -pattern "start show feature" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo  | Select-String -pattern "end show feature" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "Feature Name") -and ($_ -notmatch "====") -and ($_ -notmatch "---") -and ($_ -match "enabled" ) -and ($_.length -gt 0)}

foreach ($line in $a)
{
$b = $line.split(" ")
$b = $b | Where-Object { $_.length -gt 0 }
$feature = $b[0] #feature name
$inst    = $b[1] #instance
$state   = $b[2] #state

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$feature</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$inst</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$state</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh license
Write-Host "Section : license usage"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : license usage</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Feature</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Instance</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">License Count</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Expiray Date</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Comments</font></th>'

###Section: show license usage ###
$from =  ($N359Kinfo | Select-String -pattern "start show license usage" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo  | Select-String -pattern "end show license usage" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "Feature") -and ($_ -notmatch "====") -and ($_ -notmatch "---") -and ($_ -notmatch "count") -and ($_.length -gt 0)}

foreach ($line in $a)
{
$b = $line.split(" ")
$b = $b | Where-Object { $_.length -gt 0 }

$feature = $b[0] #feature

$b    = $b -replace "$feature" | Where-Object { $_.length -gt 0 }
$inst = $b[0] #instance

$b      = $b -replace "$inst" | Where-Object { $_.length -gt 0 }
$LCount = $b[0] #License Count

$comments = $b[-1] #comments
$b      = $b -replace "$comments" | Where-Object { $_.length -gt 0 }

    if ($b.count -eq 1) {
    $status = $b #status
    $expiry = "" #expiration
    }
    
    if ($b.count -eq 2) {
    $status = $b[0] #status
    $expiry = $b[-1] #expiration
    }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$feature</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$inst</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$LCount</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$expiry</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$comments</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh license
Write-Host "Section : Inventory"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Inventory</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">PID</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VID</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SN</font></th>'

###Section: show inventory ###
$from =  ($N359Kinfo | Select-String -pattern "start show inventory" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo  | Select-String -pattern "end show inventory" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$line1s = $a | Where-Object { ($_ -match "NAME:") -and ($_.length -gt 0) }
$line2s = $a | Where-Object { ($_ -match "PID:") -and ($_.length -gt 0) }
$count = $line1s.count

[int]$n=0
do
{
$b = $line1s[$n]
$b    = $b.split(",")

$c    = $b[0] -replace "NAME:" -replace '"'
$name = $c.trim() #name

$c    = $b[-1] -replace "DESCR:" -replace '"'
$desc = $c.trim() #description

$b = $line2s[$n]
$b = $b.split(",")

$c    = $b[0] -replace "PID:" -replace '"'
$ppid = $c.trim()

$c   = $b[1] -replace "VID:" -replace '"'
$vid = $c.trim()

$c  = $b[2] -replace "SN:" -replace '"'
$sn = $c.trim()

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$name</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$desc</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$ppid</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vid</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$sn</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

$n++
} while ($count -gt $n)

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: Fans
Write-Host "Section : Fans"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Fans</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">fan</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">model</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">hardware</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">status</font></th>'

###Section: show environment ###
#fans
$from =  ($N359Kinfo | Select-String -pattern "Fan:" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "Temperature" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$b = $a | where-object {($_ -notmatch "Fan Zone Speed") -and ($_ -notmatch "Fan Air Filter") -and ($_ -notmatch "---") -and ($_ -notmatch "Status" ) -and ($_.length -gt 0 ) }

foreach ($line in $b)
{
$c = $line.split(" ") | Where-Object { $_.length -gt 0 }
$fan    = $c[0]
$model  = $c[1]
$hw     = $c[2]
$status = $c[3]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$fan</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$model</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$hw</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: Temperature
Write-Host "Section : Temperature"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Temperature</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Sensor</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

###Section: show environment ###
#Temperature
$from =  ($N359Kinfo | Select-String -pattern "start show environment" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show environment" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -cmatch "ASIC") -or ($_ -cmatch "Back    ") -or($_ -cmatch "Front-Left") -or($_ -cmatch "Front-Right") -or ($_ -cmatch "FRONT") -or ($_ -cmatch "BACK") -or ($_ -cmatch "CPU") -or ($_ -cmatch "TD2-1") -or ($_ -cmatch "NS-1") }

foreach ($line in $a)
{
$c = $line.split(" ") | Where-Object { $_.length -gt 0 }

$module = $c[0]
$sensor = $c[1]
$status = $c[-1]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$module</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$sensor</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: Power Supply
Write-Host "Section : Power Supply"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Power Supply</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Power Supply</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

###Section: show environment ###
#Power Supply
$from =  ($N359Kinfo | Select-String -pattern "start show environment " | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show environment " | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -cmatch " W  ") -or ( $_ -cmatch "    AC    " ) -or ( $_ -match '    powered-up' )}

foreach ($line in $a)
{
$c = $line.split(" ") | Where-Object { $_.length -gt 0 }

$ps = $c[0] #power supply
$c = $c -replace "$ps"

$model = $c[1] #psu model
$c = $c -replace "$model"

$status = $c[-1] #psu model

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$ps</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$model</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: start show vpc brief 1
Write-Host "Section : VPC"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : VPC Information</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Value</font></th>'

###Section: show vpc brief ###
$from =  ($N359Kinfo | Select-String -pattern "start show vpc brief" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show vpc brief" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$b = $a | Where-Object { ($_ -match ":") -and ($_ -notmatch "Legend") }

foreach ($line in $b)
{
$c = $line.split(":")
$desc  = $c[0] #description
$value = $c[1] #value

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$desc</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

###Section: show run vpc###
$from =  ($N359Kinfo | Select-String -pattern "start sh run vpc" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end sh run vpc" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array | Where-Object { ($_.length -gt 0 ) }

#vpc switch
$b = $a | Where-Object { $_ -match "switch" }
$VSwitch = $b.trim()

#role priority
$b = $a | Where-Object { $_ -match "role" }
$b = $b -replace "role priority"
$b = $b.trim()
$RPriority = $b

#system priority
$b = $a | Where-Object { $_ -match "system" }
$b = $b -replace "system-priority"
$SPriority = $b.trim()

$b = $a | Where-Object { $_ -match "destination" }
$b = $b -replace "peer-keepalive" -replace "destination" -replace "source"
$b = $b.trim()
$b = $b.split(" ")

#vpc destination
$VDest   = $b[0]
$VSource = $b[-1]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>switch</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$VSwitch</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>Role Priority</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$RPriority</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>system-priority</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$SPriority</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>Destination IP</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$VDest</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>Source IP</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$VSource</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

###Section: show vpc brief ###
$from =  ($N359Kinfo | Select-String -pattern "vPC Peer-link status" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "vPC status" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$b = $a | where-object {($_ -match 'Po') -and ( $_ -notmatch 'id' ) }

foreach ($line in $b)
{
$c = $line.split(" ") | Where-Object { $_.length -gt 0 }
$id      = $c[0]
$port    = $c[1]
$status  = $c[2]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$id</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$port</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Consistency</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Reason</font></th>'

###Section: show vpc brief ###
$from =  ($N359Kinfo | Select-String -pattern "vPC status" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show vpc brief" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$b = $a | where-object {($_ -match 'Po') -and ( $_ -notmatch 'id' ) }

foreach ($line in $b)
{
$c = $line.split(" ") | Where-Object { $_.length -gt 0 }
$id      = $c[0]
$port    = $c[1]
$status  = $c[2]
$cons    = $c[3]
$reason  = $c[4]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$id</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$port</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$cons</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$reason</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show port-channel summary
Write-Host "Section : port-channel summary"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : port-channel summary</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Group</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port-Channel</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Protocol</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Member Ports</font></th>'

###Section: show port-channel summary###
$from =  ($N359Kinfo | Select-String -pattern "Group Port-" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show port-channel summary" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$b = $a | Where-Object { ($_ -notmatch "Group Port-") -and ($_ -notmatch "--") -and ($_ -notmatch "Channel") -and ($_.Length -gt 0)}

foreach ($line in $b)
{
$c = $line.split(" ") | Where-Object { $_.Length -gt 0 }

$group     = $c[0] #groups
$pc        = $c[1] #port-channel
$type      = $c[2] #type
$protocol  = $c[3] #protocol
$Ports     = $c | Where-Object { $_ -match "/" } #Member Ports
if ($Ports.count -gt 1) { $Ports = $Ports -join ", " }

if ($c.count -lt 3)
{
$group     = $null
$pc        = $null
$type      = $null
$protocol  = $null
$Ports     = $line
}

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$group</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$pc</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$type</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$protocol</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Ports</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show vlan
Write-Host "Section : Vlans"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Vlans</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">vlan</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">name</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ports</font></th>'

###Section: show vlan###
$from =  ($N359Kinfo | Select-String -pattern "VLAN Name" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "VLAN Type" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "---") -and ($_.Length -gt 0) }
$a = $a.trim()

foreach ($line in $a)
{
if (($line.StartsWith("Eth")) -or $line.StartsWith("Po")){
    $b = $line.split(" ") | Where-Object { $_.Length -gt 0 }
    $vlan   = $null
    $name   = $null
    $status = $null
    $ports  = $b[0..9]
} else {
$b = $line.split(" ") | Where-Object { $_.Length -gt 0 }
    $vlan   = $b[0]
    $name   = $b[1]
    $status = $b[2]
    $ports  = $b[3..9]
} 

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vlan</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$name</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$ports</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VLAN</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Vlan-mode</font></th>'

###Section: show portchannel summary###
$from =  ($N359Kinfo | Select-String -pattern "Vlan-mode" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "Primary  Secondary" | Select-Object LineNumber).LineNumber
if ($N359Kinfo -cmatch "Remote SPAN VLANs") { 
$to   =  ($N359Kinfo | Select-String -pattern "Remote SPAN VLANs" | Select-Object LineNumber).LineNumber
}

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ($_ -notmatch "---") -and ($_.length -gt 0) }

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0) }

$vlan  = $b[0]
$type  = $b[1]
$vmode = $b[2]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vlan</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$type</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vmode</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show module
Write-Host "Section : module"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Module</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module Type</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

###Section: show module###
$from =  ($N359Kinfo | Select-String -pattern "start show module" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "Mod  Sw" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ($_ -notmatch "---") -and ($_ -notmatch "====" ) -and ($_ -notmatch "Mod Ports" ) -and ($_.length -gt 0) }

foreach ($line in $a)
{
$b   = $line.split(" ") | Where-Object { ($_.length -gt 0) }

$mod = $b[0] #mod
$b   = $b -replace "$mod" | Where-Object { ($_.length -gt 1) }

$ports = $b[0] #module type
$b     = $b -replace "$ports" | Where-Object { ($_.length -gt 1) }

$status = $b[-1] #status
$b      = $b -replace $status | Where-Object { ($_.length -gt 1) }

$model = $b[-1] #model
$b     = $b -replace $model | Where-Object { ($_.length -gt 1) }

$MType = $b -join " " #module type

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mod</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$ports</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$MType</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Model</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Software</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Hardware Type</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">WWN</font></th>'

###Section: show module###
$from =  ($N359Kinfo | Select-String -pattern "Mod  Sw" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "Mod  MAC-Address" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ($_ -notmatch "---") -and ($_ -notmatch "====" ) -and ($_ -notmatch "Mod Ports" ) -and ($_.length -gt 0) }

foreach ($line in $a)
{
$b   = $line.split(" ") | Where-Object { ($_.length -gt 0) }

$mod = $b[0]
$sw  = $b[1]
$hw  = $b[2]
$wwn = $b[3]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mod</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$sw</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$hw</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$wwn</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">MAC-Address(es)</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Serial-Num</font></th>'

###Section: show module###
$from =  ($N359Kinfo | Select-String -pattern "Mod  MAC-Address" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show module" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ($_ -notmatch 'Mod  Online' ) -and  ($_ -notmatch "Pass") -and  ($_ -notmatch "---") -and  ($_ -notmatch "this terminal session") -and ($_ -notmatch "====" ) -and ($_ -notmatch "Mod Ports" ) -and ($_.length -gt 0) }

foreach ($line in $a)
{
$b   = $line.split(" ") | Where-Object { ($_.length -gt 0) -and ($_ -notmatch "---" )}
$mod = $b[0]
$sn  = $b[-1]
$mac = $b[1,2,3] -join " "

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mod</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mac</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$sn</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

if (($N359Kinfo | Where-Object {$_ -match "PID: N9k"}) -eq $null) {
#Section: sh hsrp brief
Write-Host "Section : HSRP"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : HSRP</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="60%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Group</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Priority</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">preempt</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">state</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Active addr</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Standby addr</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Group addr</font></th>'

###Section: sh hsrp brief###
$from =  ($N359Kinfo | Select-String -pattern "start sh hsrp brief" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end sh hsrp brief" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ($_ -notmatch "---") -and ($_ -notmatch "====" ) -and ($_ -notmatch "indicates configured to preempt" ) -and ($_ -notmatch "Mod Ports" ) -and ($_.length -gt 0) }
$a = $a -replace $a[0] | Where-Object { ($_.length -gt 1) -and ($_ -notmatch "Interface" )  -and ($_ -notmatch "conf" )}

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0) -and ($_ -notmatch "---" )}
$interace = $b[0]
$grp      = $b[1]
$prio     = $b[2]
$preempt  = $b[3]
$state    = $b[4]
$AAddress = $b[5]
$SAddress = $b[6]
$GAddress = $b[7]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$interace</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$grp</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$prio</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$preempt</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$state</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$AAddress</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$SAddress</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$GAddress</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"
} else

{
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : No HSRP</b></p></font></td></tr></table>'
ac $N359Kaudit "<br>"
}

#Section: show int counters errors
Write-Host "Section : counters errors"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : counters errors [Align-Err, FCS-Err, Xmit-Err, Rcv-Err, UnderSize, OutDiscards]</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Healthy Ports</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports with errors</font></th>'

###Section: show int counters errors###
$from =  ($N359Kinfo | Select-String -pattern "Align-Err" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "Single-Col" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "---" ) -and ($_.length -gt 0 ) }

foreach ($line in $a)
{
$b    = $line.split(" ") | where-object { ($_.length -gt 0 ) -and ($_ -notmatch "--" ) }
$port = $b[0] #port
$b    = $b[1..9]
$b    = $b | Get-Unique
        if ($b.count -eq 1) {
    $GPort = $port
    $BPort = $null } else { 
    $GPort = $null
    $BPort = $port }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$GPort</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$BPort</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show int counters errors
Write-Host "Section : counters errors"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : counters errors [Single-Col, Multi-Col, Late-Col, Exces-Col, Carri-Sen, Runts]</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Healthy Ports</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports with errors</font></th>'

###Section: show int counters errors###
$from =  ($N359Kinfo | Select-String -pattern "Single-Col" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "SQETest-Err" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "---" ) -and ($_.length -gt 0 ) }

foreach ($line in $a)
{
$b    = $line.split(" ") | where-object { ($_.length -gt 0 ) -and ($_ -notmatch "--" ) }
$port = $b[0] #port
$b    = $b[1..9]
$b    = $b | Get-Unique
        if ($b.count -eq 1) {
    $GPort = $port
    $BPort = $null } else { 
    $GPort = $null
    $BPort = $port }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$GPort</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$BPort</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show int counters errors
Write-Host "Section : counters errors"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : counters errors [Single-Col, Multi-Col, Late-Col, Exces-Col, Carri-Sen, Runts]</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Healthy Ports</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports with errors</font></th>'

###Section: show int counters errors###
$from =  ($N359Kinfo | Select-String -pattern "SQETest-Err" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show int counters errors" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "---" ) -and ($_.length -gt 0 ) }

foreach ($line in $a)
{
$b    = $line.split(" ") | where-object { ($_.length -gt 0 ) -and ($_ -notmatch "--" ) }
$port = $b[0] #port
$b    = $b[1..9]
$b    = $b | Get-Unique
        if ($b.count -eq 1) {
    $GPort = $port
    $BPort = $null } else { 
    $GPort = $null
    $BPort = $port }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$GPort</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$BPort</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show int brief
Write-Host "Section : Interface Brief"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Interface Brief</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VLAN</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Mode</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Reason</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Speed</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Channel</font></th>'


###Section: show int brief###
$from =  ($N359Kinfo | Select-String -pattern "start show int brief" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show int brief" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | where-object { ($_ -match "/" ) }

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 ) }

$int     = $b[0] #Ethernet Interface
$vlan    = $b[1] #VLAN
$type    = $b[2] #Type
$mode    = $b[3] #Mode
$status  = $b[4] #Status
$speed   = $b[-2] #speed
$pc      = $b[-1] #port channel

if ($line -match "none") { $reason = "none" }
if ($line -match "Administratively")  { $reason = "Administratively down" }
if ($line -match "SFP not inserted")  { $reason = "SFP not inserted" }
if ($line -match "XCVR not inserted") { $reason = "XCVR not inserted" }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$int</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vlan</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$type</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mode</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$reason</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$speed</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$pc</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VLAN</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Mode</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Reason</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Speed</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Channel</font></th>'

$a = $array
$a = $a | where-object { ($_ -match "Po" ) -and ($_ -notmatch "Port   VRF" ) -and ($_ -notmatch "Ethernet" ) -and ($_ -notmatch "Port-channel" ) -and ($_ -notmatch "/" ) -and ($_.length -gt 0 ) }

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 ) }

$int     = $b[0] #Ethernet Interface
$vlan    = $b[1] #VLAN
$type    = $b[2] #Type
$mode    = $b[3] #Mode
$status  = $b[4] #Status
$speed   = $b[-2] #speed
$pc      = $b[-1] #port channel

if ($line -match "none") { $reason = "none" }
if ($line -match "Administratively")  { $reason = "Administratively down" }
if ($line -match "SFP not inserted")  { $reason = "SFP not inserted" }
if ($line -match "XCVR not inserted") { $reason = "XCVR not inserted" }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$int</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vlan</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$type</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mode</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$reason</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$speed</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$pc</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VRF</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">IP Address</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Speed</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">MTU</font></th>'

$a = $array
$a = $a | Where-Object { ($_ -match "mgmt" ) -and ($_.length -gt 0 ) }

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 ) }

$int     = $b[0] #Ethernet Interface
$vrf     = $b[1] #VRF
$status  = $b[2] #Status
$IpAdds  = $b[3] #IP Address
$speed   = $b[4] #Speed
$mtu     = $b[5] #MTU

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$int</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vrf</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$IpAdds</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$speed</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$mtu</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Secondary VLAN(Type)</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Reason</font></th>'

$a = $array
$a = $a | Where-Object { ($_ -cmatch "Vlan" ) -and ($_.length -gt 0 ) }

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 ) }

$interface = $b[0] #Interface
$vlan      = $b[1] #Secondary VLAN(Type)
$status    = $b[2] #Status

if ($line -match "none") { $reason = "none" }
if ($line -match "Administratively") { $reason = "Administratively down" }
if ($line -match "SFP not inserted") { $reason = "SFP not inserted" }
if (($vlan -eq "--") -and ((($b -replace "--") | Where-Object {($_.length -gt 0 )}).count) -eq 2) { $reason = "--" }

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$interface</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vlan</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$status</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$reason</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#Section: show ip interface 
Write-Host "Section : Ip Interface "
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Ip Interface</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Vlans</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Configured IP, subnet</font></th>'

###Section: show ip interface###
$from =  ($N359Kinfo | Select-String -pattern "start show ip interface" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show ip interface" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line 
        }
}
$a = $array
$a = $a | Where-Object { ($_ -notmatch "----" ) -and ($_.length -gt 0 ) }

$b = $a | Where-Object { ($_ -match "Interface status:" ) }

#vlans
$vlans = @()
foreach ($line in $b) { 
$c = $line.split(",") 
$vlans  += $c[0] 
}

$vlans = $vlans -join "; "

#configured ip addresses
$b = $a | Where-Object { ($_ -match "IP address: " ) }
$b = $b -replace "IP address: " -replace "IP subnet: "
$ConIps = $b.split(",") #configured ip addresses
$ConIps = $ConIps -join "; "

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$vlans</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$ConIps</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh int desc 
Write-Host "Section : Interface Description"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Interface Description</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'

###Section: sh int desc ###
$from =  ($N359Kinfo | Select-String -pattern "Port          Type   Speed   Description" | Select-Object LineNumber).LineNumber
$tos  =  ($N359Kinfo | Select-String -pattern "Interface                Description" | Select-Object LineNumber).LineNumber
$to   = $tos[0]
if ($from -gt $to) { $to = $tos[1] }
if ($from -gt $to) { $to = $tos[2] }
if ($from -gt $to) { $to = $tos[3] }

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array | Where-Object { ($_ -notmatch "---------" ) -and ($_.length -gt 0 )  }

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 )  }
$port = $b[0]
$c = $b -replace $port -replace $b[1] -replace $b[2] -join " "
$description = $c.trim()


#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$port</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$description</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'

###Section: sh int desc ###
$from =  ($N359Kinfo | Select-String -pattern "start sh int desc" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end sh int desc" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt ($to+1)))
        {
        $array += $line      
        }
}

$from =  ($array | Select-String -pattern "Interface                Description" | Select-Object LineNumber).LineNumber
$to   =  ($array | Select-String -pattern "end sh int desc" | Select-Object LineNumber).LineNumber
$from = $from[-1]

$i = 0
$array1 = @()
foreach ($line in $array)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array1 += $line      
        }
}
$a = $array1
$a = $a | Where-Object { ($_.length -gt 0) -and ($_ -notmatch '---') }
 
foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 )  }

$port        = $b[0] #port
$b           = $b -replace $port -join " "
$description = $b.trim() #description


#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$port</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$description</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"

#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'

###Section: sh int desc ###
$from =  ($N359Kinfo | Select-String -pattern "start sh int desc" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end sh int desc" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt ($to+1)))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | where-object { ( $_ -match 'mgmt' ) }
 
foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0 )  }

$port        = $b[0] #port
$b           = $b -replace $port -join " "
$description = $b.trim() #description


#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$port</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$description</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh run 
Write-Host "Section : QOS Settings"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : QOS Settings</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers

###Section: show run###
$from =  ($N359Kinfo | Select-String -pattern "start show run" | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show run" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { $_.length -gt 0 }

$qos = @(
"policy-map type network-qos jumbo"
"class type network-qos class-default"
"mtu 9216"
"system qos"
"service-policy type network-qos jumbo"
)

foreach ($line in $qos)
{
if ($N359Kinfo -match $line)
    {
    #start of a new row
    ac $N359Kaudit "<TR>"
    
    ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
    ac $N359Kaudit "<p><font color='#196aa5'>$line</font></p>"
    ac $N359Kaudit "</TD>"
    
    #end of row
    ac $N359Kaudit "</TR>"    
    }
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh int desc 
Write-Host "Section : SNMP"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : SNMP</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">User</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SNMP Host</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SNMP Version</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SNMP Community</font></th>'

###Section: sh int desc ###
#snmp users
$a = $N359Kinfo | Where-Object { $_ -match 'snmp-server user' } 
$a = $a -replace "snmp-server user "
$a = $a.split(" ")
$snmpuser = $a[0]

#snmp target
$a = $N359Kinfo | Where-Object { $_ -match 'snmp-server host' } 
$a = $a -replace "snmp-server host "
$a = $a.split(" ")
$snmp = $a[0]

#snmp version
$snmpv = $a[3]

#snmp community string
$snmpc = $a[4]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$snmpuser</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$snmp</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$snmpv</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$snmpc</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: sh run 
Write-Host "Section : Security Hardening"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Security Hardening</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Value</font></th>'

###Section: sh run ###

#start of a new row
ac $N359Kaudit "<TR>"

$Description = "ip dhcp snooping"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
#start of a new row
ac $N359Kaudit "<TR>"

$Description = "service dhcp"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
#start of a new row
ac $N359Kaudit "<TR>"

$Description = "ip dhcp relay"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
#start of a new row
ac $N359Kaudit "<TR>"

$Description = "vrf context management"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
#start of a new row
ac $N359Kaudit "<TR>"

$Description = "auto-recovery"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
#start of a new row
ac $N359Kaudit "<TR>"

$Description = "ip arp synchronize"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
#start of a new row
ac $N359Kaudit "<TR>"

$Description = "ip tcp path-mtu-discovery"
if ($N359Kinfo -match $Description) { $value = 'True'  } else { $value = 'false' }

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Description</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$value</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Section: show ip int brief vrf all
Write-Host "Section : VRF"
ac $N359Kaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : VRF</b></p></font></td></tr></table>'
#main table
ac $N359Kaudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $N359Kaudit '<table border="1px" width="35%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Group</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port-Channel</font></th>'
ac $N359Kaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'

###Section: show ip int brief vrf all###
$from =  ($N359Kinfo | Select-String -pattern "start show ip int brief vrf all " | Select-Object LineNumber).LineNumber
$to   =  ($N359Kinfo | Select-String -pattern "end show ip int brief vrf all" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $N359Kinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ( $_ -notmatch "=====" ) -and ( $_ -notmatch "IP Interface" ) -and ( $_ -notmatch "Interface Status" ) -and ($_.length -gt 0 )}

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { $_.length -gt 0 }
$int    = $b[0]
$IpAddr = $b[1]
$Status = $b[2]

#start of a new row
ac $N359Kaudit "<TR>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$int</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$IpAddr</font></p>"
ac $N359Kaudit "</TD>"

ac $N359Kaudit "<TD style='border:1px solid black' align=center>"
ac $N359Kaudit "<p><font color='#196aa5'>$Status</font></p>"
ac $N359Kaudit "</TD>"

#end of row
ac $N359Kaudit "</TR>"
}

#Ending & fixing the position of the table
ac $N359Kaudit "</TD></TR></table>"
ac $N359Kaudit "</table><P>"
ac $N359Kaudit "<br>"

#Rename the text file to an html file
Rename-Item $N359Kaudit $html

$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black

#open the html file
ii $html
}



#Start of NicMenu
function N359kAudit
{
 do {
 do {     
     Write-Host "`N359kAudit Menu" -BackgroundColor White -ForegroundColor Black
     Write-Host "
     A. Pull Text Output
     B. Generate Audit Report
     " -BackgroundColor Black -ForegroundColor Green #options to choose from
    
     $choice = Read-Host "choose one of the above" #Get user's entry
     $ok     = $choice -match '^[abz]+$'
     if ( -not $ok) { write-host "Invalid selection" -BackgroundColor Red }
    } until ( $ok )
    switch -Regex ($choice) 
    {
    "A" { N359ktext }
    "B" { N359kreport }
    }
    } until ( $choice -match "Z" )
} #end of NicMenu

#run the menu function
N359kAudit

#End of script