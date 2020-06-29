@IsTest(SeeAllData = true)
public with sharing class SFSPortal_LtngForgotPasswordCtrlTest {

    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testSFSPortal_LightningForgotPasswordCtrlInvalidUserName() {
        System.assertEquals(SFSPortal_LightningForgotPasswordCtrl.forgotPassword('fakeUser', 'http://a.com'), 'Invalid username');
        System.assertEquals(SFSPortal_LightningForgotPasswordCtrl.forgotPassword(null, 'http://a.com'), 'Username cannot be blank');
        //System.assertEquals(SFSPortal_LightningForgotPasswordCtrl.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
    }
    
    /* Verifies that null checkEmailRef url throws proper exception. 
    @IsTest
    static void testSFSPortal_LightningForgotPasswordCtrlWithNullCheckEmailRef() {
        //System.assertEquals(SFSPortal_LightningForgotPasswordCtrl.forgotPassword('a', null), 'Argument 1 cannot be null');
        //System.assertEquals(SFSPortal_LightningForgotPasswordCtrl.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
    }*/
    
    /* Verifies that SFSPortal_LightningForgotPasswordCtrl object is instantiated correctly. */
    @IsTest
    static void SFSPortal_LightningForgotPasswordCtrlInstantiation() {
        SFSPortal_LightningForgotPasswordCtrl controller = new SFSPortal_LightningForgotPasswordCtrl();
        System.assertNotEquals(controller, null);
    }
 
    @IsTest
    static void LightningForgotPasswordExpiration() {
 
        Account account = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account;
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        //account1.Primary_Client__c = account.Id;
        insert account1;
            
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account.Id];
            
        Contact con1 = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
           
        User user2 = SFSPortal_TestRecordCreator.createCommunityUser(con1.Id);
        user2.username = 'test@test.com';
        insert user2;
        
        String headerdata = URL.getCurrentRequestUrl().toExternalForm();
        List<String> urlValueList = headerdata.split('/apex');
        
        Portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('4569871238');
        portfolioInstance.Domain_URL__c = urlValueList[0];
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Name = 'Timberline';
        insert portfolioInstance;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account.Id,null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Test.startTest();
        
            SFSPortal_LightningForgotPasswordCtrl.forgotPassword('tester@noemail.com', urlValueList[0]);
            SFSPortal_LightningForgotPasswordCtrl.checkUserAccess('tester@noemail.com', urlValueList[0], 'Timberline', urlValueList[0]);
            SFSPortal_LightningForgotPasswordCtrl.setExperienceId(account1.Id);
        Test.stopTest();
    }
}