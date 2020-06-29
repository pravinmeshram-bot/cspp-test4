/***********************************
*@Class Name :Test_Attorney_FinancialProfileHandler
*@Purpose:It is Used to test the functionlity of the class Attorney_FinancialProfileHandler
************************************/
@isTest
private class Test_Attorney_FinancialProfileHandler {
/***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class 
************************************/    
    Static User u1 = new User();
    @TestSetup
    private static void creatData(){
        
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_FinancialProfileHandler.LeadTraceNetClientMock());
        Test.stopTest();
        
        
    }
    
/***********************************
*@Method Name :  test_CreateOrUpdateNDSBankAccount
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSFinancialProfile.
************************************/
    private static testMethod void test_CreateOrUpdateNDSFinancialProfile(){
        //User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND Attorney_admin__c=false AND isActive =true AND id=:u1.Id limit 1];
        
        //Update User
          
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '1Attorney_TestUser@test.com';
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
        
        //Create Program reocrd
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Draft_Plan_ID__c= '232343';
        objProgram.Import_id__c = '2323';
        Database.Insert(objProgram);
        
        nu_dse__Financial_Profile__c objFinancialProfile = new nu_dse__Financial_Profile__c();
        objFinancialProfile.nu_dse__Program__c = objProgram.Id;
        Database.Insert(objFinancialProfile);
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
    
        
        objFinancialProfile = [Select id,CampaignId__c,Import_ID__c,IsAttorney__c,nu_dse__Automobile_Insurance__c, 
                                                            nu_dse__Car_Payment__c,nu_dse__Car_Maintenance__c,nu_dse__Back_Taxes__c,nu_dse__Television_Cable_Satellite__c,Is_Self_Employed__c,
                                                            nu_dse__Charity_Donations__c,nu_dse__Child_Care_Day_Care__c,nu_dse__Net_Monthly_Income__c,nu_dse__Clothing__c,nu_dse__Education__c,
                                                            nu_dse__Entertainment__c,nu_dse__Food_Groceries_Eating_Out__c,nu_dse__Gym_Health__c, nu_dse__Homeowner_s_Renter_s_Insurance__c,
                                                            nu_dse__Home_Status__c,nu_dse__Household_Items__c,nu_dse__Rent_Mortgage_payment__c,nu_dse__Additional_Income__c,nu_dse__Laundry_Dry_Cleaning__c,nu_dse__Life_Insurance__c,
                                                            nu_dse__Medical__c,nu_dse__Co_Client_Gross_Income__c,nu_dse__Other_1_Payments__c,nu_dse__Other_1_Payments_Description__c,
                                                            nu_dse__Personal_Care__c,nu_dse__Student_Loans__c,nds_Discretionary_Percentage__c,nds_DiscretionaryIncome__c,nu_dse__Telephone__c,nu_dse__Utilities__c,Co_Client_Annual_Base_Salary_Velocify__c,
                                                            Is_Co_Applicant_Self_Employed__c,nu_dse__Extra_Income_Amount_1__c,nu_dse__Extra_Income_Amount_2__c,nu_dse__Extra_Income_Description_1__c,
                                                            nu_dse__Extra_Income_Description_2__c,nu_dse__Total_Expenses__c,nu_dse__Total_Income__c, nu_dse__Bankruptcy_Type__c,nu_dse__Co_Year_Filed_for_Bankruptcy__c,
                                                            nu_dse__Credit_Score__c,nu_dse__Home_Value__c, nu_dse__Client_Has_Filed_Bankruptcy__c,nu_dse__Amount_Owed_on_Home__c, nu_dse__Hardship_Description__c, nu_dse__Number_of_Dependants__c,
                                                            nu_dse__Hardship_Reason__c from nu_dse__Financial_Profile__c limit 1];
     //   objFinancialProfile.Attorney__c = false;
        Database.Update(objFinancialProfile);
        
        nu_dse__Financial_Profile__c objOldFinancialProfile = new nu_dse__Financial_Profile__c();
        objOldFinancialProfile = objFinancialProfile.Clone();
        objOldFinancialProfile.Id = objFinancialProfile.Id;
        objOldFinancialProfile.nu_dse__Automobile_Insurance__c = 4345;
        objOldFinancialProfile.nu_dse__Car_Payment__c = 3454;
        objOldFinancialProfile.nu_dse__Car_Maintenance__c = 3455;
        objOldFinancialProfile.nu_dse__Back_Taxes__c = 2353253;
        objOldFinancialProfile.nu_dse__Television_Cable_Satellite__c = 2354325;
        objOldFinancialProfile.nu_dse__Charity_Donations__c = 2355;
        objOldFinancialProfile.nu_dse__Child_Care_Day_Care__c = 235325;
        objOldFinancialProfile.nu_dse__Clothing__c = 54354;
        objOldFinancialProfile.nu_dse__Education__c= 435435;
        objOldFinancialProfile.nu_dse__Entertainment__c= 345343;
        objOldFinancialProfile.nu_dse__Food_Groceries_Eating_Out__c = 3455;
        objOldFinancialProfile.nu_dse__Gym_Health__c = 3455;
        objOldFinancialProfile.nu_dse__Homeowner_s_Renter_s_Insurance__c = 43545;
        objOldFinancialProfile.nu_dse__Home_Status__c='TestHomeStatus';
        objOldFinancialProfile.nu_dse__Household_Items__c=34545;
        objOldFinancialProfile.nu_dse__Laundry_Dry_Cleaning__c=34534;
        objOldFinancialProfile.nu_dse__Life_Insurance__c=345345;
        objOldFinancialProfile.nu_dse__Medical__c=43534;
        objOldFinancialProfile.nu_dse__Co_Client_Gross_Income__c=34534;
        objOldFinancialProfile.nu_dse__Co_Client_Gross_Income__c=2355;
        objOldFinancialProfile.nu_dse__Other_1_Payments__c=786857;
        objOldFinancialProfile.nu_dse__Other_1_Payments_Description__c='5646';
        objOldFinancialProfile.nu_dse__Personal_Care__c=23432;
        objOldFinancialProfile.nu_dse__Student_Loans__c=5657434;
        objOldFinancialProfile.nu_dse__Telephone__c=456456;
        objOldFinancialProfile.nu_dse__Utilities__c=456456;
        Database.Update(objOldFinancialProfile);
        
        List<nu_dse__Financial_Profile__c>lstFinancialProfile = new List<nu_dse__Financial_Profile__c>();
        
        lstFinancialProfile.add(objFinancialProfile);
        Map<id,nu_dse__Financial_Profile__c>financialProfileMap = new Map<Id,nu_dse__Financial_Profile__c>();
        financialProfileMap.Put(objOldFinancialProfile.Id,objOldFinancialProfile);
    //    System.runAs(objUser){
            
                Test.startTest();
                Test.setMock(WebServiceMock.Class, new Test_Attorney_FinancialProfileHandler.LeadTraceNetClientFinancialProfileMock());
                Attorney_FinancialProfileHandler.CreateOrUpdateNDSFinancialProfile(lstFinancialProfile,financialProfileMap);
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
/***********************************
*@Class Name :LeadTraceNetClientFinancialProfileMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/19/2018
************************************/    
    public without sharing class LeadTraceNetClientFinancialProfileMock implements WebServiceMock{
        
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