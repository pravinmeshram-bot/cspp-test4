public class SFSPortal_PortalIdentityServiceHandler {

    public static void updateUser(List<Portal_Identity_Service__c> newPortalIdentityServiceList, Map<Id, Portal_Identity_Service__c> oldPortalIdentityServiceMap) {
        
        Set<Id> userIdSet = new Set<Id>();
        List<Contact> updateContactList = new List<Contact>();
        List<User> updateUserList = new List<User>();
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        try {
        
            if (newPortalIdentityServiceList.isEmpty() == False) {
            
                String identityRecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification');
                 
                for (Portal_Identity_Service__c portalIdentityService : newPortalIdentityServiceList) {
                    
                    if (portalIdentityService.RecordTypeId == identityRecordTypeId
                        && oldPortalIdentityServiceMap.ContainsKey(portalIdentityService.Id) 
                            && portalIdentityService.Status__c != oldPortalIdentityServiceMap.get(portalIdentityService.Id).Status__c 
                                && portalIdentityService.Status__c == 'Verified' && portalIdentityService.user__c != null 
                                    && portalIdentityService.New_Value__c != null) {
                                           
                        Matcher MyMatcher = MyPattern.matcher(portalIdentityService.New_Value__c);  
                        if (MyMatcher.matches()) {
                            
                            userIdSet.add(portalIdentityService.user__c);
                            User userInstance = new User(Id = portalIdentityService.user__c);     
                            userInstance.Email = portalIdentityService.New_Value__c;
                          //  userInstance.CommunityNickname = portalIdentityService.New_Value__c;
                            updateUserList.add(userInstance);
                        }
                    }
                }
                
                if (updateUserList.isEmpty() == False) {
                    
                    update updateUserList;
                    if (userIdSet.isEmpty() == False) {
                        
                        for (User userInstance :  [SELECT Id, Email, ContactId FROM User WHERE Id IN :userIdSet] ) {
                            
                            Contact contactInstance = new Contact(Id = userInstance.ContactId);
                            contactInstance.Email = userInstance.Email;
                            updateContactList.add(contactInstance);
                        }
                        
                        if (updateContactList.isEmpty() == False) {
                            
                            update updateContactList;
                        }
                        
                       // updateUserName1(userIdSet);
                    }
                }
            }
        } catch(Exception e) {
            
            throw new CustomException(e.getMessage());
        }
    }
    @future
    public static void updateUserName1(Set<ID> uerIds){
     System.debug(uerIds) ;
     list<User> userList = [select id, Username, Email from User where id in :uerIds];
     System.debug(userList[0].id) ;
     list<User> userListToUpdate = new list<User>();

         try {
            
                if (userList.isEmpty() == False) {
                
                    for(User u : userList){
                    
                        if( u.userName != u.Email){
                            u.userName = u.Email;
                        }
                        
                        
                        userListToUpdate.add(u);
                       System.debug('=======>'+ u.userName);  
                    }
                   
                    update userListToUpdate;
                } 
         }catch(Exception e) {
                
               // throw new CustomException(e.getMessage());
               System.debug('===>'+e.getMessage());
          }
     }
}