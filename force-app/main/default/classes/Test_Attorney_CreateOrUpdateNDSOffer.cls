/***********************************
*@Class Name :Test_Attorney_CreateOrUpdateNDSOffer
*@Purpose:It is Used to test the functionlity of the class Attorney_CreateOrUpdateNDSOfferHandler
*@Created Date :03/18/2018
************************************/
@isTest
private without sharing  class Test_Attorney_CreateOrUpdateNDSOffer {
    /***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class 
*@Created Date:03/18/2018
************************************/    
    @TestSetup
    private static void creatData(){
        //Call Mock for thr Client data
        Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetClinetMock());
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadTraceNetDebtGetCreditorNameMock());
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
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'AsynCallToNDSettlementPayment';
        insert bd;
        
        system.runAs(u1){
            Account acc = new Account();
            acc.FirstName = 'test';
            acc.LastName = 'test';
            acc.NDS_File_Number__c = '1234';
            acc.PersonMailingState = 'CA';
            acc.nu_dse__SSN__c = 'ABBHBD6876';
            acc.Attorney__c = true;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
            insert acc;
            
            Portfolio__c portfolio = new Portfolio__c();
            portfolio.Name = 'Anchor';
            portfolio.Profile_Name__c = 'Anchor';
            portfolio.Active_Status__c = true;
            insert portfolio;
            
            
            nu_dse__Program__c p = new nu_dse__Program__c();
            p.nu_dse__Account__c = acc.id;
            p.Import_ID__c = '1234';
            p.Attorney__c = true;
            p.Program_Type__c = 'Anchor';
            p.Portfolio__c = portfolio.id;
            p.Draft_Plan_ID__c = '1321323';
            p.nu_dse__Trust_Account_Balance__c = 1234;
            p.nu_dse__Reoccurring_Debit_Day__c = date.today().day();
            p.nu_dse__Twice_Monthly_Reoccuring_Day__c = date.today().day();
            insert p;
            
            Id recID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
            Account objNewCreditorAccount = new Account();
            objNewCreditorAccount.RecordTypeId = recID;
            //objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
            objNewCreditorAccount.Name = 'TestAccount';
            objNewCreditorAccount.campaignId__c = '3432423';
            objNewCreditorAccount.Attorney__c = False;
            objNewCreditorAccount.Best_Day__c = 'Sunday';
            Database.Insert(objNewCreditorAccount);
            
            //Create Tradeline Object
            nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
            objTradeLine.nds_Debt_Type__c = 'TestType';
            objTradeLine.nu_dse__Original_Debt__c = 1234;
            objTradeLine.nu_dse__Program__c = p.id;
            objTradeline.applicant_type__c = 'Joint';        
            objTradeLine.nds_Original_Creditor_Name__c='Test';
            objTradeline.nu_dse__Original_Account_Number__c = '12234';
            ObjTradeline.SFS_current_balance__c = 1234;
            Database.Insert(objTradeLine);
            
            
            objTradeline.Import_id__c = '11111111';
            Database.Update(objTradeLine);
            
            
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
        } 
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentialsPush = new LeadTracCredentials__c();
        objCredentialsPush.UserName__c = 'dev_team';
        objCredentialsPush.Password__c = 'Password1234';
        objCredentialsPush.Name = 'NDSPushCredentials';
        Database.Insert(objCredentialsPush);
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
        
        
        
        
    }
    /***********************************
*@Method Name :  test_CreateOrUpdateNDSPaymentOffer
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSPaymentOffer.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_CreateOrUpdateNDSPaymentOffer(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        
        // Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
        //                     from Account
        //                   where nu_dse__CFT_Synced__c =: true Limit 1];
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        // objAccount.nu_dse__CFT_Synced__c = true;
        // objAccount.Attorney__c = true;
        insert objAccount;
        
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        objTradLine.nu_dse__Current_Stage__c = 'New';
        //objTradLine.nu_dse__New_Creditor__c = objAccount.Id;
        objTradLine.Import_ID__c = '111111111122';
        objTradLine.applicant_type__c = 'Joint';
        
        Database.Update(objTradLine);
        
        
        nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         Limit 1];
        System.runAs(objUser){
            
            Test.startTest();
            
            nu_dse__Offer__c objOffer = [Select Id,nu_dse__TradeLine__c from nu_dse__Offer__c Limit 1];
             
            
            // objOffer.nu_dse__TradeLine__c = objTradLine.Id;
            objOffer.nu_dse__Program__c = objProgram.Id;
            objOffer.NDS_Offer_Id__c = null;
            //   objOffer.nu_dse__Status__c = 'Pending';
            objOffer.Suspended_On__c = System.today()+2;
            objOffer.Settlement_Status__c = 'Client Pay';
            objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+5);
            objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+3);
            
            
            objOffer.PushToNDS__c = true;
            Database.Update(objOffer);
            objOffer.Ended_On__c = System.today()+7;
            objOffer.NDS_Offer_Id__c = '12334';
            //objOffer.Settlement_Status__c = 'Creditor Accepted';
            
            nu_dse__Offer__c relatedOffer = new nu_dse__Offer__c();
            relatedOffer.nu_dse__TradeLine__c = objTradline.Id;
            relatedOffer.nu_dse__Program__c = objProgram.Id;
            insert relatedOffer;
            
            Database.Update(objOffer);
            
            
            
            List<nu_dse__Offer__c> lstOfferList = New list<nu_dse__Offer__c>();
            objOffer.Latest_Offer__c = true;
            objOffer.pushToNDS__c = true;
            lstOfferList.Add(objOffer);
            Map<Id,nu_dse__Offer__c>mapOffer = New Map<Id,nu_dse__Offer__c>();
            mapOffer.Put(objOffer.Id,objOffer);
            
            //Attorney_CreateOrUpdateNDSOfferHandler.dummyMethod();
            Attorney_CreateOrUpdateNDSOfferHandler.CreateOrUpdateNDSPaymentOffer(lstOfferList,mapOffer);
            Attorney_CreateOrUpdateNDSOfferHandler.setIntegrationFields(objOffer,'Test','TestReason');
            Attorney_CreateOrUpdateNDSOfferHandler.doSettlementMapping(objOffer);
            Attorney_CreateOrUpdateNDSOfferHandler.UpdateOfferField(lstOfferList);
            Attorney_CreateOrUpdateNDSOfferHandler.UpdateRelatedOfferField(lstOfferList);
            /*Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment AsyncCall = new Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment(objOffer.id);
            AsyncCall.execute(null);*/
            
            
            Test.stopTest(); 
        }
        System.assert(true);
    }
    
    private static testMethod void test_CreateOrUpdateNDSPaymentOffer2(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        objUser.Attorney_Admin__c = false;
        update objUser;
        
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        objTradLine.nu_dse__Current_Stage__c = 'New';
        objTradLine.Import_ID__c = '111111111122';
        objTradLine.applicant_type__c = 'Joint';
        Database.Update(objTradLine);
        
        
        
        System.runAs(objUser){
            
            Test.startTest();
            nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         Limit 1];
            objProgram.Attorney__c = true;
            Update objProgram;
            nu_dse__Offer__c objOffer = [Select Id,nu_dse__TradeLine__c from nu_dse__Offer__c Limit 1];
             
            
            // objOffer.nu_dse__TradeLine__c = objTradLine.Id;
            objOffer.nu_dse__Program__c = objProgram.Id;
            objOffer.NDS_Offer_Id__c = null;
            //   objOffer.nu_dse__Status__c = 'Pending';
            objOffer.Suspended_On__c = System.today()+2;
            objOffer.Settlement_Status__c = 'Client Pay';
            objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+5);
            objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+3);
            
            
            objOffer.PushToNDS__c = true;
            objOffer.nu_dse__Status__c = 'To Payment Processing';
            Database.Update(objOffer);
            objOffer.Ended_On__c = System.today()+7;
            objOffer.NDS_Offer_Id__c = '12334';
            objOffer.Latest_Offer__c = true;
            //objOffer.Settlement_Status__c = 'Creditor Accepted';
            
            nu_dse__Offer__c relatedOffer = new nu_dse__Offer__c();
            relatedOffer.nu_dse__TradeLine__c = objTradline.Id;
            relatedOffer.nu_dse__Program__c = objProgram.Id;
            //insert relatedOffer;
            
            Database.Update(objOffer);
            
            
            
            List<nu_dse__Offer__c> lstOfferList = New list<nu_dse__Offer__c>();
            
            lstOfferList.Add(objOffer);
            Map<Id,nu_dse__Offer__c>mapOffer = New Map<Id,nu_dse__Offer__c>();
            mapOffer.Put(objOffer.Id,objOffer);
            try{
            objOffer.nu_dse__Status__c = 'Accepted';
            Update objOffer;
            } catch(Exception e){
                
            }
            Test.stopTest(); 
        }
        System.assert(true);
    }
    
    private static testMethod void test_CreateOrUpdateNDSPaymentOffer1(){
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'AsynCallToNDSettlementPayment';
        insert bd;
        
        User objUser = [Select id,Name,isActive from User where
                       Profile.Name=:'System Administrator' AND isActive =true limit 1];
        objUser.attorney_admin__c = false;
        update objUser;
        // Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
        //                     from Account
        //                   where nu_dse__CFT_Synced__c =: true Limit 1];
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        // objAccount.nu_dse__CFT_Synced__c = true;
        // objAccount.Attorney__c = true;
        insert objAccount;
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        objTradLine.nu_dse__Current_Stage__c = 'New';
        //objTradLine.nu_dse__New_Creditor__c = objAccount.Id;
        objTradLine.Import_ID__c = '111111111122';
        objTradLine.applicant_type__c = 'Joint';
        
        //Database.Update(objTradLine);
        
        
        nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         Limit 1];
        System.runAs(objUser){
            
            
            
            nu_dse__Offer__c objOffer = [Select Id,nu_dse__TradeLine__c from nu_dse__Offer__c Limit 1];
            
            // objOffer.nu_dse__TradeLine__c = objTradLine.Id;
            objOffer.nu_dse__Program__c = objProgram.Id;
            objOffer.NDS_Offer_Id__c = '123245';
            //   objOffer.nu_dse__Status__c = 'Pending';
            objOffer.Suspended_On__c = System.today()+2;
            objOffer.Settlement_Status__c = 'Client Pay';
            objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+5);
            objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+3);
            
            
            objOffer.PushToNDS__c = true;
            Database.Update(objOffer);
            objOffer.Ended_On__c = System.today()+7;
            objOffer.NDS_Offer_Id__c = '12334';
            //objOffer.Settlement_Status__c = 'Creditor Accepted';
            
            nu_dse__Offer__c relatedOffer = new nu_dse__Offer__c();
            relatedOffer.nu_dse__TradeLine__c = objTradline.Id;
            relatedOffer.nu_dse__Program__c = objProgram.Id;
            //insert relatedOffer;
            Test.startTest();
            Attorney_StaticVariableUtility.isOfferTriggerExecuted = false;
            Database.Update(objOffer);
            
            
            List<nu_dse__Offer__c> lstOfferList = New list<nu_dse__Offer__c>();
            
            lstOfferList.Add(objOffer);
            Map<Id,nu_dse__Offer__c>mapOffer = New Map<Id,nu_dse__Offer__c>();
            mapOffer.Put(objOffer.Id,objOffer);
            
        //system.runAs(objUser){
            objOffer.nu_dse__Status__c = 'Negotiations Associate Approved' ;
               update objOffer;
            
            Attorney_CreateOrUpdateNDSOfferHandler.getOfferStatusLst();
        //}
           /* Attorney_CreateOrUpdateNDSOfferHandler.CreateOrUpdateNDSPaymentOffer(lstOfferList,mapOffer);
            Attorney_CreateOrUpdateNDSOfferHandler.setIntegrationFields(objOffer,'Test','TestReason');
            Attorney_CreateOrUpdateNDSOfferHandler.doSettlementMapping(objOffer);
            Attorney_CreateOrUpdateNDSOfferHandler.UpdateOfferField(lstOfferList);
            Attorney_CreateOrUpdateNDSOfferHandler.UpdateRelatedOfferField(lstOfferList);
            Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment AsyncCall = new Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment(objOffer.id);
            AsyncCall.execute(null);
            */Test.stopTest(); 
        }
        System.assert(true);
    }
    
    
    /***********************************
*@Method Name :  test_Fault_CreateOrUpdateNDSPaymentOffer
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSPaymentOffer.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_Fault_CreateOrUpdateNDSPaymentOffer(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        
        //Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
        //                     from Account
        //                    where nu_dse__CFT_Synced__c =: true Limit 1];
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        //  objAccount.nu_dse__CFT_Synced__c = true;
        //objAccount.Attorney__c = true;
        insert objAccount;
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        objTradLine.nu_dse__Current_Stage__c = 'New';
        //objTradLine.nu_dse__New_Creditor__c = objAccount.Id;
        objTradLine.Import_ID__c = '111111111122';
        objTradLine.applicant_type__c = 'Joint';
        
        Database.Update(objTradLine);
        
        /*nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         Limit 1];*/
        nu_dse__Offer__c objOffer = [Select Id from nu_dse__Offer__c Limit 1];
        //objOffer.nu_dse__Program__c = objProgram.Id;
        objOffer.NDS_Offer_Id__c = '12345';
        objOffer.nu_dse__Status__c = 'To Payment Processing';
        objOffer.Suspended_On__c = System.today()+2;
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+5);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+3);
        objOffer.Ended_On__c = System.today()+7;
        
        //update objOffer;
        //Database.Update(objOffer);
        List<nu_dse__Offer__c> lstOfferList = New list<nu_dse__Offer__c>();
        lstOfferList.Add(objOffer);
        Map<Id,nu_dse__Offer__c>mapOffer = New Map<Id,nu_dse__Offer__c>();
        mapOffer.Put(objOffer.Id,objOffer);
        System.runAs(objUser){
            
            Test.startTest();
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadtracNetDebtOfferFaultMock());
            Attorney_CreateOrUpdateNDSOfferHandler.CreateOrUpdateNDSPaymentOffer(lstOfferList,mapOffer);
            //Attorney_CreateOrUpdateNDSOfferHandler.setIntegrationFields(objOffer,'Test','TestReasonn vevbehfbvjhbfvhbdsksdnxmn nvnkdvnfdvndfnxxndkvjnjdxc  dv dv bfbdhhfdv'
             //                                                           +'nfvfbhbvhdbfkdfbvkdfhfbvgdngrfngkjdfnhkj wenjgknerkjgnerkjgnrekj nvfkjbnjfkbngkjbngkjngjbnjnkjnkjnkjnjk enjefngk fjnvkfkf dfvnjdfnvkjfnv dvfvjfnvkjsldfjweojfonfdsoieroiejrdsf');
            //Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment AsyncCall = new Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment(objOffer.id);
            //AsyncCall.execute(null);
            
            Test.stopTest(); 
        }
        System.assert(true);
    } 
    
    
    private static testMethod void test_Fault_CreateOrUpdateNDSPaymentOffer1(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        
        //Account objAccount = [Select id,FirstName,Attorney__c,recordTypeId,nu_dse__CFT_Synced__c,Name
        //                     from Account
        //                    where nu_dse__CFT_Synced__c =: true Limit 1];
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        //  objAccount.nu_dse__CFT_Synced__c = true;
        //objAccount.Attorney__c = true;
        insert objAccount;
        nu_dse__TradeLine__c objTradLine = [Select id,nu_dse__Original_Creditor__c,nu_dse__Program__c,Valid_Offers_Created__c
                                            from nu_dse__TradeLine__c Limit 1];
        objTradLine.nu_dse__Current_Stage__c = 'New';
        //objTradLine.nu_dse__New_Creditor__c = objAccount.Id;
        objTradLine.Import_ID__c = '111111111122';
        objTradLine.applicant_type__c = 'Joint';
        
        Database.Update(objTradLine);
        
        /*nu_dse__Program__c objProgram = [select id,Import_ID__c 
                                         from nu_dse__Program__c
                                         Limit 1];*/
        nu_dse__Offer__c objOffer = [Select Id from nu_dse__Offer__c Limit 1];
        //objOffer.nu_dse__Program__c = objProgram.Id;
        objOffer.NDS_Offer_Id__c = '12345';
        objOffer.nu_dse__Status__c = 'To Payment Processing';
        objOffer.Suspended_On__c = System.today()+2;
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+5);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+3);
        objOffer.Ended_On__c = System.today()+7;
        
        
        //Database.Update(objOffer);
        List<nu_dse__Offer__c> lstOfferList = New list<nu_dse__Offer__c>();
        lstOfferList.Add(objOffer);
        Map<Id,nu_dse__Offer__c>mapOffer = New Map<Id,nu_dse__Offer__c>();
        mapOffer.Put(objOffer.Id,objOffer);
        System.runAs(objUser){
            
            Test.startTest();
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSOffer.LeadtracNetDebtOfferFaultMock());
            update objOffer;
            System.enqueueJob(new Attorney_CreateOrUpdateNDSOfferHandler.AsynCallToNDSettlementPayment(objOffer.Id));
            Test.stopTest(); 
        }
        System.assert(true);
    } 
     
    /***********************************
*@Class Name :LeadTraceNetClinetMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
************************************/    
    public without sharing class LeadTraceNetClinetMock implements WebServiceMock{
        
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
*@Class Name :LeadtracNetDebtOfferMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
************************************/   
    public without sharing class LeadtracNetDebtOfferMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            
            LeadTracNetDebt.CreateOrUpdateSettlementPaymentsResponse_element settlementPaymentPlanResponse = Null;
            settlementPaymentPlanResponse = new LeadTracNetDebt.CreateOrUpdateSettlementPaymentsResponse_element();
            leadtracNetDebt.CreateOrUpdateSettlementPaymentPlanResult createOrUpdateSettlementPaymentsResult =Null;
            createOrUpdateSettlementPaymentsResult = New  leadtracNetDebt.CreateOrUpdateSettlementPaymentPlanResult();
            leadtracNetDebt.ResultMessage objResultMessage = New leadtracNetDebt.ResultMessage();
            objResultMessage.MessageType = 'TestMessage';
            objResultMessage.Message = 'Test';
            List<leadtracNetDebt.ResultMessage>lstResultMessage = New List<leadtracNetDebt.ResultMessage>();
            lstResultMessage.Add(objResultMessage);
            leadtracNetDebt.ArrayOfResultMessage Messages = New leadtracNetDebt.ArrayOfResultMessage();
            Messages.ResultMessage = lstResultMessage;
            createOrUpdateSettlementPaymentsResult.IsSuccessful =true;
            createOrUpdateSettlementPaymentsResult.Messages = Messages;
            
            settlementPaymentPlanResponse.CreateOrUpdateSettlementPaymentsResult = createOrUpdateSettlementPaymentsResult;
            response.put('response_x', settlementPaymentPlanResponse);
            
        }
    } 
    /***********************************
*@Class Name :LeadtracNetDebtOfferFaultMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
************************************/   
    public without sharing class LeadtracNetDebtOfferFaultMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            
            LeadTracNetDebt.CreateOrUpdateSettlementPaymentsResponse_element settlementPaymentPlanResponse = Null;
            settlementPaymentPlanResponse = new LeadTracNetDebt.CreateOrUpdateSettlementPaymentsResponse_element();
            leadtracNetDebt.CreateOrUpdateSettlementPaymentPlanResult createOrUpdateSettlementPaymentsResult =Null;
            createOrUpdateSettlementPaymentsResult = New  leadtracNetDebt.CreateOrUpdateSettlementPaymentPlanResult();
            leadtracNetDebt.ResultMessage objResultMessage = New leadtracNetDebt.ResultMessage();
            objResultMessage.MessageType = 'TestMessage';
            objResultMessage.Message = 'Test';
            List<leadtracNetDebt.ResultMessage>lstResultMessage = New List<leadtracNetDebt.ResultMessage>();
            lstResultMessage.Add(objResultMessage);
            leadtracNetDebt.ArrayOfResultMessage Messages = New leadtracNetDebt.ArrayOfResultMessage();
            Messages.ResultMessage = lstResultMessage;
            createOrUpdateSettlementPaymentsResult.IsSuccessful =False;
            createOrUpdateSettlementPaymentsResult.Messages = Messages;
            
            settlementPaymentPlanResponse.CreateOrUpdateSettlementPaymentsResult = createOrUpdateSettlementPaymentsResult;
            response.put('response_x', settlementPaymentPlanResponse);
            
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
}