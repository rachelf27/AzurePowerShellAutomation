# Create-ServicePrinciple.ps1

<#
.SYNOPSIS
    A function to create a new Azure Service Principle.

.DESCRIPTION
    This function creates a new Service Principle using a privileged Application authentication
    https://learn.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-10.3.0#code-try-0

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to the Key Vault and call the Key Vault Secrets for security.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePathAzConnect = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePathAzConnect -Verbose

function New-MyAzServicePrinciple {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc
    
    try {
        # Extract the variables from the hash table 
        $servicePrincipleName = "$($variables['servicePrincipleName'])$(Get-Date -Format 'yyMMddHHmm')"
        
        # Create the Service Principal
        $sp = New-AzADServicePrincipal -DisplayName $servicePrincipleName

        # Get the Password Credential from the newly created Service Principal
        $spPassword = $sp.PasswordCredentials.SecretText
        return $spPassword
    }
    catch {
        Write-Error "Error creating Service Principal: $_"
        return $null
    }  
}

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
}

New-MyAzServicePrinciple -variables $variables

