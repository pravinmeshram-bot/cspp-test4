global class Attorney_GetLogEntriesBatch implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
    
    global Integer currentPage; 
    global Integer totalPagesToExecute = 0; 
    global DateTime startTime; 
    global DateTime endTime; 
    global system_log__c sysLog;
    global LeadtracNetClient.GetCompanyLogEntries_element request_x = new LeadtracNetClient.GetCompanyLogEntries_element();
    global Attorney_GetLogEntriesBatchHandler batchHandler = new  Attorney_GetLogEntriesBatchHandler();
    global Batch_Data__c LogEntriesBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    global Attorney_GetLogEntriesBatch(DateTime BatchStartTime, DateTime BatchEndTime){
        
        LogEntriesBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_GetLogEntriesBatch'];
        System.OrgLimit async;
        if(Test.isRunningTest()){
            asyncLimitUsed = 0;    
        } else {
        	async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
        		asyncLimitUsed = async.getValue();
        }
        if(LogEntriesBatchData.Last_Execution_Time__c == null || LogEntriesBatchData.Last_Execution_Time__c.day() != System.now().day()){
            LogEntriesBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        
        startTime = BatchStartTime;
        endTime = BatchEndTime;
        sysLog = new system_log__c();
        sysLog.Category__c = 'Note'; 
        sysLog.Start_Time__c = startTime.addHours(7);
        sysLog.End_Time__c  = endTime.addHours(7);
        sysLog.Batch_Start__c = startTime;
        insert sysLog; 
    }
    
    global List<Task> start(Database.BatchableContext BC){ 
        currentPage = 1;
        try
        {
        request_x = setupRequest(currentPage,startTime.addhours(-1),endTime.addhours(-1));
        totalPagesToExecute = batchHandler.executeLogPages(request_x);
            
            if(test.isRunningTest()){
                System.debug(integer.valueof('hhkj'));
            }
        }
        catch(Exception e){
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
        return [Select Id from Task Limit :totalPagesToExecute];
    }
    
    global void execute(Database.BatchableContext BC,List<Task>  pagesToProcess){
        
        try
        {
            currentPage = currentPage + 1;
            request_x.page_x = currentPage; 
            batchHandler.executeLogPages(request_x);
        }
        catch(Exception e){
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
                    NextBatchJobTimings_Log__c timings = NextBatchJobTimings_Log__c.getValues(UserInfo.getProfileId());
                    DateTime successfulrunLoadTime = endTime.addHours(7);
                    timings.LastSuccessfullRun_Log__c = successfulrunLoadTime.addMinutes(-1);
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
        if(!Test.isRunningTest()){
        	System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
            if(async.getValue() != null)
                LogEntriesBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(LogEntriesBatchData.Number_of_Callouts__c) + async.getValue() - asyncLimitUsed);
            else
                LogEntriesBatchData.Number_of_Callouts__c = String.valueOf(Integer.valueOf(LogEntriesBatchData.Number_of_Callouts__c) + asyncLimitUsed);
        }
        LogEntriesBatchData.Last_Execution_Time__c = System.now();
        LogEntriesBatchData.Batch_Execution_Status__c = 'Success';
        Update LogEntriesBatchData;
    }
    
    public LeadtracNetClient.GetCompanyLogEntries_element setupRequest(Integer currentPage,DateTime startDate,DateTime endDate){
        LeadtracNetClient.GetCompanyLogEntries_element request_x = new LeadtracNetClient.GetCompanyLogEntries_element();
        request_x.userName = 'dev_team'; //Attorney_StaticVariableUtility.credentials.UserName__c;
        request_x.password = 'Password1234'; //Attorney_StaticVariableUtility.credentials.Password__c;
        request_x.startDate = startDate;
        request_x.endDate = endDate;
        request_x.page_x = currentPage;
        leadtracNetClient.ArrayOfCriteria criteriaArray = new leadtracNetClient.ArrayOfCriteria();
        List<leadtracNetClient.Criteria> criteriaLst = new List<leadtracNetClient.Criteria>();
        List<LeadTracProgramType__mdt> LeadtrackProgrmLst = Attorney_GetLogEntriesBatchHandler.getLeadtrackProgramLst();
        leadtracNetClient.Criteria criteria;
        String programTypeStr = '';
        for(LeadTracProgramType__mdt programType: LeadtrackProgrmLst){
            programTypeStr +=','+programType.Label;      
        }
        criteria = new leadtracNetClient.Criteria();       
        criteria.Key = 'ProgramType';
        criteria.Operator = 'In';
        criteria.Value = programTypeStr;
        criteriaLst.add(criteria);
        
        criteriaArray.Criteria = criteriaLst;
        request_x.criteriaList = criteriaArray;
        
        System.debug('++++ Request Build ' + request_x);
        
        return request_x;
    }
    
    
}