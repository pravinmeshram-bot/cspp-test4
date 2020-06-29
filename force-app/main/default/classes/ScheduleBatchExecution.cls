global class ScheduleBatchExecution implements Schedulable {
    
    Id batchExecutionId;
    
    global ScheduleBatchExecution(Id batchExecutionIdVal) {
    
        batchExecutionId = batchExecutionIdVal;
    }
    
    global void execute(SchedulableContext SC) {
        
        Database.executeBatch(new Batch_Execution(batchExecutionId), 1);
    }
}