global class UpdateTasks {

      
    @InvocableMethod(label='Update Task')

    global static List<UpdateTaskResponse> upsertTask(List<UpdateTaskRequest> request ){
        
         Map<String, Holiday> holidayMap = new Map<String, Holiday>();
        
         holidayMap = Holidays.getHolidaysMap(); 
        
        List<Task> taskInsertList = new List<task>(); 
        
        for(UpdateTaskRequest tr: request){
           
          Date activityDate = tr.activityDate; 
            
          activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        
          Task t = new Task(); 
            
          t.id = tr.id; 
           
          t.subject = tr.subject; 
        
          t.ActivityDate = activityDate; 
        
          t.Unique_Identifier__c = tr.uniqueIdentifier;
         
          t.nu_dse__Communication_Template__c = tr.templateId;
        
            
          t.WhatId = tr.parentId;
            
          t.nu_dse__Is_System_Task__c = true; 
            
          taskInsertList.add(t); 
            
        }
       
        List<UpdateTaskResponse>  response = new List<UpdateTaskResponse>(); 
        
        
        try{
            
            update taskInsertList ; 
              
            for(task t: taskInsertList){
                UpdateTaskResponse tresponse =  new UpdateTaskResponse();
                tresponse.Id = t.Id; 
                response.add(tresponse);
            }
        }catch(Exception e){
            
            UpdateTaskResponse tresponse =  new UpdateTaskResponse();
            tresponse.error = 'Insert Failed';
            response.add(tresponse);
            System.debug('insert failed');
        }
        
        
        return response; 
    }

    
     global class UpdateTaskRequest {
        
       @InvocableVariable(required=true)
       global String id;
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
    
    global class  UpdateTaskResponse{
        
        @InvocableVariable
        global String Id; 
         @InvocableVariable
        global String error; 
        
    }
    
}