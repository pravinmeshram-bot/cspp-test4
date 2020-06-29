@isTest
public class Test_Attorney_CreateOrUpdateNDSTradeSch {
    
    static List <nu_dse__Payment__c> paymentList = new List <nu_dse__Payment__c> ();
    static List <nu_dse__TradeLine__c> tradeLinesList = new List <nu_dse__TradeLine__c> ();
    static void init () {
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        NextBatchJobTimings_Push__c batchJobTimings = new NextBatchJobTimings_Push__c ();
        //batchJobTimings.Duration__c = 1000;
        //batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        //batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        //batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getProfileId ();
        
        batchJobTimings.Push_Backup_Duration__c=1440;
        insert batchJobTimings;
        
        nu_dse__Payment__c payment = new nu_dse__Payment__c ();
        //    payment.Attorney__c = TRUE; using formula field instead of this
        insert payment;
        paymentList.add (payment);
        
        System_Log__c log = new System_Log__c ();
        log.Category__c = 'Client';
        log.Exception_Description__c = 'test';
        insert log;
        
        System_Log__c log1 = new System_Log__c ();
        log1.Category__c = 'Tradeline';
        log1.Exception_Description__c = 'test';
        insert log1;
        
        System_Log__c log2 = new System_Log__c ();
        log2.Category__c = 'Payment';
        log2.Exception_Description__c = 'test';
        insert log2;
        
        nu_dse__TradeLine__c tradeLine = new nu_dse__TradeLine__c ();
        tradeLine.Additional_Name__c = 'test';
        tradeLinesList.add (tradeLine);
    }
    
    @isTest static void schedulerTest () {
        //try {
            init ();
            Test.startTest ();
            System.debug('****here');
            //Test.setMock (WebServiceMock.class, new Test_Attorney_fileNumberBatchSchedular.webserviceClientsMock ());
            //Database.BatchableContext bc;
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            Attorney_CreateOrUpdateNDSTradeScheduler obj = new Attorney_CreateOrUpdateNDSTradeScheduler ();
            String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
            
           
            //Attorney_GetDebtsBatch debtsObj = new Attorney_GetDebtsBatch (DateTime.Now ().addMinutes (-100), DateTime.Now ().addMinutes (10));
            //debtsObj.execute (null, tradeLinesList);
            //debtsObj.finish (bc);
            Test.stoptest ();
        //}catch (Exception e) {}
    }
    
    @isTest static void schedulerTest2 () {
        //try {
            init ();
            Test.startTest ();
            
            NextBatchJobTimings_Push__c batchJobTimings = NextBatchJobTimings_Push__c.getValues(UserInfo.getProfileId());
            batchJobTimings.Is_Push_Job_Running__c = True;
            Update batchJobTimings;
            System.debug('****'+batchJobTimings);
            
            String CRON_EXP1 = '0 0 0 3 9 ? 2022';
            Attorney_CreateOrUpdateNDSTradeScheduler obj1 = new Attorney_CreateOrUpdateNDSTradeScheduler ();
            String jobId1 = System.schedule('testBasicScheduledApex', CRON_EXP1, obj1);
            
            //Attorney_GetDebtsBatch debtsObj = new Attorney_GetDebtsBatch (DateTime.Now ().addMinutes (-100), DateTime.Now ().addMinutes (10));
            //debtsObj.execute (null, tradeLinesList);
            //debtsObj.finish (bc);
            Test.stoptest ();
        //}catch (Exception e) {}
    }
}