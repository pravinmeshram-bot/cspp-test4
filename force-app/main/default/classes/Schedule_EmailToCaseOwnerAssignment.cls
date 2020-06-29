public class Schedule_EmailToCaseOwnerAssignment implements Schedulable  {
    
    public Integer batchSize;
    
    public Schedule_EmailToCaseOwnerAssignment() {
        
        batchSize = 50 ;
    }
    
    public void execute(SchedulableContext SC) {
    
        Database.executeBatch(new Batch_EmailToCaseOwnerAssignment(), batchSize);
    }
}