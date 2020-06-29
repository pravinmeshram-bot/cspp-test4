global class Attorney_GetLogEntriesBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE AND CATEGORY__C = 'Note' AND (NOT Exception_Message__c LIKE '%Read timed out%') AND (NOT Exception_Message__c LIKE '%connect timed out%') AND (NOT Exception_Message__c LIKE '%unable to obtain exclusive access%')];
        if(systemLogLst.isEmpty()){
        NextBatchJobTimings_Log__c timings = NextBatchJobTimings_Log__c.getInstance(); 
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Duration_Log__c));
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(Attorney_GetLogEntriesBatchScheduler.class.getName() + '-' + now.format(), cronString, new Attorney_GetLogEntriesBatchScheduler());
        DateTime startTime = timings.LastSuccessfullRun_Log__c.addHours(-7);
        DateTime endTime = system.now().addHours(-7);
        if(timings.API_Duration_Log__c != NULL)
            endTime = startTime.addMinutes(Integer.ValueOf(timings.API_Duration_Log__c));
        Database.executeBatch(new Attorney_GetLogEntriesBatch(startTime,endTime),1);
        }
        else{
            NextBatchJobTimings_Log__c timings = NextBatchJobTimings_Log__c.getInstance();
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Duration_Log__c));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(Attorney_GetLogEntriesBatchScheduler.class.getName() + '-' + now.format(), cronString, new Attorney_GetLogEntriesBatchScheduler());
            Database.executeBatch(new Attorney_GetEmptyBatch_Log());    
        }
    }
   
}