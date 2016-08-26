<#
.SYNOPSIS
    VNX Audit
.DESCRIPTION
    This will log into VNX and generate an html audit report.
.NOTES
    File Name      : VnxAudit.ps1
    Author         : Prathap Sreenivas, gajendra d ambi
    Date           : July 2016
    Prerequisites  : PowerShell V4+, Naviseccli over Vista and upper.
    Copyright      - 
  .LINK
    Script posted over: VCE Internal   
#>

#vnx ip address
Write-Host IP Address of SP A? -BackgroundColor White -ForegroundColor Black
$IP  = Read-Host " " #SP A
Write-Host IP Address of SP B? -BackgroundColor White -ForegroundColor Black
$IP1 = Read-Host " " #SP B
Write-Host USername? -BackgroundColor White -ForegroundColor Black
$UP  = Read-Host " "          #username = password

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

#Start of the Report script
$name      = "VNXAudit"
$VnxAudit  = "$PSScriptRoot\$name.html" #create html file
ni -ItemType file $VnxAudit -Force

#variables for section system settings
#Statistics Logging Status
$a1 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP setstats
if ($a1 -eq "Statistics logging is ENABLED") { $a1 = "Enabled" } elseif ($a1 -ne "Statistics logging is ENABLED") { $a1 = "Disabled" }
$stats = $a1

#Analyzer Status
$b1 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP analyzer -status
$AnStat = $b1

#Analyzer nar interval
$c1 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP analyzer -get -narinterval
$AnNar = $c1

#Analyzer rt interval
$d1 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP analyzer -get -rtinterval
$AnRt = $d1

#Analyzer Periodic Acrchiving
$e1 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP analyzer -get -periodicarchiving 
$e1 = $e1 | Select-String "Periodic Archiving" | Out-String
$e1 = $e1.split(":")[1] 
$AnPe = $e1

#System Powersaving Status
$f1 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP powersaving -info
$f1 = $f1 | Select-String "Global Power Saving Settings" | Out-String
$f1 = $f1.split(":")[1] 
$SysPower = $f1
#end of variables for system settings

#Variables for Fast Cache Information
$a2 = naviseccli -User $UP -Password $UP -Scope 0 -h $IP getall -fastcache

#Disks
$Disk = $a2 | Select-String "Enclosure" | Out-String

#Raid
$RAID = $a2 | Select-String "Raid Type" | Out-String
$RAID = $RAID.split(":")[1] 

#Size
$Size = $a2 | Select-String "Size " | Out-String
$Size = $Size.split(":")[1]

#State
$State = $a2 | Select-String "State" | Out-String
$State = $State.split(":")[1] 

#End of variables for fast cache information

#Variables for Auto-tier Settings
$k = naviseccli -User $UP -Password $UP -Scope 0 -h $IP autotiering -info -state
$l = naviseccli -User $UP -Password $UP -Scope 0 -h $IP autotiering -info -rate
$m = naviseccli -User $UP -Password $UP -Scope 0 -h $IP autotiering -info -schedule

#Auto-tiering State
$ATstate = $k | Select-String "Auto-Tiering State" | Out-String
$ATstate = $ATstate.split(":")[1] 

#Relocation Rate
$Relocrate = $l | Select-String "Relocation Rate" | Out-String
$Relocrate = $Relocrate.split(":")[1] 

#Schedule State
$SState = $m | Select-String "Schedule State" | Out-String
$SState = $SState.split(":")[1] 

#Schedule Days
$SDay = $m | Select-String "Schedule Days" | Out-String
$SDay = $SDay.split(":")[1] 

#Schedule Start Time
$SStart = $m | Select-String "Schedule Start Time" | Out-String
$SStart = $SStart.split(":")[1] 

#Schedule Stop Time
$SStop = $m | Select-String "Schedule Stop Time" | Out-String
$SStop = $SStop.split(":")[1] 
#End of variables for Auto-tier Settings

#Hot Spare
$HS         = naviseccli -User $UP -Password $UP -Scope 0 -h $IP hotsparepolicy -list

#NTP
$Ntps = naviseccli -User $UP -Password $UP -Scope 0 -h $IP ntp -list -servers | Select-String "address: " | out-string
$Ntps = ($Ntps.split(":")[1]).Trim()
[string]$Ntps = $Ntps.replace(" ", ",")

#title
ac $VnxAudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#00518c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>EMC VNX Audit</b></left></td></tr></table><br><br>"
ac $VnxAudit '<!DOCTYPE html>'
ac $VnxAudit '<html>'
ac $VnxAudit '<head>'
ac $VnxAudit '<title>VNXAudit</title>'
ac $VnxAudit '</head>'
ac $VnxAudit '<body bgcolor="white">'
ac $VnxAudit '<table border=1px width="100%" cellspacing="0">'

#Section
Write-Host "Section : Device Information"
ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Device Information</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Serial No.</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Block Version</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">NTP</font></th>'

$a = naviseccli -User $UP -Password $UP -Scope 0 -h $IP getall -host

#Model
$b = $a | Select-String "Model" | Out-String
$b = $b.split(":")[1] -replace "Model Type"

#Serial Number
$c = $a | Select-String "Serial No" | Out-String
$c = $c.split(":")[1] 

#Block Version
$d = $a | Select-String "Revision" | Out-String
$d = $d.split(":")[1] -replace "Revision of the software package"

#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$b</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$c</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$d</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Ntps</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : User Information"
ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : User Information</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'

ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Username</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Role</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Scope</font></th>'

$a = naviseccli -User $UP -Password $UP -Scope 0 -h $IP Security -list

$User  = $a | Select-String "Username" #username
$Role  = $a | Select-String "Role"     #role
$Scope = $a | Select-String "Scope"    #scope

$count = $User.count
[int]$n = "0"

do { 
$Users = $User[$n] | out-string
$Users = $Users.split(":")[1]

$Roles = $Role[$n] | out-string
$Roles = $Roles.split(":")[1]

$Scopes = $Scope[$n] | out-string
$Scopes = $Scopes.split(":")[1] 

$n++

#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Users</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Roles</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Scopes</font></p>"
ac $VnxAudit "</TD>"


#end of row
ac $VnxAudit "</TR>"

} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : Packages Installed"
ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Packages Installed</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Version</font></th>'

$a      = naviseccli -User $UP -Password $UP -Scope 0 -h $IP getall -host
$Pkgs   = $a | Select-String "Name of the software package"
$vers   = $a | Select-String "Revision of the software package"
$count  = $Pkgs.count
[int]$n = "0"

do { 
#start of a new row
ac $VnxAudit "<TR>"

$Pkg = $Pkgs[$n] | out-string
$Pkg = $Pkg.split(":")[1]

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Pkg</font></p>"
ac $VnxAudit "</TD>"

$ver = $vers[$n] | out-string
$ver = $ver.split(":")[1]

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$ver</font></p>"
ac $VnxAudit "</TD>"

$n++
#end of row
ac $VnxAudit "</TR>"
} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : SP Information"

ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : SP Information</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="80%" bgcolor="white" cellspacing="0" cellpadding="2">'

ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SP</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SP Name</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">IP</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Subnet</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Gateway</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Current Speed</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SNMP Status</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Community String</font></th>'

$a = naviseccli -User $UP -Password $UP -Scope 0 -h $IP getall -sp 
$b = naviseccli -User $UP -Password $UP -Scope 0 -h $IP networkadmin -mib  

#SP
$SP = $a | Select-String "Storage Processor" | Out-String 
$SP = $SP.split(":")[1] -replace "Storage Processor Network Name"

#SP Name
$Name = $a | Select-String "Storage Processor Network Name" | Out-String
$Name = $Name.split(":")[1] 

#IP
$IP = $a | Select-String "Storage Processor IP Address" | Out-String  
$IP = $IP.split(":")[1] 

#Subnet
$Subnet = $a | Select-String "Storage Processor Subnet Mask" | Out-String
$Subnet = $Subnet.split(":")[1] 

#Gateway 
$Gateway = $a | Select-String "Storage Processor Gateway Address" | Out-String
$Gateway = $Gateway.split(":")[1] 

#Current Speed 
$SpSpeed = $a | Select-String "Current Speed" | Out-String
$SpSpeed = $SpSpeed.split(":")[1] 

#SNMP Status
$Status = $b | Select-String "SNMP MIB Status" | Out-String
$Status = $Status.split(":")[1] 

#Community
$Community = $b | Select-String "Community" | Out-String
$Community = $Community.split(":")[1] 


#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SP</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Name</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$IP</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Subnet</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Gateway</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SpSpeed</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Community</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

$a = naviseccli -User $UP -Password $UP -Scope 0 -h $IP1 getall -sp 
$b = naviseccli -User $UP -Password $UP -Scope 0 -h $IP1 networkadmin -mib  

#SP B
$SP = $a | Select-String "Storage Processor" | Out-String 
$SP = $SP.split(":")[1] -replace "Storage Processor Network Name"

#SP Name
$Name = $a | Select-String "Storage Processor Network Name" | Out-String
$Name = $Name.split(":")[1] 

#IP
$IP = $a | Select-String "Storage Processor IP Address" | Out-String  
$IP = $IP.split(":")[1] 

#Subnet
$Subnet = $a | Select-String "Storage Processor Subnet Mask" | Out-String
$Subnet = $Subnet.split(":")[1] 

#Gateway 
$Gateway = $a | Select-String "Storage Processor Gateway Address" | Out-String
$Gateway = $Gateway.split(":")[1] 

#Current Speed 
$SpSpeed = $a | Select-String "Current Speed" | Out-String
$SpSpeed = $SpSpeed.split(":")[1] 

#SNMP Status
$Status = $b | Select-String "SNMP MIB Status" | Out-String
$Status = $Status.split(":")[1] 

#Community
$Community = $b | Select-String "Community" | Out-String
$Community = $Community.split(":")[1] 

#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SP</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Name</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$IP</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Subnet</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Gateway</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SpSpeed</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Status</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Community</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : FAST Cache Information"

ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : FAST Cache Information</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="30%" bgcolor="white" cellspacing="0" cellpadding="2">'

ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Disks</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">RAID Type Name</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Size</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">State</font></th>'

#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' width='40%' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Disk</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$RAID</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Size</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$State</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : Hot Spare Policy"
ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Hot Spare Policy</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="60%" bgcolor="white" cellspacing="0" cellpadding="2">'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Policy ID</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Disk Type</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Number of Disks</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Unused disks for Hot Spares</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Recommended Ratio of Keep Unused</font></th>'

$PolicyIDs  = $HS | Select-String "Policy ID" 
$DiskType   = $HS | Select-String "Disk Type" 
$NUMDisk    = $HS | Select-String "Number of Disks" 
$UnusedDisk = $HS | Select-String "Unused disks for hot spares" 
$RecomDisk  = $HS | Select-String "Recommended Ratio of Keep Unused"  

$count = $PolicyIDs.count
[int]$n = "0"

do { 
$PolicyID = $PolicyIDs[$n] | Out-String 
$PolicyID = $PolicyID.split(":")[1] 

$Disk = $DiskType[$n] | Out-String
$Disk = $Disk.split(":")[1]

$NO = $NUMDisk[$n] | Out-String
$NO = $NO.split(":")[1] 

$Unused = $UnusedDisk[$n] | Out-String
$Unused = $Unused.split(":")[1]

$Recomm = $RecomDisk[$n] | Out-String
$Recomm = $Recomm.split(":")[1] 

$n++

#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$PolicyID</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Disk</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$NO</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Unused</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=left>"
ac $VnxAudit "<p><font color='#196aa5'>$Recomm</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : System Settings"

ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : System Settings</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="80%" bgcolor="white" cellspacing="0" cellpadding="2">'

ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Statistics Logging Status</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Analyzer Status</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Analyzer nar Interval</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Analyzer rt Interval</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Analyzer Periodic Archiving</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">System Powersaving Status</font></th>'
   
#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$stats</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$AnStat</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$AnNar</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$AnRt</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$AnPe</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SysPower</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

#Section
Write-Host "Section : Auto-tier Settings"

ac $VnxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Auto-tier Settings</b></p></font></td></tr></table>'
#main table
ac $VnxAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxAudit '<table border="1px" width="80%" bgcolor="white" cellspacing="0" cellpadding="2">'

ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Auto-tiering State</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Relocation Rate</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Schedule State</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Schedule Days</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Schedule Start Time</font></th>'
ac $VnxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Schedule Stop Time</font></th>'

#start of a new row
ac $VnxAudit "<TR>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$ATstate</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$Relocrate</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SState</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SDay</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SStart</font></p>"
ac $VnxAudit "</TD>"

ac $VnxAudit "<TD style='border:1px solid black' align=center>"
ac $VnxAudit "<p><font color='#196aa5'>$SStop</font></p>"
ac $VnxAudit "</TD>"

#end of row
ac $VnxAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxAudit "</TD></TR></table>"
ac $VnxAudit "</table><P>"
ac $VnxAudit "<br>"

$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black

#open the report
ii $VnxAudit