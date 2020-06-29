@isTest
public class Test_PullDataForPrizmLead {
    
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
        
    }
    @isTest
    public static void testDoPostLeadPull(){
        
       /* RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        JSONGenerator gen = JSON.createGenerator(true); 
        List<String> listOfFileIds = new List<String>();
        listOfFileIds.add('1234');
        gen.writeObject(listOfFileIds);        
        String jsonS = gen.getAsString();
        req.requestURI = '/services/apexrest/pullDataForPrizmLead';
        req.requestBody = Blob.valueOf(jsonS);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;*/
        
        Test.startTest();
        PullDataForPrizmLead.doPostLeadPull();
        Test.stopTest();
        /*String endpoint = '/services/apexrest/pullDataForPrizmLead';
        List<String> listOfFileIds = new List<String>();
        listOfFileIds.add('1234');
        JSONGenerator gen = JSON.createGenerator(true); 
        gen.writeObject(listOfFileIds);        
        String jsonS = gen.getAsString();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(jsonS);
        Http http = new Http();
        HTTPResponse response = http.send(req);*/
        
       
       
       
    }
    
    @isTest
    public static void Test_getTradeLineDetails()
    {
        
       	List<Id> programIds = new List<Id>();
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_ID__c,Name, nu_dse__Total_Debt_Included__c,nu_dse__Account__c, nu_dse__Account__r.FirstName, 
                                                nu_dse__Account__r.LastName, nu_dse__Account__r.nu_dse__Campaign__r.Type,
                                                nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.nu_dse__SSN__c,
                                                Rollup_Draft_Amount__c,nu_dse__Account__r.nu_dse__Co_State__c, 
                                                nu_dse__Account__r.nu_dse__CO_SSN_ENC__c, nu_dse__Account__r.nu_dse__Co_First_Name__c, 	
                                                nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Account__r.nu_dse__Co_Phone__c, 
                                                nu_dse__Account__r.nu_dse__CO_Email_Address__c,
                                                nu_dse__Account__r.MiddleName, nu_dse__Account__r.PersonBirthdate, 
                                                nu_dse__Account__r.Phone,
                                                nu_dse__Account__r.nu_dse__Cell_phone__c,
                                                nu_dse__Account__r.nu_dse__Best_Phone__c,
                                                nu_dse__Account__r.nu_dse__Home_Phone__c,
                                                nu_dse__Account__r.nu_dse__Work_Phone__c,
                                                nu_dse__Account__r.PersonMobilePhone,
                                                Enrollment_Date__c,
                                                nu_dse__Account__r.PersonOtherPhone,nu_dse__Payment_Frequency__c, nu_dse__Program_Length__c,  
                                                Program_Type__c, nu_dse__Processor__r.Name, Sales_Rep__c, ClientEmail__c, Portfolio__c,Portfolio__r.Support_Email__c, 
                                                Portfolio__r.Retention_Email__c, Portfolio__r.Communication_Template_Email__c, Portfolio__r.Name, Attorney__c
                                                ,
                                                //Fields for Draft Fees - DLM 37
                                                Paid_Accumulation__c, Paid_Admin_Fee__c, Paid_Creditor_Payments__c, Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, 
                                                Remaining_Accumulation__c, Remaining_Admin_Fee__c, Remaining_Creditor_Payments__c, 
                                                Remaining_Maintenance_Fee__c, Remaining_Processor_Fee__c, Remaining_Program_Fee__c, Remaining_Retainer_Fee__c, 
                                                Remaining_Service_Fee__c, Remaining_Third_Party_Fee__c, Total_Accumulation__c, Total_Admin_Fee__c, Total_Creditor_Payments__c, 
                                                Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                Total_Third_Party_Fee__c
                                                from nu_dse__Program__c where Import_id__c = '1234'];      
        test.startTest();
        NuDebtProgramWrapper nuDebtProgramWrapper = new NuDebtProgramWrapper();
        if(programDetailsList != null){
            programIds.add(programDetailsList[0].Id);
       	nuDebtProgramWrapper.tradelines = PullDataForPrizmLead.getTradeLineDetails(programIds);
        System.assertNotEquals(null, nuDebtProgramWrapper.tradelines);
        }  
        
        test.stopTest();
    }
    @isTest
    public static void Test_getPaymentDetails()
    {
        
       	List<Id> programIds = new List<Id>();
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_ID__c,Name, nu_dse__Total_Debt_Included__c,nu_dse__Account__c, nu_dse__Account__r.FirstName, 
                                                nu_dse__Account__r.LastName, nu_dse__Account__r.nu_dse__Campaign__r.Type,
                                                nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.nu_dse__SSN__c,
                                                Rollup_Draft_Amount__c,nu_dse__Account__r.nu_dse__Co_State__c, 
                                                nu_dse__Account__r.nu_dse__CO_SSN_ENC__c, nu_dse__Account__r.nu_dse__Co_First_Name__c, 	
                                                nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Account__r.nu_dse__Co_Phone__c, 
                                                nu_dse__Account__r.nu_dse__CO_Email_Address__c,
                                                nu_dse__Account__r.MiddleName, nu_dse__Account__r.PersonBirthdate, 
                                                nu_dse__Account__r.Phone,
                                                nu_dse__Account__r.nu_dse__Cell_phone__c,
                                                nu_dse__Account__r.nu_dse__Best_Phone__c,
                                                nu_dse__Account__r.nu_dse__Home_Phone__c,
                                                nu_dse__Account__r.nu_dse__Work_Phone__c,
                                                nu_dse__Account__r.PersonMobilePhone,
                                                Enrollment_Date__c,
                                                nu_dse__Account__r.PersonOtherPhone,nu_dse__Payment_Frequency__c, nu_dse__Program_Length__c,  
                                                Program_Type__c, nu_dse__Processor__r.Name, Sales_Rep__c, ClientEmail__c, Portfolio__c,Portfolio__r.Support_Email__c, 
                                                Portfolio__r.Retention_Email__c, Portfolio__r.Communication_Template_Email__c, Portfolio__r.Name, Attorney__c
                                                ,
                                                //Fields for Draft Fees - DLM 37
                                                Paid_Accumulation__c, Paid_Admin_Fee__c, Paid_Creditor_Payments__c, Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, 
                                                Remaining_Accumulation__c, Remaining_Admin_Fee__c, Remaining_Creditor_Payments__c, 
                                                Remaining_Maintenance_Fee__c, Remaining_Processor_Fee__c, Remaining_Program_Fee__c, Remaining_Retainer_Fee__c, 
                                                Remaining_Service_Fee__c, Remaining_Third_Party_Fee__c, Total_Accumulation__c, Total_Admin_Fee__c, Total_Creditor_Payments__c, 
                                                Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                Total_Third_Party_Fee__c
                                                from nu_dse__Program__c where Import_id__c  = '1234'];      
        test.startTest();
        NuDebtProgramWrapper nuDebtProgramWrapper = new NuDebtProgramWrapper();
        if(programDetailsList != null){
            programIds.add(programDetailsList[0].Id);
       	nuDebtProgramWrapper.payments = PullDataForPrizmLead.getPaymentDetails(programIds);
        System.assertNotEquals(null, nuDebtProgramWrapper.payments);
        }  
        
        test.stopTest();
    }
        @isTest
    public static void Test_getDraftFeesDetails()
    {
        
       	List<Id> programIds = new List<Id>();
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_ID__c,Name, nu_dse__Total_Debt_Included__c,nu_dse__Account__c, nu_dse__Account__r.FirstName, 
                                                nu_dse__Account__r.LastName, nu_dse__Account__r.nu_dse__Campaign__r.Type,
                                                nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.nu_dse__SSN__c,
                                                Rollup_Draft_Amount__c,nu_dse__Account__r.nu_dse__Co_State__c, 
                                                nu_dse__Account__r.nu_dse__CO_SSN_ENC__c, nu_dse__Account__r.nu_dse__Co_First_Name__c, 	
                                                nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Account__r.nu_dse__Co_Phone__c, 
                                                nu_dse__Account__r.nu_dse__CO_Email_Address__c,
                                                nu_dse__Account__r.MiddleName, nu_dse__Account__r.PersonBirthdate, 
                                                nu_dse__Account__r.Phone,
                                                nu_dse__Account__r.nu_dse__Cell_phone__c,
                                                nu_dse__Account__r.nu_dse__Best_Phone__c,
                                                nu_dse__Account__r.nu_dse__Home_Phone__c,
                                                nu_dse__Account__r.nu_dse__Work_Phone__c,
                                                nu_dse__Account__r.PersonMobilePhone,
                                                Enrollment_Date__c,
                                                nu_dse__Account__r.PersonOtherPhone,nu_dse__Payment_Frequency__c, nu_dse__Program_Length__c,  
                                                Program_Type__c, nu_dse__Processor__r.Name, Sales_Rep__c, ClientEmail__c, Portfolio__c,Portfolio__r.Support_Email__c, 
                                                Portfolio__r.Retention_Email__c, Portfolio__r.Communication_Template_Email__c, Portfolio__r.Name, Attorney__c
                                                ,
                                                //Fields for Draft Fees - DLM 37
                                                Paid_Accumulation__c, Paid_Admin_Fee__c, Paid_Creditor_Payments__c, Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, 
                                                Remaining_Accumulation__c, Remaining_Admin_Fee__c, Remaining_Creditor_Payments__c, 
                                                Remaining_Maintenance_Fee__c, Remaining_Processor_Fee__c, Remaining_Program_Fee__c, Remaining_Retainer_Fee__c, 
                                                Remaining_Service_Fee__c, Remaining_Third_Party_Fee__c, Total_Accumulation__c, Total_Admin_Fee__c, Total_Creditor_Payments__c, 
                                                Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                Total_Third_Party_Fee__c
                                                from nu_dse__Program__c where Import_id__c = '1234'];      
        test.startTest();
        NuDebtProgramWrapper nuDebtProgramWrapper = new NuDebtProgramWrapper();
        if(programDetailsList != null){
            programIds.add(programDetailsList[0].Id);
       	nuDebtProgramWrapper.draftFeesList = PullDataForPrizmLead.getDraftFeesDetails(programDetailsList);
        System.assertNotEquals(null, nuDebtProgramWrapper.draftFeesList);
        }  
        test.stopTest();
    }
}