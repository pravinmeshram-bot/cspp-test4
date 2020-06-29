@isTest
public class CreateTask_Test {

    /*@testsetup
    public static void testData(){
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
        program.External_Id__c= 'Test_CreateTaskData'; 
        
        insert program; 
        
        nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
    }*/
    
    public testmethod static void testcreateTask(){
        
        //nu_dse__Program__c program = [select id from  nu_dse__Program__c limit 1];
        //nu_dse__Communication_Template__c template  = [select id from  nu_dse__Communication_Template__c limit 1];
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
        
        insert program; 
        
        nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template;  
                
        CreateTask.CreateTaskRequest request = new CreateTask.CreateTaskRequest(); 
        
        request.activityDate = System.date.today(); 
        request.subject = 'Test'; 
        request.parentId = program.Id;
        request.uniqueIdentifier = '111';
        request.templateName = program.id; 
        
        List<CreateTask.CreateTaskRequest> requestList = new List<CreateTask.CreateTaskRequest>(); 
        
        requestList.add(request);
       
        CreateTask.invoke(requestList);
        
        List<Task> taskList = [Select Id FROM Task];
        System.assertEquals(False, taskList.isEmpty());

       
    }
    
}