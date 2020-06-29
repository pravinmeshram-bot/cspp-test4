@isTest
public class versaraPaymentEditaccess_Test {
    @testsetup static void setupTestData() {
        nu_dse__Program__c  programInst = TestRecordCreator.createProgram();
        Insert programInst; 
    }
    @isTest static void testMethod1() {
        List<nu_dse__Program__c> programInst = new List<nu_dse__Program__c>([SELECT Id FROM nu_dse__Program__c]);
        nu_dse__Payment__c newPayment = TestRecordCreator.createPayments(programInst[0].Id);
        Test.startTest();   
        Insert newPayment; 
        Test.stopTest();   
    }
}