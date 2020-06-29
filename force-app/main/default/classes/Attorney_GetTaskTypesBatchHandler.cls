public without sharing class Attorney_GetTaskTypesBatchHandler {
    public static LeadtracNetClient.TaskTypeResult taskTypeResult;
    public static List<nu_dse_Task_Type__c> getTaskTypes()
    {
        List<nu_dse_Task_Type__c> ObjecttaskTypeUpsertList = new List<nu_dse_Task_Type__c>();
        LeadtracNetClient.ClientServiceSoap soap = new LeadtracNetClient.ClientServiceSoap();
        
        if (!Test.isRunningTest()) {
            taskTypeResult = new LeadtracNetClient.TaskTypeResult();
        	taskTypeResult = soap.GetTaskTypes(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c);
        }
        if(taskTypeResult.IsSuccessful == true)
        {
             LeadtracNetClient.ArrayOfTaskType arryofTaskType = taskTypeResult.TaskType;
             for(LeadtracNetClient.TaskType t: arryofTaskType.TaskType)
             {
                 nu_dse_Task_Type__c ObjTaskType = new nu_dse_Task_Type__c();
                 ObjTaskType.TaskTypeId__c = String.valueOf(t.TaskTypeId);
                 ObjTaskType.TaskName__c = t.Name;
                 ObjecttaskTypeUpsertList.add(ObjTaskType);   
             }
        }
        
        return ObjecttaskTypeUpsertList;
    }
}