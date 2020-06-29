global class CreateTask {

    
    @InvocableMethod(label='Create Task')
    global static List<CreateTaskResponse> invoke(List<CreateTaskRequest> request ){
        
         Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        
         holidayMap = Holidays.getHolidaysMap(); 
        
        List<Task> taskInsertList = new List<task>(); 
        
        for(CreateTaskRequest tr: request){
           
          Date activityDate = tr.activityDate; 
            
          activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        
          Task t = new Task(); 
        
          t.subject = tr.subject; 
        
          t.ActivityDate = activityDate; 
        
          t.Unique_Identifier__c = tr.uniqueIdentifier;
         
          t.nu_dse__Communication_Template__c = tr.templateId;
        
          t.nu_dse__Is_System_Task__c = true; 
            
          t.WhatId = tr.parentId;
            
          t.ownerId = tr.ownerId; 
            
          t.nu_dse__Is_Sticky_Note__c = tr.isStickyNote; 
              
          taskInsertList.add(t); 
            
        }
       
        List<CreateTaskResponse>  response = new List<CreateTaskResponse>(); 
        
        
        try{
            
            insert taskInsertList ; 
              
            for(task t: taskInsertList){
                CreateTaskResponse tresponse =  new CreateTaskResponse();
                tresponse.Id = t.Id; 
                response.add(tresponse);
            }
        }catch(Exception e){
            
            CreateTaskResponse tresponse =  new CreateTaskResponse();
            tresponse.error = 'Insert Failed';
            response.add(tresponse);
            System.debug('insert failed');
        }
        
        
        return response; 
    }

    global class CreateTaskRequest {
        
       @InvocableVariable(required=true)
       global String uniqueIdentifier;
       @InvocableVariable//(required=true) 
       global Id templateId;
       @InvocableVariable//(required=true)
       global String templateName;
       @InvocableVariable(required=true)
       global String subject; 
       @InvocableVariable(required=true) 
       global Date activityDate;
       @InvocableVariable(required=true) 
       global Id parentId; 
       @InvocableVariable
       global String status; 
       @InvocableVariable
       global Id ownerId = UserInfo.getUserId(); 
       @invocableVariable
       global boolean isStickyNote=false; 
        
        


    } 
    
    global class CreateTaskResponse{
        
        @InvocableVariable
        global String Id; 
         @InvocableVariable
        global String error; 
        
    }
}