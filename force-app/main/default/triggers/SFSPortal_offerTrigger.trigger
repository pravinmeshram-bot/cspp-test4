trigger SFSPortal_offerTrigger on nu_dse__Offer__c (after insert, after update) {

    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        
        SFSPortal_OfferHandler.sendNotificationToOffer(trigger.new, trigger.oldMap);    
    } 
}