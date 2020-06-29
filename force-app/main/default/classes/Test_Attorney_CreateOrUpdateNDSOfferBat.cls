@isTest
public class Test_Attorney_CreateOrUpdateNDSOfferBat {
    
    @TestSetup
    private static void creatData(){
        
        /*Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetClientMock());
        Test.stopTest();*/
        
        //Update User
         User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '11Attorney_TestUser@test.com';
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
        bd.Name = 'Attorney_CreateOrUpdateNDSOfferBatch';
        insert bd;
        
        system.runAs(u1){
        //Create Program reocrd
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
        objTradeline.nu_dse__Original_Account_Number__c = '1234';
        objTradeLine.Import_id__c = '2323';
        objTradeLine.Applicant_type__C = 'Joint';
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
        Database.Insert(objTradeLine);
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted =false;
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Offer Made';
            objOffer.PushToNDS__c = True;
        //objOffer.NDS_Offer_Id__c  = '233';
        //objOffer.IsAttorney__c = True;
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
        Database.insert(objOffer);
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = false;
    }
    }
    
    @isTest static void batchTest () {
        Test.startTest ();
            Attorney_CreateOrUpdateNDSOfferBatch NDSOfferBatch = new Attorney_CreateOrUpdateNDSOfferBatch ();
            Database.executeBatch(NDSOfferBatch,1);
        Attorney_CreateOrUpdateNDSOfferBatch.fakeMethod();
        Test.stoptest ();
    }
}