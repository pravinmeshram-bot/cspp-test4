//To aggregate the total and paid amounts of drafts, settlements and fees

public class Batch_AggregatePayments implements Database.batchable<sObject> {
    
    public String queryString;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String queryFilter = '';
        
        Aggregate_Payments__c aggregatePaymentCustomSettings = Aggregate_Payments__c.getInstance();
        
        if (aggregatePaymentCustomSettings != null && aggregatePaymentCustomSettings.Program_Query_Filter__c != null) {
        
            queryFilter = aggregatePaymentCustomSettings.Program_Query_Filter__c;
        
        } else if (String.isNotBlank(queryString)) {
        
            queryFilter = queryString;
            
        } else {
        
            queryFilter = 'Id != null';
        }
        return Database.getQueryLocator('SELECT Id FROM nu_dse__Program__c WHERE ' + queryFilter);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c > programList){
        
        Set<Id> programIdSet = new Set<Id>();
        
        for (nu_dse__Program__c programRec : programList) {
        
            programIdSet.add(programRec.Id);
        }
        
        if (programIdSet.isEmpty() == False) {
        
            List<nu_dse__Program__c> programListToUpdateList = CalculatePaymentsCurrentAmount.calculateCurrentAmount(programIdSet);
        
            if (programListToUpdateList != null && programListToUpdateList.isEmpty() == False) {
            
                update programListToUpdateList;
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}