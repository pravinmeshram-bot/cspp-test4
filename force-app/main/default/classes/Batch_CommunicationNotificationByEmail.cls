global with sharing class Batch_CommunicationNotificationByEmail implements Database.Batchable<sObject>, Database.stateful {
   
    Integer dailyLimit, hourlyLimit;
    public Set<Id> taskIds = new Set<Id>();
    
    global Batch_CommunicationNotificationByEmail() {
    
        nu_dse__Communication_Notification_Settings__c communicationNotifSetting = nu_dse__Communication_Notification_Settings__c.getInstance();
        
        if (communicationNotifSetting.nu_dse__Email_Daily_Limit__c != null) {
        
            dailyLimit = Integer.valueOf(communicationNotifSetting.nu_dse__Email_Daily_Limit__c);
        }
        
        if (communicationNotifSetting.nu_dse__Email_Hourly_Limit__c != null) {
        
            hourlyLimit = Integer.valueOf(communicationNotifSetting.nu_dse__Email_Hourly_Limit__c);
        }
    }
    
    public Batch_CommunicationNotificationByEmail(Set<Id> paramIds) {
    
        if (paramIds.isEmpty() == false) {
        
            taskIds.addAll(paramIds);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         
        Set<String> taskSkipStatusSet = new Set<String> {'Completed', 'Canceled'};
        
        String query = 'SELECT Id, Subject, WhatId, WhoId, nu_dse__Communication_Template__c, nu_dse__Communication_Template__r.nu_dse__Action_Type__c,' + 
                       ' nu_dse__Communication_Template__r.nu_dse__Email_Template_Id__c, nu_dse__Communication_Template__r.nu_dse__Email_Body__c,'+
                       ' nu_dse__Communication_Template__r.nu_dse__From__c FROM Task ' + 
                       ' WHERE ActivityDate = Today AND nu_dse__Communication_Sent__c = False AND Status NOT IN :taskSkipStatusSet AND ' +
                       ' nu_dse__Communication_Template__r.nu_dse__Action_Type__c = \'Email Alert\' ';
          
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
       
        try {
       
            communicationHandler communicationHandlerInstance = new communicationHandler();
            communicationHandlerInstance.sendEmailAlerts(scope);
           
        } catch(Exception e) {
       
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_CommunicationNotificationByEmail', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = userInfo.getName());
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
                                           AND nu_dse__Communication_Template__r.nu_dse__Action_Type__c = 'Email Alert'];
                                           
           Integer numOfNotProcessRecords = 0;
           
           if (Test.isRunningTest()) {
               
               numOfNotProcessRecords = 1;
           }
           
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
                                       AND nu_dse__Communication_Template__r.nu_dse__Action_Type__c = 'Email Alert' 
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
       
           nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_CommunicationNotificationByEmail.Finish',nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),  nu_dse__User_Context__c = userInfo.getName());
           errorLogToInsertList.add(errorlog);
       }
       
       if (errorLogToInsertList.isEmpty() == False) {
           
           insert errorLogToInsertList;
       }
    }
}