/***********************************************************************
Modification History
*1.0    08-04-2020    Praveen       ND-331 Changes

*************************************************************************/


public class TaskHandler_PopulateProgram {
    
    private static final STRING PROGRAM_OBJ_NAME = 'nu_dse__Program__c' ;
    
    public static void populatePrograme(List<Task> newTaskList){
        for (Task T : newTaskList) 
        {
            String str;
            str = T.WhatId ;
            
            System.debug('str  ' + str) ;
            if(String.isNotBlank(T.WhatId) && PROGRAM_OBJ_NAME.equalsIgnoreCase(String.valueOf(T.WhatId.getSObjectType())) && String.isBlank(T.Program__c)) {
                System.debug('program blank') ;
                T.Program__c = T.WhatId;
                System.debug('Test '+T.Program__c) ;
            }
            
        }
    }
    // ND-274
    public static void makeIsNoteTrue(List<task> taskList){
        
        List<String> dispositionList= new List<String>();
        List<Schema.PicklistEntry> ple = nu_dse__Program__c.nu_dse__Disposition__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple)
        {
            dispositionList.add(pickListVal.getLabel());
        }
        system.debug('### dispositionList: '+dispositionList);
        
        for(Task sub: taskList)  
        {
           
           
            for(String dispositionStr: dispositionList)
            {
                if(sub.Subject != null && sub.Subject.contains(': Follow Up') ){
                    sub.IsNote__c=false;
                    break;
                }
                else if(sub.Subject != null && sub.Subject.contains(dispositionStr) && sub.Status == 'Completed' )
                {
                system.debug('subject'+sub.Subject);
                  sub.IsNote__c=true;
                  // sub.Channel_Name__c = grpTask;
                    break;
                }                
            }
          
    }
    }
    
    
    /* Start - ND-331 : Moving the "Send client survey mail" process builder to Code/trigger */
    public static boolean isExecute = true;
    public static void sendClientSurveyEmail(List<task> taskList){
        
        if(isExecute){
            List<task> updateTaskList = new List<task>();
            set<id> prgmIds = new set<id>();
            For(task taskInstance : taskList){
                if(taskInstance.Supplemental__c == 'Sent Client Survey'){
                    if(taskInstance.Program__c == null){
                        task thetask = new task();
                        thetask.id = taskInstance.id;
                        thetask.Program__c = taskInstance.WhatId;
                        updateTaskList.add(thetask);
                        prgmIds.add(thetask.Program__c);
                    }else{
                        prgmIds.add(taskInstance.Program__c);
                    }
                }
            }
            
            if(!updateTaskList.isEmpty()){
                update updateTaskList;
            }
            
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
             
            if(prgmIds.size()>0){
                
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                Map<String,id> tempMapSurvey = new Map<String,Id>(); // Prepare Template Map to process logic  dynamically
                Map<String,id> orgEmailMapSurvey = new Map<String,id>(); // Prepare OrgWideEmailAddress Map to process logic  dynamically
                Map<String, PortfolioAndRetentionEmailMapping__mdt>  metadataMapSurvey = new Map<String, PortfolioAndRetentionEmailMapping__mdt>(); // prepare custom metadata Map to process logic dynamically
                Map<id,id> targetObjIdMap = new Map<id,id>();  // Prepare targetObjectId to send single email message
                
                For(PortfolioAndRetentionEmailMapping__mdt portfolioMetadata : [select id,MasterLabel, From_Email_for_Refer_to_BK__c , Template_Name_for_Survey_Email__c , isSendClient_SurveyEmail__c from PortfolioAndRetentionEmailMapping__mdt where isSendClient_SurveyEmail__c = true]){
                    portfolioMetadata.MasterLabel = portfolioMetadata.MasterLabel.toLowerCase();
                    metadataMapSurvey.put(portfolioMetadata.MasterLabel,portfolioMetadata );
                    tempMapSurvey.put(portfolioMetadata.Template_Name_for_Survey_Email__c ,null);
                    orgEmailMapSurvey.put(portfolioMetadata.From_Email_for_Refer_to_BK__c,null);
                }
                system.debug('===Map==='+metadataMapSurvey);
                system.debug('===Map==='+tempMapSurvey);
                system.debug('===Map==='+orgEmailMapSurvey);
                
                // Get all required templates
                if(tempMapSurvey.KeySet().size()>0){
                    for(EmailTemplate temp : [select Id, Name FROM EmailTemplate WHERE Name IN: tempMapSurvey.KeySet()]){
                        tempMapSurvey.put(temp.Name,temp.id);
                    }
                }
                system.debug('===after==='+tempMapSurvey);
                // get all required FROM email ids
                if(orgEmailMapSurvey.KeySet().size()>0){
                    for(OrgWideEmailAddress orgEmail : [select Id,Address from OrgWideEmailAddress where Address IN: orgEmailMapSurvey.KeySet()]){
                        orgEmailMapSurvey.put(orgEmail.Address,orgEmail.id);
                    }
                }
                system.debug('===after==='+orgEmailMapSurvey);
                
                 List<id> accIds = new List<id>(); // collect account ids
                 List<nu_dse__Program__c> prgm_list = new List<nu_dse__Program__c>();
                for(nu_dse__Program__c prgmRec: [select id,nu_dse__Account__c,Portfolio__r.Name,ClientEmail__c from nu_dse__Program__c where id IN:prgmIds]){
                     accIds.add(prgmRec.nu_dse__Account__c);
                     prgm_list.add(prgmRec);
                }
            
                if(accIds.size()>0){
                    for(Contact con : [select id, accountId from Contact where accountId IN:accIds]){
                        targetObjIdMap.put(con.accountId, con.id);
                    }
                }
                system.debug('===con map==='+targetObjIdMap); 
                
                for(nu_dse__Program__c prgmIns : prgm_list){
                system.debug('==========='+metadataMapSurvey.containsKey(prgmIns.Portfolio__r.Name.toLowerCase()) + '=============='+prgmIns.Portfolio__r.Name.toLowerCase());
                    if(metadataMapSurvey.containsKey(prgmIns.Portfolio__r.Name.toLowerCase()) && prgmIns.ClientEmail__c != null){
                        emailMsg = ProgramTriggerHandler.sendRetentionEmail(prgmIns.id, tempMapSurvey.get(metadataMapSurvey.get(prgmIns.Portfolio__r.Name.toLowerCase()).Template_Name_for_Survey_Email__c), prgmIns.ClientEmail__c , targetObjIdMap.get(prgmIns.nu_dse__Account__c), orgEmailMapSurvey.get(metadataMapSurvey.get(prgmIns.Portfolio__r.Name.toLowerCase()).From_Email_for_Refer_to_BK__c ));
                        emailList.add(emailMsg);
                    }
                } 
                  system.debug('==========='+emailList);
                  
                if(emailList.size()>0){
                      try{
                         results = Messaging.sendEmail(emailList);
                         TaskHandler_PopulateProgram.isExecute = false;
                         }catch(Exception ex){
                             system.debug('===Exception==='+ex.getMessage());
                         }
                 } 
            }
            
        }
            
    }
    // ND-331 End
    
  
}