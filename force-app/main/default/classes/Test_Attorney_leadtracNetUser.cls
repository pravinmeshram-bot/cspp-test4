@isTest
public class Test_Attorney_leadtracNetUser {
    static LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
    static void init () {
        
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        
    }
    @isTest static void webServiceTest () {
        init ();
        Test.startTest();
        
        clientWebservice ();
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetUser.GetUserListMock());
        
        leadtracNetUser.UserServiceSoap respElement = new leadtracNetUser.UserServiceSoap ();
        respElement.GetUserList('Test','Test');
    }
    static void clientWebservice () {
        
    }
    public class GetUserListMock implements WebServiceMock {
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
                leadtracNetUser.GetUserListResponse_element respElement = new leadtracNetUser.GetUserListResponse_element();
                 leadtracNetUser.GetUserListResult result = new leadtracNetUser.GetUserListResult();
                result.IsSuccessful = true;
                leadtracNetUser.ArrayOfApiUser arrayUser = new leadtracNetUser.ArrayOfApiUser ();
                leadtracNetUser.ApiUser apiusr = new leadtracNetUser.ApiUser();
                apiusr.UserName = 'testName';
                apiusr.FirstName = 'testFirstName';
                apiusr.LastName = 'TestlastName';
                apiusr.UserId = 001;
                apiusr.EmailAddress = 'test@test.com';
                List<leadtracNetUser.ApiUser> apiUsrLst = new List<leadtracNetUser.ApiUser>();
                apiUsrLst.add(apiusr);
                leadtracNetUser.ArrayOfApiUser arrayUsr = new leadtracNetUser.ArrayOfApiUser();
                arrayUsr.apiUser = apiUsrLst;
                result.UserList = arrayUsr;
                respElement.GetUserListResult = result;
                response.put('response_x', respElement);
                
            }
    }
}