@isTest
public class PymentStatusComponentController_Test implements HttpCalloutMock {
    
    public static String paymentSObj = nu_dse__Payment__c.sObjectType.getDescribe().getName();
        
    @isTest static void testPymentStatusComponentController() {
        
        /*Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;*/
                
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        //program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        List<RecordType> rectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Draft' AND 
                       SObjectType =: paymentSObj AND isActive = True];
        
        if (!rectypeList.isEmpty()) {    
                
            nu_dse__Payment__c payment= new nu_dse__Payment__c();
            payment.nu_dse__Program__c = program.id;
            payment.nu_dse__transaction_status__c = 'In Progress';
            payment.nu_dse__Amount__c = 1000;
            payment.nu_dse__Schedule_Date__c = System.Today().addDays(-1);
            payment.RecordTypeId = rectypeList[0].Id;
            insert payment;
        }
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new PymentStatusComponentController_Test());
        
        List<PymentStatusComponentController.Payment> paymentCtrl = PymentStatusComponentController.getPayments(program.Id);
        System.assertEquals('In Progress', paymentCtrl[0].status);          
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