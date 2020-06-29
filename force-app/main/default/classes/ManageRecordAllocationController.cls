/*
* Class Name  : ManageRecordAllocationController
* Description : Controller for Manage Record Allocation VisualForce Page
* Developer(s): MZ
*/
public class ManageRecordAllocationController {
    public list<UserWrapper> lstUserWrapper{get;set;} 
    
    public ManageRecordAllocationController(){
        initData();
    }
    
    /* Function to initialize data
     * Get list of user from Lead Assignment group and form wrapper
     */
    public void initData(){
        set<Id> setUserId = new set<Id>();
        lstUserWrapper = new List<UserWrapper>();
        
        //Get userid from group member object
       /* for(GroupMember g:[Select Id,UserOrGroupId,Group.Name 
                           from GroupMember where Group.Name = 'Lead Assignment']){
            setUserId.add(g.UserOrGroupId); 
        }*/
        for(User u:[Select id,name from User Where Profile.Name='Pre-Sales']){
            setUserId.add(u.id); 
        }
        //Generate wrapper from users
        for(User usr: [SELECT Id, Name, IsRoundRobinAllocationEnabled__c, 
                       LastRRAllocationStatusUpdatedDateTime__c FROM User 
                       WHERE Id In :setUserId]) {
            lstUserWrapper.add(new UserWrapper(usr));
        }
        
        System.debug('--lstUserWrapper:'+lstUserWrapper);
    }
    
    /*
     * Function to update user record
     */
   
    public void setEnableChoice(){
        Id userId = ApexPages.currentPage().getParameters().get('userId'); 
        Boolean isSelected = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSelected'));
        system.debug('--userId : ' + userId);
        system.debug('--isSelected : ' + isSelected);
        
        User userToUpdate = new User(Id = userId,IsRoundRobinAllocationEnabled__c = isSelected);
       /* userToUpdate.Id = userId;
        userToUpdate.IsRoundRobinAllocationEnabled__c = isSelected; */
        
        update userToUpdate;
        initData();
        
    }
    
      
      public class UserWrapper{
        public String userName {get;set;}
        public String userId{get;set;}
        public boolean isSelected {get;set;}
        
        public UserWrapper(User user){
            this.userName = user.Name;
            this.userId = user.Id;
            this.isSelected = user.IsRoundRobinAllocationEnabled__c;
        }
    }
}