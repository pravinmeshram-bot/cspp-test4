/***********************************
*@Class Name :Test_Attorney_CrOrUpNDSProgramHandler
*@Purpose:It is Used to test the functionlity of the class Attorney_CreateOrUpdateNDSProgramHandler
************************************/
@isTest
private class Test_Attorney_CrOrUpNDSProgramHandler {
/***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class 
************************************/    
    @TestSetup
    private static void createData(){
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_CrOrUpNDSProgramHandler.LeadTraceNetClientMock());
        Test.stopTest();
        
        //Update User
  User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '7Attorney_TestUser@test.com';
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
        
        nu_dse__Fee_Template__c feeTemplateInst = new nu_dse__Fee_Template__c();
        
        insert feeTemplateInst;
        
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.nds_EstimatedSettlement_Amount__c = 655;
        objProgram.Draft_Plan_ID__c = '4564';
        objProgram.Import_ID__c = '1231231233';    
        objProgram.DNL_Status__c='Pre-TILA Signed';
        objProgram.nu_dse__Fee_Template__c = feeTemplateInst.Id;
        
        Database.Insert(objProgram); 
           
        nu_dse__Payment__c payment = new nu_dse__Payment__c();
        payment.recordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        payment.nu_dse__Program__c =objProgram.Id;
        insert Payment;
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
    }
    }
/***********************************
*@Method Name :  test_CreateOrUpdateNDSProgram
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSProgram.
************************************/
    private static TestMethod void test_CreateOrUpdateNDSProgram(){
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true limit 1];
        objUser.Attorney_Admin__c =true;
        update objUser;
        nu_dse__Program__c objProgram = [Select id from nu_dse__Program__c Limit 1];
        
        nu_dse__Fee_Template__c ft = new nu_dse__Fee_Template__c();
        
        System.runAs(objUser){
        objProgram.Attorney__c = true;
        Database.Update(objProgram);
        
        nu_dse__Program__c objOldProgram = new nu_dse__Program__c();
        objOldProgram = objProgram.Clone();
        objOldProgram.Id = objProgram.Id;
        objOldProgram.nds_EstimatedSettlement_Amount__c = 32432;
        objOldProgram.nds_EstimatedProgram_Fee__c = 32432;
        objOldProgram.nds_Program_Savings__c = 32432;
        objOldProgram.nds_Retainer_Fee__c = 32432;
        objOldProgram.nds_Retainer_Fee_Total__c = 32432;
        objOldProgram.nds_Total_Program_Cost__c = 32432;
        objOldProgram.nds_Trust_Fee_Monthly__c = 32432;
        objOldProgram.Cancellation_Date__c = System.today();
      //  objOldProgram.Cancellation_Reason__c = 'TestReason';
        objOldProgram.nds_Current_Debt_Payments__c = 3243;
        objOldProgram.nds_Estimated_Total_Debt__c = 32432;
        objOldProgram.NSF_Draft_Date__c = System.today()+1;
        objOldProgram.nds_Maxprogram_length__c = 'MaxProgram';
        objOldProgram.nds_NSF_Draft_Amount__c = 32432;
        objOldProgram.nds_NSF_Reason__c = 'NSFReason';
        objOldProgram.nu_dse__Program_Length__c = 3;
        objOldProgram.Program_Type__c = 'Timberline';
        objOldProgram.nu_dse__Reoccurring_Debit_Day__c = 3;
        objOldProgram.nu_dse__Twice_Monthly_Reoccuring_Day__c = 3;
        objOldProgram.Sales_Rep__c = 'TestSales rep';
        objOldProgram.Sales_Rep_Email__c = 'Test@Test.com';
        //objOldProgram.DNL_Status__c='Pre-TILA Signed';  //@
        //Database.Update(objOldProgram);
        
        List<nu_dse__Program__c> lstProgram = New List<nu_dse__Program__c>();
        lstProgram.add(objProgram);
        
        Map<Id,nu_dse__Program__c> programMap = new Map<Id,nu_dse__Program__c>();
        programMap.put(objOldProgram.Id, objOldProgram);
        
        
                Test.startTest();
                Test.setMock(WebServiceMock.Class, new Test_Attorney_CrOrUpNDSProgramHandler.LeadTraceNetClientMock());
                Attorney_CreateOrUpdateNDSProgramHandler.CreateOrUpdateNDSProgram(lstProgram,programMap);
                Attorney_CreateOrUpdateNDSProgramHandler.CreateFeeTemplate(lstProgram);
                //Attorney_CreateOrUpdateNDSProgramHandler.UpdateFeeTemplateBatch();
                Test.stopTest();
        }
        System.assert(true);
    } 
    
    private static TestMethod void test_CreateOrUpdateNDSProgram2(){
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true limit 1];
        objUser.Attorney_Admin__c =true;
        objUser.Attorney_Ignore_Validation__c = true;
        update objUser;
        nu_dse__Program__c objProgram = [Select id from nu_dse__Program__c Limit 1];
        
        nu_dse__Fee_Template__c ft = new nu_dse__Fee_Template__c();
        ft.Name = 'SUMMIT-Under 30000-81880-50-9-Summit - LDP';
        //u_dse__Settlement_Fee_Percentage__c = 0;
        ft.nu_dse__Settlement_Pct__c = 50;
        ft.nu_dse__GCS_Fee_Group_Id__c = '81880';
        ft.Portfolio_Name__c = 'SUMMIT';
        ft.Debt_Amount__c = 'Under 30000';
        ft.Service_Fee_Percentage__c = 9;
        ft.Program_Type__c = 'Summit - LDP';
        insert ft;
        
        System.runAs(objUser){
        objProgram.Attorney__c = true;
        Database.Update(objProgram);
        
        nu_dse__Program__c objOldProgram = new nu_dse__Program__c();
        objOldProgram = objProgram.Clone();
        objOldProgram.Id = objProgram.Id;
        objOldProgram.nds_EstimatedSettlement_Amount__c = 32432;
        objOldProgram.nds_EstimatedProgram_Fee__c = 32432;
        objOldProgram.nds_Program_Savings__c = 32432;
        objOldProgram.nds_Retainer_Fee__c = 32432;
        objOldProgram.nds_Retainer_Fee_Total__c = 32432;
        objOldProgram.nds_Total_Program_Cost__c = 32432;
        objOldProgram.nds_Trust_Fee_Monthly__c = 32432;
        objOldProgram.Cancellation_Date__c = System.today();
      //  objOldProgram.Cancellation_Reason__c = 'TestReason';
        objOldProgram.nds_Current_Debt_Payments__c = 3243;
        objOldProgram.nds_Estimated_Total_Debt__c = 32432;
        objOldProgram.NSF_Draft_Date__c = System.today()+1;
        objOldProgram.nds_Maxprogram_length__c = 'MaxProgram';
        objOldProgram.nds_NSF_Draft_Amount__c = 32432;
        objOldProgram.nds_NSF_Reason__c = 'NSFReason';
        objOldProgram.nu_dse__Program_Length__c = 3;
        objOldProgram.Program_Type__c = 'Summit - LDP';
        objOldProgram.nu_dse__Reoccurring_Debit_Day__c = 3;
        objOldProgram.nu_dse__Twice_Monthly_Reoccuring_Day__c = 3;
        objOldProgram.Sales_Rep__c = 'TestSales rep';
        objOldProgram.Sales_Rep_Email__c = 'Test@Test.com';
        objOldProgram.nu_dse__Fee_Template__c = ft.id;
        objOldProgram.nu_dse__Total_Debt_Included__c= 30001;
        objOldProgram.GCS_Policy_Group__c = '81880';
        objOldProgram.Settlement_Fee__c = 9;
        objOldProgram.Estimated_Settlement__c = 50;
        Database.Update(objOldProgram);
        
            Attorney_CreateOrUpdateNDSProgramHandler.FeetemplateUpdated = false;
            objOldProgram.nu_dse__Total_Debt_Included__c = 1;
            objOldProgram.DNL_Status__c='Pre-TILA Signed';
            Database.Update(objOldProgram);
            
        List<nu_dse__Program__c> lstProgram = New List<nu_dse__Program__c>();
        lstProgram.add(objProgram);
        
        Map<Id,nu_dse__Program__c> programMap = new Map<Id,nu_dse__Program__c>();
        programMap.put(objOldProgram.Id, objOldProgram);
        
        
                Test.startTest();
                Test.setMock(WebServiceMock.Class, new Test_Attorney_CrOrUpNDSProgramHandler.LeadTraceNetClientMock());
                Attorney_CreateOrUpdateNDSProgramHandler.CreateOrUpdateNDSProgram(lstProgram,programMap);
                Attorney_CreateOrUpdateNDSProgramHandler.CreateFeeTemplate(lstProgram);
                Test.stopTest();
        }
        System.assert(true);
    }
    
    private static TestMethod void test_CreateOrUpdateNDSProgram1(){
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true limit 1];
        
        nu_dse__Program__c objProgram = [Select id from nu_dse__Program__c Limit 1];
        //System.runAs(objUser){
        objProgram.Attorney__c = true;
    //    objProgram.Draft_Plan_ID__c = '1234';
        Database.Update(objProgram);
        
        nu_dse__Program__c objOldProgram = new nu_dse__Program__c();
        objOldProgram = objProgram.Clone();
        objOldProgram.Id = objProgram.Id;
        objOldProgram.nds_EstimatedSettlement_Amount__c = 32432;
        objOldProgram.nds_EstimatedProgram_Fee__c = 32432;
        objOldProgram.nds_Program_Savings__c = 32432;
        objOldProgram.nds_Retainer_Fee__c = 32432;
        objOldProgram.nds_Retainer_Fee_Total__c = 32432;
        objOldProgram.nds_Total_Program_Cost__c = 32432;
        objOldProgram.nds_Trust_Fee_Monthly__c = 32432;
        objOldProgram.Cancellation_Date__c = System.today();
      //  objOldProgram.Cancellation_Reason__c = 'TestReason';
        objOldProgram.nds_Current_Debt_Payments__c = 3243;
        objOldProgram.nds_Estimated_Total_Debt__c = 32432;
        objOldProgram.NSF_Draft_Date__c = System.today()+1;
        objOldProgram.nds_Maxprogram_length__c = 'MaxProgram';
        objOldProgram.nds_NSF_Draft_Amount__c = 32432;
        objOldProgram.nds_NSF_Reason__c = 'NSFReason';
        objOldProgram.nu_dse__Program_Length__c = 3;
        objOldProgram.Program_Type__c = 'Timberline';
        objOldProgram.nu_dse__Reoccurring_Debit_Day__c = 3;
        objOldProgram.nu_dse__Twice_Monthly_Reoccuring_Day__c = 3;
        objOldProgram.Sales_Rep__c = 'TestSales rep';
        objOldProgram.Sales_Rep_Email__c = 'Test@Test.com';
        
        Database.Update(objOldProgram);
        
        List<nu_dse__Program__c> lstProgram = New List<nu_dse__Program__c>();
        lstProgram.add(objProgram);
        
        Map<Id,nu_dse__Program__c> programMap = new Map<Id,nu_dse__Program__c>();
        programMap.put(objOldProgram.Id, objOldProgram);
        
        
                Test.startTest();
                Test.setMock(WebServiceMock.Class, new Test_Attorney_CrOrUpNDSProgramHandler.LeadTraceNetClientMock());
                Attorney_CreateOrUpdateNDSProgramHandler.CreateOrUpdateNDSProgram(lstProgram,programMap);
                Attorney_CreateOrUpdateNDSProgramHandler.CreateFeeTemplate(lstProgram);
                Test.stopTest();
        //}
        System.assert(true);
    }
/***********************************
*@Class Name :LeadTraceNetClinetMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
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
      private static testMethod void cancelPayments_Test(){
          nu_dse__Program__c objProgram = [Select id from nu_dse__Program__c Limit 1];
          objProgram.nu_dse__Program_Status__c = 'Active Client';
          update objProgram;
          
          nu_dse__Program__c objOldProgram = new nu_dse__Program__c();
          objOldProgram = objProgram.Clone();
          objOldProgram.Id = objProgram.Id;
          objOldProgram.nds_EstimatedSettlement_Amount__c = 32432;
          objOldProgram.nu_dse__Program_Status__c = 'NSF';
          objOldProgram.nds_EstimatedProgram_Fee__c = 32432;
          objOldProgram.nds_Program_Savings__c = 32432;
          objOldProgram.nds_Retainer_Fee__c = 32432;
          objOldProgram.nds_Retainer_Fee_Total__c = 32432;
          objOldProgram.nds_Total_Program_Cost__c = 32432;
          objOldProgram.nds_Trust_Fee_Monthly__c = 32432;
          
          List<nu_dse__Program__c> lstProgram = New List<nu_dse__Program__c>();
          lstProgram.add(objProgram);
          
          Map<Id,nu_dse__Program__c> programMap = new Map<Id,nu_dse__Program__c>();
          programMap.put(objOldProgram.Id, objOldProgram);
          
          List<nu_dse__Payment__c> Payment = [Select id from nu_dse__Payment__c where nu_dse__Program__c=:objProgram.id];
          Payment[0].nu_dse__Transaction_Status__c = 'Cancelled';
          Payment[0].nu_dse__Is_Makeup_Payment_Created__c = False;
          
          
          Test.startTest();
          Attorney_CreateOrUpdateNDSProgramHandler.cancelPayments(lstProgram,programMap);
          Test.stopTest();
            
        
    }
    
    public static testmethod void test_populatePortfolioOnAccount(){
    
     Account acc = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), Phone  = '9845764876', 
                               PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', PersonMailingCity = 'city', personMailingState = 'AL', 
                               personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', 
                               PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', PersonEmail = 'client@test.com', nu_dse__Co_First_Name__c = 'Test', 
                               nu_dse__Co_Last_Name__c = 'CoClient', nu_dse__Co_SSN__c = '501-96-4554', nu_dse__Co_Date_of_Birth__c = System.Today(), 
                               nu_dse__Co_Phone__c = '7854986587', nu_dse__Co_Address_Line__c = 'Test Street num 1', nu_dse__Co_City__c = 'Clio', 
                               nu_dse__Co_Postal_Code__c = '94406', nu_dse__Co_State__c = 'AL', nu_dse__CO_Email_Address__c = 'test@email.com');   
                               
     insert acc;
                               
        Portfolio__c portfolio = new Portfolio__c(Name = 'Timberline', Active_Status__c = True);
        insert portfolio;
        
        nu_dse__Program__c program = new nu_dse__Program__c (nu_dse__Account__c = acc.Id, 
                                         nu_dse__Processor_Status__c = 'Inactive', Import_ID__c='1232',Attorney__c = true,
                                         Portfolio__c = portfolio.Id);
        insert program;
        
   }

}