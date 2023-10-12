# Group modification via checkout hook
These scripts can be used in checkout hooks or event pipeline to modify user group memberships

## Usage
Add these scritps to the check-in check-out processes. 

If using CredSSP the arguments are
`$Username GroupToModify`

If not using CredSSP (default) the arguments are
### checkout hook
`$Username GroupToModify $[1]$Domain  $[1]$Username  $[1]$password`
### event pipeline
`$Username GroupToModify $[add:1]$Domain  $[add:1]$Username  $[add:1]$password`

To customize domain controller edit the variable `$HardcodeDomainController `
