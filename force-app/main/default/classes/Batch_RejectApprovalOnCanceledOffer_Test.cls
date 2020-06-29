//S20-178 ****Starts**** ~ One time push to reject approvals for canceled offers. Conflicting on offerTaskTrigger.
@isTest
public class Batch_RejectApprovalOnCanceledOffer_Test{
    
    @isTest
    static void test_Batch_RejectApprovalOnCanceledOffer() {
    
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        programInstance.RecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Program__c', 'Attorney');
        programInstance.import_id__c = '123456456offertest';
        insert programInstance;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.Tradeline_Litigation_Status__c='Lit';
        offerInstance.nu_dse__Status__c = 'Management Review';
        offerInstance.Source_of_Payment__c = 'Client Direct';
        offerInstance.Tradeline_Litigation_Status__c = 'Non Lit'; 
        insert offerInstance;
        
        offerInstance.nu_dse__Status__c = 'Canceled';
        update offerInstance;
        
        Test.startTest();
        
        Database.executeBatch(new Batch_RejectApprovalOnCanceledOffer());
        
        Test.stopTest();
        
        List<ProcessInstance> processInstances = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :offerInstance.Id]; 
        System.assertEquals('Rejected', processInstances[0].Status);        
    }
}
//S20-178 ****Ends****