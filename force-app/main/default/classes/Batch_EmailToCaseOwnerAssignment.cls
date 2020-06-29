public class Batch_EmailToCaseOwnerAssignment implements Database.Batchable<sObject>, Database.Stateful {
    
    Integer userCount = 0;
    Integer currentUser = 1;
    public Map<Integer, Id> userNoIdMap = new Map<Integer, Id>();
    public set<Id> caseIdSet = new set<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query;
        Email_to_Case_Owner_assignment__mdt emailToCaseAssignmentInstance = [SELECT Id, Case_Limit__c, Source_Queue__c, Target_Queue__c 
                                                                                FROM Email_to_Case_Owner_assignment__mdt 
                                                                                WHERE MasterLabel = 'Email to Case Owner assignment' 
                                                                                AND Case_Limit__c > 0 AND Source_Queue__c != null 
                                                                                AND Target_Queue__c != null];
            
        if (emailToCaseAssignmentInstance != null) {
            
            Integer caseCount = Integer.valueOf(emailToCaseAssignmentInstance.Case_Limit__c);
            List<Id> UserIdList = new List<Id>();
            
            for (GroupMember gmInst : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = :emailToCaseAssignmentInstance.Target_Queue__c And Group.Type = 'Queue' Order By SystemModstamp Asc]) {
                
                System.debug('userInst-->'+gmInst);
                UserIdList.add(gmInst.UserOrGroupId);
            }
            
            if (UserIdList.isEmpty() == False) {
                
                Map<Id, User> userMap =new Map<Id, User> ([SELECT Id, Name FROM User WHERE Id IN :UserIdList AND IsActive = True]);
                
                if (userMap.isEmpty() == False) {
                    
                    List<User> userList = new List<User>();
                    
                    for (Id userId : UserIdList) {
                        
                        if (userMap.containsKey(userId) == True) {
                            
                            userNoIdMap.put(userCount, userId);
                            userCount ++;
                        }
                    }
                    System.debug('userNoIdMap-->'+userNoIdMap);
                }
            }
            
            caseCount *= userCount;
            
            Group EmailtoCaseQueue = [SELECT Id FROM GROUP WHERE Name = :emailToCaseAssignmentInstance.Source_Queue__c];
            System.debug('EmailtoCaseQueue' + EmailtoCaseQueue);
            Id queueId = EmailtoCaseQueue.Id;
            
            if (caseIdSet == null || caseIdSet.isEmpty() == True) { 
            
                //query = 'SELECT Id, OwnerId FROM Case WHERE Status = \'New\' AND Case.OwnerId = :queueId ORDER BY CreatedDate Asc LIMIT :caseCount';
                query = 'SELECT Id, OwnerId FROM Case WHERE Status = \'New\' ORDER BY CreatedDate Asc LIMIT :caseCount';
            
            } else {
                
                //query = 'SELECT Id, OwnerId FROM Case WHERE Id IN :caseIdSet AND Status = \'New\' AND Case.OwnerId = :queueId ORDER BY CreatedDate Asc LIMIT :caseCount';
                query = 'SELECT Id, OwnerId FROM Case WHERE Id IN :caseIdSet AND Status = \'New\' ORDER BY CreatedDate Asc LIMIT :caseCount';
            }
        
        } else {
            
            query = 'SELECT Id FROM Case LIMIT 0';
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Case> caseList) {      
        
        for(Case caseInst :caseList) {
            
            caseInst.OwnerId = userNoIdMap.get(currentUser - 1);
            currentUser ++;
            
            if(userCount < currentUser) {
                currentUser = 1;    
            }
        }  
        update caseList;
    
    }        
    
    public void finish(Database.BatchableContext BC) {
        
    }
}