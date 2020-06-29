global class Attorney_Trade_Pay_No_Program implements Schedulable{
    global void execute(System.SchedulableContext sc){
        NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Program_Update_Scheular_Duration__c));
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        if(!Test.isRunningTest())
        System.schedule(Attorney_Trade_Pay_No_Program.class.getName() + '-' + now.format(), cronString, new Attorney_Trade_Pay_No_Program());
        Database.executeBatch(new Attorney_TradelineProgramUpdateBatch(),50);
        
    }
}