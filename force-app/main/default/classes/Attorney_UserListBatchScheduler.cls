global class Attorney_UserListBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
        DateTime now  = DateTime.now();
        
        System.debug('***'+Integer.valueOf(timings.NDS_User_List_Duration__c));
        DateTime nextRunTime = now.addMinutes(Integer.valueOf(timings.NDS_User_List_Duration__c));
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(Attorney_UserListBatchScheduler.class.getName() + '-' + now.format(), cronString, new Attorney_UserListBatchScheduler());
        
        Database.executeBatch(new Attorney_GetUserListBatch());
    }
    
    
    
}