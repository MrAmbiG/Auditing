<#
.SYNOPSIS
    Audit report for emc esrs appliance
.DESCRIPTION
    This will generate an audit report for esrs
.NOTES
    File Name      : EsrsAudit.ps1
    Author         : gajendra d ambi
    Date           : August 2016
    Prerequisite   : PowerShell v4+, plink over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: 
#>
#start of script

$filename  = "EsrsInfo.txt"
$esrsinfo   = "$PSScriptRoot\$filename" #create text file

#Start of function
function GetPlink 
{
<#
.SYNOPSIS
    Gets the plink
.DESCRIPTION
    This will make sure plink is either downloaded from the internet if it is not present and if it cannot download
    then it will pause the script till you copy it manually.
.NOTES
    File Name      : GetPlink.ps1
    Author         : gajendra d ambi
    Date           : Audust 2016
    Prerequisite   : PowerShell v4+, over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: 
    github.com/mrambig
    [source] http://www.virtu-al.net/2013/01/07/ssh-powershell-tricks-with-plink-exe/

#>
$PlinkLocation = $PSScriptRoot + "\Plink.exe"
$presence = Test-Path $PlinkLocation
if (-not $presence) 
    {
    Write-Host "Missing Plink.exe, trying to download...(10 seconds)" -BackgroundColor White -ForegroundColor Black
    Invoke-RestMethod "http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe" -TimeoutSec 10 -OutFile "plink.exe"
    if (-not $presence)
        {
            do
            {
            Write-Host "Unable to download plink.exe, please download and add it to the same folder as this script" -BackgroundColor Yellow -ForegroundColor Black
            Read-host "Hit Enter/Return once plink is present"
            $presence = Test-Path $PlinkLocation
            } while (-not $presence)
        }
    }

if ($presence) { Write-Host "Detected Plink.exe" -BackgroundColor White -ForegroundColor Black }
} #End of function

function Esrstext
{
GetPlink #calling the get plink function.

#X server's credentials
Write-Host esrs Address?  -ForegroundColor Black -BackgroundColor White
$esrs  = Read-Host ""
Write-Host esrs Username? -ForegroundColor Black -BackgroundColor White
$user = Read-Host ""
Write-Host esrs password? -ForegroundColor Black -BackgroundColor White
$pass = Read-Host ""

#start timer
$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

ni -ItemType file $esrsinfo -Force
 
#copy plink to c:\ for now
Copy-Item $PSScriptRoot\plink.exe C:\

$commands = @(
"hostname"
"cat /etc/hosts"
"cat /etc/resolv.conf"
"cat /etc/esrsclient.conf"
"route"
"date"
)

    [int]$n="0"
    foreach ($command in $commands)
    {
    echo y | C:\plink.exe -ssh $user@$esrs -pw $pass "exit"
    "Section$n"                                                     >> $esrsinfo
    $n++
    "start "+$command                                               >> $esrsinfo
    "%%%%%%%%%%%%%%%%%%%%%%%%%%%%"                                  >> $esrsinfo
    C:\plink.exe -ssh -v -noagent $esrs -l $user -pw $pass $command >> $esrsinfo
    ""                                                              >> $esrsinfo
    ""                                                              >> $esrsinfo
    "end "+$command                                                 >> $esrsinfo
    $n++
    }
}

function esrsreport 
{
$esrsinfo = gc $esrsinfo
#Start of the Report script
$report     = "EsrsAudit"
$EsrsAudit  = "$PSScriptRoot\$report.txt" #create text file
$html       = "$PSScriptRoot\$report.html" #html file
if ((Test-Path $html) -eq "True") {ri $html -Force -Confirm:$false } #remove old html report file
ni -ItemType file $N359Kaudit -Force

$from =  ($esrsinfo | Select-String -pattern "start hostname" | Select-Object LineNumber).LineNumber
$to   =  ($esrsinfo | Select-String -pattern "end hostname" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $esrsinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

#hostname
$hostname = $a | Where-Object { ($_.length -gt 0) -and ( $_ -notmatch "%%%%%%%" ) }

$from =  ($esrsinfo | Select-String -pattern "start cat /etc/resolv.conf" | Select-Object LineNumber).LineNumber
$to   =  ($esrsinfo | Select-String -pattern "end cat /etc/resolv.conf" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $esrsinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "#") -and ($_ -notmatch "#") -and ($_.length -gt 0) -and ( $_ -notmatch "%%%%%%%" ) }

#domain
$b = $a | Where-Object { $_ -match 'search' }
$b = $b -replace "search"
$domain = $b.trim()

#dns
$b = $a | Where-Object { $_ -match 'nameserver' }
$b = $b -replace "nameserver"
$b = $b.trim()
$dns = $b
if ($b.count -gt 1) { $dns = $b -join ", " }

#date
$from =  ($esrsinfo | Select-String -pattern "start date" | Select-Object LineNumber).LineNumber
$to   =  ($esrsinfo | Select-String -pattern "end date" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $esrsinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array 

$date = $a | Where-Object { $_ -notmatch "%%%" } #date

#version
$a = $esrsinfo | Select-String "Version="
$version = $a -replace "Version="

#title
ac $EsrsAudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#00518c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>ESRS Audit</b></left></td></tr></table><br><br>"
ac $EsrsAudit '<!DOCTYPE html>'
ac $EsrsAudit '<html>'
ac $EsrsAudit '<head>'
ac $EsrsAudit '<title>ESRSAudit</title>'
ac $EsrsAudit '</head>'
ac $EsrsAudit '<body bgcolor="white">'
ac $EsrsAudit '<table border=1px width="100%" cellspacing="0">'

#Section
Write-Host "Section : ESRS Information"
ac $EsrsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : ESRS Information</b></p></font></td></tr></table>'
#main table
ac $EsrsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $EsrsAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">hostname</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Domain</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">dns</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">version</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">date</font></th>'

#start of a new row
ac $EsrsAudit "<TR>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$hostname</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$domain</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$dns</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$version</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$date</font></p>"
ac $EsrsAudit "</TD>"

#end of row
ac $EsrsAudit "</TR>"

#Ending & fixing the position of the table
ac $EsrsAudit "</TD></TR></table>"
ac $EsrsAudit "</table><P>"
ac $EsrsAudit "<br>"

#Section
Write-Host "Section : Route Information"
ac $EsrsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : ESRS Route Informaiton</b></p></font></td></tr></table>'
#main table
ac $EsrsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $EsrsAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Destination</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Gateway</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Genmask</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Flags</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Metric</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ref</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Use</font></th>'
ac $EsrsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'

#route
$from =  ($esrsinfo | Select-String -pattern "start route" | Select-Object LineNumber).LineNumber
$to   =  ($esrsinfo | Select-String -pattern "end route" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $esrsinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array

$a = $a | Where-Object { ($_ -notmatch "Destination     Gateway") -and ($_ -notmatch "Kernel IP") -and ($_ -notmatch "#") -and ($_ -notmatch "#") -and ($_.length -gt 0) -and ( $_ -notmatch "%%%%%%%" ) } 
 
 foreach ($line in $a)
 {
 $b = $line.split(" ") | Where-Object { ($_.length -gt 0) }
 $dest    = $b[0]
 $gw      = $b[1]
 $mask    = $b[2]
 $flags   = $b[3]
 $metric  = $b[4]
 $ref     = $b[5]
 $use     = $b[6]
 $iface   = $b[7]


#start of a new row
ac $EsrsAudit "<TR>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$dest</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$gw</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$mask</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$flags</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$metric</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$ref</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$use</font></p>"
ac $EsrsAudit "</TD>"

ac $EsrsAudit "<TD style='border:1px solid black' align=center>"
ac $EsrsAudit "<p><font color='#196aa5'>$iface</font></p>"
ac $EsrsAudit "</TD>"

#end of row
ac $EsrsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $EsrsAudit "</TD></TR></table>"
ac $EsrsAudit "</table><P>"
ac $EsrsAudit "<br>"

Rename-Item $EsrsAudit $html

$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black

#open the report
ii $html
}

#Start of NicMenu
function EsrsAudit
{
 do {
 do {     
     Write-Host "`EsrsAudit Menu" -BackgroundColor White -ForegroundColor Black
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
    "A" { Esrstext }
    "B" { esrsreport }
    }
    } until ( $choice -match "Z" )
} #end of NicMenu

#run the menu function
EsrsAudit

#End of script

