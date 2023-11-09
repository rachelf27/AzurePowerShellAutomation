# Create-AutoAccountRunbooks.psm1

<#
.SYNOPSIS
    Functions to create an Azure Automation Account, Runbook, and a Schedule.

.DESCRIPTION
    This scripts has functions that does the following in Azure using a valid authenticated Service Principal:  
    create an Automation Account, Runbook, Schedule and then link/register the schedule to the Runbook.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to the Key Vault and call the Key Vault Secrets for security.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePathAzConnect = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePathAzConnect -Verbose


# Global/Script-level Variables
# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $key, $value = $_.Split('=').Trim()
    $variables[$key] = $value
    Write-Host "$($temp[0]): $($temp[1])"
}

# Authenticate to Azure using the imported function
Get-MyAzAccountFunc

# Function to create an Automation Account
function New-MyAzAutomationAccount() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )
    try {
        # Create Automation Account
        New-AzAutomationAccount -ResourceGroupName $variables["resourceGroupName"] -Location $variables["location"] -Name $variables["automationAccountName"]
        Write-Host "Automation Account $($variables['automationAccountName']) created successfully."
    } 
    catch {
        Write-Error "Failed to create the Automation Account. Error: $_"
    }
}

# Function to create a Runbook
function New-MyAzRunBook() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    try {
        # Create Runbook
        New-AzAutomationRunbook -ResourceGroupName $variables["resourceGroupName"] -Name $variables["runBookName"] -Type $variables["runType"]
        Write-Host "Runbook $($variables['runBookName']) created successfully."
    }
    catch {
        Write-Error "Failed to create the Runbook. Error: $_"
    }

}

# Function to create a Schedule
function New-MyAzSchedule() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables,
        [Parameter(Mandatory = $true)]    
        [string]$startTime
    )

    try {
        # Create Schedule
        New-AzAutomationSchedule -ResourceGroupName $variables["resourceGroupName"] -Name $variables["scheduleName"] -StartTime $startTime -DayInterval $variables["dayInterval"]
        Write-Host "Schedule $($variables['scheduleName']) created successfully."
    }
    catch {
        Write-Error "Failed to create the Schedule. Error: $_"
    }

}

# Function to register the Schedule with the Runbook
function Set-MyAzScheduleWithRunBook() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    try {
        # Link the Schedule with the RunBook
        Register-AzAutomationScheduledRunbook -ResourceGroupName $variables["resourceGroupName"] -RunBookName $variables["runBookName"] -ScheduleName $variables["scheduleName"]
        Write-Host "Schedule $($variables['scheduleName']) is linked with Runbook $($variables['runBookName']) successfully."
    }
    catch {
        Write-Error "Failed to link the Schedule with the Runbook. Error: $_"
    }
}

Export-ModuleMember -Function New-MyAzAutomationAccount, New-MyAzRunBook, New-MyAzSchedule, Set-MyAzScheduleWithRunBook
