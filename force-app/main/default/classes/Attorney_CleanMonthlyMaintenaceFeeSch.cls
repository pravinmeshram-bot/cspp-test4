public class Attorney_CleanMonthlyMaintenaceFeeSch implements Schedulable{
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Attorney_CleanMonthlyMaintenaceFee(),1);
    }
    
}