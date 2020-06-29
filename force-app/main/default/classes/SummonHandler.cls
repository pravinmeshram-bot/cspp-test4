public class SummonHandler {
    
    public static boolean GroupTaskCreated = false; 
    public static void createGroupTaskOnRejected(){
        System.debug('group task creation method');
        if(!GroupTaskCreated){
            List<Summon__c> SummonList = Trigger.new;
            Map<Id,Summon__c> SummonOldMap = (Map<Id,Summon__c>)Trigger.oldMap;
            List<nu_dse__Group_Task__c> GroupTaskList = new List<nu_dse__Group_Task__c>();
            for(Summon__c scase: SummonList){
                System.debug('scase.Hot_Potato__c'+scase.Hot_Potato__c);
                if(scase.Hot_Potato__c == 'With Inbound Lit Support (Rejected)' && SummonOldMap.get(scase.Id) != null && SummonOldMap.get(scase.Id).Hot_Potato__c == 'With Pre-Lit' ){
                    System.debug('inside if');
                    nu_dse__Group_Task__c gt = new nu_dse__Group_Task__c();
                    gt.nu_dse__Subject__c = 'Review for Lit Defense';
                    gt.OwnerId = Label.Lit_Support_Operations_Queue;
                    gt.Subject_Picklist__c = 'Review for LitDefense';
                    gt.nu_dse__ActivityDate__c = Date.Today() +1;
                    gt.nu_dse__Type__c = 'None';
                    gt.Summon__c = scase.Id;
                    GroupTaskList.add(gt);
                }
            }
            System.debug(GroupTaskList);
            if(!GroupTaskList.isEmpty()){
                System.debug(GroupTaskList);
                insert GroupTaskList;
                GroupTaskCreated = True;
            }
            System.debug(GroupTaskList);
        }
        
    }
    
    
    //**S20-486** Starts ** Owner assignment when the summon record is created under tradeline
    public static void litigationSummonOwnerAssignment(List<Summon__c> summonList) {
        
        Map<Id, Set<Id>> programIdAndItsTradelineMap = new Map<Id, Set<Id>>();
        Map<Id, nu_dse__Tradeline__c> tradelineIdAndInstanceMap = new Map<Id, nu_dse__Tradeline__c> ();
        Set<Id> programIdSet = new Set<Id>();
        
        Set<String> portfoliosAndStatesSet = new Set<String>();
        Set<String> creditorSet = new Set<String>();
        
        Integer checkDateNew = integer.valueOf(Label.Summon_CheckDate);
        Integer minimumResponseDays = integer.valueOf(Label.Summon_Minimum_Response_Days);  //10 Days
        Id litSupportManagementId;
        
        Set<String> currentStagesSet = new Set<String>();
        //{'Offer Made','In-House Attorney Review','In-House Attorney Approved', 'Payment Plan Active','To Payment Processing'};

        //List<String> CaseStatusList = new List<String>{'New', 'In Progress', 'Completed'};
        
        //Commented this, since this logic moved to Tradeline trigger.
        //Set<String> litigationStagesSet = new Set<String>{'Referred to ALLG','Referred to Attorney','Judgement','Garnishment'};
                       
        if (summonList.isEmpty() == FALSE) {
        
            System.debug('SummonForCreation---->' + summonList);
        
            for (Summon__c summonInstance : summonList) {
            
                if (summonInstance.Program__c != null) {
                    
                    programIdSet.add(summonInstance.Program__c);
                }
            }
            
            if (programIdSet.isEmpty() == False) {
                
                for (nu_dse__Tradeline__c tradelineInst : [SELECT Id, nu_dse__Current_Stage__c, Litigation_Stage__c, nu_dse__Program__c,
                                                            nu_dse__Program__r.MailingState__c, nu_dse__Program__r.Portfolio__r.Name, 
                                                            Normalized_Original_Creditor__c, Normalized_Current_Creditor__c,
                                                            Assign_Litigation_Support_Management__c
                                                            FROM nu_dse__TradeLine__c WHERE nu_dse__Program__c IN :programIdSet]) {
                    
                    if (programIdAndItsTradelineMap.containsKey(tradelineInst.nu_dse__Program__c) == False) {
                        
                        programIdAndItsTradelineMap.put(tradelineInst.nu_dse__Program__c, new Set<Id>());
                    }
                    
                    programIdAndItsTradelineMap.get(tradelineInst.nu_dse__Program__c).add(tradelineInst.Id);
                    tradelineIdAndInstanceMap.put(tradelineInst.Id, tradelineInst);
                }
            }
            
            if (tradelineIdAndInstanceMap.isEmpty() == FALSE) {
                   
                List<Summon__c> summonForRoundRobinList = new List<Summon__c> ();
                Set<Id> tradelineIdForRoundRobinSet = new Set<Id>(); 
                List<Group> groupList = [Select Id FROM Group where  Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management'];
                
                if (groupList.size() > 0) {
                     
                    litSupportManagementId = groupList[0].Id;
                } 
                
                for (Summon_PortfolioOrState__mdt ps : [SELECT Id, MasterLabel FROM Summon_PortfolioOrState__mdt]) {
                    
                    portfoliosAndStatesSet.add(ps.MasterLabel);
                    System.debug('portfoliosAndState-->'+ps.MasterLabel);
                }
                
                System.debug('portfoliosAndStatesSet-->'+portfoliosAndStatesSet);
                
                for (Summon_Creditor__mdt oc : [SELECT Id, Original_Creditor__c, New_Creditor__c FROM Summon_Creditor__mdt]) {
                    
                    String creditorCombo = oc.Original_Creditor__c + '/' + oc.New_Creditor__c;
                    creditorSet.add(creditorCombo);
                    System.debug('creditorCombo-->'+creditorCombo);
                }
                
                System.debug('creditorSet-->'+creditorSet);
                
                for (CurrentStage_Value_To_Avoid_Owner_Change__mdt currentStageInstance : [SELECT Id, MasterLabel FROM CurrentStage_Value_To_Avoid_Owner_Change__mdt]) {
                    
                    currentStagesSet.add(currentStageInstance.MasterLabel);
                    System.debug('currentStage-->'+currentStageInstance.MasterLabel);
                }
                
                System.debug('currentStagesSet-->'+currentStagesSet);
                
                for (Summon__c summonInstance :summonList) {
                    
                    if (summonInstance.Tradeline__c != null) {
                        
                        nu_dse__Tradeline__c summonTradeline = new nu_dse__Tradeline__c();
                        
                        if (tradelineIdAndInstanceMap.containsKey(summonInstance.Tradeline__c) == True) {
                            
                            summonTradeline = tradelineIdAndInstanceMap.get(summonInstance.Tradeline__c);
                            System.debug('summonTradeline-->'+summonTradeline);
                            
                            System.debug('CreditorCombo-->'+summonTradeline.Normalized_Original_Creditor__c + '/' + summonTradeline.Normalized_Current_Creditor__c);
                            System.debug('checkDateNew'+checkDateNew);
                            System.debug('minimumResponseDays'+minimumResponseDays);
                            System.debug('Summon Response Date-->'+summonInstance.Response_Date__c);
                            
                            if (summonTradeline.Litigation_Stage__c == 'Summons') {
                                
                                if (portfoliosAndStatesSet.isEmpty() == False && summonTradeline.nu_dse__Program__c != null  && (summonTradeline.nu_dse__Program__r.MailingState__c != null && portfoliosAndStatesSet.contains(summonTradeline.nu_dse__Program__r.MailingState__c) == True
                                    || (summonTradeline.nu_dse__Program__r.Portfolio__c != null && summonTradeline.nu_dse__Program__r.Portfolio__r.Name != null && portfoliosAndStatesSet.contains(summonTradeline.nu_dse__Program__r.Portfolio__r.Name) == True))) {
                                    
                                    summonInstance.OwnerId = litSupportManagementId;
                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                    System.debug('Case 1---->' +summonInstance);
                                    
                                } else if (creditorSet.contains(summonTradeline.Normalized_Original_Creditor__c + '/' + summonTradeline.Normalized_Current_Creditor__c) == True) {
                                    
                                    summonInstance.OwnerId = litSupportManagementId;
                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                    System.debug('Case 2.1---->' +summonInstance);
                                    
                                } else if (creditorSet.contains(summonTradeline.Normalized_Original_Creditor__c + '/ALL') == True) {
                                    
                                    summonInstance.OwnerId = litSupportManagementId;
                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                    System.debug('Case 2.2---->' +summonInstance);
                                    
                                } else if (creditorSet.contains('ALL/' + summonTradeline.Normalized_Current_Creditor__c) == True) {
                                    
                                    summonInstance.OwnerId = litSupportManagementId;
                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                    System.debug('Case 2.3---->' +summonInstance);
                                                                    
                                } else if (summonInstance.Response_Date__c != null && System.Today().daysBetween(summonInstance.Response_Date__c) < minimumResponseDays){
                                    
                                    summonInstance.OwnerId = litSupportManagementId;
                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                    System.debug('Case 3---->' +summonInstance);
                                
                                } else if (summonInstance.Response_Date__c != null && (System.Today().daysBetween(summonInstance.Response_Date__c) < checkDateNew 
                                                && currentStagesSet.contains(summonTradeline.nu_dse__Current_Stage__c) == False)) {
                                    
                                    summonInstance.OwnerId = litSupportManagementId;
                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                    System.debug('Case 4---->' +summonInstance);
                                
                                } else {
                                    
                                    if (programIdAndItsTradelineMap.containsKey(summonInstance.Program__c) == True) {
                                        
                                        Boolean isQualifiedForRoundRobin = True;
                                        
                                        for (Id tradelineId :programIdAndItsTradelineMap.get(summonInstance.Program__c)) {
                                            
                                            if (tradelineId != summonInstance.Tradeline__c && tradelineIdAndInstanceMap.containsKey(tradelineId) == True) {
                                                
                                                nu_dse__Tradeline__c tradelineInst = tradelineIdAndInstanceMap.get(tradelineId);
                                                
                                                if (tradelineInst.Assign_Litigation_Support_Management__c == True) {
                                                //if (tradelineInst.Litigation_Stage__c != null && litigationStagesSet.contains(tradelineInst.Litigation_Stage__c) == True) 
                                                    
                                                    summonInstance.OwnerId = litSupportManagementId;
                                                    //summonInstance.Batch_To_Lit_Support__c = True;
                                                    System.debug('Case 5---->' +summonInstance);
                                                    isQualifiedForRoundRobin = False;
                                                    break;
                                                }
                                            }
                                        }
                                        
                                        //Moved this condition below to support previous tradeline has
                                        if (isQualifiedForRoundRobin == True && summonInstance.Response_Date__c != null && System.Today().daysBetween(summonInstance.Response_Date__c) >= minimumResponseDays) {  //10days
                                            
                                            summonForRoundRobinList.add(summonInstance);
                                            /*Instead of checking same SFS case under same parent tradeline, 
                                              checking other tradeline under same program, which has SFS case with Active owner Id.
                                            */
                                            //tradelineIdForRoundRobinSet.add(summonInstance.Tradeline__c);
                                            
                                            if (programIdAndItsTradelineMap.containsKey(summonInstance.Program__c) == True) {

                                                tradelineIdForRoundRobinSet.addAll(programIdAndItsTradelineMap.get(summonInstance.Program__c));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                //Round robin Assignment if lit support is not assinged...
                if (summonForRoundRobinList.isEmpty() == FALSE) { 
            
                    Map<Id, Id> tradelineIdAndUserId = new Map<Id, Id>();
                    Map<Id, User> activeUserMap = new Map<Id, User> ([SELECT Id FROM USER WHERE IsActive = True]);
                    
                    Map<Id, Integer> userIdSummonCountMap = new Map<Id, Integer>();
                    List<Summon__c> SummonToAssignList = new List<Summon__c>(); 
                    Integer leastCount;
               
                    for (Summon__c summonInst : [SELECT Id, OwnerId, Tradeline__c FROM Summon__c 
                                          WHERE Tradeline__c IN :tradelineIdForRoundRobinSet //AND Case_Status__c IN :CaseStatusList 
                                          ORDER BY LastModifiedDate DESC]) {
                                                  
                        if (tradelineIdAndUserId.containsKey(summonInst.Tradeline__c) == False 
                            && activeUserMap.containsKey(summonInst.OwnerId) == True) {
                             
                            tradelineIdAndUserId.put(summonInst.Tradeline__c, summonInst.OwnerId);
                        }                                                                                   
                    }
                             
                    /*    
                    Commented due to recent changes in round robin assignment                         
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
                    */
                    for (Summon__c summonInstance : summonForRoundRobinList) {
                    
                        Boolean case6Assigned = False;
                        
                        for (Id tradelineId :programIdAndItsTradelineMap.get(summonInstance.Program__c)) {
                            
                            if (tradelineIdAndUserId != null && tradelineIdAndUserId.containsKey(tradelineId)) {
                            
                                summonInstance.OwnerId = tradelineIdAndUserId.get(tradelineId);
                                
                                if(userIdSummonCountMap.containskey(summonInstance.OwnerId) == false) {
                                
                                    userIdSummonCountMap.put(summonInstance.OwnerId, 0);
                                } 
                                userIdSummonCountMap.put(summonInstance.OwnerId, userIdSummonCountMap.get(summonInstance.OwnerId) + 1);
                                System.debug('Case 6---->' + summonInstance);
                                case6Assigned = True;
                                Break;
                            } 
                        }
                        
                        if(case6Assigned == false) {
                            SummonToAssignList.add(summonInstance);
                        }
                    }
                            
                    if(SummonToAssignList.isEmpty() == false) {
                        
                        Retention_Rep_Assignment__c retentionRepInst = Retention_Rep_Assignment__c.getValues('Summon Assignment Data');
                        System.debug('retentionRepInst-->'+retentionRepInst);
                        System.debug('Queue Name ----->' + retentionRepInst.Queue_Name__c);
                        
                        if (retentionRepInst != null && retentionRepInst.Queue_Name__c != null) {
                            
                            List<User> userList = userListWithOrder(retentionRepInst.Queue_Name__c);
                            System.debug('userList ----->' + userList );
                            
                            if (userList != null && userList.size() > 0 == True) {
                            
                                Map<Integer, Set<Id>> summonCountUserIdMap = new Map<Integer, Set<Id>>();
                                Set<Id> summonUserIds = new Set<Id>();
                            
                                for (AggregateResult result : [SELECT Count(Id) summonCount, OwnerId FROM Summon__c 
                                                            WHERE Case_Status__c != 'Completed' AND OwnerId IN :userList GROUP BY ownerId]) {
                                    
                                    Integer Count = Integer.valueOf(result.get('summonCount'));
                                    Id userId = Id.valueOf(String.valueOf(result.get('OwnerId')));
                                    
                                    if(userIdSummonCountMap.containskey(userId) == true) {
                                        
                                        Count += userIdSummonCountMap.get(userId);
                                    }
                                    
                                    if(summonCountUserIdMap.containskey(Count) == false) {
                                        summonCountUserIdMap.put(Count, new Set<Id>{userId});    
                                    } else {
                                        summonCountUserIdMap.get(Count).add(userId);
                                    }
                                    
                                    if(leastCount == null || Count < leastCount) {
                                        leastCount = Count;
                                    }
                                    summonUserIds.add(userId);
                                }
                                
                                for(User userInst : userList) {
                                    
                                    Integer count = 0;
                                    
                                    if(summonUserIds.contains(userInst.Id) == false) {
                                        
                                        if(userIdSummonCountMap.containskey(userInst.Id) == true) {
                                        
                                            count += userIdSummonCountMap.get(userInst.Id);
                                        }
                                        
                                        if(summonCountUserIdMap.containskey(count) == false) {
                                            
                                            summonCountUserIdMap.put(count, new Set<Id> {userInst.Id});    
                                        
                                        } else {
                                        
                                            summonCountUserIdMap.get(count).add(userInst.Id);
                                            
                                            if(leastCount == null || Count < leastCount) {
                                                
                                                leastCount = Count;
                                            }
                                        }
                                    }
                                } 
                                
                                System.debug('leastCount-->'+leastCount);
                                System.debug('summonCountUserIdMap-->'+summonCountUserIdMap);
                                
                                for(Summon__c summonInstance : SummonToAssignList) {
                                    
                                    Id assignOwnerId; 
                                    if(summonCountUserIdMap.containskey(leastCount)) {
                                        
                                        Set<Id> userIdsForLeastCount = summonCountUserIdMap.get(leastCount);
                                        assignOwnerId = new List<Id>(userIdsForLeastCount)[0];
                                        
                                        summonInstance.OwnerId = assignOwnerId;
                                        
                                        if(summonCountUserIdMap.containsKey(leastCount + 1) == true) {
                                            
                                            summonCountUserIdMap.get(leastCount + 1).add(assignOwnerId);
                                        
                                        } else {
                                        
                                            summonCountUserIdMap.put(leastCount + 1, new Set<Id>{assignOwnerId});
                                        }
                                        
                                        userIdsForLeastCount.remove(assignOwnerId);
                                        
                                        if(userIdsForLeastCount.isEmpty() == false) {
                                            
                                            summonCountUserIdMap.put(leastCount, userIdsForLeastCount);
                                        
                                        } else {
                                        
                                            summonCountUserIdMap.remove(leastCount);
                                            leastCount++;
                                        }
                                    }
                                }   
                            }  
                        
                        } else {
                            
                            List<Group> groupList1 = [Select Id FROM Group where  Type = 'Queue' AND DeveloperNAME = 'PRE_LIT'];
                            
                            if (groupList1.isEmpty() == False) {
                            
                                for (Summon__c summonInst :SummonToAssignList) {
                                
                                    
                                    summonInst.OwnerId = groupList1[0].Id;
                                }
                            }
                        }          
                    }
                    /*
                    if (String.isNotBlank(lastAssignedUserName) == True) {

                        retentionRepInst.User_Number__c = queueMember + 1;
                        retentionRepInst.Last_Assigned_User_Name__c = lastAssignedUserName;
                        update retentionRepInst;
                    }
                    */
                }
            }
        }
    }
    
    public static List<User> userListWithOrder (String groupName) {
    
        List<Id> userIds = new List<Id>();
        
        for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = :groupName And Group.Type = 'Queue' Order By SystemModstamp Asc]) {
            
            System.debug('userInst-->'+gm);
            userIds.add(gm.UserOrGroupId);
        }
        
        if (userIds.isEmpty() == False) {
            
            Map<Id, User> userMap =new Map<Id, User> ([SELECT Id, Name FROM User WHERE Id IN :userIds AND IsActive = True]);
            
            if (userMap.isEmpty() == False) {
                
                List<User> userList = new List<User>();
                
                for (Id userId : userIds) {
                    
                    if (userMap.containsKey(userId)) {
                        
                        userList.add(userMap.get(userId));
                    }
                }
                System.debug('userList-->'+userList);
                return userList;
            }
        }       
        return null;
    }
    //**S20-486** Ends
}