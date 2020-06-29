public without sharing class Attorney_CreateOrUpdateNDSTaskHandler{
    
    public static void UpdateAttorneyFlag(List<Task> TaskList, Boolean isInsert, Map<Id, Task> OldTasks){
        
        List<Id> programIds = new List<Id>();
        List<Id> OfferIds = new List<Id>();
        for(Task t : TaskList){
            if(t.Subject == 'Versara Graduation (Prizm)'){
                if(t.WhatId != null){
                    //System.debug('***WhatId'+t.WhatId);
                    String objType = t.WhatId.getSObjectType().getDescribe().getName();
                    //System.debug('***objType'+objType);
                    if(objType.equalsIgnoreCase('nu_dse__Offer__c')){
                        /*t.Subject__c = 'Program Graduation';
                        t.Department__c = 'Negotiations';*/
                        OfferIds.add(t.WhatId);
                    }
                }
            }
            if(t.SOP__c == null){
                if(t.WhatId != null){
                    //System.debug('***WhatId'+t.WhatId);
                    String objType = t.WhatId.getSObjectType().getDescribe().getName();
                    //System.debug('***objType'+objType);
                    if(objType.equalsIgnoreCase('nu_dse__Program__c')){
                        ProgramIds.add(t.WhatId);
                        //System.debug('***ProgramId' + t.WhatId);
                    }
                }
            }
        }
        
        if(!OfferIds.isEmpty()){
            Map<Id, nu_dse__Offer__c> OfferMap = new Map<Id,nu_dse__Offer__c>([Select Id, nu_dse__Program__c from nu_dse__Offer__c where Id=: offerIds]);
            for(Task t : TaskList){
                if(t.Subject == 'Versara Graduation (Prizm)'){
                    if(t.WhatId != null){
                        String objType = t.WhatId.getSObjectType().getDescribe().getName();
                        if(objType.equalsIgnoreCase('nu_dse__Offer__c')){
                            t.Offer__c = t.WhatId;
                            t.WhatId = OfferMap.get(t.Offer__c).nu_dse__Program__c;
                            t.Subject__c = 'Program Graduation';
                            t.Department__c = 'Negotiations';
                        }
                    }
                }
            }
        }
        
        if(!ProgramIds.isEmpty()){
        Map<Id,nu_dse__Program__c> ProgramMap = new Map<Id,nu_dse__Program__c>([Select Id, Attorney__c from nu_dse__Program__c where Id =: ProgramIds and attorney__c = true]);
        
        List<Task> AttorneyTaskList = new List<Task>();
        List<String> UserNames = new List<String>();
        for(Task t:taskList){
            if(t.SOP__c == null){
                if(ProgramMap.containsKey(t.WhatId) && ProgramMap.get(t.WhatId).Attorney__c){
                    t.Attorney__c = True;
                    //System.debug('***Attorney');
                    if(t.UserName__c != null && t.UserName__c != '' && t.Isnote__c == False  && t.nu_dse__Is_Noted__c == False && Attorney_StaticVariableUtility.apiuser == true){
                        AttorneyTaskList.add(t);
                        UserNames.add(t.UserName__c);
                    }
                    //      Attorney_StaticVariableUtility.isTaskBeforeExecuted = true;
                }
            }
            //Change made by Vaibhav for stories NMI-442 and NMI-263
            
            if(t.NDS_Assigned__c != null && t.isNote__c && !t.NDS_Assigned__c.equalsIgnoreCase('dev_team') && t.NDS_Notes_Created_By__c == null){
                UserNames.add(t.NDS_Assigned__c);
                //System.debug('****NDS created by changed');
            }
            //Commented by Rajesh to stop pushing Task and Group Task and related functionalities NMI-882
 /*           if(!isInsert && OldTasks.containsKey(t.id) && t.Attorney__c == true && t.IsNote__C == False  && t.nu_dse__Is_Noted__c == False  && Attorney_StaticVariableUtility.apiuser == true){
                if(t.Completed_Date__c == null && OldTasks.get(t.id).Completed_Date__c != null){
                    t.Completed_Date__c = OldTasks.get(t.id).Completed_Date__c;
                }
            } */
        }
        
        List<NDS_User_List__c> NDSUserList = [Select Id, Email__c, User_Name__c from NDS_User_List__c where User_Name__c =: UserNames];
        
        List<String> EmailIds = new List<String>();
        Map<String, NDS_User_List__c> NDSUserNameMap = new Map<String,NDS_User_List__c>(); 
        
        for(NDS_User_List__c NDSUser : NDSUserList){
            EmailIds.add(NDSUser.Email__c);
            String UatEmail = String.valueOf(NDSUser.Email__c).replace('@','=')+'@example.com';
            EmailIds.add(UatEmail);
            NDSUserNameMap.put(NDSUser.User_Name__c.ToLowerCase(),NDSUser);
        }
        
        User DataIntegrationUser = new User();
        
        List<User> UserList = [Select Id, Email, Name from User where (Email =: EmailIds OR Name = 'Data Integration User') and isactive = True];
        Map<String,User> UserEmailMap = new Map<String,User>();
        For(User u : UserList){
            if(u.Email != null){
                UserEmailMap.put(u.Email.toLowerCase(), u);
            }
            if(u.Name == 'Data Integration User'){
                DataIntegrationUser = u;
            }
        }
        //Commented by Rajesh to stop pushing Task and Group Task and related functionalities NMI-882
        
 /*       For(Task t : AttorneyTaskList){
            if(NDSUserNameMap.containsKey(t.UserName__c.ToLowerCase()) && NDSUserNameMap.get(t.UserName__c.ToLowerCase()).Email__c != null){
                String UatEmail = String.valueOf(NDSUserNameMap.get(t.UserName__c.ToLowerCase()).Email__c).replace('@','=')+'@example.com';
                if(UserEmailMap.containsKey(UatEmail))    
                    t.OwnerId = UserEmailMap.get(UatEmail).id;
                else if(UserEmailMap.containsKey(NDSUserNameMap.get(t.UserName__c.ToLowerCase()).Email__c))
                    t.ownerId = UserEmailMap.get(NDSUserNameMap.get(t.UserName__c.ToLowerCase()).Email__c).id;
            }
        }*/
        
        //Change made by Vaibhav for stories NMI-442 and NMI-263
        
        //User DataIntegrationUser = [Select Id from User where name='Data Integration User'];
        //System.debug('****'+DataIntegrationUser.Id);
        //System.debug('*****'+NDSUserNameMap);
        //System.debug('*****'+UserEmailMap);
        for(Task t : TaskList){
            if(t.SOP__c == null){
                //System.debug('**** Update Task Created By loop');
                if(t.NDS_Notes_Created_By__c == null && t.CreatedById != DataIntegrationUser.Id && t.nu_dse__Is_Noted__c &&  ProgramMap.containsKey(t.WhatId) && ProgramMap.get(t.WhatId).Attorney__c){
                    //System.debug('****NOt Created by Data integration');
                    t.NDS_Notes_Created_By__c = t.CreatedById;
                }
                if(t.NDS_Assigned__c != null && t.NDS_Notes_Created_By__c == null && t.Attorney__c && t.isNote__c){
                    //System.debug('*****NDS Task Note');
                    if(NDSUserNameMap.containsKey(t.NDS_Assigned__c.toLowerCase()) && NDSUserNameMap.get(t.NDS_Assigned__c.toLowerCase()).Email__c != null && UserEmailMap.containsKey(NDSUserNameMap.get(t.NDS_Assigned__c.toLowerCase()).Email__c.toLowerCase())){
                        //System.debug('*****NDS Task Note Matched');
                        t.NDS_Notes_Created_By__c= UserEmailMap.get(NDSUserNameMap.get(t.NDS_Assigned__c.toLowerCase()).Email__c.toLowerCase()).id;
                    }
                }
                //System.debug('****'+t.NDS_Notes_Created_By__c);
            }
        }
      Attorney_StaticVariableUtility.isTaskBeforeExecuted = true;  
      }
    }
    
    //Commented by Rajesh to stop pushing Task and Group Task and related functionalities NMI-882
    
 /*   public static void CreateOrUpdateNDSTask(List<Task> ObjTaskList, Map<Id,Task> ObjTaskOldMap){
        
        Boolean IsInsert = false;
        List<Task> updateTask = new List<Task>();
         Set<Id> processingTaskIds = new Set<Id>();
        
        Set<string> reProcessErrorMessage = Attorney_StaticVariableUtility.reProcessConfigs('Group_Task',false);
        
        //Collect Program Task
        String Program_prefix = Schema.SObjectType.nu_dse__Program__c.getKeyPrefix();
        List<Task> programTaskList = new List<Task>();
        Set<Id> programWhatIds = new Set<Id>();
        for(Task ObjTask: ObjTaskList){
            if(ObjTask.WhatId != null && ((String)ObjTask.WhatId).startsWith(Program_prefix)){
                programTaskList.add(ObjTask);
                programWhatIds.add(ObjTask.WhatId);
            }
        }
        
        //Query Program with collected WhatId
        Map<Id,nu_dse__Program__c>  progamMap = new  Map<Id,nu_dse__Program__c>();
        for(nu_dse__Program__c p : [Select Id,Import_Id__c,Attorney__c,Test_Program__c from nu_dse__Program__c where Import_Id__c!=null and Id IN:programWhatIds])
            progamMap.put(p.Id,p);


        for(Task ObjTask: programTaskList){
            if(progamMap.containsKey(ObjTask.WhatId) == true && ObjTask.IsNote__c == False  && ObjTask.nu_dse__Is_Noted__c == False  && ObjTask.Attorney__c == True //progamMap.get(ObjTask.WhatId).Attorney__c == true  
                && Attorney_StaticVariableUtility.apiuser == false && ObjTask.nu_dse__Is_System_Task__c == False)
            {
                if(ObjTask.Task_Id__c == null)
                    IsInsert = true;
                else
                    IsInsert = false;
                
                Boolean IsRelatedRecordEligibleForPick = (progamMap.get(ObjTask.WhatId).Import_Id__c != null && ObjTask.Subject__C != '' && ObjTask.Subject__C != NULL && progamMap.get(ObjTask.WhatId).Test_Program__c == False) ? true : false;
                
                if((IsInsert == false && IsRelatedRecordEligibleForPick == true && ObjTask.Subject__C != '' && ObjTask.Subject__C != NULL  &&
                    (ObjTask.Task_Id__c !=ObjTaskOldMap.get(ObjTask.Id).Task_Id__c
                     || ObjTask.ActivityDate !=ObjTaskOldMap.get(ObjTask.Id).ActivityDate
                     || ObjTask.WhatId !=ObjTaskOldMap.get(ObjTask.Id).WhatId
                     || ObjTask.Subject !=ObjTaskOldMap.get(ObjTask.Id).Subject
                     || ObjTask.Description !=ObjTaskOldMap.get(ObjTask.Id).Description
                                         || ObjTask.Completed_date__C!=ObjTaskOldMap.get(ObjTask.Id).Completed_date__c
 
                     || ObjTask.Subject__c !=ObjTaskOldMap.get(ObjTask.Id).Subject__c
                     || ObjTask.Priority !=ObjTaskOldMap.get(ObjTask.Id).Priority
                     || ObjTask.OwnerId != ObjTaskOldMap.get(ObjTask.Id).OwnerId))
                     || (IsInsert==true && IsRelatedRecordEligibleForPick == true)//condition 2
                   || (ObjTask.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(ObjTask.Integration_Reason__c) 
                       && reProcessErrorMessage.size() > 0  && IsRelatedRecordEligibleForPick==true
                       && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjTask.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjTask.Integration_Reason_2__c)))//condition 3
                   || (IsInsert==true && string.isBlank(ObjTask.Integration_Status__c) && IsRelatedRecordEligibleForPick==true))//condition 4
                {
                    System.debug('+++++ IsInsert' + IsInsert);
                    processingTaskIds.add(ObjTask.Id);
                   
                } 
            }
        }
        
        System.debug('+++++++++++++++++++++ getCallouts ' + Limits.getCallouts());
        System.debug('+++++++++++++++++++++ getLimitCallouts() ' + Limits.getLimitCallouts());
        
        Boolean IsOverFlow; 
        if(processingTaskIds.size() < Limits.getLimitCallouts() - Limits.getCallouts())
            IsOverFlow = false; //Less than 100 Records
        else
            IsOverFlow = true; //More than 100 Records
        
        for(Id objTaskId: processingTaskIds){
            Task objTaskUpd = new Task(Id=objTaskId);
            if(IsOverFlow == false)
                setIntegrationFields(objTaskUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null); 
            if(IsOverFlow == true)
                setIntegrationFields(objTaskUpd,Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW,null);
            updateTask.add(objTaskUpd);
        }
        
        
        if(processingTaskIds.size() > 0 && IsOverFlow == false)
        {
            System.debug('****test enque job');
            System.enqueueJob(new AsynCallToNDSTask(processingTaskIds,progamMap));
        }
        System.debug('****test update task ');
        update updateTask;
    } */
    
    public static void setIntegrationFields(Task ObjTask,string IntegrationStatus,string IntegrationReason){
         string Reason1 = null;
         string Reason2 = null;
        
        if(string.isNotBlank(IntegrationReason))
        {
            if(IntegrationReason.length() <= 250)
            {
                Reason1 = IntegrationReason.subString(0,IntegrationReason.length());
            }
            else if(IntegrationReason.length() > 250)
            {
                Reason1 = IntegrationReason.subString(0,250);
                
                if(IntegrationReason.length() > 500)
                     Reason2 = IntegrationReason.subString(250,500);
                else
                     Reason2 = IntegrationReason.subString(250,IntegrationReason.length());
            }     
        }
        
        
        ObjTask.Integration_Status__c = IntegrationStatus;
        ObjTask.Integration_Reason__c = Reason1;
        ObjTask.Integration_Reason_2__c = Reason2;
    }
    
/*    public class AsynCallToNDSTask implements Queueable,Database.AllowsCallouts {
        
        Set<Id> TaskIds;
        Map<Id,nu_dse__Program__c>  progamMap;
        public AsynCallToNDSTask(Set<Id> cTaskIds, Map<Id,nu_dse__Program__c> cProgamMap)
        {
            this.TaskIds = cTaskIds;
            this.ProgamMap = cProgamMap;
        }
        
        public void execute(QueueableContext context) {
            
            List<Task> updateObjTaskList = new List<Task>();
            System.debug('****taskIds'+taskIds);
            for(Task ObjTask : [Select Task_Id__c,Integration_Status__c,WhatId,Integration_Reason__c,ActivityDate,Subject,Description,OwnerId,Owner.Name,Owner.Email,
                                TaskTypeId__c,CreatedDate,LastModifiedDate,Priority,Subject__c, completed_date__c from Task where id=:TaskIds])
            {
                
                
                try
                {
                    LeadtracNetClient.ClientServiceSoap soap = new LeadtracNetClient.ClientServiceSoap();
                    LeadtracNetClient.ArrayOfTask arrayOfTask = doTaskMapping(ObjTask,progamMap.get(ObjTask.WhatId).Import_Id__c);
                    
                    System.debug('++++++++++++ arrayOfTask' + arrayOfTask);
                    
                    LeadtracNetClient.UpdateTasksResult updateTaskResult = new LeadtracNetClient.UpdateTasksResult();
                    System.debug('***'+Attorney_StaticVariableUtility.credentials.UserName__c);
                    
                    updateTaskResult = soap.CreateOrUpdateTask(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c, arrayOfTask);
                    
                    
                    System.debug('++++++++++++++++++++++updateTaskResult ' + updateTaskResult);
                    
                    if(updateTaskResult.IsSuccessful == true)
                    {
                        
                        LeadtracNetClient.ArrayOfTaskResult Tasks = updateTaskResult.Tasks;
                        List<LeadtracNetClient.TaskResult> resultMessage = Tasks.TaskResult;
                        
                        if(resultMessage[0].IsSuccessful == true)
                        {
                            
                            if(ObjTask.Task_Id__c == null)
                            {
                                LeadtracNetClient.Task iTask = resultMessage[0].Task;
                                ObjTask.Task_Id__c = string.valueof(iTask.TaskId);
                            }
                            
                            setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                        }
                        else
                        {
                            LeadtracNetClient.ArrayOfResultMessage arrayResultMessage = resultMessage[0].Messages;
                            List<LeadtracNetClient.ResultMessage> resultMessageInner = arrayResultMessage.ResultMessage;
                            setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessageInner[0].Message);
                            
                        }
                    }
                    else
                    {
                        LeadtracNetClient.ArrayOfResultMessage arrayResultMessage = updateTaskResult.Messages;
                        List<LeadtracNetClient.ResultMessage> resultMessageOuter = arrayResultMessage.ResultMessage;
                        setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessageOuter[0].Message);
                    }
                }
                catch(Exception e)
                {
                    System.debug('***'+ e.getStackTraceString());
                    setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                         Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                         Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                }
                
                 updateObjTaskList.add(ObjTask);
            }
            
            Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
            update updateObjTaskList;
            
        }
    } 
    
    public static LeadtracNetClient.ArrayOfTask doTaskMapping(Task ObjTask,string ProgramImportId){
        
        LeadtracNetClient.ArrayOfTask arrayOfTask = new LeadtracNetClient.ArrayOfTask();

        List<LeadtracNetClient.Task> tsk= new List<LeadtracNetClient.Task>();
        
        LeadtracNetClient.Task t = new LeadtracNetClient.Task();
        t.FileNumber = ProgramImportId;
        t.TaskId =  (ObjTask.Task_Id__c == null) ? 0 : Long.ValueOf(ObjTask.Task_Id__c);
        
        t.ScheduledOnUTC = (ObjTask.ActivityDate == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : Attorney_StaticVariableUtility.dateToUTC(ObjTask.ActivityDate);
        
        t.Subject = ObjTask.Subject;
        t.Description = ObjTask.Description;
        
        if(string.valueOf(ObjTask.OwnerId).startsWith('005'))
        {
            t.AssignedAs = 'User';
            //t.AssignedTo = ObjTask.Owner.Name;
            String validEmail = '';
            if(ObjTask.Owner.Email != null && ObjTask.Owner.Email.contains('@example.com')){
                validEmail = ObjTask.Owner.Email.remove('@example.com');  
                validEmail = validEmail.replace('=','@');
            }else
                validEmail = ObjTask.Owner.Email;
            if(validEmail != NULL && validEmail != ''){
               List<NDS_User_List__c> NDSUsrLst = [Select Id,User_Name__c,Email__c from NDS_User_List__c where Email__c =: validEmail];       
               if(!NDSUsrLst.isEmpty())
                   t.AssignedTo = NDSUsrLst[0].User_Name__c;
            }
        }
        
        if(string.valueOf(ObjTask.OwnerId).startsWith('00G'))
        {
            t.AssignedAs = 'Group';
         //   t.AssignedTo = '';
        }
        
        if(string.isNotBlank(ObjTask.Subject__c))
        {
            List<nu_dse_Task_Type__c> objTaskType = [Select TaskTypeId__c,TaskName__c from nu_dse_Task_Type__c where TaskName__c=:ObjTask.Subject__c Limit 1];
            
            if(objTaskType != null && objTaskType.size() > 0)
            {
                LeadtracNetClient.TaskType tType = new LeadtracNetClient.TaskType();
                tType.TaskTypeId = Long.valueOf(objTaskType[0].TaskTypeId__c);
                tType.Name = objTaskType[0].TaskName__c;
                if(ObjTask.Priority != null && ObjTask.Priority != '' && string.valueOf(ObjTask.Priority) == 'Normal')
                {
                tType.Priority = 'Medium';
                }
                
               else
               {
                tType.Priority = string.valueOf(ObjTask.Priority);

               }
                tType.UserAssignmentRequired = 'true';
                t.TaskType = tType;
            }
        }
        
        else if(string.isBlank(ObjTask.Subject__c) && string.isNotBlank(ObjTask.Subject))
        {
            List<nu_dse_Task_Type__c> objTaskType = [Select TaskTypeId__c,TaskName__c from nu_dse_Task_Type__c where TaskName__c=:ObjTask.Subject Limit 1];
            
            if(objTaskType != null && objTaskType.size() > 0)
            {
                LeadtracNetClient.TaskType tType = new LeadtracNetClient.TaskType();
                tType.TaskTypeId = Long.valueOf(objTaskType[0].TaskTypeId__c);
                tType.Name = objTaskType[0].TaskName__c;
                if(ObjTask.Priority != null && ObjTask.Priority != '' && string.valueOf(ObjTask.Priority) == 'Normal')
                {
                tType.Priority = 'Medium';
                }
                
               else
               {
                tType.Priority = string.valueOf(ObjTask.Priority);

               }
                tType.UserAssignmentRequired = 'true';
                t.TaskType = tType;
            }
        }
        
        else
        {
        }
        
        t.RemindMinutesBefore = 0;
        t.CompletedOn = (ObjTask.completed_date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : ObjTask.completed_date__c;
        t.CreatedOn = ObjTask.CreatedDate;
        t.ModifiedOn = ObjTask.LastModifiedDate;
        
        tsk.add(t);
        arrayOfTask.Task = tsk;
        
        return arrayOfTask;
    } */
    
    public static void CreateNDSAddLogEntry(List<Task> ObjTaskList, Map<Id,Task> ObjTaskOldMap){
        Boolean IsInsert = false;
        List<Task> updateTask = new List<Task>();
        Set<Id> processingTaskIds = new Set<Id>();
        
        Set<string> reProcessErrorMessage = Attorney_StaticVariableUtility.reProcessConfigs('Group_Task',false);
        
        //Collect Program Task
        String Program_prefix = Schema.SObjectType.nu_dse__Program__c.getKeyPrefix();
        List<Task> programTaskList = new List<Task>();
        Set<Id> programWhatIds = new Set<Id>();
        /* 
        Date : 25-04-2019  
        Description :Updated to query the task to check whether the task is deleted or not 
        */
        Set<Id> taskIds = new Set<Id>();
        
        for (Task ObjTask: ObjTaskList) {
            if(ObjTask.SOP__c == null){
                taskIds.add(ObjTask.Id);
            }
        }
        if(!taskIds.isEmpty()){
        for(Task ObjTask: [SELECT Id, WhatId, IsNote__c, Attorney__c, nu_dse__Is_Noted__c, Description, Notes_Id__c, Integration_Status__c, Integration_Reason__c, Integration_Reason_2__c  FROM TASK WHERE Id =: taskIds]) { //ObjTaskList) {
            if(ObjTask.WhatId != null && ((String)ObjTask.WhatId).startsWith(Program_prefix)){
                programTaskList.add(ObjTask);
                programWhatIds.add(ObjTask.WhatId);
            }
        }
        
        //Query Program with collected WhatId
        Map<Id,nu_dse__Program__c>  progamMap = new  Map<Id,nu_dse__Program__c>();
        for(nu_dse__Program__c p : [Select Id,Import_Id__c,Attorney__c,Test_Program__c from nu_dse__Program__c where Import_Id__c!=null and Id IN:programWhatIds])
            progamMap.put(p.Id,p);


        for(Task ObjTask: programTaskList){
            System.debug('*****ProgramMap'+progamMap.containsKey(ObjTask.WhatId));
            System.debug('*****isNote'+ObjTask.IsNote__c);
            System.debug('*****Attorney'+ObjTask.Attorney__c);
            System.Debug('*****Description'+ObjTask.Description);
            if(progamMap.containsKey(ObjTask.WhatId) == true && (ObjTask.IsNote__c == true  || ObjTask.nu_dse__Is_Noted__c == True)  && ObjTask.Attorney__c == true && ObjTask.Description != null
                && Attorney_StaticVariableUtility.apiuser == false && (ObjTask.Notes_Id__c  == null || ObjTask.Notes_Id__c == ''))
            {
                if(ObjTask.Notes_Id__c == null)
                    IsInsert = true;
                
                Boolean IsRelatedRecordEligibleForPick = (progamMap.get(ObjTask.WhatId).Import_Id__c != null && progamMap.get(ObjTask.WhatId).Test_Program__c == False) ? true : false;
                
                if((IsInsert==true && IsRelatedRecordEligibleForPick == true)//condition 1
                   || (IsInsert==true && ObjTask.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(ObjTask.Integration_Reason__c) 
                       && reProcessErrorMessage.size() > 0  && IsRelatedRecordEligibleForPick==true
                       && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjTask.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjTask.Integration_Reason_2__c)))//condition 2
                   || (IsInsert==true && string.isBlank(ObjTask.Integration_Status__c) && IsRelatedRecordEligibleForPick==true))//condition 3
                {
                    System.debug('+++++ IsInsert' + IsInsert);
                    processingTaskIds.add(ObjTask.Id);
                   
                } 
            }
        }
        
        System.debug('+++++++++++++++++++++ getCallouts ' + Limits.getCallouts());
        System.debug('+++++++++++++++++++++ getLimitCallouts() ' + Limits.getLimitCallouts());
        
        Boolean IsOverFlow; 
        if(processingTaskIds.size() < Limits.getLimitCallouts() - Limits.getCallouts())
            IsOverFlow = false; //Less than 100 Records
        else
            IsOverFlow = true; //More than 100 Records
        
        for(Id objTaskId: processingTaskIds){
            Task objTaskUpd = new Task(Id=objTaskId);
            if(IsOverFlow == false)
                setIntegrationFields(objTaskUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null); 
            if(IsOverFlow == true)
                setIntegrationFields(objTaskUpd,Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW,null);
            updateTask.add(objTaskUpd);
        }
        
        
        if(processingTaskIds.size() > 0 && IsOverFlow == false)
        {
            System.enqueueJob(new AsynCallToNDSAddLogEntryTask(processingTaskIds,progamMap));
        }
        
        update updateTask;
        
        }
    }
    
    public class AsynCallToNDSAddLogEntryTask implements Queueable,Database.AllowsCallouts {
        
        Set<Id> TaskIds;
        Map<Id,nu_dse__Program__c>  progamMap;
        public AsynCallToNDSAddLogEntryTask(Set<Id> cTaskIds, Map<Id,nu_dse__Program__c> cProgamMap)
        {
            this.TaskIds = cTaskIds;
            this.ProgamMap = cProgamMap;
        }
        
        public void execute(QueueableContext context) {
            
            List<Task> updateObjTaskList = new List<Task>();
            for(Task ObjTask : [Select IsNote__c, nu_dse__Is_Noted__c, nu_dse__Is_System_Task__c, Notes_Id__c,Description,Integration_Status__c,WhatId,Integration_Reason__c,CreatedDate,LastModifiedDate from Task where id=:TaskIds])
            { 
                try
                {
                    LeadtracNetClient.ClientServiceSoap soap = new LeadtracNetClient.ClientServiceSoap();
                    leadtracNetClient.LogEntry LogEntry = doAddLogMapping(ObjTask,progamMap.get(ObjTask.WhatId).Import_Id__c);
                    
                    System.debug('++++++++++++ LogEntry' + LogEntry);
                    
                    LeadtracNetClient.GetLogEntriesResult logEntryResult = new LeadtracNetClient.GetLogEntriesResult();
                    System.debug('***'+Attorney_StaticVariableUtility.credentials.UserName__c);
                    
                    logEntryResult = soap.AddLogEntry(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,progamMap.get(ObjTask.WhatId).Import_Id__c,LogEntry);
                    
                    System.debug('++++++++++++++++++++++logEntryResult ' + logEntryResult);
                    
                    if(logEntryResult.IsSuccessful == true)
                    {
                        LeadtracNetClient.ArrayOfLogEntry Entries = logEntryResult.Entries;
                        List<LeadtracNetClient.LogEntry> LogEntryList = Entries.LogEntry;
                        
                        if(ObjTask.Notes_Id__c == null)
                        {
                            ObjTask.Notes_Id__c = string.valueof(LogEntryList[0].Id);
                        }
                        
                        setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                    }
                    else
                    {
                        LeadtracNetClient.ArrayOfResultMessage arrayResultMessage = logEntryResult.Messages;
                        List<LeadtracNetClient.ResultMessage> resultMessageOuter = arrayResultMessage.ResultMessage;
                        setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessageOuter[0].Message);
                    }
                }
                catch(Exception e)
                {
                    System.debug('***'+ e.getStackTraceString());
                    System.debug('*****'+e.getMessage());
                    setIntegrationFields(ObjTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                         Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                         Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                }
                
                 updateObjTaskList.add(ObjTask);
            }
            
            Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
            update updateObjTaskList;
            
        }
    }
    
    public static LeadtracNetClient.LogEntry doAddLogMapping(Task ObjTask,string ProgramImportId){
        
        LeadtracNetClient.LogEntry logEntry = new LeadtracNetClient.LogEntry();
        logEntry.FileNumber = ProgramImportId;
        logEntry.DebtId = 0;
        logEntry.Id = 0;
        
        LeadtracNetClient.LogCategory c = new LeadtracNetClient.LogCategory();
        c.Category = 'General';
        c.CategoryId = 1;
        c.CategoryType = 'SYSTEM';
        logEntry.Category = c;
        
        logEntry.Entry = ObjTask.Description;
        logEntry.CreatedOn = ObjTask.CreatedDate;
        logEntry.ModifiedOn = ObjTask.LastModifiedDate;
       
        return logEntry;
    }
    
}