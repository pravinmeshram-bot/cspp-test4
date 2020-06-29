@isTest
public class Test_Prizm_PaymentHandler {
	
    @isTest
    public Static void TestMethod1(){
        
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
        p.Draft_Plan_ID__c = '1234';
        insert p;
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        nu_dse__Payment__c pmt = new nu_dse__Payment__c();
        pmt.nu_dse__Program__c = p.id;
        pmt.RecordTypeId = DraftRecordTypeId;
        pmt.nu_dse__Transaction_Status__c = 'Cleared';
        pmt.Attorney__c = true;
        pmt.Import_ID__c = '1234';
        pmt.nu_dse__Amount__c = 123;
        insert pmt;
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        
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
        
        
    }
    
    @isTest
    public Static void TestMethod2(){
        
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
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        
        test.startTest();
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
        Test.setMock (WebServiceMock.class, new Test_Prizm_PaymentHandler.updateOppoMock());
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        pmt1.nu_dse__Transaction_Status__c = 'Cleared';
        update pmt1;
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        pmt.nu_dse__Transaction_Status__c = 'Cleared';
        update pmt;
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        pmt2.nu_dse__Transaction_Status__c = 'Cleared';
        update pmt2;
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        pmt2.nu_dse__Transaction_Status__c = 'Cancelled';
        //pmt2.Opportunity__c = opp.Id;
        update pmt2;
        
        Test.setMock (WebServiceMock.class, new Test_Prizm_PaymentHandler.updateOppoMock());
        
        l.Status = 'DNL Converted';
        l.Sub_Status__c = 'Warm Transfer';
        update l;
        
        Database.LeadConvert lc = new Database.LeadConvert();        
    	lc.setLeadId(L.id);
        lc.setConvertedStatus('DNL Converted');
		Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        pmt.nu_dse__Transaction_Status__c = 'Failed';
        //pmt2.Opportunity__c = opp.Id;
        update pmt;
        
        /*Opportunity opp = new Opportunity();
        opp.StageName = 'Prospecting';
        opp.name = 'Test';
        opp.CloseDate = Date.today()+30;
        insert opp;*/
        /*
        //Test.setMock (WebServiceMock.class, new Test_Prizm_PaymentHandler.updateOppoMock());
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        pmt2.nu_dse__Transaction_Status__c = 'Cancelled';
        //pmt2.Opportunity__c = opp.Id;
        //update pmt2;*/
        test.stopTest();
    }
    
    public class updateOppoMock implements WebServiceMock {
        public void doInvoke (
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                response.put('response_x', JSON.serialize('Success'));
                
            }
    }
    
}