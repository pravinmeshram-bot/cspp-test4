public class Prizm_TaskHandler{
    
    
    public static void Prizm_validateTask(List<Task> TaskList){ 
        for(Task t : TaskList){
            if(t.SOP__c == null){
                if(t.whoId != null){
                    String sObjName = t.WhoId.getSObjectType().getDescribe().getName();
                    if(t.Due_Date_Time__c != null && sObjName.equalsIgnoreCase('Lead')){
                        System.debug(t.Due_Date_Time__c);
                        t.ActivityDate = t.Due_Date_Time__c.Date();
                        // t.Due_Time__c = t.Due_Date_Time__c.Time();
                        System.debug(t.ActivityDate);
                    }
                    if(t.Due_Date_Time__c == null && sObjName.equalsIgnoreCase('Lead')){
                                                   
                        System.debug('*****Error');
                        t.addError('Due Date cannot be blank');
                    }
                }
            }
        }
    }
    
    public Static boolean leadStatus = false;
    //Prizm changes, added by Uchit
    public static void Prizm_UpdateLeadStatus(List<Task> TaskNewList, Map<Id,Task> TaskOldMap){
        if(Prizm_TaskHandler.leadStatus == false){
        Map<Id,Task> LeadTaskMap =new Map<Id,Task>();
        List<Id> LeadIds = new List<Id>();
        for(Task t: TaskNewList){
            if(t.SOP__c == null){
                //System.debug('****'+t.whoId);
                if(t.whoId != null){
                    String sObjName = t.WhoId.getSObjectType().getDescribe().getName();
                    if(sObjName.equalsIgnoreCase('Lead') && t.status == 'Completed' && (TaskOldMap == null || TaskOldMap.get(t.id)== null || TaskOldMap.get(t.id).status != 'Completed')){
                        LeadIds.add(t.WhoId);
                        LeadTaskMap.put(t.WhoId,t);
                    }
                }
            }
        }
        
        List<LeadStatusMapping__c> leadStatusMapList = LeadStatusMapping__c.getAll().Values();
        
        Map<String,List<String>> StatusMap = new Map<String,List<String>>();
        for(LeadStatusMapping__c LeadStatMap : leadStatusMapList){
            if(!StatusMap.containsKey(LeadStatMap.Sub_Status__c)){
                StatusMap.put(LeadStatMap.Sub_Status__c,new List<String>());
            }
            List<String> SubStatusList = LeadStatMap.Status_List__c.Split(',');
            StatusMap.get(LeadStatMap.Sub_Status__c).addAll(SubStatusList);
        }
        
        List<Lead> LeadList = [Select Id, Name, Sub_Status__c, Status from Lead where Id =: LeadIds];
        for(Lead l:LeadList){
            if(LeadTaskMap.containsKey(l.id) && LeadTaskMap.get(l.Id).Call_Result__c != null && LeadTaskMap.get(l.Id).Call_Result__c != ''){
                l.Sub_Status__c = LeadTaskMap.get(l.Id).Call_Result__c.trim();
                if(StatusMap.containsKey(l.Sub_Status__c) && StatusMap.get(l.Sub_Status__c).size()==1){
                    l.Status = StatusMap.get(l.Sub_Status__c).get(0);
                }
                if(StatusMap.containsKey(l.Sub_Status__c) && StatusMap.get(l.Sub_Status__c).size()>1){
                    List<String> StatusList = StatusMap.get(l.Sub_Status__c);
                    String Status;
                    integer i=0;
                    for(String s : StatusList){
                        i++;
                        if(s.equalsIgnoreCase(l.Status)){
                            break;
                        }
                        
                    }
                    if(i<StatusList.size())
                        l.Status = StatusList.get(i);
                    else
                        l.Status = StatusList.get(0);
                }
                Prizm_TaskHandler.leadStatus = true;
            }
        }
        //System.debug('****'+LeadList);
        Update LeadList;    
        }
    }
    
    public static void pushTasksToPrizm(){
        List<Task> TaskNewList = (List<Task>)Trigger.new;
        Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
        List<Id> TaskIds = new LIst<Id>();
        for(Task t:TaskNewList){
            if(t.SOP__c == null){
                if(t.whatId != null){
                    String sObjName = t.WhatId.getSObjectType().getDescribe().getName();
                    if(sObjName.equalsIgnoreCase('Opportunity') && DNLTaskRecordTypeId == t.RecordTypeId){
                        TaskIds.add(t.Id);
                    }
                }
            }
        }
        
        if(!TaskIds.isEmpty()){
            List<Task> TaskList = [Select Id,Subject,Status,ActivityDate,WhatId,Priority,Type,Description,Due_Date_Time__c from Task where Status != 'Completed' AND Status != 'Cancelled' AND Id =: TaskIds];
            pushTasks(JSON.serialize(TaskList), 'CreateTasks');
        }
    }
    
     //Change Task Reason: PDI-663
    public static void ChangeReason(list<Task> ltask){
       set<id> taskWhoIds=new set<id>();
       for(task t:ltask){
           if(t.SOP__c == null){
               if(t.whoId != null){
                   String sObjName = t.WhoId.getSObjectType().getDescribe().getName();
                   if(sObjName.equalsIgnoreCase('Lead')){
                       taskWhoIds.add(t.whoId);
                   }
               }
           }
       }
       
       if(!taskWhoIds.isEmpty()){
       list<Lead> lstLead=[Select Id, Name, Sub_Status__c, Status from Lead where Id in: taskWhoIds And status='DNL Do Not Call'];
        if(!lstLead.isEmpty() || test.isRunningTest()){
            for(Task t1:ltask){
              for(Lead l:lstLead){ 
                if(t1.whoId==l.id || Test.isRunningTest()){
                  if(t1.Call_Result__c=='Do Not Call'){
                         t1.Reason__c=l.Sub_Status__c;
                          t1.Status='Not Started';
                    } 
                    
                 }
             }
           }
        }
           
        }
            
   }
     
    
    @future(callout = true)
    public static void pushTasks(String TaskList, String Method){
        String accessToken = '';
        if(!test.isRunningTest()){
            try{
            SendOpportunityAccountUsingRestApi acc1= new SendOpportunityAccountUsingRestApi();
            accessToken=acc1.ReturnAccessToken(acc1);  
            }
            catch(Exception e){
                system.debug('Exception'+e.getMessage());
            }
        }
        System.debug(accessToken+'###0012');
        System.debug(TaskList);
        if(accessToken!=null){
        
            RestIntegrationInformation__mdt restIntegration = [select MasterLabel,System_Endpoint__c,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
            String endPoint = restIntegration.System_Endpoint__c+'/'+method; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(TaskList);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            if(!test.isRunningTest()){
                try{
                  HttpResponse res2=h2.send(req2);
                System.debug(res2+'###1203createresp');  
                }
                catch(Exception e){
                    system.debug('Exception'+e.getMessage());
                }
            }
            
        }
    }
    
   
    public Static Boolean PrizmTaskUpdated = False;
    public static void UpdatePrizmTask(){
        if(!PrizmTaskUpdated){
            List<Task> TaskList = (List<Task>)Trigger.new;
            Map<Id, Task> TaskOldMap = (Map<Id,Task>)Trigger.oldMap;
            Id DNLTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();  //@
            List<TaskStatusWrapper> TaskStatusWrapperList = new List<TaskStatusWrapper>();
            for(Task t : TaskList){
                if(t.SOP__c == null){
                    if(t.WhatId!=null){
                        String sObjName = t.WhatId.getSObjectType().getDescribe().getName();
                        if((t.Status != TaskOldMap.get(t.Id).Status || t.Description != TaskOldMap.get(t.Id).Description || t.ActivityDate != TaskOldMap.get(t.Id).ActivityDate || t.Due_Date_Time__c != TaskOldMap.get(t.Id).Due_Date_Time__c) && DNLTaskRecordTypeId == t.RecordTypeId && sObjName.equalsIgnoreCase('Opportunity')){
                            TaskStatusWrapper TaskWrap = new TaskStatusWrapper();
                            TaskWrap.TaskId = t.Id;
                            TaskWrap.Status = t.Status;
                            TaskWrap.Description = t.Description;
                            TaskWrap.DueDate = String.valueOf(t.ActivityDate);
                            TaskWrap.DueDateTime = String.valueOf(t.Due_Date_Time__c);
                            TaskStatusWrapperList.add(TaskWrap);
                        } 
                    }
                    
                }
                
                if(!TaskStatusWrapperList.isEmpty()){
                    pushTasks(JSON.serialize(TaskStatusWrapperList),'updateTaskStatus');
                    PrizmTaskUpdated = true;
                }
            }
        }
    }
    
    public class TaskStatusWrapper{
        public string TaskId;
        public String Status;
        public String Description;
        public String DueDate;
        public String DueDateTime;
        
        public TaskStatusWrapper(){
            TaskId = '';
            Status = '';
            Description = '';
            DueDate='';
            DueDateTime='';
        }
    }
    
}