@isTest
public class BatchBoxMissingFolderCreationTest  implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
        System.debug('::req::'+req);   
        String response;
        if (req.getEndpoint() == 'https://api.box.com/2.0/folders/122323232?') {
            response = '{"type":"folder","id":"100907764256","sequence_id":"0","etag":"0","name":"Test Copy","created_at":"2020-01-21T08:46:43-08:00","modified_at":"2020-01-23T11:13:33-08:00","description":"","size":0,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"99254086859","sequence_id":"0","etag":"0","name":"Test Integration"}]},"created_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"modified_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"trashed_at":null,"purged_at":null,"content_created_at":"2020-01-21T08:46:43-08:00","content_modified_at":"2020-01-23T11:13:33-08:00","owned_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"99254086859","sequence_id":"0","etag":"0","name":"Test Integration"},"item_status":"active","item_collection":{"total_count":29,"entries":[{"type":"folder","id":"101009976665","sequence_id":"2","etag":"2","name":"1099c"},{"type":"folder","id":"100907766656","sequence_id":"2","etag":"2","name":"Add Remove Debt"},{"type":"folder","id":"100907765456","sequence_id":"2","etag":"2","name":"Bank Info"},{"type":"folder","id":"101008183898","sequence_id":"1","etag":"1","name":"Bank Levy"},{"type":"folder","id":"101008354871","sequence_id":"1","etag":"1","name":"Bankruptcy"},{"type":"folder","id":"101008591183","sequence_id":"1","etag":"1","name":"Call Logs"},{"type":"folder","id":"101008319316","sequence_id":"1","etag":"1","name":"Cancellation Notice"},{"type":"folder","id":"101016283803","sequence_id":"1","etag":"1","name":"Collection Notice"},{"type":"folder","id":"101010844862","sequence_id":"1","etag":"1","name":"Creditor Notifications"},{"type":"folder","id":"101060525520","sequence_id":"0","etag":"0","name":"Customer Correspondence"},{"type":"folder","id":"101061541439","sequence_id":"0","etag":"0","name":"Death Notifications"},{"type":"folder","id":"101061093992","sequence_id":"0","etag":"0","name":"Hardship Letters"},{"type":"folder","id":"101061511530","sequence_id":"0","etag":"0","name":"Legal Garnishments"},{"type":"folder","id":"101061840516","sequence_id":"0","etag":"0","name":"Legal Judgments"},{"type":"folder","id":"101058379282","sequence_id":"0","etag":"0","name":"Legal Property Lien"},{"type":"folder","id":"101063050710","sequence_id":"0","etag":"0","name":"Legal Settlements & Stipulations"},{"type":"folder","id":"101064457961","sequence_id":"0","etag":"0","name":"Legal Summons"},{"type":"folder","id":"101059314027","sequence_id":"0","etag":"0","name":"Legal- other"},{"type":"folder","id":"101064754655","sequence_id":"0","etag":"0","name":"LOR – Fax Confirmation"},{"type":"folder","id":"101015446030","sequence_id":"1","etag":"1","name":"Notifications"},{"type":"folder","id":"101059567775","sequence_id":"0","etag":"0","name":"Original Contracts"},{"type":"folder","id":"101061957838","sequence_id":"0","etag":"0","name":"Payment Schedule Adjustments"},{"type":"folder","id":"101064302829","sequence_id":"0","etag":"0","name":"Power of Attorney"},{"type":"folder","id":"101058410731","sequence_id":"0","etag":"0","name":"Releases"},{"type":"folder","id":"101061907844","sequence_id":"0","etag":"0","name":"Satisfaction Letters"},{"type":"folder","id":"101060918616","sequence_id":"0","etag":"0","name":"Settlement Letters"},{"type":"folder","id":"101063933799","sequence_id":"0","etag":"0","name":"Settlement Offer"},{"type":"folder","id":"101064867438","sequence_id":"0","etag":"0","name":"Statements"},{"type":"folder","id":"101062601119","sequence_id":"0","etag":"0","name":"Updated Contracts"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}';
        } else if (req.getEndpoint() == 'https://api.box.com/2.0/folders/123123123?') {
            response = '{"type":"folder","id":"100907764256","sequence_id":"0","etag":"0","name":"Test Copy","created_at":"2020-01-21T08:46:43-08:00","modified_at":"2020-01-23T11:13:33-08:00","description":"","size":0,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"99254086859","sequence_id":"0","etag":"0","name":"Test Integration"}]},"created_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"modified_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"trashed_at":null,"purged_at":null,"content_created_at":"2020-01-21T08:46:43-08:00","content_modified_at":"2020-01-23T11:13:33-08:00","owned_by":{"type":"user","id":"11238624736","name":"Neeraj MZ Dev","login":"neeraj@mindzcloud.com"},"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"99254086859","sequence_id":"0","etag":"0","name":"Test Integration"},"item_status":"active","item_collection":{"total_count":29,"entries":[{"type":"folder","id":"101016283803","sequence_id":"1","etag":"1","name":"Collection Notice"},{"type":"folder","id":"101010844862","sequence_id":"1","etag":"1","name":"Creditor Notifications"},{"type":"folder","id":"101060525520","sequence_id":"0","etag":"0","name":"Customer Correspondence"},{"type":"folder","id":"101061541439","sequence_id":"0","etag":"0","name":"Death Notifications"},{"type":"folder","id":"101061093992","sequence_id":"0","etag":"0","name":"Hardship Letters"},{"type":"folder","id":"101061511530","sequence_id":"0","etag":"0","name":"Legal Garnishments"},{"type":"folder","id":"101061840516","sequence_id":"0","etag":"0","name":"Legal Judgments"},{"type":"folder","id":"101058379282","sequence_id":"0","etag":"0","name":"Legal Property Lien"},{"type":"folder","id":"101063050710","sequence_id":"0","etag":"0","name":"Legal Settlements & Stipulations"},{"type":"folder","id":"101064457961","sequence_id":"0","etag":"0","name":"Legal Summons"},{"type":"folder","id":"101059314027","sequence_id":"0","etag":"0","name":"Legal- other"},{"type":"folder","id":"101064754655","sequence_id":"0","etag":"0","name":"LOR – Fax Confirmation"},{"type":"folder","id":"101015446030","sequence_id":"1","etag":"1","name":"Notifications"},{"type":"folder","id":"101059567775","sequence_id":"0","etag":"0","name":"Original Contracts"},{"type":"folder","id":"101061957838","sequence_id":"0","etag":"0","name":"Payment Schedule Adjustments"},{"type":"folder","id":"101064302829","sequence_id":"0","etag":"0","name":"Power of Attorney"},{"type":"folder","id":"101058410731","sequence_id":"0","etag":"0","name":"Releases"},{"type":"folder","id":"101061907844","sequence_id":"0","etag":"0","name":"Satisfaction Letters"},{"type":"folder","id":"101060918616","sequence_id":"0","etag":"0","name":"Settlement Letters"},{"type":"folder","id":"101063933799","sequence_id":"0","etag":"0","name":"Settlement Offer"},{"type":"folder","id":"101064867438","sequence_id":"0","etag":"0","name":"Statements"},{"type":"folder","id":"101062601119","sequence_id":"0","etag":"0","name":"Updated Contracts"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}';
        } else if (req.getEndpoint() == 'https://api.box.com/2.0/folders') {
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
       p.BoxFolderId__c = '57206468784';
       p.Active_Status__c = true;
       insert p;
       
        Account accountInstance = TestRecordCreator.createAccount('Account Name', clientRecordTypeId);
        accountInstance.PortFolio_Name__c = 'TestPortFolio';
        accountInstance.Phone = '9879879877';
        //accountInstance.Box_Folder_Name__c = 'CL-GL0014309452'; //Field not writeable error occurs
        accountInstance.NDS_File_Number__c = 'CL-GL0014309452';
        accountInstance.Attorney__c = True; 
        accountInstance.BoxFolderId__c = '123123123';
        insert accountInstance;
                
        Box_settings__c boxInstance = TestRecordCreator.createBoxsettings();
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        boxInstance.Source_FolderId_to_Copy__c = '122323232';
        boxInstance.Last_Refresh_Date__c = system.now();
        boxInstance.Access_Token_Lifetime__c = 0;
        boxInstance.access_token__c = 'TestAccessToken';
        insert boxInstance;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new BatchBoxMissingFolderCreationTest());
            Database.executeBatch(new BatchBoxMissingFolderCreation(), 1);
            
        Test.stopTest();
        
        List<Account> accountList = [SELECT Id, BoxFolderId__c FROM Account WHERE Id = :accountInstance.Id];
        //System.assertEquals('47510948398', accountList[0].BoxFolderId__c);
    }
}