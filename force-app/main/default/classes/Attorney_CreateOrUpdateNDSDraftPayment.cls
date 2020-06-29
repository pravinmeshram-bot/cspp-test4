global class Attorney_CreateOrUpdateNDSDraftPayment implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{
   
   global set<Id> processedOfferIds = new set<Id>();
   global set<Id> processedTradeLineIds = new set<Id>();
   global set<Id> processedGroupTaskIds = new set<Id>();
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<string> reProcessPaymentError = Attorney_StaticVariableUtility.reProcessConfigs('Payment',true);
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        return Database.getQueryLocator([Select Id, LastModifiedDate, Integration_Status__c, IsAttorney__c, Attorney_Payment_Id__c, RecordType.Name  from nu_dse__Payment__c where (IsAttorney__c=true and IsRelatedRecordEligibleForPick__c= true and 
                                                                                 ((Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED and 
                                                                                  (Integration_Reason__c Like:reProcessPaymentError or 
                                                                                   Integration_Reason_2__c Like:reProcessPaymentError)) or 
                                                                                  (Integration_Status__c = null and Attorney_Payment_Id__c =null) or (Category_changed__c = True and Recordtype.name = 'Draft') or
                                                                                  Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW)) OR (IsAttorney__c = true AND Attorney_Payment_Id__c != null AND RecordType.Name = 'Draft' AND Integration_Status__c = 'Initiated' AND LastModifiedDate <: System.now().addMinutes(-2))]);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> paymentList){
        
        //Payment
        List<nu_dse__Payment__c> paymentUpdList = new List<nu_dse__Payment__c>();
        for(nu_dse__Payment__c objPayment: paymentList)
        {
            if(objPayment.IsAttorney__c == true && objPayment.Attorney_Payment_Id__c != null && objPayment.RecordType.Name == 'Draft' && objPayment.Integration_Status__c == 'Initiated' && objPayment.LastModifiedDate < System.now().addMinutes(-2)){
                objPayment.Integration_Status__c = 'Failed';
                objPayment.Integration_Reason__c = 'Read timed out';
            }
            //else {
                paymentUpdList.add(objPayment);
            //}
        }
        update paymentUpdList;
          
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Attorney_CreateOrUpdateNDSGrpTaskBatch groupTask  = new Attorney_CreateOrUpdateNDSGrpTaskBatch(); 
        //Made changes by Rajesh to stop Backend jobs for Group Task NMI-882.
        NextBatchJobTimings_Push__c timings = NextBatchJobTimings_Push__c.getValues(UserInfo.getProfileId());
         timings.Is_Push_Job_Running__c = false;
         update timings;
   /*     if(!test.isRunningTest())
            Database.executeBatch(new Attorney_CreateOrUpdateNDSGrpTaskBatch(),1);*/
       
    }
}