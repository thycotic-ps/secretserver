$args = @("https://gpepperlab.secretservercloud.com","localuser",".Lycos09@@@@@")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ServerURL = $args[0] + '/oauth2/token'
$Username = $args[1]
$Password = $args[2]

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
    Invoke-RestMethod $ServerURL -Method 'POST' -Headers $headers -Body $body | Select-Object -ExpandProperty access_token
    if ($debug) {(get-date).ToString(), "Connected to API with Account $Username : ", ($serverurl + '/oauth2/token') -join "`t" | Out-File -FilePath $errorfile -Append}
}catch 
{
    write-error "Error logging into server $serverurl with account $APIUser : $_" 
    if ($debug) {(get-date).ToString(), "Bad login attempt: ",($serverurl + '/oauth2/token'),  $body, $_ -join "`t" | Out-File -FilePath $errorfile -Append}
    return
}