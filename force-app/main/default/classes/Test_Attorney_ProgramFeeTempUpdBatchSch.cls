@isTest
public class Test_Attorney_ProgramFeeTempUpdBatchSch {
    
    @isTest public static void testMethod1(){
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
        batchJobTimings.Fee_Template_Update__c = 2;
        insert batchJobTimings;
        
        System_Log__c sysLog = new System_Log__c();
        sysLog.Category__c = 'Program';
        sysLog.JobRunning__c = FALSE;
        Insert sysLog;
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        Attorney_ProgramFeeTempUpdBatchSchedular sch = new Attorney_ProgramFeeTempUpdBatchSchedular();
         system.schedule('Test Territory Check New', CRON_EXP, sch);
        
        /*System_Log__c sysLog = new System_Log__c();
        sysLog.Category__c = 'Program';
        sysLog.JobRunning__c = TRUE;
        Insert sysLog;*/
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1';
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        insert pgm;
        
        
        System.schedule('Abc1', CRON_EXP, sch);
        Attorney_GetEmptyFeeBatch bat = new Attorney_GetEmptyFeeBatch();
        Database.executeBatch(bat);
        
    }
    @isTest public static void testMethod2(){
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
        batchJobTimings.Fee_Template_Update__c = 2;
        insert batchJobTimings;
        
        System_Log__c sysLog = new System_Log__c();
        sysLog.Category__c = 'Program';
        sysLog.JobRunning__c = TRUE;
        Insert sysLog;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1';
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        insert pgm;
        
        String CRON_EXP1 = '0 0 0 3 9 ? 2022';
        Attorney_ProgramFeeTempUpdBatchSchedular sch = new Attorney_ProgramFeeTempUpdBatchSchedular();
        System.schedule('Abc1', CRON_EXP1, sch);
    }
}