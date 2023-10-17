# Create-UserManagedIdentity.ps1

<#
.SYNOPSIS
    A function to create an Azure User Managed Identity.

.DESCRIPTION
    This function creates an Azure User Managed Identity within a resource group for a specific application

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to teh Key Vault and call the Key Vault Secrets for security.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePath -Verbose

function New-MyAzUserManagedIdentity() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )
    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc

    # Extract the variables from the hash table 
    $location = $variables["location"]
    $resourceGroupName = $variables["resourceGroupName"]
    $userManagedIdentityName = $variables["userManagedIdentityName"] + (Get-Date -Format 'yyyyMMddHHmmss')

    # Create a User Managed Identity
    New-AzUserAssignedIdentity -Location $location -ResourceGroupName $resourceGroupName -Name $userManagedIdentityName
}

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
}

New-MyAzUserManagedIdentity -variables $variables
