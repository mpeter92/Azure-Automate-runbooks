# AzureAutomate
This guide will give steps to create an azure automate runbook to find a list of inactive users and email them.
**
## Step 1 - Install the graph and exchange powershell modules

Install the Microsoft Graph powershell module and the Exchange online powershell module
open powershell with administrator rights and run the following command.
* Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
* https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0
  

When thats complete run the following command to install the exchange online powershell module.
* Install-Module -Name ExchangeOnlineManagement
* https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-and-maintain-the-exchange-online-powershell-module
<br />

## Step 2 - Create the automation account
Open Your azure portal and go to Automation accounts.

* https://portal.azure.com/#browse/Microsoft.Automation%2FAutomationAccounts <br />
* click create
* ![image](https://github.com/user-attachments/assets/d4e6c6d6-ed3f-4eb5-992a-3dc7a2019050)
* enter a name and create resource group for the account.
* Ensure System assigned managed Identity is selected under advanced.
* Leave rest of settings as they are and click create.
<br />

## Step 3 - Save the managed identity ID
Go to your newly created automation account and click
* 1 Acount settings
* 2 Identity
* 3 Copy the object ID as we will need it later.
* ![image](https://github.com/user-attachments/assets/53a9d2bd-0984-4df5-bc53-a4fe652c3161)
<br />

## Step 4 - Give the Manged Identity the exchange permission
Now that we have the object id you can give the managed identity permission to send emails on behalf of your mailbox.
* Copy the script from exchangepermission.ps1 to powershell ISE.
* be sure to modify the script with your Managed Identity object id and the mailbox you want to send from.
<br />

## Step 5 - Give the Manged Identity the graph permission
Next step is the give the managed identity graph permission so it can per for the tasks needed.
* Copy the script from graphpermission.ps1 to powershell ISE.
* be sure to modify the script with your Managed Identity object id and the mailbox you want to send from.
<br />

## Step 6 - Install the modules on the automation account.
Now we need to install the graph modules in the automate account
* in the automation account click Shared resources
* Modules
* Add a module
* ![image](https://github.com/user-attachments/assets/425949ba-9f5b-4101-b015-b944d4bd6fcc)
* Click browse from gallery
* ![image](https://github.com/user-attachments/assets/0b91e696-5cb1-4ba0-8451-ff3b2ab6bdaf)
* Search for and install Microsoft.Graph.Authentication
* Search for and install Microsoft.Graph.Users
* select the 7.2 runtime version for each.
<br />

## Step 7 - Create runbook
Now we can create the runbook to get the inactive users and email them.
* under your automation account click process automation
* Runbooks
* Create a runbook
* ![image](https://github.com/user-attachments/assets/46f93840-faac-4bb6-8768-f0af1c00a862)
* Fill in the required information and click create
* ![image](https://github.com/user-attachments/assets/e210f2d5-e281-4665-bdcb-cf438d4e1255)
* Paste in the code from runbook.ps1
* be sure to enter the mailbox we are sending from on line 13
* ![image](https://github.com/user-attachments/assets/e9fa3b7f-221d-44eb-a430-6702723d961c)
* The runbook is configured to look for inactivity older than 60 days but you can modify this on line 15.



  

