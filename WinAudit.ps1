<#
.SYNOPSIS
    Windows audit
.DESCRIPTION
    This should help you to audit a virtual/physical windows machine without having to get into the nitty gritty of things.
.NOTES
    File Name      : winaudit.ps1
    Author         : gajendra d ambi, Mohan Ganesan
    Date           : June 2016
    Prerequisite   : PowerShell v4+ over windows.
    Copyright      - None
.LINK
    Script posted over: https://github.com/gajuambi/windows
    
#>
#Start of script
$stopWatch = [system.diagnostics.stopwatch]::startNew()
$stopWatch.Start()

Write-Host "Neglect those initial gwmi errors, they are expected" -ForegroundColor Black -BackgroundColor Yellow
$mzones=(get-dnsserverzone | where-object{($_.ZoneName -like "*.*") -and ($_.IsReverseLookupZone -ne "False")}).ZoneName
$SerList = @() #list of all possible combination of servers for all mzones
foreach ($mzone in $mzones)
{
    $servers=(get-dnsserverresourcerecord -ZoneName $mzone | where-object{($_.HostName -notlike "*esx*") -and ($_.RecordType -eq "A")}).HostName
    foreach ($ser in $servers)
    {
    $server1="$ser.$mzone"
    $server =$server1.tostring()
    $SerList += ,$server
    }
}

$winservs= @() #array for windows VMs
foreach($server in $SerList)
{
$OperatingSystem = (gwmi -computername $server Win32_OperatingSystem).Caption
if($OperatingSystem -like "Microsoft*")
    {
    $winservs += ,$server
    }
}
$winservs = $winservs | Get-Unique #avoid repetition

#adding all servers as trusted hosts
set-item wsman:\localhost\Client\TrustedHosts -value "*" -Confirm:$false -Force

#Start of the Report script
$name     = "VMaudit"
$winaudit = "$PSScriptRoot\$name.html" #create html file
ni -ItemType file $winaudit -Force

foreach ($server in $winservs)
    {
    #cd wsman::localhost\client #adding $server as a trusted host
    #Set-Item TrustedHosts $server -Confirm:$false -Force
    #Restart-Service WinRm
    #cd c:

     $hostname = ($server.split('.'))[0]
     $domain   = [string]::Join(".",($server.split('.'))[1..9])
     $OperatingSystem = (gwmi -computername $server  Win32_OperatingSystem).Caption
     $activation      = (gwmi -query "select * from SoftwareLicensingProduct" -computername $server| where ApplicationId -EQ 55c92734-d682-4d71-983e-d6ec3f16059f | where PartialProductKey).LicenseStatus
     if ($activation -eq "1") { $activation = "Licensed"} else { $activation = "Unlicensed"}
     $Architecture    = (gwmi -computername $server  Win32_OperatingSystem).OSArchitecture
     $Build           = (gwmi -computername $server  Win32_OperatingSystem).BuildNumber
     $Description     = (gwmi -computername $server  Win32_OperatingSystem).Description
     $Timezone        = (gwmi -computername $server win32_timezone).Caption
     $netid           = gwmi Win32_NetworkAdapterConfiguration -ComputerName $server -filter IPEnabled=TRUE | select-object IPAddress,DefaultIPGateway,IPSubnet,DNSServerSearchOrder       
     $IP              = $netid.IPAddress     
     $Subnet          = $netid.IPSubnet
     $Gateway         = $netid.DefaultIPGateway      
     $DNS             = $netid.DNSServerSearchOrder  
     

#title
ac $winaudit "<table style='border:2px solid black' width=100% height=80 bgcolor='#005a9c' cellspacing='0' cellpadding='2'><tr><td><font face='Calibri, Times, serif' size='6' color='#ffffff'><left><b>$Description</b></left></td></tr></table>"
ac $winaudit '<!DOCTYPE html>'
ac $winaudit '<html>'
ac $winaudit '<head>'
ac $winaudit '<title>WindowsAudit</title>'
ac $winaudit '</head>'
ac $winaudit '<body bgcolor="white">'
ac $winaudit '<table border=1px width="100%" cellspacing="0">'

#Section
Write-Host "checking: Windows Information"
ac $winaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="2"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section: Windows Information</b></p></font></td></tr></table>'
#main table
ac $winaudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="2"<TR><TD>'
#subtable
ac $winaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Domain</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">OperatingSystem</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">activation</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Architecture</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Build</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">IP</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Subnet</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Gateway</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">DNS</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Timezone</font></th>'

write-host "collecting basic information about the host $hostname" -foregroundcolor green
#start of a new row
ac $winaudit "<TR>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$hostname</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$domain</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$OperatingSystem</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$activation</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Architecture</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Build</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$IP</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Subnet</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Gateway</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$DNS</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Timezone</font></p>"
ac $winaudit "</TD>"

#end of row
ac $winaudit "</TR>"

#Ending & fixing the position of the table
ac $winaudit "</TD></TR></table>"
ac $winaudit "</table><P>"
ac $winaudit "<br><br>"

#Section 2
Write-Host "Checking Windows Configuration"
ac $winaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="2"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section: Windows Configuration</b></p></font></td></tr></table>'
#main table
ac $winaudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="2"<TR><TD>'
#subtable
ac $winaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Ram</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Sockets</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Cores</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Users</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">DriveID</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Volumes</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Disksize[GB]</font></th>'

$Ram       = [string]::Join(", ",(gwmi -ComputerName $server -class win32_physicalmemory | ForEach-Object {[math]::truncate($_.capacity / 1GB)}))
$Sockets   = ((gwmi -ComputerName $server -class win32_processor).SocketDesignation).count
$Cores     = [string]::Join(", ",(gwmi -ComputerName $server -Class Win32_Processor).NumberOfCores)
$Users     = [string]::Join(", ",(gwmi -ComputerName $server -Class Win32_UserAccount).Name)
[array]$mdisks =gwmi win32_logicaldisk -computername $server | where DriveType -EQ 3
$Volumecount   = $mdisks.count

write-host "collecting basic configuration of the host $hostname" -foregroundcolor green
#start of a new row
ac $winaudit "<TR>"

ac $winaudit "<TD style='border:1px solid black' align=left rowspan=$Volumecount>"
ac $winaudit "<p><font color='#196aa5'>$hostname</font></p>"    
ac $winaudit "</TD>"                                        
                                                            
ac $winaudit "<TD style='border:1px solid black' align=left rowspan=$Volumecount>"
ac $winaudit "<p><font color='#196aa5'>$Ram</font></p>"     
ac $winaudit "</TD>"                                        
                                                            
ac $winaudit "<TD style='border:1px solid black' align=left rowspan=$Volumecount>"
ac $winaudit "<p><font color='#196aa5'>$Sockets</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left rowspan=$Volumecount>"
ac $winaudit "<p><font color='#196aa5'>$Cores</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left rowspan=$Volumecount>"
ac $winaudit "<p><font color='#196aa5'>$Users</font></p>"
ac $winaudit "</TD>"

foreach ($volume in $mdisks.VolumeName) 
{
$DriveID   = ($mdisks | where VolumeName -EQ $volume).DeviceID

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$DriveID</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Volume</font></p>"
ac $winaudit "</TD>"

$Disksize  = [math]::truncate(($mdisks | where VolumeName -EQ $volume).Size / 1GB)

ac $winaudit "<TD style='border:1px solid black' align=left>"
ac $winaudit "<p><font color='#196aa5'>$Disksize</font></p>"
ac $winaudit "</TD>"

#end of row
ac $winaudit "</TR>"
}

#Ending & fixing the position of the table
ac $winaudit "</TD></TR></table>"
ac $winaudit "</table><P>"
ac $winaudit "<br><br>"

#Section 3
Write-Host "checking Software"
ac $winaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="2"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section: Software</b></p></font></td></tr></table>'
#main table
ac $winaudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="2"<TR><TD>'
#subtable
ac $winaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
#colors from http://www.color-hex.com/
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Software</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Version</font></th>'
ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Vendor</font></th>'

$apps      = Get-WmiObject -ComputerName $server -Class Win32_Product | Sort-Object -Property Name
$count     = $apps.count

write-host "collecting the information about installed softwares in $hostname" -foregroundcolor green

#start of a new row
ac $winaudit "<TR>"

ac $winaudit "<TD style='border:1px solid black' align=left rowspan=$count>"
ac $winaudit "<p><font color='#196aa5'>$hostname</font></p>"    
ac $winaudit "</TD>"                                        

foreach ($Software in $apps) 
{
$Name     = $Software.Name
$Version  = $Software.Version
$Vendor   = $Software.Vendor
                                                            
ac $winaudit "<TD style='border:1px solid black' align=left >"
ac $winaudit "<p><font color='#196aa5'>$Name</font></p>"
ac $winaudit "</TD>"                                        
                                                            
ac $winaudit "<TD style='border:1px solid black' align=left >"
ac $winaudit "<p><font color='#196aa5'>$Version</font></p>"
ac $winaudit "</TD>"

ac $winaudit "<TD style='border:1px solid black' align=left >"
ac $winaudit "<p><font color='#196aa5'>$Vendor</font></p>"
ac $winaudit "</TD>"

#end of row
ac $winaudit "</TR>"
}

#Ending & fixing the position of the table
ac $winaudit "</TD></TR></table>"
ac $winaudit "</table><P>"
ac $winaudit "<br><br>"

#Section 4
Write-Host "checking ODBC"

$out = invoke-command -ComputerName $server -ScriptBlock {
(get-odbcdsn).Name
(get-odbcdsn).DsnType
(get-odbcdsn).Platform
(get-odbcdsn).DriverName
(get-odbcdsn).Attribute.Description
(get-odbcdsn).Attribute.Server
(get-odbcdsn).Attribute.Trusted_Connection
(get-odbcdsn).Attribute.Database
}

if ($out -ne $null)
     {      
      ac $winaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="2"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section: ODBC</b></p></font></td></tr></table>'
      #main table
      ac $winaudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="2"<TR><TD>'
      #subtable
      ac $winaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
      #colors from http://www.color-hex.com/
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Name</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">DsnType</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Platform</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">DriverName</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Description</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Server</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Trusted_Connection</font></th>'
      ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Database</font></th>'
      
      $Name               =$out[0]
      $DsnType            =$out[1]
      $Platform           =$out[2]
      $DriverName         =$out[3]
      $Description        =$out[4]
      $Server             =$out[5]
      $Trusted_Connection =$out[6]      
      $Database           =$out[7]

            write-host "collecting ODBC information of $hostname" -foregroundcolor green
            
            #start of a new row
            ac $winaudit "<TR>"
            
            ac $winaudit "<TD style='border:1px solid black' align=left>"
            ac $winaudit "<p><font color='#196aa5'>$Name</font></p>"    
            ac $winaudit "</TD>"                                        
                                                                        
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$DsnType</font></p>"
            ac $winaudit "</TD>"                                        
                                                                        
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$Platform</font></p>"
            ac $winaudit "</TD>"
            
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$DriverName</font></p>"
            ac $winaudit "</TD>"
            
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$Description</font></p>"
            ac $winaudit "</TD>"
            
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$Server</font></p>"
            ac $winaudit "</TD>"
            
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$Trusted_Connection</font></p>"
            ac $winaudit "</TD>"
            
            ac $winaudit "<TD style='border:1px solid black' align=left >"
            ac $winaudit "<p><font color='#196aa5'>$Database</font></p>"
            ac $winaudit "</TD>"
            
            #end of row
            ac $winaudit "</TR>"
            
            #Ending & fixing the position of the table
            ac $winaudit "</TD></TR></table>"
            ac $winaudit "</table><P>"
            ac $winaudit "<br><br>"
}
    #Section SQL
    Write-Host "Checking SQL"    
    if ($Description -like "*sql*")  
    {
    ac $winaudit '<table style="border:1px solid black" width=100% bgcolor="#00518c" cellspacing="0" cellpadding="2"><tr><td><font face="Bookman,Palatino,Century Gothic,Verdana,Tahoma" size="3" color="white"><p><b>Section: SQL</b></p></font></td></tr></table>'
    #main table
    ac $winaudit '<table style="border:1px solid black" width="100%" bgcolor="white" cellspacing="0" cellpadding="2"<TR><TD>'
    #subtable
    ac $winaudit '<table border="1px" width="100%" bgcolor="white" cellspacing="0" cellpadding="2">'
    #colors from http://www.color-hex.com/
    ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Computer</font></th>'
    ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Edition</font></th>'   
    ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">Version</font></th>'   
    ac $winaudit '<th style="border:1px solid black"><font face="Century Gothic,Verdana,Tahoma" color="black">NamedPipes</font></th>'   
       
    write-host "collecting information about SQL in $hostname" -foregroundcolor green
    $Version  = invoke-command -computername $server -scriptblock {
                $instance = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').((get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances)
                (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instance\Setup").Version}
    $Edition  = invoke-command -computername $server -scriptblock {
                $instance = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').((get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances)
                (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instance\Setup").Edition}
    $NamedPipes = invoke-command -computername $server -scriptblock {
    Import-Module sqlps
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
    $smo = 'Microsoft.SqlServer.Management.Smo.'  
    $wmi = new-object ($smo + 'Wmi.ManagedComputer') 
    $uri = "ManagedComputer[@Name='$env:computername']/ClientProtocol[@Name='np']"  
    $Np = $Wmi.GetSmoObject($uri)
    $Np.IsEnabled
    }

    #start of a new row
    ac $winaudit "<TR>"
    
    ac $winaudit "<TD style='border:1px solid black' align=left>"
    ac $winaudit "<p><font color='#196aa5'>$hostname</font></p>"    
    ac $winaudit "</TD>"                                        
                                                                
    ac $winaudit "<TD style='border:1px solid black' align=left >"
    ac $winaudit "<p><font color='#196aa5'>$Edition</font></p>"
    ac $winaudit "</TD>"     
    
    ac $winaudit "<TD style='border:1px solid black' align=left >"
    ac $winaudit "<p><font color='#196aa5'>$Version</font></p>"
    ac $winaudit "</TD>"     
    
    ac $winaudit "<TD style='border:1px solid black' align=left >"
    ac $winaudit "<p><font color='#196aa5'>$NamedPipes</font></p>"
    ac $winaudit "</TD>"                          
   
    #end of row
    ac $winaudit "</TR>"
    
    #Ending & fixing the position of the table
    ac $winaudit "</TD></TR></table>"
    ac $winaudit "</table><P>"
    ac $winaudit "<br><br>"
    }
}
$stopWatch.Stop()
Write-Host "Elapsed Runtime:" $stopWatch.Elapsed.Hours "Hours" $stopWatch.Elapsed.Minutes "minutes and" $stopWatch.Elapsed.Seconds "seconds." -BackgroundColor White -ForegroundColor Black
#open the report
ii $winaudit