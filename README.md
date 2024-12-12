# AzureAutomate
This guide will give steps to create an azure automate runbook to find a list of inactive users and email them.
**
# Step 1

Install the Microsoft Graph powershell module and the Exchange online powershell module
open powershell with administrator rights and run the following command.
* Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
* https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0
  

When thats complete run the following command to install the exchange online powershell module.
* Install-Module -Name ExchangeOnlineManagement
* https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-and-maintain-the-exchange-online-powershell-module


# Step 2
Open Your azure portal and go to Automation accounts.

* https://portal.azure.com/#browse/Microsoft.Automation%2FAutomationAccounts <br />

* click create
![image](https://github.com/user-attachments/assets/d4e6c6d6-ed3f-4eb5-992a-3dc7a2019050)

* enter a name and create resource group for the account.
* Ensure System assigned managed Identity is selected under advanced.
* Leave rest of settings as they are and click create.







