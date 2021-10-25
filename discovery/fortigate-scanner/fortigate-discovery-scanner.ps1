$target = $args[0]
$username = $args[1]
$password = ConvertTo-SecureString -String $args[2] -AsPlainText -Force

Import-Module posh-ssh
$cred = New-Object -TypeName System.Management.Automation.PSCredential ($username, $password)
try{
    $session = New-SSHSession -ComputerName $Target -Credential $cred -ConnectionTimeout 99999 -AcceptKey -Force
    $SSHStream = New-SSHShellStream -SSHSession $session
    Start-Sleep -Seconds 5
    $SSHStream.WriteLine("get system admin | grep name")
    Start-Sleep -Seconds 2
    $Output = $SSHStream.Read()
    $SSHStream.WriteLine("exit")
    $SSHStream.Close()
    $accounts = @()
    $result = $Output -split "`n" | Select-String "name:" -AllMatches
    foreach($line in $result){
        $account = "" | Select-Object Machine, UserName
        $account.username = $($line -split ": ")[1];
        $account.Machine = $target;
        $accounts += $account
    }

    if($accounts.count -ne 0){
        return $accounts
    } else {
        throw "No Accounts Found"
    }
} catch{
    throw "Invalid Password, please ensure the password is correct." + $_
}