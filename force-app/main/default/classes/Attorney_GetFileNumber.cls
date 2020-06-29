public class Attorney_GetFileNumber{
    public static leadtracNetDebt.ModifiedDebtsResult respdebt;
    public static leadtracNetDebt.ArrayOfGetDebtsResult debtsResArray;
    public static leadtracNetClient.ArrayOfString resp;
    static integer paymentSequence = 0;
    public static List<LeadTracProgramType__mdt> getLeadtrackProgramLst(Boolean isFirst){
        List<LeadTracProgramType__mdt> leadtrckProgramTypeLst; 
        
        if(isFirst){
            leadtrckProgramTypeLst = [Select Id,Label,Parameter__c FROM LeadTracProgramType__mdt Where Active__c = TRUE and Parameter__c = 'Program Type' AND isFirst__c = true];    
        } else{
            leadtrckProgramTypeLst = [Select Id,Label,Parameter__c FROM LeadTracProgramType__mdt Where Active__c = TRUE and Parameter__c = 'Program Type' AND isFirst__c = false];    
        }
        return leadtrckProgramTypeLst;
    }
    public static List<FileNumberData__c> getFileNumbers(DateTime StartTime, DateTime endTime, Id SysLogId,Id BatchJobId, Boolean isFirst){
        List<FileNumberData__c> fileDataLst = new List<FileNumberData__c>();
        try{
            /***************Getting LeadTrac credentials and Endpoint URL from custom settings************************/
            LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
            NextBatchJobTimings__c nextBatchTimings = NextBatchJobTimings__c.getInstance();
            Set<String> fileNumberSet = new Set<String>();
            
            /***************Making callout for getting Updated clients from LeadTrac system**************************/ 
            leadtracNetClient.ClientServiceSoap soap = new leadtracNetClient.ClientServiceSoap();
            resp = new leadtracNetClient.ArrayOfString();
            leadtracNetClient.ArrayOfCriteria criteriaArray = new leadtracNetClient.ArrayOfCriteria();
            List<leadtracNetClient.Criteria> criteriaLst = new List<leadtracNetClient.Criteria>();
            List<LeadTracProgramType__mdt> LeadtrackProgrmLst = getLeadtrackProgramLst(isFirst);
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
            system.debug('####criteriaArray::'+criteriaArray);
            //if (!Test.isRunningTest ())    
            
            //Changes made by Vaibhav as part of NMI-902
            
                if(NextBatchTimings.DayLightStarted__c)
                { 
                resp = soap.GetUpdatedClients(credentials.UserName__c,credentials.Password__c,StartTime,EndTime,criteriaArray);
                }
                else
                {                
                resp = soap.GetUpdatedClients(credentials.UserName__c,credentials.Password__c,StartTime.addhours(-1),EndTime.addhours(-1),criteriaArray);
                }
                
            // Commented by Vaibhav  resp = soap.GetUpdatedClients(credentials.UserName__c,credentials.Password__c,StartTime.addhours(-1),EndTime.addhours(-1),criteriaArray);
                system.debug(LoggingLevel.Info,'###res::'+resp.string_x);  
        
            /**************Adding file numbers which are coming from recent client updated in NDS system************/
            FileNumberData__c file;
            if(resp.string_x != NULL && (NextBatchTimings.Load_Clients__c == True || NextBatchTimings.Load_Tasks__c == true || NextBatchTimings.Load_Group_Tasks__c == True)){
                for(String fileNumber: resp.string_x){
                    fileNumberSet.add(fileNumber);    
                }
                
                for(String s: fileNumberSet){
                    file = new FileNumberData__c();
                    file.Name = s;
                    file.Completed__c = false;
                    file.Type__c = 'Client';
                    file.External_Id__c = file.Name + '_' + file.Type__c;
                    fileDataLst.add(file);
                }
            }
            /*********Geeting file Numbers related to draft payments*********************/
            leadtracNetServicing.ServicingSoap soapServicing = new leadtracNetServicing.ServicingSoap();
            leadtracNetServicing.ArrayOfCriteria criteriaArrayServing = new leadtracNetServicing.ArrayOfCriteria();
            List<leadtracNetServicing.Criteria> criteriaLstServicing = new List<leadtracNetServicing.Criteria>();
            leadtracNetServicing.ModifiedDraftPlanResult draftPlanRes = new leadtracNetServicing.ModifiedDraftPlanResult();
            leadtracNetServicing.Criteria criteriaServicing;
            
            criteriaServicing = new leadtracNetServicing.Criteria();       
            criteriaServicing.Key = 'ProgramType';
            criteriaServicing.Operator = 'In';
            criteriaServicing.Value = programTypeStr;
            criteriaLstServicing.add(criteriaServicing);
                
            criteriaArrayServing.Criteria = criteriaLstServicing;
            
             //Changes made by Vaibhav as part of NMI-902
            
                if(!Test.isRunningTest () && NextBatchTimings.DayLightStarted__c)
                { 
                draftPlanRes = soapServicing.GetModifiedDraftPlans(credentials.UserName__c,credentials.Password__c,StartTime,EndTime, criteriaArrayServing);
                }
                else if (!Test.isRunningTest ())
                {                
                draftPlanRes = soapServicing.GetModifiedDraftPlans(credentials.UserName__c,credentials.Password__c,StartTime.addhours(-1),EndTime.addhours(-1), criteriaArrayServing);
                }                       
            
        //    if (!Test.isRunningTest ())
       //         draftPlanRes = soapServicing.GetModifiedDraftPlans(credentials.UserName__c,credentials.Password__c,StartTime.addhours(-1),EndTime.addhours(-1), criteriaArrayServing);
            system.debug('###draftPlanRes::'+draftPlanRes);
            leadtracNetServicing.ArrayOfModifiedDraftPlan draftPlanArray = new leadtracNetServicing.ArrayOfModifiedDraftPlan();
        
            if(draftPlanRes.DraftPlans != NULL)
                draftPlanArray = draftPlanRes.DraftPlans;
            system.debug('###draftPlanArray::'+draftPlanArray);
        
            //added by rajesh
            leadtracNetDebt.DebtServiceSoap debtsoap1 = new leadtracNetDebt.DebtServiceSoap();
           
            leadtracNetDebt.ArrayOfCriteria criteriaArrayDebt = new leadtracNetDebt.ArrayOfCriteria();
            List<leadtracNetDebt.Criteria> criteriaDebtLst = new List<leadtracNetDebt.Criteria>();
            leadtracNetDebt.Criteria criteriaDebt;
            criteriaDebt = new leadtracNetDebt.Criteria();       
            criteriaDebt.Key = 'ProgramType';
            criteriaDebt.Operator = 'In';
            criteriaDebt.Value = programTypeStr;
            criteriaDebtLst.add(criteriaDebt);
                
            criteriaArrayDebt.Criteria = criteriaDebtLst;
            system.debug('####criteriaArrayDebt::'+criteriaArrayDebt);
            
            respdebt = new leadtracNetDebt.ModifiedDebtsResult();
            //if (!Test.isRunningTest ()) {
                
                debtsResArray = new leadtracNetDebt.ArrayOfGetDebtsResult();
                
                
                //Changes made by Vaibhav as part of NMI-902
            
                if(NextBatchTimings.DayLightStarted__c)
                { 
                respdebt = debtsoap1.GetModifiedDebts(credentials.UserName__c,credentials.Password__c,StartTime,EndTime,criteriaArrayDebt);
                }
                else
                {                
                respdebt = debtsoap1.GetModifiedDebts(credentials.UserName__c,credentials.Password__c,StartTime.addhours(-1),EndTime.addhours(-1),criteriaArrayDebt);
                }              
                
            // Commented by Vaibhav respdebt = debtsoap1.GetModifiedDebts(credentials.UserName__c,credentials.Password__c,StartTime.addhours(-1),EndTime.addhours(-1),criteriaArrayDebt);
            //} 
        
            
            if(draftPlanArray.ModifiedDraftPlan != NULL && NextBatchTimings.Load_Draft_Payments__c == true){
            
                    Set<String> filenumbersetdraft = new Set<String>();
                    for(leadtracNetServicing.ModifiedDraftPlan modifyDraftPlan: draftPlanArray.ModifiedDraftPlan){
                        filenumbersetdraft.add(modifyDraftPlan.FileNumber);    
                    }
                    List<String> fileNumberLst = new List<String>();
                    fileNumberLst.addAll(filenumbersetdraft);
                    
                    //static integer paymentSequence = 0;
                    for(String str: fileNumberLst){  
                        file = new FileNumberData__c();
                        file.Name = str;
                        file.Completed__c = false;
                        file.Type__c = 'Draft';
                        if(Math.mod(paymentSequence,2)==0){
                            file.isFirstPayment__c = true;
                        }
                        file.External_Id__c = file.Name + '_' + file.Type__c;
                        fileDataLst.add(file); 
                        PaymentSequence++;
                    }        
                }
                if(!fileDataLst.isEmpty()){ 
                    Schema.sObjectField ExternalIdField = FileNumberData__c.External_id__c.getDescribe().getSObjectField();
                    Database.UpsertResult[] saveRes = Database.Upsert(fileDataLst, ExternalIdField, True);
                    String errorString = '';
                    for(Database.UpsertResult saveRec: saveRes){
                        if(!saveRec.isSuccess())
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
             /*****************************Get Debts file Numbers*********************************/
            leadtracNetDebt debt1 = new leadtracNetDebt();
            /*leadtracNetDebt.DebtServiceSoap debtsoap1 = new leadtracNetDebt.DebtServiceSoap();
           
            leadtracNetDebt.ArrayOfCriteria criteriaArrayDebt = new leadtracNetDebt.ArrayOfCriteria();
            List<leadtracNetDebt.Criteria> criteriaDebtLst = new List<leadtracNetDebt.Criteria>();
            leadtracNetDebt.Criteria criteriaDebt;
            criteriaDebt = new leadtracNetDebt.Criteria();       
            criteriaDebt.Key = 'ProgramType';
            criteriaDebt.Operator = 'In';
            criteriaDebt.Value = programTypeStr;
            criteriaDebtLst.add(criteriaDebt);
                
            criteriaArrayDebt.Criteria = criteriaDebtLst;
            system.debug('####criteriaArrayDebt::'+criteriaArrayDebt);
    
            if (!Test.isRunningTest ()) {
                respdebt = new leadtracNetDebt.ModifiedDebtsResult();
                debtsResArray = new leadtracNetDebt.ArrayOfGetDebtsResult();
                respdebt = debtsoap1.GetModifiedDebts(credentials.UserName__c,credentials.Password__c,startTime,endTime,criteriaArrayDebt);
            } */
            system.debug('###respdebt::'+respdebt);
            leadtracNetDebt.ArrayOfModifiedDebt debtsArray = new leadtracNetDebt.ArrayOfModifiedDebt();
            if(respdebt.ModifiedDebts != NULL)
                debtsArray = respdebt.ModifiedDebts;
            leadtracNetDebt.GetDebtsResult debtRes;
            
            /******************************added to get Program Id***********************************/
            Set<string> debtFileNumSet = new Set<String>();
            
            fileDataLst.clear();
            if(debtsArray.ModifiedDebt != NULL && NextBatchTimings.Load_TradeLines__c == True){
                for(leadtracNetDebt.ModifiedDebt debt: debtsArray.ModifiedDebt){
                    debtFileNumSet.add(debt.fileNumber);     
                }
                List<String> fileNumberDebtLst = new List<String>();
                fileNumberDebtLst.addAll(debtFileNumSet);
                
                for(String str: fileNumberDebtLst){  
                    file = new FileNumberData__c();
                    file.Name = str;
                    file.Type__c = 'Debt';
                    file.Completed__c = false;
                    file.External_Id__c = file.Name + '_' + file.Type__c;
                    fileDataLst.add(file); 
                }
            }        
                if(!fileDataLst.isEmpty()){ 
                    Schema.sObjectField ExternalIdField = FileNumberData__c.External_id__c.getDescribe().getSObjectField();
                    Database.UpsertResult[] saveRes = Database.Upsert(fileDataLst, ExternalIdField, True);
                    String errorString = '';
                    for(Database.UpsertResult saveRec: saveRes){
                        if(!saveRec.isSuccess())
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                    }
                    if(errorString != ''){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }
             }catch(Exception e){
                 System_Log__c SL = new System_Log__c();
                 SL.Id = sysLogId;
                 SL.Exception_Description__c = e.getMessage() + '\n\n' + e.getStackTraceString();
                 System.debug('***'+e.getMessage() + '\n\n' + e.getStackTraceString());
                 if(e.getMessage().length()>255)
                        SL.Exception_Message__c = e.getMessage().subString(0,255);
                    else
                        SL.Exception_Message__c = e.getMessage();
                 SL.Status__c = 'Failed';
                 Update SL;
                 If(!Test.isRunningTest())
                 System.abortJob(BatchJobId);
             }
         return fileDataLst;
     }
}