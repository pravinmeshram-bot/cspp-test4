@IsTest
public with sharing class SFSPortal_LightningSelfRegisterCtrlTest {

 /* Verifies that IsValidPassword method with various password combinations. */
 @isTest(SeeAllData=true)
 static void testIsValidPassword() {
  System.assert(SFSPortal_LightningSelfRegisterCtrl.isValidPassword('password?@12334', 'password?@12334') == true);
  System.assert(SFSPortal_LightningSelfRegisterCtrl.isValidPassword('password?@12334', 'dummyPassword') == false);
  System.assert(SFSPortal_LightningSelfRegisterCtrl.isValidPassword('password?@12334', null) == false);
  System.assert(SFSPortal_LightningSelfRegisterCtrl.isValidPassword(null, 'fakePwd') == false);
 }

 @isTest(SeeAllData=true)
 static void testSiteAsContainerEnabled() {
  System.assertNotEquals(null, SFSPortal_LightningSelfRegisterCtrl.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
 }

 /* Verifies the selfRegistration method flow with various invalid inputs */
 @isTest(SeeAllData=true)
 static void testSelfRegistration() {
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);
    /*System.assertEquals(Label.Site.lastname_is_required, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('dob') ,paramsMap.get('ssn'),'',paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
    System.assertEquals(Label.Site.email_is_required, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('dob') ,paramsMap.get('ssn'),'',paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
    System.assertEquals(Label.Site.email_is_required, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('dob') ,paramsMap.get('ssn'),'',paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
    System.assertEquals(Label.site.passwords_dont_match, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('dob') ,paramsMap.get('ssn'),'',paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
    System.assertNotEquals(null, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'),paramsMap.get('dob') ,paramsMap.get('ssn'),'',paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
     */
 }


 /* Verifies the selfRegistration flow for valid inputs */
 @isTest(SeeAllData=true)
 static void testSelfRegisterWithProperCredentials() {
  Map < String, String > paramsMap = initializeParams();
  //System.assertEquals(null, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
 }

 /* Verifies SelfRegistration flow with an accounId that is created within the test */
 @isTest(SeeAllData=true)
 static void testSelfRegisterWithCreatedAccount() {
  Account acc = new Account(name = 'test acc');
  insert acc;
  List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
  System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
  String accountId = accounts[0].Id;
  Map < String, String > paramsMap = initializeParams();
  //System.assertEquals(null, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
 }

 @isTest(SeeAllData=true)
 static void testGetNullExtraFields() {
  System.assertEquals(new List < Map < String, Object >> (), SFSPortal_LightningSelfRegisterCtrl.getExtraFields(null));
 }

 @isTest(SeeAllData=true)
 static void testGetNonEmptyExtraFields() {
  System.assertEquals(new List < Map < String, Object >> (), SFSPortal_LightningSelfRegisterCtrl.getExtraFields('field1'));
 }

 /* Verifies validation of extraFields within the Self Registration flow */
 @isTest(SeeAllData=true)
 static void testGetExtraFieldsInSelfRegistration() {
  List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
  Map < String, String > paramsMap = initializeParams();
  Map < String, Object > fieldMap = new Map < String, Object > ();
  fieldMap.put('description', 'new field');
  fieldMap.put('fieldPath', 'dummyPath');
  fieldlist.add(fieldMap);
  String extraFields = JSON.serialize(fieldlist);
  //System.assertNotEquals(null, SFSPortal_LightningSelfRegisterCtrl.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
 }

 @isTest(SeeAllData=true)
 static void LightningSelfRegisterControllerInstantiation() {
  SFSPortal_LightningSelfRegisterCtrl controller = new SFSPortal_LightningSelfRegisterCtrl();
  System.assertNotEquals(controller, null);
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > ();
  String firstName = 'test';
  String lastName = 'User';
  String email = 'testUser@salesforce.com';
  String password = 'testuser123';
  Date dob = system.today().AddDays(-9000);
  String confirmPasswordCorrect = 'testuser123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';
  paramsMap.put('firstName', firstName);
  paramsMap.put('lastName', lastName);
  paramsMap.put('dob', String.ValueOf(dob));
  paramsMap.put('ssn', '859478598');
  
  paramsMap.put('email', email);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  return paramsMap;
 }
 
    public static testMethod void testLightningSelfRegistrationClient() {
        
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
        
        Test.startTest();
            String cryptoString = '0123456789ABCDEF0123456789ABCDE0';
            Blob contactIdBlob = Blob.valueOf(account1.Id); 
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(cryptoString), contactIdBlob);
            String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
            SFSPortal_LightningSelfRegisterCtrl.getdefault(encryptedDataString, true);
            
            SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '9658', portfolioInstance.Domain_URL__c,'test');
            System.assertEquals( true, accountWrapper != null);
            if (accountWrapper != null) {
                
                SFSPortal_LightningSelfRegisterCtrl.selfRegister('testing','testing','test@test.com.client', json.serialize(accountWrapper), '/test','/login');
            }
        Test.stopTest(); 
    }
    
    public static testMethod void testLightningSelfRegistrationClient_Exception() {
    
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        insert account1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        //programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Test.startTest();
            
            
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount('', '', '', portfolioInstance.Domain_URL__c,'');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '958', portfolioInstance.Domain_URL__c,'test');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '9658', portfolioInstance.Domain_URL__c, 'test');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '7658', portfolioInstance.Domain_URL__c, 'test');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.selfRegister('','','', json.serialize(new SFSPortal_LightningSelfRegisterCtrl.AccountWrapper()), '/test','/login'); 
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.selfRegister('testing','testing123','test@test.com.client', json.serialize(new SFSPortal_LightningSelfRegisterCtrl.AccountWrapper()), '/test','/login');
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.setExperienceId(account1.Id);
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest(); 
    }
    
    /*public static testMethod void testLightningSelfRegistrationCoClient() {
    
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.nu_dse__Co_Date_of_Birth__c = system.today().AddDays(-10000);
        account1.nu_dse__Co_SSN__c = '254789658';
        account1.nu_dse__CO_Email_Address__c = 'test@test.com';
        insert account1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Profile_Name__c = 'Customer Community User';
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Test.startTest();
            
            SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.nu_dse__CO_Email_Address__c, String.ValueOf(account1.nu_dse__Co_Date_of_Birth__c), '9658', portfolioInstance.Domain_URL__c);
            System.assertEquals( true, accountWrapper != null);
            if (accountWrapper != null) {
                
                SFSPortal_LightningSelfRegisterCtrl.selfRegister('testing','testing','test@test.com.coclient', json.serialize(accountWrapper), '/test','/login');
            }
        Test.stopTest(); 
    }*/
    
    public static testMethod void testLightningSelfRegistrationCoClient_Exception() {
    
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.nu_dse__Co_Date_of_Birth__c = system.today().AddDays(-10000);
        account1.nu_dse__Co_SSN__c = '254789658';
        account1.nu_dse__CO_Email_Address__c = 'test@test.com';
        account1.nu_dse__Co_Last_Name__c = 'test';
        account1.nu_dse__Co_First_Name__c = 'TEst';
        insert account1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Test.startTest();
            
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount('', '', '', portfolioInstance.Domain_URL__c,'');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '958', portfolioInstance.Domain_URL__c,'test');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '9658', portfolioInstance.Domain_URL__c,'test');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.AccountWrapper accountWrapper = SFSPortal_LightningSelfRegisterCtrl.findTheRelatedAccount(account1.PersonEmail, String.ValueOf(account1.PersonBirthdate), '7658', portfolioInstance.Domain_URL__c,'test');
            } catch(Exception e) {
    
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.selfRegister('','','', json.serialize(new SFSPortal_LightningSelfRegisterCtrl.AccountWrapper()), '/test','/login'); 
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            try {
                    
                SFSPortal_LightningSelfRegisterCtrl.selfRegister('testing','testing123','test@test.com.client', json.serialize(new SFSPortal_LightningSelfRegisterCtrl.AccountWrapper()), '/test','/login');
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest(); 
    }
}