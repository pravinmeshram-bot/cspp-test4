global class Attorney_CreateOrUpdateNDSGrpTaskBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{
   

    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<string> reProcessGrpTaskError = Attorney_StaticVariableUtility.reProcessConfigs('Group_Task',true);
        return Database.getQueryLocator([Select Id from nu_dse__Group_Task__c where ((Subject_Picklist__c != null and Subject_Picklist__c != '') or (nu_dse__Subject__c != null and nu_dse__Subject__c != '')) and IsAttorney__c=true and  IsRelatedRecordEligibleForPick__c= true and
                                                                                 ((Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED and 
                                                                                  (Integration_Reason__c Like:reProcessGrpTaskError or 
                                                                                   Integration_Reason_2__c Like:reProcessGrpTaskError)) or 
                                                                                  (Integration_Status__c = null and Task_Id__c = null) or
                                                                                 Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW)]);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Group_Task__c> groupTaskList){
        
        //GroupTask
        List<nu_dse__Group_Task__c> GroupTaskUpdList = new List<nu_dse__Group_Task__c>();
        for(nu_dse__Group_Task__c objGrpTask : groupTaskList)
        {
            GroupTaskUpdList.add(objGrpTask);
        }
        update GroupTaskUpdList;
          
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Attorney_CreateOrUpdateNDSTaskBatch Task  = new Attorney_CreateOrUpdateNDSTaskBatch(); 
        if(!Test.isRunningTest())
        Database.executeBatch(new Attorney_CreateOrUpdateNDSTaskBatch(),1);
         NextBatchJobTimings_Push__c timings = NextBatchJobTimings_Push__c.getValues(UserInfo.getProfileId());
         timings.Is_Push_Job_Running__c = false;
         update timings;

    }
}