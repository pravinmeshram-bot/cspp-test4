public without sharing class Attorney_GetUserListBatchHandler {
    public static leadtracNetUser.GetUserListResult  userListResult;
    public static List<NDS_User_List__c> getUserList()
    {
        List<NDS_User_List__c> UserLst = new List<NDS_User_List__c>();
        leadtracNetUser.UserServiceSoap soap = new leadtracNetUser.UserServiceSoap ();
        
        if (!Test.isRunningTest()) {
            userListResult = new leadtracNetUser.GetUserListResult();
            userListResult = soap.GetUserList(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c);
        }
        if(userListResult != NULL)
        {
             leadtracNetUser.ArrayOfApiUser arryofUser = userListResult.UserList;
             for(leadtracNetUser.ApiUser usr: arryofUser.ApiUser)
             {
                 NDS_User_List__c ObjUsrLst = new NDS_User_List__c();
                 ObjUsrLst.Email__c = usr.EmailAddress;
                 ObjUsrLst.First_Name__c = usr.FirstName;
                 ObjUsrLst.Last_Name__c = usr.LastName;
                 ObjUsrLst.User_Id__c = String.ValueOf(usr.UserId);
                 ObjUsrLst.User_Name__c = usr.userName;
                                  ObjUsrLst.IsActive__c= usr.IsActive;

                 UserLst.add(ObjUsrLst);   
             }
        }
        
        return UserLst;
    }
}