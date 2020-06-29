global class UpsertTasks {
    
    static Map<String, Holiday> holidayMap = new Map<String, Holiday>();
    static Boolean mapConstructed = False;
    
    @InvocableMethod(label='Upsert Task')
    global static List<UpsertTaskResponse> upsertTask(List<UpsertTaskRequest> request ){
         
         if (mapConstructed == False) {
         
             holidayMap = Holidays.getHolidaysMap(); 
             mapConstructed = True;
        }
        
        List<Task> taskInsertList = new List<task>(); 
        
        for(UpsertTaskRequest tr: request){
           
          Date activityDate = tr.activityDate; 
            
          activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        
          Task t = new Task(); 
        
          t.subject = tr.subject; 
        
          t.ActivityDate = activityDate; 
        
          t.Unique_Identifier__c = tr.uniqueIdentifier;
         
          t.nu_dse__Communication_Template__c = tr.templateId;
        
          t.Status = tr.status;
            
          t.WhatId = tr.parentId;
            
          t.nu_dse__Is_System_Task__c = true; 
              
          taskInsertList.add(t); 
            
        }
       
        List<UpsertTaskResponse>  response = new List<UpsertTaskResponse>(); 
        
        
        try{
            
            upsert taskInsertList Unique_Identifier__c; 
              
            for(task t: taskInsertList){
                UpsertTaskResponse tresponse =  new UpsertTaskResponse();
                tresponse.Id = t.Id; 
                response.add(tresponse);
            }
        }catch(Exception e){
            
            UpsertTaskResponse tresponse =  new UpsertTaskResponse();
            tresponse.error = 'Insert Failed';
            response.add(tresponse);
            System.debug('insert failed');
        }
        
        
        return response; 
    }

    
     global class UpsertTaskRequest {
        
       @InvocableVariable(required=true)
       global String uniqueIdentifier;
       @InvocableVariable//(required=true)
       global Id templateId;
       @InvocableVariable
       global String templateName;
       @InvocableVariable(required=true)
       global String subject; 
       @InvocableVariable(required=true) 
       global Date activityDate;
       @InvocableVariable(required=true) 
       global Id parentId; 
       @InvocableVariable
       global String status; 
        
        


    } 
    
    global class  UpsertTaskResponse{
        
        @InvocableVariable
        global String Id; 
         @InvocableVariable
        global String error; 
        
    }
    
}