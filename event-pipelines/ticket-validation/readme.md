# Introduction

The purpose of this document is to provide details on configuring an Event Pipeline that can be used to provide ticket validation when Require Comment is being utilized. This is provided as a workaround to Thycotic Secret Server's ticket integration when a more robust ticket validation is required.

> The script provided and configuration is written around Infor CRM, any other ticketing system can be utilized in the same pattern.

## Requirements

1. Secret Server Cloud or Secret Server 10.9 or higher for on-premises
1. Secret Server application user account saved as a secret
1. Infor CRM access required for querying for ticket validation (TBD)

## Prerequisites

### Create PowerShell Script

1. Navigate to **Admin \| Scripts**
1. Create new PowerShell script
1. Provide Name and Description. _Category can be left as Untyped_
1. Copy PowerShell script provided in this folder.

### Create Secret Server Application User Account

1. Navigate to **Admin | Users**
1. Create new user
1. Click **Advanced**
1. Check box for **Application Account**

Ensure the user is assigned to the target folders for the secrets that will be monitored using the Event Pipeline.

If granular control is required, the minimum role permissions the secret should need:

- Add Secret Custom Audit
- View Secret Audit

## Add Audit Report

The report is utilized to obtain the audit entry of the comment where the ticket is being entered for a given secret. *At this time an endpoint is not available on the API, so a report is being utilized*.

1. Navigate to Reports
1. Provide Report Name, Report Category (Activity)
1. Past the SQL script [get-secret-lastcomment.sql](get-secret-lastcomment.sql).
1. Click **Save**

## Event Pipeline Configuration

1. Navigate to **Admin | See All | Event Pipeline Policy**
1. Create Event Pipeline Policy
1. Select Secret as the policy type
1. Create Event Pipeline
1. Add Secret Trigger: **View**
1. Add Secret Filter: **Secret Setting**

    a.  Setting Name: *Require View Comment*
    b.  Value Match Type: *Equals*
    c.  Value: *true*

1. Add Secret Task: **Run Script**

    - Select script
    - Use Site to Run as Secret (checked)
    - Run Secret (ignored if using site)
    - Script Args (***space between each argument***): `"https://<your Secret Server URL>" $[ADD:1]$USERNAME $[ADD:1]$PASSWORD ReportID $SecretId "$MAS Account Number" $ByUser $EventUserId`
    - Additional Secret: Add the Secret Server application user for API calls. _This account requires edit rights to the secrets (needed to write custom audit entry)_.
    - Save
