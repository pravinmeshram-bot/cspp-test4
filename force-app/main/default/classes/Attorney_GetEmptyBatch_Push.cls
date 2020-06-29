global class Attorney_GetEmptyBatch_Push implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{
    global List<FileNumberData__c> start(Database.BatchableContext BC){
        List<FileNumberData__c> fileNumberDataLst = [select id,Name,Type__c From FileNumberData__c where completed__c = FALSE AND Type__c = 'Client' order by Name DESC LIMIT 1];
        return fileNumberDataLst;
    }
    global void execute(Database.BatchableContext BC,List<FileNumberData__c> scope){
    }
    global void finish(Database.BatchableContext BC){
    }
}