trigger Prizm_LeadTrigger on Lead (before insert, before update, after insert, after update) {
    
    
    if(Trigger.isBefore){
        
        if(!Prizm_LeadTriggerHandler.isTriggerExecuted){
        Prizm_LeadTriggerHandler.Prizm_LeadTriggerBefore();
        }
        
        
    }
    
    if(Trigger.isAfter && !Prizm_LeadTriggerHandler.isTriggerExecuted){
        //Prizm_LeadTriggerHandler.roundRobinLeadAssignment();
        if(Trigger.isInsert)
        Prizm_LeadTriggerHandler.Prizm_LeadTriggerAfter();
        
    }
}