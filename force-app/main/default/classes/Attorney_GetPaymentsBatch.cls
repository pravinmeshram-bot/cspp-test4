global class Attorney_GetPaymentsBatch implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
    global DateTime EndTime;
    global DateTime StartTime;
    global system_log__c sysLog; 
    public List<String> FileNumberList = new List<String>();    
    global Attorney_GetPaymentsBatch(DateTime BatchStartTime, DateTime BatchEndTime){
        system.debug('###BatchEndTime::'+BatchEndTime);
        system.debug('###BatchStartTime::'+BatchStartTime);
        EndTime = BatchEndTime;
        StartTime = BatchStartTime;   
        sysLog = new system_log__c();
        sysLog.Category__c = 'Payment'; 
        sysLog.Start_Time__c = startTime.addHours(7);
        sysLog.End_Time__c  = EndTime.addHours(7);
        sysLog.Batch_Start__c = startTime;
        Insert sysLog;    
    }
    global List<FileNumberData__c> start(Database.BatchableContext BC){
        List<FileNumberData__c> fileNumberDataLst = new List<FileNumberData__c>();
        //List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE];
        //if(systemLogLst.isEmpty())
            fileNumberDataLst = [select id,Name,Type__c From FileNumberData__c where completed__c = FALSE AND Type__c = 'Draft' AND isFirstPayment__c = True];
        /*else{
            FileNumberData__c fileNum = new FileNumberData__c();
            fileNumberDataLst.add(fileNum); 
        }*/
        return fileNumberDataLst;
    }
    global void execute(Database.BatchableContext BC,List<FileNumberData__c> scope){
        try{
            List<String> draftFileNumbersLst = new List<String>();
            for(FileNumberData__c file: scope){ 
                file.completed__c = TRUE;
                file.System_Log__c = sysLog.Id;
                draftFileNumbersLst.add(file.Name);
                fileNumberList.add(file.Name);
            }
            Attorney_GetClients.fetchDraftPayments(StartTime, EndTime, sysLog.Id,draftFileNumbersLst);
            Update scope;  
        }catch(Exception e){
            System_Log__c SL = new System_Log__c();
            SL.Id = sysLog.Id;
            SL.Exception_Description__c = e.getMessage() + '\n\n' + e.getStackTraceString();
            if(e.getMessage().length()>255)
                SL.Exception_Message__c = e.getMessage().subString(0,255);
            else
                SL.Exception_Message__c = e.getMessage();
            SL.Status__c = 'Failed';
            Update SL;
            if(!Test.isRunningTest())
                System.abortJob(bc.getJobId());
        }
    }
    global void finish(Database.BatchableContext BC){
        try{
            String status = '';
            System_Log__c SL = new System_Log__c();
            SL = [Select Status__c,JobRunning__c FROM System_Log__c Where Id =: sysLog.Id];
            SL.jobRunning__c = FALSE;
            AsyncApexJob job = new AsyncApexJob ();
            
            if (!Test.isRunningTest ()) {
                job = [SELECT TotalJobItems, JobItemsProcessed, CompletedDate, Status,ExtendedStatus FROM AsyncApexJob WHERE Id = :bc.getJobId()];        
                status = job.status;
                SL.Batch_Completed__c = Job.CompletedDate;
                
                    
            }
            if (Test.isRunningTest ())
                status = 'Completed';
            
            if(status == 'Completed' && SL.Status__c != 'Failed'){
                SL.Status__c = 'Completed'; 
                SL.JobRunning__c = FALSE; 
                if(job.ExtendedStatus != NULL){
                    SL.Exception_Description__c = job.ExtendedStatus;    
                    SL.JobRunning__c = TRUE; 
                }else{
                    NextBatchJobTimings__c batchTimings = NextBatchJobTimings__c.getValues(UserInfo.getProfileId());
                    //Attorney_GetDebtsBatch DebtsBatch = new Attorney_GetDebtsBatch(StartTime,EndTime);
                    //if (!Test.isRunningTest ())
                       // Database.executeBatch(DebtsBatch,Integer.valueOf(batchTimings.Debt_Batch_Size__c));
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
        
        try{
            List<nu_dse__Program__c>  ProgramList = [Select Id,Import_ID__c,Program_Type__c from nu_dse__Program__c where Import_ID__c=:FileNumberList];
            Set<Id> ProgramIds = new Set<Id>();
            
            for(nu_dse__Program__c Program : ProgramList){
                if(program.Import_Id__c != null && program.Program_Type__c != null && getLeadtrackProgramLst().get(program.Program_Type__c) != null && getLeadtrackProgramLst().get(Program.Program_Type__c).RAMS__c){
                    ProgramIds.add(Program.Id);
                }
            }
            if(!ProgramIds.isEMpty()){
          //      Database.executeBatch(new nu_dse.Batch_CreateAndUpdatePayment_RAMS(ProgramIds), 1);
            }
        } catch (Exception e){
        
        }
    }
        
    
    public static Map<String,LeadTracProgramType__mdt> getLeadtrackProgramLst(){
        List<LeadTracProgramType__mdt> leadtrckProgramTypeLst = [Select Id,RAMS__c,Label,Parameter__c FROM LeadTracProgramType__mdt Where Active__c = TRUE and Parameter__c = 'Program Type'];    
        Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String,LeadTracProgramType__mdt>();
        for(LeadTracProgramType__mdt programType : leadtrckProgramTypeLst ){
            LeadTracProgramTypeMap.put(programType.Label,programType);
        }
        return LeadTracProgramTypeMap;
    }    
        
}