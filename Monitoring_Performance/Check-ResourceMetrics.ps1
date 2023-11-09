# Check-ResourceMetrics.ps1

<#
.SYNOPSIS
    A function to create a new Azure Service Principal.

.DESCRIPTION
    This function creates a new Service Principal using a privileged Application authentication
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

function Get-MyAzResourceMetrics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc
    
    try {
        # Install the Az.Monitor Module
        Install-Module -Name Az.Monitor

        # list available Metric Definition for a resource
        $metricDefs = Get-AzMetricDefinition -ResourceId [varaibles('resourceId')]

        # Retrieve Metrics for a specific Resource 
        $cpuPercentage = Get-AzMetric -ResourceId Get-Date -Format 'yyMMddHHmm'
        return $metricDefs, $cpuPercentage
   
    }
    catch {
        Write-Error "Error checking resource metrics: $_"
        return $null
    }  
}

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $key, $value = $_.Split('=').Trim()
    $variables[$key] = $value
}

Get-MyAzResourceMetrics -variables $variables

