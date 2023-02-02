# Expected arguments: $[1]$USERNAME $[1]$DOMAIN $[1]$PASSWORD $MACHINE
$privUserName = $args[0]
$prefix = $args[1] #this can be a domain or machine name
$privUserName = "$prefix\$privUserName"
$privPassword = ConvertTo-SecureString -AsPlainText $args[2] -Force
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $privUserName, $privPassword
Invoke-Command -ComputerName $args[3] -Credential $creds -ScriptBlock { Restart-Computer -Force }