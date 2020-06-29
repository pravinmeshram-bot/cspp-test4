public class BatchSyncGroupTaskbasedOnTask implements Database.Batchable<sObject> { 
    
        
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, nu_dse__Group_Task__c FROM TASK WHERE nu_dse__Group_Task__c != null AND Status = \'Completed\' AND nu_dse__Group_Task__r.nu_dse__Status__c <> \'Completed\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Task> taskList) {
        
        List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>();
        set<Id> groupTaskId = new Set<Id>();
        
        for (Task taskInstance : taskList) {
            
            if (!groupTaskId.Contains(taskInstance.nu_dse__Group_Task__c)) {
                
                nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c(Id = taskInstance.nu_dse__Group_Task__c);
                groupTask.nu_dse__Status__c = 'Completed';
                groupTaskList.add(groupTask);
                groupTaskId.add(taskInstance.nu_dse__Group_Task__c);
            }
        }    
        if (groupTaskList.isEmpty() == False) {
            
            Database.SaveResult[] groupTaskUpdateResultList = Database.update(groupTaskList, false);
            List<nu_dse__Error_log__c> errorLogList = new List<nu_dse__Error_log__c>();
            Integer i = 0;
            for (Database.SaveResult sr : groupTaskUpdateResultList) {
                                            
                if (sr.isSuccess() == False) {
                    
                    nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'BatchSyncGroupTaskbasedOnTask.execute', nu_dse__User_Context__c = UserInfo.getUserId(), 
                                                                             nu_dse__Error_Causing_Record_Id__c = groupTaskList[0].Id, nu_dse__Message__c = '');
                    for(Database.Error err : sr.getErrors()) {
                    
                        errorLog.nu_dse__Message__c += err.getMessage(); 
                    }
                    errorLogList.add(errorLog);
                } 
                i++;
            }
            if (errorLogList.isEmpty() == False) {
                
                insert errorLogList;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) { 
        
        
    } 
     
}