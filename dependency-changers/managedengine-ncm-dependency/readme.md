# Introduction

This document provides the details for having Secret Server update the credential password stored in ManagedEngine Network Configuration Manager (NCM). Adjustments may be needed based on the configuration of NCM.

The script utilized generates a timestamp and will update the `description` of the profile in NCM to give an indicator that Secret Server updated it.

## Permissions

The API Key used by NCM is global and has the permissions required to update the profiles and credential properties.

## Setup

The script expects the need for an Enabled Password to be provided that is also stored on the Credential's Profile. Associated Secret(s) can be applied to the Secret for this dependency changer. The `$[1]$PASSWORD` in the expected arguments is meant to present the first Associated Secret set.

If you have multiple Shared Profiles using different Enabled Passwords simply reference the Associated Secret for each.

## Create Script

1. Navigate to **Admin | Scripts**
2. Enter name: **NCM - Dependency Script**
3. Description: **NCM dependency script to update backup credential**
4. Category: **Dependency**
5. Script: **Copy and Paste** the provided script [managedengine-ncm-dependency.ps1](managedengine-ncm-dependency.ps1)
6. Click **OK**

## Add to Secret

1. Navigate to desired Secret
2. Navigate to **Dependencies** tab
3. Click on **New Dependency**
4. Drop-down for **Type** select the dependency created in the previous step under **Run PowerShell Script**
5. Use **Dependency Group** drop-down to select a current group or create a new one
6. Creating a new one provide the **New Group Name** and **New Group Site Name** (drop-down selection)
7. Provide the **NCM Profile Name** in the **Dependency Name** field - this is the profile containing the credential we need to update
8. Select **Run As** secret if needed (account is used to execute the PowerShell script, if not using other configuration options)
9. Provide the **URL for ManagedEngine NCM** in the **Machine Name** field - ensure you include `/api/json` on the end (e.g. `<url>/api/json`)

> **NOTE** If the Profile in NCM has a space in the name, ensure the token for `$SERVICENAME` is wrapped in double-quotes.

> Note the URL used for the Machine Name must be accessible from the Web Node(s) or Distributed Engine(s). Entering the URL should have you hit the Managed Engine login page.
