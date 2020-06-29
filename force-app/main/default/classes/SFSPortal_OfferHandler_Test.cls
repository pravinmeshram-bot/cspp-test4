@isTest
global class SFSPortal_OfferHandler_Test implements HttpCalloutMock{
    
    @testSetup 
    public static void setup() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor');
        
        Account account2 = new Account(Name = 'Test',RecordTypeId = recordTypeId);
        insert account2;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Name = 'Option 1 Legal';
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.SFSPortal_OneSignal_App_Id__c = 'abcd-123-abcd';
        programInstance.Client_Portal_User_Id__c = userinfo.getuserid();
        insert programInstance;
        
        nu_dse__TradeLine__c tradeInstance = SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id);
        tradeInstance.nu_dse__Original_Creditor__c = account2.Id;
        tradeInstance.SFS_Current_Balance__c = 500;
        insert tradeInstance;
        
    }
    
    static testMethod void test_OfferHandler(){
        
        List<nu_dse__Program__c> programList = [SELECT ID FROM nu_dse__Program__c];
        
        List<nu_dse__TradeLine__c > tradelineList = [SELECT ID FROM nu_dse__TradeLine__c ];
        
        nu_dse__Offer__c offerInstance1 = SFSPortal_TestRecordCreator.createoffer(programList[0].Id, tradelineList[0].Id, 100, 50, 5, 5);
        offerInstance1.Tradeline_Litigation_Status__c = 'Non Lit';
        offerInstance1.Available_for_Client_Review__c = true;
        offerInstance1.Source_of_Payment__c = 'PSA';
        offerInstance1.nu_dse__Status__c = 'Pending Creditor Approval';
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new SFSPortal_OfferHandler_Test());
            insert offerInstance1;
            
        Test.stopTest();
        
    }
    
    static testMethod void test_UpdateOfferHandler(){
        
        List<nu_dse__Program__c> programList = [SELECT ID FROM nu_dse__Program__c];
        
        List<nu_dse__TradeLine__c > tradelineList = [SELECT ID FROM nu_dse__TradeLine__c ];
        
        nu_dse__Offer__c offerInstance = SFSPortal_TestRecordCreator.createoffer(programList[0].Id, tradelineList[0].Id, 100, 50, 5, 5);
        offerInstance.Tradeline_Litigation_Status__c = 'Non Lit';
        offerInstance.Available_for_Client_Review__c = true;
        offerInstance.Source_of_Payment__c = 'PSA';
        offerInstance.nu_dse__Status__c = 'Pending Creditor Approval';
        offerInstance.Authorization_Received__c = true;
        insert offerInstance;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SFSPortal_OfferHandler_Test());
            offerInstance.Authorization_Received__c = false;
            update offerInstance;
        Test.stopTest();
    }
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
       System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        String body = '[{ "app_id": "abcd-123-abcd"}]';
        res.setBody(body);
        res.setHeader('Content-Type', 'application/xml');
        res.setStatusCode(200);
        return res;
    }
}