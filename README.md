# Cireson-Powershell-Module
This Powershell Module allows you to work with SMLets and Service Manager in a more user friendly way.  The functions are built so that an administrator can send in basic parameter values to get the same data you would get when using SMLets directly.

## Installation
* Download and Install the SMLets PowerShell Module (https://smlets.codeplex.com/)
* Download the Cireson PowerShell Module from this repository
* Unblock the Zip File
* Save the File to "C:\Program Files\WindowsPowerShell\Modules"

## Getting Started
...
Import-Module SMLets
Import-Module "C:\Program Files\WindowsPowerShell\Modules\CiresonPowerModule.psm1

Get-CiresonWorkItem -WorkItemId "IR1234" -ComputerName $ComputerName

...
