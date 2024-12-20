# Email the inactive users with Azure Automation accounts.
This guide will give steps to create an azure automate runbook to find a list of inactive users and email them.

## DISCLAIMER:
 
This code-sample is provided "AS IS" without warranty of any kind, either expressed or implied,
including but not limited to the implied warranties of merchantability and/or fitness for a
particular purpose.

The author further disclaims all implied warranties including, without limitation, any implied
warranties of merchantability or of fitness for a particular purpose.
 
The entire risk arising out of the use or performance of the sample and documentation remains with
you.
 
In no event shall the authors, or anyone else involved in the creation, production, or
delivery of the script be liable for any damages whatsoever (including, without limitation, damages
for loss of business profits, business interruption, loss of business information, or other
pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if the author
has been advised of the possibility of such damages.

<br />

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
* be sure to modify the script with your Managed Identity object id, the mailbox you want to send from and your admin address to connect to exchangeonline
![image](https://github.com/user-attachments/assets/9d1c3c4b-11a9-4594-98bd-c1c3049edfc2)


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
1. If you want to test the run book with just getting a list of inactive users you can paste in the code from getusers.ps1. The script is configured to get inactive users older than 60 days. you can modify this.
2. To configure the runbook to email the inactive users. Paste in the code from runbook.ps1
* be sure to enter the mailbox we are sending from on line 13
* ![image](https://github.com/user-attachments/assets/e9fa3b7f-221d-44eb-a430-6702723d961c)
* The runbook is configured to look for inactivity older than 60 days but you can modify this on line 15.
*  You may need to wait a few minutes for the modules from step 6 to install otherwise you may see an error in the following section that hte module is not found. If you see this error confirm the modules are installed and just wait a few minutes and try again.
<br />

## Step 8 - Test the runbook to ensure it runs ok
Test it first before publishing it. 
Note!!! this will send emails to the users it finds as inactive so if you want to test before emailing you can
* ![image](https://github.com/user-attachments/assets/338032b2-1415-42e0-9b78-5217cd5db30f)

## Step 9 - Publish and add a schedule.
Now that we have confirmed the runbook works as it should we can publish it and automate it so it runs on a schedule.
* in the edit page click publish to publish the runbook. You can leave it here if you want to manually run each time or continue to add the schedule
* To add the schedule click Schedules under Resources.
* Click add a schedule
* click link a schedule to your runbook
* Click add a schedule
* Set the parameters of the schedule, create and add to your runbook.


  

