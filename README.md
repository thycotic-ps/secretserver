# Secret Server Scripts

> **Note:** Many scripts from this repository have been migrated to the official Delinea platform repository. See below for details.

## Active Content

The following scripts in this repository are **not available on the official platform** and remain active here:

### Dependency Changers
`idera-sqldm`, `iis-physical-path`, `managedengine-ncm`, `rapid7`, `secretserver-linked-secrets`, `sqlcredential`, `sqlservice-norestart`, `sqlssisdb`, `ssrs`, `tableau-service`, `veeam`, `windows-restart`

### Discovery
`active-directory-attributes`, `cisco-ios`, `cisco-ise-internaluser`, `fortigate-scanner`, `iis-physical-path-credentials`, `mixed-domain-scanner`, `windows-ip-scanner`, `windows-local-services`

### Event Pipelines
`checkout-timewindow`, `enhanced-personal-folders`, `radius-user-sync`, `sync-secrets`, `ticket-validation`, `update-priv-pipeline-acct`

### Launchers
`azure-microsoft365`, `chrome`, `couchbase`, `firefox`, `heidi-sql`, `ibm-acs`, `ibm-as400-tn5250`, `ldp`, `netuse`, `powershell-enter-pssession`, `putty-x11-forwarding`, `putty-x11-xming`, `rd-tabs`, `rdp-restricted-admin`, `zoc`

### Remote Password Changers
`cassandra-accounts`, `cisco-ios-expressway`, `couchbase-accounts`, `dell-idrac-ssh`, `dzdo-ssh-changer`, `oraclecloud-local-accounts`, `synology-ssh`, `windows-local-accounts`

### Reports
All SQL reports remain in `reports/`

### Example REST Scripts
All examples remain in `ExampleRestScripts/`

## Migrated Content

Items that have been migrated to the official platform are in the [`Archived/`](Archived/) directory. Their canonical home is now:

- **[DelineaXPM/delinea-platform/Scripts/SecretServer](https://github.com/DelineaXPM/delinea-platform/tree/main/Scripts/SecretServer)** — Official Delinea platform integrations

| Archived Item | Official Location |
|--------------|-------------------|
| `dependency-changers/autologon-dependency` | `Microsoft/Autologon/Dependency` |
| `dependency-changers/solarwinds-dependency` | `Solarwinds/DPA/Dependency` |
| `discovery/autologon-account` | `Microsoft/Autologon/Discovery` |
| `discovery/azure-tenant` | `EntraId/Discovery` |
| `discovery/sql-login-account` | `Microsoft/SQL Server/Discovery` |
| `launchers/active-directory-users-computers` | `Microsoft/Active Directory Users and Computers` |
| `launchers/filezilla` | `FileZilla/Launchers` |
| `launchers/kitty` | `Kitty/Launchers` |
| `launchers/moba-x-term` | `MobaXterm/Launchers` |
| `launchers/secure-crt` | `SecureCRT/Launchers` |
| `launchers/sql-plus` | `SQL Plus/Launchers` |
| `launchers/ssms` | `Microsoft/SQL Server/Launchers` |
| `launchers/toad` | `TOAD/Launchers` |
| `launchers/ultravnc` | `UltraVNC/Launchers` |
| `launchers/winscp` | `WinSCP/Launchers` |
| `remote-password-changers/Okta` | `Okta/Remote Password Changing` |
| `remote-password-changers/entraid-azuread-with-mfa` | `EntraId/Remote Password Changer` |
| `remote-password-changers/secretserver-local-accounts` | `Delinea/SecretServer Local Account` |
| `remote-password-changers/servicenow-local-accounts` | `ServiceNow/Remote Password Changer` |

## Disclaimer

The content (scripts, documentation, examples) included in this repository are provided as-is and do not provide any warranty or support.

The entire risk arising out of the code and content's use or performance remains **with you**. In no event shall maintainers, authors, or anyone else involved in the creation, production, or delivery of the content be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the code or content.
