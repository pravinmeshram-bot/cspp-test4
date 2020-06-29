public class OfferHandler {
    
    Static Date todayDate;
    Static Date firstWorkingDay;
    Static Date secondWorkingDay;
    Static Date thirdWorkingDay;
    Static Date fourthWorkingDay;
    Static Date fifthWorkingDay;
    
    Static Date sixthWorkingDay;
    Static Date seventhWorkingDay;
    Static Date eigthWorkingDay;
    Static Date ninethWorkingDay;
    Static Date tenthWorkingDay;
    
    Static Date workingDay11;
    Static Date workingDay12;
    Static Date workingDay13;
    Static Date workingDay14;
    Static Date workingDay15;
    
    Static Boolean workingDaysCalculated = False;
    
    public static void ToCancelTask(List<nu_dse__Offer__c> newList, Map<Id, nu_dse__Offer__c> oldMap) {
        
        Map<Id, Task> tasksToUpdate = new Map<Id, Task>();
        Set<Id> offerIdSet = new Set<Id>();
        Set<Id> authorisationReceivedTaskId = new Set<Id>();
        Set<Id> reactivateOfferIdSet = new Set<Id>();
        Set<Id> offerToletterUploadIds = new Set<Id>();
        //Added 15 day offer authorization tasks..
        Set<String> authorisationReceivedTaskSubjectSet = new Set<String>{'Pending Client Approval (Voice)', 'Pending Client Approval (SMS)', 'Pending Client Approval (Email)',
                                                                'URGENT: Action Required', 'Respond Now', 'ALERT: You Have a Settlement Offer', 'NEEDS Approval - Pending Settlement',
                                                                'ACTION REQUIRED', 'Your Offer is Expiring', 'We\'ve been Trying to Reach You',
                                                                'Don\'t Let your Offer Expire', 'EXPIRING SOON', 'URGENT:Your settlement offer expires soon', 'HURRY, Before It\'s Too Late',
                                                                'URGENT: Your Approval is Required', 'Don\'t Miss Out!', 'AVOID LOSING MORE MONEY', 
                                                                'LAST CHANCE to Approve Your Settlement', 'Day 1 Auth SMS', 'Day 2 Auth SMS', 'Day 3 Auth SMS',
                                                                'Day 4 Auth SMS', 'Day 5 Auth SMS', 'Day 6 Auth SMS', 'Day 7 Auth SMS', 'Day 8 Auth SMS',
                                                                'Day 9 Auth SMS', 'Day 10 Auth SMS', 'Day 11 Auth SMS', 'Day 12 Auth SMS', 'Day 13 Auth SMS',
                                                                'Day 14 Auth SMS', 'Day 15 Auth SMS', 'Day 1 Auth Voice', 'Day 2 Auth Voice', 'Day 3 Auth Voice',
                                                                'Day 4 Auth Voice', 'Day 5 Auth Voice', 'Day 6 Auth Voice', 'Day 7 Auth Voice', 'Day 8 Auth Voice',
                                                                'Day 9 Auth Voice', 'Day 10 Auth Voice', 'Day 11 Auth Voice', 'Day 12 Auth Voice', 'Day 13 Auth Voice',
                                                                'Day 14 Auth Voice', 'Day 15 Auth Voice'};
        
        for (nu_dse__Offer__c offerInstance : newList) { 
            
            /*If Authorization Received Flag = 'True' we should cancel offer communication templates*/
            if (offerInstance.Authorization_Received__c == True && oldMap.get(offerInstance.Id).Authorization_Received__c == False) {
                
                authorisationReceivedTaskId.add(offerInstance.Id);
            }
            // ***S20-457*** Added In-House Attorney Denied for canceling Tasks for Royal Portfolio.
            if( offerInstance.Latest_Offer__c == false || (offerInstance.nu_dse__Status__c != oldMap.get(offerInstance.Id).nu_dse__Status__c && 
                (offerInstance.nu_dse__Status__c == 'Canceled' || offerInstance.nu_dse__Status__c == 'Offer Canceled' || 
                offerInstance.nu_dse__Status__c == 'Client Declined' || offerInstance.nu_dse__Status__c == 'Management Denied' || 
                offerInstance.nu_dse__Status__c == 'Settlement Auth Denied' ||offerInstance.nu_dse__Status__c == 'Negotiations Associate Denied' ||
                offerInstance.nu_dse__Status__c == 'In-House Attorney Denied'))) {
                
                offerIdSet.add(offerInstance.Id);
            }
            
            //S20-457** Starts To reactivate tasks under offer.
            if(offerInstance.nu_dse__Status__c != oldMap.get(offerInstance.Id).nu_dse__Status__c 
                && ((offerInstance.nu_dse__Status__c == 'Management Review' && offerInstance.Portfolio_Name__c == 'Timberline')
                    || (offerInstance.nu_dse__Status__c == 'In-House Attorney Review' && offerInstance.Portfolio_Name__c == 'Royal'))) {
           
                if(offerInstance.Letter_Uploaded__c == false) {
                    offerToletterUploadIds.add(offerInstance.Id);
                }
                if(offerInstance.Authorization_Received__c == false) {
                    reactivateOfferIdSet.add(offerInstance.Id);
                }
            }
            //S20-457** Ends To reactivate tasks under offer.
        }
        // Iterate over the related tasks
        if (offerIdSet.isEmpty() == False || authorisationReceivedTaskId.isEmpty() == False 
            || reactivateOfferIdSet.isEmpty() == false || offerToletterUploadIds.isEmpty() == false) {
            
            if (workingDaysCalculated == False
                && reactivateOfferIdSet.isEmpty() == false) {
                    
                calculateWorkingDays();
                workingDaysCalculated = True;
            }
            
            Map<Integer, Date> workingDaysMap = new Map<Integer, Date> {1 => firstWorkingDay, 2 => secondWorkingDay, 3 => thirdWorkingDay,
                    4 => fourthWorkingDay, 5=> fifthWorkingDay, 6=> sixthWorkingDay, 7 => seventhWorkingDay, 8 => eigthWorkingDay,
                    9 => ninethWorkingDay, 10 => tenthWorkingDay, 11 => workingDay11, 12 => workingDay12, 13 => workingDay13,
                    14 => workingDay14, 15 =>workingDay15};
                    
            Map<Id, Map<String, Integer>> offerIdTaskCount = new Map<Id, Map<String, Integer>>();
            Set<String> taskSubjectSet = new Set<String> {'Pending Client Approval (Voice)', 'Pending Client Approval (SMS)', 'Pending Client Approval (Email)'};
                    
            for(Task tsk : [SELECT Id, Subject, Status, whatId, ActivityDate FROM Task 
                            WHERE ((WhatId =:authorisationReceivedTaskId AND Subject IN :authorisationReceivedTaskSubjectSet) 
                                OR WhatId = :offerIdSet OR WhatId IN :reactivateOfferIdSet 
                                OR (WhatId IN :offerToletterUploadIds AND Subject = 'Obtain Creditor Auth')) AND Status != 'Completed' 
                            ORDER BY WhatId, Activitydate]) {      
            
                // Close Task
                if (tsk.Status != 'Canceled'
                    && ((authorisationReceivedTaskId.contains(tsk.WhatId) && authorisationReceivedTaskSubjectSet.contains(tsk.Subject))
                        || offerIdSet.contains(tsk.WhatId))) {
                
                    tsk.Status = 'Canceled';
                    
                    if ((authorisationReceivedTaskSubjectSet.contains(tsk.Subject) == True || tsk.Subject == 'Obtain Creditor Auth' || tsk.Subject == 'Obtain Creditor Auth')  
                            && taskSubjectSet.contains(tsk.Subject) == False) {
                        
                        tsk.ActivityDate = null;
                    }
                    
                    tasksToUpdate.put(tsk.Id, tsk);
                
                //S20-457** Starts To reactivate tasks under offer.
                } else if(tsk.Status == 'Canceled'
                        && reactivateOfferIdSet.contains(tsk.whatId)) {
                    
                    if((authorisationReceivedTaskSubjectSet.contains(tsk.Subject) || tsk.Subject == 'Obtain Client Auth')
                        && taskSubjectSet.contains(tsk.Subject) == false) {
                        
                        tsk.activityDate = System.today();
                        
                        if(tsk.subject.contains('Auth SMS')) {
                        
                            if(offerIdTaskCount.containskey(tsk.whatId) == true &&
                                offerIdTaskCount.get(tsk.whatId).containskey('SMS') == true) {
                                
                                offerIdTaskCount.get(tsk.whatId).put('SMS', offerIdTaskCount.get(tsk.whatId).get('SMS')+1);
                            } else {
                                offerIdTaskCount.put(tsk.whatId, new Map<String, Integer>{'SMS'=> 1, 'Email' => 0, 'Voice' => 0});
                            }
                            tsk.activityDate = workingDaysMap.get(offerIdTaskCount.get(tsk.whatId).get('SMS'));
                            
                        } else if(tsk.subject.contains('Auth Voice')) {
                        
                            if(offerIdTaskCount.containskey(tsk.whatId) == true &&
                                offerIdTaskCount.get(tsk.whatId).containskey('Voice') == true) {
                                
                                offerIdTaskCount.get(tsk.whatId).put('Voice', offerIdTaskCount.get(tsk.whatId).get('Voice')+1);
                            } else {
                                offerIdTaskCount.put(tsk.whatId, new Map<String, Integer>{'SMS'=> 0, 'Email' => 0, 'Voice' => 1});
                            }
                            tsk.activityDate = workingDaysMap.get(offerIdTaskCount.get(tsk.whatId).get('Voice'));
                            
                        } else if((tsk.Subject == 'Obtain Client Auth') == false){
                            
                             if(offerIdTaskCount.containskey(tsk.whatId) == true &&
                                offerIdTaskCount.get(tsk.whatId).containskey('Email') == true) {
                                
                                offerIdTaskCount.get(tsk.whatId).put('Email', offerIdTaskCount.get(tsk.whatId).get('Email')+1);
                            } else {
                                offerIdTaskCount.put(tsk.whatId, new Map<String, Integer>{'SMS'=> 0, 'Email' => 1, 'Voice' => 0});
                            }
                            
                            tsk.activityDate = system.today().addDays(offerIdTaskCount.get(tsk.whatId).get('Email'));
                        }
                        
                        tsk.Status = 'Not Started';
                        tasksToUpdate.put(tsk.Id, tsk);
                    } 
                    //To activate Creditor Auth tasks along with pending client Approval Tasks...
                } else if(tsk.Status == 'Canceled' && offerToletterUploadIds.contains(tsk.whatId) 
                            && tsk.Subject == 'Obtain Creditor Auth'){
                        
                    tsk.Status = 'Not Started';
                    tsk.activityDate = System.today();
                    tasksToUpdate.put(tsk.Id, tsk);
                }
                //S20-457** Ends To reactivate tasks under offer.
            }
        }
        // Perform DML on a collection
        if (tasksToUpdate.isEmpty() == False) {
            
            update tasksToUpdate.Values();
        }
    }
    
    public static void ToLockOfferRecord(List<nu_dse__Offer__c> newList, Map<Id, nu_dse__Offer__c> oldMap) {
        
        Map<String, Schema.RecordTypeInfo> paymentRecordTypeMap = nu_dse__Offer__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id,Id> offerIdWithTradelineIdSet = new Map<Id,Id>();
        
        if (oldMap.isEmpty() == False && newList.isEmpty() == False) {
            
            for (nu_dse__Offer__c offer : newList) {
                
                if (offer.Is_submitted_for_Approval_process__c == True && oldMap != null
                    && oldMap.get(offer.Id).Is_submitted_for_Approval_process__c != offer.Is_submitted_for_Approval_process__c) {
                    
                    if (paymentRecordTypeMap.containsKey('Locked Offer')) {
                    
                       offer.recordTypeId = paymentRecordTypeMap.get('Locked Offer').getRecordTypeId();
                    }
                } else if ((offer.nu_dse__Status__c == 'Canceled' || offer.nu_dse__Status__c == 'Accepted') 
                           && (oldMap != null && oldMap.get(offer.Id).nu_dse__Status__c != offer.nu_dse__Status__c)) {
                
                    if (paymentRecordTypeMap.containsKey('Offer Accepted/Cancelled')) {
                    
                       offer.recordTypeId = paymentRecordTypeMap.get('Offer Accepted/Cancelled').getRecordTypeId();
                    }
                    if (offer.nu_dse__Status__c == 'Accepted' ) {
                        
                        offerIdWithTradelineIdSet.put(offer.Id, offer.nu_dse__TradeLine__c);
                    }
                } else if (offer.Is_submitted_for_Approval_process__c == False
                    && oldMap.get(offer.Id).Is_submitted_for_Approval_process__c != offer.Is_submitted_for_Approval_process__c 
                        || ((offer.nu_dse__Status__c != 'Canceled' && offer.nu_dse__Status__c != 'Accepted') 
                            && oldMap.get(offer.Id).nu_dse__Status__c != offer.nu_dse__Status__c)) {
                    if (paymentRecordTypeMap.containsKey('Default')) {
                    
                       offer.recordTypeId = paymentRecordTypeMap.get('Default').getRecordTypeId();
                    }
                }
            }
            
            if (offerIdWithTradelineIdSet.isEmpty() == False) {
                
                List<nu_dse__Offer__c> updateOfferList = new List<nu_dse__Offer__c>();
                
                for (nu_dse__Offer__c offer : [SELECT Id, nu_dse__status__c  FROM nu_dse__Offer__c 
                                               WHERE nu_dse__TradeLine__c IN :offerIdWithTradelineIdSet.Values() AND 
                                               Id NOT IN :offerIdWithTradelineIdSet.keySet() AND Renegotiable__c = True AND 
                                               nu_dse__status__c != 'Canceled']) {
                    
                    nu_dse__Offer__c offerInstance = new nu_dse__Offer__c(Id = offer.Id);
                    offerInstance.nu_dse__status__c = 'Canceled';
                    updateOfferList.add(offerInstance);
                }
                if (updateOfferList.isEmpty() == False) {
                    system.debug('++++++updateOfferList++++'+updateOfferList);
                    update updateOfferList;
                }
            }
        }
    }
    
    //S20-94 
    /*public static void validateApprovalRejection(List<nu_dse__Offer__c> newList, Map<Id, nu_dse__Offer__c> oldMap) {
        
        Map<String, Schema.RecordTypeInfo> paymentRecordTypeMap = nu_dse__Offer__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id,Id> offerIdWithTradelineIdSet = new Map<Id,Id>();
        
        if (!oldMap.isEmpty() && !newList.isEmpty()) {
        
           for (nu_dse__Offer__c offer : newList) {
            
                 if( oldMap.get(offer.id).nu_dse__Status__c != offer.nu_dse__Status__c 
                     && oldMap.get(offer.Id).nu_dse__Status__c != 'Canceled' && offer.nu_dse__Status__c != 'Canceled'
                     && oldMap.get(offer.Id).nu_dse__Status__c!='Payments Department Denied' 
                     && (offer.Attorney_Settlement_Approval_Status__c == 'Negotiations Associate Review Rejected' 
                        || offer.Timberline_Settlement_Approval_Status__c == 'Negotiations Associate Review Rejected' 
                         || offer.DNL_Negotiations_Approval_Status__c == 'Negotiations Associate Review Rejected')
                     &&  offer.Rejection_Reason__c == null) {
                     
                     offer.addError('Please provide rejection reason on offer to proceed with NAR rejection.');                
                }                
            }
        }
    }*/
    //S20-94

    
    //S20-19 ***Started***
    public static void ClientAuthFor15Days (List<nu_dse__Offer__c> newList, Map<Id, nu_dse__Offer__c> offerOldMap) {
        
        List<Task> taskCreateList = new List<Task>();
        
        // Mayur - ND-337
        List<nu_dse__Offer__c> offerList_to_process = new List<nu_dse__Offer__c>();
        Map<String, boolean> metadataMap = new Map<String, boolean>();
        
        for(PortfolioAndRetentionEmailMapping__mdt portfolioMetadata : [select id, MasterLabel, Send_Client_Auth__c from PortfolioAndRetentionEmailMapping__mdt  where Send_Client_Auth__c = true]){
            metadataMap.put(portfolioMetadata.MasterLabel.toLowerCase(), portfolioMetadata.Send_Client_Auth__c);
        }
        
        for(nu_dse__Offer__c ofrIns : newList){
            if(ofrIns.Portfolio_Name__c != null && metadataMap.containsKey(ofrIns.Portfolio_Name__c.toLowerCase()) && metadataMap.get(ofrIns.Portfolio_Name__c.toLowerCase()) == true){ 
                offerList_to_process.add(ofrIns);    
            }
        }
        // Mayur
     //   taskCreateList.addAll(createOfferAuthRequestTasks(newList, offerOldMap));
        taskCreateList.addAll(createOfferAuthRequestTasks(offerList_to_process, offerOldMap));  //Mayur
        insert taskCreateList;
    }
    
    public static List<Task> createOfferAuthRequestTasks(List<nu_dse__Offer__c> offerList, Map<Id, nu_dse__Offer__c> offerOldMap) {
        
        List<Task> taskList = new List<Task>();
        Map<String, Id> taskCommTempIds = new Map<String, Id> ();
        Map<String, Id> taskOwnerIdMap = new Map<String, Id> ();
        Set<String> settlementValueSet = new Set<String>{'Settlement', 'Balance in Full'};
        Id taskRecordTypeId;
        
        Set<String> dnlStatusSet = new Set<String>{'Pre-TILA Signed'}; //S20-507: Removed 'Converted' since this status do not guarantee that the client will be approved for the DNL loan.
        
        for (Task_Communication_Template__mdt CommTempCMDT : [SELECT Id, Label, DeveloperName, Communication_Template_Id__c FROM Task_Communication_Template__mdt]) {
              
            taskCommTempIds.put(CommTempCMDT.Label, CommTempCMDT.Communication_Template_Id__c);
            System.debug('taskCommTempIds----> '+ taskCommTempIds);
        }
        
        for (Task_Owner_Id_Mapping__mdt taskOwnerIdInst : [SELECT Id, Label, Owner_Id__c FROM Task_Owner_Id_Mapping__mdt]) {
            
            taskOwnerIdMap.put(taskOwnerIdInst.Label, taskOwnerIdInst.Owner_Id__c);
        }
        
        taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Nudebt Record Type').getRecordTypeId();
        
        for (nu_dse__Offer__c offerInstance :offerList) {
            
            if (dnlStatusSet.contains(offerInstance.DNL_Status__c) == False && offerInstance.Client_Auth_Task_Created__c == False && settlementValueSet.contains(offerInstance.Type_of_Settlement__c) 
                    && offerInstance.Source_of_Payment__c == 'PSA'
                    && (String.IsBlank(offerOldMap.get(offerInstance.Id).Type_of_Settlement__c) && String.IsBlank(offerOldMap.get(offerInstance.Id).Source_of_Payment__c)) ) {
                
                if (workingDaysCalculated == False) {
                    
                    calculateWorkingDays();
                    workingDaysCalculated = True;
                }
                
                //Create Email Tasks
                taskList.addAll(createOfferTasks(offerInstance, 'URGENT: Action Required', todayDate.addDays(1), taskCommTempIds.get('URGENT: Action Required'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Respond Now', todayDate.addDays(2), taskCommTempIds.get('Respond Now'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'ALERT: You Have a Settlement Offer', todayDate.addDays(3), taskCommTempIds.get('ALERT: You Have a Settlement Offer'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'NEEDS Approval - Pending Settlement', todayDate.addDays(4), taskCommTempIds.get('NEEDS Approval - Pending Settlement'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'ACTION REQUIRED', todayDate.addDays(5), taskCommTempIds.get('ACTION REQUIRED'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Your Offer is Expiring', todayDate.addDays(6), taskCommTempIds.get('Your Offer is Expiring'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'We\'ve been Trying to Reach You', todayDate.addDays(7), taskCommTempIds.get('We\'ve been Trying to Reach You'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Don\'t Let your Offer Expire', todayDate.addDays(8), taskCommTempIds.get('Don\'t Let your Offer Expire'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'EXPIRING SOON', todayDate.addDays(9), taskCommTempIds.get('EXPIRING SOON'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'URGENT:Your settlement offer expires soon', todayDate.addDays(10), taskCommTempIds.get('URGENT:Your settlement offer expires soo'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'HURRY, Before It\'s Too Late', todayDate.addDays(11), taskCommTempIds.get('HURRY, Before It\'s Too Late'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'URGENT: Your Approval is Required', todayDate.addDays(12), taskCommTempIds.get('URGENT: Your Approval is Required'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Don\'t Miss Out!', todayDate.addDays(13), taskCommTempIds.get('Don\'t Miss Out!'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'AVOID LOSING MORE MONEY', todayDate.addDays(14), taskCommTempIds.get('AVOID LOSING MORE MONEY'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'LAST CHANCE to Approve Your Settlement', todayDate.addDays(15), taskCommTempIds.get('LAST CHANCE to Approve Your Settlement'),taskRecordTypeId));
                
                //Create SMS Tasks
                taskList.addAll(createOfferTasks(offerInstance, 'Day 1 Auth SMS', firstWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 2 Auth SMS', secondWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 3 Auth SMS', thirdWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 4 Auth SMS', fourthWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 5 Auth SMS', fifthWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                
                taskList.addAll(createOfferTasks(offerInstance, 'Day 6 Auth SMS', sixthWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 7 Auth SMS', seventhWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 8 Auth SMS', eigthWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 9 Auth SMS', ninethWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 10 Auth SMS', tenthWorkingDay, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                
                taskList.addAll(createOfferTasks(offerInstance, 'Day 11 Auth SMS', workingDay11, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 12 Auth SMS', workingDay12, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 13 Auth SMS', workingDay13, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 14 Auth SMS', workingDay14, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 15 Auth SMS', workingDay15, taskCommTempIds.get('Offer Auth SMS 1 to 15'),taskRecordTypeId));
                
                //Create Voice Tasks
                taskList.addAll(createOfferTasks(offerInstance, 'Day 1 Auth Voice', firstWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 2 Auth Voice', secondWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 3 Auth Voice', thirdWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 4 Auth Voice', fourthWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 5 Auth Voice', fifthWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                
                taskList.addAll(createOfferTasks(offerInstance, 'Day 6 Auth Voice', sixthWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 7 Auth Voice', seventhWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 8 Auth Voice', eigthWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 9 Auth Voice', ninethWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 10 Auth Voice', tenthWorkingDay, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                
                taskList.addAll(createOfferTasks(offerInstance, 'Day 11 Auth Voice', workingDay11, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 12 Auth Voice', workingDay12, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 13 Auth Voice', workingDay13, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 14 Auth Voice', workingDay14, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
                taskList.addAll(createOfferTasks(offerInstance, 'Day 15 Auth Voice', workingDay15, taskCommTempIds.get('Offer Auth Voice 1 to 15'),taskRecordTypeId));
            
                offerInstance.Client_Auth_Task_Created__c = True;
            }
        }
        return taskList;
    }
    
    public static List<Task> createOfferTasks (nu_dse__Offer__c offerInstance, String subject, Date activityDate, Id commTempId, Id taskRecordTypeId) {
        
        List<Task> taskList = new List<Task>();
        
        Task taskInstance = new Task();
        taskInstance.WhatId = offerInstance.Id;
        taskInstance.subject = subject;
        taskInstance.activityDate = activityDate;
        
        if (String.isNotBlank(commTempId) == True) {
            
            taskInstance.nu_dse__Communication_Template__c = commTempId;
        }
        
        if (String.isNotBlank(taskRecordTypeId) == True) {
            
            taskInstance.recordTypeId = taskRecordTypeId;
        }
        
        taskList.add(taskInstance);
        
        return taskList;
    }
    
    public static void calculateWorkingDays() {
        
        todayDate = System.today();
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        holidayMap = Holidays.getHolidaysMap();
        
        firstWorkingDay = Holidays.getNextWorkingDay(holidayMap, todayDate.addDays(1));
        secondWorkingDay = Holidays.getNextWorkingDay(holidayMap, firstWorkingDay.addDays(1));
        thirdWorkingDay = Holidays.getNextWorkingDay(holidayMap, secondWorkingDay.addDays(1));
        fourthWorkingDay = Holidays.getNextWorkingDay(holidayMap, thirdWorkingDay.addDays(1));
        fifthWorkingDay = Holidays.getNextWorkingDay(holidayMap, fourthWorkingDay.addDays(1));
        
        sixthWorkingDay = Holidays.getNextWorkingDay(holidayMap, fifthWorkingDay.addDays(1));
        seventhWorkingDay = Holidays.getNextWorkingDay(holidayMap, sixthWorkingDay.addDays(1));
        eigthWorkingDay = Holidays.getNextWorkingDay(holidayMap, seventhWorkingDay.addDays(1));
        ninethWorkingDay = Holidays.getNextWorkingDay(holidayMap, eigthWorkingDay.addDays(1));
        tenthWorkingDay = Holidays.getNextWorkingDay(holidayMap, ninethWorkingDay.addDays(1));
        
        workingDay11 = Holidays.getNextWorkingDay(holidayMap, tenthWorkingDay.addDays(1));
        workingDay12 = Holidays.getNextWorkingDay(holidayMap, workingDay11.addDays(1));
        workingDay13 = Holidays.getNextWorkingDay(holidayMap, workingDay12.addDays(1));
        workingDay14 = Holidays.getNextWorkingDay(holidayMap, workingDay13.addDays(1));
        workingDay15 = Holidays.getNextWorkingDay(holidayMap, workingDay14.addDays(1));
    }
    //S20-19 ***Ended***
    
    //S20-178 ****Starts**** ~ To reject pending approvals for canceled offers 
    public static void ToRejectPendingApprovals(List<nu_dse__Offer__c> offerList, Map<Id, nu_dse__Offer__c> offerOldMap) {

        Set<Id> offerIds = new Set<Id>();
        List<nu_dse__Offer__c> offersToBeUpdated = new List<nu_dse__Offer__c>();
        Set<Id> processInstanceWorkItems = new Set<Id>();
        System.debug('offers--++++--->'+offerList);
        for (nu_dse__Offer__c offer : offerList) {

            if (offer.nu_dse__Program__c != null && offer.nu_dse__TradeLine__c != null && offer.nu_dse__Status__c != NULL && offer.nu_dse__Status__c == 'Canceled'
                && offerOldMap.get(offer.Id).nu_dse__Status__c != offer.nu_dse__Status__c) {

                offerIds.add(offer.Id);
            }
        }
        System.debug('offerIds----->'+offerIds);
        
        if (offerIds.isEmpty() == False) {

            for (ProcessInstanceWorkitem instanceWork : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                                         FROM ProcessInstanceWorkitem  
                                                         WHERE ProcessInstance.TargetObjectId IN :offerIds Order By CreatedDate]) {

                if (offerIds.contains(instanceWork.ProcessInstance.TargetObjectId)) {

                    processInstanceWorkItems.add(instanceWork.Id);
                    
                    offersToBeUpdated.add(new nu_dse__Offer__c(Id = instanceWork.ProcessInstance.TargetObjectId, 
                                                               Rejection_Reason__c = 'Offer moved to Canceled'));
                    
                    offerIds.remove(instanceWork.ProcessInstance.TargetObjectId);
                }
            }
            System.debug('processInstanceWorkItems----->'+processInstanceWorkItems);
            System.debug('offersToBeUpdated----->'+offersToBeUpdated);
            
            if (processInstanceWorkItems.isEmpty() == False) {
            
                if (offersToBeUpdated.isEmpty() == False) {
                    
                    update offersToBeUpdated;
                }

                List<Approval.ProcessWorkitemRequest> workItemRequests = new List<Approval.ProcessWorkitemRequest>();

                for (Id workItems : processInstanceWorkItems) {

                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setAction('Reject');
                    req.setWorkitemId(workItems);
                    workItemRequests.add(req);
                }
                System.debug('workItemRequests--->'+workItemRequests);

                Approval.ProcessResult[] result2 =  Approval.process(workItemRequests);
            }
        }
    }
    //S20-178 *****Ends*****
    
    //S20-93 ****Starts**** ~ Developed on Sept 09, 2019 : Whenever the Offer is 'Accepted', the Current Stage in the Tradeline should be changed to 'Payment Plan Active'
    public static void ToSetTradelineCurrentStage(List<nu_dse__Offer__c> offerList, Map<Id, nu_dse__Offer__c> offerOldMap) {
        
        if (offerList.isEmpty() == False) {
            
            Map<Id, Id> filteredOfferwithTradelineMap = new Map<Id, Id>();
            List<nu_dse__Tradeline__c> updatedTradelineList = new List<nu_dse__Tradeline__c>();
            
            for (nu_dse__Offer__c offer : offerList) {
                
                if (offer.nu_dse__Program__c != NULL && offer.nu_dse__TradeLine__c != NULL && offer.nu_dse__Status__c == 'Accepted' 
                    && offerOldMap.get(offer.Id).nu_dse__Status__c != offer.nu_dse__Status__c) {
                    
                    filteredOfferwithTradelineMap.put(offer.Id, offer.nu_dse__TradeLine__c);                   
                }
            }
            System.debug('filteredOfferwithTradelineMap----->'+filteredOfferwithTradelineMap);
            
            if (filteredOfferwithTradelineMap.isEmpty() == False) {
                
                for (nu_dse__Tradeline__c tradeline : [SELECT Id, nu_dse__Current_Stage__c FROM nu_dse__Tradeline__c 
                                                       WHERE Id IN :filteredOfferwithTradelineMap.values()
                                                       AND nu_dse__Current_Stage__c != 'Payment Plan Active']) {
                    
                    updatedTradelineList.add(new nu_dse__Tradeline__c(Id = tradeline.Id, nu_dse__Current_Stage__c = 'Payment Plan Active'));                                      
                }
                System.debug('updatedTradelineList----->'+updatedTradelineList);
                
                if (updatedTradelineList.isEmpty() == False) {
                    
                    update updatedTradelineList;
                }
            }
        }       
    }
    //S20-93 *****Ends*****
    
    /*ND-279 - Depending on the new payment dates , Need to update the schedule date  
    
    Public Static void UpdateScheduleDate(List<nu_dse__Offer__c> offerList, Map<Id, nu_dse__Offer__c> offerOldMap) 
    {
   
        
         Set<Id> offerID= new Set<Id>();
         
                  for(nu_dse__Offer__c ofr:offerList)
             {
                 if(ofr.Creditor_Due_Date__c!= NULL && ofr.Creditor_Due_Date__c!= offerOldMap.get(ofr.ID).Creditor_Due_Date__c)
                  offerID.add(ofr.id);
          
             }
    Map<Id, List<nu_dse__Payment__c>> PaymentListByOfferID= new Map<Id, List<nu_dse__Payment__c>>();
     
     for(nu_dse__Payment__c payment : [Select id, nu_dse__Offer__c from nu_dse__Payment__c where nu_dse__Offer__c IN : offerID order by createddate asc ])
     
     {
          if(!PaymentListByOfferID.containskey(payment.nu_dse__Offer__c ))
              {
          
          PaymentListByOfferID.put(payment.nu_dse__Offer__c ,new List<nu_dse__Payment__c>{payment});
                          
          
               }
          else {
          
          PaymentListByOfferID.get(payment.nu_dse__Offer__c).add(payment);
               
               }
     
     }
     
     if(!PaymentListByOfferID.isEmpty())
          {
             List<nu_dse__Payment__c> paymenttoupdate =new List<nu_dse__Payment__c>();
          for(nu_dse__Offer__c ofr:offerList)
             { 
             
                 integer offermth = 0;
                 //integer numberofpayment = ofr.nu_dse__Number_of_Payments__c;
                 
               for(nu_dse__Payment__c payment :PaymentListByOfferID.get(ofr.id) )
               
                 {
                   payment.nu_dse__Schedule_Date__c = ofr.Creditor_Due_Date__c.addmonths(offermth);
                   offermth++;
                   paymenttoupdate.add(payment);
                 }
          
                          
              
              }
              
            if(!paymenttoupdate.isEmpty())
               {
                  update paymenttoupdate ;
               
               }  
              
              
          
          }
     
     
    
    } */
    
    
    public static void approveFundingOnLendingApplication(List<nu_dse__Offer__c> offerList, Map<Id, nu_dse__Offer__c> offerOldMap) {
        Set<Id> programIdSet = new Set<Id>();
        for (nu_dse__Offer__c newOffer: offerList) {
            nu_dse__Offer__c oldOffer = offerOldMap.get(newOffer.Id);
            if (newOffer.DNL_Status__c == 'Pre-TILA Signed' && newOffer.Is_Last_Debt__c && !oldOffer.Is_Last_Debt__c) {
                programIdSet.add(newOffer.nu_dse__Program__c);
            }
        }
        system.debug('+++++++++programIdSet++++'+programIdSet);
        if (!programIdSet.isEmpty()) {
            Set<Id> lendingAppIdSet = new Set<Id>();
            for (nu_dse__Program__c program: [Select Id, DNL_Lending_Application_ID__c from nu_dse__Program__c where Id IN :programIdSet]) {
                if (!String.isBlank(program.DNL_Lending_Application_ID__c)) {
                    lendingAppIdSet.add(program.DNL_Lending_Application_ID__c);
                }
            }
            system.debug('+++++++++lendingAppIdSet++++'+lendingAppIdSet);
            if (!lendingAppIdSet.isEmpty()) {
                setLendingAppFinalSettlementReached(lendingAppIdSet);
            }
        }
    }
    
    @Future(callout=true)
    public static void setLendingAppFinalSettlementReached (Set<Id> lendingAppIdSet) {
        String jsonstr = JSON.serialize(lendingAppIdSet);
        RestIntegrationInformation__mdt restIntegration = [select MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c,System_Endpoint__c From RestIntegrationInformation__mdt];
        SendOpportunityAccountUsingRestApi classInstance= new SendOpportunityAccountUsingRestApi();
        String accessToken = classInstance.ReturnAccessToken(classInstance);
        system.debug('++++accessToken++++'+accessToken);
        if(accessToken!=null){
            String endPoint= restIntegration.System_Endpoint__c + '/setApplicationFinalSettlementReached'; 
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            req.setHeader('Authorization','Bearer ' + accessToken);
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(jsonstr);
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            system.debug('++++REQUEST++++'+req);
            HttpResponse response;
            try{
                response= h.send(req);
            }
            catch(Exception e){
                System.debug(e.getMessage());
                notifyConnectionFail(e.getMessage());
            }
            System.debug('++++reques++++'+response);
            String str = response.getBody();
            
            
            System.debug('++++request body++++'+str);
            
            if (response.getStatus() != 'OK' && response.getStatusCode() != 200) {
                notifyConnectionFail(str);
            }
        }
    }
    
    private static void notifyConnectionFail (String errroMsg) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{'msanghani@mindzcloud.com','jtamilarasu@stratfs.com','abhandari@stratfs.com'};
        semail.setToAddresses(sendingTo);
        semail.setSubject('Nudebt-Lending Connection failed.');
        String emailContent = 'Your api request to mark lending application \'Final Settlement Reached\' was failed due to this error. Please take a look. \n\n '+ errroMsg;
        semail.setPlainTextBody(emailContent);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    }
}