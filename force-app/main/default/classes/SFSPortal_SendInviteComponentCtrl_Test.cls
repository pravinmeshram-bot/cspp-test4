@isTest
public class SFSPortal_SendInviteComponentCtrl_Test {

    @testSetup static void setup() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
               
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Logo_Document_Name__c = 'Timberline_Logo';
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram();
        programInstance.nu_dse__Account__c = account1.Id;
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
    }
    
    public static testMethod void SendInviteComponentController_Client_Test() {
       
        Portfolio__c portfolioClient = [SELECT Id, Domain_URL__c FROM Portfolio__c LIMIT 1];
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        if(portfolioClient != null && program != null) {
        
            Test.startTest();
                SFSPortal_SendInviteComponentController sendInviteInstance = new SFSPortal_SendInviteComponentController();
                sendInviteInstance.isClientEmail = true;
                sendInviteInstance.recordId = program.Id;
                sendInviteInstance.init();
                String url = sendInviteInstance.redirectionURL; 
            Test.stopTest();
            system.assertEquals(true, String.isNotBlank(url));
        }
    }
   
    public static testMethod void SendInviteComponentController_CoClient_Test() {
    
        Account account2 = SFSPortal_TestRecordCreator.createAccount('Test Account 2',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account2;
        
        Account accountInstance = [SELECT Id FROM Account LIMIT 1];
        //accountInstance.Primary_Client__c = account2.Id;
        update accountInstance;
        
        Portfolio__c portfolioCoClient = [SELECT Id, Domain_URL__c FROM Portfolio__c LIMIT 1];
        nu_dse__Program__c program = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
               
        if (portfolioCoClient != null && program != null) {
            
             Test.startTest();
                 SFSPortal_SendInviteComponentController sendInviteInstance = new SFSPortal_SendInviteComponentController();
                 sendInviteInstance.isClientEmail = false;
                 sendInviteInstance.recordId = program.Id;
                 sendInviteInstance.init();
                 String url = sendInviteInstance.redirectionURL; 
             Test.stopTest();
             system.assertEquals(true, String.isNotBlank(url));
        }
    }
    
    /* Unit test case for email template portfolio assignement */
    public static testMethod void emailTemplate_Test() {
       
        Portfolio__c portfolioClient = [SELECT Id, Domain_URL__c FROM Portfolio__c LIMIT 1];
        nu_dse__Program__c program = [SELECT Id, nu_dse__Account__c FROM nu_dse__Program__c LIMIT 1];
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: program.nu_dse__Account__c];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        if(portfolioClient != null && program != null) {
               
            Test.startTest();
                SFSPortal_SendInviteComponentController sendInviteInstance = new SFSPortal_SendInviteComponentController();
                sendInviteInstance.emailType_Email = 'Welcome';
                sendInviteInstance.receiving_UserId = user1.Id;
                
                
            Test.stopTest();
            
        }
    }
}