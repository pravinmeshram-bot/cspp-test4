/***********************************
*@Class Name :Test_Attorney_BankAccountHandler
*@Purpose:It is Used to test the functionlity of the class Attorney_BankAccountHandler
************************************/
@isTest
private class Test_Attorney_BankAccountHandler {
/***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class 
************************************/    
    @TestSetup
    private static void creatData(){
        
        //Adding the mock for Account Trigger
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_BankAccountHandler.LeadTraceNetClientMock());
        Test.stopTest();
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '3Attorney_TestUser@test.com';
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
        //Create the Program Data
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        Database.Insert(objProgram);
        
        nu_dse__Bank_Account__c objBankAccount = new nu_dse__Bank_Account__c();
        objBankAccount.nu_dse__Program__c = objProgram.Id;
        Database.Insert(objBankAccount);
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
    }
    }
/***********************************
*@Method Name :  test_CreateOrUpdateNDSBankAccount
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSBankAccount.
************************************/
    private static testMethod void test_CreateOrUpdateNDSBankAccount(){
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true limit 1];
        nu_dse__Bank_Account__c objBankAccount = [select id,CampaignId__c from nu_dse__Bank_Account__c Limit 1];
     //   objBankAccount.Attorney__c = false;
        
        System.runAs(objUser){
            Test.startTest();
        objBankAccount.nu_dse__Account_Type__c = 'TestAccountType';
        objBankAccount.nu_dse__Bank_Account_Number__c = '123456';
        objBankAccount.nu_dse__City__c = 'TestCity';
        objBankAccount.nu_dse__Bank_Name__c = 'TestBankName';
        objBankAccount.nu_dse__Telephone__c = 'TestBankName';
        objBankAccount.nu_dse__Routing_Number__c = '1234';
        objBankAccount.nu_dse__State__c = 'TestState';
        objBankAccount.nu_dse__Zip__c = '765654';
        Database.Update(objBankAccount);
        
        nu_dse__Bank_Account__c objOldBankAccount = new nu_dse__Bank_Account__c();
        objOldBankAccount = objBankAccount.clone();
        objOldBankAccount.Id = objBankAccount.Id;
        objOldBankAccount.nu_dse__Holder_s_Name__c = 'HolderName';
        objOldBankAccount.Import_ID__c = '34543543';
        objOldBankAccount.nu_dse__Account_Type__c = 'AccountType';
        objOldBankAccount.nu_dse__Bank_Account_Number__c = '12345';
        objOldBankAccount.nu_dse__City__c = 'City';
        objOldBankAccount.nu_dse__Bank_Name__c = 'BankName';
        objOldBankAccount.nu_dse__Telephone__c = 'BankName';
        objOldBankAccount.nu_dse__Routing_Number__c = '1234';
        objOldBankAccount.nu_dse__State__c = 'State';
        objOldBankAccount.nu_dse__Zip__c = '65654';
        
        Database.Update(objOldBankAccount);
        
        List<nu_dse__Bank_Account__c>lstBankAccount = new List<nu_dse__Bank_Account__c> ();
        lstBankAccount.add(objBankAccount);
        
        Map<id,nu_dse__Bank_Account__c>bankAccountMap=  new Map<id,nu_dse__Bank_Account__c>();
        bankAccountMap.put(objOldBankAccount.Id,objOldBankAccount);
        
        
          
                
                Test.setMock(WebServiceMock.Class, new Test_Attorney_BankAccountHandler.LeadTraceNetClientBankAccountMock());
                Attorney_BankAccountHandler.CreateOrUpdateNDSBankAccount(lstBankAccount,bankAccountMap);
                Test.stopTest();
          
        }
        System.assert(true);
    }
/***********************************
*@Class Name :LeadTraceNetClinetMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/9/2018
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
/***********************************
*@Class Name :LeadTraceNetClientBankAccountMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/9/2018
************************************/    
    public without sharing class LeadTraceNetClientBankAccountMock implements WebServiceMock{
        
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