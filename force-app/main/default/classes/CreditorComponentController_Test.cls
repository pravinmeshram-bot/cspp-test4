@isTest
public class CreditorComponentController_Test implements HttpCalloutMock {
    
    public static String accountSObj = Account.sObjectType.getDescribe().getName();
    
    @isTest static void testCreditorComponentController() {
        
        /****Changes for generic record creation****Starts****/
        Velocify_Settings__c settings = TestRecordCreator.createVelocifySettings();
        insert settings;
        
        Account acct = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct.nu_dse__CFT_Synced__c = TRUE;
        insert acct;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(); 
        //program.External_Id__c= 'Test_CreateTaskData'; 
        program.External_Id__c= '11223344';  //modified on oct03-2017
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
                
        nu_dse__TradeLine__c trd = TestRecordCreator.createTradeLine(acct.Id, program.Id);
        trd.nu_dse__New_Account_Number__c = '987654321654';
        trd.nu_dse__New_Creditor__c = acct.Id;//un-commented out on Mar-14-2019
        insert trd;
        /****Changes for generic record creation****Ends****/
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CreditorComponentController_Test());
        
        List<CreditorComponentController.Creditor> creditorCtr = CreditorComponentController.getCreditors(program.Id);
        
        //System.assertEquals(True, creditorCtr[0].verified);  commented out on oct-03-2017
        
        Test.stopTest();  
        System.assertEquals(true, creditorCtr[0].verified); 
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
}