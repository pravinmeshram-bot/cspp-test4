@isTest
public class BatchDeleteAttorneyTaskAndRetrigger_Test {
    
    @testSetup
    static void setup() {
    
        Id clientRecTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        nu_dse__Processor__c newProcessor = TestRecordCreator.createProcessor();
        Insert newProcessor;
        
        List<Account> accountList = new List<Account>();
        
        Account accountInstance1 = TestRecordCreator.createAccount(clientRecTypeId);   
        accountInstance1.nu_dse__External_CFT_ID__c = '123456';
        accountList.add(accountInstance1);
        
        Account accountInstance2 = TestRecordCreator.createAccount(clientRecTypeId);   
        accountInstance2.nu_dse__External_CFT_ID__c = '123457';
        accountList.add(accountInstance2);
        
        insert accountList;
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
        
        nu_dse__Program__c activeProgram = TestRecordCreator.createProgram(accountList[0].Id, newProcessor.Id, 'Active');
        activeProgram.Attorney__c = True;
        activeProgram.NDS_CREATED_DATE__c = System.Today().AddDays(-200);
        activeProgram.RUN_PROCESSES_ON_IMPORT__c = False;
        activeProgram.Run_First_Year_Workflow__c = False;
        programList.add(activeProgram);
        
        nu_dse__Program__c pendingProgram = TestRecordCreator.createProgram(accountList[1].Id, newProcessor.Id, 'Pending Creation');
        pendingProgram.Attorney__c = True;
        pendingProgram.NDS_CREATED_DATE__c = System.Today().AddDays(-200);
        pendingProgram.RUN_PROCESSES_ON_IMPORT__c = False;
        pendingProgram.Run_First_Year_Workflow__c = False;
        programList.add(pendingProgram );
        
        insert programList;
        
        List<Task> taskList = new List<Task>();
        Task taskInstance = TestRecordCreator.createTask(programList[0].Id);
        taskInstance.Subject = 'MO 1 Letter Due';
        taskList.add(taskInstance);
        
        Task taskInstance2 = TestRecordCreator.createTask(programList[0].Id);
        taskInstance2.Subject = 'MO 2 Letter Due';
        taskList.add(taskInstance2);
        
        Task taskInstance1 = TestRecordCreator.createTask(programList[1].Id);
        taskInstance1.Subject = 'MO 1 Letter Due';
        taskList.add(taskInstance1);
        
        Task taskInstance3 = TestRecordCreator.createTask(programList[1].Id);
        taskInstance3.Subject = 'MO 2 Letter Due';
        taskList.add(taskInstance3);
        
        insert taskList;
        
        List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>{new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[0].Id, nu_dse__Subject__c = 'MO 1 Letter Due'),
                                                                                    new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[0].Id, nu_dse__Subject__c = 'MO 2 Letter Due'),
                                                                                    new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[1].Id, nu_dse__Subject__c = 'MO 1 Letter Due'),
                                                                                    new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[1].Id, nu_dse__Subject__c = 'MO 2 Letter Due')};
        
        insert groupTaskList;
        
    }
    
    static testMethod void testDeleteAttorneyTask() {
        
        List<nu_dse__Program__c> programUpdateList = [SELECT Id FROM nu_dse__Program__c];
        
        programUpdateList[0].RUN_PROCESSES_ON_IMPORT__c = True;
        programUpdateList[1].RUN_PROCESSES_ON_IMPORT__c = True;
        
        update programUpdateList;
        
        programUpdateList[0].RUN_PROCESSES_ON_IMPORT__c = False;
        programUpdateList[0].Run_First_Year_Workflow__c = True;
        programUpdateList[0].ACRs_Scheduled__c = False;
        programUpdateList[0].YR2_ACRs_Scheduled__c = False;
        programUpdateList[0].YR3_ACRs_Scheduled__c = False;
        programUpdateList[0].YR4_ACRs_Scheduled__c = False;
        programUpdateList[0].YR5_ACRs_Scheduled__c = False;
        programUpdateList[0].First_Year_Workflow_Ran__c = False;
        
        programUpdateList[1].RUN_PROCESSES_ON_IMPORT__c = False;
        programUpdateList[1].Run_First_Year_Workflow__c = True;
        programUpdateList[1].ACRs_Scheduled__c = False;
        programUpdateList[1].YR2_ACRs_Scheduled__c = False;
        programUpdateList[1].YR3_ACRs_Scheduled__c = False;
        programUpdateList[1].YR4_ACRs_Scheduled__c = False;
        programUpdateList[1].YR5_ACRs_Scheduled__c = False;
        programUpdateList[1].First_Year_Workflow_Ran__c = False;
        
        update programUpdateList;
        
        Test.startTest();
        
        BatchDeleteAttorneyTasksAndRetrigger aggregatePaymentBatch = new BatchDeleteAttorneyTasksAndRetrigger(False);
        Database.executeBatch(aggregatePaymentBatch , 50);      
        Test.stopTest(); 
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        
        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id FROM nu_dse__Group_Task__c WHERE Program__c =: programList[0].Id];
        //System.assertEquals(True, groupTaskList.isEmpty());
        
        List<Task> taskList = [SELECT Id FROM Task WHERE WhatId =: programList[0].Id];
       // System.assertEquals(True, taskList.isEmpty());    
        
    }
    
    static testMethod void testDeleteAttorneyTaskAndRetrigger() {
        
        List<nu_dse__Program__c> programUpdateList = [SELECT Id FROM nu_dse__Program__c];
        programUpdateList[0].RUN_PROCESSES_ON_IMPORT__c = True;
        programUpdateList[1].RUN_PROCESSES_ON_IMPORT__c = True;
        update programUpdateList;
        
        Test.startTest();           
        
        BatchDeleteAttorneyTasksAndRetrigger aggregatePaymentBatch = new BatchDeleteAttorneyTasksAndRetrigger(True);
        Database.executeBatch(aggregatePaymentBatch , 50);      
        Test.stopTest(); 
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c ];
        
        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id FROM nu_dse__Group_Task__c WHERE Program__c =: programList[0].Id AND nu_dse__ActivityDate__c < Today];
        //System.assertEquals(False, groupTaskList.isEmpty());
        
        List<Task> taskList = [SELECT Id FROM Task WHERE WhatId =: programList[0].Id AND ActivityDate < Today];
        //System.assertEquals(False, taskList.isEmpty());    
        
    }
    /*
    static testMethod void testDeleteAttorneyTaskAndRetrigger_Exception() {
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c ];
        
        List<nu_dse__Group_Task__c> groupTaskList1 = [SELECT Id, nu_dse__Unique_Identifier__c FROM nu_dse__Group_Task__c];
        System.debug('groupTaskList123-->'+groupTaskList1);
        
        nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c();
        groupTask.nu_dse__Subject__c = 'Welcome Package Needed';
        groupTask.nu_dse__Unique_Identifier__c= programList[0].Id +'WP Needed';
        insert groupTask;
        
        Task taskInstance = TestRecordCreator.createTask(programList[0].Id);
        taskInstance.Subject = 'Test';
        taskInstance.Unique_Identifier__c = programList[0].Id +'OB Call 2';
        insert taskInstance;
        
        Test.startTest();           
        
        BatchDeleteAttorneyTasksAndRetrigger aggregatePaymentBatch = new BatchDeleteAttorneyTasksAndRetrigger(True);
        Database.executeBatch(aggregatePaymentBatch,5);      
        Test.stopTest(); 
        
        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id FROM nu_dse__Group_Task__c];
        //System.assertEquals(False, groupTaskList.isEmpty());
        
        List<Task> taskList = [SELECT Id FROM Task];
       // System.assertEquals(False, taskList.isEmpty()); 
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Class_Method__c, nu_dse__Message__c FROM nu_dse__Error_Log__c];
        //System.assertEquals(1, errorLogList.size());
        //System.assertEquals('BatchDeleteAttorneyTasksAndRetrigger_Execute' ,errorLogList[0].nu_dse__Class_Method__c);
    }*/
}