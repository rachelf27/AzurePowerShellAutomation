# Manage-AzSqlServer.ps1

<#
.SYNOPSIS
    A function to manage Azure SQL Server.

.DESCRIPTION
    This function calls a SQL Operations module to manage creating a SQL server, elastic Pool and adding a DB.

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
$modulePathSQLOps = Join-Path -Path $PSScriptRoot -ChildPath "../Resources_VMs/Create-AzSqlOperations.psm1"
Import-Module $modulePathSQLOps -Verbose

function Set-AzSQLServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc

    # Extract the variables from the hash table 
    $resourceGroupName = $variables["resourceGroupName"]
    $location = $variables["location"]
    $sqlServerName = $variables["sqlServerName"]
    $elasticPoolName = $variables["elasticPoolName"]
    $dbName = $variables["dbName"]
    $sqlAdminUserName = $variables["sqlAdminUserName"]
    $sqlAdminPassword = ConvertTo-SecureString -String $variables["sqlAdminPassword"] -AsPlainText -Force

    # Create a new SQL Server
    New-MyAzSQLServer -ResourceGroupName  $resourceGroupName -Location $location -SQLServerName $sqlServerName -SQLAdminUserName $sqlAdminUserName -SQLAdminPassword $sqlAdminPassword

    New-MyAzElasticPool -ResourceGroupName $resourceGroupName -SQLServerName $sqlServerName -ElasticPoolName $elasticPoolName

    New-MyAzResToElasticPool -ResourceGroupName $resourceGroupName -SQLServerName $sqlServerName -ElasticPoolName $elasticPoolName -DatabaseName $dbName
}

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
    Write-Host "$($temp[0]): $($temp[1])"
}

Set-AzSQLServer -variables $variables