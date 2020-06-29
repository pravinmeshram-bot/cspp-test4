global class Schedule_PauseAccountReviewFlows implements Schedulable  {
    
    global Integer batchSize = 10;
    
    global void execute(SchedulableContext SC) {
    
        Database.executeBatch(new Batch_PauseAccountReviewFlows(), batchSize);
    }
}