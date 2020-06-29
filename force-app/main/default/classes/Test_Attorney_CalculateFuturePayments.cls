@isTest
public class Test_Attorney_CalculateFuturePayments {

    @isTest
    public static void testMethod1(){
        
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Draft_Plan_ID__c= '232343';
        objProgram.Import_id__c = '2323';
        Database.Insert(objProgram);
        
        Id recID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = False;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);
        
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';        
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        objTradeline.nu_dse__Original_Account_Number__c = '12234';
        Database.Insert(objTradeLine);
        
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Settled';
        objOffer.NDS_Offer_Id__c  = '233';
        objOffer.nu_dse__Program__c = objProgram.id;
        Database.insert(objOffer);
        
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        Id  DraftPlanRecId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        objPayment.RecordTypeId = DraftPlanRecId;
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = objProgram.Id;
        //objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today());
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.nu_dse__Amount__c = 12.24;
        objPayment.nu_dse__Transaction_Status__c = 'Pending';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Withdrawal';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
        objPayment.nu_dse__Schedule_Date__c = Date.today();
            //objPayment.Refund_Payment__c = true;
        Database.Insert(objPayment);
        
        Attorney_CalculateFuturePaymentSchedular obj= new Attorney_CalculateFuturePaymentSchedular();
        obj.execute(null);
        
        Database.executeBatch(new Attorney_CalculateFuturePaymentBatch());
        
    }
    
}