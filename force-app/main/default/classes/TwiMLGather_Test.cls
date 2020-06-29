@isTest
public class TwiMLGather_Test {
    @isTest static void testCreateTwiMLGather() {
        
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
        
        ApexPages.currentPage().getParameters().put('Digits', '1');
        ApexPages.currentPage().getParameters().put('AnsweredBy', 'machine_start');
        String twiml;
        
        Test.startTest();
        System.runAs(user1) { 
            
            twiml = TwiMLGather.getResponse();
        }
        Test.stopTest();  
        
        System.assertEquals('<Response><Say>Hello</Say></Response>', twiml);  
               
    }
}