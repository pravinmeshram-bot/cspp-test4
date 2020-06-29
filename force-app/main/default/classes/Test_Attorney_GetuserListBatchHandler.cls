@isTest
public class Test_Attorney_GetuserListBatchHandler {

    static leadtracNetUser.GetUserListResult userTypeResult () {
        
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
        return result;
    }
    @isTest static void schedulerTest () {
        Test.startTest ();
        
            Attorney_GetUserListBatchHandler obj = new Attorney_GetUserListBatchHandler();
            Attorney_GetUserListBatchHandler.userListResult = userTypeResult ();
            Attorney_GetUserListBatchHandler.getUserList();
        Test.stopTest ();
    }
}