$SecretServerUrl = $args[0]
$SSUser = $args[1]
$SSPassword = $args[2]
$ReportId = $args[3]
$SecretId = $args[4]
$MasAccountNumber = $args[5]
$ByUser = $args[6]
$EventUserId = $args[7]

#region Static values
$baseInforURL = '<url>/sdata/slx/dynamic/-/vstargateabbrevs'
$soapUrl = "$SecretServerUrl/webservices/sswebservice.asmx"
#endregion Static values

#region Token request
$credential = [pscredential]::new($SSUser,(ConvertTo-SecureString $SSPassword -AsPlainText -Force))
$apiUrl = "$SecretServerUrl/api/v1"

$Body = @{
    "grant_type" = "password"
    "username"   = $Credential.UserName
    "password"   = $Credential.GetNetworkCredential().Password
}

$token = Invoke-RestMethod -Method Post -Uri "$SecretServerUrl/oauth2/token" -Body $Body | Select-Object -ExpandProperty access_token

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")
#endregion Token request

#region pull data
$reportBody = @{
    id         = "$ReportId"
    parameters = @(
        @{
            Name  = "CustomText"
            Value = "$SecretId"
        }
    )
} | ConvertTo-Json

$ticketNumber = Invoke-RestMethod "$apiUrl/reports/execute" -Method 'POST' -Headers $headers -Body $reportBody -ContentType 'application/json' | Select-Object -ExpandProperty rows
$urlMetadata = [PSCustomObject]@{
    TicketNumber     = $ticketNumber[0]
    MasAccountNumber = $MasAccountNumber
}
#endregion pull data

#region CRM validation
$inforUrl = "$baseInforURL('$($urlMetadata.MasAccountNumber)-$($urlMetadata.TicketNumber)')"
try {
    $InforCrmResponse = Invoke-WebRequest -Uri $inforUrl
} catch {
    $auditMsg = "$ByUser | $($urlMetadata.TicketNumber) | $SecretId | $($urlMetadata.MasAccountNumber) | 'ticket could not be validated'"
}
if ($InforCrmResponse.SatusCode -eq 200) {
    [xml]$inforXml = $InforCrmResponse.Content
    if ($inforXml.diagnoses) {
        if ($inforXml.dianoses.daignosis.message -match "not found") {
            $auditMsg = "$ByUser | $($urlMetadata.TicketNumber) | $SecretId | $($urlMetadata.MasAccountNumber) | 'ticket not found'"
        }
    } elseif ($inforXml.entry) {
        switch ($inforXml.entry.payload.Vstargateabbrev.Result) {
            "Invalid-Closed" {
                $auditMsg = "$ByUser | $($urlMetadata.TicketNumber) | $SecretId | $($urlMetadata.MasAccountNumber) | 'ticket invalid or closed'"
            }
            "Valid*" {
                $auditMsg = "$ByUser | $($urlMetadata.TicketNumber) | $SecretId | $($urlMetadata.MasAccountNumber) | 'ticket valid'"
            }
            default {
                $auditMsg = "$ByUser | $($urlMetadata.TicketNumber) | $SecretId | $($urlMetadata.MasAccountNumber) | $($inforXml.entry.payload.Vstargateabbrev.Result)"
            }
        }
    }
}
#region CRM validation

#region soap - write custom audit
$soap = New-WebServiceProxy -Uri $soapUrl -Namespace 'ss'
$result = $soap.AddSecretCustomAudit($token,$SecretId,$auditMsg,$null,$null,$null,$EventUserId)
if ($result.Errors) {
    throw "Issue writing audit message to secret $SecretId [$($result.Errors)]"
}
#endregion soap - write custom audit