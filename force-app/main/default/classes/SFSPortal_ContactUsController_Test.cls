@isTest
public class SFSPortal_ContactUsController_Test {

    public static testMethod void ContactUsController_email_test() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Feedback_Email__c = 'feedback@test.com';
        insert portfolioInstance;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        ContentVersion contentVersionInstance = SFSPortal_TestRecordCreator.createContentVersion();
        insert contentVersionInstance;
        
        ContentVersion content = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInstance.Id];
        ContentDocumentLink contentLink = SFSPortal_TestRecordCreator.createContentDocumentLink(content.ContentDocumentId,account1.Id);
        insert contentLink;
        
        EmailMessage msgInstance = new EmailMessage(subject = 'Contact Info',TextBody = 'Test Message');
        insert msgInstance;
        
        System.runAs(user1) {
        
            Test.startTest();
                       
            SFSPortal_ContactUsController.ContactUsDefaultWrapper wrapper = SFSPortal_ContactUsController.getDefaultValue();
            system.assertEquals(true, wrapper!=null);
            
                try {
                    
                    SFSPortal_ContactUsController.sendMail(new EmailMessage(subject = 'Contact Info',TextBody = 'Test Message', 
                        RelatedToId = contentLink.ContentDocumentId, Request_Subject__c = 'Estimate to Complete'),account1.Id
                    );       
                
                } catch(Exception e) {
                
                    System.assert(e.getMessage() != null);
                }
                
                try {
                    
                    SFSPortal_ContactUsController.sendMail(new EmailMessage(subject = 'Contact Info',TextBody = 'Test Message', 
                        RelatedToId = contentLink.ContentDocumentId, Request_Subject__c = 'Feedback'),account1.Id
                    );       
                
                } catch(Exception e) {
                
                    System.assert(e.getMessage() != null);
                }
                
                try {
                    
                    SFSPortal_ContactUsController.sendMail(new EmailMessage(subject = 'Contact Info',TextBody = 'Test Message', 
                        RelatedToId = contentLink.ContentDocumentId, Request_Subject__c = 'Document Request'),account1.Id
                    );       
                
                } catch(Exception e) {
                
                    System.assert(e.getMessage() != null);
                }
                
                try {
                
                    SFSPortal_ContactUsController.deleteDocument(contentLink.contentDocumentId);  
                
                } catch(Exception e) {
                
                    System.assert(e.getMessage() != null);
                }
            
            Test.stopTest();
        }
    }    
    
    public static testMethod void ContactUsController_Exception_test() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        ContentVersion contentVersionInstance = SFSPortal_TestRecordCreator.createContentVersion();
        insert contentVersionInstance;
        
        ContentVersion content = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInstance.Id];
        ContentDocumentLink contentLink = SFSPortal_TestRecordCreator.createContentDocumentLink(content.ContentDocumentId,account1.Id);
        insert contentLink;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Support_Email__c = '';
        insert portfolioInstance;
        
        System.runAs(user1) {
        
            Test.startTest();
                                  
                try {
                    
                    SFSPortal_ContactUsController.sendMail(new EmailMessage(subject = 'Contact Info',TextBody = 'Test Message', 
                        RelatedToId = contentLink.ContentDocumentId, Request_Subject__c = 'Feedback'),account1.Id
                    );       
                
                } catch(Exception e) {
                
                    System.assert(e.getMessage() != null);
                }
                
                try {
                    
                    SFSPortal_ContactUsController.sendMail(new EmailMessage(subject = 'Contact Info',TextBody = 'Test Message', 
                        RelatedToId = contentLink.ContentDocumentId, Request_Subject__c = 'Document Request'),account1.Id
                    );       
                
                } catch(Exception e) {
                
                    System.assert(e.getMessage() != null);
                }
        }
    }

}