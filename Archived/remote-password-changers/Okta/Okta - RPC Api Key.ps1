# Expected Args @("Okta User ID","Okta User Id" , "New Password" , "Okta Root Instance"  , "Okta API Key")

$userid = $arg[0]
$domain = $arg[1]
$newpassword = $arg[2]
$instance = $arg[3]
$apikey = $arg[4]
$userid = $userid,$domain -join "@"

# Cretae Headers 
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "SSWS $apikey")
 
$body = @{
  "credentials" = @{
    "password" = @{ "value" = $newpassword }
  }
} | ConvertTo-Json -Depth 3
 
try {
$url = "https://$instance/api/v1/users/$userid"
Invoke-RestMethod -Uri $url -Method 'PUT' -Headers $headers -Body $body | Out-Null
} catch {
    throw $_
}
