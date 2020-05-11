# Cireson-Powershell-Module
This Powershell Module allows you to work with SMLets and Service Manager.  The functions are built so that an administrator can send in basic parameter values to get the same data you would get when using SMLets directly.

## Installation
* Download and Install the SMLets PowerShell Module (https://github.com/SMLets/SMLets)
* Download the CiresonSCSMFunctions folder from this repository
* Unblock the Zip File
* Extract to "C:\Program Files\WindowsPowerShell\Modules"

## Getting Started
```
Import-Module SMLets
Import-Module CiresonSCSMFunctions

Get-CiresonWorkItem -WorkItemId "IR1234" -ComputerName $ComputerName
```
## Cmdlets 
* Get-CiresonAffectedCI
* Get-CiresonAffectedUser
* Get-CiresonCreatedByUser
* Get-CiresonDomainUser
* Get-CiresonMAinWI
* Get-CiresonNextAvailableSequenceID
* Get-CiresonParentWI
* Get-CiresonParentWIByGUID
* Get-CiresonRAinWI
* Get-CiresonRelatedCI
* Get-CiresonUserManager
* Get-CiresonWorkItem
* New-CiresonChangeRequest
* New-CiresonIncident
* New-CiresonServiceRequest
* New-CiresonManualActivity
* New-CiresonReviewActivity
* New-CiresonParallelActivity
* Set-CiresonAffectedUser
* Set-CiresonAssignedUser
* Set-CiresonUserAsReviewer
* Set-CiresonWorkItemValue
* Move-CiresonActivityInWorkItem
