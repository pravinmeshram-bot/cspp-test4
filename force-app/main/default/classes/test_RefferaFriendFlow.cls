@isTest
public class test_RefferaFriendFlow{

private static testMethod void testNew1() {
        //Call Mock for thr Client data
        list<Id> programId=new list<Id>();
        Test.startTest();
       // Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
        //nu_dse__TradeLine__c objTradeLine = [select id from nu_dse__TradeLine__c limit 1];
       // system.debug('line 11'+ objTradeLine );
        test.stopTest();
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '45Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
       system.runAs(u1){
        
           
        //Create Account Object
        /*Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        //objNewCreditorAccount.PersonMailingState = 'CA';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);*/
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678' 
        );
 
        insert acc;
        
        // create portfolio
        Portfolio__c p = new Portfolio__c();
       // p.LastName='test';
        p.Communication_Template_Email__c='test@test.com';
        p.Linkedin_URL__c ='www.test.com';
        p.Active_Status__c=true;
        insert p;
        System.assertNotEquals(p.id,null);
               
         //Create Program Object
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        objProgram.Portfolio__c=p.id;
        objProgram.nu_dse__Account__c=acc.id;
        Database.Insert(objProgram);
        programId.add(objProgram.id);
        System.debug('objProgram'+objProgram);
        
      
        } 
     RefferaFriendFlow.sendMail(programId);


}
}