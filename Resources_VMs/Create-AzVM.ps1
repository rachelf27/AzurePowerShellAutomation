# Create-AzVM.ps1

<#
.SYNOPSIS
    A function to create an Azure VM.

.DESCRIPTION
    This function creates an Azure VM in an existing Resource Group

.PARAMETER variables
    A hashtable containing the variables needed for the operation.
    Add your variables to the AccountVariables.txt and change the filename to CustomVariables.txt
    I have added the .gitignore, CustomVariables.txt to ensure secure data will not be uploaded to GitHub.
    If preferred, any Secrets, add directly to the Key Vault and call the Key Vault Secrets for security.
#>

# Import the Check-MyAzAcntConnect.psm1
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "../Connect/Check-MyAzAcntConnect.psm1"
Import-Module $modulePath -Verbose

function New-MyWinAzVM() {
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
    $vmWinName = "$($variables['vmWinName'])$(Get-Date -Format 'yyMMddHHmm')"
    $vNetName = $variables["vNetName"]
    $subnetName = $variables["subnetName"]
    $netSecurityGroupName = $variables["netSecurityGroupName"]
    $vmWinAdminUserName = $variables["vmWinAdminUserName"]
    $vmWinAdminPassword = ConvertTo-SecureString $variables["vmWinAdminPassword"] -AsPlainText -Force 
    $vmWinSize = $variables["vmWinSize"]
    $vmWinPublisherName = $variables["vmWinPublisherName"]
    $vmWinOffer = $variables["vmWinOffer"]
    $vmWinSKU = $variables["vmWinSKU"]
    $ipConfigurationName = $variables["ipConfigurationName"]
    
    # Retrieve Network Resource Ids
    $vnet = Get-AzVirtualNetwork -Name $vNetName 
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
    $subnetId = $subnet.Id

    # Create the NIC
    $vmWinNic = "$($vmWinName)$('-nic')"

    # Store the Credntials for the Windows admin account
    $credentials = New-Object System.Management.Automation.PSCredential ($vmWinAdminUsername, $vmWinAdminPassword)

    # Define the network interface configuration
    $nicParams = @{
        Name                = $vmWinNic
        ResourceGroupName   = $resourceGroupName
        Location            = $location
        SubnetId            = $subnetId
        IpConfigurationName = $ipConfigurationName
    }

    # Add the NSG to the NIC configuration
    if ($securityGroupName) {
        $nicParams["networkSecurityGroupId"] = (Get-AzNetworkSecurityGroup -Name $netSecurityGroupName -ResourceGroupName $resourceGroupName).Id
    }

    # Define the network interface configuration
    $nic = New-AzNetworkInterface @nicParams

    # Define parameters for the new VM
    $vmConfig = New-AzVMConfig -VMName $vmWinName -VMSize $vmWinSize 
    $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmWinName -Credential $credentials -ProvisionVMAgent -EnableAutoUpdate
    $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $vmWinPublisherName -Offer $vmWinOffer -Skus $vmWinSKU -Version "latest"
    $vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Disable
    $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
    
    # Create the virtual machine.
    New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -Verbose
}

# Import the variables from CustomVariables.txt
$variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

# Read the variables from CustomeVariables.txt
$variables = [ordered]@{}
Get-Content $variablesPath | Foreach-Object {
    $temp = ($_ -split '=').Trim()
    $variables[$temp[0]] = $temp[1]
}

New-MyWinAzVM -variables $variables