@isTest
public class Test_Prizm_TradelineHandler {

    @isTest
    public static void TestTralineHandler(){
        
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'CA';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        acc.Attorney__c = true;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
        insert acc;
        
        nu_dse__Program__c p = new nu_dse__Program__c();
        p.nu_dse__Account__c = acc.id;
        p.Import_ID__c = '1234';
        p.Attorney__c = true;
        insert p;
        
        DNL_Settlement_Rate__c rate = new DNL_Settlement_Rate__c();
        rate.Current_Creditor__c = 'test';
        rate.Original_Creditor__c = 'test';
        rate.Average_of_Adjusted_Settlement__c = 70;
        rate.Type__c = 'Legal';
        rate.IsActive__c = true;
        rate.Start_Date__c = date.today();
        insert rate;
        
        DNL_Settlement_Rate__c rate1 = new DNL_Settlement_Rate__c();
        rate1.Current_Creditor__c = 'test1';
        rate1.Original_Creditor__c = 'test1';
        rate1.Average_of_Adjusted_Settlement__c = 70;
        rate1.Type__c = 'Legal';
        rate1.IsActive__c = true;
        rate1.Start_Date__c = date.today();
        insert rate1;
        
        nu_dse__Tradeline__c t = new nu_dse__Tradeline__c();
        t.Attorney__c = true;
        t.FileNumber__c = '1234';
        t.nu_dse__Original_Debt__c = 1233;
        t.nu_dse__Current_Stage__c = 'New';
        //t.Lead__c = l.Id;
        t.SFS_Current_Balance__c = 123;
        t.Applicant_Type__c = 'Applicant';
        t.Normalized_Current_Creditor__c = 'test';
        t.Normalized_Original_Creditor__c = 'test';
        Attorney_CreateOrUpdateNDSTradeHandler.CreditorUpdated = true;
        insert t;
        
        Prizm_TradelineHandler.isTradelineUpdated = False;
        
        Lead l = new Lead();
        l.NDS_File_Number__c = '1234';
        l.lastName = 'test';
        l.Cash_in_Dedicated_Account__c = 1234;
        l.Addnl_Months_with_Loan__c = 1234;
        l.Loan_Amount__c = 1234;
        l.Loan_Term__c = 123;
        l.Status = 'DNL New Lead';
        l.Sub_Status__c = 'New Lead';
        l.Origination_Fee__c = 200;
        l.Unpaid_Program_Fees__c = 200;
        insert l;
        
        Prizm_TradelineHandler.isTradelineUpdated = False;
        Prizm_TradelineHandler.DNLPercentUpdated = false;
        t.Lead__c = l.Id;
        t.nu_dse__Current_Stage__c = 'Current';
        update t;
        
        t.Normalized_Current_Creditor__c = 'test1';
        t.Normalized_Original_Creditor__c = 'test1';
        Prizm_TradelineHandler.DNLPercentUpdated = false;
        Update t;
    }
    
}