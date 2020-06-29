global class Attorney_GetTaskTypesBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts{

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([Select Id from nu_dse_Task_Type__c Limit 1]);
   }

   global void execute(Database.BatchableContext BC, List<nu_dse_Task_Type__c> taskTypeList){
       
       List<nu_dse_Task_Type__c> taskTypeUpsertList = new List <nu_dse_Task_Type__c> ();
       if (!Test.isRunningTest())
           taskTypeUpsertList = Attorney_GetTaskTypesBatchHandler.getTaskTypes();
       Schema.SObjectField f = nu_dse_Task_Type__c.Fields.TaskTypeId__c;
       Database.UpsertResult [] cr = Database.upsert(taskTypeUpsertList, f, false);
    }

   global void finish(Database.BatchableContext BC){
       
   }
}