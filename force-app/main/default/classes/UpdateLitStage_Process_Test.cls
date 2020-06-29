// Test class for Update Tradeline Litigation Stage If SFS Case Resolved
@isTest
public class UpdateLitStage_Process_Test{

    @testSetup static void setupTestData() {
    
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c = false;
        
        insert testProgram;
    
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.Litigation_Stage__c = 'Summons';
        tradeline.nu_dse__Program__c = testProgram.Id;
        
        insert tradeline;
        
        Summon__c sfsCase = new Summon__c();
        sfsCase.Tradeline__c = tradeline.Id;
        sfsCase.Subject__c = 'Test Subject';
        sfsCase.Case_Status__c = 'New';
        
        insert sfsCase;
    }

    
    static testMethod void settlement_Approval_Process_Fired() {
    
        List<Summon__c> updatedSFSCase = [SELECT Id, Case_Status__c FROM Summon__c];
        
        updatedSFSCase[0].Case_Status__c = 'Completed';
        
        update updatedSFSCase;
        
        List<nu_dse__Tradeline__c> updatedTradeline = [SELECT Id, Litigation_Stage__c FROM nu_dse__Tradeline__c];
        
        System.assertEquals('Settled', updatedTradeline[0].Litigation_Stage__c);

    }

}