# Azure Tenant Discovery

This script is utilized to Discovery privileged Azure AD accounts for a given Azure Subscription. The script will include scanning the Azure Active Directory privileged roles and Subscription assignment as recommended by Microsoft:

- Global administrator
- Privileged role administrator
- Exchange Online Administrator (_Microsoft 365 Administrators_)
- Service Administrator (_Subscription Classic Administrator_ - equivalent to Owner)
- Co-Administrator (_Subscription Class Administrator_ - equivalent to Owner)

The general use for this custom Discovery process is for those tenants that are not being managed by [Azure Privileged Identity Management (PIM)](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure), or with customers that are not interested in using that service. Customers that are using it should be aware that Service Administrator and Co-Administrator are both assignment roles that [cannot be managed by PIM](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-roles#classic-subscription-administrator-roles).

## Terms/Features:

- Distributed Engine – The main reason for this requirement is because the discovery script needs 2 different privileged accounts to accomplish this feature.
    1. One account runs the PowerShell script.
    2. One account authenticates to AzureAD.

This may be accomplished without a DE, but it would be best practice to have this running from the DE rather than the WebNode. There will be some configurations on the DE itself as well as within SS.
Scripts, Scan Templates, Discovery Scan Templates, Scanner Settings, Remote Password Changers – All items that will need creation and/or configuration within SS.
Azure Terms:
- Assigned Roles – Roles required for account performing Azure AD discovery.
- Azure Role Assignments (aka Subscriptions) – **This could be optional, but I need to validate**.  Your tenant must be able to add subscriptions (the only one req’d is ‘Reader’, and it appears to be free)

## Prerequisite

The following modules are required for this script to run. The modules listed below should be installed on all Distributed Engines or Web Nodes (if doing web processing on-premises):

| Module Name  | Purpose                                                                       |
| ------------ | ----------------------------------------------------------------------------- |
| AzureAD      | Used to pull Azure Active Directory privileged role members                   |
| Az.Accounts  | Used to login to the Azure Subscription                                       |
| Az.Resources | Used to pull Azure AD accounts assigned privileged roles Owner or Contributor |

### Privileged Account

The minimum privileges required for scanning the Azure AD and Resource assignment for the subscription:

- AzureAD: **Directory readers**
- Subscription: **Reader**

## Logging

The script will log to the provided directory in the script (defaults to `C:\thycotic`). The naming convetion of the log file will be `azure_ad_discovery_<filedatetime>.log`.

The script includes a process to clean up the logs and will keep *the last 10 based on LastWriteTime*.

## Azure Prep

   1. From your tenant, create a new user that will be the discovery account.
   
        a.	Add the Assigned Role of “Directory Readers” to the account:
        ![image](https://user-images.githubusercontent.com/84103738/153434617-2a41039a-8b43-4e4a-88a4-c8adeed1eb12.png)
        
        b.	Make sure you login once to change the password, as there is not a setting to disable force pwd change on first login. Discovery will fail and throw an error if this pwd is not changed.
        
   2. If necessary, add the “Reader” to the “Azure Role Assignments” (access this from left nav for the User). See this link from MS about subscriptions, https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles.
   3. If creating new privileged accounts in Azure AD to be discovered, be sure to login once to change the initial login pwd or Heartbeats will fail after import.


## Secret Server Configuration

### Distributed Engine Prep

   1. If you do not have a DE installed see https://docs.delinea.com/secrets/current/secret-server-cloud/quick-start/index.md#distributed_engine for instructions on installing and configuring this.
    
       a. Rabbit MQ - https://docs.delinea.com/secrets/current/secret-server-setup/installation/installing-rabbitmq
       
       b. DE - https://docs.delinea.com/secrets/current/networking/distributed-engines/index.md 
   2. In an elevated PowerShell session, perform the following:
    
       a. Install the following modules (use the following syntax: ‘Install-Module ModuleName’):
       
            i. AzureAD
            ii. Az.Accounts
            iii. Az.Resources
         
       b. Run ‘Enable-PSRemoting’ (see https://docs.delinea.com/secrets/current/api-scripting/configuring-winrm-powershell for more information on this)
            NOTE:  Many folks have had issues when attempting to run this. If there are issues, just run the individual command in the link above.
            Also, here is the link on the cmdlet from MS’ site, https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-7.2 
       
       c. Configure CredSSP for WinRM - https://docs.delinea.com/secrets/current/authentication/configuring-credssp-for-winrm-with-powershell/index.md#configuring_credssp_for_winrm_on_the_secret_server_machine

### Create Scripts

1. Navigate to **Admin | Scripts**
1. Select **Create New Script** (_see table below_)

    | Field       | Value                                                                                      |
    | ----------- | ------------------------------------------------------------------------------------------ |
    | Name        | Azure Account Discovery                                                                    |
    | Description | Discovery members of privileged roles in Azure AD and Owner assignment to the Subscription |
    | Category    | Dependency                                                                                 |
    | Script      | [discovery-azure-privileged.ps1](discovery-azure-privileged.ps1)                           |
    
    *NOTE*:  If this account does not have any SubscriptionAccounts, the script will error out.  To mitigate this, comment out the following lines of code (comment blocks in PowerShell begin with <# and end with #>).  It is around lines 75-83:

```powershell
foreach ($role in $AzureSubRoles) {
    try {
        $discoveredSubAccounts = Get-AzRoleAssignment -RoleDefinitionName $role -IncludeClassicAdministrators | Where-Object { $_.SignInName -notlike "*#EXT#*" -and -not [string]::IsNullOrEmpty($_.SignInName) } | Select-Object ObjectId, ObjectType, DisplayName, SignInName, @{L = 'MemberOf';E = { $_.RoleDefinitionName } }
        Add-Content -Path $logFile -Value "Successfully retrieved [$role] assignments on Tenant [$tenantId]" -ErrorAction SilentlyContinue
    } catch {
        Add-Content -Path $logFile -Value "Issue retrieved [$role] assignments on Tenant [$tenantId]: $($_)" -ErrorAction SilentlyContinue
        throw "Issue retreiving [$role] assignments on Tenant [$tenantId]"
    }
}
```
3. Select **OK**

### Configure Discovery, Create the Scan Templates, and Discovery Scanners 

#### Host Ranges Template

1. Navigate to **Admin | Discovery | Configuration (tab) | Scan Templates**
1. Navigate to **Host Ranges** tab
1. Click **Create New Scan Template** (_see table below_)

    | Field                | Value            |
    | -------------------- | ---------------- |
    | Name                 | Azure Tenant ID  |
    | Scan Type            | Find Host Ranges |
    | Parent Scan Template | Host Range       |
    | Active               | **Checked**      |

1. Under **Fields** Section

    | Field Name | Parent Field             | Include in Match       |
    | ---------- | ------------------------ | ---------------------- |
    | TenantId   | HostRange (not editable) | Checked (not editable) |

1. Click **Save**  

#### Accounts Template

1. Navigate to **Admin | Discovery | Configuration (tab) | Scan Templates**
1. Navigate to **Accounts** tab
1. Click **Create New Scan Template** (_see table below_)

    > For import purpose the name of this scanner must match the Secret Template, `Office 365 Account` (or other name if using a custom Secret Template).  If this name must differ, see step 6 titled: “Configure Password Changing Edit Scan Template.”

    | Field                | Value                  |
    | -------------------- | ---------------------- |
    | Name                 | **Office 365 Account** |
    | Scan Type            | Find Local Accounts    |
    | Parent Scan Template | Account (Basic)        |
    | Active               | **Checked**            |

1. Under **Fields** Section

    | Field Name  | Parent Field            | Include in Match       |
    | ----------- | ----------------------- | ---------------------- |
    | Domain      | Resource (not editable) | Checked (not editable) |
    | Username    | Username (not editable) | Checked (not editable) |
    | Password    | Password (drop-down)    | Unchecked              |
    | Type        | `<None>` (not editable) | Unchecked              |
    | MemberOf    | `<None>` (not editable) | Unchecked              |

1. Click **Save**

1. Configure Password Changing Edit Scan Template:

    a. Go to “Admin | Remote Password Changing:
    
    b. Click “Configure Password Changers”
    
    c. Select Password Type Name “Office365”
    
    d. Scroll down and click “Configure Scan Template”
    
    e. Click “Edit”
    
    f. Under “Scan Template to use”, select the name of the scan template as you titled it under section iii above, if you called it something different.
    
    g. Change any corresponding fields to match the Secret Template as appropriate (ex.  ‘Type’ and ‘MemberOf’ are not default fields in the o365 Secret Template.  Add those fields to the Secret Template if you want to import/use them.)

#### Host Range Scanner

1. Navigate to **Admin | Discovery | Configuration (tab) | Extensible Discovery | Configure Discovery Scanners (button)**
1. Navigate to the **Host Ranges** tab
1. Click **Create New Scanner** (_see table below_)

    | Field           | Value                         |
    | --------------- | ----------------------------- |
    | Name            | Azure Tenant Scanner          |
    | Description     | Azure Tenant ID to be scanned |
    | Active          | **Checked**                   |
    | Discovery Type  | Find Host Ranges              |
    | Base Scanner    | **Manual Input Discovery**    |
    | Input Template  | *Discovery Source**           |
    | Output Template | **Azure Tenant ID**           |

1. Select **OK**

#### Accounts Scanner

1. Navigate to **Admin | Discovery | Configuration (tab) |  Extensible Discovery | Configure Discovery Scanners (button)**
1. Navigate to the **Accounts** tab
1. Click **Create New Scanner** (_see table below_)

    | Field                  | Value                                             |
    | ---------------------- | ------------------------------------------------- |
    | Name                   | **Azure Tenant Account Scanner**                  |
    | Description            | Scan a given Azure Tenant for Privileged accounts |
    | Active                 | **Checked**                                       |
    | Discovery Type         | Find Local Accounts                               |
    | Base Scanner           | PowerShell Discovery                              |
    | Allow OU Input         | **Checked**                                       |
    | Input Template         | **Azure Tenant ID**                               |
    | Output Template        | **Office365 Account**                             |
    | Script                 | **Azure Account Discovery**                       |
    | Arguments              | `$[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD $TARGET` |
    | Use Site Run As Secret | **Checked**                                       |

1. Select **OK**

> **Note:** When checking the `Allow OU Input` this mean Account scanning will be performed during Discovery Scan, **NOT** during Computer Scanning.

### Create Discovery Source

1. Navigate to **Admin | Discovery**
1. Click **Create Discovery Source** drop-down
1. Click **Unix**
1. Click **Next**
1. Enter **Tenant Domain Name** as the Discovery Source Name
1. Click **Next**
1. Enter **Tenant ID** for the IP Scan Range
1. Click **Next**
1. Select the appropriate Site
1. Click **Next**
1. Click **Add Secret** and select the privileged secret
1. Click **Finish**

#### Configure Discovery Source Scanners

1. Navigate to **Admin | Discovery**
1. Click the **Tenant Name** to edit
1. Click the button **Scanner Settings**
1. **Delete all the scanners under each section**
1. Click **Add New Host Range Scanner**
1. Click the `+` sign for the **Azure Tenant Scanner**
1. Add the **Tenant ID** in the Lines box (if not done when creating the source)
1. Click **Ok**
1. Click **Add new Account Scanner**
1. Click the `+` sign for the **Azure Tenant Account Scanner**
1. Click **Add Secret** to add the privileged secret for the Tenant being scanned
1. Check box for **Use Site Run As Secret**
1. Click **Ok**

### Next Steps

Start **Discovery Scan** then check **Discovery Network View** for results under **Domain\Cloud Accounts**

#### Additional Data Report

Additional data points captured in the above process include identifying the account type and the role or assignment of the user found. This data will not be visible from the Discovery Network View so the below custom report can be used for viewing this data:

```sql
SELECT
    d.[ComputerAccountId]
    ,d.[CreatedDate]
    ,MIN(CASE JSON_VALUE([adata].[value],'$.Name') WHEN 'Domain' THEN JSON_VALUE([adata].[value],'$.Value') END) AS [Domain]
    ,d.[AccountName] AS [Username]
    ,MIN(CASE JSON_VALUE([adata].[value],'$.Name') WHEN 'Type' THEN JSON_VALUE([adata].[value],'$.Value') END) AS [Type]
    ,MIN(CASE JSON_VALUE([adata].[value],'$.Name') WHEN 'MemberOf' THEN JSON_VALUE([adata].[value],'$.Value') END) AS [MemberOf]
FROM tbComputerAccount AS d
CROSS APPLY OPENJSON (d.AdditionalData) AS adata
INNER JOIN tbScanItemTemplate AS s ON s.ScanItemTemplateId = d.ScanItemTemplateId
WHERE s.ScanItemTemplateName LIKE 'Office365%Account'
GROUP BY d.ComputerAccountId, d.AccountName, d.CreatedDate
```

Sample view of the report data:

![sample output of report](https://user-images.githubusercontent.com/11204251/132103489-9b51653a-6a68-42fb-97b6-b0088bb5251f.png)

### Sample Output

Sample **Discovery Network View**:

![sample discovery network view](https://user-images.githubusercontent.com/11204251/132103423-03762395-9392-4896-9984-9ef897f28ed3.png)

Sample **Discovery Logs**:

![sample discovery scan log](https://user-images.githubusercontent.com/11204251/132103379-2d21b5d8-1162-4fd3-9077-e8196777a033.png)

Sample of physical log file on the Distributed Engine:

![image](https://user-images.githubusercontent.com/11204251/132103456-5a89ec2b-8c40-4368-b9e5-0f7a73aef936.png)
