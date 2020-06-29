/***********************************
*@Class Name :Test_Attorney_createOrupdateNDSClient
*@Purpose:It is Used to test the functionlity of the class Attorney_createOrupdateNDSClient
************************************/
@isTest
private class Test_Attorney_createOrupdateNDSClient {
    
/***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class
************************************/    
@TestSetup
    private static void creatData(){
        
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_createOrupdateNDSClient.LeadTraceNetClientMock());
        Test.stopTest();
        
         User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '2Attorney_TestUser@test.com';
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
        
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
       Account objAccount = New Account();
        objAccount.Salutation = 'Mr.';
        objAccount.FirstName = 'testAccount';
        objAccount.LastName = 'LastName';
        objAccount.RecordTypeId = RecTypeId;
        objAccount.Attorney__c = true;
        Database.Insert(objAccount);
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
    }
    }
    
/***********************************
*@Method Name :  test_createOrupdateNDSClientMeth
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method createOrupdateNDSClientMeth.
************************************/
    private static testMethod void test_createOrupdateNDSClientMeth(){
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true limit 1];
        
        Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId from Account Limit 1];
        objAccount.Attorney__c = true;
        objAccount.campaignId__c = '3432423';
        objAccount.FirstName = 'TestFirstName';
        Database.Update(objAccount);
        
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(objAccount);
        
        Account objOldAccount = new Account();
        objOldAccount = objAccount.clone();
        objOldAccount.Salutation = 'Mr.';
        objOldAccount.FirstName = 'TestFirstName';
        objOldAccount.LastName = 'TestLastName';
        objOldAccount.Attorney__c = false;
        objOldAccount.PersonMailingStreet = 'TestStreet';
        objOldAccount.PersonMobilePhone = '8787678767';
        objOldAccount.PersonMailingCity = 'TestCity';
        objOldAccount.PersonEmail = 'Test@Test.com';
        objOldAccount.PersonHomePhone = '7876787678';
        objOldAccount.PersonMailingState = 'TestState';
        objOldAccount.nu_dse__Work_Phone__c = '6767878989';
        objOldAccount.PersonMailingPostalCode = '434543';
        objOldAccount.Fax = '4354353434';
        objOldAccount.Contact_Preference__c = 'Test';
        objOldAccount.PersonOtherPhone = '9876543210';
        objOldAccount.Best_Time__c = '12.34';
        objOldAccount.Sales_Rep__c = 'TestSalesRep';
        objOldAccount.Co_Drivers_License__c = 'fere343432';
        objOldAccount.Co_Drivers_License_State__c = 'DriverState';
        objOldAccount.Employer_Name__c = 'TestEmployer';
        objOldAccount.Occupation__c = 'TestOccuoation';
        objOldAccount.nu_dse__Co_Address_Line__c = 'TestAddressLine';
        objOldAccount.nu_dse__SSN__c = 'TestSSN';
        objOldAccount.Best_Day__c = 'Sunday';
        objOldAccount.CampaignId__c = '23423432';
        objOldAccount.Id = objAccount.Id;
        Database.Update(objOldAccount);
        
        Map<id,Account>accountOldMap = new Map<id,Account>();
        accountOldMap.put(lstAccount[0].id,objOldAccount);
        System.runAs(objUser){
          
            Test.startTest();
            Test.setMock(WebServiceMock.Class, new Test_Attorney_createOrupdateNDSClient.LeadTraceNetClientMock());
            Attorney_createOrupdateNDSClientHandler.createOrupdateNDSClientMeth(lstAccount,accountOldMap);
            Test.stopTest();
           
        }
        System.assert(true);
    }
/***********************************
*@Class Name :LeadTraceNetClinetMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/19/2018
************************************/    
    public without sharing class LeadTraceNetClientMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            
            leadtracNetClient.CreateOrUpdateClientResponse_element respElement =new leadtracNetClient.CreateOrUpdateClientResponse_element();
            respElement.CreateOrUpdateClientResult = 'TestResult';
            response.put('response_x', respElement);
            
        }
    } 
}