function Get-Token
{
    [CmdletBinding()]
    param(
        $credentials,
        [Switch] $UseTwoFactor
    )

    $creds = @{
        username = $credentials.UserName
        password = $credentials.GetNetworkCredential().Password
        grant_type = "password"
    };

    $headers = $null
    If ($UseTwoFactor) {
        $headers = @{
            "OTP" = (Read-Host -Prompt "Enter your OTP for 2FA: ")
        }
    }

    try
    {
        $response = Invoke-RestMethod "$application/oauth2/token" -Method Post -Body $creds -Headers $headers;
        $token = $response.access_token;
        return $token;
    }
    catch
    {
        $result = $_.Exception.Response.GetResponseStream();
        $reader = New-Object System.IO.StreamReader($result);
        $reader.BaseStream.Position = 0;
        $reader.DiscardBufferedData();
        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "ERROR: $($responseBody.error)"
        return;
    }
}
if ($args.count -gt 4) {[string]$APIUsername = $args[4],$args[0] -join "\"}else{[string]$APIUsername = $args[0]}
[securestring]$APIPassword =  ConvertTo-SecureString $args[1] -AsPlainText -Force
$UsernameID = $args[2]
$FolderName = $args[3]

$credentials = [PSCredential]::new($APIUsername, $APIPassword)
###### ADD YOUR URL ##########
$application = "https://CHANGE.secretservercloud.com"
$Token = Get-Token -credentials $credentials
$headers = @{"Authorization"="Bearer $token"}
$body = @{}

######### CHANGE ##########
$PFolderBaseID = 0
$FolderOwnerUsers = @("Manager1","Manager2")
$FolderOwnerGroups =  @("ManagementGroup")
$AllowedTemplateIDs = @()

#############################

#$logFile = "c:\temp\ss-EnhancedPersonalFolders.log"
#(get-date).ToString() + ":`t" + $args[0,2,3] | Add-Content -path $logFile

try {
    $Token = Get-Token -credentials $credentials
    $headers = @{"Authorization"="Bearer $token"}

    #Does folder exist
    $existingFolder = Invoke-RestMethod "$application/api/v1/folders?filter.parentFolderId=$PFolderBaseID&filter.searchText=$FolderName" -Method 'GET' -Headers $headers

    if ($existingFolder.total -lt 1) {
         
        #Create new folder
        $body = @{
            "folderName"= "$foldername"
            "folderTypeId"= "1"
            "parentFolderId"= "$PFolderBaseID"
            "inheritPermissions"= "false"
            "inheritSecretPolicy"= "true"
            "secretPolicyId"= "-1"
          }
          $newFolder = Invoke-RestMethod "$application/api/v1/folders" -Method 'POST' -Headers $headers -Body $body
          $newFolder = $newFolder.id
        
        foreach ($OwnerUserName in $FolderOwnerUsers){
            #Set permission for users
            $body = @{}            
            $getUser = Invoke-RestMethod "$application/api/v1/users/lookup?filter.includeInactive=false&filter.searchFields=username&filter.searchText=$OwnerUserName" -Method 'GET' -Headers $headers
            $getUser = $getUser.records.id
            $body = @{
                "breakInheritance"= "true"
                "folderAccessRoleName"= "Owner"
                "folderId"= "$newFolder"
                "groupId"= ""
                "secretAccessRoleName"= "Owner"
                "userId"= "$getUser"
              }
            
            $response = Invoke-RestMethod "$application/api/v1/folder-permissions" -Method 'POST' -Headers $headers -Body $body
        }

        foreach ($GroupName in $FolderOwnerGroups){
            #Set permission for groups
            $GetGroup = Invoke-RestMethod "$application/api/v1/groups?filter.includeInactive=false&filter.searchText=$groupname" -Method 'GET' -Headers $headers
            $GetGroup = $GetGroup.records.ID
            $body = @{
                "breakInheritance"= "true"
                "folderAccessRoleName"= "Owner"
                "folderId"= "$newFolder"
                "groupId"= "$getGroup"
                "secretAccessRoleName"= "Owner"
                "userId"= ""
              }
            
            $response = Invoke-RestMethod "$application/api/v1/folder-permissions" -Method 'POST' -Headers $headers -Body $body
        
        }

        #Set permission for target user !!! Argument is user ID not user!!!!
        $body = @{
            "breakInheritance"= "true"
            "folderAccessRoleName"= "Owner"
            "folderId"= "$newFolder"
            "groupId"= ""
            "secretAccessRoleName"= "Owner"
            "userId"= "$usernameID"
          }
        
        $response = Invoke-RestMethod "$application/api/v1/folder-permissions" -Method 'POST' -Headers $headers -Body $body



        if ($AllowedTemplateIDs.count -gt 0){
            #Set allowed templates
            $body = '{
                "data": {
                  "allowedTemplates": []
                }
              }'
              $body = $body | ConvertFrom-Json
            foreach ($template in $AllowedTemplateIDs){
            $body.data.allowedTemplates += $template

            }
            $body = $body | Convertto-Json
            $response = Invoke-RestMethod "$application/api/v1/folder/$newfolder"  -Method 'PATCH' -ContentType "application/json" -Headers $headers -Body $body

        }
    }else{Write-Verbose ("Folder Exists:" + $existingFolder.records.id)}
}Catch{if ($null -ne $logFile){(get-date).ToString() + ":`t" + $_ | Add-Content -path $logFile}else{write-error $_}}
