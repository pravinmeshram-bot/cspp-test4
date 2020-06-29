@isTest 
public class Test_SFSPortal_PortalIdentityService {
 private static testMethod void testNew1() {
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'System_Admin' LIMIT 1];
Profile profile_1 = [SELECT Id FROM Profile WHERE Name = 'Timberline Client' LIMIT 1];
User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole_1.Id LIMIT 1];
User user_1;
System.runAs(admin) {
  Account account_1 = new Account( Name = 'Community'  );
  insert account_1;
  
  Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
  insert contact_1;
  
  user_1 = new User( 
    Email = 'yourusername@gmail.com',
    ProfileId = profile_1.Id, 
    UserName = 'yourusername@gmail.com', 
    Alias = 'Test',
    TimeZoneSidKey = 'America/New_York',
    EmailEncodingKey = 'ISO-8859-1',
    LocaleSidKey = 'en_US', 
    LanguageLocaleKey = 'en_US',
    ContactId = contact_1.Id,
    PortalRole = 'Manager',
    FirstName = 'Firstname',
    LastName = 'Lastname'
  );
  insert user_1;
  
  user usr= new user();
  usr.id=user_1.id;
  usr.Email ='Test@test.com';
  //update usr;
}
Test.startTest();
 Portal_Identity_Service__c p = new Portal_Identity_Service__c();
System.runAs(user_1) {
  System.assertEquals(UserInfo.getUserId(), user_1.Id);
  // your test code for Salesforce Community

  
   Id RecordTypeIdCO = Schema.SObjectType.Portal_Identity_Service__c.getRecordTypeInfosByName().get('Identity Verification').getRecordTypeId();
   
    p.Description__c='test';
    p.recordtypeid=RecordTypeIdCO ;
    p.Is_Agent_Sent__c=true;
    p.Status__c='Initiated';
    p.New_Value__c='test';
    p.Old_Value__c='test1';
    p.User__c=user_1.id;
    insert p;
 }
 System.runAs(admin) {
    Portal_Identity_Service__c  p1 = new Portal_Identity_Service__c ();
    p1.id=p.id;
    p1.New_Value__c='ytikkisetti@selastech.com';
    p1.Old_Value__c='test4';
    p1.Status__c='Verified';
    update P1;
    Test.stopTest();
    }
  }
  
}