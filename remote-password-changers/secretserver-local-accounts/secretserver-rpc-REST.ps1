[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$authServerURL = $args[0] + '/oauth2/token'
$apiServerURL = $args[0] + '/api/v1'
$Username = $args[1]
$Password = $args[2]
$newPassword = $args[3]

#if you need more verbose errors change this to $true and make sure the file path exists
$debug = $false
$errorfile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Secret Server Local Accounts Heartbeat.log"

$body = @{
        username = $Username
        password = $Password
        grant_type = "password"
    }

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")

try 
{
    $token = Invoke-RestMethod $authServerURL -Method 'POST' -Headers $headers -Body $body | Select-Object -ExpandProperty access_token
    if ($debug) {(get-date).ToString(), "Connected to API: ", $authServerUrl -join "`t" | Out-File -FilePath $errorfile -Append}
}catch 
{
    write-error "Error logging into server $serverurl with account $APIUser : $_" 
    if ($debug) {(get-date).ToString(), "Bad login attempt: ",($authServerUrl + '/oauth2/token'),  $body, $_ -join "`t" | Out-File -FilePath $errorfile -Append}
    return
}

$headers.Add("Authorization", "Bearer " + $Token)
$body = @{ 
    "newPassword" = $newPassword
    "currentPassword" = $password
}

try 
    {
        Invoke-RestMethod ( $apiServerURL + '/users/change-password') -Method 'POST' -Headers $headers -Body ($body|convertto-json) | Out-Null
        if ($debug) {(get-date).ToString(), "Updating User Password: $Username", "Updated Without Error" -join "`t" | Out-File -FilePath $errorfile -Append}
    }catch{
        if ($debug) {(get-date).ToString(), "SecretID: $secretid", ($_.ErrorDetails) -join "`t" | Out-File -FilePath $errorfile -Append}
    }