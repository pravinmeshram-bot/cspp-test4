@isTest
public class UpdateDebts_Test implements HttpCalloutMock {

    static testMethod void testUpdateDebts() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        List<nu_dse__TradeLine__c> tradeline= new List<nu_dse__TradeLine__c>();
        
        nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = program.id;
        trd.nu_dse__Original_Debt__c = 2.0;
        tradeline.add(trd);
                
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new UpdateDebts_Test());
        UpdateDebts.doPost(tradeline);
        
        Test.stopTest();  
        
        List<nu_dse__TradeLine__c> tradelineList = [SELECT Id FROM nu_dse__TradeLine__c ];
        System.assertEquals(False, tradelineList.isEmpty());     
    }
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
}