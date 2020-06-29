@isTest
public class BatchBoxFolderCreation_Test  implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
        System.debug('::req::'+req);   
        String response;
        if (req.getEndpoint().startsWith('https://api.box.com/2.0/search') == True) {
        
             response = '{"total_count":1,"entries":[{"type":"folder","id":"56618422535","etag":"1","name":"CL-GL0014309452","parent":{"type":"folder","id":"57206468784","sequence_id":"0","etag":"0","name":"GREAT LAKES"}}],"limit":10,"offset":0}';
        }
        else if (req.getEndpoint() == 'https://api.box.com/2.0/folders') {
        
             response = '{"type":"folder","id":"101176268784","sequence_id":"0","etag":"0","name":"CL-146052","'
                 		+'created_at":"2020-01-23T07:18:42-08:00","modified_at":"2020-01-23T07:18:42-08:00","'
                 		+'description":"","size":0,"path_collection":{"total_count":3,"entries":[{"type":"folder",'
                 		+'"id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"99254086859",'
                 		+'"sequence_id":"0","etag":"0","name":"Test Integration"},{"type":"folder","id":"100086731825",'
                 		+'"sequence_id":"2","etag":"2","name":"Whitestone"}]},"created_by":{"type":"user","id":"11238624736",'
                 		+'"name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"modified_by":{"type":"user","id":"11238624736",'
                 		+'"name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"trashed_at":null,"purged_at":null,'
                 		+'"content_created_at":"2020-01-23T07:18:42-08:00","content_modified_at":"2020-01-23T07:18:42-08:00",'
                 		+'"owned_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},'
                 		+'"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"100086731825","sequence_id":"2",'
                 		+'"etag":"2","name":"Whitestone"},"item_status":"active","item_collection":{"total_count":29,"entries":['
             			+'{"type":"folder","id":"101176277184","sequence_id":"0","etag":"0","name":"1099c"},{"type":"folder",'
                 		+'"id":"101176271184","sequence_id":"0","etag":"0","name":"Add Remove Debt"},{"type":"folder","id":"101176269984",'
                 		+'"sequence_id":"0","etag":"0","name":"Bank Info"},{"type":"folder","id":"101176272384","sequence_id":"0",'
                 		+'"etag":"0","name":"Bank Levy"},{"type":"folder","id":"101176274784","sequence_id":"0","etag":"0",'
                 		+'"name":"Bankruptcy"},{"type":"folder","id":"101176275984","sequence_id":"0","etag":"0","name":"Call Logs"},'
             			+'{"type":"folder","id":"101176273584","sequence_id":"0","etag":"0","name":"Cancellation Notice"},'
             			+'{"type":"folder","id":"101176280784","sequence_id":"0","etag":"0","name":"Collection Notice"},{"type":"folder",'
                 		+'"id":"101176278384","sequence_id":"0","etag":"0","name":"Creditor Notifications"},{"type":"folder","id":'
                 		+'"101176287984","sequence_id":"0","etag":"0","name":"Customer Correspondence"},{"type":"folder","id":'
                 		+'"101176295184","sequence_id":"0","etag":"0","name":"Death Notifications"},{"type":"folder","id":"101176290384",'
                 		+'"sequence_id":"0","etag":"0","name":"Hardship Letters"},{"type":"folder","id":"101176291584","sequence_id":'
                 		+'"0","etag":"0","name":"Legal Garnishments"},{"type":"folder","id":"101176296384","sequence_id":"0","etag":'
                 		+'"0","name":"Legal Judgments"},{"type":"folder","id":"101176283184","sequence_id":"0","etag":"0","name":'
                 		+'"Legal Property Lien"},{"type":"folder","id":"101176301184","sequence_id":"0","etag":"0","name":'
                 		+'"Legal Settlements & Stipulations"},{"type":"folder","id":"101176304784","sequence_id":"0","etag":"0",'
                 		+'"name":"Legal Summons"},{"type":"folder","id":"101176285584","sequence_id":"0","etag":"0","name":'
                 		+'"Legal- other"},{"type":"folder","id":"101176305984","sequence_id":"0","etag":"0","name":"LOR \u2013 '
                 		+'Fax Confirmation"},{"type":"folder","id":"101176279584","sequence_id":"0","etag":"0","name":'
                 		+'"Notifications"},{"type":"folder","id":"101176286784","sequence_id":"0","etag":"0","name":'
                 		+'"Original Contracts"},{"type":"folder","id":"101176298784","sequence_id":"0","etag":"0","name":'
                 		+'"Payment Schedule Adjustments"},{"type":"folder","id":"101176303584","sequence_id":"0","etag":"0",'
                 		+'"name":"Power of Attorney"},{"type":"folder","id":"101176284384","sequence_id":"0","etag":"0",'
                 		+'"name":"Releases"},{"type":"folder","id":"101176297584","sequence_id":"0","etag":"0","name":'
                 		+'"Satisfaction Letters"},{"type":"folder","id":"101176289184","sequence_id":"0","etag":"0","name":'
                 		+'"Settlement Letters"},{"type":"folder","id":"101176302384","sequence_id":"0","etag":"0","name":'
                 		+'"Settlement Offer"},{"type":"folder","id":"101176307184","sequence_id":"0","etag":"0","name":'
                 		+'"Statements"},{"type":"folder","id":"101176299984","sequence_id":"0","etag":"0","name":'
                 		+'"Updated Contracts"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":'
                 		+'"name","direction":"ASC"}]}}';
        } else{
        
            response = '{"access_token":"SBI5y9vqwn13m9cFCo0YbYms0uIhANNA","expires_in":3603,"restricted_to":[],"token_type":"bearer"}';
        }
        HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatus('OK');
            res.setStatusCode(201);    
        return res;
    }

    static testMethod void testCreateBoxFolderAndSubFolders() {
        
       Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
       Portfolio__c p = new Portfolio__c();
       p.name = 'TestPortFolio';
       //p.BoxFolderId__c = '22222222222'; replaced inorder to increase code converage... If boxFolderId in the response didn't match id wont be populated...
       p.BoxFolderId__c = '57206468784';
       p.Active_Status__c = true;
       insert p;
       
        Account accountInstance = TestRecordCreator.createAccount('Account Name', clientRecordTypeId);
        accountInstance.PortFolio_Name__c = 'TestPortFolio';
        accountInstance.Phone = '9879879877';
        //accountInstance.Box_Folder_Name__c = 'CL-GL0014309452'; //Field not writeable error occurs
        accountInstance.NDS_File_Number__c = 'CL-GL0014309452';
        accountInstance.Attorney__c = True; 
        insert accountInstance;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accountInstance.id;
        pgm.Portfolio__c = p.id;
        insert pgm;
        
        Box_settings__c boxInstance = TestRecordCreator.createBoxsettings();
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new BatchBoxFolderCreation_Test());
            Database.executeBatch(new BatchBoxFolderCreation(), 1);
            
        Test.stopTest();
        
        List<Account> accountList = [SELECT Id, BoxFolderId__c FROM Account WHERE Id = :accountInstance.Id];
        //System.assertEquals('47510948398', accountList[0].BoxFolderId__c);
    }
    
    static testMethod void testRootIdMismatchCreateNewBoxFolderAndSubFolders() {
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
       Portfolio__c p = new Portfolio__c();
       p.name = 'TestPortFolio';
       p.BoxFolderId__c = '22222222222'; //actual parent Id is '57206468784'
       p.Active_Status__c = true;
       
       insert p;
       
        Account accountInstance = TestRecordCreator.createAccount('Account Name', clientRecordTypeId);
        accountInstance.PortFolio_Name__c = 'TestPortFolio';
        accountInstance.Attorney__c = True; 
        accountInstance.Phone = '9879879877';
        insert accountInstance;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accountInstance.id;
        pgm.Portfolio__c = p.id;
        insert pgm;
        
        Box_settings__c boxInstance = TestRecordCreator.createBoxsettings();
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new BatchBoxFolderCreation_Test());
            Database.executeBatch(new BatchBoxFolderCreation(), 1);
            
        Test.stopTest();
        
        List<Account> accountList = [SELECT Id, BoxFolderId__c FROM Account WHERE Id = :accountInstance.Id];
        //System.assertEquals('47510948398', accountList[0].BoxFolderId__c);
    }
    
    static testMethod void testExecute(){
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
       Portfolio__c p = new Portfolio__c();
       p.name = 'TestPortFolio';
       //p.BoxFolderId__c = '22222222222'; //actual parent Id is '57206468784'
       p.Active_Status__c = true;
       
       insert p;
       
        Account accountInstance = TestRecordCreator.createAccount('Account Name', clientRecordTypeId);
        accountInstance.PortFolio_Name__c = 'TestPortFolio';
        accountInstance.Attorney__c = True; 
        accountInstance.Phone = '9879879877';
        insert accountInstance;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accountInstance.id;
        pgm.Portfolio__c = p.id;
        insert pgm;
        
        Box_settings__c boxInstance = TestRecordCreator.createBoxsettings();
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
        
        test.startTest();
        	
        	BatchBoxFolderCreation inst = new BatchBoxFolderCreation();
			Database.executebatch(inst);
        test.stopTest();
        
    }
}