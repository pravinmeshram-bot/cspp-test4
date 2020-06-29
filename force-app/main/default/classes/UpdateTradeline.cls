global class UpdateTradeline implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID from nu_dse__TradeLine__c'
        );
    }
    global void execute(Database.BatchableContext bc, List<nu_dse__TradeLine__c> scope){
        update scope;
        
    }   
    global void finish(Database.BatchableContext bc){
       
    }   
     
}