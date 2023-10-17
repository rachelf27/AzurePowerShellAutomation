# Stop-AzVms.psm1

<#
.SYNOPSIS
    A function to stop Azure VMs if they are running.

.DESCRIPTION
    This function stops any VM if they are running.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.

.PARAMETER vms    
    $vms is an array to store all Vms in the given Resource Group
#>

function Stop-MyAzVMs() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$vms
    )
    
    # Import the variables from CustomVariables.txt
    $variablesPath = Join-Path -Path $PSScriptRoot -ChildPath "../CustomVariables.txt"

    # Read the variables from CustomeVariables.txt
    $variables = [ordered]@{}
    Get-Content $variablesPath | Foreach-Object {
        $temp = ($_ -split '=').Trim()
        $variables[$temp[0]] = $temp[1]
    }

    # Stop VMs if running
    foreach ($vm in $vms) {
        $vmStatus = Get-AzVM -Name $vm.Name -ResourceGroupName $variables["resourceGroupName"] -Status
    
        if ($vmStatus.Statuses[1].Code -eq 'PowerState/running') {
            Write-Output "Shutting down $($vm.Name)..."
            try {
                Stop-AzVM -Name $vm.Name -ResourceGroupName $variables["resourceGroupName"] -Force -ErrorAction Stop
                Write-Output "$($vm.Name) has been stopped."
            }
            catch {
                Write-Error "Failed to stop $($vm.Name). Error: $_"
            }
        }
        else {
            Write-Output "$($vm.Name) is not running."
        }
    }
}

Export-ModuleMember -Function Stop-MyAzVMs -Debug