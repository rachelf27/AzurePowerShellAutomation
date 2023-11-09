# Manage-AzVMOperations.ps1

<#
.SYNOPSIS
    A function to manage Azure VM operations.

.DESCRIPTION
    This function calls 3 modules to do the following operations for VMs given a resource group.
    User must provide which operation to execute.

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
$modulePathVMStop = Join-Path -Path $PSScriptRoot -ChildPath "../Resources_VMs/Stop-AzVms.psm1"
Import-Module $modulePathVMStop -Verbose
$modulePathVMRestart = Join-Path -Path $PSScriptRoot -ChildPath "../Resources_VMs/Restart-AzVms.psm1"
Import-Module $modulePathVMRestart -Verbose
$modulePathVMRemove = Join-Path -Path $PSScriptRoot -ChildPath "../Resources_VMs/Remove-AzVms.psm1"
Import-Module $modulePathVMRemove -Verbose

function Get-AzVMOperation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$variables,
        [Parameter(Mandatory = $true)]
        [string]$OperationType
    )

    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc

    # Extract the variables from the hash table 
    $resourceGroupName = $variables["resourceGroupName"]
    
    # Get VMs
    $vms = Get-AzVM -ResourceGroupName $resourceGroupName
    Write-Host "VMs in the Resource Group ($resourceGroupName): $($vms.Name -join ', ')"
    
        # Execute the appropriate operation based on $OperationType
        switch ($OperationType) {
            "Stop" {
                Stop-MyAzVMs -vms $vms
            }
            "Reboot" {
                Restart-MyAzVMs -vms $vms 
            }            
            "Remove" {
                Remove-MyAzVMs -vms $vms
            }
            default {
                Write-Error "Invalid operation type. Please specify 'Stop', 'Restart' or 'Remove'."
            }
        }
    }

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $key, $value = $_.Split('=').Trim()
    $variables[$key] = $value
    Write-Host "$($temp[0]): $($temp[1])"
}

# Prompt the user for the operation type
$OperationType = Read-Host "Enter the VM operation type (Stop, Restart or Remove)"

# Call the function with the user's input
Get-AzVMOperation -variables $variables -OperationType $OperationType






