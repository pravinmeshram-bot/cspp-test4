@isTest
public class TaskViewController_Test implements HttpCalloutMock {
        
    @isTest static void testTaskViewController() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
                
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        Task taskStr = new Task();
        taskStr.Subject = 'Test';
        taskStr.Status = 'In Progress';
        taskStr.ActivityDate = System.Today().addDays(-1);
        taskStr.Call_Type__c = 'On boarding Calls';
        taskStr.WhatId = program.Id;
        insert taskStr;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new TaskViewController_Test());
        TaskViewController taskCtrl = new TaskViewController();
        taskCtrl.taskCallType = 'On boarding Calls';
        taskCtrl.parentId = program.Id;
        List<TaskViewController.TaskWraper> taskWrapStr = TaskViewController.getTaskList(program.Id);   
        TaskViewController.closeTask(taskStr.Id);
        System.assertEquals('over-due', taskWrapStr[0].color);  
        
        Test.stopTest();
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
}