
##Variables Assignment

$RG = "SentinelRG-dev1"

$Success=0

$Failure=0

##Playbooks path

$Path = "path of the folder which contains playbooks"

$Jsonpaths = get-childitem  $Path -recurse | where {$_.extension -eq ".json"} | % {

     $_.FullName

}


$File = Split-Path $Jsonpaths -Leaf

##Get Subscription Details
$Subscription = Get-AzSubscription
$SubName = $Subscription.Name
Write-Host("Subscription Name -->",$SubName)
$SubId=$Subscription.Id
Write-Host("Subscription ID -->",$SubId)
$SubTenant = $Subscription.TenantId
Write-Host("Subscription Tenant ID -->", $SubTenant)
Write-Host("`nFetching Subscription Details Completed")
Set-AzContext -Subscription $SubId

 

##Time Stamp Details

 

$date = Get-Date -Format yyyy-MM-dd
$time = get-date -Format HH:mm:ss
$datetime = $date + "|" + $time

 

 

## Import Playbookss from CSV


$starttime = Get-Date -DisplayHint Time
$endtime = Get-Date -DisplayHint Time

 

 

##Array to Store Data

 

$SuccessArray = @()
$FailedArray = @()

 

### Iterate through CSV and Deploy the Playbookss

 

Write-Host("Starting the Playbook deployment at  $starttime")

Write-Host("Iterating to deploy Playbooks `n ")

 

foreach ( $Jsonpath in $Jsonpaths)

 

{

    try

    { 

            $Parms = @{

                ResourceGroupName = $RG

                TemplateFile      = $Jsonpath

         }

 

            New-AzResourceGroupDeployment @Parms

            #$File = Split-Path $Jsonpath -Leaf

            $File = Get-Item $Jsonpath

            $Status = Get-AzResourceGroupDeployment -ResourceGroupName $RG -Name $File.BaseName

            if ($Status.ProvisioningState -eq "Succeeded")

            {

                Write-Host "Deployment is Successful"

                $Success+=1

                Write-Host $Success

                $SuccessArray += $File.BaseName

            }

            else

            {

                Write-Host "Deployment is Failed"

                $Failure+=1

                Write-Host $Failure

                $FailedArray += $File.BaseName

                Write-Host $_ -ForegroundColor Red

                Write-Host "Playbook Deployment FAILED  ---> "

            }

 

    }

    catch

    {

       

        Write-Host "An error occurred:"

        Write-Host $_ -ForegroundColor Red

     }

 

}

 

###Deployment Status

$JsonpathsCount=$Jsonpaths.Count

Write-Host("`n Total number of Playbooks to be deployed ---> ",$JsonpathsCount)

Write-Host("Number of Playbooks deployed Successfully ----->",$Success)

Write-Host("Number of Playbooks deployed UnSuccessfully ---->",$Failure)


$endtime = Get-Date -DisplayHint Time

Write-Host("`n Completed the Playbook deployment at  $endtime")
 

## Compose New Mail

##Open Outlook Application

$OL = New-Object -ComObject outlook.application

Start-Sleep 5


## Compose New Mail

#Create Item

$mItem = $OL.CreateItem("olMailItem")

 

$mItem.To = 'Email address'

$mItem.CC = 'Email address'

$mItem.Subject = "Automated Mail : Sentinel Playbooks deployment Status "

 

##Specify the content of the Mail

 

$mItem.Body = "

Hello All,
 

Sentinel Playbooks deployment is Completed and Status for the Deployment are as follows :



--Playbooks is deployed in Subscription --> $SubName

--Playbooks deployment started at --> $starttime

--Playbooks deployed from the path --> $Path

--ResourceGroup --> $RG

--Total Number of Playbookss are  --> $JsonpathsCount

--Number of Playbookss deployed Successfully --> $Success

--Number of Playbookss deployed UnSuccessfully --> $Failure

--Playbooks deployment completed at --> $endtime

 


COMPLETE DETAILS

--Successfully Deployed Playbookss are

$SuccessArray

--Failed Playbookss are

$FailedArray `n

Regards,
"
#$mItem.Attachments.add($csvUC)

##Send the Mail
$mItem.Send()
