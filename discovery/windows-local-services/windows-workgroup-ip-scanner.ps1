#Global Variables for Logging
$debug = $false
$errorfile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Windows Workgroup IP Scanner.log"
#Setting this variable to $true ignores all Active Directory Domain Memebers
$workGroupOnly = $true

$container = $args[0]
$username = $args[1]
$password = $args[2]
if ($false -eq $workGroupOnly) {
    $domain = $args[3]
}


if ($debug) {
        (get-date).ToString() + "   Arguments: $container, $Username  `t" | Out-File -FilePath $errorfile -Append
        write-debug "Arguments: $container, $Username"
}


#IPRangeLookup
# parse out the range from the container args
$ranges = $container.Substring($container.IndexOf('=') + 1,($container.Length - $container.IndexOf('='))-1)


$targetMachines = $null


if ($debug) {
    (get-date).ToString() + "   Strating...  `t" | Out-File -FilePath $errorfile -Append
    write-debug "Starting..."
}

function Is-LocalIP {
   param(
       [string]$targetIp,
       [string[]]$localIps
   )

   Foreach ($ip in $localIps) {  
            
            if ($ip -eq $targetIp) { 
                    "Yes it's here: " 
                    return $true
                }
        }  
}

function Is-ValidIP {
  param(
       [string]$containerName
   )

    return [bool]($containerName -as [ipaddress])
}

function Is-ValidRange {
  param(
       [string]$containerName
   )
   if ($containerName -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}[-].[0-9]{1,3}$") 
   {
        return $true;
   }
}

function Get-IpAddressesFromRange {
    param(
       [string]$containerName
    )
    try {
        $ipAddresses = @() 
        $ipAddresses = @() 
        $parts = $containerName.Split("-");
        $baseIpParts = $parts[0].Split(".")
        $baseIp = "$($baseIpParts[0]).$($baseIpParts[1]).$($baseIpParts[2])"
        $start = [convert]::ToInt32($baseIpParts[3], 10)
        $end = [convert]::ToInt32($parts[1], 10)
        
 
        for ($i = $start; $i -le $end; $i++) 
        { 
           $ipAddresses += "$baseIp.$i"
        }
        return $ipAddresses

    }
    catch {
        write-debug ("Error occured generating IP Addresses: `n{0}" -f $_.Exception.ToString())
    }
}

function IsIpAddressInOtherRanges {
param(
    [string] $ipAddress
    )

    foreach ($range in $ranges) {
        $parts = $range.Split("-")
        $start = $parts[0]
        $baseIpParts = $parts[0].Split(".")
        $end =  "$($baseIpParts[0]).$($baseIpParts[1]).$($baseIpParts[2]).$($parts[1])"
        if (IsIpAddressInRange $ipAddress $start $end) {
            return $true;
        }
    }
    return $false;
}

function IsIpAddressInRange {
param(
        [string] $ipAddress,
        [string] $fromAddress,
        [string] $toAddress
    )

    $ip = [system.net.ipaddress]::Parse($ipAddress).GetAddressBytes()
    [array]::Reverse($ip)
    $ip = [system.BitConverter]::ToUInt32($ip, 0)

    $from = [system.net.ipaddress]::Parse($fromAddress).GetAddressBytes()
    [array]::Reverse($from)
    $from = [system.BitConverter]::ToUInt32($from, 0)

    $to = [system.net.ipaddress]::Parse($toAddress).GetAddressBytes()
    [array]::Reverse($to)
    $to = [system.BitConverter]::ToUInt32($to, 0)

    $from -le $ip -and $ip -le $to
}



$isContainerIpAddress = $false
$targetMachines = @()
$containerIp = $container.Replace("OU=","")
#Check to see if it's a Single IP address
if (Is-ValidIP -containerName $containerIp) {
    
    if ($debug) {
        (get-date).ToString() + "   Valid IP `t" | Out-File -FilePath $errorfile -Append
         write-debug "Valid IP"
    }
    $targetMachines += $containerIp
    $isContainerIpAddress = $true
}

#Check to see if it's a IP Range 
if (Is-ValidRange -containerName $containerIp) {
    if ($debug) {
        (get-date).ToString() + "   Valid Range `t" | Out-File -FilePath $errorfile -Append
        write-debug "Valid Range"
    }
    $targetMachines = Get-IpAddressesFromRange -containerName $containerIp
    $isContainerIpAddress = $true

}

#Get Local IPs off the Distributed Engine
if ($debug) {
    (get-date).ToString() + "   Getting local IP's.. `t" | Out-File -FilePath $errorfile -Append
    write-debug "Getting local IP's.."
}

$FoundComputers = @()

#Loop through List of IPs/Names
foreach ($target in $targetMachines)
{
    if ($debug) {
        (get-date).ToString() + "   Scanning targets...  $target `t" | Out-File -FilePath $errorfile -Append
        write-debug "Scanning target.."
        write-debug $target
    }

    $comp = $null
    #If Cotaniner is IP address
    if ($isContainerIpAddress) {  
        
        if ($debug) {
            (get-date).ToString() + "   Testing IP's `t" | Out-File -FilePath $errorfile -Append
            write-debug "Testing IP's"
        }
        #Send a ICMP Ping request to IP address
        if ((test-connection $target –count 1 -quiet)) {
                #If IP responses
                if ($debug) {
                    (get-date).ToString() + "   Found Target - $target `t" | Out-File -FilePath $errorfile -Append
                    write-debug "found target - $target"
                }
               
                try
                {
                    $isDomainMachine = $false
                    #Create Powershell Credential based on Arguments passed into script
                    $Spassword = ConvertTo-SecureString "$password" -AsPlainText -Force #Secure PW
                    if ($workGroupOnly) {
                        $cred = New-Object System.Management.Automation.PSCredential ("$username", $Spassword) #Set credentials for PSCredential logon
                    } else {
                        $cred = New-Object System.Management.Automation.PSCredential ("$domain\$username", $Spassword) #Set credentials for PSCredential logon
                    }

            
                    #Query Non-DE for Information
                    $comp = Get-WmiObject Win32_ComputerSystem -ComputerName $target -Credential $cred
                    $osInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $target -Credential $cred -ErrorAction SilentlyContinue
                    $GUID = Get-WmiObject Win32_ComputerSystemProduct -ComputerName $target -Credential $cred -ErrorAction SilentlyContinue
                    if ($debug) {
                        (get-date).ToString() + "  Found - " + ($comp).Name + "`t" | Out-File -FilePath $errorfile -Append
                        (get-date).ToString() + "  Domain Role - " + ($comp).domainrole + "`t" | Out-File -FilePath $errorfile -Append
                    }
                    #Check to see if this is a Domain Registered Machine.   1 = Member Workstation 3 = Member Server  4 = Backup Domain Controller 5 = Primary Domain Controller
                    $isDomainMachine = (($comp).domainrole -in $null,1,3,4,5)
            
                    #Setting values to Null if IP is a Domain Member. Only looking for Workgroup devices.
                    if (($isDomainMachine) -and ($true -eq $workGroupOnly))
                    {
                        if ($debug) {
                            (get-date).ToString() + "   Discarding Domain Machine $target `t" | Out-File -FilePath $errorfile -Append
                            write-debug "Discarding Domain Machine $target"
                        }
                        $osInfo = $null
                        $comp = $null
                        $GUID = $null
                    }
                }
                catch
                {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName 
                    if ($debug) {
                        (get-date).ToString() + "Failed to Query $target - $ErrorMessage `t" | Out-File -FilePath $errorfile -Append
                        write-debug "Failed to Query $target - $ErrorMessage"
                    }
                }
        }
        else {
            
            continue
        }
    }
    
    #If ICMP was successfull but the Querying of Device Failed we ignore those IPs
    if ($null -ne $comp.Name) {

        #Create Object to return to Scanner Template
        $object = New-Object –TypeName PSObject;
        $object | Add-Member -MemberType NoteProperty -Name Machine -Value $comp.Name;
        $object | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $osInfo.Caption;
        $object | Add-Member -MemberType NoteProperty -Name DNSHostName -Value $comp.DNSHostName;
        $object | Add-Member -MemberType NoteProperty -Name ADGUID -Value $GUID.UUID;
        $object | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value "CN=$($comp.Name),$container"
        $object | Add-Member -MemberType NoteProperty -Name IP -Value $target
        $FoundComputers += $object
        if ($debug) {
            ("Machine : " + $object.Machine) | Out-File -FilePath $errorfile -Append
            ("OS - " + $object.OperatingSystem) | Out-File -FilePath $errorfile -Append
            ("DNSHostName - " + $object.DNSHostName) | Out-File -FilePath $errorfile -Append
            ("ADGUID - " + $object.ADGUID) | Out-File -FilePath $errorfile -Append
            ("DistinguishedName - " + $object.DistinguishedName) | Out-File -FilePath $errorfile -Append
            ("IPAdress - " + $object.IP) | Out-File -FilePath $errorfile -Append
            write-debug ("Found Machine - {0}" -f $object.ComputerName)
        }

        $object = $null
        
    } else {
        if ($debug) {
            (get-date).ToString() + "   Discarding due to lack of information $target `t" | Out-File -FilePath $errorfile -Append
            write-debug "Discarding due to loack of infomation  $target"
        }
    }

}

write-debug "Finished.."
if ($debug) {
    
    (get-date).ToString() + "   # Computers Found " + $FoundComputers.Count + " `t" | Out-File -FilePath $errorfile -Append
    $FoundComputers | ConvertTo-Json | Out-File -FilePath $errorfile -Append
}


return $FoundComputers