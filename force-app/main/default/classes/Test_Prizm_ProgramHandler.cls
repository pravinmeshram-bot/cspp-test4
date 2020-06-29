@isTest
public class Test_Prizm_ProgramHandler {
    
    @isTest
    public static void TestMethod1(){
        
        Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        
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
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        insert u1;
        
        Account acc = new Account();
            acc.FirstName = 'test';
            acc.LastName = 'test';
        	acc.Phone = '1234567890';
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
        	//p.DNL_Status__c = 'Converted';
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
        	objTradeline.SFS_Current_Balance__c	= 6545;
          //  objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
            objTradeline.nu_dse__Original_Account_Number__c = '12234';
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
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        Prizm_PaymentHandler.PrizmTriggerExceuted = false;
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        
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
        
        nu_dse__Fee_Template__c ft = new nu_dse__Fee_Template__c();
        ft.Attorney_Program_Type__c = 'Anchor';
        ft.Debt_Amount__c = 'Over 30000';
        ft.nu_dse__Settlement_Pct__c = 42;
        ft.nu_dse__Service_Fee_Percentage__c = 19;
        ft.Portfolio_Name__c = 'Anchor';
        ft.nu_dse__GCS_Fee_Group_Id__c = '12345';
        ft.Service_Fee_Percentage__c = 2;
        insert ft;
        
        Database.LeadConvert lc = new Database.LeadConvert();        
        lc.setLeadId(L.id);
        lc.setConvertedStatus('DNL Converted');
        Database.LeadConvertResult lcr;
        System.runAs(u1){
            lcr = Database.convertLead(lc);
        }
        
        List<Id> OpportunityId = new List<Id>();
        opportunityId.add(lcr.getOpportunityId());
        
        Prizm_ProgramHandler.TotalFeesUpdated = false;
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        p.Total_Fees__c = 100;
        p.DNL_Status__c = 'Converted';
        p.nu_dse__Program_Status__c = 'Graduated';
        update p;
        
        Attorney_StaticVariableUtility.groupTasksCreatedforPrizm = false;
        p.DNL_Status__c = 'Pre-TILA Signed';
        p.nu_dse__Fee_Template__c = ft.Id;
        update p;
        
    }        
    
    /*@isTest
    public static void TestMethod2(){
        
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
        //acc1.FirstName = 'test';
        acc1.Name = 'test';
        acc1.NDS_File_Number__c = '1234';
        //acc1.PersonMailingState = 'CA';
        acc1.nu_dse__SSN__c = 'ABBHBD6876';
        //acc1.Attorney__c = true;
        acc1.BillingCOuntry = 'USA';
        acc1.ShippingCountry ='USA';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        insert acc1;
        
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
        
        nu_dse__Program__c objprogram = new nu_dse__Program__c();
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
        
        insert objProgram;
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        nu_dse__Payment__c pmt = new nu_dse__Payment__c();
        pmt.nu_dse__Program__c = objProgram.id;
        pmt.RecordTypeId = DraftRecordTypeId;
        pmt.nu_dse__Transaction_Status__c = 'Pending';
        pmt.Attorney__c = true;
        pmt.Import_ID__c = '1234';
        pmt.nu_dse__Amount__c = 123;
        pmt.FileNumber__c = '1234';
        pmt.nu_dse__Schedule_Date__c = Date.today();
        insert pmt;
        
        nu_dse__Payment__c pmt1 = new nu_dse__Payment__c();
        pmt1.nu_dse__Program__c = objProgram.id;
        pmt1.RecordTypeId = DraftRecordTypeId;
        pmt1.nu_dse__Transaction_Status__c = 'Pending';
        pmt1.Attorney__c = true;
        pmt1.Import_ID__c = '12345';
        pmt1.FileNumber__c = '1234';
        pmt1.nu_dse__Schedule_Date__c = Date.today()+15;
        pmt1.nu_dse__Amount__c = 123;
        insert pmt1;
        
        nu_dse__Payment__c pmt2 = new nu_dse__Payment__c();
        pmt2.nu_dse__Program__c = objProgram.id;
        pmt2.RecordTypeId = DraftRecordTypeId;
        pmt2.nu_dse__Transaction_Status__c = 'Pending';
        pmt2.Attorney__c = true;
        pmt2.Import_ID__c = '12346';
        pmt2.FileNumber__c = '1234';
        pmt2.nu_dse__Amount__c = 123;
        pmt2.nu_dse__Schedule_Date__c = Date.today()+30;
        insert pmt2;
        
        NDS_User_List__c NDSUser = new NDS_User_List__c();
            NDSUser.Email__c = 'mayur.techup@gmail.com';
            NDSUser.First_Name__c = 'Mayur';
            NDSUser.Last_Name__c = 'Agrawal';
            NDSUser.IsActive__c = 'True';
            NDSUser.User_Name__c = 'magrawal';
            NDSUser.User_Id__c = '1234';
            insert NDSUser;
        
        nu_dse__Tradeline__c t = new nu_dse__Tradeline__c();
        t.Attorney__c = true;
        t.FileNumber__c = '1234';
        t.nu_dse__Original_Debt__c = 1233;
        t.nu_dse__Program__c = objProgram.id;
        t.SFS_Current_Balance__c = 123;
        t.Applicant_Type__c = 'Joint';
        t.nu_dse__Original_Creditor__c = acc1.id;
        t.nu_dse__Original_Account_Number__c = '12345434';
        t.Negotiator__c = UserInfo.getUserId();
            t.NDS_Negotiator_Id__c ='1234';
            t.nds_Debt_Type__c = 'TestType';
        insert t;
        
        nu_dse__Offer__c Offer = new nu_dse__Offer__c();
        Offer.nu_dse__TradeLine__c = t.Id;
        offer.FileNumber__c = '1234';
        offer.nu_dse__Status__c = 'Accepted';
        offer.nu_dse__Program__c = objProgram.id;
            Offer.Approved__c = true;
            offer.nu_dse__TradeLine__c = t.Id;
            //   objOffer.nu_dse__Status__c = 'Offer Made';
            //objOffer.NDS_Offer_Id__c  = '233';
            Offer.Suspended_On__c = System.today()+1;
            
           Offer.nu_dse__Valid_Until__c = Date.ValueOf(System.today()+4);
            Offer.nu_dse__First_Payment_Date__c = Date.valueOf(System.today()+1);
           Offer.Ended_On__c = System.today()+6;
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
        
        Prizm_ProgramHandler.TotalFeesUpdated = false;
        objProgram.Total_Fees__c = 100;
        objProgram.nu_dse__Program_Status__c = 'Graduated';
        update objProgram;
        
    }*/
    
}