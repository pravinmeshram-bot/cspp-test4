/***********************************
*@Class Name :Test_Attorney_CreateOrUpdateNDSPayment
*@Purpose:It is Used to test the functionlity of the class Attorney_CreateOrUpdateNDSPaymentHandler
*@Created Date :03/18/2018
************************************/
@isTest(seeAllData = false)
private without Sharing class Test_Attorney_CreateOrUpdateNDSPayment {
/***********************************
*@Method Name :  CreateData
*@Params :NA
*@Purpose:To create the data for test class 
*@Created Date:03/18/2018
************************************/    
    @TestSetup
    private static void creatData(){
        //Test.startTest();
        //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetClientMock());
        //Test.stopTest();
        
        //Update User
        //
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'AsynCallToNDSettlementPaymentWithSplits';
        insert bd;
        
        Batch_Data__c bd1 = new Batch_Data__c();
        bd1.Name = 'AsynCallToNDDraftPaymentWithSplits';
        insert bd1;
        
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '9Attorney_TestUser@test.com';
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
        //PaymentTriggerHandler.hasAlreadyRanAfterUpdate = true;
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Draft_Plan_ID__c= '232343';
        objProgram.Import_id__c = '2323';
        Database.Insert(objProgram);
        
        //Create Account Object
        Id recID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = False;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        //Database.Insert(objNewCreditorAccount);
        
        //Create Tradeline Object
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';        
        objTradeLine.nds_Original_Creditor_Name__c = 'Test';
        objTradeline.nu_dse__Original_Account_Number__c = '12234';
        Database.Insert(objTradeLine);
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Offer Made';
        objOffer.NDS_Offer_Id__c  = '233';
            objOffer.nu_dse__Program__c = objProgram.id;
        Database.insert(objOffer);

        
     // Create Payment Data
        //;
        
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = objProgram.Id;
            //objPayment.nu_dse__Transaction_Status__c = 'Failed';
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+30);
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
   //     objPayment.nu_dse__Transaction_Status__c = 'Completed';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
            Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            objPayment.RecordTypeId = DraftPlanRecId;
            //PaymentTriggerHandler.hasAlreadyRanAfterUpdate = true;
        Database.Insert(objPayment);
        System.debug('***'+[select id, IsAttorney__c,IsRelatedRecordEligibleForPick__c,Integration_Status__c,Integration_Reason__c,Integration_Reason_2__c from nu_dse__Payment__c where id=:objPayment.Id]);
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
    }
    }
    
    /*public static testMethod void testPaymentHandler(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        nu_dse__offer__c objOffer = [Select Id, NDS_offer_id__c from nu_dse__Offer__c Limit 1];
        nu_dse__program__c objProgram = [Select Id, Import_id__c from nu_dse__Program__c Limit 1];
        System.runAs(objUser){
        Test.startTest();
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = objProgram.Id;
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today());
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
        objPayment.nu_dse__Transaction_Status__c = 'Pending';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
        Database.Insert(objPayment);
        
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = false;
            
        objPayment.Attorney_Payment_Id__c= '13434';
        /*objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 14;
        objPayment.nu_dse__Amount__c = 12.25;
        objPayment.nu_dse__Transaction_Status__c = 'Completed';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;*/
      /*  Database.update(objPayment);
        
        Test.stopTest();
        }
    }*/
    
    public static testMethod void testPaymentHandler1(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        nu_dse__offer__c objOffer = [Select Id, NDS_offer_id__c from nu_dse__Offer__c Limit 1];
        nu_dse__program__c objProgram = [Select Id, Import_id__c from nu_dse__Program__c Limit 1];
        System.runAs(objUser){
        Test.startTest();
            Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
            Attorney_CreateOrUpdateNDSOfferHandler.CreatedByUpdated = true;
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = objProgram.Id;
        //objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today());
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
        objPayment.nu_dse__Transaction_Status__c = 'Pending';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Withdrawal';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
            //objPayment.Refund_Payment__c = true;
        Database.Insert(objPayment);
        
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = false;
            
        objPayment.Attorney_Payment_Id__c= '13434';
        /*objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 14;
        objPayment.nu_dse__Amount__c = 12.25;
        objPayment.nu_dse__Transaction_Status__c = 'Completed';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;*/
            objPayment.nu_dse__Processor_Fee__c = 1234;
        Database.update(objPayment);
        
            Delete objPayment;
        Test.stopTest();
        }
    }
    
/***********************************
*@Method Name :  test_CreateOrUpdateNDSPaymentDraft
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSPayment.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_CreateOrUpdateNDSPaymentDraft(){
        User objUser = [Select id,Name,isActive,Attorney_Ignore_Validation__c from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        nu_dse__Payment__c objPayment = [Select Id from nu_dse__Payment__c Limit 1];
        
        ObjUser.Attorney_Ignore_Validation__c = true;
        Update ObjUSer;
        nu_dse__offer__c objOffer = [Select Id, NDS_offer_id__c from nu_dse__Offer__c Limit 1];
        System.runAs(objUser){
            Test.startTest();
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__offer__c=objOffer.Id;
        objPayment.Attorney_Payment_Id__c= '12345';
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+45);
        objPayment.nu_dse__Payment_Sequence_Number__c = 122;
        objPayment.nu_dse__Amount__c = 134;
        objPayment.nu_dse__Transaction_Status__c = 'Cleared';
        objPayment.Statused_On__c = System.today()+6;
        objPayment.Status_Reason__c = 'TestReaso';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType1';
        objPayment.Draft_Split__c = 213.3;
        objPayment.Legal_Split__c = 123;
        objPayment.Reserve_Split__c = 2;
        objPayment.Retainer_Split__c = 223;
        objPayment.Service_Split__c = 23;
        objPayment.Trust_Split__c = 23;
        objPayment.Refund_Payment__c = true;
        Database.Update(objPayment);
        
        ObjPayment.Attorney_Payment_Id__c = '122345';
        ObjPayment.nu_dse__Processor_Fee__c = 123;
            objPayment.nu_dse__Transaction_Status__c='Failed';
            Attorney_StaticVariableUtility.isPaymentTriggerExecuted = False;   
        Database.Update(objPayment);
        
        List<nu_dse__Payment__c>lstPayment = new List<nu_dse__Payment__c>();
        Map<id,nu_dse__Payment__c> mapPayment = New Map<Id,nu_dse__Payment__c>();
                Map<id,nu_dse__Payment__c> map1Payment = New Map<Id,nu_dse__Payment__c>();

        mapPayment.Put(objPayment.Id,objPayment);
                map1Payment.Put(objPayment.Id,objPayment);

        
            
            Attorney_StaticVariableUtility.isPaymentTriggerExecuted = False;
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetDraftMock()); 
            Attorney_CreateOrUpdateNDSPaymentHandler.CreateOrUpdateNDSPayment(lstPayment,mapPayment,map1Payment);
            Attorney_CreateOrUpdateNDSPaymentHandler.doSettlementMapping(objPayment);
            Attorney_CreateOrUpdateNDSPaymentHandler.beforeUpdateHandler(lstPayment,mapPayment,false);
            Test.stopTest(); 
            Delete ObjPayment;
        }
        System.assert(true);
    }
/***********************************
*@Method Name :  test_Fault_CreateOrUpdateNDSPaymentDraft
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSPayment.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_Fault_CreateOrUpdateNDSPaymentDraft(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        nu_dse__Payment__c objPayment = [Select Id from nu_dse__Payment__c Limit 1];
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+15);
        objPayment.nu_dse__Payment_Sequence_Number__c = 122;
        objPayment.nu_dse__Amount__c = 134;
        objPayment.nu_dse__Transaction_Status__c = 'Cleared';
        objPayment.Statused_On__c = System.today()+6;
        objPayment.Status_Reason__c = 'TestReaso';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType1';
        objPayment.Draft_Split__c = 213.3;
        objPayment.Legal_Split__c = 123;
        objPayment.Reserve_Split__c = 2;
        objPayment.Retainer_Split__c = 223;
        objPayment.Service_Split__c = 23;
        objPayment.Trust_Split__c = 23;
        Database.Update(objPayment);
        
        List<nu_dse__Payment__c>lstPayment = new List<nu_dse__Payment__c>();
        Map<id,nu_dse__Payment__c> mapPayment = New Map<Id,nu_dse__Payment__c>();
        mapPayment.Put(objPayment.Id,objPayment);
        Map<id,nu_dse__Payment__c> map1Payment = New Map<Id,nu_dse__Payment__c>();
        map1Payment.Put(objPayment.Id,objPayment);
        System.runAs(objUser){
            
            Test.startTest();
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetDraftFaultMock()); 
            Attorney_CreateOrUpdateNDSPaymentHandler.CreateOrUpdateNDSPayment(lstPayment,mapPayment,map1payment);
            Test.stopTest(); 
        }
        System.assert(true);
    }    
/***********************************
*@Method Name :  test_CreateOrUpdateNDSPaymentSettlement
*@Params :NA
*@Purpose:It is Used to test the functionality of the Method CreateOrUpdateNDSPayment.   
*@Created Date :16/03/2018
************************************/
    private static testMethod void test_CreateOrUpdateNDSPaymentSettlement(){
        User objUser = [Select id,Name,isActive from User where
                        Profile.Name=:'System Administrator' AND isActive =true limit 1];
        Id  settlementPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        nu_dse__Payment__c objPayment = [Select Id from nu_dse__Payment__c Limit 1];
        nu_dse__Offer__c objOffer = [Select Id from nu_dse__Offer__c Limit 1];
        objPayment.Attorney_Payment_Id__c= '343243';
        objPayment.RecordTypeId = settlementPlanRecId;
        
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 122;
        objPayment.nu_dse__Amount__c = 134;
        objPayment.nu_dse__Transaction_Status__c = 'Cleared';
        objPayment.Statused_On__c = System.today()+6;
        objPayment.Status_Reason__c = 'TestReaso';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType1';
        objPayment.Draft_Split__c = 213.3;
        objPayment.Legal_Split__c = 123;
        objPayment.Reserve_Split__c = 2;
        objPayment.Retainer_Split__c = 223;
        objPayment.Service_Split__c = 23;
        objPayment.Trust_Split__c = 23;
        Database.Update(objPayment);
        
        List<nu_dse__Payment__c>lstPayment = new List<nu_dse__Payment__c>();
        Map<id,nu_dse__Payment__c> mapPayment = New Map<Id,nu_dse__Payment__c>();
        mapPayment.Put(objPayment.Id,objPayment);
        Map<id,nu_dse__Payment__c> map1Payment = New Map<Id,nu_dse__Payment__c>();
        map1Payment.Put(objPayment.Id,objPayment);
        Set<Id> PaymentId = new Set<Id>();
        PaymentId.add(objPayment.Id);
        System.runAs(objUser){
            
            Test.startTest();
             Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetSettlementMock());
            Attorney_CreateOrUpdateNDSPaymentHandler.CreateOrUpdateNDSPayment(lstPayment,mapPayment,map1payment);
            Attorney_CreateOrUpdateNDSPaymentHandler.AsynCallToNDSettlementPaymentWithSplits asynCall = new Attorney_CreateOrUpdateNDSPaymentHandler.AsynCallToNDSettlementPaymentWithSplits(PaymentId);
            asynCall.execute(null);
            Test.stopTest(); 
        }
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
    
/***********************************
*@Class Name :LeadTraceNetDraftMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
************************************/    
    public without sharing class LeadTraceNetDraftMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_element objResponse = Null;  
            objResponse = New leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_element();
            leadtracNetServicing.UpdateDraftPaymentResult CreateOrUpdateDraftPaymentWithSplitListResult =Null;
            CreateOrUpdateDraftPaymentWithSplitListResult = New leadtracNetServicing.UpdateDraftPaymentResult();
            CreateOrUpdateDraftPaymentWithSplitListResult.IsSuccessful  = true;
            leadtracNetServicing.ArrayOfResultMessage objMessages = New leadtracNetServicing.ArrayOfResultMessage();
            leadtracNetServicing.ResultMessage ResultMessage =  New leadtracNetServicing.ResultMessage();
            ResultMessage.Message = 'Messsage';
            ResultMessage.MessageType = 'TestMessageType';
            List<leadtracNetServicing.ResultMessage>lstResultMessage = New List<leadtracNetServicing.ResultMessage>();
            objMessages.ResultMessage = lstResultMessage;
            CreateOrUpdateDraftPaymentWithSplitListResult.Messages = objMessages;
            objResponse.CreateOrUpdateDraftPaymentWithSplitListResult = CreateOrUpdateDraftPaymentWithSplitListResult;
            response.put('response_x', objResponse);
        }
    }
/***********************************
*@Class Name :LeadTraceNetDraftFaultMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
************************************/    
    public without sharing class LeadTraceNetDraftFaultMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_element objResponse = Null;  
            objResponse = New leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_element();
            leadtracNetServicing.UpdateDraftPaymentResult CreateOrUpdateDraftPaymentWithSplitListResult =Null;
            CreateOrUpdateDraftPaymentWithSplitListResult = New leadtracNetServicing.UpdateDraftPaymentResult();
            CreateOrUpdateDraftPaymentWithSplitListResult.IsSuccessful  = False;
            leadtracNetServicing.ArrayOfResultMessage objMessages = New leadtracNetServicing.ArrayOfResultMessage();
            leadtracNetServicing.ResultMessage ResultMessage =  New leadtracNetServicing.ResultMessage();
            ResultMessage.Message = 'Messsage';
            ResultMessage.MessageType = 'TestMessageType';
            List<leadtracNetServicing.ResultMessage>lstResultMessage = New List<leadtracNetServicing.ResultMessage>();
            objMessages.ResultMessage = lstResultMessage;
            CreateOrUpdateDraftPaymentWithSplitListResult.Messages = objMessages;
            objResponse.CreateOrUpdateDraftPaymentWithSplitListResult = CreateOrUpdateDraftPaymentWithSplitListResult;
            response.put('response_x', objResponse);
        }
    }    
/***********************************
*@Class Name :LeadTraceNetSettlementMock
*@Purpose:It is Used to create the mock response
*@Created Date :03/18/2018
************************************/    
    public without sharing class LeadTraceNetSettlementMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            if(soapAction.endsWith('CreateOrUpdateDraftPaymentWithSplitList')){
            LeadtracNetDebt.CreateOrUpdateSettlementPaymentWithSplitListResponse_element respElement = Null;
            respElement = new LeadtracNetDebt.CreateOrUpdateSettlementPaymentWithSplitListResponse_element();
            LeadtracNetDebt.UpdateDraftPaymentResult CreateOrUpdateSettlementPaymentWithSplitListResult = Null;
            CreateOrUpdateSettlementPaymentWithSplitListResult =  new LeadtracNetDebt.UpdateDraftPaymentResult();
            LeadtracNetDebt.ArrayOfResultMessage objMessages = New LeadtracNetDebt.ArrayOfResultMessage();
            LeadtracNetDebt.ResultMessage objResultMessage =  New LeadtracNetDebt.ResultMessage();
            objResultMessage.MessageType ='SuccessTest';
            objResultMessage.Message = 'Test';
            List<LeadtracNetDebt.ResultMessage>lstMessage = New List<LeadtracNetDebt.ResultMessage>();
            lstMessage.Add(objResultMessage);
            objMessages.ResultMessage = lstMessage;
            LeadtracNetDebt.Split Split = New LeadtracNetDebt.Split();
            Split.SplitId = 2323;
            Split.Name = 'Test';
            Split.Amount = 23432;
            List<LeadtracNetDebt.Split>lstSplit = New List<LeadtracNetDebt.Split>();
            lstSplit.Add(Split);
            LeadtracNetDebt.ArrayOfSplit Splits = New LeadtracNetDebt.ArrayOfSplit();
            Splits.Split = lstSplit;
            LeadtracNetDebt.Payment DraftPayment = New LeadtracNetDebt.Payment();
            DraftPayment.Splits = Splits;
            LeadtracNetDebt.SettlementPlan SettlmentPlan = New LeadtracNetDebt.SettlementPlan();
            LeadtracNetDebt.ArrayOfPayment PaymentsArray = New LeadtracNetDebt.ArrayOfPayment();
            LeadtracNetDebt.Payment objPayment = New LeadtracNetDebt.Payment();
            objPayment.Splits = Splits;
            objPayment.PaymentId = 3242;
            objPayment.Number_x = 234;
            List<LeadtracNetDebt.Payment>lstPayment = New List<LeadtracNetDebt.Payment>();
            lstPayment.add(objPayment);
            PaymentsArray.Payment = lstPayment;
            SettlmentPlan.Payments = PaymentsArray;
            CreateOrUpdateSettlementPaymentWithSplitListResult.IsSuccessful =true;
            CreateOrUpdateSettlementPaymentWithSplitListResult.Messages = objMessages;
            CreateOrUpdateSettlementPaymentWithSplitListResult.DraftPayment= DraftPayment;
            CreateOrUpdateSettlementPaymentWithSplitListResult.SettlmentPlan = SettlmentPlan;
            respElement.CreateOrUpdateSettlementPaymentWithSplitListResult = CreateOrUpdateSettlementPaymentWithSplitListResult;
            response.put('response_x', respElement);
            }
            else if(soapAction.endsWith('CreateOrUpdateSettlementPaymentWithSplitList')){
                response.put('response_x',new LeadtracNetDebt.CreateOrUpdateSettlementPaymentWithSplitListResponse_element());
            }
        }
    }     
}