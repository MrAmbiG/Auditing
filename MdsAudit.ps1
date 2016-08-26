<#
.SYNOPSIS
    Audit report for MDS
.DESCRIPTION
    This will generate an audit report for MDS Switches
.NOTES
    File Name      : MdsAudit.ps1
    Author         : gajendra d ambi
    Date           : July 2016
    Prerequisite   : PowerShell v4+, plink over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: 
#>

#Start of script
$name      = "MDSinfo.txt"
$MDSinfo   = "$PSScriptRoot\$name" #create text file

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

function MDStext {
GetPlink #calling the get plink function.

#MDS credentials
Write-Host MDS Address? -ForegroundColor Black -BackgroundColor White
$mds  = Read-Host " "
Write-Host MDS Username? -ForegroundColor Black -BackgroundColor White
$user = Read-Host " "
Write-Host MDS password? -ForegroundColor Black -BackgroundColor White
$pass = Read-Host " "

#start timer
$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

   ni -ItemType file $MDSinfo -Force
    
    #copy plink to c:\ for now
    Copy-Item $PSScriptRoot\plink.exe C:\
    
    $commands = @(
    "sh version                     "
    "sh module                      "
    "sh int mgmt 0                  "
    "sh int bri                     "
    "sh int desc                    "
    "sh switchname                  "
    "sh clock                       "
    "sh license usage               "
    "sh env                         "
    "sh feature                     "
    "sh flogi database              "
    "sh port-channel database       "
    "sh vsan                        "
    "sh zone status                 "
    "sh snmp community              "
    "sh snmp host                   "
    "sh logging server              "
    "sh ntp peer-status             "
    "sh fcalias                     "
    "sh zoneset act                 "
    "sh int fc1/1-48                "
    "sh hosts                       "
    "Sh logging console             "
    "Sh logging monitor             "
    "sh device-alias database       "
    "sh port-license                "
    )
    
    [int]$n="0"
    foreach ($command in $commands)
    {
    echo y | C:\plink.exe -ssh $user@$mds -pw $pass "exit"
    "#"                                                            >> $MDSinfo
    "Section$n"                                                    >> $MDSinfo
    $command                                                       >> $MDSinfo
    "============================"                                 >> $MDSinfo
    C:\plink.exe -ssh -v -noagent $mds -l $user -pw $pass $command >> $MDSinfo
    ""                                                             >> $MDSinfo
    ""                                                             >> $MDSinfo
    "Section$n"                                                    >> $MDSinfo
    "#"                                                            >> $MDSinfo
    $n++
    }
    
ac $MDSinfo "end of text report"
}

function MDSreport {
$MDSinfo = gc $MDSinfo

#Start of the Report script
$name      = "MdsAudit"
$MdsAudit  = "$PSScriptRoot\$name.txt" #create text file
$html      = "$PSScriptRoot\$name.html" #html file
if ((Test-Path $html) -eq "True") {ri $html -Force -Confirm:$false } #remove old html report file
ni -ItemType file $MdsAudit -Force

###Section: sh version###
$section = @()
$MDSinfo | %{
    if ($_.Contains("Section0")) #all lines after the key word Section0
        { $in = $true }
    elseif ($_.Contains("Section1")) #but before section 1
        { $in = $false; }
    elseif ($in)
        {$section += $_} 
}
$version = $section

#title
ac $MdsAudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#005a9c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>MDS Switch's Audit</b></left></td></tr></table><br><br>"
ac $MdsAudit '<!DOCTYPE html>'
ac $MdsAudit '<html>'
ac $MdsAudit '<head>'
ac $MdsAudit '<title>MdsAudit</title>'
ac $MdsAudit '</head>'
ac $MdsAudit '<body bgcolor="white">'
ac $MdsAudit '<table border=1px width="100%" cellspacing="0">'

#Section
Write-Host "Section : Device Information 1"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Device Information 1</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Bios</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">loader</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">kickstart</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">system</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">kickstart Image</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">System Image</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">device</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Memory</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Processor ID</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">System Vesion</font></th>'

#Bios
$a       = $version | Select-String "BIOS:      " | out-string
$bios    = $a.split(":")[1] -replace "version"

#loader
$a       = $version | Select-String "loader: "    | out-string
$loader  = $a.split(":")[1] -replace "version"

#kickstart
$a       = $version | Select-String "kickstart:" | out-string
$ks      = $a.split(":")[1] -replace "version"

#system
$a       = $version | Select-String "system:"    | out-string
$sys     = $a.split(":")[1] -replace "version"

#kickstart image file is
$a       = $version | Select-String "kickstart image file is:" | out-string
$ki      = $a.split(' ')[-1]

#system image file
$a       = $version | Select-String "system image file is:" | out-string
$si      = $a.split(' ')[-1]

#device
$a      = $version | Select-String "Chassis" | out-string
$a      = $a.split(" ")
$device = $a[3..5] -join " "

#memory
$a      = $version | Select-String "of memory" | out-string
$a = $($a.split(" ")) #creating an array with all words and numbers in that line above

function Is-Numeric ($Value) { return $Value -match "^[\d\.]+$"} #defining one function to check whether the value in the array is an integer
foreach ($i in $a)
{
 if (Is-Numeric($i) -eq True)
 {
 if ($i.Length -gt "2") 
    { $memory = $i }
 }
}

#Processor Board ID
$a    = $version | Select-string "Processor Board" | out-string
$PBId = $a.split(' ')[-1]

#Device Name
$a     = $version | Select-String "Device Name:" | Out-String
$DName = $a.split(":")[1]

#System Version
$a = $version | Select-string "System Version:" | Out-String
$SVer = $a.split(":")[1]

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$bios</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$loader</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ks</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$sys</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ki</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$si</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$device</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$memory</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PBId</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$DName</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$SVer</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"


#Section
Write-Host "Section : Device Information 2"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Device Information 2</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">mod</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ports</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module-Type</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SW</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">HW</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">WWN</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">MAC</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SN</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Clock</font></th>'

###Section: sh module###
$section = @()
$MDSinfo | %{
    if ($_.Contains("sh module")) 
        { $in = $true }
    elseif ($_.Contains("Section2")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_} 
}
$version = $section

$a = $version | Select-String "Mod  Ports" -Context 0,3 | out-string
$a = $a.split("----------") -replace ">" -replace "Type" -replace "Ports" -replace "Module" -replace "Model" -replace "Status" -replace "Mod"
$a = $a.trim()
$a = $a.split(" ") 
$a = $a | Where-Object {$_.Length -gt '0'} 
$a = $a.TrimEnd('*')

#mod
$mod = $a[0]

#ports
$a = $a.TrimStart($mod)
$a = $a.trim() | Where-Object {$_.Length -gt '0'}
$ports = $a[0]

#Module-Type
$a = $a.TrimStart($ports)
$a = $a.trim() | Where-Object {$_.Length -gt '0'}
$ModType = $a[0]+" "+$a[1]+" "+$a[2]

#status
$a = $a.TrimStart($ModType)
$a = $a.trim() | Where-Object {$_.Length -gt '0'}
$status = $a.split()[-1]

#Model
$a = $a.TrimEnd($status)
$a = $a.trim() | Where-Object {$_.Length -gt '0'}
$Model=$a -join ('-')

$a = $version | Select-String "Mod  Sw" -Context 0,3 | out-string
$a = $a.split("-----")[-1]

#SW
$a  = $a.trim()
$a  = $a.TrimStart($mod)
$a  = $a.trim()
$b  = $a.Substring(0,15)
$SW = $b.trim()

#HW
$a  = $a.TrimStart($SW)
$a  = $a.trim()
$b  = $a.Substring(0,7)
$HW = $b 

#wwn
$a   = $a.TrimStart($HW)
$a   = $a.trim()
$b   = $a.split('to')[0]
$c   = $a.split('to')[2]
$wwn = "[$b] to [$c]"

$a = $version | Select-String "Serial-Num" -Context 0,3 | out-string
$a = $a.split("-----") | Where-Object { ( $_ -notmatch '> Mod  MAC' ) -and ( $_ -notmatch 'Num' ) -and ( $_ -notmatch 'Serial' ) -and ( $_.length -gt '1' )} #-replace 'Serial' -replace '> Mod  MAC' -replace 'Address(es)' -replace 'Num'
$a = $a.trim()
$a = $a.split() | Where-Object { ( $_.length -gt '0' ) }

#Serial-Num
$SN = $a[-1]

#mac
$a   = $a -replace "$SN" | Where-Object { ($_.Length -gt '1') }
$mac = $a -join '-' -replace "-to-"," to "

###Section: sh switchname###
$section = @()
$MDSinfo | %{
    if ($_.contains("Section5"))
        { $in = $true }
      elseif ($_.contains("Section6")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

#switch's name 
$switchName = $version -replace '=' | Where-Object {$_.length -gt '1'} | Where-Object {$_ -notmatch 'sh switchname'}

###Section: sh clock###
$section = @()
$MDSinfo | %{
    if ($_.contains("Section6"))
        { $in = $true }
      elseif ($_.contains("Section7")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

#clock 
$clock = $version -replace '='| Where-Object {$_.length -gt '2'} | Where-Object {$_ -notmatch 'sh clock '}

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$mod</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ports</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ModType</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Model</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$SW</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$HW</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$wwn</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$mac</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$SN</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$switchName</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$clock</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Management Interface"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section :  Management Interface</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Speed</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Address</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Net Address</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">MTU</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">BW</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">errors</font></th>'

###Section: sh int mgmt 0###
$section = @()
$MDSinfo | %{
    if ($_.Contains("sh int mgmt 0")) 
        { $in = $true }
    elseif ($_.Contains("Section2")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_} 
}
$version = $section
#$version

#MgmtSpeed
$a         = $version | Select-String "Hardware is"
$MgmtSpeed = ($a -split(" "))[-1]

#MgmtAddress
$a           = $version | Select-String -CaseSensitive "Address is "
$MgmtAddress = ($a -split(" "))[-1]

#MgmtIntAddress
$a              = $version | Select-String "Internet address"
$MgmtIntAddress = ($a -split(" "))[-1]

#MgmtMtu
$a   = $version | Select-String "MTU"
$a   = ($a -split('bytes'))[0] -replace 'MTU'
$mtu = $a.trim()

#MgmtBw
$a       = $version | Select-String "MTU"
$MgmtBw  = ($a -split('BW'))[1]

#errors
$a = $version | Select-String "errors" | Where-Object {$_ -notmatch '0'  }
if ($a -eq $null) { $a = 'No Errors'}
$errors = $a

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$MgmtSpeed</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$MgmtAddress</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$MgmtIntAddress</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$mtu</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$MgmtBw</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$errors</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Interface Brief 1"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Interface Brief 1</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Vsan</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Admin Mode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Admin Trunk Mode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SFP</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Oper Mode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Oper Speed(Gbps)</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Channel</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">IP</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">mtu</font></th>'


###Section: sh int bri ###
$section = @()
$MDSinfo | %{
    if ($_.contains("Section3"))
        { $in = $true }
      elseif ($_.contains("Section4")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_} 
}
$version = $section
$lines   = $version | Where {$_ -match "fc"} | Where {$_ -notmatch "sup-"}

#Port Map table#
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int      = $line[0] #Interface
$vsan     = $line[1] #Vsan
$AMode    = $line[2] #Admin Mode
$ATMode   = $line[3] #Admin Trunkk Mode
$Status   = $line[4] #Status
$SFP      = $line[5] #SFP
$OMode    = $line[6] #Oper Mode
$OSpeed   = $line[7] #Oper Speed (Gbps)
$PChannel = $line[8] #Port Channel

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$vsan</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$AMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ATMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$SFP</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$OMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$OSpeed</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PChannel</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Port Channel Summary
$lines   = $version | Where {$_ -match "port-"}
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int     = $line[0] #Interface
$vsan    = $line[1] #vsan
$ATMode  = $line[2] #admn trunk mode
$status  = $line[3] #status
$OMode   = $line[4] #Oper mode
$OSpeed  = $line[5] #oper speed
$ip      = $line[6] #ip

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$vsan</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$AMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$OMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$OSpeed</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ip</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#supervisor engine
$lines   = $version | Where {$_ -match "sup-"}
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int      = $line[0] #Interface
$Status   = $line[1] #Status
$Speed    = $line[2] #SFP

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Speed</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Management
$lines   = $version | Where {$_ -match "mgmt"}
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int      = $line[0] #Interface
$ip       = $line[2] #ip
$Status   = $line[1] #Status
$Speed    = $line[3] #SFP
$mtu      = $line[5] #mtu

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Speed</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>-</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ip</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$mtu</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Interface Description"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Interface Description</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'

###Section: sh int desc###
$section = @()
$MDSinfo | %{
    if ($_.contains("Section4"))
        { $in = $true }
      elseif ($_.contains("Section5")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_} 
}
$version = $section

#Port Interface Description#
$lines   = $version | Where {$_ -match "fc"}
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int      = $line[0] #Interface
$desc     = $line -replace $int
$desc     = $desc -join " " #description

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$desc</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Port Interface Description#
$lines   = $version | Where {$_ -match "mgmt"}
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int      = $line[0] #Interface
$desc     = $line[1] #Description

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$desc</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Port Interface Description#
$lines   = $version | Where {$_ -match "port-"}
foreach ($line in $lines)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$int      = $line[0] #Interface
$desc     = $line[1] #Description

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$desc</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : License Usage"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : License Usage</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="40%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">feature</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ins</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Lic Count</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Expiry</font></th>'

###Section: sh license usage###
$section = @()
$MDSinfo | %{
    if ($_.contains("Section7"))
        { $in = $true }
      elseif ($_.contains("Section8")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

$a = $version -replace '=' -replace '#' | Where-Object {($_ -notmatch 'Feature ') -and ($_ -notmatch 'sh license usage') -and ($_ -notmatch '---------------') -and ($_ -notmatch 'count')}
$a = $a | Where-Object { $_.length -gt '0' }

foreach ($line in $a)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$feature  = $line[0] #feature
$ins      = $line[1] #ins
$LCount   = $line[2] #License Count
$Status   = $line[3] #status
if ($Status -contains "In") { $Status = "In Use" }
$Expiry   = $line[4] #Expiry
if ($line -contains "never") { $Expiry = "never" }

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$feature</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ins</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$LCount</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Expiry</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Power Supply Information 1"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Power Supply Information 1</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">PS</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Power(watts)</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">status</font></th>'

###Section: sh env###
$section = @()
$MDSinfo | %{
    if ($_.contains("Section8"))
        { $in = $true }
      elseif ($_.contains("Section9")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

#Power Supply Information 1#
$a = $version | Where-Object {$_ -match 'Voltage'}
$voltage = $a.split(':')[-1]

$section = @()
$version | %{
    if ($_.contains("Voltage:"))
        { $in = $true }
      elseif ($_.contains("Mod Model")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version0 = $section

$version0 = $version0 | Where-Object {$_ -notmatch '-------------------'} | Where-Object {$_ -notmatch 'PS  Mode'} | Where-Object {$_ -notmatch '(Watts)'}
$version0 = $version0 | Where-Object { $_.length -gt '0' }

foreach ($line in $version0)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$ps     = $line[0] #PowerSupply
$model  = $line[1] #Model
$PowerW = $line[2] #power (watts)
$Status = $line[4] #status

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ps</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$model</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PowerW</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Power Supply Information 2"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Power Supply Information 2</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Mod</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Power requested(watts)</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Power allocated(watts)</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">status</font></th>'

$section = @()
$version | %{
    if ($_.contains("Mod Model"))
        { $in = $true }
      elseif ($_.contains("Power Usage Summary:")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version0 = $section

$version0 = $version0 | Where-Object {($_ -notmatch 'Requested') -and ($_ -notmatch 'Mod Model') -and ($_ -notmatch '(Watts)') -and ($_ -notmatch '------')}
$version0 = $version0 | Where-Object { $_.length -gt '0' }

foreach ($line in $version0)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$ps      = $line[0] #PowerSupply
$model   = $line[1] #Model
$PowerRW = $line[2] #power requested (watts))
$PowerAW = $line[2] #power allocated (watts)
$Status  = $line[6] #status

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ps</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$model</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PowerW</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PowerAW</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Power Supply Information 3"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Power Supply Information 3</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="70%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Redundancy Mode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Redundancy Op Mode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Power Capacity</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Total Allocated Power</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Total Available Poweratus</font></th>'

#power usage summary#
$section = @()
$MDSinfo | %{
    if ($_.contains("Section8"))
        { $in = $true }
      elseif ($_.contains("Section9")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

$section = @()
$version | %{
    if ($_.contains("Power Usage Summary:"))
        { $in = $true }
      elseif ($_.contains("Clock:")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version0 = $section
$version0 = $version0 | Where-Object {$_ -notmatch '-------'}

#Redundancy Mode
$a     = $version0 | Where-Object {$_ -match 'Power Supply redundancy mode' }
$a     = $a.split(":")[-1]
$RMode = $a.trim() #Power Supply redundancy mode

#redundancy operational mode
$a      = $version0 | Where-Object {$_ -match 'Power Supply redundancy operational mode' }
$a      = $a.split(":")[-1]
$ROMode = $a.trim() #Power Supply redundancy operational mode

#Total Power Capacity
$a      = $version0 | Where-Object {$_ -match 'Total Power Capacity' }
$a      = $a.split(":")[-1]
$TPC    = $a.trim() #Total Power Capacity

#Total Power Allocated (budget)
$a      = $version0 | Where-Object {$_ -match 'Total Power Allocated' }
$a      = $a.split("(budget)")[-1]
$TPAB   = $a.trim() #Total Power Allocated

#Total Power Available
$a      = $version0 | Where-Object {$_ -match 'Total Power Available' }
$a      = $a.split("Available")[-1]
$TPA    = $a.trim() #Total Power Available 

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$RMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ROMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$TPC</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$TPAB</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$TPA</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Fans"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Fans</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="70%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">RFan</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">HW</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

#power usage summary#
$section = @()
$MDSinfo | %{
    if ($_.contains("Section8"))
        { $in = $true }
      elseif ($_.contains("Section9")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

#FAN#
$section = @()
$version | %{
    if ($_.contains("Fan:"))
        { $in = $true }
      elseif ($_.contains("Temperature:")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version0 = $section
$version0 = $version0 | Where-Object { ($_ -notmatch "-----------------" ) -and ($_ -notmatch 'Fan             Model' ) -and ($_ -notmatch 'Fan Air Filter :' ) }
$version0 = $version0 | Where-Object { $_.length -gt "1" } #Removing blank lines

foreach ($line in $version0)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$version0 = $version0 | Where-Object { $_.length -gt '0' } #remove blank lines
$line = $line.split(" ") 

#variables
$fan     = $line[0] #fan
$model   = $line[1,2,3] #Model
$hw      = $line[2] #hw
$status  = $line[3] #status

if ($model -match '--') { $model = '--' }
if ($model -match '--') { $hw = '--' }
if ($line -contains 'OK') { $status = 'OK' } 
if ($line -notcontains 'OK') { $status = 'error' } 

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$fan</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$model</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$hw</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$status</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Temperature"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Temperature</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Module</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

#Temperature#
$section = @()
$MDSinfo | %{
    if ($_.contains("Section8"))
        { $in = $true }
      elseif ($_.contains("Section9")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version = $section

#Temperature#
$section = @()
$version | %{
    if ($_.contains("Temperature:"))
        { $in = $true }
      elseif ($_.contains("Section8")) 
        { $in = $false; }
    elseif ($in)
        {$section += $_}
}
$version0 = $section
$version0 = $version0 | Where-Object { ($_ -notmatch "-----------------" ) -and ($_ -notmatch 'Module   Sensor' ) -and ($_ -notmatch '(Celsius)' ) }
$version0 = $version0 | Where-Object { $_.length -gt "1" }

foreach ($line in $version0)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$version0 = $version0 | Where-Object { $_.length -gt '0' } #remove blank lines
$line = $line.split(" ") 

#variables
$module  = $line[0] #module
$status  = $line[6]

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$module</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$status</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Features"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Features</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Features</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Instance</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

###Section: sh feature ###
$from =  ($MDSinfo | Select-String -pattern "sh feature" | Select-Object LineNumber).LineNumber
$to =  ($MDSinfo  | Select-String -pattern "sh flogi database " | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$version = $array | where-Object { ( $_ -notmatch 'Section' ) -and ( $_ -notmatch '#' ) -and ( $_ -notmatch '====' ) -and ( $_ -notmatch 'Feature Name' ) -and ( $_ -notmatch '--------' ) -and ( $_.length -gt '0' )}

foreach ($line in $version)
{
$line = $line -replace '\s+', ' ' #remove multiple white spaces
$line = $line.split(" ")

#variables
$feature = $line[0] #Feature Name
$insta   = $line[1] #Instance
$status  = $line[2] #State

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$feature</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$insta</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$status</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : flogi Database"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : flogi Database</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Vsan</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FC ID</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Name</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Node Name</font></th>'

#sh flogi database
$from =  ($MDSinfo | Select-String -pattern "sh flogi database" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh port-channel database" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$version = $array |  Where-Object { ( $_ -match "/" ) -or ($_ -match "port-") }
foreach ($line in $version)
{
$line  = $line.split(" ")
$line  = $line | Where-Object { $_.length -gt '0' } #remove blank lines

$int   = $line[0]
$vsan  = $line[1]
$fcid  = $line[2]
$PName = $line[3]
$NName = $line[4]

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$vsan</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$fcid</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PName</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$NName</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : port-channel database"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : port-channel database</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">PortChannel</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">AdminMode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">OPMode</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports Up</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports Down</font></th>'

#sh port-channel database
$from =  ($MDSinfo | Select-String -pattern "sh port-channel database" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh vsan" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
#$array
$a = $array
$b = $a | Where-Object { $_ -match "ports in total" } | get-unique 
$b = $b -replace "ports in total," -replace "ports up"
$b = $b.split(" ") | Where-Object { $_.length -gt '0' }
$TotalPorts = $b | get-unique #total number of port numbers

$version = $a | Where-Object { ( $_ -notmatch "Section" ) -and ($_ -notmatch "#") -and ($_.length -gt 0 ) -and ($_ -notmatch '======' ) -and ($_ -notmatch 'First operational port' ) -and ($_ -notmatch 'Last membership' ) -and ($_ -notmatch 'ports in total' )}

#total port numbers
$TotalPC = ($version | Where-Object { ( $_ -match "port-" ) }).count #total number of port channels

$PortChannels = @($version | Where-Object { ( $_ -match "port-" ) })
$AdminModes   = @($version | Where-Object { ( $_ -match "Administrative" ) })
$OpModes      = @($version | Where-Object { ( $_ -match "Operational channel" ) })

[int]$n  = '0'
[int]$FP = '0' #first port
[int]$LP = '3' #last port

do { 
$PortChannel = $PortChannels[$n]
$AdminMode   = $AdminModes[$n]
$AdminMode   = $AdminMode.split(' ')[-1]
$OpMode      = $OpModes[$n]
$OpMode      = $OpModes.split(' ')[-1]

#ports
$a = $version -replace "Ports:" -replace '\s+', ' ' #remove multiple white spaces
$a = $a | Where-Object {$_ -match "fc"}
$UPports = @($a)

$UPorts = $UPports[$FP..$LP] | Where-Object { $_ -match "[up]" }
$DPorts = $UPports[$FP..$LP] | Where-Object { $_ -notmatch "[up]" }


#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PortChannel</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$AdminMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$OpMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left width=20%>"
ac $MdsAudit "<p><font color='#196aa5'>$UPorts</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left width=20%>"
ac $MdsAudit "<p><font color='#196aa5'>$DPorts</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

$FP += $TotalPorts
$LP += $TotalPorts
$n++
} while (($TotalPC) -gt $n )

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : VSAN"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : VSAN</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VSAN</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interoperability</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">loadbalancing</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Operational Mode</font></th>'

#sh vsan 
$from =  ($MDSinfo | Select-String -pattern "sh vsan" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh zone status" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$version = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch 'Section12' ) -and ( $_ -notmatch 'Section13' ) -and ( $_ -notmatch '#' ) }

#IDs
$a   = $version | Where-Object { ( $_ -match 'information' ) } 
$a   = $a -replace "information"
$IDs = $a.trimstart()

#count
$count = $IDs.count

#VSAN Names
$a      = $version | Where-Object { ( $_ -match 'name:' ) } 
$a      = $a -replace "name:" -replace "state:"
$vNames = $a.trimstart()

#interoperability mode
$a      = $version | Where-Object { ( $_ -match 'interoperability mode' ) } 
$a      = $a -replace "interoperability mode:"
$IModes = $a.trimstart()

#loadbalancing
$a   = $version | Where-Object { ( $_ -match 'loadbalancing' ) } 
$a   = $a -replace "loadbalancing:"
$lbs = $a.trimstart()

#operational state
$a  = $version | Where-Object {$_ -match 'operational state'}
$a  = $a.split(':') -replace 'operational state'
$oss = $a | ? {$_.trim() -ne "" } #remove empty lines

[int]$n = '0'
do { 
$ID     = $IDs[$n]
   $vNS    = $vNames[$n]
$vName  = $vNS.split(' ')[0]
   $status = $vNS -replace "$vName"
$status = $status.trimstart()
$IMode  = $IModes[$n]
$lb     = $lbs[$n]
$os     = $oss[$n]

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$vName</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$status</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$IMode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$lb</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$os</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

$n++
} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"


#Section
Write-Host "Section : zone status"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : zone status</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">modes</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">sessions</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">hard-zoning</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">smart-zoning</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">rscn-format</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">activation overwrite control</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Default zone</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Status</font></th>'

#sh zone status 
$from =  ($MDSinfo | Select-String -pattern "sh zone status" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh snmp community" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$version = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch 'Section13' ) -and ( $_ -notmatch 'Section14' ) -and ( $_ -notmatch '#' ) }

#vSAN ID
$a = $version | Where-Object { ($_ -match 'default-zone:') }
$a = $a -replace 'default-zone: deny distribute:' -replace ': default' -replace ' active only Interop' -replace 'full Interop'
$IDs = $a -replace 'VSAN: '

#count
$count = $vsans.count

#modes
$a     = $version | Where-Object { ($_ -match 'mode: ') }
$modes = ($a -replace 'mode: ').trim()

#sessions
$a        = $version | Where-Object { ($_ -match 'session: ') }
$sessions = ($a -replace 'session: ').trim()

#hard-zoning
$a      = $version | Where-Object { ($_ -match 'hard-zoning:') }
$HZones = ($a -replace 'hard-zoning:').trim()

#smart-zoning
$a      = $version | Where-Object { ($_ -match 'smart-zoning:') }
$SZones = ($a -replace 'smart-zoning:').trim()

#rscn-format
$a         = $version | Where-Object { ($_ -match 'rscn-format:') }
$FAddresss = ($a -replace 'rscn-format:').trim()

#activation overwrite control
$a    = $version | Where-Object { ($_ -match 'activation overwrite control:') }
$AVCs = ($a -replace 'activation overwrite control:').trim()

#Default zone:qos?
$a = $version | Where-Object { ($_ -match 'qos') }
$a = $a.trim()
$a = $a.replace(": ","-")
$DZones = $a.replace(" ",", ")

#Status
$a = $version | Where-Object { ($_ -match 'Status:') }
$a = $a -replace 'Status:'
$Statuss = $a.trim()

[int]$n = '0'
do { 
$ID       = $IDs[$n]
$mode     = $modes[$n]
$session  = $sessions[$n]
$HZone    = $HZones[$n]
$SZone    = $SZones[$n]
$FAddress = $FAddresss[$n]
$AVC      = $AVCs[$n]
$DZone    = $DZones[$n]
    $Status   = $Statuss[$n]
$Status   = $Status.split(' ')[0,1] -join " "

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$mode</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$session</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$HZone</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$SZone</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$FAddress</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$AVC</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$DZone</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

$n++
} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

### section : sh snmp community + sh snmp host###
Write-Host "Section : SNMP Setitngs"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : SNMP Setitngs</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="60%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Target</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Version</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Level</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">community</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Group/Access</font></th>'

#sh snmp community 
$from =  ($MDSinfo | Select-String -pattern "sh snmp community " | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh snmp host" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch '_______' ) -and ( $_ -notmatch 'Section14' )  -and ( $_ -notmatch 'context' ) -and ( $_ -notmatch 'Section15' ) -and ( $_ -notmatch '#' ) }
$a = @($a.split(' ') | Where-Object {$_.length -gt '0'})

#Group/Access
$G_Access  = $a[1]
$community = $a[0]

#sh snmp host
$from =  ($MDSinfo | Select-String -pattern "sh snmp host" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh logging server" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$version = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch '------' ) -and ( $_ -notmatch 'Section15' )  -and ( $_ -notmatch 'SecName' ) -and ( $_ -notmatch 'Section16' ) -and ( $_ -notmatch '#' ) -and ( $_.length -gt '0' ) }
$count = $version.count

foreach ($a in $version)
{
$a = $a.split(' ') | Where-Object {$_.length -gt '0'}
$tar   = $a[0] #target
$port  = $a[1]
$ver   = $a[2]
$level = $a[3]
$type  = $a[4]
$string = $a[5]
if ($string -eq $community) { $GAccess = $G_Access } else { $GAccess = $null  }

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$tar</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$port</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ver</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$level</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$type</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$string</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$GAccess</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
} 

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Section
Write-Host "Section : Syslog Information"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Syslog Information</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="20%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">syslog</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">severity</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">facility</font></th>'

###sh logging server###
$from =  ($MDSinfo | Select-String -pattern "sh logging server" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh ntp peer-status" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch 'Section16' )  -and ( $_ -notmatch 'Section17' ) -and ( $_ -notmatch '#' ) }
$version = $a.split(' ') | Where-Object {$_.length -gt '0'}

#syslog servers
$syslog = $version | Where-Object { $_ -match '{' }

#severity
$a        = $version | Where-Object { $_ -match 'severity' }
$severity = ($a.split(':')[-1]).trimstart()

#facility
$a        = $version | Where-Object { $_ -match 'facility' }
$facility = ($a.split(':')[-1]).trimstart()

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$syslog</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$severity</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$facility</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"


#Section
Write-Host "Section : NTP Information"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : NTP Information</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Remote NTP</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Local NTP</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ST</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Poll</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Reach</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Delay</font></th>'

###sh ntp peer-statusr###
$from =  ($MDSinfo | Select-String -pattern "sh ntp peer-status" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh fcalias" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$version = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch '------' ) -and ( $_ -notmatch 'Section17' ) -and ( $_ -notmatch 'Section18' )  -and ( $_ -notmatch 'reach delay' ) -and ( $_ -notmatch 'peer' ) -and ( $_ -notmatch '#' ) -and ($_.length -gt '0')}

foreach ($a in $version)
{
$a = $a.split(' ') | Where-Object {$_.length -gt '0'}
$RemoteNTP = $a[0]
$LocalNTP  = $a[1]
$St        = $a[2]
$Poll      = $a[3]
$Reach     = $a[4]
$Delay     = $a[5]

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$RemoteNTP</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$LocalNTP</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$St</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Poll</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Reach</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$Delay</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

###sh fcalias ###
$from =  ($MDSinfo | Select-String -pattern "sh fcalias" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh zoneset act" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$a = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch 'Section18' ) -and ( $_ -notmatch 'Section19' ) -and ( $_ -notmatch '#' ) -and ($_.length -gt '0')}
$version = $a.trimstart()

if ($version -notcontains "Alias not present")
{
#Section
Write-Host "Section : FC Alias"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : FC Alias</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="40%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VSAN ID</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Alias</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">PWWN</font></th>'

#count
$count = $version.count/2

#arrays
$fcaliass = @() #array for fc alias
$pwwnss   = @() #array for fc pwwn

#populate the above arrays using the loop below
[int]$n  = '0'
foreach ($line in $version)
    {
    if(($n%2) -eq 0 )
        {
        $fcaliass += $line
        } else
        {
        $pwwnss += $line
        }
    $n++
    }

[int]$n  = '0'
do {
$a     = $fcaliass[$n] -replace "fcalias name " -replace " vsan"
$a     = $a.split(' ')
$ID    = $a[-1]
$alias = $a[0]

$pwwn = $pwwnss[$n] -replace "pwwn "

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$alias</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$pwwn</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

$n++
} while ($count -gt $n)

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

} else 

{
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b><i>Alias not present</i></b></p></font></td></tr></table>'
ac $MdsAudit "<br>"
}

###sh zoneset act###
$from =  ($MDSinfo | Select-String -pattern "sh zoneset act" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "sh int fc1/1-" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$a = $array
$version = $a.trimstart()
 
if ($version -notcontains "Zoneset not present")
{
#Section
Write-Host "Section : zoneset"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : zoneset</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="60%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">VSAN ID</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Alias</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">PWWNs</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FC ID</font></th>'

$version  = $a | Where-Object { ( $_ -notmatch '=========' ) -and ( $_ -notmatch 'zoneset' ) -and ( $_ -notmatch 'Section' ) -and ( $_ -notmatch '#' ) -and ($_.length -gt '0')}

#count
$count = ($version | Where-Object { $_ -match "zone name" }).count

#zones
$a = $version | Where-Object { $_ -match "zone name" } 
$line1 = $a -replace "zone name " -replace "vsan"

#fcids
$a = $version | Where-Object { $_ -match "fcid" } 
$fcidsline = $a -replace "fcid"

#arrays
$fcarray   = @()
$pwwnarray = @()

[int]$n=0
foreach ($a in $fcidsline)
{
$a = $a.split(' ') 
$a = $a -replace "pwwn" | Where-Object {$_.length -gt 1}
$fcarray   += $a[0]
$pwwnarray += $a[1]
}

[int]$n=0
[int]$f=0
[int]$p=1
do{
$a = $line1[$n]
$a = $a.split(' ')
$alias = $a[0]
$ID    = $a[-1]

$fcs = $fcarray[$f..$p] -join ", "

$pwwns = $pwwnarray[$f..$p] -join ", "

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$alias</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$fcs</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$pwwns</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"

$f++
$p++
$f++
$p++
$n++
} while ($count -gt $n)

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"
} else

{
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b><i>Zoneset not present</i></b></p></font></td></tr></table>'
ac $MdsAudit "<br>"
}

#Section
Write-Host "Section : port-license"
ac $MdsAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : port-license</b></p></font></td></tr></table>'
#main table
ac $MdsAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $MdsAudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Interface</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Cookie</font></th>'
ac $MdsAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Activation License</font></th>'

###sh port-license###
$from =  ($MDSinfo | Select-String -pattern "sh port-license" | Select-Object LineNumber).LineNumber
$to   =  ($MDSinfo  | Select-String -pattern "end of text report" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $MDSinfo)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$version = $array | where-Object { ( $_ -notmatch 'Section' ) -and ( $_ -notmatch '#' ) -and ( $_ -notmatch '====' ) -and ( $_ -notmatch 'Available port activation' ) -and ( $_ -notmatch 'Interface   Cookie' ) -and ( $_ -notmatch '--------' ) -and ( $_.length -gt '0' )}


foreach ($a in $version)
{
$a = $a.split(" ") | Where-Object { $_.length -gt "0" }
$int       = $a[0]
$cookie    = $a[1]
$PALicense = $a[2]

#start of a new row
ac $MdsAudit "<TR>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$int</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$cookie</font></p>"
ac $MdsAudit "</TD>"

ac $MdsAudit "<TD style='border:1px solid black' align=left>"
ac $MdsAudit "<p><font color='#196aa5'>$PALicense</font></p>"
ac $MdsAudit "</TD>"

#end of row
ac $MdsAudit "</TR>"
}

#Ending & fixing the position of the table
ac $MdsAudit "</TD></TR></table>"
ac $MdsAudit "</table><P>"
ac $MdsAudit "<br>"

#Rename the text file to an html file
Rename-Item "$PSScriptRoot\$name.txt" $html

$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black

#open the html file
ii $html
}

#Start of NicMenu
function MDSAudit
{
 do {
 do {     
     Write-Host "`MDSAudit Menu" -BackgroundColor White -ForegroundColor Black
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
    "A" { MDStext }
    "B" { MDSreport }
    }
    } until ( $choice -match "Z" )
} #end of NicMenu

#run the menu function
MDSAudit

#End of script
































