public class ProgramHandlerRoundRobinAssign {
    
    public static Set<Id> processedProgramIdSet = new Set<Id>();
    
    public static void roundRobinAssignment(List<nu_dse__Program__c> newProgramList, Map<Id,nu_dse__Program__c> programOldMap) {
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
        
        for (nu_dse__Program__c programInst :newProgramList) {
            
            if (processedProgramIdSet.contains(programInst.Id) == False && programInst.nu_dse__Program_Status__c == 'Pending Cancellation' 
                && programOldMap.get(programInst.Id).nu_dse__Program_Status__c != 'Pending Cancellation' && programInst.Retention_Rep__c == null) {
                
                processedProgramIdSet.add(programInst.Id);
                programList.add(programInst);
            }
        }
        
        if (programList.isEmpty() == False) {
            
            Retention_Rep_Assignment__c retentionRepInst = Retention_Rep_Assignment__c.getValues('Rep Assignment Data');
            System.debug('retentionRepInst-->'+retentionRepInst);
            
            if (retentionRepInst != null && retentionRepInst.Queue_Name__c != null) {
                
                List<User> userList = userListWithOrder(retentionRepInst.Queue_Name__c);
                
                if (userList != null && userList.size() > 0 == True) {
                    
                    Integer queueMember = (retentionRepInst.User_Number__c != null && retentionRepInst.User_Number__c > 0)?Integer.ValueOf(retentionRepInst.User_Number__c) : 1;
                    queueMember = queueMember-1;
                    System.debug('queueMember-->'+queueMember);
                    
                    Integer totalUserSize = userList.size() - 1;
                    System.debug('totalUserSize-->'+totalUserSize);
                    
                    //If queue name is changed in custom settings and its user number is not changed means there is a possibility of having greater user number than actual users in queue. 
                    if (queueMember > totalUserSize) {
                        
                        queueMember = 0;
                    }
                    
                    String lastAssignedUserName;
                    
                    for (nu_dse__Program__c programInst :programList) {
                        
                        programInst.Retention_Rep__c = userList[queueMember].Id;
                        lastAssignedUserName = userList[queueMember].Name;
                        
                        queueMember++;
                        System.debug('queueMember1-->'+queueMember);
                        
                        if (queueMember > totalUserSize) {
                            
                            queueMember = 0;
                        }
                        System.debug('queueMember2-->'+queueMember);
                    }
                    
                    retentionRepInst.User_Number__c = queueMember + 1;
                    retentionRepInst.Last_Assigned_User_Name__c = lastAssignedUserName;
                    update retentionRepInst;
                }
            }
        }
    }
    
    public static List<User> userListWithOrder (String groupName) {
        
        List<Id> UserIdList = new List<Id>();
        
        for (GroupMember gmInst : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = :groupName And Group.Type = 'Queue' Order By SystemModstamp Asc]) {
            
            System.debug('userInst-->'+gmInst);
            UserIdList.add(gmInst.UserOrGroupId);
        }
        
        if (UserIdList.isEmpty() == False) {
            
            Map<Id, User> userMap =new Map<Id, User> ([SELECT Id, Name FROM User WHERE Id IN :UserIdList AND IsActive = True]);
            
            if (userMap.isEmpty() == False) {
                
                List<User> userList = new List<User>();
                
                for (Id userId : UserIdList) {
                    
                    if (userMap.containsKey(userId) == True) {
                        
                        userList.add(userMap.get(userId));
                    }
                }
                System.debug('userList-->'+userList);
                return userList;
            }
        }
        
        return null;
    }
}