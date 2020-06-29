public class GroupTaskHandler{
        
        //S20-88 ****Starts**** ~ Developed on Sept 09, 2019 : To reassign the Group Tasks to Program Owner while assigning to Negotiations Associate.
        public static void replaceGroupTaskOwner(List<nu_dse__Group_Task__c> groupTaskList, Map<Id, nu_dse__Group_Task__c> oldGroupTaskMap) {
        
        List<nu_dse__Group_Task__c> filteredGroupTasks = new List<nu_dse__Group_Task__c>();
        Set<Id> programIds = new Set<Id>();
        
        if (groupTaskList.isEmpty() == False) {
        
        String program_prefix = Schema.SObjectType.nu_dse__Program__c.getKeyPrefix();
        
        for (nu_dse__Group_Task__c groupTask : groupTaskList) {
        
        if (String.isNotBlank(groupTask.nu_dse__Related_To__c) && groupTask.nu_dse__Related_To__c.startsWith(program_prefix)
        && (Trigger.isInsert || (Trigger.isUpdate && oldGroupTaskMap != NULL 
        && oldGroupTaskMap.get(groupTask.Id).OwnerId != groupTask.OwnerId))
        && groupTask.Owner_Name__c == 'Negotiations Associate' && groupTask.nu_dse__Status__c != 'Completed'
        && groupTask.nu_dse__Status__c != 'Canceled') {
        
        filteredGroupTasks.add(groupTask);
        programIds.add(groupTask.nu_dse__Related_To__c);
        }
        }
        System.debug('filteredGroupTasks------>'+filteredGroupTasks);
        System.debug('programIds------>'+programIds);
        
        if (filteredGroupTasks.isEmpty() == False && programIds.isEmpty() == False) {
        
        Map<Id, nu_dse__Program__c> programMap = new Map<Id, nu_dse__Program__c>([SELECT Id, OwnerId FROM nu_dse__Program__c 
                                                                      WHERE Id IN :programIds]);
        
        for (nu_dse__Group_Task__c groupTask : filteredGroupTasks) {
        
        groupTask.OwnerId = programMap.get(groupTask.nu_dse__Related_To__c).OwnerId;                   
        }
        }    
        }               
        }
        //S20-88 ****Ends****
        
        //S20-577 ****Starts****
        
        public static void populateExcelaTradline(List<nu_dse__Group_Task__c> groupTaskList) 
        {
            List<nu_dse__Group_Task__c> GT = new List<nu_dse__Group_Task__c>();
            Set<Id> programIds = new Set<Id>();
        
        
        if (groupTaskList.isEmpty() == False) 
        
        {
        
             String program_prefix = Schema.SObjectType.nu_dse__Program__c.getKeyPrefix();
        
             for (nu_dse__Group_Task__c GT_Task : groupTaskList) 
             {
                if (String.isNotBlank(GT_Task.nu_dse__Related_To__c) && GT_Task.nu_dse__Related_To__c.startsWith(program_prefix))
                {
                    GT.add(GT_Task);
                    programIds.add(GT_Task.nu_dse__Related_To__c);
                }
                System.debug('GT------>'+GT);
                System.debug('programIds------>'+programIds);
            }
            if (programIds.isEmpty() == False) 
            {
        
                Map<Id, nu_dse__Program__c> programMapForGrptask = new Map<Id, nu_dse__Program__c>([SELECT Id,Excela_Tradeline__c 
                                                                                                    FROM nu_dse__Program__c 
                                                                                                    WHERE Id IN :programIds]);
                List<nu_dse__Program__c> programListToUpdate = new List<nu_dse__Program__c>() ;
                Set<String> tradelineName = new Set<String> () ;
                for(nu_dse__Program__c progmObj : programMapForGrptask.values()){
                    if(String.isNotBlank(progmObj.Excela_Tradeline__c)) {
                        tradelineName.add(progmObj.Excela_Tradeline__c) ;
                    }
                }
                Map<String, nu_dse__Tradeline__c> tradelinemap = new Map<String, nu_dse__Tradeline__c>();
                for(nu_dse__Tradeline__c tradeLineObj :[Select Id,Name,Exela_Current_Balance__c,Exela_Offer_Amount__c from nu_dse__Tradeline__c where name In :tradelineName]){
                    tradelinemap.put(tradeLineObj.Name, tradeLineObj) ;
                }
                
                for (nu_dse__Group_Task__c GT_Task : GT)
                {
                    if(programMapForGrptask.get(GT_Task.nu_dse__Related_To__c).Excela_Tradeline__c != Null
                      && tradelinemap.get(programMapForGrptask.get(GT_Task.nu_dse__Related_To__c).Excela_Tradeline__c) != null)
                    {
                    //Convert excela tradeline name into Record id
                    String tradeLineId = tradelinemap.get(programMapForGrptask.get(GT_Task.nu_dse__Related_To__c).Excela_Tradeline__c).Id ;
                     GT_Task.Exela_Current_Balance__c = tradelinemap.get(programMapForGrptask.get(GT_Task.nu_dse__Related_To__c).Excela_Tradeline__c).Exela_Current_Balance__c;
                     GT_Task.Exela_Offer_Amount__c = tradelinemap.get(programMapForGrptask.get(GT_Task.nu_dse__Related_To__c).Excela_Tradeline__c).Exela_Offer_Amount__c;
                     GT_Task.Excela_Tradeline__c = tradeLineId;  
                     programListToUpdate.add(new nu_dse__Program__c(
                         Id = programMapForGrptask.get(GT_Task.nu_dse__Related_To__c).Id ,
                         Excela_Tradeline__c = '' 
                     )) ;
                                      
                    }
                }  
                if(!programListToUpdate.isEmpty()) {
                     update programListToUpdate ;
                }
           }
        
        
        }
        
        }
        //****S20-577 ENDS****
        
        }