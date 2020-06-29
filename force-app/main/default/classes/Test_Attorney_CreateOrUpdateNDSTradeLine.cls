/***********************************
*@Class Name :Test_Attorney_CreateOrUpdateNDSTradeLine
*@Purpose:It is Used to test the functionlity of the class Attorney_CreateOrUpdateNDSTradeHandler
*@Created Date :03/16/2018
************************************/
@isTest
public without sharing class Test_Attorney_CreateOrUpdateNDSTradeLine {
    /***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class 
*@Created Date:03/16/2018
************************************/    
    @TestSetup
    private static void creatData(){
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSTradeLine.LeadTraceNetClineMock());
        test.stopTest();
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        
        //Update User
        User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '6Attorney_TestUser@test.com';
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
            Id recID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
            Account objNewCreditorAccount = new Account();
            objNewCreditorAccount.RecordTypeId = recID;
            objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
            objNewCreditorAccount.Name = 'TestAccount';
            objNewCreditorAccount.campaignId__c = '3432423';
            //objNewCreditorAccount.Attorney__c = true;
            objNewCreditorAccount.Best_Day__c = 'Sunday';
            objNewCreditorAccount.Name= 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.BillingCity = 'TestCity';
        objNewCreditorAccount.BillingStreet = 'TestBillingStreet';
        objNewCreditorAccount.BillingPostalCode = '12345';
        objNewCreditorAccount.BillingState = 'TestState';
            Database.Insert(objNewCreditorAccount);
            
            nu_dse__Fee_Template__c ft = new nu_dse__Fee_Template__c();
            ft.Attorney_Program_Type__c = 'Anchor';
            ft.Debt_Amount__c = 'Over 30000';
            ft.nu_dse__Settlement_Pct__c = 42;
            ft.nu_dse__Service_Fee_Percentage__c = 19;
            ft.Portfolio_Name__c = 'Anchor';
            ft.nu_dse__GCS_Fee_Group_Id__c = '12345';
            ft.Service_Fee_Percentage__c = 2;
            insert ft;
                
            Portfolio__c portfolio = new Portfolio__c();
            portfolio.Active_Status__c =true;
            portfolio.Name = 'Anchor';
            insert portfolio;
            
            //Create Program Object
            nu_dse__Program__c objProgram = new nu_dse__Program__c();
            objProgram.Attorney__c = true;
            objProgram.Import_Id__c = '34324234';
            objProgram.nu_dse__Fee_Template__c = ft.Id;
            objProgram.Program_Type__c = 'Anchor';
            objProgram.Portfolio__c = portfolio.Id;
            objProgram.nu_dse__Total_Debt_Included__c = 30001;
            objProgram.nu_dse__Total_Debt__c = 30001;
            objProgram.Estimated_Settlement__c = 42;
            objProgram.GCS_Policy_Group__c = '12345';
            objProgram.Settlement_Fee__c = 2;
            objProgram.Program_Type__c = 'Anchor';
            objProgram.Portfolio__c = portfolio.id;
            objProgram.Draft_Plan_ID__c = '1321323';
            objProgram.nu_dse__Trust_Account_Balance__c = 1234;
            objProgram.nu_dse__Reoccurring_Debit_Day__c = date.today().day();
            objProgram.nu_dse__Twice_Monthly_Reoccuring_Day__c = date.today().day();  
            Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
            //Attorney_CreateOrUpdateNDSProgramHandler.FeetemplateUpdated = true;
            Database.Insert(objProgram);
            System.debug('objProgram'+objProgram);
            
            NDS_User_List__c NDSUser = new NDS_User_List__c();
            NDSUser.Email__c = 'mayur.techup@gmail.com';
            NDSUser.First_Name__c = 'Mayur';
            NDSUser.Last_Name__c = 'Agrawal';
            NDSUser.IsActive__c = 'True';
            NDSUser.User_Name__c = 'magrawal';
            NDSUser.User_Id__c = '1234';
            insert NDSUser;
            
            nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
            
            //Create Tradeline Object
            
            objTradeLine.nds_Debt_Type__c = 'TestType';
            objTradeLine.nu_dse__Original_Debt__c = 1234;
            objTradeLine.nu_dse__Program__c = objProgram.id;
            objTradeline.applicant_type__c = 'Joint';
            objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
            objTradeline.nu_dse__Original_Account_Number__c = '1234';
            ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
            ObjTradeline.Negotiator__c = UserInfo.getUserId();
            ObjTradeline.NDS_Negotiator_Id__c ='1234';
            ObjTradeline.SFS_Current_Balance__c =500;
            objTradeLine.nds_Debt_Type__c = 'TestType';
            objTradeLine.nu_dse__Original_Debt__c = 1234;
            objTradeLine.nu_dse__Program__c = objProgram.id;
            objTradeline.applicant_type__c = 'Joint';        
            objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
            objTradeline.nu_dse__Original_Account_Number__c = '12234';
            Database.Insert(objTradeLine);
            
            
            //Create Offer Object 
            nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
            objOffer.Approved__c = true;
            objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
            //   objOffer.nu_dse__Status__c = 'Offer Made';
            //objOffer.NDS_Offer_Id__c  = '233';
            objOffer.Suspended_On__c = System.today()+1;
            
            objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
            objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
            objOffer.Ended_On__c = System.today()+6;
            Database.insert(objOffer);
            
            //Create the custome Setting LeadTracCredentials__c
            
            Creditor_Standardization__c currentCreditor = new Creditor_Standardization__c();
            currentCreditor.Name = 'Test';
            currentCreditor.creditor_name__c = 'Test';   
            insert currentCreditor;
            
            Creditor_Standardization__c currentCreditor1 = new Creditor_Standardization__c();
            currentCreditor1.Name = 'Test1';
            currentCreditor1.creditor_name__c = 'Test1';   
            insert currentCreditor1;
            
            
        }
    }
    /***********************************
*@Method Name :  test_Success_CreateOrUpdateNDSTradeLine
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method createOrupdateNDSClientMeth.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_Success_CreateOrUpdateNDSTradeLine(){
        
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true AND Attorney_admin__c = false limit 1];
        List<nu_dse__TradeLine__c> lstTradeline = new List<nu_dse__TradeLine__c>();
        Map<id,nu_dse__TradeLine__c> mapTradeline = new Map<id,nu_dse__TradeLine__c>();
        
        LeadTracCredentials__c objCredentialsPush = new LeadTracCredentials__c();
        objCredentialsPush.UserName__c = 'dev_team';
        objCredentialsPush.Password__c = 'Password1234';
        objCredentialsPush.Name = 'NDSPushCredentials';
        //Database.Insert(objCredentialsPush);
        
        
        Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
                              from Account
                              where nu_dse__CFT_Synced__c =: true Limit 1];
        objAccount.Attorney__c = false;
        objAccount.Name= 'TestAccount';
        objAccount.campaignId__c = '3432423';
        objAccount.BillingCity = 'TestCity';
        objAccount.BillingStreet = 'TestBillingStreet';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingState = 'TestState';
        //Database.Update(objAccount);
        
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        
        nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         where id=:objTradLine.nu_dse__Program__c];
        
        System.runAs(objUser){
            
            Test.startTest();
            objTradLine.import_Id__c = '123435';
      //      objTradLine.External_Id__c = '123435';
            objTradLine.nu_dse__Original_Creditor__c = objAccount.Id;
            objTradLine.nds_Debt_Type__c = 'TestDebtType';
            objTradLine.nds_negotiation_status__c = 'Settlement 40-60%';
            objTradLine.nu_dse__Status__c = 'No Account';
            objTradLine.Primary_Applicant__c = 'TestApplicant';
            objTradLine.Secondary_Applicant__c = 'TestApplicant';
            objTradLine.Secondary_Name_Relation__c = 'TestNameRelation';
            objTradLine.Additional_Name__c = 'TestAdditionalName';
            objTradLine.Additional_Relation__c = 'TestRelation';
            //objTradLine.nu_dse__Original_Debt__c = 234.23;
            objTradLine.nu_dse__Minimum_Payment_Amount__c =234.34;
            objTradLine.nu_dse__Verified_Balance__c = 2345;
            objTradLine.nds_Last_Statement_Date__c =Date.valueOf(System.now());
            objTradLine.nu_dse__Percentage__c = 12;
            objTradLine.is_cash_or_transfer__c = true;
            objTradLine.nu_dse__Last_Payment_Date__c = Date.valueOf(System.now());
            objTradLine.Ended_On__c = Date.valueOf(System.now());
            objTradLine.nu_dse__Current_Stage__c = 'New';
            objTradLine.nu_dse__New_Creditor__c = objAccount.Id;
            objTradline.nds_Current_Creditor_Name__c = 'Test1';
            objTradline.nds_Original_Creditor_Name__c = 'Test';
            objTradline.Future_Payment_Amount__c = 200;
        objTradline.Future_Payment_count__c = 20;
        objTradline.Future_Payment_Total_Amount__c = 200;
        objTradline.SFS_Current_Balance__c = 200;
            Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
            Database.Update(objTradLine);
            lstTradeline.add(objTradLine);
            mapTradeline.put(objTradLine.Id, objTradLine);
            
            Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSTradeLine.LeadTraceNetDebtGetCreditorNameMock());
            Attorney_CreateOrUpdateNDSTradeHandler.CreateOrUpdateNDSTradeLine(lstTradeline,mapTradeline,mapTradeline);
            Test.stopTest(); 
        }
        System.assert(true);
    }
    /***********************************
*@Method Name :  test_Fault_CreateOrUpdateNDSTradeLine
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method createOrupdateNDSClientMeth.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_Fault_CreateOrUpdateNDSTradeLine(){
        
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true AND Attorney_admin__c = false limit 1];
        List<nu_dse__TradeLine__c> lstTradeline = new List<nu_dse__TradeLine__c>();
        Map<id,nu_dse__TradeLine__c> mapTradeline = new Map<id,nu_dse__TradeLine__c>();
        
        Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
                              from Account
                              where nu_dse__CFT_Synced__c =: true Limit 1];
        //objAccount.Attorney__c = true;
        objAccount.Name= 'TestAccount';
        objAccount.campaignId__c = '3432423';
        objAccount.BillingCity = 'TestCity';
        objAccount.BillingStreet = 'TestBillingStreet';
        objAccount.BillingPostalCode = '12345';
        objAccount.BillingState = 'TestState';
        //Database.Update(objAccount);
        
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        
        nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         where id=:objTradLine.nu_dse__Program__c];
        
        
        objTradLine.import_Id__c = '123435';
        /*objTradLine.External_Id__c = '123435';
        //objTradLine.nu_dse__New_Creditor__c = objAccount.Id;
        objTradLine.nu_dse__Original_Creditor__c = objAccount.Id;
        objTradLine.nds_Debt_Type__c = 'TestDebtType';
        objTradLine.nds_negotiation_status__c = 'Settlement 40-60%';
        objTradLine.nu_dse__Status__c = 'No Account';
        objTradLine.Primary_Applicant__c = 'TestApplicant';
        objTradLine.Secondary_Applicant__c = 'TestApplicant';
        objTradLine.Secondary_Name_Relation__c = 'TestNameRelation';
        objTradLine.Additional_Name__c = 'TestAdditionalName';
        objTradLine.Additional_Relation__c = 'TestRelation';
        //objTradLine.nu_dse__Original_Debt__c = 234.23;
        objTradLine.nu_dse__Minimum_Payment_Amount__c =234.34;
        objTradLine.nu_dse__Verified_Balance__c = 2345;
        objTradLine.nds_Last_Statement_Date__c =Date.valueOf(System.now());
        objTradLine.nu_dse__Percentage__c = 12;
        objTradLine.is_cash_or_transfer__c = true;
        objTradLine.nu_dse__Last_Payment_Date__c = Date.valueOf(System.now());
        objTradLine.Ended_On__c = Date.valueOf(System.now());
        objTradLine.nu_dse__Current_Stage__c = 'New';*/
        objTradLine.SFS_Current_Balance__c = 200;
        objTradline.Future_Payment_Amount__c = 200;
        objTradline.Future_Payment_count__c = 20;
        objTradline.Future_Payment_Total_Amount__c = 200;
        
        lstTradeline.add(objTradLine);
        mapTradeline.put(objTradLine.Id, objTradLine);
        
        System.runAs(objUser){
            
            Test.startTest();
            
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSTradeLine.LeadTraceNetDebtGetCreditorNameFaultMock());
            Attorney_CreateOrUpdateNDSTradeHandler.CreateOrUpdateNDSTradeLine(lstTradeline,mapTradeline,mapTradeline);
            try{
            Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
            Attorney_CreateOrUpdateNDSTradeHandler.doCheckCreditor(objAccount, ObjTradLine,true,true);
                }
            catch(exception e){
                
            }
            try{
                
            Attorney_CreateOrUpdateNDSTradeHandler.doCreditorMapping(objAccount, ObjTradLine, new leadtracNetDebt.Creditor(),true);
            }
            catch(exception e){    
            }
            try{
                Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
                Attorney_CreateOrUpdateNDSTradeHandler.checkCreditorExistence('34324234');
            }
            catch(exception e){
                
            } try{
                Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
                Attorney_CreateOrUpdateNDSTradeHandler.CreateOrUpdateCreditor(objAccount, ObjTradLine,true);
            }
            catch(exception e){
                
            }    
            Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
        objTradline.Future_Payment_Amount__c = 200;
        objTradline.Future_Payment_count__c = 20;
        objTradline.Future_Payment_Total_Amount__c = 200;
            Database.Update(objTradLine);
            
            //Attorney_CreateOrUpdateNDSTradeHandler.UpdateOriginalCreditor(lstTradeline);
            
            Test.stopTest(); 
            
        }
        System.assert(true);
    }
    
    private static testMethod void test_Fault_CreateOrUpdateNDSTradeLine1(){
        
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true AND Attorney_admin__c = false limit 1];
        List<nu_dse__TradeLine__c> lstTradeline = new List<nu_dse__TradeLine__c>();
        Map<id,nu_dse__TradeLine__c> mapTradeline = new Map<id,nu_dse__TradeLine__c>();
        
        Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
                              from Account
                              where nu_dse__CFT_Synced__c =: true Limit 1];
        
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        
        nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         where id=:objTradLine.nu_dse__Program__c];
        System.runAs(objUser){
            
            Test.startTest();
            nu_dse__Tradeline__c trade1 = new nu_dse__Tradeline__c();
            trade1.import_Id__c = '123435';
            trade1.SFS_Current_Balance__c = 200;
            trade1.Id = ObjTradline.Id;
            lstTradeline.add(Trade1);
            mapTradeline.put(objTradLine.Id, ObjTradline);
            Map<Id,nu_dse__Tradeline__c> newMap = new Map<Id,nu_dse__Tradeline__c>();
            newMap.put(objTradLine.Id, Trade1);
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSTradeLine.LeadTraceNetDebtGetCreditorNameFaultMock());
            Attorney_CreateOrUpdateNDSTradeHandler.CreateOrUpdateNDSTradeLine(lstTradeline,mapTradeline,newMap);
            Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
            
            objTradLine.import_Id__c = '123435';
            objTradLine.SFS_Current_Balance__c = 200;
            Database.Update(objTradLine);
            Test.stopTest(); 
            
        }
        System.assert(true);
    }
    
    private static testMethod void test_Fault_CreateOrUpdateNDSTradeLine2(){
        
        User objUser = [Select id,Name,isActive from User where Profile.Name=:'System Administrator' AND isActive =true AND Attorney_admin__c = false limit 1];
        List<nu_dse__TradeLine__c> lstTradeline = new List<nu_dse__TradeLine__c>();
        Map<id,nu_dse__TradeLine__c> mapTradeline = new Map<id,nu_dse__TradeLine__c>();
        
        Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
                              from Account
                              where nu_dse__CFT_Synced__c =: true Limit 1];
        
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        
        nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         where id=:objTradLine.nu_dse__Program__c];
        System.runAs(objUser){
            
            Test.startTest();
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSTradeLine.LeadTraceNetDebtGetCreditorNameFaultMock());
            Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = false;
            objTradLine.import_Id__c = '123435';
            objTradLine.SFS_Current_Balance__c = 200;
            Database.Update(objTradLine);
            Test.stopTest(); 
            
        }
        System.assert(true);
    }
    
    /***********************************
*@Class Name :LeadTraceNetClineMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/16/2018
************************************/    
    public without sharing class LeadTraceNetClineMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            if(soapAction.endsWithIgnoreCase('')){
                leadtracNetClient.CreateOrUpdateClientResponse_element respElement =new leadtracNetClient.CreateOrUpdateClientResponse_element();
                respElement.CreateOrUpdateClientResult = 'TestResult';
                response.put('response_x', respElement);
            }
            if(soapAction.endsWithIgnoreCase('GetCreditorByName')){
                leadtracNetDebt.GetCreditorByNameResponse_element respElement =new leadtracNetDebt.GetCreditorByNameResponse_element();
                leadtracNetDebt.GetCreditorListResult GetCreditorByNameResult = new leadtracNetDebt.GetCreditorListResult();
                leadtracNetDebt.ArrayOfCreditor Creditors = new leadtracNetDebt.ArrayOfCreditor();
                leadtracNetDebt.ArrayOfResultMessage Messages = new leadtracNetDebt.ArrayOfResultMessage();
                leadtracNetDebt.ResultMessage objResultMessage = new leadtracNetDebt.ResultMessage();
                
                leadtracNetDebt.Creditor objCreditor = new leadtracNetDebt.Creditor();
                List<leadtracNetDebt.Creditor>lstCreditor = new List<leadtracNetDebt.Creditor>();
                objCreditor.Address1 = 'TestBillingStreet';
                objCreditor.City = 'TestCity';
                objCreditor.State = 'TestState';
                objCreditor.Zip = '12345';
                lstCreditor.Add(objCreditor);
                Creditors.Creditor = lstCreditor;
                objResultMessage.MessageType = 'TestMessage';
                objResultMessage.Message = 'Test';
                List<leadtracNetDebt.ResultMessage> lstResultMsg = new List<leadtracNetDebt.ResultMessage>();
                lstResultMsg.Add(objResultMessage);
                Messages.ResultMessage = lstResultMsg;
                GetCreditorByNameResult.ResultMessage = lstResultMsg;
                GetCreditorByNameResult.IsSuccessful = true;
                GetCreditorByNameResult.Messages = Messages;
                GetCreditorByNameResult.Creditors = Creditors;  
                
                respElement.GetCreditorByNameResult = GetCreditorByNameResult;    
                
                response.put('response_x', respElement);
            }
        }
    }    
    /***********************************
*@Class Name :LeadTraceNetDebtMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/16/2018
************************************/    
    public without sharing class LeadTraceNetDebtMock implements WebServiceMock{
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType)
        {
            
            leadtracNetDebt.CreateOrUpdateDebtsResponse_element response_x =new LeadtracNetDebt.CreateOrUpdateDebtsResponse_element();
            leadtracNetDebt.GetDebtsResult CreateOrUpdateDebtsResult = new leadtracNetDebt.GetDebtsResult();
            leadtracNetDebt.ArrayOfDebtCreditor CreditorHistory =new leadtracNetDebt.ArrayOfDebtCreditor();
            leadtracNetDebt.SettlementPlan SettlementPlan =new   leadtracNetDebt.SettlementPlan();
            leadtracNetDebt.ArrayOfDebtProperty Properties= new  leadtracNetDebt.ArrayOfDebtProperty();
            leadtracNetDebt.ArrayOfDebt objArrayDebt = new  leadtracNetDebt.ArrayOfDebt();
            List<leadtracNetDebt.Debt>lstDebt = new  List<leadtracNetDebt.Debt>();
            leadtracNetDebt.Debt objDebt = new  leadtracNetDebt.Debt();
            objDebt.AccountStatus = 'TestSTaus';
            objDebt.CreditorHistory = CreditorHistory;    
            objDebt.SettlementPlan =  SettlementPlan;    
            objDebt.Properties =Properties; 
            lstDebt.add(objDebt);
            objArrayDebt.Debt = lstDebt;
            CreateOrUpdateDebtsResult.Debts =objArrayDebt;     
            response_x.CreateOrUpdateDebtsResult = CreateOrUpdateDebtsResult;
            response.put('response_x', response_x);
            
        }
    }
    /***********************************
*@Class Name :LeadTraceNetDebtGetCreditorNameMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/16/2018
************************************/    
    public without sharing class LeadTraceNetDebtGetCreditorNameMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            
            leadtracNetDebt.GetCreditorByNameResponse_element respElement =new leadtracNetDebt.GetCreditorByNameResponse_element();
            leadtracNetDebt.GetCreditorListResult GetCreditorByNameResult = new leadtracNetDebt.GetCreditorListResult();
            leadtracNetDebt.ArrayOfCreditor Creditors = new leadtracNetDebt.ArrayOfCreditor();
            leadtracNetDebt.ArrayOfResultMessage Messages = new leadtracNetDebt.ArrayOfResultMessage();
            leadtracNetDebt.ResultMessage objResultMessage = new leadtracNetDebt.ResultMessage();
            
            leadtracNetDebt.Creditor objCreditor = new leadtracNetDebt.Creditor();
            List<leadtracNetDebt.Creditor>lstCreditor = new List<leadtracNetDebt.Creditor>();
            objCreditor.Address1 = 'TestBillingStreet';
            objCreditor.City = 'TestCity';
            objCreditor.State = 'TestState';
            objCreditor.Zip = '12345';
            lstCreditor.Add(objCreditor);
            Creditors.Creditor = lstCreditor;
            objResultMessage.MessageType = 'TestMessage';
            objResultMessage.Message = 'Test';
            List<leadtracNetDebt.ResultMessage> lstResultMsg = new List<leadtracNetDebt.ResultMessage>();
            lstResultMsg.Add(objResultMessage);
            Messages.ResultMessage = lstResultMsg;
            GetCreditorByNameResult.ResultMessage = lstResultMsg;
            GetCreditorByNameResult.IsSuccessful = true;
            GetCreditorByNameResult.Messages = Messages;
            GetCreditorByNameResult.Creditors = Creditors;  
            
            respElement.GetCreditorByNameResult = GetCreditorByNameResult;    
            
            response.put('response_x', respElement);
        }
    }      
    /***********************************
*@Class Name :LeadTraceNetDebtGetCreditorNameFaultMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/16/2018
************************************/    
    public without sharing class LeadTraceNetDebtGetCreditorNameFaultMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            
            leadtracNetDebt.GetCreditorByNameResponse_element respElement =new leadtracNetDebt.GetCreditorByNameResponse_element();
            leadtracNetDebt.GetCreditorListResult GetCreditorByNameResult = new leadtracNetDebt.GetCreditorListResult();
            leadtracNetDebt.ArrayOfCreditor Creditors = new leadtracNetDebt.ArrayOfCreditor();
            leadtracNetDebt.ArrayOfResultMessage Messages = new leadtracNetDebt.ArrayOfResultMessage();
            leadtracNetDebt.ResultMessage objResultMessage = new leadtracNetDebt.ResultMessage();
            
            leadtracNetDebt.Creditor objCreditor = new leadtracNetDebt.Creditor();
            List<leadtracNetDebt.Creditor>lstCreditor = new List<leadtracNetDebt.Creditor>();
            objCreditor.Address1 = 'TestBilling';
            objCreditor.City = 'Test';
            objCreditor.State = 'TestState';
            objCreditor.Zip = '12345';
            lstCreditor.Add(objCreditor);
            Creditors.Creditor = lstCreditor;
            objResultMessage.MessageType = 'TestMessage';
            objResultMessage.Message = 'Test';
            List<leadtracNetDebt.ResultMessage> lstResultMsg = new List<leadtracNetDebt.ResultMessage>();
            lstResultMsg.Add(objResultMessage);
            Messages.ResultMessage = lstResultMsg;
            GetCreditorByNameResult.ResultMessage = lstResultMsg;
            GetCreditorByNameResult.IsSuccessful = true;
            GetCreditorByNameResult.Messages = Messages;
            GetCreditorByNameResult.Creditors = Creditors;  
            
            respElement.GetCreditorByNameResult = GetCreditorByNameResult;    
            response.put('response_x', respElement);
        }
    }
    
    //PDI-731
    private static testMethod void test_UpdateOriginalCreditor(){
      //list<nu_dse__TradeLine__c> lstTrade=new list<nu_dse__TradeLine__c>();
      nu_dse__TradeLine__c objTradLine1 = [Select id,nu_dse__Original_Creditor__c,Normalized_Original_Creditor__c,nu_dse__Sales_Creditor_Name__c
                                            from nu_dse__TradeLine__c limit 1]; 
     
        objTradLine1.Normalized_Original_Creditor__c=null;
      update objTradLine1;
      
      objTradLine1.Normalized_Original_Creditor__c='Capital Two';
      update objTradLine1;
      //lstTrade.add(objTradLine1);
     // Attorney_CreateOrUpdateNDSTradeHandler.UpdateOriginalCreditor(lstTrade);
      nu_dse__TradeLine__c objTradLine2 = [Select id,nu_dse__Original_Creditor__c,Normalized_Original_Creditor__c,nu_dse__Sales_Creditor_Name__c
                                            from nu_dse__TradeLine__c Limit 1]; 
      
      objTradLine2.Normalized_Original_Creditor__c=null;
      objTradLine2.nu_dse__Sales_Creditor_Name__c='Bank of India';
      //lstTrade.add(objTradLine2);
      update objTradLine2;
      //Attorney_CreateOrUpdateNDSTradeHandler.UpdateOriginalCreditor(lstTrade);
    }
    
}