# Introduction

This document provides the details for having Secret Server manage local user passwords for servers utilizing the DZDO elevation commands

# Permissions

The account used must be able to connect to the device through SSH and execute the listed commands

# Setup

## Create Password Changer

1. Navigate to **Admin | Remote Password Changing**
2. Click **Configure Password Changers**
3. Click **New**

### Create New Password Changer

1. Provide following details:

    | Field                 | Value                     |
    | --------------------- | ------------------------- |
    | Base Password Changer | Unix Account Custom (SSH) |
    | Name                  | Unix Local Account DZDO managed (SSH)          |

2. Click **Save**

### Enter Commands

1. Under _Verify Password Changed Commands_
2. Under _Authenticate As_
    |Item    | Value       |
    |--------|-------------|
    |Username|$[1]$USERNAME|
    |Password|$[1]$PASSWORD|
    
4. Enter Commands

    | Order | Field                                   | Value                     | Pause |
    | ----- | --------------------------------------- | ------------------------- | ----- |
    | 1     | su $USERNAME                            | Substitute User           | 500   |
    | 2     | $CURRENTPASSWORD                        | Enter target password     | 500   |
    | 3     | whoami                                  | Get logged in account     | 500   |
    | 4     | $$CHECKCONTAINS $USERNAME               | Validate username         | 500   |

3. Under _Password Changed Commands_
2. Under _Authenticate As_
    |Item    | Value       |
    |--------|-------------|
    |Username|$[1]$USERNAME|
    |Password|$[1]$PASSWORD|
    
4. Enter Commands

    | Order | Field                                 | Value                     | Pause |
    | ----- | ------------------------------------- | ------------------------- | ----- |
    | 1     | dzdo passwd $USERNAME                 | Substitute User           | 500   |
    | 2     | $[1]$PASSWORD                         | Enter priviliged password | 500   |
    | 3     | $NEWPASSWORD                          | Update password           | 500   |
   	| 4     | $NEWPASSWORD                          | Validate                  | 500   |

Note that step #3 in the password change commands is optional and can be dropped if DZDO is configured to run without a password
