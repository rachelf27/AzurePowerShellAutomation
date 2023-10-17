# Create-AzSqlOperations.psm1

<#
.SYNOPSIS
    Functions to create a SQL Server, and Elastic Pool and a DB in Azure.

.DESCRIPTION
    This scripts has functions that does the following in Azure using a valid authenticated Service Principle:  
    create a SQL server, elastic Pool and add a DB.

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
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
    Write-Host "$($temp[0]): $($temp[1])"
}

# Authenticate to Azure using the imported function
Get-MyAzAccountFunc

# Function to create a SQL Server
function New-MyAzSQLServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    try {
        # Create SQL Server
        New-AzSqlServer -ResourceGroupName $variables["resourceGroupName"] -Location $variables["location"] -ServerName $variables["sqlServerName"] -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $variables["sqlAdminUserName"], $variables["sqlAdminPassword"])
        Write-Host "SQL Server $($variables['sqlServerName']) created successfully."
    }
    catch {
        Write-Error "Failed to create SQL Server. Error: $_"
    }
}

# Function to create an Elastic Pool
function New-MyAzElasticPool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )
    
    try {
        # Create Elastic Pool
        New-AzSqlElasticPool -ResourceGroupName $variables["resourceGroupName"] -ServerName $variables["sqlServerName"] -ElasticPoolName $variables["elasticPoolName"] -Edition "Standard" -Dtu 50
        Write-Host "Elastic Pool $($variables['elasticPoolName']) created successfully."
    }
    catch {
        Write-Error "Failed to create Elastic Pool. Error: $_"
    }
}

# Function to create a Database in the Elastic Pool
function New-MyAzResToElasticPool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )
    
    try {
        # Create a Database in the Elastic Pool
        New-AzSqlDatabase -ResourceGroupName $variables["resourceGroupName"] -ServerName $variables["sqlServerName"] -DatabaseName $variables["dbName"] -ElasticPoolName $variables["elasticPoolName"]
        Write-Host "Database $($variables['dbName']) created successfully in Elastic Pool $($variables['elasticPoolName'])."
    }
    catch {
        Write-Error "Failed to create Database. Error: $_"
    }
}

Export-ModuleMember -Function New-MyAzSQLServer, New-MyAzElasticPool, New-MyAzResToElasticPool
