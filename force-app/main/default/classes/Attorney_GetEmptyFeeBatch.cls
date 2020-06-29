global class Attorney_GetEmptyFeeBatch implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
    global List<nu_dse__Program__c> start(Database.BatchableContext BC){
        List<nu_dse__Program__c> fileNumberDataLst = [Select Id,GCS_Policy_Group__c,Settlement_Fee__c,Estimated_Settlement__c,Program_type__c,nu_dse__Total_Debt_Included__c,nu_dse__Fee_Template__c from nu_dse__Program__c LIMIT 1];
        return fileNumberDataLst;
    }
    global void execute(Database.BatchableContext BC,List<nu_dse__Program__c> scope){
    }
    global void finish(Database.BatchableContext BC){
    }
}