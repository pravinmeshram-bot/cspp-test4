@isTest
public class Test_Attorney_CreateOrUpdateNDSTradeBat {
    
    @testSetup
    private static void creatData(){
        /*Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetClientMock());
        Test.stopTest();*/
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_CreateOrUpdateNDSTradeBatch';
        insert bd;
        
        //Update User
        User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '65Attorney_TestUser@test.com';
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
        
        //Create Account Object
        Id recID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        //objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);
        
        //Create Tradeline Object
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
                objTradeLine.nu_dse__Original_account_number__c = '123';

         objTradeline.applicant_type__c = 'Joint';
        objTradeLine.SFS_Current_Balance__c = 2323;
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
        Database.Insert(objTradeLine);
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted =false;
        
        /*nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c ();
        groupTask.Program__c = objProgram.Id;
        //groupTask.Task_Id__c = '1';
        groupTask.nu_dse__Subject__c = 'Test';
        groupTask.nu_dse__Description__c = 'Testing';
        groupTask.Subject_Picklist__c = '30 Day In-House Follow Up';
        groupTask.Priority__c = 'High';
        groupTask.nu_dse__ActivityDate__c = Date.Today ();
        insert groupTask;*/
            
        //Create Offer Object 
        /*nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Offer Made';
        objOffer.NDS_Offer_Id__c  = '233';
        //objOffer.IsAttorney__c = True;
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
        Database.insert(objOffer);
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = false;*/
        
    }
    }
    
    @isTest static void batchTest () {
        Test.startTest ();
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
            Attorney_CreateOrUpdateNDSTradeBatch NDSTradeBatch = new Attorney_CreateOrUpdateNDSTradeBatch ();
            Database.executeBatch(NDSTradeBatch,1);
        Attorney_CreateOrUpdateNDSTradeBatch.fakeMethod();
        Test.stoptest ();
    }
}