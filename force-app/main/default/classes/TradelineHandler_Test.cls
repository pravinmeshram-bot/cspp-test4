@isTest
public class TradelineHandler_Test {
    
    static TestMethod void triggerTest(){
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.Litigation_Stage__c = 'Settled';
        tradeline.Lit_Def_Stage__c = 'Referred_To_Core';
        tradeline.nds_Current_Creditor_Name__c = 'citi';
        tradeline.Normalized_Current_Creditor__c = '';        
        tradeline.nu_dse__Original_Debt__c = 10000;
        
        List<nu_dse__Tradeline__c> tradelines = new List<nu_dse__Tradeline__c>();
        tradelines.add(tradeline); 
        
        Test.startTest();
        Database.insert(tradelines);
        Test.stopTest();
    }
    
    static TestMethod void updateCreditorStandardization_Test(){
        Creditor_Standardization__c creditStandard = new Creditor_Standardization__c();
        creditStandard.Creditor_Name__c = 'citi';
        creditStandard.Name = 'Citibank';
        insert creditStandard;
        
        Account acc = new Account();
        acc.Name = 'Citibank';
        
        insert acc;
        
                    
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.Litigation_Stage__c = 'Settled';
        tradeline.Lit_Def_Stage__c = 'Referred_To_Core';
        tradeline.nds_Current_Creditor_Name__c = 'citi';
        tradeline.Normalized_Current_Creditor__c = '';        
        tradeline.nu_dse__Original_Debt__c = 10000;
        
        insert tradeline;
        List<nu_dse__Tradeline__c> tradelines = new List<nu_dse__Tradeline__c>();
        tradelines.add(tradeline);        
            
        TradelineHandler.updateCreditorStandardization(null, tradelines);
        
        tradelines = [Select Id, Normalized_Current_Creditor__c from nu_dse__Tradeline__c limit 10];        
        
        acc = [Select Id, Name from Account where Name = 'Citibank'];
        
        tradeline.nu_dse__New_Creditor__c = acc.Id;
        
        tradelines.clear();
        tradelines.add(tradeline);
        TradelineHandler.updateResponseDate(null, tradelines);
        
        System.assertEquals('citi', tradelines[0].Normalized_Current_Creditor__c);
        
    }
    
    static testMethod void updateIncludedintheProgram_Test(){
        //Create Creditor Standardization.
        Creditor_Standardization__c creditStandard = new Creditor_Standardization__c();
        creditStandard.Creditor_Name__c = 'American Express';
        creditStandard.Name = 'American Express Creditor';
        insert creditStandard;
        
        //Create Account
        List<RecordType> lstRecordType = [Select Id, Name, DeveloperName from RecordType 
                                          where SobjectType = 'Account' AND DeveloperName = 'Creditor' ];
        
        Account acc = new Account();
        acc.Name = 'American Express';
        if(lstRecordType != null && lstRecordType.size() > 0){
          acc.RecordTypeId = lstRecordType[0].Id;    
        }
        insert acc;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.Litigation_Stage__c = 'Settled';
        tradeline.Lit_Def_Stage__c = 'Referred_To_Core';
        tradeline.nu_dse__Original_Debt__c = 10000;
        //tradeline.nu_dse__New_Creditor__c = acc.Id;
		tradeline.nu_dse__Current_Stage__c='Removed from Program';
        insert tradeline;
    }
    
    static testMethod void updateLitDefStage_Test() {
    
      //Create Creditor Standardization.
        Creditor_Standardization__c creditStandard = new Creditor_Standardization__c();
        creditStandard.Creditor_Name__c = 'American Express';
        creditStandard.Name = 'American Express Creditor';
        insert creditStandard;
        
        //Create Account
        List<RecordType> lstRecordType = [Select Id, Name, DeveloperName from RecordType 
                                          where SobjectType = 'Account' AND DeveloperName = 'Creditor' ];
        
        Account acc = new Account();
        acc.Name = 'American Express';
        if(lstRecordType != null && lstRecordType.size() > 0){
          acc.RecordTypeId = lstRecordType[0].Id;    
        }
        insert acc;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.Litigation_Stage__c = 'Settled';
        tradeline.Lit_Def_Stage__c = 'Referred_To_Core';
        tradeline.nu_dse__Original_Debt__c = 10000;
        //tradeline.nu_dse__New_Creditor__c = acc.Id;
        
        insert tradeline;
        
        List<nu_dse__Tradeline__c> tradelines = [SELECT Id, Litigation_Stage__c, Lit_Def_Stage__c, Normalized_Current_Creditor__c
                                                 FROM nu_dse__Tradeline__c WHERE Id = :tradeline.Id];
        System.debug('tradelines--->'+tradelines);
        System.assert(tradelines.size() > 0);
        //System.assertEquals('American Express Creditor', tradelines[0].Normalized_Current_Creditor__c);
        
        tradeline.nds_Current_Creditor_Name__c = 'Test Creditor';
        tradeline.nu_dse__New_Creditor__c = null;
        tradeline.Normalized_Current_Creditor__c = '';
        tradeline.nu_dse__Current_Stage__c = 'Payment Plan Active';
        update tradeline;
        
        tradelines = [SELECT Id, Litigation_Stage__c, Lit_Def_Stage__c, Normalized_Current_Creditor__c
                                                 FROM nu_dse__Tradeline__c WHERE Id = :tradeline.Id];
        
        System.assert(tradelines.size() > 0);
        //System.assertEquals('Test Creditor', tradelines[0].Normalized_Current_Creditor__c);
    }
    
    //S20-37 ****Starts****
    static testMethod void changesRelatedToSummons_Test() {
     
        nu_dse__Program__c programInstance = new nu_dse__Program__c ();
        insert programInstance;
        
        List<nu_dse__Tradeline__c> tradelineList = new List<nu_dse__Tradeline__c>{
            
            TestRecordCreator.createTradeLine(NULL, programInstance.Id),
            TestRecordCreator.createTradeLine(NULL, programInstance.Id),
            TestRecordCreator.createTradeLine(NULL, programInstance.Id),
            TestRecordCreator.createTradeLine(NULL, programInstance.Id)
        };
        tradelineList[0].SFS_Current_Balance__c = 10000;
        tradelineList[1].SFS_Current_Balance__c = 10000;
        tradelineList[2].SFS_Current_Balance__c = 10000;
        tradelineList[3].SFS_Current_Balance__c = 10000;
        
        insert tradelineList;
        
        List<Summon__c> summonList = new List<Summon__c> {
            
            new Summon__c( Client_Email__c = 'test@test.com', Program__c = programInstance.Id, Subject__c = 'New Legal File', Tradeline__c = tradelineList[1].Id),
            new Summon__c( Client_Email__c = 'test@test.com', Program__c = programInstance.Id, Subject__c = 'New Legal File', Tradeline__c = tradelineList[2].Id),
            new Summon__c( Client_Email__c = 'test@test.com', Program__c = programInstance.Id, Subject__c = 'New Legal File', Tradeline__c = tradelineList[3].Id, Case_Status__c = 'Completed')
        };
        insert summonList;
        
        List<nu_dse__Tradeline__c> tradelineToUpdate = new List<nu_dse__Tradeline__c>();
        
        tradelineList[0].Litigation_Stage__c = 'Summons';
        tradelineToUpdate.add(tradelineList[0]);
        
        tradelineList[1].Litigation_Stage__c = 'Summons';
        tradelineList[1].IsSummonCreated__c = True;
        tradelineList[1].Response_Date__c = System.Today();
        tradelineToUpdate.add(tradelineList[1]);
        
        tradelineList[2].Litigation_Stage__c = 'Summons';
        tradelineList[2].Account_Status__c = 'Summons';
        tradelineList[2].IsSummonCreated__c = True;
        tradelineToUpdate.add(tradelineList[2]);
        
        tradelineList[3].Litigation_Stage__c = 'Summons';
        tradelineList[3].IsSummonCreated__c = True;
        tradelineToUpdate.add(tradelineList[3]);
        set<id> tdid= new set<id>();
        tdid.add(tradelineList[0].id);
        
        update tradelineToUpdate;
        
        Test.startTest();
        
        User userInstance = [SELECT Id FROM User WHERE FirstName = 'Stephanie' AND LastName = 'Gatti' AND IsActive = TRUE LIMIT 1];
        System.debug('userInstance---->'+userInstance);
        
        System.runAs(userInstance) {
            
            tradelineList[2].Litigation_Stage__c = '';
            update tradelineList[2];   
            
            List<Summon__c> summon1 = [SELECT Id, Case_Status__c, Tradeline__c FROM Summon__c WHERE Tradeline__c = :tradelineList[2].Id];         
            System.assertEquals(0, summon1.size());
            
            try {
                
                tradelineList[3].Litigation_Stage__c = '';
                update tradelineList[3];
                
            } catch(Exception e) {
                
                System.Assert(e.getMessage().contains('Litigation Stage cannot be changed to \'--None--\''));
            }
        }  
        
       TradelineHandler.processCasesToComplete (tradelineToUpdate,tdid);  
       TradelineHandler.changesRelatedToCases (tradelineToUpdate ); 
       }
    //S20-37 ****Ends****     
}