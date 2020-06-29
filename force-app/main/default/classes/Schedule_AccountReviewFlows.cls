global class Schedule_AccountReviewFlows implements Schedulable  {
    
    global Integer batchSize = 10;
    
    global void execute(SchedulableContext SC) {
    
        Database.executeBatch(new Batch_AccountReviewFlows(), batchSize);
    }
}