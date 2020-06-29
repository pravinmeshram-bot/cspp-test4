public class SFSPortal_TaskHandler {
    
    public static void sendNotification(List<Task> newTask, Map<Id, Task> oldTaskMap) {
        
        Map<Id, List<Id>> programIdWithTaskListMap = new Map<Id, List<Id>>();
        Map<Id, String> taskIdWithOneSignalIdMap= new Map<Id, String>();
        
        for (Task taskInstance : newtask) {
            if(taskInstance.SOP__c == null)
            {
                String sObjectName = SFSPortal_Utility.getsObjectName(taskInstance.whatId);
                
                if ((oldTaskMap == null || ( oldTaskMap.isEmpty() == False && oldTaskMap.ContainsKey(taskInstance.Id) 
                                            && (taskInstance.Clients_task__c != oldTaskMap.get(taskInstance.Id).Clients_task__c  
                                                || taskInstance.whatId != oldTaskMap.get(taskInstance.Id).WhatId 
                                                || taskInstance.Status != oldTaskMap.get(taskInstance.Id).Status  ||
                                                taskInstance.Call_Type__c != oldTaskMap.get(taskInstance.Id).Call_Type__c ))) 
                                                && taskInstance.Clients_task__c == true && sObjectName == 'nu_dse__Program__c' && 
                                                taskInstance.Status == 'Not Started' && taskInstance.Call_Type__c == 'NSF') {
                    
                    if (programIdWithTaskListMap.ContainsKey(taskInstance.whatId) == False) {
                        programIdWithTaskListMap.put(taskInstance.whatId, new List<Id>()); 
                    }
                    programIdWithTaskListMap.get(taskInstance.whatId).add(taskInstance.Id);
                }
            } 
        }
        if (programIdWithTaskListMap.isEmpty() == False) {
            
            for (nu_dse__Program__c programInstance : [SELECT Id, nu_dse__Program_Status__c, SFSPortal_OneSignal_App_Id__c 
                                                       FROM nu_dse__Program__c 
                                                       WHERE Id IN :programIdWithTaskListMap.Keyset() AND Client_Portal_User_Id__c != null
                                                       AND SFSPortal_OneSignal_App_Id__c != null
                                                       AND nu_dse__Program_Status__c != 'Active Client' ]) {
                
                if (programIdWithTaskListMap.containsKey(programInstance.Id)) {
                    
                    for (Id taskId : programIdWithTaskListMap.get(programInstance.Id)) {
                        
                        taskIdWithOneSignalIdMap.put(taskId, programInstance.SFSPortal_OneSignal_App_Id__c );
                    }
                }
            }    
        }
        if (taskIdWithOneSignalIdMap != null &&  taskIdWithOneSignalIdMap.isempty() == False) {
            
            createNotification(taskIdWithOneSignalIdMap);
        }
    }
    
    @Future (callout=true) 
    public static void createNotification(Map<Id, String> sObjectIdMap) {
        
        set<Id> taskIdSet = new set<Id>();
        
        if (sObjectIdMap.isEmpty() == False) {
            
            for (Id sObjectId : sObjectIdMap.KeySet()) {
                
                String sObjectName = SFSPortal_Utility.getsObjectName(sObjectId);
                
                if (sObjectIdMap.ContainsKey(sObjectId) && sObjectIdMap.get(sObjectId) != null) {
                    
                    if (sObjectName == 'Task') {
                        
                        taskIdSet.add(sObjectId);
                    } else if (sObjectName == 'nu_dse__Offer__c') {
                        
                        SFSPortal_PushNotificationController.pushNotification(sObjectIdMap.get(sObjectId), System.Label.SFSPortal_OfferNotification, 'Urgent','');
                    }
                }
            }
            if (taskIdSet.isEmpty() == False) {
            
                Set<Id> nsfPaymentIdSet = new Set<Id>();
                Map<Id, Task> paymentAndTaskMap = new Map<Id, Task>();
                
                for (Task nsfTaskInstance : [SELECT Id, NSF_payment_18_Digit__c FROM Task WHERE Id = :taskIdSet]) {
                    
                    if(nsfTaskInstance.NSF_payment_18_Digit__c != null) {
                                    
                        nsfPaymentIdSet.add(nsfTaskInstance.NSF_payment_18_Digit__c);
                        paymentAndTaskMap.put(nsfTaskInstance.NSF_payment_18_Digit__c, nsfTaskInstance);
                    }
                }
                
                if(nsfPaymentIdSet.isEmpty() == FALSE) {
                                
                    for(nu_dse__Payment__c payment : [SELECT Id, nu_dse__Advance_Payment__c FROM nu_dse__Payment__c 
                                                      WHERE nu_dse__Advance_Payment__c IN :nsfPaymentIdSet
                                                      AND nu_dse__Advance_Payment__r.nu_dse__Is_Makeup_Payment_Created__c = TRUE]) {
                        
                        if(paymentAndTaskMap.containsKey(payment.nu_dse__Advance_Payment__c) == TRUE) {
                        
                            paymentAndTaskMap.remove(payment.nu_dse__Advance_Payment__c);
                        }
                    }
                }
                
                system.debug('paymentAndTaskMap----->'+paymentAndTaskMap);
                
                if (paymentAndTaskMap.isEmpty() == False) {
                    
                    for (Id sObjectId : paymentAndTaskMap.KeySet()) {
                        
                        if (paymentAndTaskMap.ContainsKey(sObjectId) &&  paymentAndTaskMap.get(sObjectId).Id != null &&
                                 sObjectIdMap.ContainsKey(paymentAndTaskMap.get(sObjectId).Id) 
                                 && sObjectIdMap.get(paymentAndTaskMap.get(sObjectId).Id) != null) {
                            
                            system.debug('sObjectId----->'+sObjectIdMap.get(paymentAndTaskMap.get(sObjectId).Id));
                            SFSPortal_PushNotificationController.pushNotification(sObjectIdMap.get(paymentAndTaskMap.get(sObjectId).Id), System.Label.SFSPortal_TaskNotification, 'Urgent', '');
                        }
                    }
                }
            }
        }
    }
}