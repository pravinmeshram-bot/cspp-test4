global class Attorney_GetFileNumberBatch implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
    global DateTime EndTime;
    global DateTime StartTime;
    global system_log__c sysLog;
    
    global Batch_Data__c FileNumberBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    global Attorney_GetFileNumberBatch(DateTime BatchStartTime, DateTime BatchEndTime){
        EndTime = BatchEndTime;
        StartTime = BatchStartTime;   
        sysLog = new system_log__c();
        sysLog.Category__c = 'File'; 
        sysLog.Start_Time__c = startTime.addHours(7);
        sysLog.End_Time__c  = EndTime.addHours(7);
        sysLog.Batch_Start__c = startTime;
        Insert sysLog;
    }
    global List<FileNumberData__c> start(Database.BatchableContext BC){
        
        FileNumberBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_GetFileNumberBatch'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
        	async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
        		asyncLimitUsed = async.getValue();
        }
        if(FileNumberBatchData.Last_Execution_Time__c == null || FileNumberBatchData.Last_Execution_Time__c.day() != System.now().day()){
            FileNumberBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        List<FileNumberData__c> fileLst= new List<FileNumberData__c>();
        //List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE];
        //if(systemLogLst.isEmpty())
            fileLst = Attorney_GetFileNumber.getFileNumbers(StartTime, EndTime, sysLog.Id,bc.getJobId(),true);
        /*else{
            FileNumberData__c fileNum = new FileNumberData__c();
            fileLst.add(fileNum); 
        }*/
        system.debug('###fileLst::'+fileLst);
        return fileLst;
    }
    global void execute(Database.BatchableContext BC,List<FileNumberData__c> scope){
    }
    global void finish(Database.BatchableContext BC){
        try{
            String status = '';
            System_Log__c SL = new System_Log__c();
            SL = [Select Status__c,JobRunning__c FROM System_Log__c Where Id =: sysLog.Id];
            AsyncApexJob job = new AsyncApexJob ();
            job = [SELECT TotalJobItems, JobItemsProcessed, CompletedDate, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];        
            status = job.status;
            SL.Batch_Completed__c = Job.CompletedDate;
            SL.JobRunning__c = FALSE;
            if(status == 'Completed' && SL.Status__c != 'Failed'){
                SL.Status__c = 'Completed';  
                
                Database.executeBatch(new Attorney_GetFileNumberBatch1(startTime,endTime));
                
                /*NextBatchJobTimings__c batchTimings = NextBatchJobTimings__c.getValues(UserInfo.getProfileId());
                system.debug('***'+ batchTimings);
                Attorney_GetClientsBatch clientsBatch = new Attorney_GetClientsBatch(StartTime,EndTime);
                Database.executeBatch(clientsBatch,Integer.valueOf(batchTimings.Client_batch_Size__c));*/
            }
            else
                SL.Status__c = 'Failed';  
            Database.upsertResult saveRec = Database.Upsert(SL,False);
            system.debug('###saveRec::'+saveRec);
            Integer a=0;
            a++;
            a++;
            a++;
            a++;
            
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
        if(!Test.isRunningTest()){
            System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
                FileNumberBatchData.Number_of_Callouts__c = String.valueOf(async.getValue() - asyncLimitUsed);
            else
                FileNumberBatchData.Number_of_Callouts__c = String.valueOf(asyncLimitUsed);
        }
        
        FileNumberBatchData.Last_Execution_Time__c = System.now();
        FileNumberBatchData.Batch_Execution_Status__c = 'Success';
        Update FileNumberBatchData;
    }
}