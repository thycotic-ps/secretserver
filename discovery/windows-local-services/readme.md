# Introduction

The purpose of this solution is help discover services running as local server accounts in a Windows Workgroup.  It has also been tested to work in a Windows Domain environment as well but it will not work in a mixed environment.  If you have the need to discover these Service account in both a Workgroup and Domain Members you will need to setup two different scanners.


## Prerequisites

- A Secret Server instance version 10.1.0 or newer with a Professional add-on or Platinum License
- A PowerShell implementation enabled and working properly on the Distributed Engines. 
    - See Configuring WinRM for PowerShell - https://docs.delinea.com/online-help/secret-server/api-scripting/configuring-winrm-powershell/index.htm
- Download and run WellnessChecker tool on the Distributed Engines
    - http://updates.thycotic.net/tools/powershell.wellnesschecker.zip
- Create the user accounts and secrets described below.
    - An API User account and a corresponding secret. This API User account will NOT take up a user license. Recommended templates for the secret include the Active Directory template and the Web Password template. Credentials may be a local account or an Active Directory service account assigned to the Synchronization group, but must be stored in Secret Server to be passed to the PowerShell script.
    - A secret to run the Powershell script on the Distributed Engine.  Typically this account is a administrator on your Distributed Engine servers.
    - A secret that has administrator access to servers/workstations.  This account needs to be the same for all your devices. 
- Download the following scripts form Thycotic github
    - https://github.com/thycotic-ps/secretserver/blob/main/discovery/windows-local-services/localservice-discovery-workgroup.ps1
    - https://github.com/thycotic-ps/secretserver/blob/main/discovery/windows-local-services/windows-workgroup-ip-scanner.ps1

## Setup

## WellnessChecker
1. Download exe to Distributed Engines
1.  Extract the ZIP file and run this command
    `` PowerShell.WellnessChecker.exe -fixerrors ``

### Create Script

Navigate to **Admin | Scripts** and create a script for the workgroup IP scanner using the details below.

| Field       | Value                                                                                       |
| ----------- | --------------------------------------------------------------------------------------------|
| Name        | Windows Workgroup IP Scanner                                                                |
| Description | Script for scanning Windows machine via IP range                                            |
| Active      | Check the box                                                                               |
| Script Type | PowerShell                                                                                  |
| Category    | Discovery Scanner                                                                           |
| Script      | Paste contents of the [windows-workgroup-ip-scanner.ps1](windows-workgroup-ip-scanner.ps1)  |

Navigate to **Admin | Scripts** and create a script for the local account service discovery using the details below.


| Field       | Value                                                                                       |
| ----------- | --------------------------------------------------------------------------------------------|
| Name        | Windows Service Local Account                                                               |
| Description | Script finding Windows Service running as non-domain accounts                               |
| Active      | Check the box                                                                               |
| Script Type | PowerShell                                                                                  |
| Category    | Dependency                                                                                  |
| Script      | Paste contents of the [windows-workgroup-ip-scanner.ps1](windows-workgroup-ip-scanner.ps1)  |


### Scanner Templates

1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Scanner Definition** from the drop-down list.
1. Click **Create Scan Template** button


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Windows Workgroup Computer                                                      |
| Active                | check box                                                                       |
| Scan Type             | Machine                                                                         |
| Parent Scan Template  | Computer                                                                        |
| Fields                | Add DNSHostName  (Leave Parent Unselected & INCLUDE IN MATCH unchecked)         |
|                       | Add ADGUID                                                                      |
|                       | Add DistinguishedName                                                           |
|                       | Add IP                                                                          |



1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Scanner Definition** from the drop-down list.
1. Click **Create Scan Template** button


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Windows Local Account Service                                                   |
| Active                | check box                                                                       |
| Scan Type             | Dependency                                                                      |
| Parent Scan Template  | Computer Dependency (Basic)                                                     |
| Account Scan Template | Windows Local Account                                                           |
| Fields                | Remove Domain                                                                   |


### Dependency Templates

1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Scanner Definition** from the drop-down list.
1. Click **Dependency Templates** tab
1. Click **Create Dependency Template** button


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Windows Local Account Dependency                                                |
| Description           | Dependency template for Windows Service Running as Local Accounts               |
| Active                | check box                                                                       |
| Dependency Type       | Windows Service                                                                 |
| Scan Template         | Windows Service Local Account                                                   |
| Dependency Changer    | Windows Service Dependency Changer                                              |



### Scanners

1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Scanner Definition** from the drop-down list.
1. Click **Scanners** tab
1. Click **Create Scanner** button


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Widows IP Scanner                                                               |
| Description           | IP Scanner for Windows machines                                                 |
| Active                | check box                                                                       |
| Scanner Type          | Machines                                                                        |
| Base Scanner          | PowerShell Discovery                                                            |
| Input Template        | Host Range                                                                      |
| Output Template       | Windows Workgroup Computer                                                      |
| Script                | Windows Workgroup IP Scanner                                                    |
| Script Arguments      | $target $[2]$username $[2]$password                                             |


1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Scanner Definition** from the drop-down list.
1. Click **Scanners** tab
1. Click **Create Scanner** button


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Windows Service w/ Local Accounts                                               |
| Description           | Find Windows Services running as Local Accounts                                 |
| Active                | check box                                                                       |
| Scanner Type          | Dependency                                                                      |
| Base Scanner          | PowerShell Discovery                                                            |
| Input Template        | Windows Workgroup Computer                                                      |
| Output Template       | Windows Local Account Service                                                   |
| Script                | Windows Service Local Account                                                   |
| Script Arguments      | $target $[2]$username $[2]$password                                             |


1. Browse to **Admin > Discovery** and click the **Configuration** tab.
1. Click **Discovery Configuration Options** and select **Scanner Definition** from the drop-down list.
1. Click **Scanners** tab
1. Click **Create Scanner** button


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Windows Local Accounts                                               |
| Description           | Find Windows Local Accounts                                 |
| Active                | check box                                                                       |
| Scanner Type          | Accounts                                                                      |
| Base Scanner          | Windows Discovery                                                            |
| Allow OU Input        | Checked                                                                         |
| Input Template        | Windows Workgroup Computer                                                      |
| Output Template       | Windows Local Account                                                           |


### Create Discovery Source

1. Browse to **Admin > Discovery**
1. Click **Create** button and select **Empty Discovery Source**


| Field                 | Value                                                                           |
| ----------------------| --------------------------------------------------------------------------------|
| Name                  | Workgroup Discovery                                                             |
| Site                  | Select Secret Server Site                                                       |
| Source Type           | Empty                                                                           |


1. Click **Save** button
1. Click **Cancel** button on **Add Flow** dialog box

#### Manual Host Range

1. Click **Add Scanner** button
1. Find **Manual Host Range** scanner and Click **Add Scanner** button
1. Click on **Manual Host Range** step
1. Click **Edit Scanner**
1. Add IP addresses or IP Range to **Lines** field
1. Click **Save** button

#### Add Windows IP Scanner

1. Click **Add Scanner** button
1. Find **Windows IP Scanner** scanner and Click **Add Scanner** button
1. Click on **Windows IP Scanner** step
1. Click **Edit Scanner**
1. Click **Add Secret**
1. Select a secret with permissions to run PowerShell on Distributed Engines
1. Click **Add Secret**
1. Select secret with administrator permissions on workgroup machines
1. Click **Save** button

#### Add Windows Local Accounts Scanner

1. Click **Add Scanner** button
1. Find **Windows Local Accounts** scanner and Click **Add Scanner** button
1. Click on **Windows Local Accounts** step
1. Click **Edit Scanner**
1. Click **Add Secret**
1. Select secret with administrator permissions on workgroup 
1. Click **Save** button

#### Add Windows Service w/ Local Accounts Scanner

1. Click **Add Scanner** button
1. Find **Windows Service w/ Local Accounts** scanner and Click **Add Scanner** button
1. Click on **Windows Service w/ Local Accounts  ** step
1. Click **Edit Scanner**
1. Click **Add Secret**
1. Select a secret with permissions to run PowerShell on Distributed Engines
1. Click **Add Secret**
1. Select secret with administrator permissions on workgroup machines
1. Click **Save** button

#### Enable Discovery Source
1. Browse to **Admin > Discovery**
1. Select the **Enabled** dropdown box
1. Select **Include disabled**
1. Select **Workgroup Discovery**
1. Click **Edit** button
1. Click **Enabled** checkbox
1. Click **Save** button

### Run Discovery Scan
1. Browse to **Admin > Discovery**
1. Click **Run Discovery Now** button
1. Select **Run Discovery Scan** from menu
1. Click **Run Discovery Now** button
1. Select **Run Computer Scan** from menu

### View Discovery Results
1. Browse to **Admin > Discovery**
1. Click **Network View** tab
1. Click **Legacy Page** button
1. Click **Service Accounts** tab
1. Select the service accounts to import
1. Click **Import** button
1. Fill out the details of the secret
1. Click **Ok** button

** Note: Service Accounts may only show up on the Legacy Network View Page. **



### Scanning and Importing Accounts & Dependencies
