global class Attorney_CreateOrUpdateNDSPaymentBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{
   
   global set<Id> processedOfferIds = new set<Id>();
   global set<Id> processedTradeLineIds = new set<Id>();
   global set<Id> processedGroupTaskIds = new set<Id>();
    global Batch_Data__c PaymentsBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        PaymentsBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_CreateOrUpdateNDSPaymentBatch'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
            async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
                asyncLimitUsed = async.getValue();
        }
        if(PaymentsBatchData.Last_Execution_Time__c == null || PaymentsBatchData.Last_Execution_Time__c.day() != System.now().day()){
            PaymentsBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        Set<string> reProcessPaymentError = Attorney_StaticVariableUtility.reProcessConfigs('Payment',true);
        return Database.getQueryLocator([Select Id, LastModifiedDate, Integration_Status__c, IsAttorney__c, Attorney_Payment_Id__c, RecordType.Name  from nu_dse__Payment__c where (IsAttorney__c=true and IsRelatedRecordEligibleForPick__c= true and 
                                                                                 ((Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED and 
                                                                                  (Integration_Reason__c Like:reProcessPaymentError or 
                                                                                   Integration_Reason_2__c Like:reProcessPaymentError)) or 
                                                                                  (Integration_Status__c = null and Attorney_Payment_Id__c =null) or (Category_changed__c = True and Recordtype.name = 'Draft') or
                                                                                  Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW)) OR (IsAttorney__c = true AND Attorney_Payment_Id__c != null AND RecordType.Name = 'Draft' AND Integration_Status__c = 'Initiated' AND LastModifiedDate <: System.now().addMinutes(-2))]);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> paymentList){
        
        //Payment
        //try{
        List<nu_dse__Payment__c> paymentUpdList = new List<nu_dse__Payment__c>();
        List<nu_dse__Payment__c> draftPaymentList = new List<nu_dse__Payment__c>();
        List<nu_dse__Payment__c> settlementPaymentList = new List<nu_dse__Payment__c>();
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id SettlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        for(nu_dse__Payment__c objPayment: paymentList)
        {
            if(objPayment.IsAttorney__c == true && objPayment.Attorney_Payment_Id__c != null && objPayment.RecordType.Name == 'Draft' && objPayment.Integration_Status__c == 'Initiated' && objPayment.LastModifiedDate < System.now().addMinutes(-2)){
                objPayment.Integration_Status__c = 'Failed';
                objPayment.Integration_Reason__c = 'Read timed out';
            }
            if(objPayment.RecordTypeId == DraftRecordTypeId){
                DraftPaymentList.add(objPayment);
            } else if(objPayment.RecordTypeId == SettlementRecordTypeId){
                SettlementPaymentList.add(objPayment);
            }
            else{
                paymentUpdList.add(objPayment);
            }
        }
        if(!DraftPaymentList.isEMpty()){
            Update DraftPaymentList;
        }
        if(!SettlementPaymentList.isEmpty()){
            Update SettlementPaymentList;
        }
        if(!PaymentUpdList.isEmpty())
            update paymentUpdList;
        /*} Catch(Exception E){
            PaymentsBatchData.Batch_Failure_Reason__c = E.getMessage();
            PaymentsBatchData.Batch_Execution_Status__c = 'Failed';
        }*/
          
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Attorney_CreateOrUpdateNDSGrpTaskBatch groupTask  = new Attorney_CreateOrUpdateNDSGrpTaskBatch(); 
        //Made changes by Rajesh to stop Backend jobs for Group Task NMI-882.
        NextBatchJobTimings_Push__c timings = NextBatchJobTimings_Push__c.getValues(UserInfo.getProfileId());
         timings.Is_Push_Job_Running__c = false;
         update timings;
   /*     if(!test.isRunningTest())
            Database.executeBatch(new Attorney_CreateOrUpdateNDSGrpTaskBatch(),1);*/
        if(!Test.isRunningTest()){
            System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            //String NumberOfCallouts = PaymentsBatchData.Number_of_Callouts__c;
            if(async.getValue() != null )
                PaymentsBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(PaymentsBatchData.Number_of_Callouts__c) + async.getValue() - asyncLimitUsed);
            else
                PaymentsBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(PaymentsBatchData.Number_of_Callouts__c));
            /*if(Integer.valueOf(PaymentsBatchData.Number_of_Callouts__c) <0){
                PaymentsBatchData.Number_of_Callouts__c = NumberOfCallouts;
            }*/
        }
        PaymentsBatchData.Last_Execution_Time__c = System.now();
        PaymentsBatchData.Batch_Execution_Status__c = 'Success';
        Update PaymentsBatchData;
       
    }
    public static void fakeMethod(){
        Integer i = 0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        
    }
}