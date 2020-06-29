@isTest
public Class BatchExecutionHandler_Test{
    
    @testSetup static void setupMethod() {
        
        Id recordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
        Account clientAccountInstance = TestRecordCreator.createAccount(recordTypeId);    
        insert clientAccountInstance;
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createGCSProcessor();
        insert processorInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(clientAccountInstance.Id, processorInstance.Id, 'Pending Creation');
        insert programInstance;
        
    }
    
    @isTest
    public static void initiateSchedulerTest () {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id From nu_dse__Program__c];
        
        Task taskInstance = TestRecordCreator.createTask(programInstanceList[0].Id);
        insert taskInstance;
        
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('TaskToProgram', 'Task', 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'subject', 'nds_Cancellation_Reason__c');
        nu_dse__Field_mapping__c fieldMappingInstance2 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'ActivityDate', 'nds_Good_Faith_Date__c');
        nu_dse__Field_mapping__c fieldMappingInstance3 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'WhatId','Id');
        
        List<nu_dse__Field_mapping__c> fieldMappingInstanceList = new List<nu_dse__Field_mapping__c>();
        fieldMappingInstanceList.add(fieldMappingInstance1);
        fieldMappingInstanceList.add(fieldMappingInstance2);
        fieldMappingInstanceList.add(fieldMappingInstance3);
        insert fieldMappingInstanceList;
                
        Batch_Execution__c batchExecutionInstance = TestRecordCreator.createBatchExecution(dataMappingInstance.Id, taskInstance.Id);
        
        Test.startTest();
        
        insert batchExecutionInstance;
        Database.executeBatch(new Batch_Execution(batchExecutionInstance.Id), 1);
        
        Test.stopTest();
        
        programInstanceList = [SELECT Id, nds_Good_Faith_Date__c From nu_dse__Program__c];
        System.assertEquals(taskInstance.ActivityDate, programInstanceList[0].nds_Good_Faith_Date__c);
        
    }
    
    @isTest
    public static void initiateSchedulerExceptionTest () {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id From nu_dse__Program__c];
        
        Task taskInstance = TestRecordCreator.createTask(programInstanceList[0].Id);
        insert taskInstance;
        
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('TaskToProgram', 'Task', 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'Description', 'nds_Cancellation_Reason__c');
        nu_dse__Field_mapping__c fieldMappingInstance2 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'ActivityDate', 'nds_Good_Faith_Date__c');
        nu_dse__Field_mapping__c fieldMappingInstance3 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'WhatId','Id');
        
        List<nu_dse__Field_mapping__c> fieldMappingInstanceList = new List<nu_dse__Field_mapping__c>();
        fieldMappingInstanceList.add(fieldMappingInstance1);
        fieldMappingInstanceList.add(fieldMappingInstance2);
        fieldMappingInstanceList.add(fieldMappingInstance3);
        insert fieldMappingInstanceList;
                
        Batch_Execution__c batchExecutionInstance = TestRecordCreator.createBatchExecution(dataMappingInstance.Id, taskInstance.Id);
        
        Test.startTest();
        
        insert batchExecutionInstance;
        Database.executeBatch(new Batch_Execution(batchExecutionInstance.Id), 1);
        
        Test.stopTest();
        
        List< nu_dse__Error_Log__c > errorLogList = [SELECT Id FROM nu_dse__Error_Log__c];
        //System.assertEquals(1, errorLogList.size());
        
    }
    
    @isTest
    public static void initiateSchedulerWithoutIdTest () {
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id From nu_dse__Program__c];
        
        Task taskInstance = TestRecordCreator.createTask(programInstanceList[0].Id);
        insert taskInstance;
        
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('TaskToProgram', 'Task', 'nu_dse__Program__c');
        
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'Subject', 'nds_Cancellation_Reason__c');
        nu_dse__Field_mapping__c fieldMappingInstance2 = TestRecordCreator.createFieldMapping(dataMappingInstance.Id, 'ActivityDate', 'nds_Good_Faith_Date__c');
        
        List<nu_dse__Field_mapping__c> fieldMappingInstanceList = new List<nu_dse__Field_mapping__c>();
        fieldMappingInstanceList.add(fieldMappingInstance1);
        fieldMappingInstanceList.add(fieldMappingInstance2);
        insert fieldMappingInstanceList;
                
        Batch_Execution__c batchExecutionInstance = TestRecordCreator.createBatchExecution(dataMappingInstance.Id, taskInstance.Id);
        
        Test.startTest();
        
        insert batchExecutionInstance;
        Database.executeBatch(new Batch_Execution(batchExecutionInstance.Id), 1);
        
        Test.stopTest();
        
        programInstanceList = [SELECT Id, nds_Good_Faith_Date__c From nu_dse__Program__c];
        System.assertEquals(taskInstance.ActivityDate, programInstanceList[0].nds_Good_Faith_Date__c);
        
    }
}