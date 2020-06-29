public class TaskHandler_StopTaskCreation {
    
    static List<StopTaskCreationInDisposition__mdt> stopTaskCreationInDispositionList = new List<StopTaskCreationInDisposition__mdt>();
    static Map<Id, set<String>> tasKWhatIdWithSubjectSet = new Map<Id, set<String>>();
    static Set<Id> processedOfferIdSet = new Set<Id>();
    
    public static void stopTaskCreation(List<Task> newList) {
        
        List<Task> taskToDeleteList = new List<Task>();
        Map<String, String> taskSubjectWithStatusMap = new Map<String, String>();
        
        if (newList.isEmpty() == False) {
            
            //S20-228 optimization, avoid quering metadata multiple times
            if (stopTaskCreationInDispositionList.isEmpty() == True) {
                
                stopTaskCreationInDispositionList = [SELECT Id, Label, Task_Status_to_Delete__c FROM StopTaskCreationInDisposition__mdt WHERE Active__c = True];
            }
            System.debug('stopTaskCreationInDispositionList'+stopTaskCreationInDispositionList);
            for (StopTaskCreationInDisposition__mdt CommTempCMDT :stopTaskCreationInDispositionList) {
            
                if (String.isNotBlank(CommTempCMDT.Task_Status_to_Delete__c)) {
                    
                    taskSubjectWithStatusMap.put(CommTempCMDT.Label, CommTempCMDT.Task_Status_to_Delete__c);
                }
            }
            //System.debug('taskSubjectWithStatusMap--->' + taskSubjectWithStatusMap);
            
            if (taskSubjectWithStatusMap.isEmpty() == False) {
                
                String program_prefix = Schema.SObjectType.nu_dse__Program__c.getKeyPrefix();
                
                for (Task taskInstance : newList) {
                    if(taskInstance.SOP__c == null)
                    {
                        if (String.isNotBlank(taskInstance.WhatId) && ((String)taskInstance.WhatId).startsWith(program_prefix) 
                            && String.isNotBlank(taskInstance.Subject) && taskSubjectWithStatusMap.containsKey(taskInstance.Subject)
                            && taskSubjectWithStatusMap.get(taskInstance.Subject) != NULL) {
                                
                                if ((taskSubjectWithStatusMap.get(taskInstance.Subject)).equalsIgnoreCase(taskInstance.Status)) {
                                    
                                    taskToDeleteList.add(new Task(Id = taskInstance.Id));
                                }
                            }
                    }
                }
            }
            System.debug('taskToDeleteList--->'+taskToDeleteList);
            
            if (taskToDeleteList.isEmpty() == False) {
                
                delete taskToDeleteList;
            }
        }       
    }
    
    public static void stopDuplicateTaskCreation(List<Task> newList) {
        
        String offer_prefix = Schema.SObjectType.nu_dse__Offer__c.getKeyPrefix();
        List<Task> taskList = new List<Task>();
        Map<Id, Id> taskIdWithOfferIdMap = new Map<Id, Id>();
        List<Task> taskToDeleteList = new List<Task>();
        Set<Id> offerIdSet = new Set<Id>();
        
        for (Task taskInstance: newList) {
            if(taskInstance.SOP__c == null)
            {
                if (String.isNotBlank(taskInstance.WhatId) && ((String)taskInstance.WhatId).startsWith(offer_prefix)) {
                    
                    taskIdWithOfferIdMap.put(taskInstance.Id, taskInstance.WhatId);
                    taskList.add(taskInstance);
                    
                    //S20-228 optimization, avoid quering tasks under same
                    if (processedOfferIdSet.contains(taskInstance.WhatId) == False) {
                        
                        offerIdSet.add(taskInstance.WhatId);
                    }
                    
                }
            }
            
        }
        
        //system.debug('taskList---->'+taskList);
        //system.debug('taskIdWithOfferIdMap---->'+taskIdWithOfferIdMap);
        if (taskIdWithOfferIdMap .isEmpty() == False) {
            
            if (offerIdSet.isEmpty() == False) {
                
                for (Task taskInstance : [SELECT Id, WhatId, Subject FROM Task WHERE WhatId IN :offerIdSet]) {
                    
                    if (taskIdWithOfferIdMap.ContainsKey(taskInstance.Id) == False) {
                    
                        if (tasKWhatIdWithSubjectSet.ContainsKey(taskInstance.WhatId) == False) {
                        
                            tasKWhatIdWithSubjectSet.put(taskInstance.WhatId, new set<String>());
                            processedOfferIdSet.add(taskInstance.WhatId);
                        }
                        tasKWhatIdWithSubjectSet.get(taskInstance.WhatId).add(taskInstance.Subject);
                    }
                }
            }
        }
        //system.debug('tasKWhatIdWithSubjectSet---->'+tasKWhatIdWithSubjectSet);
        if (taskList.isEmpty() == False) {
        
            if (tasKWhatIdWithSubjectSet.isEmpty() == False) {
                
                for (Task taskInstance : taskList) {
                    
                    if (tasKWhatIdWithSubjectSet.get(taskInstance.WhatId) != null 
                            && tasKWhatIdWithSubjectSet.get(taskInstance.WhatId).Contains(taskInstance.Subject) == True) {
                        
                        Task taskInst = new Task(Id = taskInstance.Id );
                        taskToDeleteList.add(taskInst);
                    
                    } else {
                        
                        if (tasKWhatIdWithSubjectSet.ContainsKey(taskInstance.WhatId) == False) {
                        
                            tasKWhatIdWithSubjectSet.put(taskInstance.WhatId, new set<String>());
                            processedOfferIdSet.add(taskInstance.WhatId);
                        }
                        tasKWhatIdWithSubjectSet.get(taskInstance.WhatId).add(taskInstance.Subject);
                    }
                }
            }
            
            system.debug('taskToDeleteList---->'+taskToDeleteList);
            
            if (taskToDeleteList.isEmpty() == False) {
                
                delete taskToDeleteList;
            }
        }
    }
}