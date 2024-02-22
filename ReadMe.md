# ---------------------------------------ReadMe File------------------------------------------------#
## The purpose of this ReadMe file is to guide the user to execute this particular terraform scripts at ease having basic knowledge about Azure & terraform. ##

### --------------Prerequisites for executing the scripts.---------------------###
Need to have VS code editor to create, change & manage terraform files as per requirements.
For running terraform scripts you must have terraform installed in your system. For checking if terraform is  installed or not run the following command in command prompt.

 >   terraform -version

The above command shows the terraform version. In case if is not showing in yours then either terraform is not installed or the path has not been set correctly. Kindly follow the below links for download & installation.

Download [Link]  https://www.terraform.io/downloads

Installation [Link]  https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform

Also make sure Azure cli is installed in your system for login purposes to azure.

Download [Link] https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

### --------------------------------------------Prerequisites over----------------------------------------###


### -------------------------------Commands to setup your azure account-----------------------------------###
- Open the terraform folder containing .tf files in your visual studio code editor
- Open terminal in visual studio code & the terminal will show the complete path of terraform folder.

 Run the following command to login to your azure account:
 >       az login

 The below command shows the account in which you are already logged in.
 >       az account show

 If you have multiple subscriptions in your directory set the subscription in which you want to deplpoy the infra
 >       az account set --subscription="your_subscription_ID"

 If you are not in right directory change the directory using below command & set your subscription using above command.
 >       az login --tenant <myTenantID>

 Run the below command in windows powershell as our code conatins powershell file also.
 >       Connect-AzAccount
 If you are not in right directory change the directory using below command & set your subscription using above command.
 >  Connect-AzAccount -TenantId <>
 >   Set-AzContext -Subscription <>
### -------------------------------Azure Account setup completed-----------------------------------###
### -------------------Terraform commands to execute the script-------------------###
The part which is in green color in .tf files are either instruction or information about the resource & need not to be worried about.

- Change the name of resources in variables.tf file according to your requirement.
- Change the RG & workspace name in Final-UC-Deployment.ps1 & linux_syslog.ps1 file.
- Change the subscription ID & email ID where you want to receive the mail about analytic rules deployed in Final-UC-Deployment.ps1
- Final-UC-Deployment.ps1 contains the path of csv file which contains the custom use cases which needs to be deployed. Change the path where you have kept your csv file.
- jsonplaybook PowerShell file contains the RG name(must be same name as in variables.tf) and path of json playbook which needs to be changed with the path where you have kept your playbooks.
- AzSentinel powershell needs some changes such as rg,workspace,sub id and few other things before deployment.

- Give the values if any in terraform.tfvars. In our case it contains the username & password of virtual machine.

Run the below commands in the same order to deploy the infra.
- The below command is used to initialize the working directory,initialize the backend config,install the required  plugins for providers & install required modules for your code.
>           terraform init
After running this command [.terraform] folder & [.terraform.lock.hcl] is created

- Run the below command if you want to check syntax of your code (not mandatory).
>           terraform validate

- The below command is used to show what resources are going to be deployed in your portal.
>           terraform plan

- The below commands are used to deploy the infrastructure.Run any one of the below commands
With prompt:
>       terraform apply
Without prompt:
>       terraform apply -auto-approve

Once the infra is deployed, [terraform.tfstate] & [terraform.tfstate.backup] is created which contains metadata about the infra deployed. Kindly handle this file carefully.

If you want to destroy the infrastructure, run any one of the below commands
With prompt:
>       terraform destroy
Without prompt:
>       terraform destroy -auto-approve

Important Notes: 
- After the infra is deployed, You need to wait for atleast 10 minutes (depending on each data connectors) for the data connectors to be enabled as logs takes time to generate.
- After infra is destroyed & you want to deploy the infra again, you can delete [.terraform] folder , [.terrafor.lock.hcl], [terraform.tfstate] & [terraform.tfstate.backup] & start fresh deployment. Make sure to give new name to KeyVault (Globally unique),RG name & worskapce to prevent any unexpected error.
### -------------------------Infra deployment is completed---------------------------------------###

