@isTest
public class Test_Attorney_Trade_Pay_No_Program {
    
    public static testMethod void testMethod1(){
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getProfileId ();
        batchJobTimings.Program_Update_Scheular_Duration__c = 10;
        insert batchJobTimings;
        
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
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);
        
        //Create Tradeline Object
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeline.applicant_type__c = 'Joint';        
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
        objTradeline.FileNUmber__c = '2323';
        Database.Insert(objTradeLine);
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Offer Made';
        objOffer.NDS_Offer_Id__c  = '233';
        objOffer.FileNumber__c = '2323';
        objOffer.nu_dse__program__C = objProgram .Id;
        Database.insert(objOffer);

        
     // Create Payment Data
        //;
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        //objPayment.nu_dse__Program__c = objProgram.Id;
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today());
        objPayment.nu_dse__Payment_Sequence_Number__c = 13;
        objPayment.FileNUmber__c = '2323';
        objPayment.nu_dse__Amount__c = 12.24;
     //   objPayment.nu_dse__Transaction_Status__c = 'Completed';
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
        objPayment.RecordTypeId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Database.Insert(objPayment);
        
        Task task1 = new Task();
        task1.FileNumber__c = '2323';
        //task1.WhoId=UserInfo.getUserId();
        Database.insert(task1);
        
        nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c();
        GroupTask.FileNumber__c = '2323';
        GroupTask.Subject_Picklist__c = 'Bankruptcy Referral';
        Database.insert(groupTask);
        
        Test.startTest();
        Attorney_Trade_Pay_No_Program schedular = new Attorney_Trade_Pay_No_Program();
        schedular.execute(null);
        Test.stopTest();
        
    }
    
}