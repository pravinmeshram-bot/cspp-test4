@isTest
public class PaymentUpdateTriggerHandler_Test{

    @isTest
    public static void updatePaymentAsDontOverrideTest() {
    
        nu_dse__Payment__c payment = new nu_dse__Payment__c();
        payment.nu_dse__Amount__c = 1200;
        payment.nu_dse__Retainer_Fee__c = 100;
        payment.nu_dse__Service_Fee__c = 170;
        
        insert payment;
        
        payment.nu_dse__Retainer_Fee__c = 150;
        payment.nu_dse__Service_Fee__c = 150;
        Test.startTest();
        
        update payment;
        Test.stopTest();
        nu_dse__Payment__c updatedPayment = [SELECT Id,nu_dse__Dont_Override__c FROM nu_dse__Payment__c WHERE Id = :payment.Id LIMIT 1];
        System.assert(updatedPayment.nu_dse__Dont_Override__c == TRUE);
    }
}