trigger ProspectTrigger on nu_dse__Prospect__c (after insert, after update, Before insert) {

    if (Trigger.isAfter && Trigger.isUpdate && !System.isFuture() && !System.isBatch()) {
    
        ProspectHandler.handle(trigger.oldMap, trigger.newMap);
    }
    
    if (system.isFuture() == False && Trigger.new.size() == 1 && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    
        for (nu_dse__Prospect__c p : Trigger.new) {
            
             if((p.boxfolderid__c == '' || p.boxfolderid__c == null) && p.portfolio__c != null){
               
                CreateParentAndSubFoldersInBox.createProspectFolder(Trigger.newMap.keySet());
             
             }
             
        }
    }
    
    /*if(Trigger.isAfter && Trigger.isInsert){
        System.enqueueJob(new ProspectHandler.UpdatePortfolio(Trigger.new));
    }*/
    
    if(Trigger.isBefore && Trigger.isInsert){
        ProspectHandler.populatePortfolio();
    }
}