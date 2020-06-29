@isTest
public class BatchSyncGroupTaskbasedOnTask_Test {
    
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
        
        List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>();
        
        nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[0].Id, nu_dse__Subject__c = 'MO 1 Letter Due', nu_dse__Status__c = 'Not Started');
        groupTaskList.add(groupTask);
        
        nu_dse__Group_Task__c groupTask1 = new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[0].Id, nu_dse__Subject__c = 'MO 2 Letter Due', nu_dse__Status__c = 'Not Started');
        groupTaskList.add(groupTask1);
        
        nu_dse__Group_Task__c groupTask2 = new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[1].Id, nu_dse__Subject__c = 'MO 1 Letter Due', nu_dse__Status__c = 'Not Started');
        groupTaskList.add(groupTask2);
        
        nu_dse__Group_Task__c groupTask3 = new nu_dse__Group_Task__c(nu_dse__Related_To__c = programList[1].Id, nu_dse__Subject__c = 'MO 2 Letter Due', nu_dse__Status__c = 'Not Started');
        groupTaskList.add(groupTask3);                                            
        
        insert groupTaskList;
        
        List<Task> taskList = new List<Task>();
        Task taskInstance = TestRecordCreator.createTask(programList[0].Id);
        taskInstance.Subject = 'MO 1 Letter Due';
        taskInstance.nu_dse__Group_Task__c = groupTask.Id;
        taskInstance.Status = 'Completed';
        taskList.add(taskInstance);
        
        Task taskInstance2 = TestRecordCreator.createTask(programList[0].Id);
        taskInstance2.Subject = 'MO 2 Letter Due';
        taskInstance2.nu_dse__Group_Task__c = groupTask1.Id;
        taskInstance2.Status = 'Completed';
        taskList.add(taskInstance2);
        
        Task taskInstance1 = TestRecordCreator.createTask(programList[1].Id);
        taskInstance1.Subject = 'MO 1 Letter Due';
        taskInstance1.nu_dse__Group_Task__c = groupTask2.Id;
        taskInstance1.Status = 'Completed';
        taskList.add(taskInstance1);
        
        Task taskInstance3 = TestRecordCreator.createTask(programList[1].Id);
        taskInstance3.Subject = 'MO 2 Letter Due';
        taskInstance3.nu_dse__Group_Task__c = groupTask2.Id;
        taskInstance3.Status = 'Completed';
        taskList.add(taskInstance3);
        
        insert taskList;
        
    }
    static testMethod void testSyncGroupTaskbasedOnTask() {
        
        Test.startTest();           
        
            Database.executeBatch(new BatchSyncGroupTaskbasedOnTask() , 50);      
        Test.stopTest(); 
    }
}