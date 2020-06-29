@isTest
public class Test_Attorney_GetLogEntriesBatchSch {
    
    @isTest
    public static void TestMethod1(){
        
        NextBatchJobTimings_log__c batchJobTimings = new NextBatchJobTimings_log__c ();
        batchJobTimings.Duration_log__c = 1000;
        batchJobTimings.API_Duration_Log__c = 1000;
        //batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        //batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfullRun_Log__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
        insert batchJobTimings;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        
        Test.startTest ();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        Attorney_GetLogEntriesBatchScheduler obj = new Attorney_GetLogEntriesBatchScheduler ();
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
        Test.stoptest ();
        
    }
    
    @isTest
    public static void TestMethod2(){
        
        NextBatchJobTimings_log__c batchJobTimings = new NextBatchJobTimings_log__c ();
        batchJobTimings.Duration_log__c = 1000;
        batchJobTimings.API_Duration_Log__c = 1000;
        //batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        //batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfullRun_Log__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
        insert batchJobTimings;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        System_Log__c sl= new System_Log__c();
        sl.Category__c = 'Note';
        sl.JobRunning__c = true;
        insert sl;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1';
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        insert pgm;
        
        Task tsk = new task();
        tsk.WhatId = pgm.Id;
        //tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.FileNumber__c = '1';
        tsk.ActivityDate = Date.Today ();
        insert tsk;

        
        
        
        Test.startTest ();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        Attorney_GetLogEntriesBatchScheduler obj = new Attorney_GetLogEntriesBatchScheduler ();
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
        Test.stoptest ();
        
    }
    
    
}