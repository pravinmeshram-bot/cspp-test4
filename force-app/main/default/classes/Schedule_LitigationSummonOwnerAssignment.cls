public class Schedule_LitigationSummonOwnerAssignment implements Schedulable  {
    
    public Integer batchSize;
    
    public Schedule_LitigationSummonOwnerAssignment() {
    
        batchSize = 50 ;
    }
    
    public void execute(SchedulableContext SC) {
        
        Database.executeBatch(new Batch_LitigationSummonOwnerAssignment(), batchSize);
    }
}