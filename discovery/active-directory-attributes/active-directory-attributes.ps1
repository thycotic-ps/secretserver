#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Retrieves enabled normal user accounts from Active Directory with extra attributes returned to update secret fields

.DESCRIPTION
    Queries AD using an LDAP filter to find all enabled normal user accounts
    (UAC bit 512 = NORMAL_ACCOUNT, excluding UAC bit 2 = ACCOUNTDISABLE).
    Returns user properties including password age, last logon, and domain info.

.PARAMETER args[0]
    Username for AD authentication (domain\user or UPN format).

.PARAMETER args[1]
    Password for AD authentication (plain text, converted to SecureString).

.EXAMPLE
    Used in secret server discovery traditionally
    From command line .\Get-ADEnabledUsers.ps1 "domain\serviceaccount" "P@ssw0rd"
#>

# Build credential from arguments
$username = $args[0]
$password = $args[1]
$privCred = [PSCredential]::new($username, (ConvertTo-SecureString $password -AsPlainText -Force))

# LDAP filter: enabled normal user accounts
# - 512 (0x200)  = NORMAL_ACCOUNT
# - 2   (0x2)    = ACCOUNTDISABLE (excluded with !)
# - OID 1.2.840.113556.1.4.803 = bitwise AND matching rule
$ldapFilter = "(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=512)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"

# Define output properties with calculated fields
$properties = @(
    @{ L = "Domain";              E = { ($_.PrimaryGroup -split ",")[-2].Replace("DC=","") + "." + ($_.PrimaryGroup -split ",")[-1].Replace("DC=","") } }
    @{ L = "Username";            E = { $_.samAccountName } }
    'SamAccountName'
    'DisplayName'
    'extensionAttribute14'
    @{ L = "extensionAttribute01"; E = { $_.mail } }
    'UserPrincipalName'
    'sn'
    @{ L = "Active";              E = { $_.Enabled } }
    'PasswordExpired'
    @{ L = "extensionAttribute02"; E = { $_.Manager } }
    'UserAccountControl'
    @{ L = "PwdLastSet";          E = { [datetime]::FromFileTime($_.PwdLastSet) } }
    @{ L = "PwdAge";              E = { ((Get-Date) - [datetime]::FromFileTime($_.pwdLastSet)).Days } }
    @{ L = "LastLogonTimestamp";  E = { [datetime]::FromFileTime($_.lastLogonTimestamp) } }
    'WhenCreated'
    'DistinguishedName'
)

# Query parameters
$queryParams = @{
    LDAPFilter = $ldapFilter
    Credential = $privCred
    Properties = '*'
}

# Execute query and return selected properties
Get-ADUser @queryParams | Select-Object $properties
