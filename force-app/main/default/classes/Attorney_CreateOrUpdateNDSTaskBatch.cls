global class Attorney_CreateOrUpdateNDSTaskBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{
   

    global Database.QueryLocator start(Database.BatchableContext BC){
       Set<string> reProcessGrpTaskError = Attorney_StaticVariableUtility.reProcessConfigs('Group_Task',true);
        return Database.getQueryLocator([Select Id,WhatId,Attorney__c from Task where   nu_dse__Is_System_Task__c = False and IsNote__c = False and nu_dse__Is_Noted__c = False and (notes_id__C = null or notes_id__c = '') and Attorney__c = true and Subject__c != null and Subject__c != '' and Attorney__c = True and ((Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED
        and (Integration_Reason__c Like:reProcessGrpTaskError or Integration_Reason_2__c Like:reProcessGrpTaskError)) 
        or (Subject__c != null and Subject__c != '' and Attorney__c = True and Integration_Status__c = null and Task_Id__c = null)
        or Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW)]);
    }
    
    global void execute(Database.BatchableContext BC, List<Task> ObjTaskList){
        
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
        for(nu_dse__Program__c p : [Select Id,Import_Id__c,Attorney__c from nu_dse__Program__c where Import_Id__c!=null and Id IN:programWhatIds])
            progamMap.put(p.Id,p);
        
        
        List<Task> TaskUpdList = new List<Task>();
        for(Task ObjTask: programTaskList){
            
            if(progamMap.containsKey(ObjTask.WhatId) == true && ObjTask.Attorney__c // progamMap.get(ObjTask.WhatId).Attorney__c == true  
               && Attorney_StaticVariableUtility.apiuser == false)
            {
                TaskUpdList.add(ObjTask);
            }
        }
        update TaskUpdList;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}