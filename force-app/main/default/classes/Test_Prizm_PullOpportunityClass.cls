@isTest
public class Test_Prizm_PullOpportunityClass {
	
    @isTest
    public Static void testPullOpportunity(){
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        Attorney_StaticVariableUtility.isTradelineTriggerExecuted = true;
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'CA';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        acc.Attorney__c = true;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
        insert acc;
        
        Account acc1 = new Account();
       // acc1.FirstName = 'test';
        acc1.Name = 'test';
        acc1.NDS_File_Number__c = '1234';
        //acc1.PersonMailingState = 'CA';
        acc1.nu_dse__SSN__c = 'ABBHBD6876';
        //acc1.Attorney__c = true;
        acc1.BillingCOuntry = 'USA';
        acc1.ShippingCountry ='USA';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        insert acc1;
        
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
        t.isNewTrade__c=true;
       // t.nu_dse__Original_Creditor__c = acc1.id;
        t.nu_dse__Original_Account_Number__c = '12345434';
        insert t;
        
        nu_dse__Offer__c Offer = new nu_dse__Offer__c();
        Offer.nu_dse__TradeLine__c = t.Id;
        offer.FileNumber__c = '1234';
        offer.nu_dse__Status__c = 'Accepted';
        offer.nu_dse__Program__c = p.id;
        insert offer;
        
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
        
        l.Status = 'DNL Converted';
        l.Sub_Status__c = 'Warm Transfer';
        update l;
        
        User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '9Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'Pre-Sales'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        Database.LeadConvert lc = new Database.LeadConvert();        
    	lc.setLeadId(L.id);
        lc.setConvertedStatus('DNL Converted');
        Database.LeadConvertResult lcr; 
        System.runAs(u1){
		lcr = Database.convertLead(lc);
        }
        
        List<Id> OpportunityId = new List<Id>();
        opportunityId.add(lcr.getOpportunityId());
        pullOpportunitydetailsClass.UpdateNewTradeNPay(OpportunityId);
        pullOpportunitydetailsClass.getOppDataJSON(OpportunityId);
        
    }
    
}