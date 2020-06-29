@isTest
public class DeleteTasks_Test {
    
    public testmethod static void testupsertTask() {
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        insert program; 
        
        Task taskObj = new Task();
        taskObj.Status = 'Completed';
        taskObj.WhatId = program.id;
        taskObj.Unique_Identifier__c = program.Id;
        insert taskObj;
        
        List< DeleteTasks.DeleteTaskRequest> request = new List< DeleteTasks.DeleteTaskRequest>();
        
        DeleteTasks.DeleteTaskRequest req = new DeleteTasks.DeleteTaskRequest();
        req.uniqueIdentifier = program.Id;
        request.add(req);
        
        DeleteTasks.DeleteTasks(request);
        
        List<Task> taskList = [SELECT Id FROM Task WHERE Id =: taskObj.Id];
        System.assertEquals(True, taskList.isEmpty());

    }
}