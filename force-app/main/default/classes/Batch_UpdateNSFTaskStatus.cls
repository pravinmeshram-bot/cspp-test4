global class Batch_UpdateNSFTaskStatus implements Database.Batchable<sObject>, Database.stateful {
   
    public Set<Id> WhatIdSet = new Set<Id>();
    public Batch_UpdateNSFTaskStatus(Set<Id> WhatId) {
        
        WhatIdSet = new Set<Id>(WhatId);
    }
    
    public Batch_UpdateNSFTaskStatus() {
    
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
                
        String query = 'SELECT Id, NSF_Payment__c FROM Task WHERE Call_Type__c = \'NSF\' AND Status = \'Not Started\' AND NSF_payment__c != null ';
        if (WhatIdSet.isEmpty() == False) {
            
            query += ' AND WhatId IN :WhatIdSet';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Task> scope) {
        
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        Map<Id, Task> taskToUpdateMap = new Map<Id, Task>();
        Map<Id, List<Task>> nSFPaymentIdWithTaskMap = new Map<Id, List<Task>>();
        try {
            
            for (Task taskInstance : scope) {
                
                if (taskInstance.NSF_Payment__c.length() < 18) {
                
                    taskInstance.NSF_Payment__c = Id.ValueOf(taskInstance.NSF_Payment__c);
                    taskToUpdateMap.put(taskInstance.Id, taskInstance);
                }
                
                if (nSFPaymentIdWithTaskMap.ContainsKey(taskInstance.NSF_Payment__c) == False) {
                    
                    nSFPaymentIdWithTaskMap.put(taskInstance.NSF_Payment__c, new List<Task>());
                }
                
                nSFPaymentIdWithTaskMap.get(taskInstance.NSF_Payment__c).add(taskInstance);
            }
                        
            if (nSFPaymentIdWithTaskMap.isEmpty() == False) {
                
                for (nu_dse__Payment__c payment: [SELECT Id, Name FROM nu_dse__Payment__c 
                    WHERE Id IN :nSFPaymentIdWithTaskMap.Keyset() 
                    AND RecordType.DeveloperName = 'Draft' AND nu_dse__Dont_Consider__c = True AND nu_dse__Is_Makeup_Payment_Created__c = True]
                ) {
                                                 
                    if (nSFPaymentIdWithTaskMap.ContainsKey(payment.Id)) {
                        
                        for (Task taskInstance : nSFPaymentIdWithTaskMap.get(payment.Id)) {
                            
                            Task taskToUpdate = taskInstance;
                            taskToUpdate.Status = 'Completed';
                            taskToUpdateMap.put(taskToUpdate.Id, taskToUpdate);
                        } 
                    }                                
                }
            }
            
            if (taskToUpdateMap.isEmpty() == False) {
                
                list<Database.SaveResult> results = Database.update(taskToUpdateMap.Values(), false);
                
                for (Database.SaveResult sr : results) {
                
                    if (!sr.isSuccess()) {
                    
                        String errMsg = '';
                        for (Database.Error err : sr.getErrors()) { errMsg += err.getMessage() + '; '; }
                        errorLogList.add(new nu_dse__Error_Log__c (nu_dse__Class_Method__c = 'Batch_UpdateNSFTaskStatus.Execute', nu_dse__Message__c = errMsg, nu_dse__User_Context__c = UserInfo.getName()));
                    }
                }
            }
        } catch(Exception e) {
        
            errorLogList.add(new nu_dse__Error_Log__c (nu_dse__Class_Method__c = 'Batch_UpdateNSFTaskStatus.Execute', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),nu_dse__User_Context__c = UserInfo.getName()));
        }
        if (errorLogList.isEmpty() == False) {
            
            insert errorLogList;
        }
        system.debug('errorLogList--->'+errorLogList);
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
}