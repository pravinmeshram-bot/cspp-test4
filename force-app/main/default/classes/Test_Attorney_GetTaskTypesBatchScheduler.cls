@isTest
public class Test_Attorney_GetTaskTypesBatchScheduler {
    @isTest static void schedulerTest () {
		
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchJobTimings.Push_Task_Type_Duration__c = 1440;
        insert batchJobTimings;
        
        
        Test.startTest ();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            Attorney_GetTaskTypesBatchScheduler obj = new Attorney_GetTaskTypesBatchScheduler();
            String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
        Test.stopTest ();
    }
}