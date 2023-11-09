# Restart-AzVms.psm1

<#
.SYNOPSIS
    A function to restart Azure VMs if they are deallocated.

.DESCRIPTION
    This function restarts any deallocated Vms.

.PARAMETER variables
    A hashtable containing the variables needed for the operation.

.PARAMETER vms    
    $vms is an array to store all Vms in the given Resource Group
#>

function Restart-MyAzVMs() {
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
        $key, $value = $_.Split('=').Trim()
        $variables[$key] = $value
    }

    # Restart VMs if deallocated
    foreach ($vm in $vms) {
        $vmStatus = Get-AzVM -Name $vm.Name -ResourceGroupName $variables["resourceGroupName"] -Status
        
        if ($vmStatus.Statuses[1].Code -eq 'PowerState/deallocated') {
            Write-Output "Restarting $($vm.Name)..."
            try {
                Start-AzVM -Name $vm.Name -ResourceGroupName $variables["resourceGroupName"] -Force -ErrorAction Stop
                Write-Output "$($vm.Name) has been restarted."
            }
            catch {
                Write-Error "Failed to restart $($vm.Name). Error: $_"
            }
        }
        else {
            Write-Output "$($vm.Name) is already running."
        }
    }
}

Export-ModuleMember -Function Restart-MyAzVMs