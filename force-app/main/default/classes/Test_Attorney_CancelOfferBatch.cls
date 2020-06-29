@isTest
public class Test_Attorney_CancelOfferBatch{
    
    @isTest
    public static void TestMethod1(){
        
        Id recCreditorID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recCreditorID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        //objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount); 
         
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_CancelOffersBatch';
        insert bd;
        
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Import_Id__c = '11111111';
        Database.Insert(objProgram);
        System.debug('objProgram'+objProgram);
        
        //Create Tradeline Object
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
           ObjTradeline.nu_dse__Original_Account_Number__c = 'abc';
        objTradeline.SFS_Current_Balance__c = 11111;
        ObjTradeLine.nu_dse__New_Creditor__c = objNewCreditorAccount.Id;
        Database.Insert(objTradeLine);
        
        objTradeline.Import_id__c = '11111111';
        Database.Update(objTradeLine);
        
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.nu_dse__Program__c = objProgram.Id;
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Offer Made';
        //objOffer.NDS_Offer_Id__c  = '233';
        objOffer.Suspended_On__c = System.today()+1;
        
        objOffer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
        objOffer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()-6);
        objOffer.Ended_On__c = System.today()+6;
        Database.insert(objOffer);
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        System.schedule('test', CRON_EXP, new Attorney_CancelOffersSchedular());
        
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
        Database.executebatch(new Attorney_CancelOffersBatch(),1);
        Attorney_CancelOffersBatch.fakeMethod();
        
    }
    
}