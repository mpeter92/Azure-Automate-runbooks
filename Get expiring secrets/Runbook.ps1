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
$DaysUntilExpiration = 90
$IncludeAlreadyExpired = yes

# Creation of the results table
$arrOutput = [System.Collections.Generic.List[Object]]::new()

# Loop through each app and store the data in the variable arrOutput
$Now = Get-Date
$Applications = Get-MgApplication -all
$Logs = @()

foreach ($App in $Applications) {
    $AppName = $App.DisplayName
    $AppID   = $App.Id
    $ApplID  = $App.AppId

    $AppCreds = Get-MgApplication -ApplicationId $AppID |
        Select-Object PasswordCredentials, KeyCredentials

    $Secrets = $AppCreds.PasswordCredentials
    $Certs   = $AppCreds.KeyCredentials

    foreach ($Secret in $Secrets) {
        $StartDate  = $Secret.StartDateTime
        $EndDate    = $Secret.EndDateTime
        $SecretName = $Secret.DisplayName

        $Owner    = Get-MgApplicationOwner -ApplicationId $App.Id
        $Username = $Owner.AdditionalProperties.userPrincipalName -join ';'
        $OwnerID  = $Owner.Id -join ';'

        if ($null -eq $Owner.AdditionalProperties.userPrincipalName) {
            $Username = @(
                $Owner.AdditionalProperties.displayName
                '**<This is an Application>**'
            ) -join ' '
        }
        if ($null -eq $Owner.AdditionalProperties.displayName) {
            $Username = '<<No Owner>>'
        }

        $RemainingDaysCount = ($EndDate - $Now).Days

        if ($IncludeAlreadyExpired -eq 'No') {
            if ($RemainingDaysCount -le $DaysUntilExpiration -and $RemainingDaysCount -ge 0) {
                $Logs += [PSCustomObject]@{
                    'ApplicationName'        = $AppName
                    'ApplicationID'          = $ApplID
                    'Secret Name'            = $SecretName
                    'Secret Start Date'      = $StartDate
                    'Secret End Date'        = $EndDate
                    'Certificate Name'       = $Null
                    'Certificate Start Date' = $Null
                    'Certificate End Date'   = $Null
                    'Owner'                  = $Username
                    'Owner_ObjectID'         = $OwnerID
                }
            }
        } elseif ($IncludeAlreadyExpired -eq 'Yes') {
            if ($RemainingDaysCount -le $DaysUntilExpiration) {
                $Logs += [PSCustomObject]@{
                    'ApplicationName'        = $AppName
                    'ApplicationID'          = $ApplID
                    'Secret Name'            = $SecretName
                    'Secret Start Date'      = $StartDate
                    'Secret End Date'        = $EndDate
                    'Certificate Name'       = $Null
                    'Certificate Start Date' = $Null
                    'Certificate End Date'   = $Null
                    'Owner'                  = $Username
                    'Owner_ObjectID'         = $OwnerID
                }
            }
        }
    }

    foreach ($Cert in $Certs) {
        $StartDate = $Cert.StartDateTime
        $EndDate   = $Cert.EndDateTime
        $CertName  = $Cert.DisplayName

        $Owner    = Get-MgApplicationOwner -ApplicationId $App.Id
        $Username = $Owner.AdditionalProperties.userPrincipalName -join ';'
        $OwnerID  = $Owner.Id -join ';'

        if ($null -eq $Owner.AdditionalProperties.userPrincipalName) {
            $Username = @(
                $Owner.AdditionalProperties.displayName
                '**<This is an Application>**'
            ) -join ' '
        }
        if ($null -eq $Owner.AdditionalProperties.displayName) {
            $Username = '<<No Owner>>'
        }

        $RemainingDaysCount = ($EndDate - $Now).Days

        if ($IncludeAlreadyExpired -eq 'No') {
            if ($RemainingDaysCount -le $DaysUntilExpiration -and $RemainingDaysCount -ge 0) {
                $Logs += [PSCustomObject]@{
                    'ApplicationName'        = $AppName
                    'ApplicationID'          = $ApplID
                    'Secret Name'            = $Null
                    'Certificate Name'       = $CertName
                    'Certificate Start Date' = $StartDate
                    'Certificate End Date'   = $EndDate
                    'Owner'                  = $Username
                    'Owner_ObjectID'         = $OwnerID
                    'Secret Start Date'      = $Null
                    'Secret End Date'        = $Null
                }
            }
        } elseif ($IncludeAlreadyExpired -eq 'Yes') {
            if ($RemainingDaysCount -le $DaysUntilExpiration) {
                $Logs += [PSCustomObject]@{
                    'ApplicationName'        = $AppName
                    'ApplicationID'          = $ApplID
                    'Secret Name'            = $Null
                    'Certificate Name'       = $CertName
                    'Certificate Start Date' = $StartDate
                    'Certificate End Date'   = $EndDate
                    'Owner'                  = $Username
                    'Owner_ObjectID'         = $OwnerID
                    'Secret Start Date'      = $Null
                    'Secret End Date'        = $Null
                }
            }
        }
    }
}

$arrOutput.AddRange($Logs)

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
