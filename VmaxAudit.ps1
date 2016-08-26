<#
.SYNOPSIS
    Audit report for VMax
.DESCRIPTION
    This will generate an audit report for EMC VMAX devices which will help you to do the QA effortlessly
.NOTES
    File Name      : VmaxAudit.ps1
    Author         : gajendra d ambi, Prathap Sreenivasa
    Date           : July 2016
    Prerequisite   : PowerShell v4+, uemcli over win7 and upper.
    Copyright      - None
.LINK
    Script posted over: 
#>
#Start of script

$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

#Start of the Report script
$name      = "VmaxAudit"
$VmaxAudit  = "$PSScriptRoot\$name.html" #create html file
ni -ItemType file $VmaxAudit -Force

#title
ac $VmaxAudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#00518c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>EMC Vmax Audit</b></left></td></tr></table><br><br>"
ac $VmaxAudit '<!DOCTYPE html>'
ac $VmaxAudit '<html>'
ac $VmaxAudit '<head>'
ac $VmaxAudit '<title>VmaxAudit</title>'
ac $VmaxAudit '</head>'
ac $VmaxAudit '<body bgcolor="white">'
ac $VmaxAudit '<table border=1px width="100%" cellspacing="0">'

#clear previous variables for vmax
#symcfg discover

#Section
Write-Host "Section : SRP Information"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : SRP Information</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">symmetrix ID</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Attachment</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Model</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Mcode Version</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Cache Size (MB)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Num Phys Devices</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Num Symm Devices</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Enginuity Build Version</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Symcli Version</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Symwin Version</font></th>'

############section : General Information ##############
$a = symcfg list | Where-Object { $_ -match "VMAX" }
$a = $a.split(" ") | Where-Object { $_.length -gt 0 }

#SID
$sid = $a[0]

#Attachment
$attachment = $a[1]

#model
$model = $a[2]

#Mcode Version
$Mcode = $a[3]

#Cache Size (MB)
$cache = $a[4]

#Num Phys Devices
$NPdevices = $a[5]

#Num Symm Devices
$NSdevices = $a[6]

$a = symcfg -sid $sid list -container
$a = $a | Where-Object { ( $_ -notmatch "Ports" ) -and ( $_ -notmatch "Container Name" ) -and ( $_ -notmatch "--------" ) -and ( $_ -notmatch 'E M B E D D E D' )}

#Enginuity Build Version
$a = symcfg -sid $sid list -v | more
$b = $a | Where-Object { $_ -match "Enginuity Build Version" }
$ebv  = $b.split(':')[-1] #Enginuity Build Version

#Symmwin Version
$a = symcfg -sid $sid list -v | more
$b = $a | Where-Object { $_ -match "Symmwin Version" }
$sv  = $b.split(':')[-1] #Symmwin Version

#Symmitrix CLI
$a = symcfg -sid $sid list -v | more
$b = $a | Where-Object { $_ -match "Symmetrix CLI " }
$b = $b.split(':')  | Where-Object { $_.length -gt 0 }
$b = $b[1]
$b = $b.split(' ') | Where-Object { $_.length -gt 0 }
$SymCli = $b[0]

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$sid</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$attachment</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$model</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$Mcode</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$cache</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$NPdevices</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$NSdevices</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$ebv</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$SymCli</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$sv</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section symcfg SRP
Write-Host "Section : SRP Information"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : SRP Information</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Default SRP</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Usable Capacity (GB)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Allocated Capacity (GB)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Free Capacity (GB)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Subscribed Capacity (GB)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Subscribed Capacity (%)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Reserved Capacity (%)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">RDFA DSE</font></th>'

### symcfg SRP ###
$a = symcfg -sid $sid list -srp -v

#count
$b = $a | Where-Object { $_ -match "Default SRP  " }
$count = $b.count

[int]$n=0
do 
{
#Names
$b = $a | Where-Object { $_ -match "Name                  " }
$b = $b | select -Index $n
$Names = $b.split(':')[-1]

#Default SRP
$b = $a | Where-Object { $_ -match "Default SRP           " }
$b = $b | select -Index $n
$dsrps = $b.split(':')[-1]

#Usable Capacity
$b = $a | Where-Object { $_ -match "Usable Capacity" }
$b = $b | select -Index $n
$ucs = $b.split(':')[-1]

#Allocated Capacity
$b = $a | Where-Object { $_ -match "Allocated Capacity" }
$b = $b | select -Index $n
$acs = $b.split(':')[-1]

#Free Capacity (GB)
$b  = $a | Where-Object { $_ -match 'Free Capacity' }
$b = $b | select -Index $n
$fcs = $b.split(':')[-1]

#Subscribed Capacity (GB)
$b    = $a | Where-Object { ($_ -match 'Subscribed Capacity') -and ($_ -match 'GB') }
$b = $b | select -Index $n
$scgbs = $b.split(':')[-1]

#Subscribed Capacity (%)
$b    = $a | Where-Object { ($_ -match 'Subscribed Capacity') -and ($_ -match '%') }
$b = $b | select -Index $n
$scpes = $b.split(':')[-1] 

#Reserved Capacity (%)
$b    = $a | Where-Object { ($_ -match 'Subscribed Capacity') -and ($_ -match '%') }
$b = $b | select -Index $n
$rcpes = $b.split(':')[-1]

#RDFA DSE
$b    = $a | Where-Object { ($_ -match 'RDFA DSE') }
$b = $b | select -Index $n
$rdfas = $b.split(':')[-1]

$n++

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$Names</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$dsrps</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$ucs</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$acs</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$fcs</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$scgbs</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$scpes</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$rcpes</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$rdfas</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"
} while ($count -gt $n )

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"


#Section symcfg SRP
Write-Host "Section : Disk Groups"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Disk Groups</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SRP</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">ID</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Flags LTS</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Speed (rpm)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FBA (%)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">CKD (%)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Usable Capacity (GB)</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Product</font></th>'

#SRP
$a = symcfg -sid $sid list -srp -v

#count
$b = $a | Where-Object { $_ -match "Default SRP  " }
$TSrp = $b.count #total number of SRP

##disk groups
$ADG = $a | Where-Object { ($_ -match "Internal") -and ($_ -notmatch "External") }  #all disk groups

[int]$n = 0
do{
$b = $a | Where-Object { $_ -match "Disk Groups" } 
$b = $b -replace '\D+(\d+)\D+','$1' #extract integer
$TDG = $b[$n] #Total number of disk groups for the nth SRP

#Disk groups
$DGs = $ADG | select -First $TDG
foreach ($line in $DGs) {$ADG = $ADG -replace $line | Where-Object { $_.length -gt 0 }}

foreach ($line in $DGs)
    {
    $line = $line.split(" ")
    $line = $line | Where-Object { $_.length -gt 0 }
    $ID        = $line[0]
    $Name      = $line[1]
    $Flgs      = $line[2]
    $Speed     = $line[3]
    $Fba       = $line[4]
    $Ckd       = $line[5]
    $UCapacity = $line[6]
    $Product   = $line[7]

    #Names
    $b = $a | Where-Object { $_ -match "Name                     :" }
    $b = $b | select -Index $n
    $srp = $b.split(':')[-1]

    #start of a new row
    ac $VmaxAudit "<TR>"

    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$srp</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$ID</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$Name</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$Flgs</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$Speed</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$Fba</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$Ckd</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$UCapacity</font></p>"
    ac $VmaxAudit "</TD>"
    
    ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
    ac $VmaxAudit "<p><font color='#196aa5'>$Product</font></p>"
    ac $VmaxAudit "</TD>"
    
    #end of row
    ac $VmaxAudit "</TR>"
    }

$n++
} while ($TSrp -gt $n)

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section SB Bays
Write-Host "Section : System Bays"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : System Bays</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Title</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Value</font></th>'

###environment data###
$a = symcfg -sid $sid list -env_data 
$a = $a | Where-Object { $_.length -gt 0 }

#Bay Name
$b     = $a | Where-Object { $_ -match "Bay Name" }
$b = $b -replace "Bay Name " -replace ":"
$BNs = $b.trimstart() | Where-Object { $_.length -gt 0 } #BayNames

#count
$count = $BNs.count

[int]$x = 1
[int]$y = 2
do
{
$sba = "SB-$x"
$from =  ($a | Select-String -pattern $sba | Select-Object LineNumber).LineNumber
$sbb = "SB-$y"
if ($y -gt $count) { $sbb = "Drive Bays" }
$to   =  ($a | Select-String -pattern $sbb | Select-Object LineNumber).LineNumber

    $i = 0
    $array = @()
    foreach ($line in $a)
    {
    foreach-object { $i++ }
        if (($i -gt $from) -and ($i -lt $to))
            {
            $array += $line      
            }
    }  
$bay = $array

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>System Bay</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$sba</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"  

foreach ($line in $bay) 
    {
     if ($line -match ":") 
        {
        $line = $line.trim()
        $line = $line.split(":")
        $header = $line[0]
        $value  = $line[1]
        }


#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$header</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$value</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"    
    
    }
$x++
$y++
} while (($count+1) -gt $x)

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section port Group
Write-Host "Section : Port Group"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Port Groups</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Groups</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Count</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">View Count</font></th>'

###Port Group Name###
$a = symaccess -sid $sid list -type port -detail
$a = $a | Where-Object { ($_.length -gt 0) -and ($_ -notmatch 'Symmetrix ID') -and ($_ -notmatch 'Port ') -and ($_ -notmatch '----------')}

foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { ($_.length -gt 0) }
$pgn = $b[0]
$pc  = $b[1]
$vc  = $b[2]

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$pgn</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$pc</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$vc</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"      
}

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section Storage Groups
Write-Host "Section : Storage Groups"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Storage Groups</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Storage Group Name</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Dev Count</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SG Count</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">View Count</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">FLGS</font></th>'

###Storage Groups###
$a = symaccess -sid $sid list -type storage -detail
$a = $a | Where-Object { ($_.length -gt 0) -and ($_ -notmatch 'Symmetrix ID') -and ($_ -notmatch 'Legend:')  -and ($_ -notmatch '=')  -and ($_ -notmatch 'Dev   SG') -and ($_ -notmatch 'Group Name') -and ($_ -notmatch '----------')}
foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { $_.length -gt 0 }
$SPN     = $b[0]
$DCount  = $b[1]
$SGCount = $b[2]
$VCount  = $b[3]
$Flgs    = $b[4]

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$SPN</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$DCount</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$SGCount</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$VCount</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$Flgs</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"      
}

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section Initiator Groups
Write-Host "Section : Initiator Groups"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Initiator Groups</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Initiator Group Name</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Init Count</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">View Count</font></th>'

###Initiator Groups###
$a = symaccess -sid $sid list -type initiator -detail
$a = $a | Where-Object { ($_.length -gt 0) -and ($_ -notmatch 'Symmetrix ID') -and ($_ -notmatch 'Legend:')  -and ($_ -notmatch '=')  -and ($_ -notmatch 'Init    View') -and ($_ -notmatch 'Group Name') -and ($_ -notmatch '----------')}
foreach ($line in $a)
{
$b = $line.split(" ") | Where-Object { $_.length -gt 0 }
$IGN = $b[0]
$IC  = $b[1]
$VCl = $b[2]

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$IGN</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$IC</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$VCl</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"      
}

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section List View
Write-Host "Section : Detailed List View"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Detailed List View</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'

$a = symaccess -sid $sid list view -detail
$b = $a | Select-String "Masking View Name"
$count = $b.count

[int]$n = 0
do {
$from =  ($b[$n] | Select-Object LineNumber).LineNumber
$mvn  =  $b[$n] -replace "Masking View Name" -replace ":"
$mvn  = $mvn.trim() #Masking View Name
$n++
$to   =  ($b[$n] | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $a)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$c   = $array
#subtable
ac $VmaxAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Masking View</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Initiator Group</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">WWNs</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port Group</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Storage Group</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Director ID</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Port</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">WWN Port / iSCSI Target</font></th>'

$ign = $c | Where-Object { $_ -match 'Initiator Group Name' }
$ign = $ign -replace "Initiator Group Name" -replace ":"
$ign = $ign.trim() #Initiator Group Name

$rowcount = $c | Where-Object { $_ -match '000' }
$rowcount = $rowcount.count #total rows

$wwns = $c | Where-Object { ($_ -match 'WWN') -and ( $_ -match ':' ) }
$wwns = $wwns -replace 'WWN' -replace ':'
$wwns = $wwns.trim() #WWNs
$wwncount = $wwns.count

$Dirs = $c | Where-Object { $_ -match 'FA-' }
$Dirs = $Dirs.trim()
$DirCount = $Dirs.Count

$pgn = $c | Where-Object { $_ -match 'Port Group Name' }
$pgn = $pgn -replace "Port Group Name" -replace ":"
$pgn = $pgn.trim() #Initiator Group Name

$sgn = $c | Where-Object { ( $_ -match 'Storage Group Name' ) -and ($_ -notmatch 'Storage Group Names') }
$sgn = $sgn -replace "Storage Group Name" -replace ":"
$sgn = $sgn.trim() #Storage Group Name

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center rowspan=$DirCount>"
ac $VmaxAudit "<p><font color='#196aa5'>$mvn</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center rowspan=$DirCount>"
ac $VmaxAudit "<p><font color='#196aa5'>$ign</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center rowspan=$DirCount width=15%>"
ac $VmaxAudit "<p><font color='#196aa5'>$wwns</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center rowspan=$DirCount>"
ac $VmaxAudit "<p><font color='#196aa5'>$pgn</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center rowspan=$DirCount>"
ac $VmaxAudit "<p><font color='#196aa5'>$sgn</font></p>"
ac $VmaxAudit "</TD>"

foreach ($line in $Dirs)
    {
    $d = $line.split(" ") | Where-Object { $_.Length -gt 0 }
    $DirId  = $d[0] #Director ID
    $port   = $d[1] #Port
    $ptname = $d[2] #WWN Port Name / iSCSI Target Name

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$DirId</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$port</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$ptname</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"
    }
ac $VmaxAudit "</TD></TR></table>"

$from =  ($c | select-string -pattern "Dev     Dir:Port" | Select-Object LineNumber).LineNumber
$to   =  ($c | select-string -pattern "Total Capacity" | Select-Object LineNumber).LineNumber

$i = 0
$array = @()
foreach ($line in $a)
{
foreach-object { $i++ }
    if (($i -gt $from) -and ($i -lt $to))
        {
        $array += $line      
        }
}
$e   = $array

$e = $c | where-Object { ($_ -match "000") -and ($_ -match ":0") }

#subtable
ac $VmaxAudit '<table border="1px" width="40%" bgcolor="white" cellspacing="0" cellpadding="2">'

#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Device</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Lun</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Capacity</font></th>'

foreach ($line in $e)
    {
    $f = $line.split(" ") | Where-Object { ( $_ -notmatch ':' ) -and ( $_.length -gt 0 ) -and ( $_ -notmatch "Not" ) -and ( $_ -notmatch "Visible" ) -and ( $_ -notmatch '\\' )}
    $dev = $f[0] #Dev
    $lun = $f[1] #lun
    $cap = $f[-1] #capacity(mb)

#Start of row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$dev</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$lun</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$cap</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"
    }

ac $VmaxAudit "</table><P>"
} while ($n -lt ($count-1))

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section SLO Details
Write-Host "Section : SLO Details"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : SLO Details</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#headers
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Storage Group</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Flags</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Devices</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">GKs</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SGs</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Service Level</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Workload</font></th>'
ac $VmaxAudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">SRP</font></th>'

###SLO###
$a = symsg -sid $sid list -by_slo -detail
$a = $a | Where-Object { $_ -match 'SRP_' }

foreach ($line in $a) 
{
$b = $line.split(" ") | Where-Object { ( $_.length -gt 0 ) }
$sgn   = $b[0]
$flags = $b[1]
$devs  = $b[2]
$gks   = $b[3]
$sgs   = $b[4]
$sln   = $b[5]
$wl    = $b[6]
$srp   = $b[7]

if ($wl -match '>') { $wl = $wl -replace '<' -replace '>'} #<somedata> format will have a problem with html/css, this is the workaround

#start of a new row
ac $VmaxAudit "<TR>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$sgn</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$flags</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$devs</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$gks</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$sgs</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$sln</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$wl</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$srp</font></p>"
ac $VmaxAudit "</TD>"

#end of row
ac $VmaxAudit "</TR>"      
}

#Ending & fixing the position of the table
ac $VmaxAudit "</TD></TR></table>"
ac $VmaxAudit "</table><P>"
ac $VmaxAudit "<br>"

#Section
Write-Host "Section : Environment Data"
ac $VmaxAudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="1"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section : Environment Data</b></p></font></td></tr></table>'
#main table
ac $VmaxAudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="1"<TR><TD>'
#subtable
ac $VmaxAudit '<table border="1px" width="50%" bgcolor="white" cellspacing="0" cellpadding="2">'

#headers

$a = symcfg -sid $sid list -env_data -v
$a = $a | Where-Object { ($_.length -gt 0) -and ( $_ -notmatch 'Timestamp' ) -and ( $_ -notmatch 'Symmetrix' ) -and ( $_ -match ':' ) }
$a = $a.trim()

foreach ($line in $a)
{
$b = $line.split(':')
$b = $b.trim()
$title = $b[0]
$value = $b[1]

#start of a new row
ac $VmaxAudit "<TR>"

if ($title -eq 'Bay Name')
{
ac $VmaxAudit "<TD style='border:1px solid black' align=center >"
ac $VmaxAudit "<p><b><font size=5 color='black'>$title</font></b></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center >"
ac $VmaxAudit "<p><b><font size=5 color='black'>$value</font></b></p>"
ac $VmaxAudit "</TD>"

} elseif ($title -eq 'Drive Enclosure Number')
{
ac $VmaxAudit "<TD style='border:1px solid black' align=center >"
ac $VmaxAudit "<p><i><font size=3 color='black'>$title</font></i></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center >"
ac $VmaxAudit "<p><i><font size=3 color='black'>$value</font></i></p>"
ac $VmaxAudit "</TD>"
} else
{
ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$title</font></p>"
ac $VmaxAudit "</TD>"

ac $VmaxAudit "<TD style='border:1px solid black' align=center>"
ac $VmaxAudit "<p><font color='#196aa5'>$value</font></p>"
ac $VmaxAudit "</TD>"
}

#end of row
ac $VmaxAudit "</TR>"
}

#open the report
ii $VmaxAudit