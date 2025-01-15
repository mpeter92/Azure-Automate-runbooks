# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All","AppRoleAssignment.ReadWrite.All,RoleManagement.ReadWrite.Directory"

#enter the managed identity object id here from step 3.
$managedIdentityId = "xxxxxxxxxxxxxxxxxxxxxxxxxx"

$graphApp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

$graphScopes = @(
  'UserAuthenticationMethod.Read.All',
  'Group.ReadWrite.All',
  'Directory.Read.All',
  'User.ReadWrite.All',
  'mail.send',
  'AuditLog.Read.All'
)

ForEach($scope in $graphScopes){
  $appRole = $graphApp.AppRoles | Where-Object {$_.Value -eq $scope}
  New-MgServicePrincipalAppRoleAssignment -PrincipalId $managedIdentityId -ServicePrincipalId $managedIdentityId -ResourceId $graphApp.Id -AppRoleId $appRole.Id
}

