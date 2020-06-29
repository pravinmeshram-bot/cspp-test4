@isTest
public class Test_Batch_Tradeline_Payments_issue {

    @testsetup static void setupTestData1() {
      Account acc = new Account();
        acc.name = 'test';
        //acc.NDS_File_Number__c = '1234';
       // acc.PersonMailingState = 'CA';
       // acc.nu_dse__SSN__c = 'ABBHBD6876';
       // acc.Attorney__c = true;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        insert acc;
        
               
        nu_dse__Program__c p = new nu_dse__Program__c();
        p.nu_dse__Account__c = acc.id;
        p.Import_ID__c = '1234';
        p.Attorney__c = true;
        p.Draft_Plan_ID__c = '1234';
        insert p;
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        nu_dse__Payment__c pmt = new nu_dse__Payment__c();
        pmt.nu_dse__Program__c = p.id;
        pmt.RecordTypeId = DraftRecordTypeId;
        pmt.nu_dse__Transaction_Status__c = 'Pending';
        pmt.Attorney__c = true;
        
        pmt.Import_ID__c = '1234';
        pmt.nu_dse__Amount__c = 123;
        pmt.FileNumber__c = '1234';
        pmt.nu_dse__Schedule_Date__c = Date.today();
        insert pmt;
        
        nu_dse__Payment__c pmt1 = new nu_dse__Payment__c();
        pmt1.nu_dse__Program__c = p.id;
       pmt1.RecordTypeId = DraftRecordTypeId;
        pmt1.nu_dse__Transaction_Status__c = 'Pending';
        pmt1.Attorney__c = true;
        pmt1.Import_ID__c = '12345';
        pmt1.FileNumber__c = '1234';
        pmt1.nu_dse__Schedule_Date__c = Date.today()+15;
        pmt1.nu_dse__Amount__c = 123;
        insert pmt1;
        
        nu_dse__Payment__c pmt2 = new nu_dse__Payment__c();
        pmt2.nu_dse__Program__c = p.id;
        pmt2.RecordTypeId = DraftRecordTypeId;
        pmt2.nu_dse__Transaction_Status__c = 'Pending';
        pmt2.Attorney__c = true;
        pmt2.Import_ID__c = '12346';
        pmt2.FileNumber__c = '1234';
        pmt2.nu_dse__Amount__c = 123;
        pmt2.nu_dse__Schedule_Date__c = Date.today()+30;
        insert pmt2;
        
        nu_dse__Tradeline__c t = new nu_dse__Tradeline__c();
        t.Attorney__c = true;
        t.FileNumber__c = '1234';
        t.nu_dse__Original_Debt__c = 1233;
        t.nu_dse__Program__c = p.id;
        t.SFS_Current_Balance__c = 123;
        t.Applicant_Type__c = 'Applicant';
        t.nu_dse__Original_Creditor__c = acc.id;
        t.nu_dse__Original_Account_Number__c = '12345434';
        insert t;
        
      Opportunity o = new Opportunity();
        o.Amount = 1000;
        o.Additional_months_with_loan__c = 12;
        o.Name = 'Test Test';
        o.CloseDate = Date.today()+1;
        //o.Applicant_State__c = 'Joint';
        o.AccountId = acc.Id;
        //o.Program_ID__c=p.Id;
        o.StageName = 'DNL-Prospecting';
        o.CreatedDate =Date.valueOf('2019-06-24T06:10:21.000+0000');
        //o.CreatedDate = System.Now() - 5 ;
        insert o;
                
  }
    @isTest
    public static void TestPaymentTraderetrieve()
    {
       list<opportunity> lstopp=new list<opportunity>();
        opportunity op=[select id,Amount,Name from Opportunity where Amount=1000];
        nu_dse__Program__c prg=[select id,name,Import_ID__c from nu_dse__Program__c where Import_ID__c='1234'];
        op.Program_ID__c=prg.Id;
        lstopp.add(op);
        update lstopp;
        test.startTest();
      Batch_Tradeline_payments_retrieve b=new Batch_Tradeline_payments_retrieve();
        
        Database.QueryLocator ql = b.start(null);
        b.execute(null,lstopp);
        b.Finish(null);
     // Database.executeBatch(b,30);
       test.stopTest();
    }
}