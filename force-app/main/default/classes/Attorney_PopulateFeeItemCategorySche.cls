public class Attorney_PopulateFeeItemCategorySche implements Schedulable{
  
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Attorney_PopulateFeeItemCategory(),1);
    }
    
    
}