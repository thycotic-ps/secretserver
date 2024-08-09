function new-DelineaPlatformSession {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [uri] $platformURL, 
        [Parameter(Mandatory = $true)]
        [PSCredential]$Credentials,
        [Parameter()]
        [switch]$unsafe
    ) 
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/x-www-form-urlencoded")
    if ($platformURL.scheme -ne "https") {
        switch ($platformURL.Scheme) {
            $null { [uri]$platformURL = "https://" + $platformURL }
            Default { if($unsafe){}else{Write-Warning ($platformurl.OriginalString + ' not https:// rewriting, use -unsafe switch to avoid'); [uri]$platformURL = [Uri]::new($platformURL.ToString() -replace ('.*://', 'https://')) }}
        }
        Write-Verbose "Platform URL updated to $platformurl"
    }
    $body = @{
        "client_secret" = $credentials.GetNetworkCredential().Password 
        "client_id"     = $credentials.UserName
        "grant_type"    = "client_credentials" 
        "scope"         = "xpmheadless" 
    }
    try {
        $token = (Invoke-RestMethod "$platformURL/identity/api/oauth2/token/xpmplatform" -Method 'POST' -Headers $headers -Body $body ).access_token
        Remove-Variable body
        $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $Headers.add("authorization", "Bearer " + $token)
        $secretServerURL = (Invoke-RestMethod "$platformURL/vaultbroker/api/vaults" -Method get -Headers $headers -Body $body ).vaults[0].connection.url
        $ssUser = (Invoke-WebRequest -UseBasicParsing -Uri "$secretServerURL/api/v1/users/current" -Headers $headers).content | ConvertFrom-Json
        $platUser = (Invoke-RestMethod "$platformURL/identity/UserMgmt/GetUserInfo" -Method get -Headers $headers -Body $body).result | Select-Object -Property Name, displayname, emailaddress, id

        Write-Verbose "Authenticated to $platformURL | $secretServerURL as"
        Write-Verbose ("Platform User: {0} id ({1}) | Secret Server User: {2} id ({3})" -f $platUser.Name, $platUser.id, $ssUser.userName, $ssuser.id)
    }
    catch {
        Write-Error ("Error connecting to $platformURL as " + $credentials.UserName)
        Write-Error $_
    }
if ($null -eq $headers.authorization ){throw "failed to authenticate"}else{return $headers}
}
