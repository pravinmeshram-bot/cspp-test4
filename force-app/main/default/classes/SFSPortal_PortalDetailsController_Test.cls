/* Date : 05-03-2019
 * Author : Team IDev
 * Description : Unit test cases for Portal details controller
 */
@isTest
public class SFSPortal_PortalDetailsController_Test {
    
    @testsetup static void setupTestData() {
        
        List<Account> accountList = new List<Account>();
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.Phone = '1231231231';
        account1.nu_dse__Home_Phone__c = null;
        
        accountList.add(account1);
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor');
        
        Account account2 = new Account(Name = 'Test',RecordTypeId = recordTypeId);
        account1.Phone = '1231231231';
        accountList.add(account2);
        
        insert accountList;
        
        List<OrgWideEmailAddress> OrgWideEmailInst = [SELECT Id, DisplayName FROM OrgWideEmailAddress LIMIT 1];
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Name = 'Canyon';
        
        if (OrgWideEmailInst.isEmpty() == False) {
            
            portfolioInstance.OWD_Email_Name__c = OrgWideEmailInst[0].DisplayName;
        }
        
        insert portfolioInstance;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.Invitation_Attempt__c = 'Re-Invitation 1';
        insert programInstance;
        
        Account accInstance = [SELECT Id, PersonContactId FROM Account WHERE Id = :account1.Id];
        
        nu_dse__Group_Task__c  gtInstance = SFSPortal_TestRecordCreator.groupTaskInstance(programInstance.Id, 'Request to add a new tradeline');
        nu_dse__Group_Task__c  bankGTInstance = SFSPortal_TestRecordCreator.groupTaskInstance(programInstance.Id, 'Request to update bank info');
        
        List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>();
        groupTaskList.add(gtInstance);
        groupTaskList.add(bankGTInstance);
        
        insert groupTaskList;
        
        nu_dse__TradeLine__c tradelineInst = SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id);
        tradelineInst.SFS_Current_Balance__c = 1;
        insert tradelineInst;
    }
    
    public static testMethod void initTest1() {
        
        Test.startTest();
            
            List<nu_dse__Program__c> programListInst = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
            List<nu_dse__TradeLine__c> tradelineList = [SELECT Id FROM nu_dse__TradeLine__c LIMIT 1];
            
            Account accountInstance = [SELECT Id, PersonContactId FROM Account WHERE RecordType.DeveloperName = 'Client' LIMIT 1];
            
            User userInstance = SFSPortal_TestRecordCreator.createCommunityUser(accountInstance.PersonContactId);
            insert userInstance;
            
            nu_dse__Offer__c offerInstance = new nu_dse__Offer__c();
            //SFSPortal_TestRecordCreator.createoffer(, , 2500, 1000, 4, 6);
            offerInstance.LastModifiedById = userInstance.Id;
            offerInstance.nu_dse__TradeLine__c = tradelineList[0].Id;
            offerInstance.nu_dse__Program__c = programListInst[0].Id;
            offerInstance.nu_dse__Offer_Amount__c = 2500;
            offerInstance.nu_dse__Status__c = 'None';
            insert offerInstance;
            ///////////////////////////////////
            
            nu_dse__Payment__c paymentInst = SFSPortal_TestRecordCreator.createPayments(programListInst[0].Id);
            paymentInst.Decision_Source__c = 'Portal';
            insert paymentInst;
            
            SFSPortal_PortalDetailsController controllerInst = new SFSPortal_PortalDetailsController();
            controllerInst.programId = programListInst[0].Id;
            
            ApexPages.currentPage().getParameters().put('selctedMode', 'Email');
            
            controllerInst.sendVerificationCodeToClient();
            
            ApexPages.currentPage().getParameters().put('selctedMode', 'Mobile');
            
            controllerInst.sendVerificationCodeToClient();
            
        Test.stopTest();
    }
    
    public static testMethod void initTest2() {
        
        Test.startTest();
        
            List<nu_dse__Program__c> programListInst = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
            List<nu_dse__TradeLine__c> tradelineList = [SELECT Id FROM nu_dse__TradeLine__c LIMIT 1];
            
            Account accountInstance = [SELECT Id, PersonContactId FROM Account WHERE RecordType.DeveloperName = 'Client' LIMIT 1];
            
            User userInstance = SFSPortal_TestRecordCreator.createCommunityUser(accountInstance.PersonContactId);
            insert userInstance;
            
            nu_dse__Offer__c offerInstance = SFSPortal_TestRecordCreator.createoffer(programListInst[0].Id, tradelineList[0].Id, 2500, 1000, 4, 6);
            offerInstance.LastModifiedById = userInstance.Id;
            insert offerInstance;
                
            nu_dse__Payment__c paymentInst = SFSPortal_TestRecordCreator.createPayments(programListInst[0].Id);
            paymentInst.Decision_Source__c = 'Portal';
            insert paymentInst;
            
            SFSPortal_PortalDetailsController controllerInst = new SFSPortal_PortalDetailsController();
            controllerInst.programId = programListInst[0].Id;
            
            ApexPages.currentPage().getParameters().put('selctedMode', 'Email');
            
            controllerInst.sendVerificationCodeToClient();
            
            ApexPages.currentPage().getParameters().put('selctedMode', 'Mobile');
            
            controllerInst.sendReInvitationToClient();
            
        Test.stopTest();
    }
}