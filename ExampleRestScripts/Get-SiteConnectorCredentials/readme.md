# Get-SiteConnectorCredentials.ps1 

This example function will connect to secret server and retrieve the site connector credentials for a specified site connector.

## Usage

`Get-SiteConnectorCredentials -SecretServerURL "https://alpha/SecretServer/" -siteConnectorName "RMQ W/TLS" -credentials (Get-Credential)`

`Get-SiteConnectorCredentials -SecretServerURL "https://alpha/SecretServer/"  -siteConnectorName "RMQ W/TLS" -APIToken (Read-Host "please input API token value")`
