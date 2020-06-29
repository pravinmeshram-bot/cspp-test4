@isTest
public class Attorney_GetEmptyBatch_PushTest {
    @isTest
    static void  Attorney_GetEmptyBatch_PushTest(){
        
        FileNumberData__c file = new FileNumberData__c();
        file.Completed__c = false;
        file.Name = '1234';
        file.Type__c = 'Client';
        file.completed__c = false;
        insert file;
        
        Test.startTest ();
        Attorney_GetEmptyBatch_Push fileNumberObj = new Attorney_GetEmptyBatch_Push();
        Database.executeBatch(fileNumberObj);
        Test.stoptest ();
    }
    
    @isTest
    static void  Attorney_GetEmptyBatchTest(){
        
        FileNumberData__c file = new FileNumberData__c();
        file.Completed__c = false;
        file.Name = '1234';
        file.Type__c = 'Client';
        file.completed__c = false;
        insert file;
        
        Test.startTest ();
        Attorney_GetEmptyBatch fileNumberObj = new Attorney_GetEmptyBatch();
        Database.executeBatch(fileNumberObj);
        Test.stoptest ();
    }
}