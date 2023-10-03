# Introduction
This solution will replicate the Personal Folders option in Secret Server with additional contols and manageability. 

---
# Prerequisites 

**[SecretServer webservices](https://docs.thycotic.com/ss/11.1.0/webservices/enabling-webservices/index.md)**

Must be enabled as we leverage the REST API.

**SecretServer application account**

This can be either a local account or a domain based account. This account will also need to have a secret with the credentials. This account cannot have MFA enabled on it, but can be restricted by IP address. A domain account is preferred as SecretServer can be used to rotate the credentials.

---
# Configuration Steps

## Create Scripts

1. Go to **Admin** \> **Scripts**.

    ![image](https://user-images.githubusercontent.com/9537950/108251572-8ee47e80-7125-11eb-8eac-0d000b12fde2.png)

1. On the PowerShell tab, click :heavy_plus_sign:**Create New**. The New PowerShell Script window appears:
1. Fill in the **Name**, **Description** and **Category** fields.
    > **Note**: Select "Untyped" for Category
1. Paste the script into the Script text box. [EnhancedFolders.ps1](EnhancedFolders.ps1)
1. Set variables on lines 46, 52-55

    | Variable | Description | Example |
    | -------- | ----------- | ------- |
    $application | Url of your SecretServer instance | https://pam.local/secretserver  https://privotter.secretservercloud.com/ |
    $PFolderBaseID | folder ID of base folder for individual folders | integer
    $FolderOwnerUsers | comma separated list of userNames to include with folder owner permissions | @("Manager1","Manager2")
    $FolderOwnerGroups | comma separated list of GroupNames to include with folder owner permissions | @("Manager Group","PAM Administrators")
    $AllowedTemplateIDs | Comma separated list of templateIDs to limit options on new folder | @(6001,6068,4,6074,2,6081,9,6030) *Will limit the folder to only have Active Directory Account, Amazon IAM Key, Bank Account, Combination Lock, Credit Card, Password, Product License Key, Web Password, and z/OS Mainframe templates available*

1. Click the OK button. The new script will appear in the table on the Scripts page.

### Webservices

> Webservices will enable other applications to interact with Secret Server via API calls.

a.  Navigate to **Admin \| Configuration \| General** tab and **Edit** to **Enable Webservices**. Check the box, then click **Save**.

![image](https://user-images.githubusercontent.com/9537950/108111924-698f3c00-7063-11eb-828f-703e280ffd1b.png)

### Create group to leverage for pipeline

You can create a new local group or use an existing local group that users are added to. 


> :warning: **The local Everyone group cannot be used** for this example as all users are members of the group and its membership cannot be modified. 


> :warning: **Domain groups should be used with care** if using triggers based on membership changes. Secret Server does not get a notification about membership changes until it performs a sync of the domain so the EP will not be triggered immediatley leading to long waits.

### Create Top Level Folder and disable Personal Folders

1. Add a new top level folder and note the folder id
    > The folder ID can be obtained by navigating to the folder and checking the URL. https://server/app/#/folders/1453 would be folder id 1453

1. Go to **Admin \| Configuration**
1. Click on the **Folders** tab
1. Edit the settings and set **Enable Personal Folders** to **No**

### Create API Account

This solution will require an application account to be used by the script. The application account will need to have appropriate permissions to create and manage folders. To create a new Application Account, follow these steps:

1. Create a new User Account: 
- **Local Account**: Go to **Admin \| Users \| Create New**, then fill in **Names** for the account and click **Advanced**. Check the **Application Account** box and **Save**.
- **Domain Account**: create AD based user and add to sync group to create user. Then open the user account and click **Advanced**. Check the **Application Account** box and **Save**.
3. **Optional:** add [IP address restrictions](https://docs.delinea.com/secrets/current/users/user-restriction-settings/index.md) to the account
4. Create a new Role for the API Folder Management User, this role should include the following role permissions: `Administer Folders` `View Folders` `View Groups` `View Roles` `View Secret Policy` `View Secret Templates` `View Users`
5. Assign the Created Role to the API user

### Create Secret for Folder Creation API User

Create a secret using the Password or Active Directory template for the API user. This will be used as an additional secret when defining the task in Event Pipeline


## Event Pipelines

Event Pipelines are a named group of triggers, filters, and tasks to manage events and responses to them. We will use a pipeline to trigger running a script to create and configure folders for the targeted users. 

### Create the Event Pipeline

1.  Go to **Admin** \| **See all \| Actions Category \| Event Pipeline Policy**
1.  Click the **Add Policy** button --- the pipeline policy popup window will show up
1.  Fill in the **Policy Name**, **Description** and **Type**.

    > **Note**: select **Event Pipeline type**: **User**

1.  Click the **Add Pipeline** button.
1.  Click the **Create New Pipeline** button. The **New Pipeline** wizard appears on the Choose Triggers page. Create the **Triggers**, **Filters**, and **Task**:

1. **Trigger:** This should be set to `Added to Group`
1. **Filters:** If desired additional filters can be applied here
1. **Tasks:** For the task choose `Run Script` 

1.  A settings box will appear
    | Option | Setting |
    | ------ | ------- |
    | Script | Select Script uploaded earlier |
    | Use Site Run As Secret | :heavy_check_mark: or leave :black_square_button: and use **Run Secret** to specify account opening the pssession
    | Script Args | `$[add:1]$username $[add:1]$password "$targetuserid" "$targetuser.displayname"`|
    | | *(for AD based API account)*  `$[add:1]$username $[add:1]$password "$targetuserid" "$targetuser.displayname" $[add:1]$domain ` |
    |Run Site | Select desired Site
    |Additional Secret 1 | Select the secret containing the API user credentials| 


1. Click the Next button. The **Name Pipeline** page of the wizard appears. Enter the **Name**, **Description** and click on **Save**.
1. Activate the Event Pipeline by clicking on the **Active/Inactive** toggle button located on the upper right side of the Event Pipeline policy --- a confirmation popup appears.
1. Set a **target** for the Event Pipeline Policy. This should be the group created earlier. 
