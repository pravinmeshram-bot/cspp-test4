@isTest
public class Test_Attorney_UserListBatchScheduler {
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
    
    Batch_Data__c bd = new Batch_Data__c();
        bd.Name = 'Attorney_GetUserListBatch';
        insert bd;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getUserId ();
        batchJobTimings.NDS_User_List_Duration__c = 1440;
        insert batchJobTimings;
        
        NDS_User_List__c usr = new NDS_User_List__c();
        usr.Email__c = 'test@test.com';
        usr.First_Name__c = 'first test';
        usr.Last_Name__c = 'last test';
        usr.User_Id__c = 'test001';
        usr.User_Name__c = 'test@test.com';
        insert usr;
}
@isTest static void schedulerTest () {
        try {
            init ();
            Test.startTest ();
                Test.setMock (WebServiceMock.class, new Test_Attorney_UserListBatchScheduler.webserviceClientsMock ());
                Database.BatchableContext bc;
                String CRON_EXP = '0 0 0 3 9 ? 2022';
                Attorney_UserListBatchScheduler obj = new Attorney_UserListBatchScheduler();
                String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, obj);
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
           leadtracNetUser.GetUserListResponse_element respElement = new leadtracNetUser.GetUserListResponse_element ();
           respElement.GetUserListResult = new leadtracNetUser.GetUserListResult();
           response.put('response_x', respElement);
           
        }
    }
}