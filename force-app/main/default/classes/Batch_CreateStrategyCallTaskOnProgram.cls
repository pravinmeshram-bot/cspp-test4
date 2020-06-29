public class Batch_CreateStrategyCallTaskOnProgram implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date todayDate = System.today();
        
        String query = 'SELECT Id, Attorney__c FROM nu_dse__Program__c WHERE Expected_Strategy_Call_Date__c = :todayDate ';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programScopeList) {
        
        Set<String> currentStageSet = new Set<String>{'Settled', 'Payment Plan - Active', 'Payment Plan Active'};
        
        List<nu_dse__TradeLine__c> tradelineList = [SELECT Id, nu_dse__Program__c FROM nu_dse__TradeLine__c
                                                       WHERE nu_dse__Program__c IN :programScopeList 
                                                       AND (In_Litigation__c = True OR nu_dse__Current_Stage__c IN :currentStageSet)];
        
        Set<Id> taskSkippingProgramIdSet = new Set<Id>();
        Map<Id, nu_dse__Program__c> programMap = new  Map<Id, nu_dse__Program__c>(programScopeList);
        
        Set<Id> taskCreatingProgramIdSet = new Set<Id>();
        taskCreatingProgramIdSet.addAll(programMap.keySet());
        
        for (nu_dse__TradeLine__c tradelineInst : tradelineList) {
            
            if (taskSkippingProgramIdSet.contains(tradelineInst.nu_dse__Program__c) == False) {
                
                taskSkippingProgramIdSet.add(tradelineInst.nu_dse__Program__c);
                taskCreatingProgramIdSet.remove(tradelineInst.nu_dse__Program__c);
            }
        }
        
        if (taskCreatingProgramIdSet.isEmpty() == False) {
            
            List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>();
            
            List<Task_Owner_Id_Mapping__mdt> taskOwnerIdList = [SELECT Id, Label, Owner_Id__c FROM Task_Owner_Id_Mapping__mdt WHERE Label = 'Strategy Call'];
            
            Id groupTaskOwnerId;
            
            if (taskOwnerIdList.isEmpty() == False) {
                
                groupTaskOwnerId  = taskOwnerIdList[0].Owner_Id__c;
            }
            
            for (Id programId :taskCreatingProgramIdSet) {
                
                nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c();
                
                groupTaskInstance.nu_dse__Subject__c = 'Strategy Call';
                groupTaskInstance.nu_dse__ActivityDate__c = System.today();
                groupTaskInstance.nu_dse__Status__c = 'Not Started';
                groupTaskInstance.nu_dse__Description__c = 'Strategy call required';
                
                //Based on Program's Attorney Subject picklist will change;
                groupTaskInstance.Subject_Picklist__c = programMap.get(programId).Attorney__c?'9 month strategy call (legal only)': '7 month Strategy Call (TL only)';
                groupTaskInstance.nu_dse__Related_To__c = programId;
                groupTaskInstance.Program__c = programId;
                if (String.isNotBlank(groupTaskOwnerId)) {
                    
                    groupTaskInstance.OwnerId = groupTaskOwnerId;
                }
                
                groupTaskList.add(groupTaskInstance);
            }
            
             if(groupTaskList !=null && groupTaskList.size()>0 ){
         
             try{
                   insert groupTaskList;
                     system.debug('line 81'+groupTaskList[0].id);
             
             }
             catch(Exception e){
             
                system.debug('exception');
             }
        
         }
            
            //insert groupTaskList;
        }
    }
    
     public void finish(Database.BatchableContext BC) {
         
         
     }
}