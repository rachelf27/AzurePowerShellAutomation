# Check-MyAzAcntConnect.psm1

<#
.SYNOPSIS
    A function to connect to Azure using an existing Service Principal.

.DESCRIPTION
    This function connects to Azure using an existing Service Principal. 
    It imports variables from my CustomVariables.txt TenantId, SubscriptionId, and ApplicationId for authentication.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to teh Key Vault and call the Key Vault Secrets for security.
    Example:
    @{
        "applicationId" = "Your Application ID "
        "subscriptionId" = "Your Subscription ID"
        "tenantId" = "Your Tenant ID"
    }

.PARAMETER azpPassword
    The Password to be used.
    I am using $env:AZ_SP_PASSWORD variable to store the password in environment as it persists until I change it.
    In Azure PowerShell set the AZ_SP_PASSWORD: $env:AZ_SP_PASSWORD= 'Your Service Principal Password'
#>

function Get-MyAzAccountFunc {
    # Import the variables from CustomVariables.txt
    $variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

    try {
        # Read the variables from CustomeVariables.txt
        $variables = [ordered]@{}
        Get-Content $variablesPath | Foreach-Object {
            $key, $value = $_.Split('=').Trim()
            $variables[$key] = $value
        }

        # Convert Password and Create Credential Object
        $azSpPassword = ConvertTo-SecureString $env:AZ_SP_PASSWORD -AsPlainText -Force 
        $psCred = New-Object System.Management.Automation.PSCredential($($variables['applicationId']) , $azSpPassword)

        # Connect to Azure
        # use Out-Null to terminate details about the authenticated account and subscription
        Select-AzSubscription -SubscriptionId $variables['subscriptionId']
        Connect-AzAccount -Credential $psCred -TenantId $variables['tenantId']  -ServicePrincipal | Out-Null
    }
    catch {
        # Handle exceptions
        Write-Error "An error occurred: $_"
    }
}
Export-ModuleMember -Function Get-MyAzAccountFunc