# Introduction

Windows Local Account RPC and HB for environments that do not allow remote access or require special Proxy configurations.

## Permissions

A privileged account that has Administrator privileges on the target endpoint is required.

## Setup

### Create Scripts

Navigate to **Admin | Scripts** and create a script for the HB and RPC using the details below.

#### Script - Heartbeat

| Field       | Value                                                                                           |
| ----------- | ----------------------------------------------------------------------------------------------- |
| Name        | Windows Local Account HB                                                                        |
| Description | Script to heartbeat local user with privileged                                                  |
| Category    | Heartbeat                                                                                       |
| Script      | Paste contents of the heartbeat script [windows-local-wpriv-hb.ps1](windows-local-wpriv-hb.ps1) |

> A version 2 of the HB script can be utilized, see the Synopsis of each script based on GPO configurations.

#### Script - Password Changer

| Field       | Value                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------- |
| Name        | Windows Local Account RPC                                                                   |
| Description | Script for password rotation local user with privileged                                     |
| Category    | Password Changing                                                                           |
| Script      | Paste contents of the RPC script [windows-local-wpriv-rpc.ps1](windows-local-wpriv-rpc.ps1) |

### Create Password Changer

1. Navigate to **Admin | Remote Password Changing**
1. Click **Configure Password Changers**
1. Click **New**
1. Provide following details:

    | Field                 | Value                     |
    | --------------------- | ------------------------- |
    | Base Password Changer | PowerShell Script         |
    | Name                  | Windows Local Account RPC |

1. Click **Save**
1. Click drop-down under _Verify Password Changed Commands_
1. Select **Windows Local Account HB**
1. Enter following for **Script Arguments**: `$MACHINE $USERNAME $PASSWORD "0" $[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD`
1. Click drop-down under _Password Change Commands_
1. Select **Windows Local Account RPC**
1. Enter following for **Script Arguments**: `$MACHINE $USERNAME $NEWPASSWORD "0" $[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD`
1. Click **Save**

## Create Windows Local Account Template

> **Note:** Create copy of OOB template if desired.

1. Navigate to **Admin | Secret Templates**
1. Click **Windows Account**
1. Click **Copy Secret Template**
1. Provide a new template name
1. Click **Ok**
1. Click **Configure Password Changing**
1. Click **Edit**
1. Adjust the **Retry Interval** and **Maximum Attempts** to your requirements
1. Adjust the **Heartbeat Check Interval** to your requirements.
1. Click drop-down for **Password Type to use**
1. Select **Windows Local Account HB**
1. Click drop-down for **Domain**
1. Select **Machine**
1. Confirm selections for **Password** and **User Name** are set correctly
1. Select a Secret for **Default Privileged Account**

Proceed to create a new secret and test/verify the HB and RPC function correctly.
