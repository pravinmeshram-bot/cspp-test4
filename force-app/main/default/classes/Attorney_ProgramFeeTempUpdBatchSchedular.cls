global class Attorney_ProgramFeeTempUpdBatchSchedular implements Schedulable{
    global void execute(SchedulableContext sc) {
        //Re-schedule ourself to run again in "intervalMinutes" time
        List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = False AND Category__c = 'Program'];
        system.debug('###systemLogLst::'+systemLogLst);
        if(!systemLogLst.isEmpty()){
            NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Fee_Template_Update__c));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year();
            
                systemLogLst[0].jobRunning__c = TRUE;
                Update systemLogLst[0];     
             
            System.schedule(Attorney_ProgramFeeTempUpdBatchSchedular.class.getName() + '-' + System.currentTimeMillis(), cronString, new Attorney_ProgramFeeTempUpdBatchSchedular());
            Database.executeBatch(new Attorney_ProgramFeeTemplateUpdateBatch());
            //systemLogLst[0].jobRunning__c = False;
            //Update systemLogLst[0];
            system.debug('###completed::');
        }else{
            NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Fee_Template_Update__c));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(Attorney_ProgramFeeTempUpdBatchSchedular.class.getName() + '-' + System.currentTimeMillis(), cronString, new Attorney_ProgramFeeTempUpdBatchSchedular());
            Database.executeBatch(new Attorney_GetEmptyFeeBatch());  
        }
    }
}