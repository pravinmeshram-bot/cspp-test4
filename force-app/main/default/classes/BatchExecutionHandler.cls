public class BatchExecutionHandler {

    public static void initateScheduler(List<Batch_Execution__c> newBatchExecutionList, Map<Id, Batch_Execution__c> oldBatchExecutionMap, Boolean inInsert) {
    
        List<Batch_Execution__c> batchExecutionToUpdateList = new List<Batch_Execution__c>();
        
        if (newBatchExecutionList != null && newBatchExecutionList.isEmpty() == False) {
        
            for (Batch_Execution__c batchExecution : newBatchExecutionList) {
            
                if ((inInsert || (inInsert == False && batchExecution.Is_Active__c != oldBatchExecutionMap.get(batchExecution.Id).Is_Active__c))
                        && String.isNotBlank(batchExecution.CRON_Expression__c) && batchExecution.Is_Active__c == True
                        && String.isBlank(batchExecution.CRON_Job_Id__c)) {
                
                    String jobID =  system.schedule(batchExecution.Name, batchExecution.CRON_Expression__c, new ScheduleBatchExecution(batchExecution.Id));
                    
                    Batch_Execution__c batchExecutionRecToUpdate = new Batch_Execution__c();
                    batchExecutionRecToUpdate.Id = batchExecution.Id;
                    batchExecutionRecToUpdate.CRON_Job_Id__c = jobID;
                    batchExecutionToUpdateList.add(batchExecutionRecToUpdate);
                }
            }
            
            if (batchExecutionToUpdateList.isEmpty() == False) {
            
                update batchExecutionToUpdateList;
            }
        }
    }
    
    public static void abortScheduler(List<Batch_Execution__c> newBatchExecutionList, Map<Id, Batch_Execution__c> oldBatchExecutionMap) {
    
        if (newBatchExecutionList != null && newBatchExecutionList.isEmpty() == False) {
        
            for (Batch_Execution__c batchExecution : newBatchExecutionList) {
            
                if (batchExecution.Is_Active__c == False && batchExecution.Is_Active__c != oldBatchExecutionMap.get(batchExecution.Id).Is_Active__c
                        && String.isNotBlank(batchExecution.CRON_Job_Id__c)) {
                
                    System.abortJob(batchExecution.CRON_Job_Id__c);
                    batchExecution.CRON_Job_Id__c = null;
                }
            }
        }
    }
}