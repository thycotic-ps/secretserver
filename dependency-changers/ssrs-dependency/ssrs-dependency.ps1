# Expected arguments: "$SERVICENAME" $MACHINE $[1]$DOMAIN $[1]$USERNAME $[1]$PASSWORD $PASSWORD
$dsPath = $args[0] # '/Shared Data Sources/dev data warehouse'
$rsUri = $args[1] # 'http://abccompany.local/ReportServer'
$privAccount = $args[2], $args[3] -join '\'
$privPassword = ConvertTo-SecureString -String $args[4] -AsPlainText -Force
$password = $args[5]

if (-not (Get-Module -Name ReportingServicesTools -ListAvailable)) {
    throw "Please install ReportingServicesTools PowerShell module"
}
$rsCred = [pscredential]::new($privAccount,$privPassword)
$rsProxy = New-RsWebServiceProxy -ReportServerUri $rsUri -Credential $rsCred

try {
    $ds = Get-RsDataSource -ReportServerUri $rsUri -Path $dsPath -Proxy $rsProxy
} catch {
    throw "Error retrieving Data Source [$dsPath]: $($_)"
}
if ($ds) {
    try {
        Set-RsDataSourcePassword -Path $dsPath -Proxy $rsProxy -Password $password -ErrorAction Stop
    } catch {
        throw "Error updating Data Source [$dsPath]"
    }
} else {
    throw "Data Source [$dsPath] not retrieved successfully"
}