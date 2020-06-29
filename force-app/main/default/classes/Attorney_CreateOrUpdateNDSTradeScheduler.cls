global class Attorney_CreateOrUpdateNDSTradeScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        NextBatchJobTimings_Push__c timings = NextBatchJobTimings_Push__c.getValues(UserInfo.getProfileId());
        
        System.debug('****'+timings);
        if(timings.Is_Push_Job_Running__c == false){
            
            timings.Is_Push_Job_Running__c = true;
            update timings;
            
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Push_Backup_Duration__c));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(Attorney_CreateOrUpdateNDSTradeScheduler.class.getName() + '-' + now.format(), cronString, new Attorney_CreateOrUpdateNDSTradeScheduler());
            
            Database.executeBatch(new Attorney_CreateOrUpdateNDSTradeBatch(),1);
        }
        else
        {
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Push_Backup_Duration__c));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(Attorney_CreateOrUpdateNDSTradeScheduler.class.getName() + '-' + now.format(), cronString, new Attorney_CreateOrUpdateNDSTradeScheduler());
            Database.executeBatch(new Attorney_GetEmptyBatch_Push());    
        }
    }
}