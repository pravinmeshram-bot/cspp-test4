trigger Attorney_CreateOrUpdateNDSWorkflowTrigger on Workflow__c (after Insert,after update) {
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSWorkflowTrigge'];
    if(TriggerFlag.isActive__c){
        if(Attorney_StaticVariableUtility.isWorkflowTriggerExecuted == false)
        {
            Attorney_StaticVariableUtility.isWorkflowTriggerExecuted = true;
            Attorney_CreateOrUpdateNDSWrkFlowHandler.CreateOrUpdateNDSWrkFlow(trigger.new, trigger.oldMap); 
        }
    }
}