global class Schedule_CreateStrategyCallTaskOnProg implements Schedulable  {
    
    global Integer batchSize = 1;
    
    global void execute(SchedulableContext SC) {
    
        Database.executeBatch(new Batch_CreateStrategyCallTaskOnProgram(), batchSize);
    }
}