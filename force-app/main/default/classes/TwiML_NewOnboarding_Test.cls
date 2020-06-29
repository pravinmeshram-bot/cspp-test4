@isTest
public class TwiML_NewOnboarding_Test {

    @isTest static void testCreateTwiML_NewOnboarding() {
        
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
        document.Name = 'ONBOARDING_NEW';
        document.FolderId = [select id from folder where name = 'Recordings'].id;
        insert document;
        
        ApexPages.currentPage().getParameters().put('Digits', '1');
        ApexPages.currentPage().getParameters().put('AnsweredBy', 'human');
        String twiml;
        String twiml1;
        String twiml2;
        Test.startTest();
        System.runAs(user1) { 
            
            TwiML_NewOnboarding newOnBoarding = new TwiML_NewOnboarding();
            twiml = newOnBoarding.getResponse();
            
            ApexPages.currentPage().getParameters().put('Digits', null);
            twiml1 = newOnBoarding.getResponse();
            
            ApexPages.currentPage().getParameters().put('AnsweredBy', 'machine_start');
            twiml2 = newOnBoarding.getResponse();
        }
        Test.stopTest();  
        System.assertEquals('<Response><Dial>+18552508329</Dial></Response>', twiml);  
        system.debug('twiml1--->'+twiml1);            
    }
}