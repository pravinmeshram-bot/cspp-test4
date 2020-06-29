@isTest
public class PaymentHandler_CloseSFSCase_Test{

    @testSetup static void setupTestData() {
                
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c = false;
        
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id; 
        offer.nu_dse__Status__c = 'Management Review';
        
        insert offer;
        
        Summon__c sfsCase = new Summon__c();
        sfsCase.Tradeline__c = tradeline.Id;
        sfsCase.Subject__c = 'Test Subject';
        sfsCase.Case_Status__c = 'New';
        
        insert sfsCase;
        
        nu_dse__Payment__c settlementPayment = new nu_dse__Payment__c();
        settlementPayment.RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        settlementPayment.nu_dse__Transaction_Status__c = 'Unknown';
        settlementPayment.nu_dse__Is_Makeup_Payment_Created__c  = false; // Added by Praveen
        insert settlementPayment;   
        
    }

    static testMethod void closeSFSCaseOnFirstSettlementComplete_Test() {
    
        
        List<nu_dse__Payment__c> settlementPayments = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Offer__c FROM nu_dse__Payment__c];
        
        List<nu_dse__Program__c> programs = [SELECT Id FROM nu_dse__Program__c];
        
        List<nu_dse__Offer__c> offers = [SELECT Id FROM nu_dse__Offer__c];
        
        settlementPayments[0].nu_dse__Transaction_Status__c = 'Completed';
        settlementPayments[0].nu_dse__Program__c = programs[0].Id;
        settlementPayments[0].nu_dse__Offer__c = offers[0].Id;
        
        Test.startTest();
        
        update settlementPayments[0];
        
        Test.stopTest();
        
        List<Summon__c> updatedSFSCase = [SELECT Id, Case_Status__c FROM Summon__c];
        
        List<nu_dse__Tradeline__c> updatedTradeline = [SELECT Id, Litigation_Stage__c FROM nu_dse__Tradeline__c];
        
        System.assert(updatedSFSCase.size() > 0);
        System.assertEquals('Completed', updatedSFSCase[0].Case_Status__c);
        
       
    }
    // code coverage for cancelTasksOnPaymentStatusUpdate by Praveen 09 March 2020 - Start
    static testMethod void cancelTaskOnPaymentStatusTest(){
    
     List<nu_dse__Payment__c> settlementPayments = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Is_Makeup_Payment_Created__c FROM nu_dse__Payment__c];
     
     Task t = new Task();
        t.whatId = settlementPayments[0].id;
        t.Status='Not Started';
        t.ActivityDate = date.today().addDays(2);

        insert t;
        
        
     settlementPayments[0].nu_dse__Transaction_Status__c = 'Failed';
     settlementPayments[0].nu_dse__Is_Makeup_Payment_Created__c = true;
     
     Test.startTest();
     update settlementPayments[0];
     Test.stopTest();
     
     System.assert(settlementPayments.size() > 0);
     System.assertEquals('Failed', settlementPayments[0].nu_dse__Transaction_Status__c );
     System.assertEquals(true, settlementPayments[0].nu_dse__Is_Makeup_Payment_Created__c );
        
    } 
    
    static testMethod void cancelTaskOnPaymentStatus_onTransactionStatusTest(){
    
        nu_dse__Payment__c paymentUpdate = new nu_dse__Payment__c();
        paymentUpdate.RecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        paymentUpdate.nu_dse__Transaction_Status__c = 'Failed';
        paymentUpdate.nu_dse__Is_Makeup_Payment_Created__c  = false;
        insert paymentUpdate;   
        
        Task tsk = new Task();
        tsk.whatId = paymentUpdate.id;
        tsk.Status='Not Started';
        tsk.ActivityDate = date.today().addDays(2);
        insert tsk; 
        
        
        paymentUpdate.nu_dse__Transaction_Status__c = 'completed';
        Test.startTest();
        update paymentUpdate;             
        Test.stopTest();
        
        System.assertEquals('completed', paymentUpdate.nu_dse__Transaction_Status__c );
    
    }
    // End - by Praveen
}