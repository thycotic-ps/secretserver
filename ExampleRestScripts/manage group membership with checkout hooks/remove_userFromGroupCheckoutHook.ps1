Import-Module ActiveDirectory

#CredSSP Arguments: $Username GroupToModify
#No CredSSP Arguments: $Username GroupToModify $[1]$Domain  $[1]$Username  $[1]$password

# set this to be your domain controller to hardcode the server, otherwise this will use the logon server of the engine
# set to null to not hardcode the controller
$HardcodeDomainController = $null

#end user config

#transition arguments to temporary variable to avoid scoping issues later
$params = $args

if ($params.count -gt 2) {
    write-verbose "credentials sent, setting up parameters"
    $password = ConvertTo-SecureString $params[4] -AsPlainText -Force
    $PSDefaultParameterValues.Add('*:credential', (New-Object System.Management.Automation.PSCredential (($params[2], $params[3] -join '\'), $password)))
}

if ($null -ne $HardcodeDomainController) {
    write-verbose "Forcing domain controller to $HardcodeDomainController"
    $PSDefaultParameterValues.Add('*:server', $HardcodeDomainController)
}

#Get the AD user as an input from Secret Server $params[0]
$ADUser = Get-ADUser -Identity $params[0]
if ($null -eq $aduser) { 
    throw "error finding user $aduser"
}
else {
    Write-Verbose "found user ${$aduser.distinguishedname}"
}
#Get the list of current groups that user is a member of, to ensure they aren't already a member.
$CurrentGroups = Get-ADPrincipalGroupMembership $ADUser | Select-Object Name
Write-Verbose "$aduser Groups found ${$currentgroups.name}"

#Return the Group Object from AD as an input from Secret Server $params[1]
$GroupToRemove = Get-ADGroup -Identity $params[1]
if ($null -eq $GroupToRemove) { 
    throw "error finding target group $GroupToRemove"
}
else {
    Write-Verbose "found target group ${$GroupToRemove.distinguishedname}"
}

#If the member is currently a member of the group, remove that user, if they not a a member, return.

if ($CurrentGroups.Name.Contains($GroupToRemove.Name)) {
    Write-Verbose "User in target group - removing"
    $result = Remove-ADPrincipalGroupMembership -Identity $ADUser -MemberOf $GroupToRemove -Confirm:$false
    Write-Verbose $result
}
else {
    Write-Verbose "User not found in target group ${$params[1]}"
}

$PSDefaultParameterValues.remove('*:credential')
$PSDefaultParameterValues.remove('*:server')
