global class Attorney_GetTaskTypesBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
        DateTime now  = DateTime.now();
        
        System.debug('***'+Integer.valueOf(timings.Push_Task_Type_Duration__c));
        DateTime nextRunTime = now.addMinutes(Integer.valueOf(timings.Push_Task_Type_Duration__c));
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(Attorney_GetTaskTypesBatchScheduler.class.getName() + '-' + now.format(), cronString, new Attorney_GetTaskTypesBatchScheduler());
        
        Database.executeBatch(new Attorney_GetTaskTypesBatch());
    }
    
    
    
}