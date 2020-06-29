@isTest
public class Test_PullProgramDetailsForPrizmOpp {
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
        t.nu_dse__Program__c = p.id;
        t.Attorney__c = true;
        t.FileNumber__c = '1234';
        t.nu_dse__Original_Debt__c = 1233;
        t.nu_dse__Current_Stage__c = 'New';
        //t.Lead__c = l.Id;
        t.nu_dse__Original_Account_Number__c = '123';
        t.SFS_Current_Balance__c = 123;
        t.Applicant_Type__c = 'Applicant';
        t.Normalized_Current_Creditor__c = 'test';
        t.Normalized_Original_Creditor__c = 'test';
        Attorney_CreateOrUpdateNDSTradeHandler.CreditorUpdated = true;
        insert t;
        
        
    }
    @isTest
    public static void Test_populateOpportunityMappingsFromProgram()
    {
        
        opportunityJsonClass oppJson = new opportunityJsonClass();
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_id__c, Name, Program_Type__c, nu_dse__Account__r.Name, nu_dse__Account__r.nu_dse__Co_First_Name__c, 
                                                       nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Trust_Account_Balance__c, nu_dse__Program_Status__c, nu_dse__Account__r.nu_dse__External_RAMS_ID__c, nu_dse__Account__r.nu_dse__External_CFT_ID__c, nu_dse__Account__r.nu_dse__External_GCS_ID__c, Portfolio__r.Name, Attorney__c, nu_dse__Account__r.BoxFolderId__c, nu_dse__Account__r.PersonBirthDate,  nu_dse__Account__r.PersonMailingCountry, nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.PersonEmail,nu_dse__Account__r.PersonMailingStreet,nu_dse__Account__r.ClientNumber__c,nu_dse__Account__r.MiddleName,nu_dse__Account__r.nu_dse__SSN__c,nu_dse__Account__r.PersonMailingCity,nu_dse__Account__r.PersonMailingPostalCode,nu_dse__Account__r.PersonHomePhone,nu_dse__Account__r.PersonMobilePhone,nu_dse__Account__r.nu_dse__Work_Phone__c,nu_dse__Account__r.FirstName,nu_dse__Account__r.LastName,nu_dse__Account__r.nu_dse__CO_Email_Address__c,nu_dse__Account__r.nu_dse__Co_Phone__c,nu_dse__Account__r.nu_dse__Co_SSN__c,nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c, 
                                                       Monthly_Legal_Fee__c,nu_dse__Monthly_Processor_Fee__c,nu_dse__Monthly_Third_Party_Fees__c,Subscribed_to_ALLG__c,nu_dse__Payment_Frequency__c,nu_dse__Reoccurring_Debit_Day__c,nu_dse__Twice_Monthly_Reoccuring_Day__c, 
                                                       Current_Accumulation__c,Versara_First_Funding_Date__c,Beginning_DA_Balance__c,Addn_l_Drafts_During_Funding__c,Current_Admin_Fee__c,Paid_Creditor_Payments__c,Total_Fees__c,Expected_Accumulation__c,Expected_Admin_Fee__c,Total_Creditor_Payments__c,Remaining_Accumulation__c,Remaining_Admin_Fee__c,Remaining_Creditor_Payments__c,Current_Maintenance_Fee__c,nu_dse__Expected_Maintenance_Fees__c,Remaining_Maintenance_Fee__c,Current_Processor_Fee__c,Remaining_Processor_Fee__c,Expected_Processor_Fee__c,Current_Program_Fee__c,Expected_Program_Fee__c,Remaining_Program_Fee__c,Current_Retainer_Fee__c,Remaining_Retainer_Fee__c,Expected_Retainer_Fee__c,Current_Service_Fee__c,Remaining_Service_Fee__c,Expected_Service_Fee__c,Current_Third_Party_Fee__c,Remaining_Third_Party_Fee__c,Expected_Third_Party_Fee__c
                                                       , nu_dse__Processor__r.Name,nu_dse__Processor__r.nu_dse__Type__c,
                                                       //Fields for Draft Fees - DLM 37
                                                       Draft_Amount__c, Paid_Accumulation__c, Paid_Admin_Fee__c,  Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                       Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, Total_Admin_Fee__c,  
                                                       Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                       Total_Third_Party_Fee__c
                                                       
                                                       FROM nu_dse__Program__c Where Import_ID__c  = '1234'];      
        test.startTest();
        oppJson = PullProgramDetailsForPrizmOpportunity.populateOpportunityMappingsFromProgram(programDetailsList);
        System.assertNotEquals(null, oppJson);
        
        test.stopTest();
    }
    @isTest
    public static void Test_populateOppBankAccountDetails()
    {
        List<Id> programIds = new List<Id>();
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_id__c, Name, Program_Type__c, nu_dse__Account__r.Name, nu_dse__Account__r.nu_dse__Co_First_Name__c, 
                                                       nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Trust_Account_Balance__c, nu_dse__Program_Status__c, nu_dse__Account__r.nu_dse__External_RAMS_ID__c, nu_dse__Account__r.nu_dse__External_CFT_ID__c, nu_dse__Account__r.nu_dse__External_GCS_ID__c, Portfolio__r.Name, Attorney__c, nu_dse__Account__r.BoxFolderId__c, nu_dse__Account__r.PersonBirthDate,  nu_dse__Account__r.PersonMailingCountry, nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.PersonEmail,nu_dse__Account__r.PersonMailingStreet,nu_dse__Account__r.ClientNumber__c,nu_dse__Account__r.MiddleName,nu_dse__Account__r.nu_dse__SSN__c,nu_dse__Account__r.PersonMailingCity,nu_dse__Account__r.PersonMailingPostalCode,nu_dse__Account__r.PersonHomePhone,nu_dse__Account__r.PersonMobilePhone,nu_dse__Account__r.nu_dse__Work_Phone__c,nu_dse__Account__r.FirstName,nu_dse__Account__r.LastName,nu_dse__Account__r.nu_dse__CO_Email_Address__c,nu_dse__Account__r.nu_dse__Co_Phone__c,nu_dse__Account__r.nu_dse__Co_SSN__c,nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c, 
                                                       Monthly_Legal_Fee__c,nu_dse__Monthly_Processor_Fee__c,nu_dse__Monthly_Third_Party_Fees__c,Subscribed_to_ALLG__c,nu_dse__Payment_Frequency__c,nu_dse__Reoccurring_Debit_Day__c,nu_dse__Twice_Monthly_Reoccuring_Day__c, 
                                                       Current_Accumulation__c,Versara_First_Funding_Date__c,Beginning_DA_Balance__c,Addn_l_Drafts_During_Funding__c,Current_Admin_Fee__c,Paid_Creditor_Payments__c,Total_Fees__c,Expected_Accumulation__c,Expected_Admin_Fee__c,Total_Creditor_Payments__c,Remaining_Accumulation__c,Remaining_Admin_Fee__c,Remaining_Creditor_Payments__c,Current_Maintenance_Fee__c,nu_dse__Expected_Maintenance_Fees__c,Remaining_Maintenance_Fee__c,Current_Processor_Fee__c,Remaining_Processor_Fee__c,Expected_Processor_Fee__c,Current_Program_Fee__c,Expected_Program_Fee__c,Remaining_Program_Fee__c,Current_Retainer_Fee__c,Remaining_Retainer_Fee__c,Expected_Retainer_Fee__c,Current_Service_Fee__c,Remaining_Service_Fee__c,Expected_Service_Fee__c,Current_Third_Party_Fee__c,Remaining_Third_Party_Fee__c,Expected_Third_Party_Fee__c
                                                       , nu_dse__Processor__r.Name,nu_dse__Processor__r.nu_dse__Type__c,
                                                       //Fields for Draft Fees - DLM 37
                                                       Draft_Amount__c, Paid_Accumulation__c, Paid_Admin_Fee__c,  Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                       Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, Total_Admin_Fee__c,  
                                                       Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                       Total_Third_Party_Fee__c
                                                       
                                                       FROM nu_dse__Program__c Where Import_ID__c  = '1234'];      
        
        test.startTest();
        //if(programDetailsList != null){
            programIds.add(programDetailsList[0].Id);
        opportunityJsonClass.cls_BankAccount bnkAcc = PullProgramDetailsForPrizmOpportunity.populateOppBankAccountDetails(programIds);
        System.assertNotEquals(null, bnkAcc);
        List<NuDebtProgramWrapper.TradelinesWrapper> tradelines = PullDataForPrizmLead.getTradeLineDetails(programIds);
        List<opportunityJsonClass.cls_Tradelines> clsTrradelines = PullProgramDetailsForPrizmOpportunity.populateOppTradelinesDetails(tradelines);
        //}        
        test.stopTest();
    }
}