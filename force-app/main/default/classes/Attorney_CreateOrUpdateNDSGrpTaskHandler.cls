public without sharing class Attorney_CreateOrUpdateNDSGrpTaskHandler{
    
    public static void UpdateRefundTaskOwner(){
        List<nu_dse__Group_Task__c> GroupTaskList = (List<nu_dse__Group_Task__c>)Trigger.new;
        List<ID> ProgramIds = new List<Id>();
        for(nu_dse__Group_Task__c gt: GroupTaskList){
            if(gt.Program__c != null && gt.nu_dse__Subject__c != null && gt.nu_dse__Subject__c.contains('Refund')){
                ProgramIds.add(gt.Program__c);
            }
        }
        
        if(!ProgramIds.isEmpty()){
            Map<Id,nu_dse__Program__c> ProgramMap = new Map<Id,nu_dse__Program__c>([Select Id,DNL_Status__c from nu_dse__Program__c where Id=: ProgramIds AND DNL_Status__c = 'Pre-TILA Signed']);
            Group DNLPayments = [select Id from Group where DeveloperName = 'DNL_Payments_Queue' and Type = 'Queue'];
            for(nu_dse__Group_Task__c gt: GroupTaskList){
                if(gt.Program__c != null && gt.nu_dse__Subject__c != null && gt.nu_dse__Subject__c.contains('Refund') && ProgramMap.containsKey(gt.Program__c)){
                    gt.OwnerId = DNLPayments.Id;
                }
            }
        }
    }
    
    public static void UpdateTaskOwner(List<nu_dse__Group_Task__c> ObjGroupTaskList, Boolean isInsert, Map<Id, nu_dse__Group_Task__c> OldGroupTasks){
        List<Group> queueList = [Select Id,name from Group where type='Queue'];
        Map<String,Group> GroupMap = new Map<String,Group>();
        for(Group que:queueList)
        {
        
        GroupMap.put(que.Name,que);
        }
        for(nu_dse__Group_Task__c GroupTask : ObjGroupTaskList){
            if((isInsert && string.isNotBlank(GroupTask.UserName__c) && Attorney_StaticVariableUtility.apiuser == true && GroupMap.containsKey(GroupTask.UserName__c.trim())) || (!isInsert && string.isNotBlank(GroupTask.UserName__c) && UserInfo.getUserEmail() == Attorney_StaticVariableUtility.ModifyGTOwner  && GroupMap.containsKey(GroupTask.UserName__c.trim())))
            {
                GroupTask.ownerId = GroupMap.get(GroupTask.UserName__c.trim()).id;
            }
            
            if(!isInsert && OldGroupTasks.containsKey(GroupTask.id) && GroupTask.isAttorney__c == true && Attorney_StaticVariableUtility.apiuser == true){
                if(GroupTask.Completed_On__c == null && OldGroupTasks.get(GroupTask.id).Completed_On__c != null){
                    GroupTask.Completed_On__c = OldGroupTasks.get(GroupTask.id).Completed_On__c;
                }
            }
        }
    }
    
    public static void CreateOrUpdateNDSGrpTask(List<nu_dse__Group_Task__c> ObjGroupTaskList, Map<Id,nu_dse__Group_Task__c> ObjGroupTaskOldMap){
        Boolean IsInsert = false;
        List<nu_dse__Group_Task__c> updateGroupTask = new List<nu_dse__Group_Task__c>();
        Set<Id> processingGroupIds = new Set<Id>();
        
         Set<string> reProcessErrorMessage = Attorney_StaticVariableUtility.reProcessConfigs('Group_Task',false);
        /*List<nu_dse__Group_Task__c> ObjGroupTaskDbList = [select id,IsAttorney__c,Task_Id__c,IsRelatedRecordEligibleForPick__c
        ,nu_dse__ActivityDate__c,nu_dse__Subject__c,nu_dse__Description__c,Subject_Picklist__c,Priority__c,OwnerId,Owner.Email,
        Integration_Status__c,Integration_Reason__c,Integration_Reason_2__c from nu_dse__Group_Task__c where ID IN: ObjGroupTaskNewMap.keySet()];*/
        for(nu_dse__Group_Task__c ObjGroupTask: ObjGroupTaskList){
            
            if(ObjGroupTask.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false)
            {    
                if(ObjGroupTask.Task_Id__c == null)
                    IsInsert = true;
                else
                    IsInsert = false;
                
                System.debug('**** IsInsert' + IsInsert);
                System.debug('****RecordEligible'+ObjGroupTask.IsRelatedRecordEligibleForPick__c);
                if((IsInsert==false && ObjGroupTask.IsRelatedRecordEligibleForPick__c==true &&
                    (ObjGroupTask.Task_Id__c !=ObjGroupTaskOldMap.get(ObjGroupTask.Id).Task_Id__c
                     || ObjGroupTask.nu_dse__ActivityDate__c !=ObjGroupTaskOldMap.get(ObjGroupTask.Id).nu_dse__ActivityDate__c
                     || ObjGroupTask.nu_dse__Subject__c !=ObjGroupTaskOldMap.get(ObjGroupTask.Id).nu_dse__Subject__c
                     || ObjGroupTask.nu_dse__Description__c !=ObjGroupTaskOldMap.get(ObjGroupTask.Id).nu_dse__Description__c
                     || ObjGroupTask.Subject_Picklist__c !=ObjGroupTaskOldMap.get(ObjGroupTask.Id).Subject_Picklist__c
                     || ObjGroupTask.Priority__c !=ObjGroupTaskOldMap.get(ObjGroupTask.Id).Priority__c
                     || ObjGroupTask.Completed_on__c!=ObjGroupTaskOldMap.get(ObjGroupTask.Id).Completed_on__c

                     || ObjGroupTask.OwnerId != ObjGroupTaskOldMap.get(ObjGroupTask.Id).OwnerId))//condition 1
                     || (IsInsert==true && ObjGroupTask.IsRelatedRecordEligibleForPick__c==true)//condition 2
                   || (ObjGroupTask.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(ObjGroupTask.Integration_Reason__c) 
                       && reProcessErrorMessage.size() > 0  && ObjGroupTask.IsRelatedRecordEligibleForPick__c==true
                       && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjGroupTask.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,ObjGroupTask.Integration_Reason_2__c)))//condition 3
                   || (IsInsert==true && string.isBlank(ObjGroupTask.Integration_Status__c) && ObjGroupTask.IsRelatedRecordEligibleForPick__c==true))//condition 4
                {
                    System.debug('+++++ IsInsert' + IsInsert);
                    processingGroupIds.add(ObjGroupTask.Id);
                    
                } 
            }
        }
        
        System.debug('+++++++++++++++++++++ getCallouts ' + Limits.getCallouts());
        System.debug('+++++++++++++++++++++ getLimitCallouts() ' + Limits.getLimitCallouts());
        
        Boolean IsOverFlow; 
        if(processingGroupIds.size() < Limits.getLimitCallouts() - Limits.getCallouts())
            IsOverFlow = false; //Less than 100 Records
        else
            IsOverFlow = true; //More than 100 Records
        
        for(Id objGroupId: processingGroupIds){
            nu_dse__Group_Task__c objGroupUpd = new nu_dse__Group_Task__c(Id=objGroupId);
            if(IsOverFlow == false)
                setIntegrationFields(objGroupUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null); 
            if(IsOverFlow == true)
                setIntegrationFields(objGroupUpd,Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW,null);
            updateGroupTask.add(objGroupUpd);
        }
        
             
        if(processingGroupIds.size() > 0 && IsOverFlow == false)
        {
            System.enqueueJob(new AsynCallToNDSGroupTask(processingGroupIds));
        }
        
        update updateGroupTask;
    }
    
     public static void setIntegrationFields(nu_dse__Group_Task__c ObjGroupTask,string IntegrationStatus,string IntegrationReason)
    {
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
        
        
        ObjGroupTask.Integration_Status__c = IntegrationStatus;
        ObjGroupTask.Integration_Reason__c = Reason1;
        ObjGroupTask.Integration_Reason_2__c = Reason2;
    }
    
    public class AsynCallToNDSGroupTask implements Queueable,Database.AllowsCallouts {
        
        Set<Id> groupTaskIds;
        public AsynCallToNDSGroupTask(Set<Id> cGroupTaskIds)
        {
            this.groupTaskIds = cGroupTaskIds;
        }
        
        public void execute(QueueableContext context) {
            
            List<nu_dse__Group_Task__c> updateObjGroupTaskList = new List<nu_dse__Group_Task__c>();
            for(nu_dse__Group_Task__c ObjGroupTask : [Select Task_Id__c,Integration_Status__c,Integration_Reason__c,Program__r.Import_Id__c,owner.email,nu_dse__ActivityDate__c,nu_dse__Subject__c,nu_dse__Description__c,OwnerId,Owner.Name,
                                                      TaskTypeId__c,CreatedDate,LastModifiedDate,Priority__c,Subject_Picklist__c,Completed_On__c from nu_dse__Group_Task__c where id=:groupTaskIds])
            {
                
                try
                {
                    LeadtracNetClient.ClientServiceSoap soap = new LeadtracNetClient.ClientServiceSoap();
                    LeadtracNetClient.ArrayOfTask arrayOfTask = doGroupTaskMapping(ObjGroupTask);
                    
                    System.debug('++++++++++++ arrayOfTask' + arrayOfTask);
                    
                    LeadtracNetClient.UpdateTasksResult updateTaskResult = new LeadtracNetClient.UpdateTasksResult();
                    updateTaskResult = soap.CreateOrUpdateTask(Attorney_StaticVariableUtility.credentials.UserName__c, 
                                                               Attorney_StaticVariableUtility.credentials.Password__c,
                                                               arrayOfTask);
                    
                    
                    System.debug('++++++++++++++++++++++updateTaskResult ' + updateTaskResult);
                    
                    if(updateTaskResult.IsSuccessful == true)
                    {
                        
                        LeadtracNetClient.ArrayOfTaskResult Tasks = updateTaskResult.Tasks;
                        List<LeadtracNetClient.TaskResult> resultMessage = Tasks.TaskResult;
                        
                        if(resultMessage[0].IsSuccessful == true)
                        {
                            
                            if(ObjGroupTask.Task_Id__c == null)
                            {
                                LeadtracNetClient.Task iTask = resultMessage[0].Task;
                                ObjGroupTask.Task_Id__c = string.valueof(iTask.TaskId);
                            }
                            
                            setIntegrationFields(ObjGroupTask,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                        }
                        else
                        {
                            LeadtracNetClient.ArrayOfResultMessage arrayResultMessage = resultMessage[0].Messages;
                            List<LeadtracNetClient.ResultMessage> resultMessageInner = arrayResultMessage.ResultMessage;
                            setIntegrationFields(ObjGroupTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessageInner[0].Message);
                            
                        }
                    }
                    else
                    {
                        LeadtracNetClient.ArrayOfResultMessage arrayResultMessage = updateTaskResult.Messages;
                        List<LeadtracNetClient.ResultMessage> resultMessageOuter = arrayResultMessage.ResultMessage;
                        setIntegrationFields(ObjGroupTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessageOuter[0].Message);
                    }
                }
                catch(Exception e)
                {
                    setIntegrationFields(ObjGroupTask,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                         Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                         Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                }
                
                updateObjGroupTaskList.add(ObjGroupTask);
            }
            
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
            update updateObjGroupTaskList;
        }
    }
    
    public static LeadtracNetClient.ArrayOfTask doGroupTaskMapping(nu_dse__Group_Task__c objGroupTask)
    {
        
        LeadtracNetClient.ArrayOfTask arrayOfTask = new LeadtracNetClient.ArrayOfTask();

        List<LeadtracNetClient.Task> tsk= new List<LeadtracNetClient.Task>();
        
        LeadtracNetClient.Task t = new LeadtracNetClient.Task();
        t.FileNumber = objGroupTask.Program__r.Import_Id__c;
        t.TaskId =  (objGroupTask.Task_Id__c == null) ? 0 : Long.ValueOf(objGroupTask.Task_Id__c);
        
        t.ScheduledOnUTC = (objGroupTask.nu_dse__ActivityDate__c == null) ? 
                            Attorney_StaticVariableUtility.DEFAULTDATETIME : 
                            Attorney_StaticVariableUtility.dateToUTC(objGroupTask.nu_dse__ActivityDate__c);
        
        t.Subject = objGroupTask.nu_dse__Subject__c;
        t.Description = objGroupTask.nu_dse__Description__c;
        
        if(string.valueOf(objGroupTask.OwnerId).startsWith('005'))
        {
            t.AssignedAs = 'User';
            String validEmail = '';
            if(objGroupTask.owner.Email != null && objGroupTask.Owner.Email.contains('@example.com')){
                validEmail = objGroupTask.Owner.Email.remove('@example.com');  
                validEmail = validEmail.replace('=','@');
            }else
                validEmail = objGroupTask.Owner.Email;
            if(validEmail != NULL && validEmail != ''){
               List<NDS_User_List__c> NDSUsrLst = [Select Id,User_Name__c,Email__c from NDS_User_List__c where Email__c =: validEmail];       
               if(!NDSUsrLst.isEmpty())
                   t.AssignedTo = NDSUsrLst[0].User_Name__c;
            }
            //t.AssignedTo = objGroupTask.Owner.Name;
        }
        
        if(string.valueOf(objGroupTask.OwnerId).startsWith('00G'))
        {
            t.AssignedAs = 'Group';
        //    t.AssignedTo = '';
        }
        
        if(string.isNotBlank(objGroupTask.Subject_Picklist__c))
        {
            List<nu_dse_Task_Type__c> objTaskType = [Select TaskTypeId__c,TaskName__c from nu_dse_Task_Type__c where TaskName__c=:objGroupTask.Subject_Picklist__c Limit 1];
            
            if(objTaskType != null && objTaskType.size() > 0)
            {
                LeadtracNetClient.TaskType tType = new LeadtracNetClient.TaskType();
                tType.TaskTypeId = Long.valueOf(objTaskType[0].TaskTypeId__c);
                tType.Name = objTaskType[0].TaskName__c;
                tType.Priority = (objGroupTask.Priority__c == null || objGroupTask.Priority__c == '') ? 'Medium' : objGroupTask.Priority__c;
                //tType.Priority = string.valueOf(objGroupTask.Priority__c);
                tType.UserAssignmentRequired = 'true';
                t.TaskType = tType;
            }
        }
        
        else if(string.isNotBlank(objGroupTask.nu_dse__Subject__c) && string.isBlank(objGroupTask.Subject_Picklist__c))
        {
            List<nu_dse_Task_Type__c> objTaskType = [Select TaskTypeId__c,TaskName__c from nu_dse_Task_Type__c where TaskName__c=:objGroupTask.nu_dse__Subject__c Limit 1];
            
            if(objTaskType != null && objTaskType.size() > 0)
            {
                LeadtracNetClient.TaskType tType = new LeadtracNetClient.TaskType();
                tType.TaskTypeId = Long.valueOf(objTaskType[0].TaskTypeId__c);
                tType.Name = objTaskType[0].TaskName__c;
                tType.Priority = (objGroupTask.Priority__c == null || objGroupTask.Priority__c == '') ? 'Medium' : objGroupTask.Priority__c;
                //tType.Priority = string.valueOf(objGroupTask.Priority__c);
                tType.UserAssignmentRequired = 'true';
                t.TaskType = tType;
            }
        }
        
        else
        
        {
        
        }
        
        
        t.RemindMinutesBefore = 0;
        t.CompletedOn = (objGroupTask.Completed_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : objGroupTask.Completed_On__c;
        t.CreatedOn = objGroupTask.CreatedDate;
        t.ModifiedOn = objGroupTask.LastModifiedDate;
        
        tsk.add(t);
        arrayOfTask.Task = tsk;
        
        return arrayOfTask;
    }
    
}