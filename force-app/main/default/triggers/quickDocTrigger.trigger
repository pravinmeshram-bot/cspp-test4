trigger quickDocTrigger on Quick_Doc__c (after insert) {
    if(trigger.isInsert && trigger.isAfter){
        quickDocTriggerHandler.CreateActivityOnQuickDocCreation(trigger.new); 
    } 
}