global class Attorney_SFSCasePushtoNDSSchedular implements Schedulable{

    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new Attorney_SFSCasePushtoNDS(),1);
        NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.SFS_Case_Push_Duration__c));
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
        nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
        nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(Attorney_SFSCasePushtoNDSSchedular.class.getName() + '-' + now.format(), cronString, new Attorney_SFSCasePushtoNDSSchedular());
    }

}