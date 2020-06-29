@isTest
public class Test_Attorney_GetTaskTypesBatch {

    @isTest static void batchTest () {
        Test.startTest ();
            nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
            taskType.TaskName__c = 'test';
            taskType.TaskTypeId__c = '123';
            insert taskType;
            List <nu_dse_Task_Type__c> taskList = new List <nu_dse_Task_Type__c> ();
            taskList.add (taskType);
            Database.QueryLocator ql;
            Database.BatchableContext bc;
            Attorney_GetTaskTypesBatch clientsObj = new Attorney_GetTaskTypesBatch ();
            clientsObj.start (bc);
            clientsObj.finish (bc);
            clientsObj.execute (bc, taskList);
            
        Test.stopTest ();
    }
}