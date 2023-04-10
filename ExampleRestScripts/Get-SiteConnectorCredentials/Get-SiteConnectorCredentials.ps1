function Get-SiteConnectorCredentials { 
    param(
        [parameter (Mandatory, ParameterSetName = "basicAuth", position = 0)]
        [parameter (Mandatory, ParameterSetName = "Token", position = 0)]
        [uri]
        $SecretServerURL, 
        [parameter (Mandatory, ParameterSetName = "basicAuth", position = 1)]
        [parameter (Mandatory, ParameterSetName = "Token", position = 1)]
        [string]
        $siteConnectorName,
        [parameter (Mandatory, ParameterSetName = "basicAuth", position = 2)]
        [pscredential]
        $credentials,
        [Parameter(Mandatory, ParameterSetName = 'Token', position = 2 )]
        [string] $APIToken
    )

    if ($APIToken -eq "") {
        $credobject = @{username = $Credentials.UserName ; password = [Net.NetworkCredential]::new('', $Credentials.Password).Password ; grant_type = "password" }
        $APIToken = (Invoke-RestMethod "$SecretServerURL/oauth2/token" -Method Post -Body $credobject ).access_token
    }
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $APIToken")

    $siteconnectors = Invoke-RestMethod "$SecretServerURL/api/v1/configuration/site-connector" -Method get -Headers $headers

    $ConnectorID = ($siteConnectors | Where-Object { $_.siteconnectorname -eq $siteConnectorName }).siteconnectorid 

    $SiteConnectorCreds = (Invoke-RestMethod "$SecretServerURL/api/v1/distributed-engine/site-connector/$connectorid/credentials" -Method get -Headers $headers -Verbose)
    return (New-Object System.Management.Automation.PSCredential ($SiteConnectorCreds.userName, (ConvertTo-SecureString $SiteConnectorCreds.Password -AsPlainText -Force)))
}
