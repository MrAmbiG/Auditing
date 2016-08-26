<#
.SYNOPSIS
    VNXeAudit
.DESCRIPTION
    This will generate an audit report for VNXe
.NOTES
    File Name      : VNXeAudit.ps1
    Author         : gajendra d ambi
    Date           : July 2016
    update1        : Included DNS, Domain, auto detect iscsi/vmfs
    Prerequisite   : PowerShell v4+, uemcli over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: VCE Internal
#>

#vnxe ip address
Write-Host VNXe IP? -ForegroundColor Black -BackgroundColor White
$vnxe = Read-Host " "
Write-Host VNXe Password? -ForegroundColor Black -BackgroundColor White
$pass = Read-Host " "

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

#Start of the Report script
$name      = "VnxeAudit"
$VnxeAudit = "$PSScriptRoot\$name.html" #create html file
ni -ItemType file $VnxeAudit -Force

#title
ac $VnxeAudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#005a9c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>EMC VNXe Audit</b></left></td></tr></table><br><br>"
ac $VnxeAudit '<!DOCTYPE html>'
ac $VnxeAudit '<html>'
ac $VnxeAudit '<head>'
ac $VnxeAudit '<title>VNXeAudit</title>'
ac $VnxeAudit '</head>'
ac $VnxeAudit '<body bgcolor="white">'
ac $VnxeAudit '<table border=1px width="100%" cellspacing="0">'

#Section
Write-Host "Section : Device Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Device Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Serial Number</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Auto Failback</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Health State</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Firmware</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SSH</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">EulaStatus</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">DNS</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Domain</font></th>'

$a = uemcli -d $vnxe -u Local/admin -p $pass /sys/general show

#SystemName
$SystemName = $a | Select-String "System name" | Out-String
$SystemName = $SystemName.split("=")[1]

#Model
$Model = $a | Select-String "Model           " | Out-String
$Model = $Model.split("=")[1]

#Serial Number
$SN = $a | Select-String "Product serial number" | Out-String;
$SN = $SN.split("=")[1]

#AutoFailback
$AutoFailback = $a | Select-String "Auto failback" | Out-String
$AutoFailback = $AutoFailback.split("=")[1]

#Health state
$Health = $a | Select-String "Health state" | Out-String
$Health = $Health.split("=")[1]

#Firmware
$b  = uemcli -d $vnxe -u Local/admin -p $pass /sys/soft/ver show
$b = $b | Select-String "Version  " | Out-String
$Firmware = $b.split("=")[1]

#SSH
$a   = uemcli -d $vnxe -u service -p $pass /service/ssh show
$SSH = $a | Select-String "Enabled" | Out-String
$SSH = $SSH.split("=")[1]

#EULA status
$a          = uemcli -d $vnxe -u Local/admin -p $pass  /sys/eula show
$eula = $a | Select-String "Agree" | Out-String
$eula = $eula.split("=")[1]

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$SystemName</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Model</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$SN</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$AutoFailback</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Health</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Firmware</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ssh</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$eula</font></p>"
ac $VnxeAudit "</TD>"

#dns
$a = uemcli -d $vnxe -u Local/admin -p $pass /net/dns/domain show -detail
$a = $a | Select-String "DNS  " | Out-String
$dns = $a.split("=")[1]
ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$dns</font></p>"
ac $VnxeAudit "</TD>"

#domain
$a = uemcli -d $vnxe -u Local/admin -p $pass /net/dns/domain show -detail
$a = $a | Select-String "Domain  " | Out-String
$domain = $a.split("=")[1]
ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$domain</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

#Section
Write-Host "Section : User Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : User Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Role</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'

$a = uemcli -d $vnxe -u Local/admin -p $pass /user/account show
#$a = $a.trim("1:    ")
#$a = $a.trim("2:    ")

$IDS   = $a | Select-String "ID"
$Names = $a | Select-String "Name"
$roles = $a | Select-String "Role"
$Types = $a | Select-String "Type"

$count = $IDS.count
[int]$n = "0"

do { 
$ID = $IDS[$n] | out-string
$ID = $ID.split("=")[1]

$Name = $Names[$n] | out-string
$Name = $Name.split("=")[1]

$role = $roles[$n] | out-string
$role = $role.split("=")[1]

$Type = $Types[$n] | out-string
$Type = $Type.split("=")[1]

$n++

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Name</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$role</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Type</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

#Section
Write-Host "Section : LACP Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : LACP Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="40%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SP</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">MTU</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Health Status</font></th>'

$a = uemcli -d $vnxe -u Local/admin -p $pass /net/la show -detail

$IDS          = $a | Select-String "ID           "
$SPs          = $a | Select-String "SP           "
$Portss       = $a | Select-String "Ports        "
$MTUs         = $a | Select-String "MTU size     "
$HealthStates = $a | Select-String "Health state "

$count = $IDS.count
[int]$n = "0"

do { 
$ID = $IDS[$n] | out-string
$ID = $ID.split("=")[1]

$SP = $SPs[$n] | out-string
$SP = $SP.split("=")[1]

$Ports = $Portss[$n] | out-string
$Ports = $Ports.split("=")[1]

$MTU = $MTUs[$n] | out-string
$MTU = $MTU.split("=")[1]

$HealthState = $HealthStates[$n] | out-string
$HealthState = $HealthState.split("=")[1]

$n++

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$SP</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Ports</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$MTU</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$HealthState</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

#Section
Write-Host "Section : FastCache & FastVp Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : FastCache & FastVp Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastCacheSize</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Drives</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Raid</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Health</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastVpPaused</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastVpScheduled</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastVpRate</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastVpDataUp</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastVpDataDown</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastVpPolicy</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Frequency</font></th>'

#FastCache
$a         = uemcli -d $vnxe -u Local/admin -p $pass /stor/config/fastcache show
$b         = $a | Select-String "Total Space" | out-string
$b         = $b.split(" ")
$FastCache = $b[-1]

$b      = $a | Select-String "Number of drives" | Out-String 
$Drives = $b.split("=")[1]

$b      = $a | Select-String "RAID level" | Out-String 
$RaidL  = $b.split("=")[1]

$b        = $a | Select-String "Health state" | Out-String 
$HealthS  = $b.split("=")[1]

#FastVp
$a      = uemcli -d $vnxe -u Local/admin -p $pass /stor/config/fastvp show -detail
$b      = $a | Select-String "Paused" | Out-String
$Paused = $b.split("=")[1]

$b               = $a | Select-String "Schedule enabled" | Out-String
$ScheduleEnabled = $b.split("=")[1]

$b    = $a | Select-String "Rate" | Out-String
$Rate = $b.split("=")[1]

$b      = $a | Select-String "Data to move up" | Out-String
$DataUp = $b.split("=")[1]

$b        = $a | Select-String "Data to move down" | Out-String
$DataDown = $b.split("=")[1]

$b         = $a | Select-String "Frequency   " | Out-String
$Frequency = $b.split("=")[1]

$d        = uemcli -d $vnxe -u Local/admin -p $pass /stor/prov/vmware/vmfs show -detail
$d        = $d | Select-String "FAST VP policy      " | Out-String
$VpPolicy = $d.split("=")[1]


#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$FastCache</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Drives</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$RaidL</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$HealthS</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Paused</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ScheduleEnabled</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Rate</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$DataUp</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$DataDown</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$VpPolicy</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Frequency</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

#Section
Write-Host "Section : Pool Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Pool Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">TotalSpace</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">RemainingSpace</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Drives</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Subscription</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">RaidL</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Stripe</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Rebalancing</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Health</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FastCacheStatus</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ProtectionSize</font></th>'

$a  = uemcli -d $vnxe -u Local/admin -p $pass /stor/config/pool show -detail

$b  = $a | Select-String "ID                " | Out-String
$ID = $b.split("=")[1]

$b    = $a | Select-String "Name       " | Out-String
$Name = $b.split("=")[1]

$b    = $a | Select-String "Description       " | Out-String
$Desc = $b.split("=")[1]

$b           = $a | Select-String "Total space   " | Out-String
$b           = $b.split("=")
$b           = $b.split(" ")
$TotalSpace  = $b[-1]

$b               = $a | Select-String "Remaining space" | Out-String
$b               = $b.split("=")
$b               = $b.split(" ")
$RemainingSpace  = $b[-1]

$b      = $a | Select-String "Number of drives" | Out-String
$Drives = $b.split("=")[1]

$b            = $a | Select-String "Subscription percent" | Out-String
$Subscription = $b.split("=")[1]

$b            = $a | Select-String "RAID level" | Out-String
$RaidL        = $b.split("=")[1]

$b      = $a | Select-String "Stripe length" | Out-String
$Stripe = $b.split("=")[1]

$b           = $a | Select-String "Rebalancing" | Out-String
$Rebalancing = $b.split("=")[1]

$b           = $a | Select-String "Health state" | Out-String
$HealthState = $b.split("=")[1]

$b      = $a | Select-String "FAST Cache enabled" | Out-String
$FastCE = $b.split("=")[1]

$b              = $a | Select-String "Protection size used" | Out-String
$ProtectionSize = $b.split("=")[1]

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Name</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Desc</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$TotalSpace</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$RemainingSpace</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Drives</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Subscription</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$RaidL</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Stripe</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Rebalancing</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$HealthState</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$FastCE</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ProtectionSize</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

#Section
Write-Host "Section : NAS Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : NAS Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Type</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Nas</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ports</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ip</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Subnet</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Gateway</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SP</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Preferred</font></th>'

$a  = uemcli -d $vnxe -u Local/admin -p $pass /net/if show

$IDs      = $a | Select-String "ID               " #don't change the extra spacing
$Types    = $a | Select-String "Type"
$Nass     = $a | Select-String "NAS server"
$Ports    = $a | Select-String "Port             " #don't change the extra spacing
$Ips      = $a | Select-String "IPv4 address "
$Masks    = $a | Select-String "IPv4 subnet mask "
$Gateways = $a | Select-String "IPv4 gateway"
$Sps      = $a | Select-String "SP               " #don't change the extra spacing
$Prefers  = $a | Select-String "Preferred        " #don't change the extra spacing

$count = $IDS.count
[int]$n = "0"

do { 
$ID = $IDS[$n] | out-string
$ID = $ID.split("=")[1]

$Type = $Types[$n] | out-string
$Type = $Type.split("=")[1]

$Nas = $Nass[$n] | out-string
$Nas = $Nas.split("=")[1]

$Port = $Ports[$n] | out-string
$Port = $Port.split("=")[1]

$Ip = $Ips[$n] | out-string
$Ip = $Ip.split("=")[1]

$Mask = $Masks[$n] | out-string
$Mask = $Mask.split("=")[1]

$Gateway = $Gateways[$n] | out-string
$Gateway = $Gateway.split("=")[1]

$Sp = $Sps[$n] | out-string
$Sp = $Sp.split("=")[1]

$Prefer = $Prefers[$n] | out-string
$Prefer = $Prefer.split("=")[1]

$n++

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Type</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Nas</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Port</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Ip</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Mask</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Gateway</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Sp</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Prefer</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"


#NFS Shares
Write-Host "Section : NFS Shares Information"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : NFS Shares Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Health</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">File System</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Server</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Pool ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Pool</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Format</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">thin</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Size</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Max Size</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Used</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Local path</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Export Path</font></th>'

$a  = uemcli -d $vnxe -u Local/admin -p $pass /stor/prov/vmware/nfs show -detail

$IDs        = $a | select-string "ID                   " #Dont't Change the extra spacing
$Names      = $a | select-string "Name                 " #Dont't Change the extra spacing
$HealthS    = $a | select-string "Health state         " #Dont't Change the extra spacing
$FSs        = $a | select-string "File system          " #Dont't Change the extra spacing
$Servers    = $a | select-string "Server               " #Dont't Change the extra spacing
$PoolIDs    = $a | select-string "Storage pool ID      " #Dont't Change the extra spacing
$SPools     = $a | select-string "Storage pool         " #Dont't Change the extra spacing
$Formats    = $a | select-string "Format               " #Dont't Change the extra spacing
$Thins      = $a | select-string "Thin provisioning enabled" #Dont't Change the extra spacing
$Sizes      = $a | select-string "Size                 " #Dont't Change the extra spacing
$MAxSizes   = $a | select-string "Maximum size         " #Dont't Change the extra spacing
$Useds      = $a | select-string "Size used            " #Dont't Change the extra spacing
$LocalPaths = $a | select-string "Local path           " #Dont't Change the extra spacing
$XportPaths = $a | select-string "Export path          " #Dont't Change the extra spacing

$count = $IDS.count
[int]$n = "0"

do { 
$ID = $IDS[$n] | out-string
$ID = $ID.split("=")[1]

$Name = $Names[$n] | out-string
$Name = $Name.split("=")[1]

$Health = $HealthS[$n] | out-string
$Health = $Health.split("=")[1]

$FS = $FSs[$n] | out-string
$FS = $FS.split("=")[1]

$Server = $Servers[$n] | out-string
$Server = $Server.split("=")[1]

$PoolID = $PoolIDs[$n] | out-string
$PoolID = $PoolID.split("=")[1]

$SPool = $SPools[$n] | out-string
$SPool = $SPool.split("=")[1]

$Format = $Formats[$n] | out-string
$Format = $Format.split("=")[1]

$Thin = $Thins[$n] | out-string
$Thin = $Thin.split("=")[1]

$Size = $Sizes[$n] | out-string
$Size = $Size.split("=")[1]
$Size = $Size.split(" ")
$Size = $Size[-1]

$MAxSize = $MAxSizes[$n] | out-string
$MAxSize = $MAxSize.split("=")[1]
$MAxSize = $MAxSize.split(" ")
$MAxSize = $MAxSize[-1]

$Used = $Useds[$n] | out-string
$Used = $Used.split("=")[1]
$Used = $Used.split(" ")
$Used = $Used[-1]

$LocalPath = $LocalPaths[$n] | out-string
$LocalPath = $LocalPath.split("=")[1]

$XportPath = $XportPaths[$n] | out-string
$XportPath = $XportPath.split("=")[1]

$n++

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Name</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Health</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$FS</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Server</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$PoolID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$SPool</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Format</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Thin</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Size</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$MAxSize</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Used</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$LocalPath</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$XportPath</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

} while (($count) -gt $n )

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

$a  = uemcli -d $vnxe -u Local/admin -p $pass /stor/prov/vmware/vmfs show -detail

$IDs              = $a | select-string "ID                   "
$LUNs             = $a | select-string "LUN                  "
$Names            = $a | select-string "Name                 "
$HealthS          = $a | select-string "Health state         "
$SpoolIds         = $a | select-string "Storage pool ID      "
$Spools           = $a | select-string "Storage pool         "
$Sizes            = $a | select-string "Size                 "
$ProtectionSizes  = $a | select-string "Protection size used "
$SpOwners         = $a | select-string "SP owner             "
$Trespasseds      = $a | select-string "Trespassed           "
$Hosts            = $a | select-string "Virtual disk access hosts"

$count = $IDS.count
[int]$n = "0"

if ($count -gt 0)
{
#Section
Write-Host "Section : VMFS"
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : VMFS Information</b></p></font></td></tr></table>'
#main table
ac $VnxeAudit '<table style="border:1px solid black" width="100%" bgcolor=""white"" cellspacing="0" cellpadding="0"<TR><TD>'
#subtable
ac $VnxeAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">LUN</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Health</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SpoolId</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Spool</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Size</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ProtectionSize</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SpOwner</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Trespassed</font></th>'
ac $VnxeAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Hosts</font></th>'

do { 
$ID = $IDS[$n] | out-string
$ID = $ID.split("=")[1]

$LUN = $LUNs[$n] | out-string
$LUN = $LUN.split("=")[1]

$Name = $Names[$n] | out-string
$Name = $Name.split("=")[1]

$Health = $HealthS[$n] | out-string
$Health = $Health.split("=")[1]

$SpoolId = $SpoolIds[$n] | out-string
$SpoolId = $SpoolId.split("=")[1]

$Spool = $Spools[$n] | out-string
$Spool = $Spool.split("=")[1]

$Size = $Sizes[$n] | out-string
$Size = $Size.split("=")[1]

$ProtectionSize = $ProtectionSizes[$n] | out-string
$ProtectionSize = $ProtectionSize.split("=")[1]

$SpOwner = $SpOwners[$n] | out-string
$SpOwner = $SpOwner.split("=")[1]

$Trespassed = $Trespasseds[$n] | out-string
$Trespassed = $Trespassed.split("=")[1]

$Host0 = $Hosts[$n] | out-string
$Host0 = $Host0.split("=")[1]

$n++

#start of a new row
ac $VnxeAudit "<TR>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ID</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$LUN</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Name</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$HealthS</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$SpoolId</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Spool</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Size</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$ProtectionSize</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$SpOwner</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Trespassed</font></p>"
ac $VnxeAudit "</TD>"

ac $VnxeAudit "<TD style='border:1px solid black' align=left>"
ac $VnxeAudit "<p><font color='#196aa5'>$Host0</font></p>"
ac $VnxeAudit "</TD>"

#end of row
ac $VnxeAudit "</TR>"

#Ending & fixing the position of the table
ac $VnxeAudit "</TD></TR></table>"
ac $VnxeAudit "</table><P>"
ac $VnxeAudit "<br>"

} while (($count) -gt $n )
} else 
{ 
ac $VnxeAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="0"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b><i>Section : No Iscsi</i></b></p></font></td></tr></table>'
}

$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black

#open the report
ii $VnxeAudit