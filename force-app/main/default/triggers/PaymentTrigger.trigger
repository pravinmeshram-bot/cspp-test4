trigger PaymentTrigger on nu_dse__Payment__c (before Insert,before Update,after Insert, after Update,after delete) {
 //   AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSPaymentTrigger'];
 //   if(TriggerFlag.isActive__c){
        if(Trigger.isAfter && (Trigger.IsInsert || Trigger.IsUpdate)) {
            System.debug('*****is After payment trigger');
            if(Attorney_StaticVariableUtility.isPaymentTriggerExecuted == false)
            {
                //Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;// moving it to handler
                System.debug('*****execution pending');
                If(Trigger.New[0].IsAttorney__c)
                {
                
                Attorney_CreateOrUpdateNDSPaymentHandler.CreateOrUpdateNDSPayment(trigger.new, trigger.oldMap,trigger.newMap); 
                }
                
            }
        }
        
//    } 
   
    //@Description: Commenting on request of Mayur as per ticket. ticket#NMI-187. 
  /*  
    if(Trigger.isAfter && Trigger.IsUpdate)
{
    if(Trigger.New[0].nu_dse__Program__r.RecordType.Name != 'Data-Temp' || Trigger.Old[0].nu_dse__Program__r.RecordType.Name != 'Data-Temp' || Trigger.Old[0].nu_dse__Program__r.nu_dse__Account__r.User_Bypasses_Triggers__c == false || Trigger.New[0].nu_dse__Program__r.nu_dse__Account__r.User_Bypasses_Triggers__c == false){
        if((Trigger.New[0].Timberline__c == true || Trigger.Old[0].Timberline__c == true ) && Trigger.New[0].Attorney__c == FALSE && 
        Trigger.New[0].IsAttorney__c == False && Trigger.Old[0].Attorney__c == FALSE && Trigger.Old[0].IsAttorney__c == FALSE){ 
           PaymentHandler.handle(trigger.oldmap, trigger.newmap);
        }
    }
    }
 */   

    
    /*if(Trigger.isBefore){// && Trigger.isUpdate){ //!Attorney_CreateOrUpdateNDSPaymentHandler.BeforeUpdateExecuted){

        Attorney_CreateOrUpdateNDSPaymentHandler.BeforeUpdateHandler(trigger.new,trigger.newMap,trigger.isInsert);
    }*/
    
    //Changes made by Vaibhav - NMI-523
    if(Trigger.isAfter){   
    
   
    
        Attorney_CreateOrUpdateNDSPaymentHandler.UpdateProgramRollUps();
        
        
        if(Trigger.IsDelete)
        {
            Attorney_CreateOrUpdateNDSPaymentHandler.rollupCalculationToOffer(trigger.old);
        }  
        else
        {
        
               
            Attorney_CreateOrUpdateNDSPaymentHandler.CreateRefundRecord(trigger.new, trigger.oldMap,trigger.newMap);            
            if(!Attorney_CreateOrUpdateNDSPaymentHandler.rollupToOfferUpdated) 
            Attorney_CreateOrUpdateNDSPaymentHandler.rollupCalculationToOffer(trigger.new); 
            
          if(!Prizm_PaymentHandler.PrizmTriggerExceuted){      
                Prizm_PaymentHandler.Prizm_UpdateLeadFields(trigger.new, Trigger.newMap);
                Prizm_PaymentHandler.Prizm_UpdateOpportunities();
            } 
        }  
    }
 
    
/* 
 * Payment status fields and UpdatePaymentAsDont Override 
 */
    if (Trigger.isBefore && Trigger.isUpdate && Trigger.new.size() == 1) {
    
        PaymentUpdateTriggerHandler.updatePaymentAsDontOverride(Trigger.new, Trigger.oldMap);
    }
    
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
      //PaymentStatusUpdateHandler.updateStatusForFields(Trigger.new, Trigger.oldMap);
      PaymentStatusUpdateHandler.updateStatusForFieldsAdmin(Trigger.new, Trigger.oldMap);
    }
    
    if(!Velocify_PaymentHandler.VelocifyExecuted){    
       VelocifyTriggerActive__mdt VelocifyTrigger = [Select Id,isActive__c from VelocifyTriggerActive__mdt where DeveloperName ='PaymentTriggerActive'];
          If(VelocifyTrigger.IsActive__c)  {
          //User currentUser = [Select id, Velocify_Admin__c from User where Id =: UserInfo.getUserId()];    
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && !Attorney_staticVariableUtility.VelocifyAdmin){
                System.debug('*******trigger');
                Velocify_PaymentHandler.updatePaymentDetailsInVelocify(Trigger.newMap,Trigger.oldMap);
            }
        }
        
   } 
    //S20-489 starts
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            PaymentTrigHandler.handleAfterInsert(Trigger.newMap);
            
            //DV-591
            PaymentTrigHandler.populateLastPaymentDateOnProgram(Trigger.new, null, Trigger.isUpdate);
        }
        
        if(Trigger.isUpdate){
            PaymentTrigHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            
            //DV-591
            PaymentTrigHandler.populateLastPaymentDateOnProgram(Trigger.new, Trigger.oldMap, Trigger.isUpdate);
        }
        
        if(Trigger.isDelete){
            PaymentTrigHandler.handleAfterDelete(Trigger.oldMap);
            
            //ND-221 by Uchit
            Attorney_CreateOrUpdateNDSPaymentHandler.deletePaymentFromNDS();
            
            //DV-591
            PaymentTrigHandler.populateLastPaymentDateOnProgram(Trigger.old, null, Trigger.isUpdate);
        }
    }
    //S20-489 ends
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        Attorney_CreateOrUpdateNDSPaymentHandler.UpdateFundsSource();
    }
    
    //Below method added by Mayur for ND-322
    if(Trigger.isBefore && Trigger.isUpdate){
        Attorney_CreateOrUpdateNDSPaymentHandler.UpdateFeeStatus();
    }
    // ND-345 Start - added by Praveen
    if(Trigger.isBefore &&(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
        PaymentTrigHandler.lockPaymentsOnProgram_DNLStatus(Trigger.new, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
    }
    // ND-345 End
}