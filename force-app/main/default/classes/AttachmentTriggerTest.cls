@isTest
public class AttachmentTriggerTest {
    
    @testSetup
    public static void testdata(){
       Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        insert programInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        tradeline.SFS_Current_Balance__c = 1;
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        insert offerInstance; 
           
        task tsk = new task(subject='Test Task', Status='Update', Priority='Update', whatId= offerInstance.Id );
        insert tsk;
    }
    
    public static testmethod void testDeleteAttForTask(){
      	
        List<Task> tsk = [SELECT Id, subject FROM Task WHERE subject = 'Test Task'];
        
        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; 
        attach.parentId=tsk[0].Id;
        insert attach;
        
        test.startTest();
        delete attach;
        test.stopTest();
        
    }
    public static testmethod void testDeleteAttForOffr(){
      	
        List<Task> tsk = [SELECT Id, whatId FROM Task WHERE subject = 'Test Task'];
        
        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; 
        attach.parentId=tsk[0].whatId;
        insert attach;
        
        test.startTest();
        delete attach;
        test.stopTest();
        
    }
}