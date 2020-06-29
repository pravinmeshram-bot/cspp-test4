@isTest
public class NoteTriggerTest {
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
    
    public static testmethod void testDeleteNoteForOffr(){
      	
        List<Task> tsk = [SELECT Id, WhatId FROM Task WHERE subject = 'Test Task'];
        
        Note notes=new Note(); 
        notes.title='Unit Test notes'; 
        //Blob bodyBlob=Blob.valueOf('Unit Test Note Body'); 
        notes.body='Unit Test Note Body'; 
        notes.parentId=tsk[0].whatId;
        insert notes;
        
        test.startTest();
        delete notes;
        test.stopTest();
        
    }
    
}