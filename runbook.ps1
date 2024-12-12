try {
    # Logging in to Azure.
    Connect-AzAccount -Identity
    $token = ((Get-AzAccessToken -AsSecureString -ResourceTypeName MSGraph).token)
    $secretToken = ((Get-AzAccessToken -ResourceTypeName MSGraph).token)
    # Get token and connect to MgGraph
    Connect-MgGraph -AccessToken $token
} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$mailbox = "info@domain.com"

$daysago = 60
# $daysago = Read-Host "Find users who have not signed in in how many days:"
$date = (Get-Date).AddDays(-$daysago)

# Creation of the results table
$arrOutput = [System.Collections.Generic.List[Object]]::new() # Create output file for report

# Loop through each user and store their data in the variable arrOutput.
Foreach ($user in Get-MgUser -All -Select id,userPrincipalName,displayName,accountEnabled,onPremisesSyncEnabled,createdDateTime,signInActivity) {
    $lastsignin = ($user.signInActivity).lastSignInDateTime
    if ($lastsignin -lt $date) {
        $ObjUsers = New-Object PSObject
        $ObjUsers | Add-Member NoteProperty -Name "Object ID" -Value $user.id
        $ObjUsers | Add-Member NoteProperty -Name "Display Name" -Value $user.displayName
        $ObjUsers | Add-Member NoteProperty -Name "User Principal Name" -Value $user.userPrincipalName
        if ($user.accountEnabled) {
            $ObjUsers | Add-Member NoteProperty -Name "Account Enabled" -Value $user.accountEnabled
        } else {
            $ObjUsers | Add-Member NoteProperty -Name "Account Enabled" -Value "False"
        }
        if ($user.onPremisesSyncEnabled) {
            $ObjUsers | Add-Member NoteProperty -Name "onPremisesSyncEnabled" -Value $user.onPremisesSyncEnabled
        } else {
            $ObjUsers | Add-Member NoteProperty -Name "onPremisesSyncEnabled" -Value "False"
        }
        $ObjUsers | Add-Member NoteProperty -Name "Created DateTime (UTC)" -Value $user.createdDateTime
        if ($lastsignin) {
            $ObjUsers | Add-Member NoteProperty -Name "Last Success Signin (UTC)" -Value $lastsignin
        } else {
            $ObjUsers | Add-Member NoteProperty -Name "Last Success Signin (UTC)" -Value "N/A"
        }
        $arrOutput.Add($ObjUsers)
    } 
}

# Exportation of the results

Write-output "User Sign-In Report"
Write-output "=================="
foreach ($item in $arrOutput | Sort-Object 'User Principal Name', 'Last Success Signin (UTC)') {
    Write-output "User Principal Name: $($item.'User Principal Name')"
    Write-output "Last Success Signin (UTC): $($item.'Last Success Signin (UTC)')"
    Write-output "------------------------"
}

Write-output ""
Write-output ""

Write-output "Emailing users"
$Headers = @{
 "Authorization" = "Bearer $($secretToken)"
 "Content-type"  = "application/json"
}
foreach ($user in $arrOutput) {
   $apiquery = "https://graph.microsoft.com/v1.0/users/$mailbox/sendMail"
   
   $emailBody = @{
       message = @{
           subject = "Inactive use"
           body = @{
               contentType = "Text"
               content = "Your account has been inactive for $daysago days."
           }
           toRecipients = @(@{ emailAddress = @{ address = $user.'User Principal Name' } })
       }
       saveToSentItems = $false
   }
   
   # Convert the email body to JSON
   $emailBodyJson = $emailBody | ConvertTo-Json -Depth 10
   
   # Send the email
   $apicall = Invoke-RestMethod -Uri $apiquery -Method POST -Headers $Headers -Body $emailBodyJson
   Write-output "Emailing $($user.'User Principal Name')"
}
