@isTest
public class Test_Attorney_fileNumberBatchSchedular {
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
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
        insert batchJobTimings;
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_GetFileNumberBatch';
        insert bd;
        
        nu_dse__Payment__c payment = new nu_dse__Payment__c ();
    //    payment.Attorney__c = TRUE; using formula field instead of this
        insert payment;
        paymentList.add (payment);

        
        
        nu_dse__TradeLine__c tradeLine = new nu_dse__TradeLine__c ();
        tradeLine.Additional_Name__c = 'test';
        tradeLinesList.add (tradeLine);
    }
    @isTest static void schedulerTest () {
        try {
            init ();
            Test.startTest ();
                Test.setMock (WebServiceMock.class, new Test_Attorney_fileNumberBatchSchedular.webserviceClientsMock ());
                Database.BatchableContext bc;
                String CRON_EXP = '0 0 0 3 9 ? 2022';
                Attorney_fileNumberBatchSchedular obj = new Attorney_fileNumberBatchSchedular ();
                String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
                
                
                //Attorney_GetDebtsBatch debtsObj = new Attorney_GetDebtsBatch (DateTime.Now ().addMinutes (-100), DateTime.Now ().addMinutes (10));
                //debtsObj.execute (null, tradeLinesList);
                //debtsObj.finish (bc);
            Test.stoptest ();
        }catch (Exception e) {}
    }
    
    @isTest static void schedulerTest1 () {
        try {
            init ();
            Test.startTest ();
            	
            System_Log__c log2 = new System_Log__c ();
        	log2.Category__c = 'Payment';
        	log2.Exception_Description__c = 'Test';
        	insert log2;
            
                Test.setMock (WebServiceMock.class, new Test_Attorney_fileNumberBatchSchedular.webserviceClientsMock ());
                Database.BatchableContext bc;
                String CRON_EXP = '0 0 0 3 9 ? 2022';
                Attorney_fileNumberBatchSchedular obj = new Attorney_fileNumberBatchSchedular ();
                String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
                
                
                //Attorney_GetDebtsBatch debtsObj = new Attorney_GetDebtsBatch (DateTime.Now ().addMinutes (-100), DateTime.Now ().addMinutes (10));
                //debtsObj.execute (null, tradeLinesList);
                //debtsObj.finish (bc);
            Test.stoptest ();
        }catch (Exception e) {}
    }
    
    public class webserviceClientsMock implements WebServiceMock {
        public void doInvoke (
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
           leadtracNetClient.GetUpdatedClientsResponse_element respElement = new leadtracNetClient.GetUpdatedClientsResponse_element ();
           respElement.GetUpdatedClientsResult = new leadtracNetClient.ArrayOfString ();
           response.put('response_x', respElement);
           
        }
    }
}