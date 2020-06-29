global class Attorney_GetDebtsBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts, Database.stateful{
    global DateTime startTime;
    global DateTime endTime;
    global Integer count = 0;
    global system_log__c sysLog;
    global Attorney_GetDebtsBatch(DateTime BatchStartTime, DateTime BatchEndtime){
        startTime = BatchStartTime;
        endTime = BatchEndtime;
        sysLog = new system_log__c();
        sysLog.Category__c = 'Tradeline'; 
        sysLog.Start_Time__c = startTime.addHours(7);
        sysLog.End_Time__c  = endTime.addHours(7);
        sysLog.Batch_Start__c = startTime;
        Insert sysLog; 
    }    
    global List<FileNumberData__c> start(Database.BatchableContext BC){
        List<FileNumberData__c> fileNumberDataLst = new List<FileNumberData__c>();
        //List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE];
        //if(systemLogLst.isEmpty())
            fileNumberDataLst = [select id,Name,Type__c From FileNumberData__c where completed__c = FALSE AND Type__c = 'Debt' Order by Name Desc];
        /*else{
            FileNumberData__c fileNum = new FileNumberData__c();
            fileNumberDataLst.add(fileNum); 
        }*/
        return fileNumberDataLst;
        
    }
    global void execute(Database.BatchableContext BC,List<FileNumberData__c> scope){
        try{
            List<String> debtFileNumbersLst = new List<String>();
            for(FileNumberData__c file: scope){ 
                file.completed__c = TRUE;
                file.System_Log__c = sysLog.Id;
                debtFileNumbersLst.add(file.Name);
            }
            Attorney_GetDebts.fetchAndprocessDebts(startTime, endTime, sysLog.Id,debtFileNumbersLst, bc.getJobId());
            Update scope;  
        } catch(Exception e){
            System_Log__c SL = new System_Log__c();
            SL.Id = sysLog.Id;
            SL.Exception_Description__c = e.getMessage()+ '\n\n' + e.getStackTraceString();
            if(e.getMessage().length()>255)
                SL.Exception_Message__c = e.getMessage().subString(0,255);
            else
                SL.Exception_Message__c = e.getMessage();
            SL.Status__c = 'Failed';
            Update SL;
            if (!Test.isRunningTest ())
                System.abortJob(bc.getJobId());
        }
    }
    global void finish(Database.BatchableContext BC){
        try{
            DateTime nextJobStartTime; 
            System_Log__c SL = new System_Log__c();
            SL = [Select Status__c,JobRunning__c FROM System_Log__c Where Id =: sysLog.Id];
            String status = '';
            AsyncApexJob job = new AsyncApexJob ();
            if (!Test.isRunningTest ()) {
                job = [SELECT TotalJobItems, JobItemsProcessed, CompletedDate, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :bc.getJobId()];        
                system.debug('###job::'+job);
                SL.Batch_Completed__c = Job.CompletedDate;
                status = job.status;
            }
            if (Test.isRunningTest ()) { 
                status = 'Completed';
                
                SL.Status__c = 'Completed';
            }
            SL.JobRunning__c = FALSE;
            if(status == 'Completed' && SL.Status__c != 'Failed'){
                SL.Status__c = 'Completed';
                if(job.ExtendedStatus != NULL){
                    SL.Exception_Description__c = job.ExtendedStatus;    
                    SL.JobRunning__c = TRUE; 
                }else{
                    //List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE];
                    //if(systemLogLst.isEmpty()){
                    NextBatchJobTimings__c timings = NextBatchJobTimings__c.getValues(UserInfo.getProfileId());
                    DateTime successfulrunLoadTime = endTime.addHours(7);
                    timings.LastSuccessfulRun__c = successfulrunLoadTime.addMinutes(-1);
                    update timings;
                }  
                //}  
            }else
                SL.Status__c = 'Failed';    
            Database.upsertResult saveRec = Database.Upsert(SL,False);
            system.debug('###saveRec::'+saveRec);
        }catch(Exception e){
            System_Log__c SL = new System_Log__c();
            SL.Id = sysLog.Id;
            SL.Exception_Description__c = e.getMessage()+ '\n\n' + e.getStackTraceString();
            if(e.getMessage().length()>255)
                SL.Exception_Message__c = e.getMessage().subString(0,255);
            else
                SL.Exception_Message__c = e.getMessage();
            SL.Status__c = 'Failed';
            Update SL;
        }
        
    }
}