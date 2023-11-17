# Script usage
# use powershell script for both hearthbeat and password changing.
# parameters to provide in each case are:
# Heartbeat: hb $userId $password $[1]$instance $apiKey 
# Password Change:  rpc $userId $password $[1]$instance $apiKey

[string]$action = $args[0]
[string]$userid = $args[1]
[string]$password = $args[2]
[string]$instance = $args[3]
[string]$apikey = $args[4]
#[string]$LogFile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\EntraID_rpc.log"
[string]$LogFile = "c:\temp\Okta_rpc.log"
[int32]$LogLevel = 3


# Uncomment the line below to enable TLS 1.2 if needed
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Auxilary Functions

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet(0,1,2,3)]
        [Int32]$ErrorLevel,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Message
    )
    # Evaluate Log Level based on global configuration
    if ($ErrorLevel -le $LogLevel) {
        # Format message
        [string]$Timestamp = Get-Date -Format "yyyy-MM-ddThh:mm:sszzz"
        switch ($ErrorLevel) {
            "0" { [string]$MessageLevel = "INF0 " }
            "1" { [string]$MessageLevel = "WARN " }
            "2" { [string]$MessageLevel = "ERROR" }
            "3" { [string]$MessageLevel = "DEBUG" }
        }
        # Write Log data
        $MessageString = "{0}`t| {1}`t| {2}" -f $Timestamp, $MessageLevel, $Message
        $MessageString | Out-File -FilePath $LogFile -Encoding utf8 -Append -ErrorAction SilentlyContinue
       
    }
}
#endregion

#region Variable ckleanup
if ($response) {
    Remove-Variable response
}
if ($result) {
    Remove-Variable result
}
#endregion

#region Check if variables are actually set
# Check if variables are actually set
# If needed variables are not set, the script will stop
Write-Log -Errorlevel 0 -Message "Checking variable setting"
# If needed variables are not set, the script will stop
Write-Log -Errorlevel 0 -Message "Checking variable setting"
if (!$userid -or !$password -or !$instance -or !$apikey) {
    # If variables are not set, the script will stop
    Write-Log -Errorlevel 0 -Message "One or more variables are not set"
    throw "One or more variables are not set"
}
#endregion

#region Check associated Secret
# If instance or any other variable contains $[1] the script will stop
if ($instance -like '$[1]*' -or $apikey -like '$[1]*' -or $username -like '$*' -or $password -like '$*') {
    Write-Log -Errorlevel 0 -Message "Incorrect Associated Secret Defined. Check RPC Configuration of Secret"
    throw "Incorrect Associated Secret Defined. Check RPC Configuration of Secret"
}
#endregion

#region Create Headers 
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "SSWS $apikey")

#endregion

#region RPC and HB Functions
    function invoke-RPC {
        try {
            #Create Payload with Current password
            $body = @{
            "credentials" = @{
                "password" = @{ "value" = $password }
            }
            } | ConvertTo-Json -Depth 3 
    
        
            $url = "https://$instance/api/v1/users/$userid"
            Write-Log -Errorlevel 0 -Message "Attempting Password change"
            Invoke-RestMethod -Uri $url -Method 'PUT' -Headers $headers -Body $body | Out-Null
            } catch {
                $message = "Remote Password Change Exception $_"
                Write-Log -Errorlevel 2 -Message $message
                throw $message
            }
        Write-Log -Errorlevel 0 -Message "Password Successfully Changed"    
        $return = "Password Successfully Changed"
        return $return    
        }

    function Invoke-HB{
    try {
        #Create Body with Current Password
        $body = @{
                    "username" = $userid
                    "password" = $password
                    "option" =       @{
                    "multiOptionalFactorEnroll" = $true
                    "warnBeforePasswordExpired" =$true
                    }
                } | ConvertTo-Json -Depth 3
        
        
            #Create API enpoint
            $url = "https://$instance/api/v1/authn"
            
            #Invoke RPC Request

            Write-Log -Errorlevel 0 -Message "Validating Username and Password"
            $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"
            
            #extract Result to berify Password
            $verify = $response.status
            if ( $verify -eq "SUCCESS")
                {

                    $result = "Password is Valid"
                    Write-Log -Errorlevel 0 -Message "Credentials are Valid"
                }

        } 
        catch {
            Write-Log -Errorlevel 1 -Message "Invoke-HB function Failed ofr unhandled Exception $_"    
            throw  "Invoke-HB function Failed Invalid Username or Password $_ " 
            }
        return $result
    }

 
#endregion

#region Main Process
if ($action -eq 'hb') {
    $result = Invoke-HB
}
elseif ($action -eq 'rpc') {
    $result =  Invoke-RPC
}
return $result
#endregion


