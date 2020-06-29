global class Attorney_fileNumberBatchSchedular implements Schedulable{
    global void execute(SchedulableContext sc) {
        //Re-schedule ourself to run again in "intervalMinutes" time
        Time timeNow = System.now().Time();
        
        List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE AND (NOT Exception_Message__c LIKE '%Read timed out%') AND (NOT Exception_Message__c LIKE '%connect timed out%') AND (NOT Exception_Message__c LIKE '%unable to obtain exclusive access%') AND (NOT Exception_Message__c LIKE '%AccessDeniedException%') AND CATEGORY__C != 'Program' AND CATEGORY__C != 'Note'];
        if(systemLogLst.isEmpty()){
            NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
            DateTime now  = DateTime.now();
            DateTime nextRunTime;
            String cronString = '';
            System.debug('*******'+timeNow);
            System.debug('********'+ timeNow.hour());
            if(timeNow.hour() >= 12 && timeNow.hour()< 14 && timings.Skip_at_12_to_2__c){
                nextRunTime = now.addMinutes(Integer.ValueOf(timings.Duration__c));
                cronString = '' + '0' + ' ' + '0' + ' ' + 
                    '14' + ' ' + nextRunTime.day() + ' ' + 
                    nextRunTime.month() + ' ? ' + nextRunTime.year();             
            } else {
                
                nextRunTime = now.addMinutes(Integer.ValueOf(timings.Duration__c));
                cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                    nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            }
            System.debug('*****'+CronString);
            System.schedule(Attorney_fileNumberBatchSchedular.class.getName() + '-' + now.format(), cronString, new Attorney_fileNumberBatchSchedular());
            // Launch a batch job or call a future method to do the actual work
            
            system.debug('###timings.NextBatchJobStartTime__cSchedular::'+timings.NextBatchJobStartTime__c);
            system.debug('###timings.NextBatchJobEndTime__cSchedular::'+timings.NextBatchJobEndTime__c);
            //String LastRunTimeStr = timings.LastSuccessfulRun__c.format('yyyy-MM-dd HH:mm:ss', 'PST');
            //DateTime LastRunTime = DateTime.ValueOf(LastRunTimeStr); 
            //String currentTimeStr = system.now().format('yyyy-MM-dd HH:mm:ss', 'PST');
            //DateTime currentTime = DateTime.ValueOf(currentTimeStr);
            //Database.executeBatch(new Attorney_GetClientsBatch(LastRunTime,currentTime));
            DateTime startTime = timings.LastSuccessfulRun__c.addHours(-7);
            DateTime endTime = system.now().addHours(-7);
            if(timings.APIDuration__c != NULL)
                endTime = startTime.addMinutes(Integer.ValueOf(timings.APIDuration__c));
            Database.executeBatch(new Attorney_GetFileNumberBatch(startTime,endTime));
            system.debug('###completed::');
        }
        else{
            NextBatchJobTimings__c timings = NextBatchJobTimings__c.getInstance();
            DateTime now  = DateTime.now();
            DateTime nextRunTime = now.addMinutes(Integer.ValueOf(timings.Duration__c));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
            System.schedule(Attorney_fileNumberBatchSchedular.class.getName() + '-' + now.format(), cronString, new Attorney_fileNumberBatchSchedular());
            //Database.executeBatch(new Attorney_GetEmptyBatch());    
        }
    }

    /*global void execute(system.schedulableContext sc){
        NextBatchJobTimings__c batchTimings = NextBatchJobTimings__c.getInstance();    
        Attorney_GetClientsBatch clientBatch = new Attorney_GetClientsBatch(batchTimings.NextBatchJobEndTime__C);
        Database.executeBatch(clientBatch);   
        
        RecurringScheduleJob.startJob();  

        String day = string.valueOf(system.now().day());

        String month = string.valueOf(system.now().month());

        String hour = string.valueOf(system.now().hour());

        String minute = string.valueOf(system.now().minute() + 10);

        String second = string.valueOf(system.now().second());

        String year = string.valueOf(system.now().year());



        String strJobName = 'Job-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;

        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

         
        System.schedule('Scheduled Job 1', '0 0 * * * ?', new Attorney_fileNumberBatchSchedular());
        System.schedule('Scheduled Job 2', '0 10 * * * ?', new Attorney_fileNumberBatchSchedular());
        System.schedule('Scheduled Job 3', '0 20 * * * ?', new Attorney_fileNumberBatchSchedular());
        System.schedule('Scheduled Job 4', '0 30 * * * ?', new Attorney_fileNumberBatchSchedular());
        System.schedule('Scheduled Job 5', '0 40 * * * ?', new Attorney_fileNumberBatchSchedular());
        System.schedule('Scheduled Job 6', '0 50 * * * ?', new Attorney_fileNumberBatchSchedular());      

    }*/
    
}