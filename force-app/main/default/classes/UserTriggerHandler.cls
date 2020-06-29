/**
* Name:          UserTriggerHandler
* Author:        Amit Goyal
* CreatedDate:   10/23/2019 - S20-374 - Amit Goyal
* Modified By:   
* Description:   To Create tasks for New Users related to all SOP based on department
*/
public class UserTriggerHandler {
    // variables to handler recurssion
    public static boolean hasAlreadyRanAfterInsert = false;
    public static boolean hasAlreadyRanAfterUpdate = false;
    
	public static void handleAfterInsert(map<Id, User> newUsers){
        // Method to execute from Trigger on after insertion of users
        if(!hasAlreadyRanAfterInsert){
            hasAlreadyRanAfterInsert=true;
        }
    	
        set<Id> profileIds = new set<Id>();
        set<Id> userIds = new set<Id>();
        if(newUsers != null && newUsers.size()>0){
            for(User usr: newUsers.values()){
            	profileIds.add(usr.ProfileId);
            }
            
            if(profileIds != null && profileIds.size()>0){
                map<Id, Profile> profilesMap = new map<Id, Profile>([Select Id, Name, UserLicenseId, UserLicense.Name 
                                                                     From Profile
                                                                    Where Id IN: profileIds]);
                if(profilesMap != null && profilesMap.size()>0){
                    for(User usr: newUsers.values()){
                        if(profilesMap.get(usr.ProfileId).UserLicense.Name=='Salesforce' || profilesMap.get(usr.ProfileId).UserLicense.Name=='Salesforce Platform'){
                            userIds.add(usr.Id);
                        }
                    }
                    
                    if(userIds != null && userIds.size()>0){
                        createCSRTasks(userIds);
                    }
                }
            }
        }
    }
    
    public static void handleAfterUpdate(map<Id, User> newUsers, map<Id, User> oldUsers){
        // Method to execute from Trigger on after insertion of users
        if(!hasAlreadyRanAfterUpdate){
            hasAlreadyRanAfterUpdate=true;
        }
        
        set<Id> profileIds = new set<Id>();
        set<Id> userIds = new set<Id>();
        set<Id> userIds_Inactive = new set<Id>();
        if(newUsers != null && newUsers.size()>0){
            for(User usr: newUsers.values()){
            	profileIds.add(usr.ProfileId);
            }
            
            if(profileIds != null && profileIds.size()>0){
                map<Id, Profile> profilesMap = new map<Id, Profile>([Select Id, Name, UserLicenseId, UserLicense.Name 
                                                                     From Profile
                                                                    Where Id IN: profileIds]);
                if(profilesMap != null && profilesMap.size()>0){
                    for(User usr: newUsers.values()){
                        if(profilesMap.get(usr.ProfileId).UserLicense.Name=='Salesforce' || profilesMap.get(usr.ProfileId).UserLicense.Name=='Salesforce Platform'){
                            if(usr.isActive==false && usr.isActive != oldUsers.get(usr.Id).isActive){
                                userIds_Inactive.add(usr.Id);
                            }
                            
                            if(usr.isActive==true && (oldUsers.get(usr.Id).ProfileId != usr.ProfileId || usr.isActive != oldUsers.get(usr.Id).isActive)){
                                userIds.add(usr.Id);
                            }
                        }
                    }
                }
                if(userIds_Inactive != null && userIds_Inactive.size()>0){
                    cancelOldCSRTasks(userIds_Inactive);
                }
                
                if(userIds != null && userIds.size()>0){
                    // Cancel all the old tasks which exists
                    cancelOldCSRTasks(userIds);
                    
                    // Create new CSR Tasks
                    createCSRTasks(userIds);
                }
            }
        }
    }
    
    @future
    public static void cancelOldCSRTasks(set<Id> userIds){
        Id NUDebtTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Nudebt Record Type').getRecordTypeId();
        list<Task> tasks = [Select Id, Subject, Status From Task 
                            Where OwnerId IN: userIds 
                            AND SOP__c != null 
                            AND Status != 'Completed'
                            AND Subject like 'SOP%' 
                            AND RecordTypeId=:NUDebtTaskRecordTypeId];
        if(tasks != null && tasks.size()>0){
            for(Task tsk: tasks){
                tsk.Status='Canceled';
            }
            update tasks;
        }
    }
    
    @future
    public static void createCSRTasks(set<Id> userIds) {
    	if(userIds != null && userIds.size()>0){
            map<Id, User> newUsers = new map<Id, User>([Select Id, Name, ProfileId From User Where Id IN: userIds]);
            // Collection of Profile Ids of new users
            set<Id> profileIds = new set<Id>();
            for(User usr: newUsers.values()){
                profileIds.add(usr.ProfileId);
            }
            
            // Collection of recordtypes on SOP Object
            Map<String, Schema.RecordTypeInfo> soprecordTypes = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName();
            system.debug('### profileIds: '+profileIds.size());
            system.debug('### soprecordTypes: '+soprecordTypes.size());
            if((profileIds != null && profileIds.size()>0) && (soprecordTypes != null && soprecordTypes.size()>0)){
                map<Id, Profile> profilesMap = new map<Id, Profile>([Select Id, Name From Profile Where Id IN: profileIds]);
                if(profilesMap != null && profilesMap.size()>0){
                    // Collection of UserIds and SOP RecordTypeIds map
                    map<String, String> userSOP_RTMap=new map<String, String>();
                    for(User usr: newUsers.values()){
                        if(profilesMap.containsKey(usr.ProfileId)){
                            String profileName = profilesMap.get(usr.ProfileId).Name;
                            for(String recName: soprecordTypes.keyset()){
                                if(recName != 'Master'){
                                    system.debug('### recName: '+recName);
                                    if(profileName.contains(recName)){
                                        if(recName=='Sales'){
                                            if(profileName.contains('Sales Operations')){
                                                userSOP_RTMap.put(usr.Id, 'Sales Operations');
                                            }
                                        }
                                        if(!userSOP_RTMap.containsKey(usr.Id)){
                                            userSOP_RTMap.put(usr.Id, recName);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    system.debug('### userSOP_RTMap: '+userSOP_RTMap.size());
                    if(userSOP_RTMap != null && userSOP_RTMap.size()>0){
                        map<String, list<SOP__kav>> sopByRTMap = new map<String, list<SOP__kav>>();
                        list<String> sopRTId=userSOP_RTMap.values();
                        String strSoql = 'Select Id, Title, RecordTypeId, RecordType.Name From SOP__kav Where RecordType.Name IN: sopRTId';
                        if(!Test.isRunningTest()){
                            strSoql+=' AND PublishStatus=\'Online\'';
                        }
                        list<SOP__kav> sops = Database.query(strSoql);
                        system.debug('### sops: '+sops.size());
                        if(sops != null && sops.size()>0){
                            for(SOP__kav sop: sops){
                                list<SOP__kav> result = sopByRTMap.get(sop.RecordType.Name);
                                if(result==null){
                                    result=new list<SOP__kav>();
                                }
                                result.add(sop);
                                sopByRTMap.put(sop.RecordType.Name, result);
                            }
                        }
                        
                        system.debug('### sopByRTMap: '+sopByRTMap.size());
                        if(sopByRTMap != null && sopByRTMap.size()>0){
                            Id NUDebtTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Nudebt Record Type').getRecordTypeId();
                            list<Task> processCSRTasks = new list<Task>();
                            for(String usrId: userSOP_RTMap.keyset()){
                                String rtName = userSOP_RTMap.get(usrId);
                                if(rtName != null && rtName.trim().length()>0){
                                    list<SOP__kav> resultSOPs=sopByRTMap.get(rtName);
                                    system.debug('### resultSOPs: '+resultSOPs.size());
                                    if(resultSOPs != null && resultSOPs.size()>0){
                                        for(SOP__kav sop: resultSOPs){
                                            processCSRTasks.add(new Task(ActivityDate=System.Today().addDays(2), OwnerId=usrId, 
                                                                         Description='Please review this SOP for updates.', SOP__c=sop.Id,
                                                                         Status='Not Started', Subject='SOP Review Required-'+sop.Title, Subject__c='SOP Review Required-'+sop.Title,
                                                                         RecordTypeId=NUDebtTaskRecordTypeId));
                                        }
                                    }
                                }
                            }
                            if(processCSRTasks != null && processCSRTasks.size()>0){
                                insert processCSRTasks;
                            }
                        }
                    }
                }            
            }
        }
    }
}