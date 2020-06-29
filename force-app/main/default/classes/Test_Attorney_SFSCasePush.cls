@isTest
public class Test_Attorney_SFSCasePush {

    @isTest
    public static void testMethod1(){
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchjobTimings.SFS_Case_Push_Duration__c = 5;
        insert batchJobTimings;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        Summon__c sc = new Summon__c();
        sc.Integration_Status__c = 'Overflow';
        insert sc;
        
        Database.executeBatch(new Attorney_SFSCasePushtoNDS(),1);
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        Attorney_SFSCasePushtoNDSSchedular obj = new Attorney_SFSCasePushtoNDSSchedular ();
                String jobId = System.schedule('Attorney_SFSCasePushtoNDSSchedular', CRON_EXP, obj);
        
        
                
        
    }
    
}