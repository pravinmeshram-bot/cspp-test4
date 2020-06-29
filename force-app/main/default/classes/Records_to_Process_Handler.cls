public class Records_to_Process_Handler {
    
    public static void createRecord(LIst<Id> recordIds, string integrationType){
        
        List<Records_To_Process__c> recordsToProcessList = new List<Records_To_Process__c>();
        
        for(Id rId: recordIds){
         
         Records_To_Process__c recordToprocess = new Records_To_Process__c(); 
         recordToprocess.Record_Id__c = rId; 
         recordToProcess.Integration_Type__c = integrationType; 
         recordToProcess.Status__c = 'Pending';
         
         recordsToProcessList.add(recordToProcess);
         
        }
        
        insert recordsToProcessList;
    }

}