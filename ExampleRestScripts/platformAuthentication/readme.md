# New-DelineaPlatformSession
## Description
  Autenticates to the delinea platform and returns a webservices authorization token
## Syntax
```
New-DelineaPlatformSession
  [-platformURL] <uri>
  [-Credentials] <pscredential>
  [-unsafe]
  [<CommonParameters>]
```
## Usage
**PlatfrormURL:** This is the base URL for your platform instance

**Credentials:** Credential object containing your service users authentication

**Unsafe:** allows for non https urls if ever needed

**verbose** Outputs logging information

## Notes
* detects underlying secret server url from first assocaited vault
* will not autneticate a Platform user, only Platform Service Users
