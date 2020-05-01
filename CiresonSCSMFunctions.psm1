<#
.DESCRIPTION 
Pass in the Work Item Class Id and get an Enterprise Management Object

.PARAMETER WorkItemId
The Work Item Id (IR1234)

.OUTPUTS
Enterprise Management Object (Work Item)

.EXAMPLE
Get-CiresonWorkItem -WorkItemId "IR1822" -ComputerName $ComputerName

.EXAMPLE
Get-CiresonWorkItem -WorkItemId "SR1572" -ComputerName $ComputerName

.EXAMPLE
Get-CiresonWorkItem -WorkItemId "MA1601" -ComputerName $ComputerName

#>
Function Get-CiresonWorkItem {

    Param (
        [string]$WorkItemId,
        [string]$ComputerName
    ) 

    $SCSM = @{
        ComputerName = $ComputerName
    }

    $SMObject = Get-SCSMObject -Class (Get-SCSMClass System.WorkItem$ @SCSM) -Filter "Id -eq $WorkItemId" @SCSM

    Return $SMObject
}

<#
.DESCRIPTION 
Pass in the Activity Object and determine the top most Work Item it belongs to

.PARAMETER Activity
Activity Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "MA1948" -ComputerName $ComputerName
Get-CiresonParentWI -Activity $SMObject -ComputerName $ComputerName

.OUTPUTS
Work Item Object (Top Most Parent)

#>
Function Get-CiresonParentWI {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$Activity,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }
    
    #Get Parent of this Activity
    $WIContainsActivityRel = Get-SCSMRelationshipClass "System.WorkItemContainsActivity" @SCSM
    $ParentWI = (Get-SCSMRelationshipObject -TargetObject $Activity -TargetRelationship $WIContainsActivityRel @SCSM).SourceObject
    
    If ($ParentWI -eq $null) {
        # We've reached the top - Return Original Actvity
        Return $Activity
    }
    Else {
        # Parent is not confrmed as the root, and thus, we will loop into another "Get-ParentWI" function.
        Get-CiresonParentWI -Activity $ParentWI @SCSM
    }
}

<#
.DESCRIPTION 
Pass in a Work Item and the Class of Configuration Item that you want to receive based on the Work Item About Config Item Relationship

.PARAMETER CIClass
This is the Name of the Configuration Item Class

.PARAMETER SMObject
The Work Item Object

.OUTPUTS
Configuration Item(s) under "Affected Configuration Items" (Work Item About Config Item Relationship)

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1832" -ComputerName $ComputerName
Get-CiresonAffectedCI -SMObject $SMObject -CIClass "Microsoft.Windows.Computer" -ComputerName $ComputerName

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1832" -ComputerName $ComputerName
Get-CiresonAffectedCI -SMObject $SMObject -CIClass "Cireson.AssetManagement.HardwareAsset" -ComputerName $ComputerName

#>
Function Get-CiresonAffectedCI {

    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$CIClass,
        [string]$ComputerName
    ) 

    $SCSM = @{
        ComputerName = $ComputerName
    }

    $WIAboutCIRel = Get-SCSMRelationshipClass -Name 'System.WorkItemAboutConfigItem' @SCSM

    #Get Related CIs
    $AffectedCIs = Get-SCSMRelatedObject -SMObject $SMObject -Relationship $WIAboutCIRel @SCSM
    $AffectedCI = $AffectedCIs | Where-Object {$_.ClassName -eq $CIClass}

    Return $AffectedCI
}

<#
.DESCRIPTION 
Pass in a Work Item and the Class of Configuration Item that you want to receive based on the Work Item Relates To Config Item Relationship

.PARAMETER CIClass
This is the Name of the Configuration Item Class

.PARAMETER SMObject
The Work Item Object

.OUTPUTS
Configuration Item(s) under "Related Configuration Items" (Work Item Relates To Config Item Relationship)

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1832" -ComputerName $ComputerName
Get-CiresonRelatedCI -SMObject $SMObject -CIClass "Microsoft.Windows.Computer" -ComputerName $ComputerName

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1832" -ComputerName $ComputerName
Get-CiresonRelatedCI -SMObject $SMObject -CIClass "Cireson.AssetManagement.HardwareAsset" -ComputerName $ComputerName

#>
Function Get-CiresonRelatedCI {

    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$CIClass,
        [string]$ComputerName
    ) 

    $SCSM = @{
        ComputerName = $ComputerName
    }

    $WIRelatedCIRel = Get-SCSMRelationshipClass -Name 'System.WorkItemRelatesToConfigItem' @SCSM

    #Get Related CIs
    $RelatedCIs = Get-SCSMRelatedObject -SMObject $SMObject -Relationship $WIRelatedCIRel @SCSM
    $RelatedCI = $RelatedCIs | Where-Object {$_.ClassName -eq $CIClass}

    Return $RelatedCI
}

<#
.DESCRIPTION 
Pass in the sAMAccountName (UserName) of a User and return the Domain User Object

.PARAMETER SAMAccountName
The Active Directory sAMAccountName of a User

.EXAMPLE
Get-CiresonDomainUser -SAMAccountName "jsmith" -ComputerName $ComputerName

.OUTPUTS
Domain User Object
#>
Function Get-CiresonDomainUser {
    Param (
        [string]$SAMAccountName,
        [string]$ComputerName
    )

        $SCSM = @{
        ComputerName = $ComputerName
    }

    $User = Get-SCSMObject -Class (Get-SCSMClass System.Domain.User$ @SCSM) -Filter "UserName -eq $SAMAccountName" @SCSM

    return $User

}

<#
.DESCRIPTION 
Pass in a Work Item Object and return the Affected User

.PARAMETER SMObject
The Work Item Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1832" -ComputerName $ComputerName
Get-CiresonAffectedUser -SMObject $SMObject -ComputerName $ComputerName

.OUTPUTS
Affected User for a Given Work Item
#>
Function Get-CiresonAffectedUser {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$ComputerName
    )

        $SCSM = @{
        ComputerName = $ComputerName
    }

    $AffectedUserRel = Get-SCSMRelationshipClass -Name System.WorkItemAffectedUser @SCSM
    $AffectedUser = Get-SCSMRelatedObject -SMObject $SMObject -Relationship $AffectedUserRel @SCSM

    return $AffectedUser 
}

<#
.DESCRIPTION 
Pass in a Work Item Object and return the Created By User

.PARAMETER SMObject
The Work Item Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1832" -ComputerName $ComputerName
Get-CiresonCreatedByUser -SMObject $SMObject -ComputerName $ComputerName

.OUTPUTS
Created By User for a Given Work Item
#>
Function Get-CiresonCreatedByUser {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$ComputerName
    )

        $SCSM = @{
        ComputerName = $ComputerName
    }

    $CreatedByUserRel = Get-SCSMRelationshipClass -Name System.WorkItemCreatedByUser @SCSM
    $CreatedByUser = Get-SCSMRelatedObject -SMObject $SMObject -Relationship $CreatedByUserRel @SCSM

    return $CreatedByUser 
}

<#
.DESCRIPTION 
Send in a Work Item Object and Manual Activity Title, return the Manual Activity Object that contains the given Title

.PARAMETER SMObject
The Work Item Object

.PARAMETER MATitle
This Title of the Manual Activity

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "CR535" -ComputerName $ComputerName
Get-CiresonMAInWI -SMObject $SMObject -MATitle "Implement Major Change" -ComputerName $ComputerName

.OUTPUTS
Manual Activity Object

#>
Function Get-CiresonMAInWI {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$MATitle,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

    # Get the relationships of this WI that are activities, where the target is a MA, and where the title equals our desired title
    $MARelObj = Get-SCSMRelationshipObject -BySource $SMObject @SCSM | Where-Object {$_.RelationshipId -eq "2da498be-0485-b2b2-d520-6ebd1698e61b" -and $_.TargetObject.ClassName -eq "System.WorkItem.Activity.ManualActivity" -and $_.TargetObject.DisplayName -LIKE "*$MATitle*"}
    #$MA_RelObj
    # Get the full object and return it
    if($MARelObj -ne $null){
        return (Get-SCSMObject -id $MARelObj.TargetObject.Id @SCSM)
    }
}

<#
.DESCRIPTION 
Send in a Work Item Object and Review Activity Title, return the Review Activity Object that contains the given Title.

.PARAMETER SMObject
The Work Item Object

.PARAMETER MATitle
This Title of the Review Activity

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "CR535" -ComputerName $ComputerName
Get-CiresonRAInWI -SMObject $SMObject -RATitle "Approve Major Change" -ComputerName $ComputerName

.OUTPUTS
Review Activity Object
#>
Function Get-CiresonRAInWI {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$RATitle,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

    # Get the relationships of this WI that are activities, where the target is a MA, and where the title equals our desired title
    $RARelObj = Get-SCSMRelationshipObject -BySource $SMObject @SCSM | Where-Object {$_.RelationshipId -eq "2da498be-0485-b2b2-d520-6ebd1698e61b" -and $_.TargetObject.ClassName -eq "System.WorkItem.Activity.ReviewActivity" -and $_.TargetObject.DisplayName -LIKE "*$RATitle*"}

    if($RARelObj -ne $null){
        return (Get-SCSMObject -id $RARelObj.TargetObject.Id @SCSM)
    }
}

<#
.DESCRIPTION 
Send in a Domain User Object and return the Manager Object of that user.

.PARAMETER User
The Domain User Object

.EXAMPLE
$User = Get-CiresonDomainUser -SAMAccountName "ssmith" -ComputerName $ComputerName
Get-CiresonUserManager -User $User -ComputerName $ComputerName

.OUTPUTS
User Object (Manager)

#>
Function Get-CiresonUserManager {
    Param(
        $User,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

    $UserManagesUserRel = Get-SCSMRelationshipClass -Name System.UserManagesUser$ @SCSM

    $Manager = (Get-SCSMRelationshipObject -ByTarget $User @SCSM | Where-Object {$_.RelationshipId -eq $UserManagesUserRel.Id}).SourceObject

    return $Manager
}

<#
.DESCRIPTION 
Send in a Work Item and Determine the next Sequence ID that should be used given the Activities associated with it.

.PARAMETER SMObject
The Work Item Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "SR1556" -ComputerName $ComputerName
Get-CiresonNextAvailableSequenceID -SMObject $SMObject -ComputerName $ComputerName

.OUTPUTS
SequenceID (Number)

#>
Function Get-CiresonNextAvailableSequenceID {
    Param (
        $SMObject,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }

    #Sleep for a moment, if I'm creating activities too fast, the first one doesn't register in time.
    Start-Sleep -Seconds 2

    #Get WI contains activity relationship
    $WIContainsActivityRel = Get-SCSMRelationshipClass -name 'System.WorkItemContainsActivity' @SCSM

    $Activities = Get-SCSMRelatedObject -SMObject $SMObject -Relationship $WIContainsActivityRel @SCSM

    #If activities already exist in the WI
    If (($Activities | Measure-Object).Count -ge 1) {
        #Sort activities, select the last one and increment it
        $Activities = $Activities | Sort-Object -Property sequenceID
        $LastActivity = $Activities | Select-Object -Last 1
        $SequenceID = $LastActivity.SequenceID + 1
    }
    Else {
        #No activities currently exist, set the first activity to ID 0
        $SequenceID = 0
    }
    Return $SequenceID
}

<#
.DESCRIPTION 
Send in a Work Item Object and a Domain User Object and update that Work Item to that Affected User.

.PARAMETER SMObject
The Work Item Object

.PARAMETER AffectedUser
The Domain User Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1810" -ComputerName $ComputerName
$User = Get-CiresonDomainUser -SAMAccountName "jsmith" -ComputerName $ComputerName
Set-CiresonAffectedUser -SMObject $SMObject -AffectedUser $User $ComputerName

#>
Function Set-CiresonAffectedUser {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$AffectedUser,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

	if($AffectedUser -ne $null){
        $AffectedUserRel = Get-SCSMRelationshipClass -Name System.WorkItemAffectedUser @SCSM

        $AffectedUserRelObj = New-SCSMRelationshipObject -nocommit -Relationship $AffectedUserRel -Source $SMObject -Target $AffectedUser @SCSM

        $AffectedUserRelObj.Commit()
	}
}

<#
.DESCRIPTION 
Send in a Work Item Object and a Domain User Object and update that Work Item to that Assigned To User.

.PARAMETER SMObject
The Work Item Object

.PARAMETER AssignedToUser
The Domain User Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1810" -ComputerName $ComputerName
$User = Get-CiresonDomainUser -SAMAccountName "jsmith" -ComputerName $ComputerName
Set-CiresonAssignedUser -SMObject $SMObject -AssignedToUser $User -ComputerName $ComputerName

#>
Function Set-CiresonAssignedUser {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$AssignedToUser,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

	if($AssignedToUser -ne $null){
        $AssignedToUserRel = Get-SCSMRelationshipClass -Name System.WorkItemAssignedToUser @SCSM

        $AssignedToUserRelObj = New-SCSMRelationshipObject -nocommit -Relationship $AssignedToUserRel -Source $SMObject -Target $AssignedToUser @SCSM

        $AssignedToUserRelObj.Commit()
	}
}

<#
.DESCRIPTION 
Pass in a Work Item, the Property Name, and Value to update.

.PARAMETER SMObject
The Work Item Object

.PARAMETER PropertyName
The (Internal) Property Name.

.PARAMETER Value
The new Value for the given Property

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "IR1744" -ComputerName $ComputerName
Set-CiresonWorkItemValue -SMObject $SMObject -PropertyName "Description" -Value "This is my new Description" -ComputerName $ComputerName

.EXAMPLE
Set-CiresonWorkItemValue -SMObject $SMObject -PropertyName "Priority" -Value 3 -ComputerName $ComputerName

.EXAMPLE
Set-CiresonWorkItemValue -SMObject $SMObject -PropertyName "IsDowntime" -Value $true -ComputerName $ComputerName

.EXAMPLE
Set-CiresonWorkItemValue -SMObject $SMObject -PropertyName "TierQueue" -Value "Desktop Support" -ComputerName $ComputerName

.OUTPUTS

#>
Function Set-CiresonWorkItemValue {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$SMObject,
        [string]$PropertyName,
        [string]$Value,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

    Set-SCSMObject -SMObject $SMObject -Property $PropertyName -Value $Value @SCSM

}

<#
.DESCRIPTION 
Add a User as a Reviewer to a given Review Activity

.PARAMETER ReviewActivity
The Review Activity Object

.PARAMETER User
The User Object

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "RA1557" -ComputerName $ComputerName
$User = Get-CiresonDomainUser -SAMAccountName "jsmith" -ComputerName $ComputerName
Set-CiresonUserAsReviewer -ReviewActivity $SMObject -User $User -ComputerName $ComputerName

.EXAMPLE
$SMObject = New-CiresonReviewActivity -ParentWorkItem $SMObject -Title "Approve Request" -Description "Approval is needed to proceed" -ComputerName $ComputerName
$User = Get-CiresonDomainUser -SAMAccountName "jsmith" -ComputerName $ComputerName
Set-CiresonUserAsReviewer -ReviewActivity $SMObject -User $User -ComputerName $ComputerName

.OUTPUTS

#>
Function Set-CiresonUserAsReviewer {
    Param (
        $ReviewActivity,
        $User,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }

    #Get the two relationships
    $ReviewerIsUserRel = Get-SCSMRelationshipClass -name 'System.ReviewerIsUser' @SCSM
    $RAHasReviewerRel = Get-SCSMRelationshipClass -name 'System.ReviewActivityHasReviewer' @SCSM

    #Define a projection for the Reviewer object

    $Projection = @{
        __CLASS = “System.WorkItem.Activity.ReviewActivity”;
        __SEED = $ReviewActivity; 
        Reviewer = @{
            __CLASS = “System.Reviewer”;
            __OBJECT = @{“ID”=”{0}”}
        } 
    } 

    #Create the reveiwers object and link it to the RA at the same time 

    New-SCSMObjectProjection -Type System.WorkItem.Activity.ReviewActivityViewProjection$ -Projection $Projection @SCSM
  
    #Get reviewer object just created
    $Reviewer = Get-SCSMRelatedObject -SMObject $ReviewActivity -Relationship $RAHasReviewerRel @SCSM | Sort-Object -Property TimeAdded -Descending | Select-Object -First 1
    
    #Relate the User to the Reviewer
    New-SCSMRelationshipObject -Relationship $ReviewerIsUserRel -Source $Reviewer -Target $User -Bulk @SCSM
}

<#
.DESCRIPTION 
Pass in a Title and Description and create a new Incident.  This will default the Impact and Urgency to Low.

.PARAMETER Title
The Title of the New Incident

.PARAMETER Description
The Description of the New Incident

.EXAMPLE
New-CiresonIncident -Title "New Incident" -Description "This is my description" -ComputerName $ComputerName

.OUTPUTS
New Incident

#>
Function New-CiresonIncident {
    Param (
        [string]$Title,
        [string]$Description,
        [string]$ComputerName
    )

    $SCSM = @{
        ComputerName = $ComputerName
    }

    $IRClass = Get-SCSMClass -name System.WorkItem.Incident$ @SCSM
    $ImpactEnum = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.ImpactEnum.Low$ @SCSM
    $UrgencyEnum = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.UrgencyEnum.Low$ @SCSM
    $IRHash = @{
        Title = $Title;
        Description = $Description;
        Impact = $ImpactEnum;
        Urgency = $UrgencyEnum;
        Id = “IR{0}”;
        Status = "Active";
    }

    $Incident = New-SCSMObject -Class $IRClass -PropertyHashtable $IRHash -PassThru @SCSM

    Return $Incident
}

<#
.DESCRIPTION 
Pass in a Title and Create a New Service Request

.PARAMETER Title
The Title of the new Service Request

.EXAMPLE
New-CiresonServiceRequest -Title "My New SR" -ComputerName $ComputerName

.OUTPUTS
New Service Request

#>
Function New-CiresonServiceRequest {
   Param (
        $Title,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }

    #Variable / Class Setup
    $SRClass = Get-SCSMClass -name System.WorkItem.ServiceRequest$ @SCSM

    #Service Request Arguements
    $SRHash = @{
        Title = $Title;
        Id = “SR{0}”;
        Status = "New";
    }

    #Create Service Request
    $ServiceRequest = New-SCSMObject -Class $SRClass -PropertyHashtable $SRHash -PassThru @SCSM

    Return $ServiceRequest
}

<#
.DESCRIPTION 
Pass in a Title and Create a New Change Request

.PARAMETER Title
The Title of the new Change Request

.EXAMPLE
New-CiresonChangeRequest -Title "My New CR" -ComputerName $ComputerName

.OUTPUTS
New Change Request

#>
Function New-CiresonChangeRequest {
    Param (
        $Title,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }

    #Variable / Class Setup
    $CRClass = Get-SCSMClass -name System.WorkItem.ChangeRequest$ @SCSM

    #Service Request Arguements
    $CRHash = @{
        Title = $Title;
        Id = “CR{0}”;
        Status = "New";
    }

    #Create Service Request
    $ChangeRequest = New-SCSMOBject -Class $CRClass -PropertyHashtable $CRHash -PassThru @SCSM

    Return $ChangeRequest
}

<#
.DESCRIPTION 
Pass in a Title and Description and create a new Manual Activity. Add it to the Parent Work Item as the last Activity.

.PARAMETER ParentWorkItem
The Work Item Object

.PARAMETER Title
The Title of the New Manual Activity

.PARAMETER Description
The Description of the New Manaul Activity

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "SR1996" -ComputerName $ComputerName
New-CiresonManualActivity -ParentWorkItem $SMObject -Title "This Activity" -Description "New Description" -ComputerName $ComputerName

.OUTPUTS
Manual Activity Object

#>
Function New-CiresonManualActivity {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$ParentWorkItem,
        [string]$Title,
        [string]$Description,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }


    $SequenceID = Get-CiresonNextAvailableSequenceID -SMObject $ParentWorkItem @SCSM


    $RelWorkItemContainsActivity = Get-SCSMRelationshipClass System.WorkItemContainsActivity$
    $ManualActivityClass = Get-SCSMClass  System.WorkItem.Activity.ManualActivity$

    $ManualActivityPropertyHash = @{Title = $Title; SequenceId = $SequenceId ; ID = 'MA{0}'; Description = $Description} 
    $ManualActivity = New-SCSMObject -Class $ManualActivityClass -PropertyHashtable $ManualActivityPropertyHash -NoCommit

    $RelObjectManualActivity = New-SCSMRelationshipObject -Relationship $RelWorkItemContainsActivity -Source $ParentWorkItem -Target $ManualActivity -NoCommit
    $RelObjectManualActivity.commit() 

    Return $ManualActivity
}

<#
.DESCRIPTION 
Pass in a Title and Description and create a new Parallel Activity. Add it to the Parent Work Item as the last Activity.

.PARAMETER ParentWorkItem
The Work Item Object

.PARAMETER Title
The Title of the New Parallel Activity

.PARAMETER Description
The Description of the New Parallel Activity

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "SR1996" -ComputerName $ComputerName
New-CiresonParallelActivity -ParentWorkItem $SMObject -Title "PA Activity" -Description "New Description" -ComputerName $ComputerName

.OUTPUTS
Parallel Activity Object

#>
Function New-CiresonParallelActivity {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$ParentWorkItem,
        [string]$Title,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }


    $SequenceID = Get-CiresonNextAvailableSequenceID -SMObject $ParentWorkItem @SCSM


    $RelWorkItemContainsActivity = Get-SCSMRelationshipClass System.WorkItemContainsActivity$
    $ParallelActivityClass = Get-SCSMClass  System.WorkItem.Activity.ParallelActivity$

    $ParallelActivityPropertyHash = @{Title = $Title; SequenceId = $SequenceId ; ID = 'PA{0}'} 
    $ParallelActivity = New-SCSMObject -Class $ParallelActivityClass -PropertyHashtable $ParallelActivityPropertyHash -NoCommit

    $RelObjectParallelActivity = New-SCSMRelationshipObject -Relationship $RelWorkItemContainsActivity -Source $ParentWorkItem -Target $ParallelActivity -NoCommit
    $RelObjectParallelActivity.commit() 

    Return $ParallelActivity
}

<#
.DESCRIPTION 
Pass in a Title and Description and create a new Review Activity. Add it to the Parent Work Item as the last Activity.  Set the Approval to Percentage and 100% by default.

.PARAMETER ParentWorkItem
The Work Item Object

.PARAMETER Title
The Title of the New Review Activity

.PARAMETER Description
The Description of the New Review Activity

.EXAMPLE
$SMObject = Get-CiresonWorkItem -WorkItemId "SR1996" -ComputerName $ComputerName
New-CiresonReviewActivity -ParentWorkItem $SMObject -Title "Approve Request" -Description "Approval is needed to proceed" -ComputerName $ComputerName

.OUTPUTS
Review Activity Object

#>
Function New-CiresonReviewActivity {
    Param (
        [Microsoft.EnterpriseManagement.Common.EnterpriseManagementObject]$ParentWorkItem,
        [string]$Title,
        [string]$Description,
        [boolean]$LineManager,
        [string]$ComputerName
    )
    
    $SCSM = @{
        ComputerName = $ComputerName
    }

    $SequenceID = Get-CiresonNextAvailableSequenceID -SMObject $ParentWorkItem @SCSM

    $RelWorkItemContainsActivity = Get-SCSMRelationshipClass System.WorkItemContainsActivity$
    $ReviewActivityClass = Get-SCSMClass  System.WorkItem.Activity.ReviewActivity$

    $ReviewActivityPropertyHash = @{
        Title = $Title; 
        Description = $Description; 
        LineManagerShouldReview = $LineManager; 
        ApprovalCondition = "ApprovalEnum.Percentage"; 
        ApprovalPercentage = 100; 
        SequenceId = $SequenceId ; 
        ID = 'RA{0}'
    } 
    $ReviewActivity = New-SCSMObject -Class $ReviewActivityClass -PropertyHashtable $ReviewActivityPropertyHash -NoCommit

    $RelObjectReviewActivity = New-SCSMRelationshipObject -Relationship $RelWorkItemContainsActivity -Source $ParentWorkItem -Target $ReviewActivity -NoCommit
    $RelObjectReviewActivity.commit() 

    Return $ReviewActivity
}
