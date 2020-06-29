global class Schedule_ExecutePaymentFlows implements Schedulable  {
    
    global Integer batchSize = 30;
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_ExecutePaymentFlows(), batchSize);
    }
}