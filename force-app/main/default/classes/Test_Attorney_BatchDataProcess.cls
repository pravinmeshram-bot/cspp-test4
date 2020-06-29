@isTest
public class Test_Attorney_BatchDataProcess {

    @isTest
    public static void testMethod1(){
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_GetLogEntriesBatch';
        bd.Emails_To_Notify__c = 'test@test.com';
        insert bd;
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
                Attorney_BatchDataProcess obj = new Attorney_BatchDataProcess();
                String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
                
    }
    
}