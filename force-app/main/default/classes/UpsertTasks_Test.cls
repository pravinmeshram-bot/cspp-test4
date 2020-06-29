@isTest
public class UpsertTasks_Test {

    @testsetup
    public static void testData(){
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
        
        insert program; 
        
        Nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
    }
    
     public testmethod static void testupsertTask(){
        
        nu_dse__Program__c program = [select id from  nu_dse__Program__c limit 1];
        nu_dse__Communication_Template__c template  = [select id from  nu_dse__Communication_Template__c limit 1];
         
        CreateTask.CreateTaskRequest request = new CreateTask.CreateTaskRequest(); 
        request.activityDate = System.date.today(); 
        request.subject = 'Test'; 
        request.parentId = program.Id;
        request.uniqueIdentifier = String.valueOf(System.Date.today());
        request.templateName = template.id;  
        
        LIst<CreateTask.CreateTaskRequest> requestList = new List<CreateTask.CreateTaskRequest>(); 
        
        requestList.add(request);
        
        CreateTask.invoke(requestList);
         
        UpsertTasks.UpsertTaskRequest upsertrequest = new  UpsertTasks.UpsertTaskRequest(); 
        upsertrequest.templateName = template.id; 
        upsertrequest.activityDate = System.date.today(); 
        
        List<UpsertTasks.UpsertTaskRequest> failUpsertRequestList = new  List<UpsertTasks.UpsertTaskRequest>{upsertrequest}; 
         
        List<UpsertTasks.UpsertTaskResponse> failTaskRes = UpsertTasks.upsertTask(failUpsertRequestList);
        
        system.assertEquals('Insert Failed', failTaskRes[0].error);
        
        upsertrequest.uniqueIdentifier = String.valueOf(System.Date.today());
        upsertrequest.subject = 'Test'; 
        upsertrequest.parentId = program.Id;
        upsertrequest.status= 'Not started'; 
        
        List<UpsertTasks.UpsertTaskRequest> passUpsertRequestList = new  List<UpsertTasks.UpsertTaskRequest>{upsertrequest}; 
         
        List<UpsertTasks.UpsertTaskResponse> passTaskRes = UpsertTasks.upsertTask(passUpsertRequestList);
        
        system.assert(passTaskRes[0].Id != null);
    }
}