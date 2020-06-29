global class IVRScoreRollupCalculationBatch implements Database.Batchable<sObject>{
    
    global final String ProgramID;
    
    global IVRScoreRollupCalculationBatch(string pID){
        ProgramID = pID;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){     
        if(string.isNotBlank(ProgramID))
        {
            return Database.getQueryLocator('SELECT Id FROM nu_dse__Program__c where id=:ProgramID');
        }
        else
        {
            return Database.getQueryLocator('SELECT Id FROM nu_dse__Program__c');
        } 
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope){

        Set<Id> incomingProgramSet = new Set<Id>();
        for(nu_dse__Program__c p : scope){
            incomingProgramSet.add(p.id);
        }
       
        IVRScoreRollupCalculationBatchHandler batchHandler = new IVRScoreRollupCalculationBatchHandler(incomingProgramSet);
        batchHandler.rollupCalculation();
    }
    
    global void finish(Database.BatchableContext BC){
    }
}