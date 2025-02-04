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
$recipient ="admin1@domain.com"
$recipientCC = "admin2@domain.com"


# Creation of the results table
$arrOutput = [System.Collections.Generic.List[Object]]::new()

# Loop through each user and store their data in the variable arrOutput
Foreach ($user in Get-MgUser -All -Select id,userPrincipalName,displayName,accountEnabled,onPremisesSyncEnabled,createdDateTime,signInActivity) {
    $lastsignin = $null
    if ($user.signInActivity -ne $null) {
        $lastsignin = $user.signInActivity.lastSignInDateTime
    }
    $ObjUsers = New-Object PSObject
    $ObjUsers | Add-Member NoteProperty -Name "Object ID" -Value $user.id
    $ObjUsers | Add-Member NoteProperty -Name "Display Name" -Value $user.displayName
    $ObjUsers | Add-Member NoteProperty -Name "User Principal Name" -Value $user.userPrincipalName
    $ObjUsers | Add-Member NoteProperty -Name "Account Enabled" -Value ($user.accountEnabled -ne $null)
    $ObjUsers | Add-Member NoteProperty -Name "onPremisesSyncEnabled" -Value ($user.onPremisesSyncEnabled -ne $null)
    $ObjUsers | Add-Member NoteProperty -Name "Created DateTime (UTC)" -Value ($user.createdDateTime.ToString("dd-MM-yyyyTHH:mm:ssZ"))
    if ($lastsignin -ne $null) {
        $ObjUsers | Add-Member NoteProperty -Name "Last Success Signin (UTC)" -Value ($lastsignin.ToString("dd-MM-yyyyTHH:mm:ssZ"))
    } else {
        $ObjUsers | Add-Member NoteProperty -Name "Last Success Signin (UTC)" -Value "N/A"
    }
    $arrOutput.Add($ObjUsers) 
}

# Get the current date in the desired format
$currentDate = (Get-Date).ToString('dd-MM-yyyy')

# Convert the results to CSV format in memory
$csvContent = $arrOutput | Sort-Object UserPrincipalName, "Last Success Signin (UTC)" | ConvertTo-Csv -NoTypeInformation -Delimiter ',' | Out-String
$csvBytes = [System.Text.Encoding]::UTF8.GetBytes($csvContent)
$csvBase64 = [System.Convert]::ToBase64String($csvBytes)

# Email script
$apiquery = "https://graph.microsoft.com/v1.0/users/$mailbox/sendMail"
$emailBody = @{
    message = @{
        subject = "Sign in logs"
        body = @{
            contentType = "Text"
            content = "Sign in logs report."
        }
        toRecipients = @(@{ emailAddress = @{ address = $recipient } })
        ccRecipients = @(@{ emailAddress = @{ address = $recipientCC } })
        attachments = @(@{
            '@odata.type' = '#microsoft.graph.fileAttachment'
            name = "SignInReport_$currentDate.csv"
            contentBytes = $csvBase64
        })
    }
    saveToSentItems = $false
}

# Convert the email body to JSON
$emailBodyJson = $emailBody | ConvertTo-Json -Depth 10

# Define Headers
$Headers = @{
  "Authorization" = "Bearer $($SecretToken)"
  "Content-type"  = "application/json"
}

# Send the email
$apicall = Invoke-RestMethod -Uri $apiquery -Method POST -Headers $Headers -Body $emailBodyJson

# Output the path of the CSV file
Write-output "Report generated and emailed"
