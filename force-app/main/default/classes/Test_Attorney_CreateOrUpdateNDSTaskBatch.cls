@isTest
public class Test_Attorney_CreateOrUpdateNDSTaskBatch {
    
    @TestSetup
    Private static void createData(){
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getProfileId ();
        
     //   batchJobTimings.Push_Backup_Duration__c=1440;
        insert batchJobTimings;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1';
        insert pgm;
        
        Task tsk = new Task ();
        tsk.WhatId = pgm.Id;
        //tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.ActivityDate = Date.Today ();
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
        insert tsk;
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = False;
    }
    
    @isTest static void batchTest (){
        Test.startTest ();
            Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
            Attorney_CreateOrUpdateNDSTaskBatch NDSTaskBatch = new Attorney_CreateOrUpdateNDSTaskBatch ();
            Database.executeBatch(NDSTaskBatch);
        Test.stoptest ();
    }
    
}