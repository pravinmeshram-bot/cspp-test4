@isTest
public class Test_CreditorLookupController {

    @isTest
    public static void TestMethod1(){
        
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
        
        nu_dse__Tradeline__c t = new nu_dse__Tradeline__c();
        t.Attorney__c = true;
        t.FileNumber__c = '1234';
        t.nu_dse__Original_Debt__c = 1233;
        //t.Lead__c = l.Id;
        t.SFS_Current_Balance__c = 123;
        t.Applicant_Type__c = 'Applicant';
        t.Normalized_Current_Creditor__c = 'test';
        t.Normalized_Original_Creditor__c = 'test';
        insert t;
        
        Creditor_Lookup__c cl = new Creditor_Lookup__c();
        cl.Current_Creditor__c = 'Test';
        cl.Original_Creditor__c = 'Test';
        cl.Is_Lit__c = false;
        cl.Average_Settlement_Percentage__c = '43';
        cl.Settlement_Terms__c = 12;
        cl.Best_Single_Settlement__c = '23';
        insert cl;
        
        PageReference myVfPage = Page.CreditorLookupTradeline;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',t.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(t);
        CreditorLookupController obj = new CreditorLookupController(sc);
        
        CreditorLookupController obj1 = new CreditorLookupController();
    }
    
}