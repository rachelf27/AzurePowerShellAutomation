# Azure PowerShell Automation

Welcome to the Azure PowerShell Automation project! This repository contains a collection of PowerShell scripts and modules to automate various tasks in Microsoft Azure.

## Table of Contents
  
- [Azure PowerShell Automation](#azure-powershell-automation)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
  - [Navigate to the project directory](#navigate-to-the-project-directory)
  - [Usage](#usage)
  - [*Note*:](#note)
  - [Project Structure](#project-structure)

## Introduction

This project aims to simplify and automate common Azure tasks using PowerShell scripts. It provides a set of scripts and modules that leverage Azure PowerShell to manage and configure Azure resources.

## Prerequisites

Before using this project, please ensure that you have the following prerequisites:

- [Azure PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
- Azure Subscription
- Proper Azure credentials (Service Principal, Managed Identity, or Interactive Login)

## Getting Started

1. Clone or download this repository to your local machine.
`git clone https://github.com/yourusername/AzurePowerShellAutomation.git`

## Navigate to the project directory
`cd AzurePowerShellAutomation`

1. Update the Variables.txt file with the necessary values for your Azure environment. Make sure to keep this file secure and don't commit it to version control. Optionally, you can provide your own CustomVariables.txt with values to override the defaults.

2. Run the desired PowerShell scripts using Azure PowerShell module to automate Azure tasks.

## Usage
To use this project, follow these steps:

1. Install Azure PowerShell if you haven't already.

2. Make sure your Azure credentials are configured correctly. You can use Service Principals, Managed Identities, or Interactive Login methods.

3. Clone or download this repository.

4. Navigate to the project directory.

5. Update the Variables.txt file with your Azure configuration details.

6. Execute the desired PowerShell scripts located in various directories based on the task you want to perform.

## *Note*:
Azure AD is now Microsoft Entra ID. https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/compare  
To view your Applications/Service Principals, select Microsoft Entra ID->Application Registrations->All Applications.   
If you run into "Insufficient privileges to complete the operation" (especially when creating new Service Principles or authentication), check your Applications API Permission and add necessary Application Read Write permissions and Grant Admin consent.

If the above approach does not resolve the insufficient privileges issue, install and import the Microsoft Graph modules as shown below:   
```
Install-Module -Name Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Groups

Import-Module -Name Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Groups

Connect-MgGraph
```
If the modules were installed correctly the below commands should work without errors.   
- The below command creates a new Service Principle and display the secret (*secure data*) on the terminal.  
`$sp = New-AzADServicePrincipal -DisplayName MyServicePrincipalName`
`$sp.PasswordCredentials.SecretText`


## Project Structure
The project is organized into directories based on different Azure automation tasks. Each directory contains scripts and modules related to specific Azure operations.

- AutomationAccounts_RunBooks: Scripts for managing Azure Automation Accounts, Runbooks, Schedules and Registering them.
- Connect: PowerShell module for connecting to Azure.
- KeyVaults: Scripts for managing Azure Key Vaults.
- Networking: Scripts related to Azure Networking (WIP).
- Resources_VMs: Scripts for creating, managing Azure resources and Virtual Machines.
- Roles_Policies: Scripts for creating/managing Service Principles, Managed Identities, and Azure Roles and Policies.