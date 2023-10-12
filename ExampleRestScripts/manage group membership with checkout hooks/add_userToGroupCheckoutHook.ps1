Import-Module ActiveDirectory

#CredSSP Arguments: $Username GroupToModify
#No CredSSP Arguments: $Username GroupToModify $[1]$Domain  $[1]$Username  $[1]$password

# set this to be your domain controller to hardcode the server, otherwise this will use the logon server of the engine
# set to null to not hardcode the controller
$HardcodeDomainController = $null


#end user config
$params = $args

if ($params.count -gt 2) {
    $password = ConvertTo-SecureString $params[4] -AsPlainText -Force
    $PSDefaultParameterValues.Add('*:credential', (New-Object System.Management.Automation.PSCredential (($params[2], $params[3] -join '\'), $password)))
}

if ($null -ne $HardcodeDomainController) {
    $PSDefaultParameterValues.Add('*:server', $HardcodeDomainController)
}

#Get the AD user as an input from Secret Server $params[0]
$ADUser = Get-ADUser -Identity $params[0]
if ($null -eq $aduser) { 
    throw "error finding user $aduser"
}
else {
    Write-Verbose "found user $($aduser.distinguishedname)"
}
#Get the list of current groups that user is a member of, to ensure they aren't already a member.
$CurrentGroups = Get-ADPrincipalGroupMembership $ADUser | Select-Object Name
Write-Verbose "$aduser Groups found $($currentgroups.name)"

#Return the Group Object from AD as an input from Secret Server $params[1]
$GroupToAdd = Get-ADGroup -Identity $params[1]
if ($null -eq $GroupToAdd) { 
    throw "error finding target group $GroupToAdd"
}
else {
    Write-Verbose "found target group $($GroupToAdd.distinguishedname)"
}

#If the member is currently a member of the group, remove that user, if they not a a member, return.

if (!($CurrentGroups.Name.Contains($GroupToAdd.Name))) {
    Write-Verbose "User not in target group - adding"
    $result = Add-ADPrincipalGroupMembership -Identity $ADUser -MemberOf $GroupToAdd -Confirm:$false
    return $result
}
else {
    Write-Verbose "User found in target group $($grouptoadd.name)"
    return
}

if ($PSDefaultParameterValues.Keys -contains "*:credential") { $PSDefaultParameterValues.remove('*:credential')}
if ($PSDefaultParameterValues.Keys -contains "*:server") { $PSDefaultParameterValues.remove('*:server')}
