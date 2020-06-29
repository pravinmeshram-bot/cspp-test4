global with sharing class Batch_CommunicationNotificationBySMS implements Database.Batchable<sObject>, Database.AllowsCallouts {
   
    Integer dailyLimit, hourlyLimit;
    public Set<Id> taskIds = new Set<Id>();
    
    global Batch_CommunicationNotificationBySMS() {
    
        nu_dse__Communication_Notification_Settings__c communicationNotifSetting = nu_dse__Communication_Notification_Settings__c.getInstance();
        
        if (communicationNotifSetting.nu_dse__SMS_Daily_Limit__c != null) {
        
            dailyLimit = Integer.valueOf(communicationNotifSetting.nu_dse__SMS_Daily_Limit__c);
        }
        
        if (communicationNotifSetting.nu_dse__SMS_Hourly_Limit__c != null) {
        
            hourlyLimit = Integer.valueOf(communicationNotifSetting.nu_dse__SMS_Hourly_Limit__c);
        }
    }
    
    public Batch_CommunicationNotificationBySMS(Set<Id> paramIds) {
    
        if (paramIds.isEmpty() == false) {
        
            taskIds.addAll(paramIds);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
       Set<String> taskSkipStatusSet = new Set<String> {'Completed', 'Canceled'};
       
       String query = 'SELECT Id, Subject, WhatId, nu_dse__Phone__c, nu_dse__Communication_Template__c, nu_dse__Communication_Template__r.nu_dse__Action_Type__c,' + 
                      ' nu_dse__Communication_Template__r.nu_dse__From__c, nu_dse__Communication_Template__r.nu_dse__SMS_Body__c FROM Task ' + 
                      ' WHERE ActivityDate = Today AND nu_dse__Communication_Sent__c = False AND Status NOT IN :taskSkipStatusSet AND ' +
                      ' nu_dse__Communication_Template__r.nu_dse__Action_Type__c = \'SMS\' ';
        
         if (taskIds.isEmpty() == False) {
            
            query += ' AND Id IN :taskIds';
        }       
        
        query += ' ORDER BY CreatedDate ';
        
        if (hourlyLimit > 0) {
        
            query += ' LIMIT ' + hourlyLimit;
        }
        
       system.debug('query--->'+query);
       return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Task> scope) {
       
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
       
        if ((Limits.getCallouts() + scope.size()) < Limits.getLimitCallouts()) {
       
            try {
                
                system.debug('execute-->'+scope);
                communicationHandler communicationHandlerInstance = new communicationHandler();
                communicationHandlerInstance.sendSMS(scope);
                /*Type t = Type.forName('communicationHandler');
                nu_dse.CommunicationInterface communication = (nu_dse.CommunicationInterface)t.newInstance();
                communication.sendSMS(scope);*/
               
            } catch(Exception e) {
           
                nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_CommunicationNotificationBySMS', 
                                            nu_dse__Message__c = e.getMessage(),
                                            nu_dse__Stack_Trace__c = e.getStackTraceString(), 
                                            nu_dse__User_Context__c = userInfo.getName());
                errorLogList.add(errorlog);
            }
           
        } else {
       
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_CommunicationNotificationBySMS',  
                                    nu_dse__Message__c = 'Callout Limit Exceeded', 
                                    nu_dse__User_Context__c = userInfo.getName());
            errorLogList.add(errorlog);
        }
       
        if (errorLogList.isEmpty() == False) {
       
            insert errorLogList;
        }
    }

    global void finish(Database.BatchableContext BC) {

        List<Task> tasksToUpdateList = new List<Task>();
        List<nu_dse__Error_Log__c> errorLogToInsertList = new List<nu_dse__Error_Log__c>();
        Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        Boolean considerWeekEnd = False, considerHoliday = False;
       
        try {
       
            Integer numOfTotalRecords = [SELECT Count() FROM Task WHERE ActivityDate = Today 
                                           AND nu_dse__Communication_Template__r.nu_dse__Action_Type__c = 'SMS'];
                                           
            Integer numOfNotProcessRecords = 0;
           
            if (numOfTotalRecords != null && dailyLimit != null) {
           
                numOfNotProcessRecords = numOfTotalRecords - dailyLimit;
            }
           
            if (numOfNotProcessRecords > 0) {
            
                holidayMap = Holidays.getHolidaysMap();
                nu_dse__Holidays_Settings__c holidaysCustSetting = nu_dse__Holidays_Settings__c.getInstance();
               
                if (holidaysCustSetting.nu_dse__Consider_Holiday__c != null) {
               
                   considerHoliday = holidaysCustSetting.nu_dse__Consider_Holiday__c;
                }
               
                if (holidaysCustSetting.nu_dse__Consider_WeekEnd__c != null) {
               
                   considerWeekEnd = holidaysCustSetting.nu_dse__Consider_WeekEnd__c;
                }
                
                for (Task taskRec : [SELECT Id, ActivityDate FROM Task WHERE ActivityDate = Today 
                                        AND nu_dse__Communication_Template__r.nu_dse__Action_Type__c = 'SMS' 
                                        ORDER BY CreatedDate DESC LIMIT :numOfNotProcessRecords]) {
               
                    Task taskRecToUpdate = new Task(Id = taskRec.Id);
                    Holidays holidayClass = new Holidays();
                    taskRecToUpdate.ActivityDate = holidayClass.getNextWorkingDay(holidayMap, taskRec.ActivityDate.addDays(1), considerWeekEnd, considerHoliday);
                    tasksToUpdateList.add(taskRecToUpdate);
                }
               
                if (tasksToUpdateList.isEmpty() == False) {
               
                    update tasksToUpdateList;
                }
            }
        } catch(Exception e) {
       
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_CommunicationNotificationBySMS.Finish', 
                                            nu_dse__Message__c = e.getMessage(), 
                                            nu_dse__Stack_Trace__c = e.getStackTraceString(),
                                            nu_dse__User_Context__c = userInfo.getName());
            errorLogToInsertList.add(errorlog);
        }
       
        if (errorLogToInsertList.isEmpty() == False) {
           
           insert errorLogToInsertList;
        }
    }
}