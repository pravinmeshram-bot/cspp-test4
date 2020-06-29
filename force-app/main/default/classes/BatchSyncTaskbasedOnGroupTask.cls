public class BatchSyncTaskbasedOnGroupTask implements Database.Batchable<sObject> { 
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c = \'Completed\'';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Group_Task__c> groupTaskList) {
        
        List<Task> taskList = [SELECT Id, Status, nu_dse__Group_Task__c FROM Task WHERE nu_dse__Group_Task__c IN :groupTaskList AND Status <> 'Completed'];
        
        if (taskList.isEmpty() == False) {

            for (Task taskInstance : taskList) {
                
                taskInstance.Status = 'Completed';
            }
            
            try {
                
                update taskList;
                
            } catch(Exception e) {
              
                 nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'BatchSyncTaskbasedOnGroupTask_Execute', nu_dse__User_Context__c = UserInfo.getUserId(),nu_dse__Message__c = e.getMessage());
                 insert errorLog;
                 
            } 
        }
    }
    
    public void finish(Database.BatchableContext BC) { 
        
        
    } 
     
}