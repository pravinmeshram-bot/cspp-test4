public class BatchDeleteAttorneyTasksAndRetrigger implements Database.Batchable<sObject> ,Database.stateful{ 
   
    public Boolean runProcessBuilders = False;
    
    Set<String> taskSubjectNameSet = new Set<String>{'Account Review One', 'Account Review Two', 'Account Review Three', 'On-Boarding Call Due', 'Strategy Call Due', 
                                                        'Account Review Twenty Eight', 'Account Review Five','Account Review Six', 'Account Review Seven', 
                                                        'Account Review Eight', 'Account Review Nine', 'Account Review Ten', 'Account Review Eleven', 
                                                        'Account Review Twelve', 'Account Review Thirteen', 'Account Review Fourteen','Account Review Fifteen', 
                                                        'Account Review Sixteen', 'Account Review Seventeen', 'Account Review Eighteen', 'Account Review Nineteen', 
                                                        'Account Review Twenty', 'Account Review Twenty One', 'Account Review Twenty Two', 
                                                        'Account Review Twenty Three', 'Account Review Twenty Four', 'Account Review Twenty Five', 
                                                        'Account Review Twenty Six', 'Account Review Twenty Seven', 'Account Review Twenty Eight', '7 Month Call Due',
                                                        'On-Boarding Call Due', 'Strategy Call Due', '30 Day AR', '60 Day AR', '90 Day AR', '150 Day AR','180 Day AR',
                                                        '210 Day AR','240 Day AR', '270 Day AR', '300 DAY AR','330 DAY AR','360 DAY AR','AR Y2Q1','AR Y2Q2','AR Y2Q3',
                                                        'AR Y2Q4',  'AR Y3Q1', 'AR Y3Q2', 'AR Y3Q3', 'AR Y3Q4', 'AR Y4Q1', 'AR Y4Q2', 'AR Y4Q3', 'AR Y4Q4', 'AR Y5Q1', 
                                                        'AR Y5Q2','AR Y5Q3','AR Y5Q4','MO 7 Call 1','MO 7 Call 2','MO 7 Call Due','OB Call 1','OB Call 2','OB Call Final', 
                                                        'Strat Call 1 Due', 'Strat Call 2 Due', 'Strat Call 3 Due', 'Final Strat Call Due', '3.5 Month Call 1 due', '3.5 Month Call 2 Due', 
                                                        '3.5 Month Call 3 Due', 'Final 3.5 Month Call Due', 'MO 1 Letter Due', 'MO 2 Letter Due', 'Mo 3 Letter Due', 
                                                        'Anniversary Mailer', 'Welcome Package Needed', 'Onboarding Call-Completed'};
                                                        
    Set<String> groupTaskSubjectSet = new Set<String> {'MO 1 Letter Due', 'MO 2 Letter Due', 'Mo 3 Letter Due', 'Anniversary Mailer', 'Welcome Package Needed'};
   
    public BatchDeleteAttorneyTasksAndRetrigger(Boolean reTriggerProcess) {
       
        runProcessBuilders = reTriggerProcess;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) { 

        String query = '';
        
        query += 'SELECT Id, ACRs_Scheduled__c, YR2_ACRs_Scheduled__c, YR3_ACRs_Scheduled__c, YR4_ACRs_Scheduled__c, ' +
                 'YR5_ACRs_Scheduled__c, First_Year_Workflow_Ran__c, RUN_PROCESSES_ON_IMPORT__c, Run_First_Year_Workflow__c  ' +
             'FROM nu_dse__Program__c WHERE Attorney__c = True';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programList) {
        
        Set<Id> programIdSet = new Set<Id>();
        List<nu_dse__Program__c> programUpdateList = new List<nu_dse__Program__c> ();
        
        
        System.debug('~`programList-->'+programList);
        
        for (nu_dse__Program__c programInstance :programList) {
            
            programIdSet.add(programInstance.Id);
            
            if (programInstance.RUN_PROCESSES_ON_IMPORT__c == True || programInstance.ACRs_Scheduled__c == True || programInstance.YR2_ACRs_Scheduled__c == True
                || programInstance.YR3_ACRs_Scheduled__c == True || programInstance.YR4_ACRs_Scheduled__c == True || programInstance.YR5_ACRs_Scheduled__c == True
                || programInstance.First_Year_Workflow_Ran__c == True || programInstance.Run_First_Year_Workflow__c == True ) {
                
                programInstance.ACRs_Scheduled__c = False;
                programInstance.YR2_ACRs_Scheduled__c = False;
                programInstance.YR3_ACRs_Scheduled__c = False;
                programInstance.YR4_ACRs_Scheduled__c = False;
                programInstance.YR5_ACRs_Scheduled__c = False;
                programInstance.First_Year_Workflow_Ran__c = False;
                programInstance.RUN_PROCESSES_ON_IMPORT__c = False;
                programInstance.Run_First_Year_Workflow__c = False;
                programUpdateList.add(programInstance);
            }
        }
        
        List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, nu_dse__Related_To__c FROM nu_dse__Group_Task__c 
                                                        WHERE nu_dse__Related_To__c In :programIdSet AND nu_dse__Subject__c IN :groupTaskSubjectSet
                                                        AND nu_dse__ActivityDate__c >= Today
                                                        AND nu_dse__Status__c <> 'Completed'];
        
        List<Task> taskList = [SELECT Id, WhatId FROM Task WHERE WhatId In :programIdSet AND Subject IN :taskSubjectNameSet AND ActivityDate >= Today AND Status <> 'Completed'];
        
        System.debug('groupTaskList-->'+groupTaskList);
        System.debug('taskList-->'+taskList);
        
        if (groupTaskList.isEmpty() == False) {
            
            delete groupTaskList;
        }
        
        if (taskList.isEmpty() == False) {
            
            delete taskList;
        }
        
        //To Retrigger the process builder...
        if (runProcessBuilders == True) {
            
            if (programUpdateList.isEmpty() == False) {
            
                update programUpdateList;
            }
            
            Datetime currentTime = System.now();
            System.debug('CurrentTime-->'+currentTime);
            
            for (nu_dse__Program__c programInstance :programList) {
                
                programInstance.RUN_PROCESSES_ON_IMPORT__c = True;
                programInstance.Run_First_Year_Workflow__c = True;
                
            }
            
            Database.SaveResult[] programUpdateResultList = Database.update(programList, false);
            
            Set<String> errorMessage = new Set<String>();
            
            for (Database.SaveResult sr : programUpdateResultList) {
                                            
                if (sr.isSuccess() == False) {
                    
                    for(Database.Error err : sr.getErrors()) {
                    
                        errorMessage.add(err.getMessage());
                        System.debug('errorMessage-->'+errorMessage);
                    }
                }
            }
            
            if (errorMessage.isEmpty() == False) {
                
                nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'BatchDeleteAttorneyTasksAndRetrigger_Execute', nu_dse__User_Context__c = UserInfo.getUserId());
                errorLog.nu_dse__Message__c = '';
                
                for (String emsg : errorMessage) {
                    
                    errorLog.nu_dse__Message__c += emsg;
                }
                insert errorLog;
            }
        }
    } 
    
    public void finish(Database.BatchableContext BC) { 
        
        
    }
}