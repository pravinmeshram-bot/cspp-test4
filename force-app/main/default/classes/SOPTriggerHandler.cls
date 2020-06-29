/**
* Name:          SOPTriggerHandler
* Author:        Amit Goyal
* CreatedDate:   08/27/2019 - S20-197 - Amit Goyal
* Modified By:   
* Description:   To Create tasks for SOP Queues on SOP Update/Publish
*/

public without sharing class SOPTriggerHandler{
    // variables to handler recurssion
    public static boolean hasAlreadyRanAfterInsert = false;
    public static boolean hasAlreadyRanAfterUpdate = false;
    
    public static void handleAfterInsert(map<Id, SOP__kav> newSOPs){
        // Method to execute from Trigger on after insertion of sop
        if(!hasAlreadyRanAfterInsert){
            hasAlreadyRanAfterInsert=true;
        }
        
        // To collect all published SOP
        set<Id> sopIds = new set<Id>();
        if(newSOPs != null && newSOPs.size()>0){
            for(SOP__kav sop: newSOPs.values()){
                // collect all SOP Ids
                sopIds.add(sop.Id);
            }
            
            if(sopIds != null && sopIds.size()>0){
                // Execute the logic to create CSR Tasks for SOPs if we have any SOP Tasks
                createCSRTasks(sopIds);
            }
        }
    }
    
    public static void handleAfterUpdate(map<Id, SOP__kav> newSOPs, map<Id, SOP__kav> oldSOPs){
        // Method to execute from Trigger on after insertion of sop
        if(!hasAlreadyRanAfterUpdate){
            hasAlreadyRanAfterUpdate=true;
        }
        
        // To collect all published SOP
        set<Id> sopIds = new set<Id>();
        if(newSOPs != null && newSOPs.size()>0){
            for(SOP__kav sop: newSOPs.values()){
                // collect all SOP Ids
                sopIds.add(sop.Id);
            }
            
            if(sopIds != null && sopIds.size()>0){
                // Execute the logic to create CSR Tasks for SOPs if we have any SOP Tasks
                createCSRTasks(sopIds);
            }
        }
    }
    /*
    public static Map<String, list<String>> getGroupUsers(set<Id> groupIds){
        Map<String, list<String>> sopMembersMap = new Map<String,list<String>>();
        Map<String, list<String>> sopGroupsMap = new Map<String, list<String>>();
        if(groupIds != null && groupIds.size()>0){
            for(GroupMember sgm : [SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN: groupIds]){
            	if(String.valueOf(sgm.UserOrGroupId).startsWith('005')){
                    list<String> gMembers = sopMembersMap.get(sgm.Group.Name);
                    if(gMembers==null){
                        gMembers=new list<String>();
                    }
                    gMembers.add(sgm.UserOrGroupId);
                    sopMembersMap.put(sgm.Group.Name, gMembers);
                }
                
                if(String.valueOf(sgm.UserOrGroupId).startsWith('00G')){
                    list<String> gMembers = sopMembersMap.get(sgm.Group.Name);
                    if(gMembers==null){
                        gMembers=new list<String>();
                    }
                    gMembers.add(sgm.UserOrGroupId);
                    sopGroupsMap.put(sgm.Group.Name, gMembers);
                }
            }
        }
        return sopMembersMap;
    }
    */
    
    public static void createCSRTasks(set<Id> sopIds){
        // This method is in use to create CSR tasks for SOP QueueMembers from SOP
        list<SOP__kav> newSOPs = [Select Id, Title, PublishStatus, RecordTypeId, (Select Id, Subject 
                                                             From Activities__r 
                                                             Where Subject like 'SOP%') 
                                  From SOP__kav Where Id IN: sopIds];
        list<Task> processCSRTasks = new list<Task>();
        // validate whether the records exist
        if(newSOPs != null && newSOPs.size()>0){
            set<String> userIds = new set<String>();
            set<String> groupIds = new set<String>();
            Map<String, list<String>> sopMembersMap = new Map<String,list<String>>();
            Map<String, list<String>> sopGroupsMap = new Map<String, list<String>>();
            
            // To query all the queues starting from SOP
            Map<Id,Group> sopQueues = new Map<Id,Group>([SELECT Id, Name FROM Group WHERE type='Queue' and Name like 'SOP%']);
            system.debug('### sopQueues size: '+sopQueues.size());
		    
            // To query all queue members from the sop queues
            for(GroupMember sgm : [SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN: sopQueues.keySet()]){
                if(String.valueOf(sgm.UserOrGroupId).startsWith('005')){
                    list<String> gMembers = sopMembersMap.get(sgm.Group.Name);
                    if(gMembers==null){
                        gMembers=new list<String>();
                    }
                    userIds.add(sgm.UserOrGroupId);
                    gMembers.add(sgm.UserOrGroupId);
                    sopMembersMap.put(sgm.Group.Name, gMembers);
                }
                
                if(String.valueOf(sgm.UserOrGroupId).startsWith('00G')){
                    list<String> gMembers = sopGroupsMap.get(sgm.Group.Name);
                    if(gMembers==null){
                        gMembers=new list<String>();
                    }
                    groupIds.add(sgm.UserOrGroupId);
                    gMembers.add(sgm.UserOrGroupId);
                    sopGroupsMap.put(sgm.Group.Name, gMembers);
                }
            }
            system.debug('### sopMembersMap ---> 1: '+sopMembersMap.size());
            system.debug('### GroupIds ---> 1: '+groupIds.size());
            system.debug('### sopGroupsMap ----> 1: '+sopGroupsMap);
            
            if(sopGroupsMap != null && sopGroupsMap.size()>0){
                map<Id, list<String>> grpUsers = new map<Id, list<String>>();
                for(GroupMember sgm : [SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN: groupIds]){
                    if(String.valueOf(sgm.UserOrGroupId).startsWith('005')){
                        list<String> result = grpUsers.get(sgm.GroupId);
                        if(result==null){
                            result=new list<String>();
                        }
                        result.add(sgm.UserOrGroupId);
                        grpUsers.put(sgm.GroupId, result);
                    }
                }
                
                if(grpUsers != null && grpUsers.size()>0){
                    for(String qName: sopGroupsMap.keyset()){
                        list<String> groups = sopGroupsMap.get(qName);
                        for(String gId: groups){
                            if(grpUsers.containsKey(gId)){
                                list<String> users = grpUsers.get(gId);
                                if(users != null && users.size()>0){
                                    list<String> gMembers=sopMembersMap.get(qName);
                                    if(gMembers==null){
                                        gMembers=new list<String>();
                                    }
                                    userIds.addAll(users);
                                    gMembers.addAll(users);
                                    sopMembersMap.put(qName, gMembers);
                                }
                            }
                        }
                    }
                }
            }
			
            system.debug('### sopMembersMap ---> 2: '+sopMembersMap.size());
            system.debug('### sopGroupsMap ----> 2: '+sopGroupsMap.size());
            
            // validate whether the records exist
            if(sopMembersMap != null && sopMembersMap.size()>0){
                map<String, User> usersMap = new map<String, User>([Select Id, Name From User Where Id IN: userIds AND isActive=true]);
                system.debug('### usersMap: '+usersMap.size());
                if(usersMap != null && usersMap.size()>0){
                    Id NUDebtTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Nudebt Record Type').getRecordTypeId();                
                    // Processing all the SOP Tasks to split
                    for(SOP__kav sop: newSOPs){
                        system.debug('### sop PublishStatus: '+sop.PublishStatus);
                        //if(sop.PublishStatus=='Online'){
                        if(sop.Activities__r != null && sop.Activities__r.size()>0){
                            // Activities already exists.
                            system.debug('### Activities already exists.');
                        }else{
                            list<String> sopMemberIds = sopMembersMap.get('SOP-'+Schema.SObjectType.SOP__kav.getRecordTypeInfosById().get(sop.RecordTypeId).getName());
                            if(sopMemberIds != null && sopMemberIds.size()>0){
                                // Creating new tasks for the queue members from second index onwards
                                for(Integer i=0; i<sopMemberIds.size(); i++){
                                    system.debug('### Userid: '+sopMemberIds[i]);
                                    if(usersMap.containsKey(sopMemberIds[i])){
                                        processCSRTasks.add(new Task(ActivityDate=System.Today().addDays(2), OwnerId=sopMemberIds[i], 
                                                                     Description='Please review this SOP for updates.', SOP__c=sop.Id,
                                                                     Status='Not Started', Subject='SOP Review Required-'+sop.Title, Subject__c='SOP Review Required-'+sop.Title,
                                                                     RecordTypeId=NUDebtTaskRecordTypeId));
                                    }
                                    
                                }
                            }
                        }
                        //}
                    }
                }
            }
        }
        
        system.debug('### processCSRTasks size: '+processCSRTasks.size());
        // validate whether the records exist
        if(processCSRTasks != null && processCSRTasks.size()>0){
            // inserting new tasks and updating original tasks
            upsert processCSRTasks;
        }
    }
}