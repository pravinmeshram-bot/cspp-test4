public class BatchCreateChildTaskForGroupTask implements Database.Batchable<sObject> {  

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, nu_dse__Related_To__c FROM nu_dse__Group_Task__c';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Group_Task__c> groupTaskList) {
        
        Map<Id, nu_dse__Group_Task__c> groupTaskMap = new Map<Id, nu_dse__Group_Task__c>(groupTaskList);
        Set<Id> groupTaskWithTaskIdSet = new Set<Id>();
        Set<Id> groupTaskWithoutTaskIdSet = new Set<Id>(groupTaskMap.keySet());
        
        for (Task taskInstance : [SELECT Id, nu_dse__Group_Task__c FROM Task WHERE nu_dse__Group_Task__c IN :groupTaskList]) {
                
            groupTaskWithTaskIdSet.add(taskInstance.nu_dse__Group_Task__c);
        }
        
        groupTaskWithoutTaskIdSet.removeAll(groupTaskWithTaskIdSet);
        
        Map<Id, Id> groupTaskIdAndItsRelatedToMap = new Map<Id, Id>();
        List<nu_dse__Group_Task__c> groupTaskRelatedToRemoved = new List<nu_dse__Group_Task__c> ();
        
        for (Id groupTaskId :groupTaskWithoutTaskIdSet) {
            
            groupTaskIdAndItsRelatedToMap.put(groupTaskId, groupTaskMap.get(groupTaskId).nu_dse__Related_To__c);
            
            nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c();
            groupTaskInstance.Id = groupTaskId;
            groupTaskInstance.nu_dse__Related_To__c = null;
            groupTaskRelatedToRemoved.add(groupTaskInstance);
        }
        
        if (groupTaskRelatedToRemoved.isEmpty() == False) {
            
            update groupTaskRelatedToRemoved;
            
            List<nu_dse__Group_Task__c> groupTaskRelatedToAdded = new List<nu_dse__Group_Task__c> ();
            
            for (Id groupTaskId :groupTaskWithoutTaskIdSet) {
                
                nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c();
                groupTaskInstance.Id = groupTaskId;
                groupTaskInstance.nu_dse__Related_To__c = groupTaskIdAndItsRelatedToMap.get(groupTaskId);
                groupTaskRelatedToAdded.add(groupTaskInstance);
            }
            
            update groupTaskRelatedToAdded;
        }
    }
    
    public void finish(Database.BatchableContext BC) { 
        
        
    } 
     
}