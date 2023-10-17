# Create-SingleKeyVault.ps1

<#
.SYNOPSIS
    A function to create an Azure Resource Group, Key Vault, and add a secret.

.DESCRIPTION
This function creates a new Azure Resource Group, Key Vault, add a secret to it, modifies the Firewall rules, 
    and then retrieves the secret. The function performs several checks to ensure resources do not already exist 
    before trying to create them.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to teh Key Vault and call the Key Vault Secrets for security.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePath -Verbose

function New-MyAzKeyVault() {
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
    $keyVaultName = "$($variables['keyVaultName'])$(Get-Date -Format 'yyMMddHHmm')"
    $secretName = "$($variables['secretName'])$(Get-Date -Format 'yyMMddHHmm')"
    $secretValue = ConvertTo-SecureString $variables["secretValue"] -AsPlainText -Force 
    $allowedIPAddresses = $variables["allowedIPAddresses"]

    # Create a Resource Group
    # Check if Resource Group already exists
    try {
        if (-not(Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
            # If it does not exist, create it
            New-AzResourceGroup -Name $resourceGroupName -Location $location
        }
        else {
            Set-AzResourceGroup -Name $resourceGroupName -Location $location
        }
    }
    catch {
        Write-Error "Failed to create Resource Group: $resourceGroupName "
    }

    # Create a Key Vault
    # Check if Key Vault already exists
    try {
        if (-not(Get-AzKeyVault -Name $keyVaultName -ErrorAction SilentlyContinue)) {
            # If it does not exist, create it
            New-AzKeyVault -ResourceGroupName $resourceGroupName -VaultName $keyVaultName -Location $location
        }
        else {
            Write-Error "The name $keyVaultName is already in use, choose another name."
            return
        }
    }
    catch {
        Write-Error "Failed to create Key Vault: $keyVaultName "    
    }

    # Add a Secret to Key Vault
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $secretValue

    # Extract the IP addresses as an array
    $allowedIPAddresses = @()
    if ($variables["allowedIPAddresses"]) {
        $allowedIPAddresses = $variables["allowedIPAddresses"].Split(',')
    }

    # Modify Firewall Rules to allow certain IP addresses
    try {
        Set-AzKeyVaultNetworkRule -ResourceGroupName $resourceGroupName -VaultName $keyVaultName -IpAddressRange $allowedIPAddresses -DefaultAction Deny
    }
    catch {
        Write-Error "Failed to set Key Vault firewall rules for $keyVaultName"
    }

    # Retrieve the Secret
    $secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName

    return $secret
}
# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
}

New-MyAzKeyVault -variables $variables

