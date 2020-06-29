@isTest
public class SFSPortal_Batch_ResendToExcelaEmail_Test {

    static testMethod void testResendToExcelaEmail() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        insert account1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        List<Emailmessage> emailMessgageList = new List<Emailmessage>();
        Emailmessage emailMsg = new Emailmessage();
        emailMsg.Decision_Source__c = 'Portal';
        emailMsg.Subject = '^^^TEST^^^ send an email';
        emailMsg.Related_Account__c = account1.Id;
        emailMsg.HtmlBody = 'Test Body';
        emailMessgageList.add(emailMsg);
        
        insert emailMessgageList;
        
        ContentVersion contentVersionInstance = SFSPortal_TestRecordCreator.createContentVersion();
        insert contentVersionInstance;
        
        List<ContentVersion> contentVersionList  = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInstance.Id];
        
        emailMessgageList[0].Attachment_Ids__c = contentVersionList[0].ContentDocumentId;
        
        ContentDocumentLink contentLink = SFSPortal_TestRecordCreator.createContentDocumentLink(contentVersionList[0].ContentDocumentId,emailMessgageList[0].Id);
        insert contentLink;
        
        update emailMessgageList;
        
        Test.startTest();
            
            Database.executeBatch(new SFSPortal_Batch_ResendToExcelaEmail(), 1);
            
        Test.stopTest();  
    }
}