# Create-AzVNet.ps1

<#
.SYNOPSIS
    A function to create an Azure Virtual Network.

.DESCRIPTION
    This function creates an Azure Virtual Network and a Subnet and associate the Subnet with the Virtual Network.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePath -Verbose

function New-MyAzVNet() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    # Authenticate to Azure using the imported function
    Get-MyAzAccountFunc

    # Extract variables from the $variables hashtable and store specific key:value pairs in hashtables $vNet and $subNet
    $vNet = @{
        Name              = $variables["vNetName"]
        ResourceGroupName = $variables["resourceGroupName"]
        Location          = $variables["location"]
        AddressPrefix     = $variables["vNetAddressPrefix"]
    }

    # Create the Virtual Network
    $virtualNetwork = New-AzVirtualNetwork @vNet

    $subNet = @{
        Name           = $variables["subnetName"]
        VirtualNetwork = $virtualNetwork
        AddressPrefix  = $variables["subnetAddressPrefix"]
    }
    
    try {
        # Create a Subnet Configuration
        Add-AzVirtualNetworkSubnetConfig @subNet

        # Associate the Subnet configuration with the Virtual Network
        $virtualNetwork | Set-AzVirtualNetwork

        Write-Host "Virtual Network and Subnet created successfully."
    }
    catch {
        Write-Error "Failed to create Virtual Network and Subnet. Error: $_"
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

New-MyAzVNet -variables $variables
