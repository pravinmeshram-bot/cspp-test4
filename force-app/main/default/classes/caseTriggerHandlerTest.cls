@isTest
public class caseTriggerHandlerTest{

@testSetup static void setupTestData(){

        Id clientRecordTypeId;
        Map<String, Schema.RecordTypeInfo> accountRecordTypeMap = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        if (accountRecordTypeMap.containsKey('Client')) {
                
           clientRecordTypeId = accountRecordTypeMap.get('Client').getRecordTypeId();
        }

        Account accStr = TestRecordCreator.createAccount('Client', clientRecordTypeId);
        accStr.Phone = '0987654321';
        insert accStr;
        
        
nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c = false;
        testProgram.nu_dse__Account__c = accStr.id;
        insert testProgram;
        
}

static testMethod void populateProgramOnAccountPopulationTest(){

      Account acc = [select id from Account Limit 1];

        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Email';
        cs.accountId = acc.id;
        insert cs;
        
        cs.Status = 'In Progress';
        update cs;
}

static testMethod void populateProgramOnAccountPopulationTest1(){

      Account acc = [select id from Account Limit 1];

        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Email';
        insert cs;
        
        cs.Status = 'In Progress';
        cs.accountId = acc.id;
        update cs;
}


}