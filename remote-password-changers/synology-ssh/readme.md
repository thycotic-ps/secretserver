# Introduction

This document provides the details for having Secret Server manage your passwords for Synology local accounts via SSH.

## Permissions

The account used within these scripts must be able to connect to the device through SSH in order for these scripts to function.  The Account must be in the Administrator role to change passwords.

## Setup

### Create Password Changer

1. Navigate to **Admin | Remote Password Changing**
1. Click **Configure Password Changers**
1. Click **New**

#### Create New Password Changer

1. Provide following details:

    | Field                 | Value                     |
    | --------------------- | ------------------------- |
    | Base Password Changer | Unix Account Custom (SSH) |
    | Name                  | Synology (SSH)            |

1. Click **Save**

#### Enter Commands

1. Under _Verify Password Changed Commands_
1. Enter Commands

    | Order | Field                     | Value             | Pause |
    | ----- | ------------------------- | ----------------- | ----- |
    | 1     | whoami                    | Get Username      | 2000  |
    | 2     | $$CHECKCONTAINS $USERNAME | Validate username | 2000  |

1. Under _Password Changed Commands_
1. Enter Commands

    | Order | Field                                        | Value                                   | Pause |
    | ----- | -------------------------------------------- | --------------------------------------- | ----- |
    | 1     | sudo synouser --setpw $USERNAME $NEWPASSWORD | Change the password for a user Username | 2000  |
    | 2     | $CURRENTPASSWORD                             | Enter password to sudo                  | 2000  |
    | 3     | exit                                         | Exit                                    | 2000  |

## Create Synology (SSH) Template

1. Navigate to **Admin | Secret Templates**
1. Under **Import Secret Templates** copy/paste the [synology_ssh_template.xml](synology_ssh_template.xml)
1. Click **Import**
1. Click **Configure Password Changing**
1. Click **Edit**
1. Check box for **Enable Remote Password Changing**
1. Adjust the **Retry Interval** and **Maximum Attempts** to your requirements
1. Check box for **Enable Heartbeat**
1. Adjust the **Heartbeat Check Interval** to your requirements.
1. Click drop-down for _Password Type to use_, select **Synology (SSH)**
1. Click drop-down for _Machine Name_, select **Machine**
1. Click drop-down for _User Name, select **Username**
1. Click drop-down for _Password_, select **Password**
1. Click **Save**

Proceed to create a new secret and test/verify the HB and RPC function correctly.
