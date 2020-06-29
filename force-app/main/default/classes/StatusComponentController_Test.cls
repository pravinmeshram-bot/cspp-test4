@isTest
public class StatusComponentController_Test implements HttpCalloutMock {
        
    @isTest static void testStatusComponentController() {
        
        /*Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;*/
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        //program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        program.nu_dse__Processor_Status__c = 'Active';
        program.nu_dse__CIP_Status__c = 'Verified';
        program.nu_dse__OFAC_Status__c = 'Verified';
        insert program; 
        
        nu_dse__Bank_Account__c bankAccount = new nu_dse__Bank_Account__c(nu_dse__Bank_Account_Number__c = '784125896541',
                                              nu_dse__Holder_s_Name__c = 'Test', nu_dse__Account_Type__c = 'SAVING',
                                              nu_dse__Routing_Number__c = '102000021', nu_dse__Program__c = program.Id, nu_dse__Status__c = 'Active');
        insert bankAccount;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new StatusComponentController_Test());
        StatusComponentController.StatusWraper statusCtrl = StatusComponentController.getStatus(program.Id);
         
        System.assertEquals('Active', statusCtrl.processorStatus.status);  
        
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