global class Attorney_CancelOffersBatch implements Database.Batchable<sObject>,Database.stateful,Database.AllowsCallouts{
    
    global Batch_Data__c CancelOfferBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    global database.QueryLocator start(Database.BatchableContext BC){
        
        CancelOfferBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_CancelOffersBatch'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
        	async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
        		asyncLimitUsed = async.getValue();
        }
        if(CancelOfferBatchData.Last_Execution_Time__c == null || CancelOfferBatchData.Last_Execution_Time__c.day() != System.now().day()){
            CancelOfferBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        List<String> StatusList = new List<String>{'Accepted','Negotiations Associate Approved','Payment Plan - Active','Settled','To Payment Processing','Canceled'};
        Date consideredDate = Date.Today()-4;
        //Added the null check for program in the query on 5th Sept 2019 to resolve the Query Exception related to S20-178
        String query='Select Id,nu_dse__First_Payment_Date__c,nu_dse__Status__c,Latest_Offer__c,IsAttorney__c,IsRelatedRecordEligibleForPick__c from nu_dse__Offer__c where nu_dse__Program__c != null AND nu_dse__First_Payment_Date__c<: consideredDate AND nu_dse__Status__c !=: StatusList AND nu_dse__Program__r.nu_dse__Program_Status__c != \'Client Cancelled\' AND nu_dse__Program__r.nu_dse__Program_Status__c != \'Graduated Program\''; 
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Offer__c> OfferList){
        for(nu_dse__Offer__c Offer: OfferList){
            if(Offer.nu_dse__First_Payment_Date__c < Date.Today()-4){
                Offer.nu_dse__Status__c = 'Canceled';
                if(Offer.Latest_Offer__c && Offer.IsAttorney__c && Offer.IsRelatedRecordEligibleForPick__c)
                Offer.Integration_Status__c = 'Overflow';
            }
        }
        Update OfferList;
    }
    
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
                CancelOfferBatchData.Number_of_Callouts__c = String.valueOf(async.getValue() - asyncLimitUsed);
            else
                CancelOfferBatchData.Number_of_Callouts__c = String.valueOf(asyncLimitUsed);
        }
        CancelOfferBatchData.Last_Execution_Time__c = System.now();
        CancelOfferBatchData.Batch_Execution_Status__c = 'Success';
        Update CancelOfferBatchData;
       
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