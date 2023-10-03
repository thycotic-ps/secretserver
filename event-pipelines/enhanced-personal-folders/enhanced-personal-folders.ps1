#test
if ($args.count -gt 4) {[string]$APIUsername = $args[4],$args[0] -join "\"}else{[string]$APIUsername = $args[0]}
[securestring]$APIPassword =  ConvertTo-SecureString $args[1] -AsPlainText -Force
$Username = $args[2]
$FolderName = $args[3]

$SecretServerURL = "https://server/url"
$PFolderBaseID = 0
$FolderOwnerUsers = @("Manager1","Manager2")
$FolderOwnerGroups =  @("ManagementGroup")
$AllowedTemplateIDs = @()

#$logFile = "c:\temp\ss-EnhancedPersonalFolders.log"
#(get-date).ToString() + ":`t" + $args[0,2,3] | Add-Content -path $logFile

try {
    $Session = New-TssSession -SecretServer $SecretServerURL -Credential (New-Object System.Management.Automation.PSCredential ($APIUsername, $APIPassword))
    $existingFolder = Search-TssFolder -TssSession $Session -ParentFolderId $PFolderBaseID -SearchText $FolderName
    if ($null -eq $existingFolder) {
        $newFolder = New-TssFolder -TssSession $Session -FolderName $FolderName -ParentFolderId $PFolderBaseID -InheritPermissions:$false
        foreach ($OwnerUserName in $FolderOwnerUsers){Add-TssFolderPermission -TssSession $Session -FolderId $newFolder.id -UserName $OwnerUserName -FolderRole "owner" -SecretRole "owner" | Out-Null}
        foreach ($GroupName in $FolderOwnerGroups){Add-TssFolderPermission -TssSession $Session -FolderId $newFolder.id -Group $GroupName -FolderRole "owner" -SecretRole "owner" | Out-Null}
        Add-TssFolderPermission -TssSession $Session -FolderId $newFolder.id -Username $username -FolderRole "add secret" -SecretRole "edit" | Out-Null
        if ($AllowedTemplateIDs.count -gt 0){set-TssFolder -TssSession $Session -Id $newFolder.id -AllowedTemplate $AllowedTemplateIDs}
    }else{Write-Verbose ("Folder Exists:" + $existingFolder.FolderId)}
}Catch{if ($null -ne $logFile){(get-date).ToString() + ":`t" + $_ | Add-Content -path $logFile}else{write-error $_}}

