@isTest
public class Test_Attorney_AsyncLeadtracNetUser {
    
    @isTest static void testEchoString() {              
        
        Test.startTest ();
            AsyncLeadtracNetUser.GetUserListResponse_elementFuture creditbyvendorelement = new AsyncLeadtracNetUser.GetUserListResponse_elementFuture();
            try {
                creditbyvendorelement.getValue ();
            } catch (Exception e) {}
            System.Continuation continuation = new Continuation (10);
            AsyncLeadtracNetUser.AsyncUserServiceSoap soap = new AsyncLeadtracNetUser.AsyncUserServiceSoap();
            soap.beginGetUserList(continuation,'test','Test'); 
    }
}