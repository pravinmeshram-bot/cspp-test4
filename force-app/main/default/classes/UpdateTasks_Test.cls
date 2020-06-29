@isTest
public class UpdateTasks_Test {

    public testmethod static void testUpdateTasks(){
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
         
        insert program; 
        
        nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
       nu_dse__Communication_Template__c Comtemplate = new nu_dse__Communication_Template__c(); 
        Comtemplate.name = 'Testing';
        
        insert Comtemplate; 
        
        Task taskObj = new Task();
        taskObj.Status = 'Completed';
        taskObj.nu_dse__Communication_Template__c = template.Id;
        taskObj.Unique_Identifier__c = '1122';
        taskObj.WhatId = program.id;
        taskObj.subject = 'Test';
        taskObj.ActivityDate = System.today();
        insert taskObj;
        
        List<UpdateTasks.UpdateTaskRequest> updateRequestList = new List<UpdateTasks.UpdateTaskRequest>();
        
        UpdateTasks.UpdateTaskRequest updaterequest = new  UpdateTasks.UpdateTaskRequest(); 
        updaterequest.id = taskObj.Id; 
        updaterequest.uniqueIdentifier = template.Id; 
        updaterequest.templateName = Comtemplate.Id; 
        updaterequest.subject = 'Test';
        updaterequest.activityDate = System.today();  
        updaterequest.parentId = program.id;
        updaterequest.status = 'Completed'; 
        
        updateRequestList.add(updaterequest);
        
        UpdateTasks.upsertTask(updateRequestList);
        
        List<Task> taskList = [SELECT Id, Unique_Identifier__c FROM Task WHERE Id =:taskObj.Id ];
        System.assertEquals(template.Id, taskList[0].Unique_Identifier__c);
    }
    
    public testmethod static void testUpdateTasks1(){
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
        
        insert program; 
        
        nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
        Task taskObj = new Task();
        taskObj.Status = 'Completed';
        taskObj.nu_dse__Communication_Template__c = template.Id;
        taskObj.Unique_Identifier__c = '1122';
        taskObj.subject = 'Test';
        taskObj.WhatId = program.id;
        taskObj.ActivityDate = System.today();
        insert taskObj;
        
        List<UpdateTasks.UpdateTaskRequest> updateRequestList = new List<UpdateTasks.UpdateTaskRequest>();
        
        UpdateTasks.UpdateTaskRequest updaterequest = new  UpdateTasks.UpdateTaskRequest(); 
        updaterequest.id = taskObj.Id; 
        updaterequest.uniqueIdentifier = taskObj.Unique_Identifier__c; 
        updaterequest.templateName = taskObj.nu_dse__Communication_Template__c;
        updaterequest.subject = taskObj.subject;
        updaterequest.activityDate = taskObj.ActivityDate; 
        updaterequest.parentId = program.id;
        updaterequest.status = 'Completed'; 
        
        updateRequestList.add(updaterequest);
        
        UpdateTasks.upsertTask(updateRequestList);
        
        List<Task> taskList = [SELECT Id, WhatId FROM Task WHERE Id =:taskObj.Id ];
        System.assertEquals(program.id, taskList[0].WhatId);
    }
    
    
}