trigger Attorney_CreateOrUpdateNDSOfferTrigger on nu_dse__Offer__c (after Insert,after update,before Update, Before Insert) {
    
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSOfferTrigger'];
    User u = Attorney_StaticVariableUtility.currentUser;
    
    if(Trigger.isBefore && Trigger.isUpdate && !u.Attorney_Ignore_Validation__c){
        Attorney_CreateOrUpdateNDSOfferHandler.validateOfferAccepted();
    }
    
    if (Trigger.isAfter) {
        if(TriggerFlag.isActive__c){
            if(Attorney_StaticVariableUtility.isOfferTriggerExecuted == false)
            {
                Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;// moving it to handler
                if(Trigger.isUpdate){
                Attorney_CreateOrUpdateNDSOfferHandler.UpdateTradeStatus();
                 
                Attorney_CreateOrUpdateNDSOfferHandler.CreateOrUpdateNDSPaymentOffer(trigger.new, trigger.oldMap); 
                }
            }
        }
        if(Trigger.isInsert && !u.Overwrite_Latest_Offer__c){
            Attorney_CreateOrUpdateNDSOfferHandler.UpdateRelatedOfferField(Trigger.new);
        }
        if(Trigger.isUpdate){
            Attorney_CreateOrUpdateNDSOfferHandler.deleteCanceledTasks();
            Attorney_CreateOrUpdateNDSOfferHandler.updateFundsSource();
        }
    }
        
    if(Trigger.isBefore && Trigger.isInsert && !u.Overwrite_Latest_Offer__c){
        
        Attorney_CreateOrUpdateNDSOfferHandler.UpdateOfferField(Trigger.New);
    }
    
    //Created this method for NMI-315. Updating Offer Created By from NDS.
     if(Trigger.isBefore){
         Attorney_CreateOrUpdateNDSOfferHandler.UpdateOfferCreatedBy();
     }
    
    if(Trigger.isBefore){
        Prizm_OfferHandler.UpdateLastDebt();
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        
        System.debug('Trigger Fired-->'+ Trigger.new);
        OfferStatusUpdateHandler.updateOfferStatus(Trigger.new, Trigger.oldMap);
    }
}