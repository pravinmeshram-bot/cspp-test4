@IsTest
public with sharing class SFSPortal_LightningLoginFormCtrlTest {

 @isTest
 static void testLoginWithInvalidCredentials() {
    
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
    insert portfolioInstance;
    
    nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account.Id,null);
    insert programInstance;
    
    Test.startTest();
        String invalidUser = SFSPortal_LightningLoginFormController.login('testing', 'fakepwd', null, portfolioInstance.Domain_URL__c, '', '');
        String withNoPortfolio = SFSPortal_LightningLoginFormController.login(user1.username, 'fakepwd', null, portfolioInstance.Domain_URL__c, '', '');
        
        programInstance.Portfolio__c = portfolioInstance.Id;
        update programInstance;
        String successClient = SFSPortal_LightningLoginFormController.login(user1.username, 'fakepwd', null, portfolioInstance.Domain_URL__c, '', '');
        
        Test.setMock(HttpCalloutMock.class, new SFSPortal_TaskHandler_Test());
        Map<String, String> onesignal = new Map<String, String>{'oneSignalUserId' => 'abcd-123-abcd'};
        List<nu_dse__Program__c> programList = [SELECT Id, SFSPortal_OneSignal_App_Id__c FROM nu_dse__Program__c];
        String successOneSignalClient = SFSPortal_LightningLoginFormController.login(user1.username, 'fakepwd', null, portfolioInstance.Domain_URL__c, '', JSON.serialize(onesignal));
        SFSPortal_LightningLoginFormController.updateProgram('abcd-123-abcd', programList);
        
        String successCoClient = SFSPortal_LightningLoginFormController.login(user2.username, 'fakepwd', null, portfolioInstance.Domain_URL__c, '', '');
        String invalidDomain = SFSPortal_LightningLoginFormController.login(user1.username, 'fakepwd', null, 'testdomain', '', '');
        String withNoPaswwordAndUsername = SFSPortal_LightningLoginFormController.login(null, null, null, portfolioInstance.Domain_URL__c, '', '');
    Test.stopTest();
    system.assertEquals('Invalid UserName.<br/>', invalidUser);
    List<nu_dse__Program__c> programList1 = [SELECT Id, SFSPortal_OneSignal_App_Id__c FROM nu_dse__Program__c];
    system.assertEquals('abcd-123-abcd', programList1[0].SFSPortal_OneSignal_App_Id__c );
    //system.assertEquals('We cannot locate the record based on the information.<br/>', withNoPortfolio);
    //system.assertEquals('You are not eleigible to login from this domain.<br/>', invalidDomain);
    //system.assertEquals('Enter UserName. <br/>Enter Password. <br/>', withNoPaswwordAndUsername);
 }

 @isTest(SeeAllData=true)
 static void SFSPortal_LightningLoginFormControllerInstantiation() {
    SFSPortal_LightningLoginFormController controller = new SFSPortal_LightningLoginFormController();
    System.assertNotEquals(controller, null);
 }

 @isTest
 static void LightningForgotPasswordExpiration() {
 
    Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
    insert account1;
    
    system.assertEquals(null, SFSPortal_LightningLoginFormController.setExperienceId(null));           
    SFSPortal_LightningLoginFormController.setExperienceId(account1.Id);
 }
 
 @isTest(SeeAllData=true)
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, SFSPortal_LightningLoginFormController.getIsUsernamePasswordEnabled());
 }
 
 @isTest(SeeAllData=true)
 static void testIsForgotPasswordUrl() {
  String forgetPasswordURL = SFSPortal_LightningLoginFormController.getForgotPasswordUrl();
  System.assertEquals(true, forgetPasswordURL != null);
 }
 
 @IsTest
 static void testIsSelfRegistrationEnabled() {
 system.debug('****^^^^^^**'+SFSPortal_LightningLoginFormController.getIsSelfRegistrationEnabled());
  //System.assertEquals(true, SFSPortal_LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @isTest(SeeAllData=true)
 static void testGetSelfRegistrationURL() {
  SFSPortal_LightningLoginFormController.getSelfRegistrationUrl();
  system.debug('**^^^^^^****'+SFSPortal_LightningLoginFormController.getSelfRegistrationUrl());
  //System.assertEquals(null, SFSPortal_LightningLoginFormController.getSelfRegistrationUrl());
 }

 @isTest(SeeAllData=true)
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = SFSPortal_LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
}