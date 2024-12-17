# Enter the managed identity that was collected in step 3 of the readme.
$managedIdentityId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Enter the mailbox you want to send the emails from
$mailbox = "info@domain.com"

#Enter the upn of the global admin on this line
Connect-ExchangeOnline -UserPrincipalName Globaladmin@domain.com

New-ApplicationAccessPolicy -AppId $managedIdentityId -PolicyScopeGroupId $mailbox -AccessRight RestrictAccess -Description "Restrict this app to members of distribution group EvenUsers."
