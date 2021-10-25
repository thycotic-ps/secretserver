# Introduction

This document provides the details for having Secret Server update the credential password stored in ManagedEngine Network Configuration Manager (NCM). Adjustments may be needed based on the configuration of NCM.

The script utilized generates a timestamp and will update the `description` of the profile in NCM to give an indicator that Secret Server updated it.

## Permissions

The API Key used by NCM is global and has the permissions required to update the profiles and credential properties.

## Setup

## Create Script

1. Navigate to **Admin | Scripts**
2. Enter name: **NCM - Dependency Script**
3. Description: **NCM dependency script to update backup credential**
4. Category: **Dependency**
5. Script: **Copy and Paste** the provided script [managedengine-ncm-dependency.ps1](managedengine-ncm-dependency.ps1)
6. Click **OK**

## Create Dependency Changer

1. Navigate to **Admin | Remote Password Changing**
2. Navigate to **Configure Dependency Changers**
3. Create a **Create New Dependency Changer**
4. Complete the form according to table below:

    | Field           | Value                      |
    | --------------- | -------------------------- |
    | Type            | PowerShell Script          |
    | Scan Template   | Windows Service            |
    | Name            | **NCM Dependency Changer** |
    | Description     | Leave blank                |
    | Port            | Leave blank                |
    | Wait(s)         | Leave at 0                 |
    | Enabled         | Leave checked              |
    | Create Template | Leave checked              |

5. Click **Scripts** tab
6. **Scripts** drop-down select PowerShell created in previous step
7. **Arguments** paste the following: `"$SERVICENAME" $MACHINE $DOMAIN $USERNAME $PASSWORD`
8. Click **Save**

> **NOTE** If the Profile in NCM has a space in the name, ensure the token for `$SERVICENAME` is wrapped in double-quotes.

## Add to Secret

1. Navigate to desired Secret
2. Navigate to **Dependencies** tab
3. Click on **New Dependency**
4. Drop-down for **Type** select the dependency created in the previous step (should be under **Standard** section)
5. Use **Dependency Group** drop-down to select a current group or create a new one
6. Creating a new one provide the **New Group Name** and **New Group Site Name** (drop-down selection)
7. Provide the **ServiceName** as the NCM Profile that contains the credential to update.
8. Select **Run As** secret if needed
9. Enter **Machine Name** as the URL for the ManagedEngine NCM site as `<url>/api/json`

## Example screenshots

Below are example screenshots of the created configuration above:

Create Dependency Changer:

![image](https://user-images.githubusercontent.com/11204251/137412909-082a2d8e-7c9a-4f2a-a63e-b1dfab8d2366.png)

![image](https://user-images.githubusercontent.com/11204251/137413024-747a4b00-2758-4f1f-b319-d571b30b14b3.png)

Creating Dependency on Secret:

![image](https://user-images.githubusercontent.com/11204251/137412660-1dee76db-6b67-4d96-aa6a-411a171fc061.png)
