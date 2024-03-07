#Global Variables used for debugging issues
$debug = $true
$errorfile = "$env:ProgramFiles\Thycotic Software Ltd\Distributed Engine\log\Local Service Account Dependencies.log"


#Pull the accounts  that are running services on the machine.
$machine = $args[0]
$username = $args[1]
$password = $args[2]
$Spassword = ConvertTo-SecureString $password -AsPlainText -Force

if ($debug) {
    (get-date).ToString() + "   Arguments: $machine, $Username  $password `t" | Out-File -FilePath $errorfile -Append
    write-debug "Arguments: $machine, $Username"
}

$machineCred = New-Object System.Management.Automation.PSCredential ("$machine\$username", $Spassword)

try {
    $services = @(Get-WmiObject Win32_Service -ComputerName $machine -Credential $MachineCred | Where-Object{ ($_.StartName -like ".\*") -and $_.StartName -notlike "*NT *" })
} catch {
    if ($debug) {
        (get-date).ToString() + $_.Exception.Message + " `t" | Out-File -FilePath $errorfile -Append
    }
    throw $_.Exception.Message
}
#In those accounts, find the ones that are local accounts, and add them to an array.
if ($services.count -ne 0) {
    $serviceAccounts = @()
    $services.ForEach({
            $object = New-Object –TypeName PSObject;
            $object | Add-Member -MemberType NoteProperty -Name ServiceName -Value $_.DisplayName;
            $object | Add-Member -MemberType NoteProperty -Name Username -Value $(if($_.startname.contains("\")) { $_.startname.split("\")[1] });
            $object | Add-Member -MemberType NoteProperty -Name Machine -Value $machine;
            $serviceAccounts += $object
        });

    if ($debug) {
        (get-date).ToString() + "   # Dependencies Found " + $serviceAccounts.Count + " `t" | Out-File -FilePath $errorfile -Append
        $serviceAccounts | ConvertTo-Json | Out-File -FilePath $errorfile -Append
    }
    return $serviceAccounts
} else {
    if ($debug) {
        (get-date).ToString() + "No local account dependencies found `t" | Out-File -FilePath $errorfile -Append
    }
    throw "No local account dependencies found"
}