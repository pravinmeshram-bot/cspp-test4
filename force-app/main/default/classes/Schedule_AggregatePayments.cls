public class Schedule_AggregatePayments implements Schedulable {
    
   public Integer batchSize = 50;
   public String queryString;
   
   public void execute(SchedulableContext SC) {
      
      Batch_AggregatePayments aggregatePayments = new Batch_AggregatePayments();
      
      if (String.isNotBlank(queryString)) {
          
          aggregatePayments.queryString = queryString;
      }
      Database.executeBatch(aggregatePayments, batchSize); 
   }
}