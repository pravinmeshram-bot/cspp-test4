@isTest

public class Batch_ModifyLeadPayments_Test {
    
    @isTest static void testUpdatePayments() { 
        
        Velocify_Settings__c velocifySettings = TestRecordCreator.createVelocifySettings();
        insert velocifySettings;
        
        Id clientRecordId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
        Account accountInstance = TestRecordCreator.createAccount('Test', clientRecordId);
        insert accountInstance;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor('GCS');
        insert processor;
        
        nu_dse__Program__c  program = TestRecordCreator.createProgram(accountInstance.Id, processor.Id);
        insert program;
        
        Id draftPaymentId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        nu_dse__Payment__c paymentInstance = TestRecordCreator.createPayment(program.Id, 'Completed', 'Deposit', draftPaymentId, null);
        insert paymentInstance;
        
        Test.startTest();
        
            Records_To_Process__c recordToUpdate = new Records_To_Process__c(Integration_Type__c = 'Velocify', Record_Id__c = paymentInstance.Id, Status__c = 'Pending');
            insert recordToUpdate;
            
            Database.executeBatch(new Batch_ModifyLeadPayments(), 1);
            
       Test.stopTest();
        
       List<Records_To_Process__c> recordsToProcessList = [SELECT Id FROM Records_To_Process__c];
       System.assertEquals(0, recordsToProcessList.size());
       
    }
    
}