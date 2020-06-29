@isTest
public class TwiML_NSF_Test {

    @isTest static void testCreateTwiML_NSF() {
    
    User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             FirstName = 'First',
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        Document document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_doc';
        document.IsPublic = true;
        document.Name = 'NSF LIVE VB';
        document.FolderId = [select id from folder where name = 'Recordings'].id;        
        insert document;
        
        Document document1;
        document1 = new Document();
        document1.Body = Blob.valueOf('Some Text');
        document1.ContentType = 'application/pdf';
        document1.DeveloperName = 'my_test_doc';
        document1.IsPublic = true;
        document1.Name = 'NSF VOICE VB';
        document1.FolderId = [select id from folder where name = 'Recordings'].id;        
        insert document1;   
        
        List<Document> newdoc = [Select Folder.Name,Name,developerName from Document where Folder.Name='Recordings'];
        System.debug('<<()()>>'+newdoc); 
        
        String twiml;
        String twiml1;
        String twiml2;
        Test.startTest();
        System.runAs(user1) { 
            
            TwiML_NSF nsf = new TwiML_NSF();
            twiml = nsf.getResponse();
            
            ApexPages.currentPage().getParameters().put('Digits', null);
            twiml1 = nsf.getResponse();
            
            ApexPages.currentPage().getParameters().put('digits', '');
            ApexPages.currentPage().getParameters().put('answeredBy', 'human');
            twiml2 = nsf.getResponse();
            
            ApexPages.currentPage().getParameters().put('digits', '1');
            ApexPages.currentPage().getParameters().put('answeredBy', 'human');      
            
            ApexPages.currentPage().getParameters().put('answeredBy', 'machine_start');
        }
        Test.stopTest();  
        //System.assertEquals('<Response><Dial>+18552508329</Dial></Response>', twiml);  
        
    }
}