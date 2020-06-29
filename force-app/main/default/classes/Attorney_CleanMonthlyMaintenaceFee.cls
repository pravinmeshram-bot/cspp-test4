public class Attorney_CleanMonthlyMaintenaceFee implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
	
    public Batch_Data__c OfferBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        OfferBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_CleanMonthlyMaintenaceFee'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
        	async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
        		asyncLimitUsed = async.getValue();
        }
        if(OfferBatchData.Last_Execution_Time__c == null || OfferBatchData.Last_Execution_Time__c.day() != System.now().day()){
            OfferBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        
        id draftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        //List<nu_dse__Payment__c> Payments = [Select id, nu_dse__Monthly_Maintenance_Fee__c from nu_dse__Payment__c where nu_dse__Monthly_Maintenance_Fee__c != null AND RecordTypeId =: DraftRecordType];
        String query = 'Select id, nu_dse__Monthly_Maintenance_Fee__c from nu_dse__Payment__c where nu_dse__admin_fee__c != null and nu_dse__Monthly_Maintenance_Fee__c != null AND nu_dse__Monthly_Maintenance_Fee__c>0 AND RecordTypeId =: DraftRecordType AND IsAttorney__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<nu_dse__Payment__c> Payments){
        try{
        List<Id> DraftIds = new List<Id>();
        for(nu_dse__Payment__c Payment: Payments){
            DraftIds.add(Payment.Id);
            Payment.nu_dse__Monthly_Maintenance_Fee__c = 0;
        }
        id draftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        List<nu_dse__Payment__c> FeePayments = [Select Id,nu_dse__Transaction_Status__c,Payment_Status__c  from nu_dse__Payment__c where nu_dse__Advance_Payment__c =: DraftIds AND nu_dse__Payment_Type__c = 'Maintenance Fee' AND Payment_Status__c != 'Canceled'];
        
        for(nu_dse__Payment__c Payment: FeePayments){
            Payment.nu_dse__Transaction_Status__c = 'Cancelled';
            Payment.Payment_Status__c = 'Canceled';
            Payments.add(Payment);
        }
        Update Payments;
        
        } Catch(Exception E){
            OfferBatchData.Batch_Failure_Reason__c = E.getMessage();
            OfferBatchData.Batch_Execution_Status__c = 'Failed';
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
        System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            String NumberOfCallouts = OfferBatchData.Number_of_Callouts__c;
            if(async.getValue() != null)
                OfferBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(OfferBatchData.Number_of_Callouts__c) + async.getValue() - asyncLimitUsed);
            else
                OfferBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(OfferBatchData.Number_of_Callouts__c));
            if(Integer.valueOf(OfferBatchData.Number_of_Callouts__c) <0){
                OfferBatchData.Number_of_Callouts__c = NumberOfCallouts;
            }
        }
        OfferBatchData.Last_Execution_Time__c = System.now();
        OfferBatchData.Batch_Execution_Status__c = 'Success';
        Update OfferBatchData;
       
    }
    
}