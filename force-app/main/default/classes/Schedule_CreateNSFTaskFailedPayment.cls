global class Schedule_CreateNSFTaskFailedPayment implements Schedulable  {
    
    global Integer batchSize = 30;
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_CreateNSFTaskFailedPayment(), batchSize);
    }
}