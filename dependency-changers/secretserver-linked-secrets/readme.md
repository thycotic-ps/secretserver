# Introduction

This solution is used to change multiple secrets to the same password as a Primary account.   If you have a set of accounts that need to share the same password this solution will help accomplish that.


## Prerequisites

- A Secret Server instance version 10.1.0 or newer with a premium add-on or Enterprise Plus
- A PowerShell implementation enabled and working properly on the Distributed Engines. 
    - See Configuring WinRM for PowerShell - [https://docs.delinea.com/online-help/secret-server/api-scripting/configuring-winrm-powershell/index.htm](https://docs.delinea.com/online-help/secret-server/api-scripting/scripting/powershell-scripts/powershell-winrm/configuring-winrm-powershell/index.htm)
- Download and run WellnessChecker tool on the Distributed Engines
    - http://updates.thycotic.net/tools/powershell.wellnesschecker.zip
- Create the user accounts and secrets described below.
    - An API User account and a corresponding secret. This API User account will NOT take up a user license. Recommended templates for the secret include the Active Directory template and the Web Password template. Credentials may be a local account or an Active Directory service account assigned to the Synchronization group, but must be stored in Secret Server to be passed to the PowerShell script.
    - A primary parent account and a corresponding secret that has RPC set up and the PowerShell dependency script from this page attached. The primary parent account credentials may be either a local account or an Active Directory service account assigned to the Synchronization group.
    - Child accounts with a corresponding secret for each account containing the child secret ID, with edit permissions granted to the API User account.
    - A privileged Active Directory account and a corresponding secret that can run PowerShell on the Secret Server machine.
- Download script form Thycotic github
    - https://github.com/thycotic-ps/secretserver/blob/main/dependency-changers/secretserver-linked-secrets/linkedSecretsDependency.ps1
- Update linkedDependency.ps1 script
    - Update line 6 to reflect the URL of your Secret Server Instance

## Setup

## WellnessChecker
1. Download exe to Distributed Engines
1.  Extract the ZIP file and run this command
    `` PowerShell.WellnessChecker.exe -fixerrors ``

## Configure Site
1. Navigate to **Admin > Distributed Engine**
1. Click name of Site (ex. Default)
1. Under Advanced Site Configuration, click Edit 
1. Update **Default PowerShell RunAs Secret**
    1. Select secret that has permission to execute PowerShell scripts on the Distributed Engine.

### Create Script

Navigate to **Admin | Scripts** and create a script for the Dependency Changer using the details below.


| ------------| --------------------------------------------------------------------------------|
| Field       | Value                                                                           |
| ----------- | --------------------------------------------------------------------------------|
| Name        | Linked Secret Dependency                                                        |
| Description | Script for Linked Secret Dependency                                             |
| Active      | Check the box                                                                   |
| Script Type | PowerShell                                                                      |
| Category    | Dependency                                                                      |
| Script      | Paste contents of the [linkedSecretDependency.ps1](linkedSecretDependency.ps1)  |
| ----------- | --------------------------------------------------------------------------------|

### Enable WebServices

1. Browse to **Admin > Configuration**
1. On the **General** tab, make sure **Enable WebServices** is set to **Yes** 

### Extensible Discovery

1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Extensible Discovery** from the drop-down list.
1. On the **Extensible Discovery Configuration** page, click **Configure Dependency Changers**.
1. On the **Secret Dependency Changers** page, click **Create New Dependency Changer**.
1. In the **New Dependency Changer** dialog, click the **Basic** tab and enter the following information.

| ------------------| ------------------------------------------------------------------------------- |
| Field             | Value                                                                           |
| ------------------| --------------------------------------------------------------------------------|
| Type              | Linked Secret Dependency                                                        |
| Scan Template     | Computer Dependency (Basic)                                                     |
| Name              | Linked Secret Dependency                                                        |
| Description       | Leave Blank                                                                     |
| Port              | Leave Blank                                                                     |
| Wait              | 0                                                                               |
| Enabled           | Checked                                                                         |
| Create Template   | Checked                                                                         |
| ------------------| ------------------------------------------------------------------------------- |

1. Click the Scripts tab and enter the following information.

| ------------------| ------------------------------------------------------------------------------- |
| Field             | Value                                                                           |
| ------------------| --------------------------------------------------------------------------------|
| Script            | Linked Secret Dependency                                                        |
| Arguments         | $[1]$USERNAME $[1]$PASSWORD $PASSWORD $NOTES $[1]$DOMAIN                        |
| ------------------| ------------------------------------------------------------------------------- |



### Configure Primary Parent Account

1. Browse to the primary parent account secret.
1. Click Remote Password Changing tab
    1. Change Password Using
        1. Privileged Account Credentials
    1. Privileged Account
        1. select an account than update password for this account
    1. Associated Secrets
        1. Add API account Secret 
1. Click Dependencies tab
    1. Click New Dependency
    1. In the **Create Dependency** dialog, click the **Select Type** dropdown and select the PowerShell dependency template you created **Linked Secret Dependency**.

| ----------------------| ------------------------------------------------------------------------------- |
| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Type                  | Linked Secret Dependency                                                        |
| Dependency Group      | Create New Group                                                                |
| New Group Name        | Linked Secrets                                                                  |
| New Group Site Name   | Leave Blank                                                                     |
| ServiceName           | Leave Blank                                                                     |
| Description           | 0                                                                               |
| Change Script         | Linked Secrets Dependency                                                       |
| Enabled               | Un-checked                                                                      |
| Run As                | unset                                                                           |
| Wait                  | 0                                                                               |
| Machine Name          | Default                                                                         |
| ----------------------| ------------------------------------------------------------------------------- |

1. Browse to **Overview** tab
1. In the primary parent account secret's Notes field, ensure that the child secret IDs appear in a comma-separated-values list.  (ex.19,39,81...)

Now the dependency has been added and you can test the full process by running a remote password change on the primary parent account. All of the secrets listed by ID in the Notes field should be updated with the same password.

