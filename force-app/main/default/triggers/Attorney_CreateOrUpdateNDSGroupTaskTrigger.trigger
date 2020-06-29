trigger Attorney_CreateOrUpdateNDSGroupTaskTrigger on nu_dse__Group_Task__c (after Insert,after update,before insert,before Update) {
    
    //Inactivated by Rajesh on 3/15/2019 to stop pushing Task and Group Task and related functionalities NMI-882. It push Group Task and also populated owner of Group Task those are coming in from NDS.
    //Activated and Commented out the below logic on Sept 11, 2019 to work on other trigger functionalities.
    
    /*AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSGroupTaskTrigg'];
    
    if(trigger.isAfter){
        
        if(TriggerFlag.isActive__c){
        
            if(Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted == false) {
            
                Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
                Attorney_CreateOrUpdateNDSGrpTaskHandler.CreateOrUpdateNDSGrpTask(Trigger.new, trigger.OldMap);                 
            }
        }
    }
    
    if(trigger.isBefore){
        
        Attorney_CreateOrUpdateNDSGrpTaskHandler.UpdateTaskOwner(Trigger.new,Trigger.isInsert, Trigger.OldMap); 
    }*/   
    
    if (Trigger.isBefore) {
        
        if (Trigger.isInsert) {
            Attorney_CreateOrUpdateNDSGrpTaskHandler.UpdateRefundTaskOwner();
            //S20-88
            GroupTaskHandler.replaceGroupTaskOwner(Trigger.new, null);
            
        } else if (Trigger.isUpdate) {
        
            //S20-88
            GroupTaskHandler.replaceGroupTaskOwner(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isBefore && Trigger.isInsert) {
    GroupTaskHandler.populateExcelaTradline(Trigger.new);
    }
}