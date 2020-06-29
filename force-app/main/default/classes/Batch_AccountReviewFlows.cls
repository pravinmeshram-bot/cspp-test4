public class Batch_AccountReviewFlows implements Database.Batchable<sObject> {
    
    public Set<Id> programIds = new Set<Id>();
    
    public Batch_AccountReviewFlows() {
        
    }

    public Batch_AccountReviewFlows(Set<Id> paramIds) {
    
        if (paramIds.isEmpty() == false) {
        
            programIds.addAll(paramIds);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
         
        Set<String> programStatusInSet = new Set<String>{'Active Client'};
        Set<String> portfolioNameSet = new Set<String>();
        
        String metaDataQuery = 'SELECT Id, Label, AR_Year1_Tasks__c, AR_Year2_Tasks__c, AR_Year3_Tasks__c, AR_Year4_Tasks__c, AR_Year5_Tasks__c, Month_1_to_3_Option1_Tasks__c FROM Process_For_Portfolio__mdt';
        
        List<Process_For_Portfolio__mdt > cmdRecords = (List<Process_For_Portfolio__mdt >)JSON.deserialize(CustomMetadataGenerator.getCMDRecords(metaDataQuery), List<Process_For_Portfolio__mdt>.class);
        Set<String> option1PortfolioNameSet = new Set<String>();
        Set<Id> option1PortfolioIdSet = new Set<Id>();
        
        for (Process_For_Portfolio__mdt portfolioName : cmdRecords) {
            
            if (portfolioName.AR_Year1_Tasks__c == True){
                //rtfolioName.AR_Year2_Tasks__c == True || 
                //rtfolioName.AR_Year3_Tasks__c == True || 
                //rtfolioName.AR_Year4_Tasks__c == True || 
                //rtfolioName.AR_Year5_Tasks__c == True || 
                //rtfolioName.Month_1_to_3_Option1_Tasks__c == True)    
                
                portfolioNameSet.add(portfolioName.Label);
                
                /* (portfolioName.Month_1_to_3_Option1_Tasks__c == True) {
                    
                    option1PortfolioNameSet.add(portfolioName.Label);
                }*/
            }
        }
        System.debug('portfolioList-->'+portfolioNameSet);
        
        List<Portfolio__c> portfolioList = [SELECT Id, Name FROM Portfolio__c WHERE NAME IN :portfolioNameSet];
        System.debug('portfolioList-->'+portfolioList);
        
        /*for (Portfolio__c portfolioInst : portfolioList) {
            
            if (option1PortfolioNameSet.contains(portfolioInst.Name)) {
                
                option1PortfolioIdSet.add(portfolioInst.Id);
            }
        }*/
        
        String query = 'SELECT Id, Attorney__c, NDS_CREATED_DATE__c, nu_dse__Program_Length__c, ACRs_Scheduled__c, CreatedDate, Portfolio__c FROM nu_dse__Program__c ' + 
                       'WHERE Portfolio__c IN :portfolioList AND RUN_PROCESSES_ON_IMPORT__c = True AND ' +
                       'ACRs_Scheduled__c = False AND RecordType.DeveloperName != \'DataTemp\' AND LastModifiedBy.Attorney_Admin__c = False'; 
                       
        if (programIds.isEmpty() == False) {
            query += ' AND Id IN :programIds';
        }             
        // testing Ids  AND Id IN (\'a0Lm0000003Aj8y\')--  AND Id IN (\'a0Lm0000003Ajq9\',\'a0Lm0000003Ai7X\', \'a0Lm0000003Aj8j\',\'a0Lm0000003Aj8y\',\'a0Lm0000003AjlE\')
        
        System.debug('AR Start Query-->'+query);   
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programScopeList) {
        
        List<Task> taskList = new List<Task>();
        List<nu_dse__Program__c> programToUpdate = new List<nu_dse__Program__c>();
        Map<String, Id> taskCommTempIds = new Map<String, Id> ();
        Map<String, Id> taskOwnerIdMap = new Map<String, Id> ();
        
        for (Task_Communication_Template__mdt CommTempCMDT : [SELECT Id, Label, DeveloperName, Communication_Template_Id__c FROM Task_Communication_Template__mdt]) {
        
            taskCommTempIds.put(CommTempCMDT.Label, CommTempCMDT.Communication_Template_Id__c);
        }
        
        for (Task_Owner_Id_Mapping__mdt taskOwnerIdInst : [SELECT Id, Label, Owner_Id__c FROM Task_Owner_Id_Mapping__mdt]) {
            
            taskOwnerIdMap.put(taskOwnerIdInst.Label, taskOwnerIdInst.Owner_Id__c);
        }
        
        System.debug('taskComm-->'+taskCommTempIds);
        
        Map<String, Process_For_Portfolio__mdt> portfolioNameAndItsFlow = new Map<String, Process_For_Portfolio__mdt>();
        Map<Id, Process_For_Portfolio__mdt> portfolioIdAndItsFlow = new Map<Id, Process_For_Portfolio__mdt>();
        
        String metaDataQuery = 'SELECT Id, Label, AR_Year1_Tasks__c, AR_Year2_Tasks__c, AR_Year3_Tasks__c, AR_Year4_Tasks__c, AR_Year5_Tasks__c, Month_1_to_3_Option1_Tasks__c FROM Process_For_Portfolio__mdt';
        
        for (Process_For_Portfolio__mdt portfolioMetaData : (List<Process_For_Portfolio__mdt >)JSON.deserialize(CustomMetadataGenerator.getCMDRecords(metaDataQuery), List<Process_For_Portfolio__mdt>.class)) {
            
            if (portfolioMetaData.AR_Year1_Tasks__c == True){
                //|| portfolioMetaData.AR_Year2_Tasks__c == True 
                //|| portfolioMetaData.AR_Year3_Tasks__c == True 
                //|| portfolioMetaData.AR_Year4_Tasks__c == True 
                //|| portfolioMetaData.AR_Year5_Tasks__c == True 
                //|| portfolioMetaData.Month_1_to_3_Option1_Tasks__c == True) { 
                portfolioNameAndItsFlow.put(portfolioMetaData.Label, portfolioMetaData);
            }
        }
        
        for (Portfolio__c portfolioInst : [SELECT Id, NAME FROM Portfolio__c WHERE NAME IN :portfolioNameAndItsFlow.keySet()]) {
            
            if (portfolioNameAndItsFlow.containsKey(portfolioInst.Name) == True) {
                
                portfolioIdAndItsFlow.put(PortfolioInst.Id, portfolioNameAndItsFlow.get(portfolioInst.Name));
            }
        }
        
        for (nu_dse__Program__c program : programScopeList) {
            
            Boolean entered = False;
            nu_dse__Program__c programInstance = new nu_dse__Program__c();
            programInstance.Id = program.Id;
            
            if (program.Portfolio__c != null && portfolioIdAndItsFlow.containsKey(program.Portfolio__c)) {
                
                Process_For_Portfolio__mdt portfolioMetaData = portfolioIdAndItsFlow.get(program.Portfolio__c);
            
                if (portfolioMetaData.AR_Year1_Tasks__c == True && program.ACRs_Scheduled__c == False) {
                    
                    taskList.addAll(FlowLogicsForBatchClass.createARFlow(program, taskCommTempIds, taskOwnerIdMap));
                    programInstance.ACRs_Scheduled__c = True;
                    programInstance.Run_First_Year_Workflow__c = True;
                    entered = True;
                }
                
                /*if (portfolioMetaData.AR_Year2_Tasks__c == True && program.nu_dse__Program_Length__c > 12 && program.YR2_ACRs_Scheduled__c == False){
                    
                    taskList.addAll(FlowLogicsForBatchClass.createYear2ARFlow(program, taskCommTempIds, taskOwnerIdMap));
                    programInstance.YR2_ACRs_Scheduled__c = True;
                    entered = True;
                }
                
                if (portfolioMetaData.AR_Year3_Tasks__c == True && program.nu_dse__Program_Length__c > 24 && program.YR3_ACRs_Scheduled__c == False) {
                    
                    taskList.addAll(FlowLogicsForBatchClass.createYear3ARFlow(program, taskCommTempIds, taskOwnerIdMap));
                    programInstance.YR3_ACRs_Scheduled__c = True;
                    entered = True;
                }
                
                if (portfolioMetaData.AR_Year4_Tasks__c == True && program.nu_dse__Program_Length__c > 36 && program.YR4_ACRs_Scheduled__c == False) {
                    
                    taskList.addAll(FlowLogicsForBatchClass.createYear4ARFlow(program, taskCommTempIds, taskOwnerIdMap));
                    programInstance.YR4_ACRs_Scheduled__c = True;
                    entered = True;
                }
                
                if (portfolioMetaData.AR_Year5_Tasks__c == True && program.nu_dse__Program_Length__c > 48 && program.YR5_ACRs_Scheduled__c == False) {
                    
                    taskList.addAll(FlowLogicsForBatchClass.createYear5ARFlow(program, taskCommTempIds, taskOwnerIdMap));
                    programInstance.YR5_ACRs_Scheduled__c = True;
                    entered = True;
                }
                
                if (portfolioMetaData.Month_1_to_3_Option1_Tasks__c == True && program.Month_1_to_3_Option_Tasks__c == False) {
                    
                    taskList.addAll(FlowLogicsForBatchClass.createOption1Task(program, taskCommTempIds, taskOwnerIdMap));
                    programInstance.Month_1_to_3_Option_Tasks__c = True;
                    entered = True;
                }*/
                
                if (entered == True) {
                    
                    programToUpdate.add(programInstance);
                }
            }
        }
        
        System.debug('taskList-->'+taskList);
        System.debug('taskList-->'+taskList.size());
        System.debug('programToUpdate-->'+programToUpdate);
        
        if (taskList.isEmpty() == False) {
            
            Database.insert(taskList, false);
        }
        
        //update program fields...
        Attorney_StaticVariableUtility.isProgramTriggerExecuted=true;
        update programToUpdate;
    }
     
    public void finish(Database.BatchableContext BC) {
        
        Database.executeBatch(new Batch_PauseAccountReviewFlows(), 10);
    }
}