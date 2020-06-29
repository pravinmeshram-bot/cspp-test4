@isTest
public class Test_ProgramPaymentsExportController {
	
    @isTest
    public static void TestMethod1(){
        
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
        insert p;
        
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
        objTradeline.SFS_Current_Balance__c= 12345;
        objTradeLine.nds_Original_Creditor_Name__c = 'Test';
        objTradeline.nu_dse__Current_Stage__c = 'Payment Plan Active';
        objTradeline.nu_dse__Original_Account_Number__c = '12234';
        Attorney_StaticVariableUtility.isTradelineTriggerExecuted = true;
        Database.Insert(objTradeLine);
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Payment Plan Active';
        objOffer.NDS_Offer_Id__c  = '233';
            objOffer.nu_dse__Program__c = p.id;
        Database.insert(objOffer);

        
     // Create Payment Data
        //;
        
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = p.Id;
            //objPayment.nu_dse__Transaction_Status__c = 'Failed';
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
   //     objPayment.nu_dse__Transaction_Status__c = 'Completed';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        Database.Insert(objPayment);
        
        objPayment = new nu_dse__Payment__c();
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = p.Id;
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        //objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
        objPayment.RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        Database.Insert(objPayment);
        
        objPayment = new nu_dse__Payment__c();
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = p.Id;
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today()+1);
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        //objPayment.nu_dse__Payment_Type__c = 'Deposit';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
        objPayment.RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        Database.Insert(objPayment);
        
        Test.startTest();
        PageReference myVfPage = Page.ProgramPaymentsExport;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',p.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        ProgramPaymentsExportController obj = new ProgramPaymentsExportController(sc);
        
        for(ProgramPaymentsExportController.PaymentWrapper PayWrap:obj.PaymentWrapperList){
            
            //System.debug(PayWrap.RunningBalance);
            PayWrap.getRunningBalance();
            PayWrap.getKeyValues();
            PayWrap.getAvailableFunds();
            //PayWrap.getadditionalDraft();
        }
        
         obj.additionalDraft();
      ProgramPaymentsExportController.copyAttorney();
        obj.cancel();
        Test.stopTest();
        
    }
    
}