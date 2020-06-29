public class Batch_PauseAccountReviewFlows implements Database.Batchable<sObject> {
        
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, Attorney__c, NDS_CREATED_DATE__c, CreatedDate, nu_dse__Program_Length__c FROM nu_dse__Program__c ' + 
                       'WHERE RecordType.DeveloperName != \'DataTemp\' AND LastModifiedBy.Attorney_Admin__c = False AND Pause_Account_Review__c = True AND Pause_AR_Tasks_Executed__c = False'; // testing Ids  AND Id IN (\'a0Lm0000003Aj8y\')--  AND Id IN (\'a0Lm0000003Ajq9\',\'a0Lm0000003Ai7X\', \'a0Lm0000003Aj8j\',\'a0Lm0000003Aj8y\',\'a0Lm0000003AjlE\')
                 
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programScopeList) {
        
        List<Task> taskList = new List<Task>();
        
        Map<Id, Set<String>> programIdWithUniqueIdSetMap = new Map<Id, Set<String>>();
        List<nu_dse__Program__c> programToUpdate = new List<nu_dse__Program__c>();
        
        Map<String, Id> taskCommTempIds = new Map<String, Id> ();
        for (Task_Communication_Template__mdt CommTempCMDT : [SELECT Id, Label, DeveloperName, Communication_Template_Id__c FROM Task_Communication_Template__mdt]) {
        
            taskCommTempIds.put(CommTempCMDT.Label, CommTempCMDT.Communication_Template_Id__c);
        }
        Set<Id> programIdSet = new Set<Id>();
        
        for (nu_dse__Program__c program : programScopeList) {
        
            programIdSet.add(program.Id);
        }
        if (programIdSet.isEmpty() == False) {
            
            for (Task taskInstance : [SELECT Id, Unique_Identifier__c FROM TASK WHERE Unique_Identifier__c != NULL AND Status = 'Completed' AND WhatId IN :programIdSet]) {
                
                if (programIdWithUniqueIdSetMap.ContainsKey(taskInstance.WhatId) == False) {
                
                    programIdWithUniqueIdSetMap.put(taskInstance.WhatId, new Set<String>());
                }
                programIdWithUniqueIdSetMap.get(taskInstance.WhatId).add(taskInstance.Unique_Identifier__c );
            }
        }
        for (nu_dse__Program__c program : programScopeList) {
            
            system.debug('program ---->'+program);
            taskList.addAll(FlowLogicsForBatchClass.upsertARFlow(program, taskCommTempIds, programIdWithUniqueIdSetMap ));
            
            program.Pause_AR_Tasks_Executed__c = True;
            programToUpdate.add(program);
            system.debug('programToUpdate---->'+programToUpdate);
            
            /*if (program.nu_dse__Program_Length__c > 12) {
                
                taskList.addAll(FlowLogicsForBatchClass.upsertYear2ARFlow(program, taskCommTempIds, programIdWithUniqueIdSetMap ));
            }
            
            if (program.nu_dse__Program_Length__c > 24) {
                
                taskList.addAll(FlowLogicsForBatchClass.upsertYear3ARFlow(program, taskCommTempIds, programIdWithUniqueIdSetMap ));
            }
            
            if (program.nu_dse__Program_Length__c > 36) {
                
                taskList.addAll(FlowLogicsForBatchClass.upsertYear4ARFlow(program, taskCommTempIds, programIdWithUniqueIdSetMap ));
            }
            
            if (program.nu_dse__Program_Length__c > 48) {
                
                taskList.addAll(FlowLogicsForBatchClass.upsertYear5ARFlow(program, taskCommTempIds, programIdWithUniqueIdSetMap ));
            }*/
        }
        
        System.debug('taskList-->'+taskList);
         
        if (taskList.isEmpty() == False) {
            
            upsert taskList Unique_Identifier__c;
        }
        
        if (programToUpdate.isEmpty() == False) {
            
            update programToUpdate;
        }        
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}