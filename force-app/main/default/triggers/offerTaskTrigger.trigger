trigger offerTaskTrigger on nu_dse__Offer__c(after insert, after update, before update) { 
    
    if (Trigger.isBefore) {
        
        if (Trigger.isUpdate) {
        
            OfferHandler.ToLockOfferRecord(Trigger.new, Trigger.oldMap);
            
            //S20-19
            OfferHandler.ClientAuthFor15Days(Trigger.new, Trigger.oldMap);
            
            //S20-94
            //OfferHandler.validateApprovalRejection(Trigger.new, Trigger.oldMap);
        } 
                  
    } else if (Trigger.isAfter) {
    
        if (Trigger.isUpdate) {
            
            //S20-457 Updated the logic to reactivate tasks under offer...
            OfferHandler.ToCancelTask(Trigger.new,Trigger.oldMap);
            
            //S20-178
            OfferHandler.ToRejectPendingApprovals(Trigger.new, Trigger.oldMap);
            
            //S20-93
            OfferHandler.ToSetTradelineCurrentStage(Trigger.new, Trigger.oldMap);   
            
            //ND-279
            //OfferHandler.UpdateScheduleDate(Trigger.new, Trigger.oldMap);      
            
            //DV-590
            OfferHandler.approveFundingOnLendingApplication(Trigger.new, Trigger.oldMap);   
        }
    }
}