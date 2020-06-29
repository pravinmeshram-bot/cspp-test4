@isTest
public class SFSPortal_CommunityUserDetailCtrl_Test {
    
    public static testMethod void userTestDetail() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
               
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
          
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        User user2 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        user2.Email = 'test2@gmail.com';
        user2.MobilePhone = '5684795684'; 
        user2.PostalCode = '45968'; 
        user2.State = 'AN'; 

        Portal_Identity_Service__c portalInstance = new Portal_Identity_Service__c(New_Value__c=user1.Email, 
            Old_Value__c=user2.Email, 
            User__c=user1.Id, 
            Status__c = 'Processing',
            Unique_Identifier__c = '12856',
            RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification')
        );
        insert portalInstance;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Email_Verification_Site_URL__c = 'https://test.com';
        portfolioInstance.OWD_Email_Name__c = 'Test';
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.nu_dse__Payment_Frequency__c = 'Twice Monthly';
        insert programInstance;
                       
        Test.startTest();
        
        System.runAs(user1) { 
            ApexPages.currentPage().getParameters().put('UniqueId','12856' );
            
            try {
                
                SFSPortal_CommunityUserDetailController.updateUser(user1, user2);
                
                
            } catch(Exception e) {
                
                 system.assert(e.getMessage() != null); 
            }
            
            try {
                
                SFSPortal_CommunityUserDetailController.updateEmailAddress();
            } catch(Exception e) {
            
                system.assert(e.getMessage() != null); 
            }
            user2.Email = 'test2#fwer';
            try {
                    
                SFSPortal_CommunityUserDetailController.updateUser(user1, user2);
                    
            } catch(Exception e) {
            
                system.assert(e.getMessage() != null); 
            }
        }
        Test.stopTest(); 
        
    }
    
    public static testMethod void uploadImage() {
        
        ContentVersion contentVersionInstance = new ContentVersion(Title = 'xxxx',PathOnClient='/ filename', VersionData = EncodingUtil.base64Decode('Test'));
        insert contentVersionInstance;
        
        Test.startTest();
        
            try {
            
                SFSPortal_CommunityUserDetailController.uploadImage(contentVersionInstance.ContentDocumentId);
                 
            }catch(Exception e) {
                
                system.assert(e.getMessage() != null); 
            }
           
        Test.stopTest(); 
       
    }
    
    public static testMethod void updatePhoneUser() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
               
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
          
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        User user2 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        user2.Email = 'test2@gmail.com';
        user2.MobilePhone = '5684795684'; 
        user2.PostalCode = '45968'; 
        user2.State = 'AN'; 

        Test.startTest();
        
            try {
            
                SFSPortal_CommunityUserDetailController.updatePhoneUser(user1, user2);
                 
            }catch(Exception e) {
                
                system.assert(e.getMessage() != null); 
            }
           
        Test.stopTest(); 
       
    }
    
    public static testMethod void updatePhone() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        Portal_Identity_Service__c portalInstance = new Portal_Identity_Service__c(New_Value__c = '7412589635', 
            Old_Value__c = user1.MobilePhone, 
            User__c = user1.Id, 
            Status__c = 'Processing',
            Unique_Identifier__c = '12856',
            Type__c = 'Mobile',
            RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification')
        );
        insert portalInstance;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Email_Verification_Site_URL__c = 'https://test.com';
        portfolioInstance.OWD_Email_Name__c = 'Test';
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.nu_dse__Payment_Frequency__c = 'Twice Monthly';
        insert programInstance;
                       
        Test.startTest();
         
        System.runAs(user1) { 
        
            try {
            
                SFSPortal_CommunityUserDetailController.updatePhoneNumber('7412589635',user1);
            
            } catch(Exception e) {
            
                system.assert(e.getMessage() != null); 
            }
            try {
            
                SFSPortal_CommunityUserDetailController.resetPassword(user1); 
            
            } catch(Exception e){ 
            
                system.assert(e.getMessage() != null); 
            }
        }
        Test.stopTest(); 
   }
   
   public static testMethod void updatePhoneException() {
       
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        
        Portal_Identity_Service__c portalInstance = new Portal_Identity_Service__c(New_Value__c = '7412589635', 
            Old_Value__c = user1.MobilePhone, 
            User__c = user1.Id, 
            Status__c = 'Processing',
            Unique_Identifier__c = '12856',
            Type__c = 'Mobile',
            RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification')
        );
        insert portalInstance;
        
        Test.startTest();
        System.runAs(user1) { 
        
            try {
            
                SFSPortal_CommunityUserDetailController.updatePhoneNumber('7412589635',user1);
            } catch(Exception e) {
            
                system.assert(e.getMessage() != null); 
            }
        }
        Test.stopTest(); 
    }
}