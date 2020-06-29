@isTest
public class Test_Attorney_GetLogEntriesBatchHandler {
    
    @isTest
    public static void TestMethod1(){
        
        Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_GetLogEntriesBatch';
        insert bd;
        
        NextBatchJobTimings_Log__c batchJobTimings = new NextBatchJobTimings_Log__c ();
        batchJobTimings.Duration_log__c = 1000;
        batchJobTimings.API_Duration_Log__c = 1000;
        //batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        //batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfullRun_Log__c = DateTime.Now().addHours(-7);
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
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1234';
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        //insert pgm;
        
        Task tsk = new task();
        tsk.WhatId = pgm.Id;
        tsk.Task_Id__c = '1234';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.FileNumber__c = '1234';
        tsk.ActivityDate = Date.Today ();
        
        //insert tsk;
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_GetLogEntriesBatchHandler.webserviceLogEntriesMock ());
        Database.executeBatch(new Attorney_GetLogEntriesBatch(System.now().addHours(-48),System.now().addHours(-7)),1);
        
    }
    
    public class webserviceLogEntriesMock implements WebServiceMock {
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
                LeadtracNetClient.GetCompanyLogEntriesResponse_element logEntriesResponse = new LeadtracNetClient.GetCompanyLogEntriesResponse_element();
                LeadtracNetClient.GetLogEntriesResult LogLogEntriesResult = new LeadtracNetClient.GetLogEntriesResult();
                LogLogEntriesResult.isSuccessful = true;
                leadtracNetClient.ArrayOfLogEntry Entries = new leadtracNetClient.ArrayOfLogEntry();
                leadtracNetClient.logEntry le= new leadtracNetClient.logEntry();
                le.FileNumber = '1234';
                le.Id = 1234;
                le.DebtId = 1234;
                le.CreatedOn = System.now().addHours(-8);
                le.CreatedBy = 'test@test.com';
                le.ModifiedBy = 'test@test.com';
                le.ModifiedOn = System.now().addHours(-8);
                
                leadtracNetClient.LogCategory category= new leadtracNetClient.LogCategory();
                category.Category = 'Note';
                category.CategoryId = 1234;
                category.CategoryType = 'Note';
                le.Category = category;
                Entries.LogEntry = new List<leadtracNetClient.logEntry>();
                Entries.LogEntry.add(le);
                LogLogEntriesResult.entries = Entries;
                logEntriesResponse.GetCompanyLogEntriesResult = LogLogEntriesResult;
                logEntriesResponse.totalPages = 1;
                logEntriesResponse.totalRecords = 1;
                response.put('response_x',logEntriesResponse);
            }
    }
    
}