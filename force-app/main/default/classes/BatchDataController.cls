public with sharing class BatchDataController {

    public List<Batch_Data__c> BatchDataList{get; set;} 

    public BatchDataController(ApexPages.StandardSetController controller) {
        BatchDataList = [Select Id, Last_Execution_Time__c, Name, Batch_Execution_Status__c, Emails_To_Notify__c, Batch_Failure_Reason__c, Number_of_Callouts__c from Batch_Data__c where isAsyncMethod__c = false];
        
    }


    public BatchDataController(ApexPages.StandardController controller) {
        
    }
    
    public pageReference saveData(){
        System.debug(BatchDataList);
        
        Update BatchDataList;
        return null;
    }

}