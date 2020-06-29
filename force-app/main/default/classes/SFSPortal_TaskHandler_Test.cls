@isTest
global class SFSPortal_TaskHandler_Test implements HttpCalloutMock{
    
    @testSetup 
    public static void setup() {
        
        
    }
    
    static testMethod void test_TaskHandler(){
        
       Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        //insert user1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Name = 'Option 1 Legal';
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.SFSPortal_OneSignal_App_Id__c = 'abcd-123-abcd';
        programInstance.nu_dse__Program_Status__c = 'UnResponsive NSF';
        programInstance.Client_Portal_User_Id__c = userinfo.getuserid();
        insert programInstance;
        
        Id pendingTaskInfoId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Pending Tasks Info');
        
        Portal_Settings__c portalSetting = SFSPortal_TestRecordCreator.createPortalSettingForTaskInfo (portfolioInstance.Id, pendingTaskInfoId, 'Strategy Calls');
        insert portalSetting;
        
        nu_dse__Payment__c paymentInstance = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        insert paymentInstance;
        
        nu_dse__Payment__c paymentInstance1 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        insert paymentInstance1;
        
        nu_dse__Payment__c advanceInstance = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        advanceInstance.nu_dse__Advance_Payment__c = paymentInstance1.Id;
        advanceInstance.nu_dse__Is_Makeup_Payment_Created__c = TRUE;
        insert advanceInstance;
        
        List<Task> tasksList = new List<Task>();
        
        Task taskInstance = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance.Clients_task__c = True;
        taskInstance.Status = 'Not Started';
        taskInstance.Call_Type__c = 'NSF';
        taskInstance.NSF_Payment__c = paymentInstance.Id;
        tasksList.add(taskInstance);
        
        Task taskInstance1 = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance1.Clients_task__c = True;
        taskInstance1.Status = 'Not Started';
        taskInstance1.Call_Type__c = 'NSF';
        taskInstance1.NSF_Payment__c = paymentInstance1.Id;
        tasksList.add(taskInstance1);
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new SFSPortal_TaskHandler_Test());
            insert tasksList;
        Test.stopTest();
    }
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
       System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String body = '[{ "app_id": "abcd-123-abcd"}]';//Pass the json 
        res.setBody(body);
        res.setHeader('Content-Type', 'application/xml');
        res.setStatusCode(200);
        return res;
    }
}