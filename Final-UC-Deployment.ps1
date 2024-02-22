##Connect AZure Account#Connect-AzAccount##Variables Assignment
$RG = "SentinelRG-dev1"
$WS = "NewLAWdev04"
$Success=0
$Failure=0
##Get Subscription DetailsWrite-Host("`nFetching Subscription Details `n")
$Subscription = Get-AzSubscription
$SubName = $Subscription.Name
Write-Host("Subscription Name -->",$SubName)
$SubId=$Subscription.Id
Write-Host("Subscription ID -->",$SubId)
$SubTenant = $Subscription.TenantId
Write-Host("Subscription Tenant ID -->", $SubTenant)
Write-Host("`nFetching Subscription Details Completed")
Set-AzContext -Subscription $SubId
##Time Stamp Details$date = Get-Date -Format yyyy-MM-dd
$time = get-date -Format HH:mm:ss
$datetime = $date + "|" + $time
$starttime = Get-Date -DisplayHint Time
$endtime = Get-Date -DisplayHint Time
## ImportUse cases from CSV
$csvUC = "C:\Users\parth.b.singh\CSV-MBCC-Sentinel-UC.csv"
Write-Host(" Import Excel Sheet path to a variable ")
$UCL = Import-Csv $csvUC
$UCLCount = $UCL.Count
##Array to Store Data

$SuccessArray = @()
$FailedArray = @()
$UCLCount = $UCL.Count



### Iterate through CSV and Deploy the use cases
Write-Host("Total Number of use cases that will be deployed are `n ", $UCLCount)
Write-Host("Starting the use case deployment at  $starttime")
Write-Host("Iterating to Excel sheet to deploy use cases `n ")

foreach ($UC in $UCL)
{
    $tact = $UC.Tactics
    $t=[Collections.Generic.List[String]]$tact
    
    try

    {  
       $NUC= New-AzSentinelAlertRule `
            -ResourceGroupName $RG `
            -WorkspaceName $WS `
            -DisplayName $UC.Name `
            -Description $UC.Description `
            -Query $UC.Query `
            -QueryFrequency $UC.QueryFrequency `
            -QueryPeriod $UC.QueryPeriod `
            -Severity $UC.Severity `
            -TriggerOperator $UC.TriggerOperator `
            -TriggerThreshold $UC.TriggerThreshold `
            -Tactic $t `
            -Enabled  `
            -Scheduled `
            -ErrorAction Stop
             Write-Host "Use case Deployment Successful --->" $UC.Name
            $Success+=1 
            $SuccessArray += $UC.Name

    }
    catch
    {
        Write-Host "Use case Deployment FAILED  ---> " $UC.Name
        Write-Host "An error occurred:"
        Write-Host $_ -ForegroundColor Red       
        $Failure+=1
        $FailedArray += $UC.Name
     }

}




Write-Host("`n Starting the use case deployment at  $endtime")

###Deployment Status

Write-Host("`n Total number of use cases to be deployed ---> ",$UCLCount)
Write-Host("Number of Use cases deployed Successfully ----->",$Success,$UC.Name)
Write-Host("Number of Use cases deployed UnSuccessfully ---->",$Failure,$UC.Name)


$endtime = Get-Date -DisplayHint Time


## Compose New Mail

##Open Outlook Application

$OL = New-Object -ComObject outlook.application
Start-Sleep 5

## Compose New Mail


#Create Item
$mItem = $OL.CreateItem("olMailItem")

$mItem.To = 'Email address'
#$mItem.CC = 'Email address'
$mItem.Subject = "Automated Mail : MBCC --> Sentinel Use case deployment Status "

##Specify the content of the Mail

$mItem.Body = "
Hello All,


Sentinel Use case deployment is Completed and Status for the Deployment are as follows :


--Use Case is deployed in Subscription --> $SubName 
--Use case deployment started at --> $starttime
--Usecases deployed from the path --> $csvUC 
--ResourceGroup --> $RG
--Workspace     --> $WS
--Total Number of use cases are  --> $UCLCount
--Number of Use cases deployed Successfully --> $Success
--Number of Use cases deployed UnSuccessfully --> $Failure
--Use case deployment completed at --> $endtime


COMPLETE DETAILS

--Successfully Deployed Use cases are
$SuccessArray


--Failed Use cases are
$FailedArray `n



Regards,
Parth
" 

$mItem.Attachments.add($csvUC)

##Send the Mail

$mItem.Send()
