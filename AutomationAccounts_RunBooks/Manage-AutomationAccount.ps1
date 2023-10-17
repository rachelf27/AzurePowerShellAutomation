# Manage-AutomationAccount.ps1

<#
.SYNOPSIS
    A function to manage Azure Automation Account, Runbook, and a Schedule.

.DESCRIPTION
    This function manages Automation Accounts by creating all the below resources in Azure using 
    a valid authenticated Service Principle:  
    creation of an Automation Account, Runbook, Schedule and then link/register the schedule to the Runbook.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to the Key Vault and call the Key Vault Secrets for security.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePathAzConnect = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePathAzConnect -Verbose

# Import VM Opeartion Modules
$modulePathAutoAcntRb = Join-Path -Path $PSScriptRoot -ChildPath "../Resources_VMs/Stop-AzVms.psm1"
Import-Module $modulePathAutoAcntRb -Verbose

# Main function that set up the new Automation Account, Run Book, Schedule and Link them
function Set-MyAzAutoAccnt() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables,
        [Parameter(Mandatory = $true)]    
        [string]$startTime
    )
    
    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc

    # Extract the variables from the hash table 
    $location = $variables["location"]
    $resourceGroupName = $variables["resourceGroupName"]
    $automationAccountName = "$($variables['automationAccountName'])$(Get-Date -Format 'yyMMddHHmm')"
    $runBookName = "$($variables['runBookName'])$(Get-Date -Format 'yyMMddHHmm')"
    $scheduleName = "$($variables['scheduleName'])$(Get-Date -Format 'yyMMddHHmm')"
    $runType = $variables["runType"]
    $dayInterval = $variables["dayInterval"]
    
    # Set Start Time and add extra 5 minutes
    $startTime = $(Get-Date).AddMinutes(5)

    # Create a new Automation Account
    New-MyAzAutomationAccount -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Location $location

    # Create a new Runbook using the Automation Account
    New-MyAzRunBook -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -RunBookName $runBookName -RunType $runType

    # Create a new Schedule in the Runbook in the Automation Account
    New-MyAzSchedule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ScheduleName $scheduleName -StartTime $startTime -DayInterval $dayInterval

    # Link the Schedule with the Runbook in the Automation Account  
    Set-MyAzScheduleWithRunBook -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -RunBookName $runBookName -ScheduleName $scheduleName     
}

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
}

Set-MyAzAutoAccnt -variables $variables
