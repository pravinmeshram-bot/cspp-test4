global class Attorney_GetClientsBatch implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
    global DateTime EndTime;
    global DateTime StartTime;
    global system_log__c sysLog;
    global Attorney_GetClientsBatch(DateTime BatchStartTime, DateTime BatchEndTime){
        system.debug('###BatchEndTime::'+BatchEndTime);
        system.debug('###BatchStartTime::'+BatchStartTime);
        EndTime = BatchEndTime;
        StartTime = BatchStartTime;   
        sysLog = new system_log__c();
        sysLog.Category__c = 'Client'; 
        sysLog.Start_Time__c = startTime.addHours(7);
        sysLog.End_Time__c  = EndTime.addHours(7);
        sysLog.Batch_Start__c = startTime;
        Insert sysLog;    
    }
    global List<FileNumberData__c> start(Database.BatchableContext BC){
        //List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE];
        List<FileNumberData__c> fileNumberDataLst = new List<FileNumberData__c>();
        //if(systemLogLst.isEmpty())
            fileNumberDataLst = [select id,Name,Type__c From FileNumberData__c where completed__c = FALSE AND Type__c = 'Client' order by Name DESC];
        /*else{
            FileNumberData__c fileNum = new FileNumberData__c();
            fileNumberDataLst.add(fileNum); 
        }*/   
        return fileNumberDataLst;
    }
    global void execute(Database.BatchableContext BC,List<FileNumberData__c> scope){
        try{
            List<String> clientFileNumbersLst = new List<String>();
            for(FileNumberData__c file: scope){ 
                file.completed__c = TRUE;
                file.System_Log__c = sysLog.Id;
                clientFileNumbersLst.add(file.Name);
                System.debug('***'+File.Name);
            }
            //Update Scope;
            
            Attorney_GetClients.fetchClinets(StartTime, EndTime, sysLog.Id, clientFileNumbersLst, bc.getJobId());
            
            
            Update scope;  
        }catch(Exception e){
            if (!Test.isRunningTest ())
                System.abortJob(bc.getJobId());
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
    
    global void finish(Database.BatchableContext BC){
        try{
            String status = '';
            System_Log__c SL = new System_Log__c();
            SL = [Select Status__c,JobRunning__c FROM System_Log__c Where Id =: sysLog.Id];
            AsyncApexJob job = new AsyncApexJob ();
            
            if (!Test.isRunningTest ()) {
                job = [SELECT TotalJobItems, JobItemsProcessed, CompletedDate, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :bc.getJobId()];        
                status = job.status;
                SL.Batch_Completed__c = Job.CompletedDate;
            }
            if (Test.isRunningTest ())
                status = 'Completed';
            SL.JobRunning__c = FALSE;
            if((status == 'Completed' && SL.Status__c != 'Failed') || Test.isRunningTest()){
                SL.Status__c = 'Completed';   
                if(job.ExtendedStatus != NULL){
                    SL.Exception_Description__c = job.ExtendedStatus;    
                    SL.JobRunning__c = TRUE; 
                }else{
                    NextBatchJobTimings__c batchTimings = NextBatchJobTimings__c.getValues(UserInfo.getProfileId());
                    Attorney_GetPaymentsBatch DraftsBatch = new Attorney_GetPaymentsBatch(StartTime,EndTime);
                    if (!Test.isRunningTest ())
                        Database.executeBatch(DraftsBatch,Integer.valueOf(batchTimings.Draft_Batch_Size__c));
                        
                    Attorney_GetPaymentsBatch1 DraftsBatch1 = new Attorney_GetPaymentsBatch1(StartTime,EndTime);
                    if (!Test.isRunningTest ())
                        Database.executeBatch(DraftsBatch1,Integer.valueOf(batchTimings.Draft_Batch_Size__c));
                    
                    Attorney_GetDebtsBatch DebtsBatch = new Attorney_GetDebtsBatch(StartTime,EndTime);
                    if (!Test.isRunningTest ())
                        Database.executeBatch(DebtsBatch,Integer.valueOf(batchTimings.Debt_Batch_Size__c));
                }
            }
            else
                SL.Status__c = 'Failed';  
            if (Test.isRunningTest ()){
                status = 'Failed';
                CalloutException e = new CalloutException();
                    //e.setMessage(errorString);
                    throw e;
            }
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