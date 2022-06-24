#this is a REST based replacement for the SOAP script at the bottom of 
#https://docs.delinea.com/secrets/current/remote-password-changing/sync-passwords-during-rpc/index.md

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ServerURL = "https://SecretServerBasePath/"

$APIUser = $args[0]
$APIUserPassword = $args[1]
$SecretPassword = $args[2]
$SecretList = $Args[3].split(",")
$APIUserDomain = $args[4]

#if you need more verbose errors change this to $true and make sure the file path exists
$debug = $true
$errorfile = "c:\temp\secretDependencyUpdateFailures.csv"

if ($debug) {(get-date).ToString(), "`nPassword Masking Key A = A-Z UPPERCASE / z = a-z lowercase / N = Any digit / ? = Anything else`n", ("Arguments: " + $args.count),(@{
    "APIUser" = $args[0]
    "APIUserPass (masked)" = $args[1]  -Creplace "[A-Z]","A" -Creplace "[a-z]","z" -Creplace "[0-9]","N" -Creplace "\W","?"
    "SecretPassword (masked)" = $args[2]  -Creplace "[A-Z]","A" -Creplace "[a-z]","z" -Creplace "[0-9]","N" -Creplace "\W","?"
    "SecretList" = $args[3].split(",")
    "APIUserDomain" = $args[4]
}|convertto-json) -join "`t" | Out-File -FilePath $errorfile -Append}

if ($null -eq $APIUserDomain -or $APIUserDomain -eq "local")
{
    $creds = @{
        username = $APIUser
        password = $APIUserPassword
        grant_type = "password"
    }
}else{
    $creds = @{
        username = $APIUserDomain, $APIUser -join "\"
        password = $APIUserPassword
        grant_type = "password"
    }
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

try 
{
    $APIToken = Invoke-RestMethod ($serverurl + 'oauth2/token') -Method 'POST' -Headers $headers -Body $creds | Select-Object -ExpandProperty access_token
    if ($debug) {(get-date).ToString(), "Connected to API: ", ($serverurl + 'oauth2/token') -join "`t" | Out-File -FilePath $errorfile -Append}
}catch 
{
    write-error "Error logging into server $serverurl : $_" 
    if ($debug) {(get-date).ToString(), "Bad login attempt: ",($serverurl + 'oauth2/token'),  $body, $_ -join "`t" | Out-File -FilePath $errorfile -Append}
    return
}

$headers.Add("Authorization", "Bearer " + $APIToken)
$body = @{ "newPassword" = $SecretPassword}
[array]$errorlist = @()
foreach ($SecretID in $SecretList){
    try 
    {
        Invoke-RestMethod ( $ServerURL + 'api/v1/secrets/' + $SecretID + '/change-password') -Method 'POST' -Headers $headers -Body ($body|convertto-json) | Out-Null
        if ($debug) {(get-date).ToString(), "SecretID: $secretid", "Updated Without Error" -join "`t" | Out-File -FilePath $errorfile -Append}
    }catch{
        $errorlist += $secretid
        if ($debug) {(get-date).ToString(), "SecretID: $secretid", ($_.ErrorDetails) -join "`t" | Out-File -FilePath $errorfile -Append}
    }
}
if ($errorlist.count -gt 0){Write-Error ("error setting password on secret id(s): " + $errorlist)}
