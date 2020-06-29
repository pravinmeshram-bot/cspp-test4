@isTest
public class TwiMl_Unresponsive_Test {

    @isTest static void testCreateTwiMl_Unresponsive() {
        
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
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'UNRESPONSIVE_LIVE_VB';
        document.FolderId = [select id from folder where name = 'Recordings'].id;
        insert document;
        
        Document document1;
        document1 = new Document();
        document1.Body = Blob.valueOf('Some Text');
        document1.ContentType = 'application/pdf';
        document1.DeveloperName = 'Test';
        document1.IsPublic = true;
        document1.Name = 'UNRESPONSIVE_VOICE_VB';
        document1.FolderId = [select id from folder where name = 'Recordings'].id;
        insert document1;
        
        ApexPages.currentPage().getParameters().put('Digits', '1');
        ApexPages.currentPage().getParameters().put('AnsweredBy', 'human');
        String twiml;
        String twiml1;
        String twiml2;
        Test.startTest();
        System.runAs(user1) { 
            
            TwiMl_Unresponsive unResponsive = new TwiMl_Unresponsive();
            twiml = unResponsive.getResponse();
            
            ApexPages.currentPage().getParameters().put('Digits', null);
            twiml1 = unResponsive.getResponse();
            
            ApexPages.currentPage().getParameters().put('AnsweredBy', 'machine_start');
            twiml2 = unResponsive.getResponse();
        }
        Test.stopTest();  
        System.assertEquals('<Response><Dial>+18552508329</Dial></Response>', twiml);  
    }
}