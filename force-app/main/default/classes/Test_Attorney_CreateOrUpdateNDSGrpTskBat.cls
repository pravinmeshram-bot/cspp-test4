@isTest
public class Test_Attorney_CreateOrUpdateNDSGrpTskBat {
    
    @TestSetup
    Private static void createData(){
    
    NextBatchJobTimings_Push__c batchJobTimings = new NextBatchJobTimings_Push__c ();
        //batchJobTimings.Duration__c = 1000;
        //batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        //batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        //batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getProfileId ();
        
        batchJobTimings.Push_Backup_Duration__c=1440;
        insert batchJobTimings;
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1';
        insert pgm;
        
        nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c ();
        groupTask.Program__c = pgm.Id;
        //groupTask.Task_Id__c = '1';
        groupTask.nu_dse__Subject__c = 'Test';
        groupTask.nu_dse__Description__c = 'Testing';
        groupTask.Subject_Picklist__c = '30 Day In-House Follow Up';
        groupTask.Priority__c = 'High';
        groupTask.nu_dse__ActivityDate__c = Date.Today ();  
        groupTask.Integration_Status__c = 'Failed';
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = True; 
        insert groupTask;
    }
    
    @isTest static void batchTest (){
        Test.startTest ();
            Attorney_CreateOrUpdateNDSGrpTaskBatch NDSGroupTaskBatch = new Attorney_CreateOrUpdateNDSGrpTaskBatch ();
            Database.executeBatch(NDSGroupTaskBatch,10);
        Test.stoptest ();
    }
}