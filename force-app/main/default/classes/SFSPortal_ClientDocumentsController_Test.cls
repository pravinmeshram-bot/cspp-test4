@IsTest
public with sharing class SFSPortal_ClientDocumentsController_Test implements HttpCalloutMock {

    @isTest
    static void testClientDocumentsController() {
        
        Account account = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account.BoxFolderId__c = '1236542';
        insert account;
           
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        String headerdata = URL.getCurrentRequestUrl().toExternalForm();
        List<String> urlValueList = headerdata.split('/apex');
        
        Portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('4569871238');
        portfolioInstance.Domain_URL__c = urlValueList[0];
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Client_Folders__c = 'Creditor Notifications;Call Logs';
        insert portfolioInstance;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account.Id,null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Box_settings__c  boxInstance = SFSPortal_TestRecordCreator.createBoxsettings();
        boxInstance.Folder_Endpoint__c = 'https://api.box.com/2.0/folders';
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
        
        List<SFSPortal_ClientDocumentsController.EntriesClass> entryClassList = new List<SFSPortal_ClientDocumentsController.EntriesClass>();
        
        Test.startTest();
            System.runAs(user1) { 
                Test.setMock(HttpCalloutMock.class, new SFSPortal_ClientDocumentsController_Test());
                
                SFSPortal_ClientDocumentsController clientCtrl = new SFSPortal_ClientDocumentsController();
                clientCtrl.getAccessToken();
                SFSPortal_ClientDocumentsController.getFolderNames();
                entryClassList = SFSPortal_ClientDocumentsController.getAllSubFoldersAndFiles('544132221');
            }
        Test.stopTest();
        system.assertEquals(false,entryClassList.isEmpty());
    }
    
    @isTest
    static void testClientDocumentsController_Exception() {
        
        Account account = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account.BoxFolderId__c = '1236542';
        insert account;
           
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        String headerdata = URL.getCurrentRequestUrl().toExternalForm();
        List<String> urlValueList = headerdata.split('/apex');
        
        Portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('4569871238');
        portfolioInstance.Domain_URL__c = urlValueList[0];
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Client_Folders__c = 'Creditor Notifications;Call Logs';
        insert portfolioInstance;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account.Id,null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Box_settings__c  boxInstance = SFSPortal_TestRecordCreator.createBoxsettings();
        boxInstance.Folder_Endpoint__c = 'https://api.box.com/2.0/folders';
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
                
        Test.startTest();
            System.runAs(user1) { 
                SFSPortal_ClientDocumentsController clientCtrl = new SFSPortal_ClientDocumentsController();
                clientCtrl.getAccessToken();
                try {
                    
                    SFSPortal_ClientDocumentsController.getFolderNames();
                } catch(Exception e) {
                
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {
                    
                    SFSPortal_ClientDocumentsController.getAllSubFoldersAndFiles('544132221');
                } catch(Exception e) {
                
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }                
            }
        Test.stopTest();
    }
    
    public HTTPResponse respond(HTTPRequest req) {
                
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-type', 'application/json');
        
        SFSPortal_ClientDocumentsController.ParentClass parent = new SFSPortal_ClientDocumentsController.ParentClass();
        parent.id = '544121';
        
        SFSPortal_ClientDocumentsController.ModifiedClass modifed = new SFSPortal_ClientDocumentsController.ModifiedClass();
        modifed.id = '34223';
        modifed.name = 'Call Logs';
        
        SFSPortal_ClientDocumentsController.EntriesClass entries = new SFSPortal_ClientDocumentsController.EntriesClass();
        entries.id = '544132221';
        entries.name = 'Creditor Notifications';
        entries.type = 'jpg';
        entries.parent = parent;
        entries.modified_by = modifed;
        
        SFSPortal_ClientDocumentsController.BoxResponse boxWrapper = new SFSPortal_ClientDocumentsController.BoxResponse();
        boxWrapper.entries = new List<SFSPortal_ClientDocumentsController.EntriesClass>{entries};
        
        res.setBody(JSON.serialize(boxWrapper));
        res.setStatusCode(200);
        return res;
    }
}