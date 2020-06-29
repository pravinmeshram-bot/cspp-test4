global class Schedule_DuplicateAttachmentAndSync implements Schedulable {
   
   public Integer batchSize;
   public String queryFilterCondition;
   public String orderingAndLimit;
   
   public Schedule_DuplicateAttachmentAndSync () {
       
   }
   
   public Schedule_DuplicateAttachmentAndSync (Integer bSize, String dataQueryFilterCondition, String ordering) {
       
       if (batchSize != null && batchSize > 0) {
           
           batchSize = bSize;
       }
       
       if (String.isNotBlank(dataQueryFilterCondition) == True) {
           
           this.queryFilterCondition= dataQueryFilterCondition;
       }
       
       if (String.isNotBlank(ordering) == True) {
           
           this.orderingAndLimit = ordering;
       }
   }
   
   global void execute(SchedulableContext sc) {
      
      if (batchSize == null) {
          
          batchSize = 1;
      }
      
      Batch_DuplicateAttachmentAndSync syncBatchInstance = new Batch_DuplicateAttachmentAndSync();
      syncBatchInstance.filterCondition = queryFilterCondition;
      syncBatchInstance.orderingAndLimit = orderingAndLimit;
      
      database.executebatch(syncBatchInstance, batchSize);
   }
}