@isTest
public class Batch_LitigationSummonOwnerAssign_Test {
    
    @testSetup 
    static void testSetupMethod() {
       
        nu_dse__Program__c programInst = TestRecordCreator.createProgram();
        insert programInst;
        
        Account accInst = new Account();
        accInst = TestRecordCreator.createAccount('LstName', '01241000000jtbuAAA');
        accInst.Phone = '1231231233';
        insert accInst;
        
        Retention_Rep_Assignment__c retentionRepInst = new Retention_Rep_Assignment__c();
        Retention_Rep_Assignment__c setting = new Retention_Rep_Assignment__c();
        setting.Name = 'Summon Assignment Data';
        setting.Queue_Name__c = 'Lit Negotiators';
        insert setting;
    }
    
    @isTest static void assignQueueUsingBatch() {
        
        Integer checkDateNew = integer.valueOf(Label.Summon_CheckDate);
        Date xDaysToResponseDate = System.Today().addDays(checkDateNew);
        
        Set<String> tradelineCurrentStageSet = new Set<String> ();
        //{'Offer Made', 'In-House Attorney Review', 'In-House Attorney Approved', 'Payment Plan Active', 'To Payment Processing'};
        
        for (CurrentStage_Value_To_Avoid_Owner_Change__mdt currentStageInstance : [SELECT Id, MasterLabel FROM CurrentStage_Value_To_Avoid_Owner_Change__mdt]) {
                    
            tradelineCurrentStageSet.add(currentStageInstance.MasterLabel);
            System.debug('tradelineCurrentStageSet -->'+tradelineCurrentStageSet );
        }
        
        Account accInst = new Account();
        accInst = [SELECT ID FROM Account LIMIT 1];
        system.debug('ACC' + accInst);
        
        nu_dse__Program__c programInst = new nu_dse__Program__c();
        programInst = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        system.debug('programInst' + programInst);
        
        nu_dse__TradeLine__c tradeInst = new nu_dse__TradeLine__c();TestRecordCreator.createTradeLine(accInst.Id, programInst.Id);
        tradeInst.nu_dse__Current_Stage__c = 'New';
        tradeInst.SFS_Current_Balance__c = 10000;
        insert tradeInst;
        
        Retention_Rep_Assignment__c retentionRepInst = Retention_Rep_Assignment__c.getValues('Summon Assignment Data');
        List<Group> groupList = [Select Id FROM Group where  Type = 'Queue' AND DeveloperNAME = 'Lit_Negotiators'];
        List<GroupMember> groupMemberList = new List<GroupMember>();
        groupMemberList =  [SELECT UserOrGroupId FROM GroupMember WHERE Group.Id = :groupList[0].Id];
        Id userId = groupMemberList[0].UserOrGroupId;
        
        /* 
        nu_dse__TradeLine__c tradeInst = new nu_dse__TradeLine__c();
        tradeInst = [SELECT Id FROM nu_dse__TradeLine__c LIMIT 1];
        */
        
        List<Summon__c> summonList = new List<Summon__c>();
        
        Summon__c summonIns = new Summon__c();
        summonIns.Tradeline__c = tradeInst.Id;
        summonIns.OwnerId = userId;
        summonIns.Response_Date__c = xDaysToResponseDate.addDays(-2);
        summonList.add(summonIns);
        
        insert summonList;
        
        system.Debug('123123123'+[Select Id, OwnerId FROM Summon__c][0].OwnerId);
        
        Test.startTest();
        
        Batch_LitigationSummonOwnerAssignment obj = new Batch_LitigationSummonOwnerAssignment();
        Database.executeBatch(obj);
        
        Test.stopTest();
        
        List<Group> groupList1 = [Select Id FROM Group where  Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management'];
        
        System.assertEquals(groupList1[0].Id, [SELECT Id, OwnerId FROM Summon__c][0].OwnerId);
        
    }
    
    @isTest static void executingBatchUsingSchedulers() {
        
        Integer checkDateNew = integer.valueOf(Label.Summon_CheckDate);
        Date xDaysToResponseDate = System.Today().addDays(checkDateNew);
        
        Set<String> tradelineCurrentStageSet = new Set<String> ();
        //{'Offer Made', 'In-House Attorney Review', 'In-House Attorney Approved', 'Payment Plan Active', 'To Payment Processing'};
        
        for (CurrentStage_Value_To_Avoid_Owner_Change__mdt currentStageInstance : [SELECT Id, MasterLabel FROM CurrentStage_Value_To_Avoid_Owner_Change__mdt]) {
                    
            tradelineCurrentStageSet.add(currentStageInstance.MasterLabel);
            System.debug('tradelineCurrentStageSet -->'+tradelineCurrentStageSet );
        }
        
        Account accInst = new Account();
        accInst = [SELECT ID FROM Account LIMIT 1];
        system.debug('ACC' + accInst);
        
        nu_dse__Program__c programInst = new nu_dse__Program__c();
        programInst = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        system.debug('programInst' + programInst);
        
        nu_dse__TradeLine__c tradeInst = new nu_dse__TradeLine__c();TestRecordCreator.createTradeLine(accInst.Id, programInst.Id);
        tradeInst.nu_dse__Current_Stage__c = 'New';
        tradeInst.SFS_Current_Balance__c = 10000;
        insert tradeInst;
        
        Retention_Rep_Assignment__c retentionRepInst = Retention_Rep_Assignment__c.getValues('Summon Assignment Data');
        List<Group> groupList = [Select Id FROM Group where  Type = 'Queue' AND DeveloperNAME = 'Lit_Negotiators'];
        List<GroupMember> groupMemberList = new List<GroupMember>();
        groupMemberList =  [SELECT UserOrGroupId FROM GroupMember WHERE Group.Id = :groupList[0].Id];
        Id userId = groupMemberList[0].UserOrGroupId;
        
        /* 
        nu_dse__TradeLine__c tradeInst = new nu_dse__TradeLine__c();
        tradeInst = [SELECT Id FROM nu_dse__TradeLine__c LIMIT 1];
        */
        
        List<Summon__c> summonList = new List<Summon__c>();
        
        Summon__c summonIns = new Summon__c();
        summonIns.Tradeline__c = tradeInst.Id;
        summonIns.OwnerId = userId;
        summonIns.Response_Date__c = xDaysToResponseDate.addDays(-2);
        summonList.add(summonIns);
        
        insert summonList;
        
        system.Debug('123123123'+[Select Id, OwnerId FROM Summon__c][0].OwnerId);
        
        Test.startTest();
        
        Schedule_LitigationSummonOwnerAssignment obj = new Schedule_LitigationSummonOwnerAssignment ();
        obj.batchSize = 45;
        System.schedule('Scheduled Job 1', '0 0 23 * * ?', obj);
        
        Test.stopTest();
    }
}