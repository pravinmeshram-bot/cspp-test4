//**S20-458** Starts **
public with sharing class Batch_LitigationSummonOwnerAssignment implements Database.Batchable<sObject>, Database.stateful {
    
    public Id litSupportManagementId;
    public Set<Id> summonIdSet;
    
    public Batch_LitigationSummonOwnerAssignment() {
        
        List<Group> groupList = [Select Id FROM Group where  Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management'];
                
        if (groupList.size() > 0) {
             
            this.litSupportManagementId = groupList[0].Id;
        } 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Integer checkDateNew = integer.valueOf(Label.Summon_CheckDate);
        Date today = System.Today();
        Date xDaysToResponseDate = today .addDays(checkDateNew);
        
        Set<String> tradelineCurrentStageSet = new Set<String> ();
        //{'Offer Made', 'In-House Attorney Review', 'In-House Attorney Approved', 'Payment Plan Active', 'To Payment Processing'};
        
        for (CurrentStage_Value_To_Avoid_Owner_Change__mdt currentStageInstance : [SELECT Id, MasterLabel FROM CurrentStage_Value_To_Avoid_Owner_Change__mdt]) {
                    
            tradelineCurrentStageSet.add(currentStageInstance.MasterLabel);
            System.debug('tradelineCurrentStageSet -->'+tradelineCurrentStageSet );
        }
        
        Retention_Rep_Assignment__c retentionRepInst = Retention_Rep_Assignment__c.getValues('Summon Assignment Data');
        System.debug('retentionRepInst-->'+retentionRepInst);
        System.debug('Queue Name ----->' + retentionRepInst.Queue_Name__c);
        
        Set<Id> userIdSet = new Set<Id>();
        
        if (retentionRepInst != null && retentionRepInst.Queue_Name__c != null) {

            for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = :retentionRepInst.Queue_Name__c And Group.Type = 'Queue']) {
                
                System.debug('userInst-->'+gm.UserOrGroupId);
                userIdSet.add(gm.UserOrGroupId);
            }
        }
        
        System.debug('xDaysToResponseDate-->'+xDaysToResponseDate);
        
        String query = 'SELECT Id, OwnerId FROM Summon__c ' + 
                       ' WHERE OwnerId IN :userIdSet AND Response_Date__c >= :today' +
                       ' AND Response_Date__c < :xDaysToResponseDate AND Batch_To_Lit_Support__c = False' +
                       ' AND Tradeline__r.nu_dse__Current_Stage__c NOT IN :tradelineCurrentStageSet'; 
        
        if (summonIdSet != null && summonIdSet.isEmpty() == False) {
            
            query += ' AND Id IN :summonIdSet';
        }             
        system.debug('query--->'+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Summon__c> summonList) {
       
       for (Summon__c summonInstance :summonList) {
           
           summonInstance.OwnerId = this.litSupportManagementId;
           summonInstance.Batch_To_Lit_Support__c = True;
       }
       
       update summonList;
    }

    public void finish(Database.BatchableContext BC) {
    
    }
}
//**S20-458** Ends**