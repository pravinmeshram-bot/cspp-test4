public class Attorney_ProcessEmptyExternalIdPaySch implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Attorney_ProcessEmtpyExternalIdPayments(),10);
    }
    
}