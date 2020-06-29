@isTest
public class Test_Attorney_GetDebtsBatch {
    static List <nu_dse__Payment__c> paymentList = new List <nu_dse__Payment__c> ();
    static List <nu_dse__TradeLine__c> tradeLinesList = new List <nu_dse__TradeLine__c> ();
    static List <FileNumberData__c> dataList = new List <FileNumberData__c> ();
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
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
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
        
        FileNumberData__c data = new FileNumberData__c ();
        data.Type__c = 'Client';
        data.completed__c = FALSE;
        insert data;
        dataList.add (data);
    }
    @isTest static void schedulerTest () {
        try {
            init ();
            Test.startTest ();
                Database.BatchableContext bc;
                
                Attorney_GetDebtsBatch debtsObj = new Attorney_GetDebtsBatch (DateTime.Now ().addMinutes (-100), DateTime.Now ().addMinutes (10));
                debtsObj.start (bc);
                debtsObj.execute (null, dataList);
                debtsObj.finish (bc);
            Test.stoptest ();
        }catch (Exception e) {}
    }
    
   
}