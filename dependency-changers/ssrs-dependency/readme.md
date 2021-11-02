# Introduction

This document provides the details to update a Shared Data Source hosted on a SQL Server Reporting Services (SSRS) instance.

## Permissions

The privileged account utilized must have **Content Manager** role on the folder where the Data Source resides in SSRS.

## Setup

### Create Scripts

Navigate to **Admin | Scripts** and create a SQL Script for the dependency changer.

#### Script

| Field       | Value                                                                         |
| ----------- | ----------------------------------------------------------------------------- |
| Name        | `SSRS Shared Data Source Dependency`                                          |
| Description | Updates the password for the Shared Data Source's username                    |
| Category    | Dependency                                                                    |
| Script      | Paste contents of the script below                                            |

### Create Dependency Changer

1. Navigate to **Admin | Remote Password Changing**
1. Click **Create New Dependency Changer**
1. Type select **PowerShell Script**
1. Scan Template select **Computer Dependency (Basic)**
1. Name: **SSRS Dependency Changer**
1. Click the **Scripts** tab
1. Select the Script created in the previous section
1. Arguments: `"$SERVICENAME" $MACHINE $[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD`

> Ensure `$SERVICENAME` is wrapped in double-quotes, this ensures any Data Source path with spaces is passed to the script properly.

## Add Dependency Changer to Secret

1. Navigate to a Secret
1. Click **New Dependency**
1. **Type**, select the Dependency Changer created in the previous section from the drop-down
1. Dependency Group: Create or Select a current one
1. **ServiceName**, enter the path for the Data Source (format `/folder 1/.../Data Source Name`, e.g. `/Shared Data Sources/devApp DB1`)
1. **Machine Name**, enter the Web Service URL for the SSRS instance.
1. Click **Save**

> When entering the Data Source path in the ServiceName field **DO NOT** use single or double-quotes
