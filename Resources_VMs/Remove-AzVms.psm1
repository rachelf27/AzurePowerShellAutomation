# Remove-AzVms.psm1

<#
.SYNOPSIS
    A function to remove/delete Azure VMs if they are deallocated.

.DESCRIPTION
    This function deletes VMs if they are deallocated.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.

.PARAMETER vms    
    $vms is an array to store all Vms in the given Resource Group
#>

function Remove-MyAzVMs() {
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

    # Delete stopped VMs
    foreach ($vm in $vms) {
        $vmStatus = Get-AzVM -Name $vm.Name -ResourceGroupName $variables["resourceGroupName"] -Status
    
        if ($vmStatus.Statuses[1].Code -eq 'PowerState/deallocated') {
            Write-Output "Deleting VM $($vm.Name)..."
            try {
                Remove-AzVM -Name $vm.Name -ResourceGroupName $variables["resourceGroupName"] -Force -ErrorAction Stop
                Write-Output "$($vm.Name) has been deleted."
            }
            catch {
                Write-Error "Failed to delete $($vm.Name). Error: $_"
            }
        }
        else {
            Write-Output "$($vm.Name) is not deallocated."
        }
    }
}
Export-ModuleMember -Function Remove-MyAzVMs -Debug