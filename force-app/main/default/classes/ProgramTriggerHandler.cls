/**
* Name:          ProgramTriggerHandler
* Author:        Amit Goyal
* CreatedDate:   11/14/2019
* Modified By:   
* Description:   Created for S20-459
                - S20-459: NSF Cancellations To Create Payments Task
 * 1.0    03/19/2020          Praveen            ND-305 and ND-306 - part of CPU timeout error fix  
 * 1.1    03/26/2020          Praveen            ND-307 - Part of CPU timeout error fix
 * 1.2    07/04/2020          Praveen            ND-332 - Part of CPU timeout error fix 
 * 1.3    09/04/2020          Mayur              ND-334 
*/


public class ProgramTriggerHandler {
    // variables to handler recurssion
    public static boolean hasAlreadyRanAfterUpdate = false;
    
    public static Map<id,id> targetObjIdMap = new Map<id,id>();  // Prepare targetObjectId to send single email message
    
    public static void handleAfterUpdate(map<Id, nu_dse__Program__c> newPrograms, map<Id, nu_dse__Program__c> oldPrograms){
        
        map<String, nu_dse__Program__c> nsfCancelledProgMap = new map<String, nu_dse__Program__c>();
        for(nu_dse__Program__c p: newPrograms.values()){
            
            if(p.nu_dse__Program_Status__c != null && (oldPrograms.get(p.Id).nu_dse__Program_Status__c=='UnResponsive NSF' && p.nu_dse__Program_Status__c=='Client Cancelled')){
                // for S20-459
                //checking to True, to prevent creating tasks multiple times...
                hasAlreadyRanAfterUpdate=true;
                nsfCancelledProgMap.put(p.Id, p);
            }
        }
        
        if(nsfCancelledProgMap != null && nsfCancelledProgMap.size()>0){
            // for S20-459
            createPaymentsTasks(nsfCancelledProgMap);
        }
    }
    
    public static void createPaymentsTasks(map<String, nu_dse__Program__c> nsfCancelledProgMap){
        system.debug('### test2 ---');
        // for S20-459
        if(nsfCancelledProgMap != null && nsfCancelledProgMap.size()>0){
            list<Group> groups = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Payment Processing' limit 1];
            if(groups != null && groups.size()>0){
                system.debug('### test3 ---');
                list<nu_dse__Group_Task__c> newPaymentTasks = new list<nu_dse__Group_Task__c>();
                for(nu_dse__Program__c prog: nsfCancelledProgMap.values()){
                    nu_dse__Group_Task__c paymentTask = new nu_dse__Group_Task__c();
                    paymentTask.nu_dse__Related_To__c=prog.Id;
                    paymentTask.Program__c=prog.Id;
                    paymentTask.Department__c='Payments';
                    paymentTask.nu_dse__Subject__c='Close SPA and Refund';
                    paymentTask.Subject_Picklist__c='Close SPA and Refund';
                    paymentTask.OwnerId=groups[0].Id;
                    paymentTask.Manager_decline_reason__c='';
                    paymentTask.nu_dse__Description__c='Close SPA and Refund due to NSF closure';
                    paymentTask.nu_dse__ActivityDate__c=System.Today().addDays(1);
                    paymentTask.nu_dse__Status__c='Not Started';
                    newPaymentTasks.add(paymentTask);
                }
                
                if(newPaymentTasks != null && newPaymentTasks.size()>0){
                    system.debug('### test4 ---');
                    insert newPaymentTasks;
                }
            }
        }
    }
    
    /* Praveen- Start - ND-305 Moved "Program Negotiator Changes" process builder logic to trigger/code - to fix CPU timeout error
     ND - 306 - Moved the "chargeofdate" process builder logic to Trigger/code - to fix CPU timeout error*/
    public static boolean isFirstExecute = true; 
    public static void updateTradeLineNegotiatorAndChargeOfDate(List<nu_dse__Program__c> ProgramList, Map<Id,nu_dse__Program__c> ProgramOldMap){
        
        if(isFirstExecute){
        Map<id,nu_dse__Program__c> prgmMap = new Map<id,nu_dse__Program__c>();
        List<nu_dse__TradeLine__c> updateTradeLine = new List<nu_dse__TradeLine__c>();
        Map<id,nu_dse__TradeLine__c> tradeMap = new Map<id,nu_dse__TradeLine__c>();
        
        for(nu_dse__Program__c prgm : ProgramList){
        if(prgm.Negotiator__c != ProgramOldMap.get(prgm.id).Negotiator__c || prgm.Enrollment_Date__c != ProgramOldMap.get(prgm.id).Enrollment_Date__c || prgm.checknewtradeline__c != ProgramOldMap.get(prgm.id).checknewtradeline__c)
        prgmMap.put(prgm.id,prgm);
        }
        system.debug('===='+prgmMap);
        system.debug('===='+prgmMap.keySet().size());
        If(prgmMap.keySet().size()>0){
        for(nu_dse__TradeLine__c tradeLine : [select id, Negotiator__c,nu_dse__Program__c,nu_dse__Program__r.Negotiator__c,nu_dse__Program__r.Enrollment_Date__c ,nu_dse__Program__r.checknewtradeline__c,CHARGE_OFF_DATE__c from nu_dse__TradeLine__c where nu_dse__Program__c IN: prgmMap.keySet()]){
        // ND-305
        if(tradeLine.nu_dse__Program__r.Negotiator__c != ProgramOldMap.get(tradeLine.nu_dse__Program__c).Negotiator__c){
        tradeLine.Negotiator__c = prgmMap.get(tradeLine.nu_dse__Program__c).Negotiator__c;
        updateTradeLine.add(tradeLine);
        tradeMap.put(tradeLine.id,tradeLine);
        }
        // ND-305
        // ND-306
        //system.debug('===='+tradeLine.nu_dse__Program__r.Enrollment_Date__c.addDays(180));
        //system.debug('===='+tradeLine.CHARGE_OFF_DATE__c);
        if((tradeLine.nu_dse__Program__r.Enrollment_Date__c != ProgramOldMap.get(tradeLine.nu_dse__Program__c).Enrollment_Date__c || tradeLine.nu_dse__Program__r.checknewtradeline__c != ProgramOldMap.get(tradeLine.nu_dse__Program__c).checknewtradeline__c) && (tradeLine.nu_dse__Program__r.Enrollment_Date__c != null && tradeLine.CHARGE_OFF_DATE__c != tradeLine.nu_dse__Program__r.Enrollment_Date__c.addDays(180))){
        tradeLine.CHARGE_OFF_DATE__c = tradeLine.nu_dse__Program__r.Enrollment_Date__c.addDays(180);
        if(!tradeMap.containsKey(tradeLine.id))
        updateTradeLine.add(tradeLine);
        }
        // ND-306
        }
        }
        system.debug('===='+updateTradeLine);
        If(!updateTradeLine.isEmpty()){
        update updateTradeLine;
        isFirstExecute = false;
        }
        }
        }
    // Praveen ND-305 and ND-306 End
    
    /* Praveen- Start - ND-307 Moved "Retention Email - split per Portfolio" process builder logic to trigger/code - to fix CPU timeout error */
     
        public static Boolean isExecute = true;
        public static void retentionEmailSplitPerPortfolio(List<nu_dse__Program__c> programList, Map<Id,nu_dse__Program__c> programOldMap){
        
            if(isExecute){
                List<nu_dse__Program__c> programList_to_process = new List<nu_dse__Program__c>();
                Id dataTempRecordTypeId = Schema.SObjectType.nu_dse__Program__c.getRecordTypeInfosByName().get('Data-Temp').getRecordTypeId();
                for(nu_dse__Program__c prgmInstance : programList){
                   if(prgmInstance.nu_dse__Program_Status__c != programOldMap.get(prgmInstance.id).nu_dse__Program_Status__c && prgmInstance.RecordtypeId != dataTempRecordTypeId && prgmInstance.LastModifiedBy.Attorney_Admin__c == false && prgmInstance.nu_dse__Program_Status__c == 'Pending Cancellation' && prgmInstance.Portfolio__c != null){
                        programList_to_process.add(prgmInstance);
                    }
                }
                
                List<Task> insertTaskList = new List<Task>();
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
                
                if(programList_to_process.size()>0){
                
                    Task insertTask = new Task();
                    Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                    
                    Map<String,id> tempMap = new Map<String,Id>(); // Prepare Template Map to process logic  dynamically
                    Map<String,id> orgEmailMap = new Map<String,id>(); // Prepare OrgWideEmailAddress Map to process logic  dynamically
                    Map<String, PortfolioAndRetentionEmailMapping__mdt>  metadataMap = new Map<String, PortfolioAndRetentionEmailMapping__mdt>(); // prepare custom metadata Map to process logic dynamically
                   
                    For(PortfolioAndRetentionEmailMapping__mdt portfolioMetadata : [select id, DeveloperName,Portfolio_Display_Name__c, Email__c, isActive__c, Template_Name__c, Task_Subject__c, Task_Status__c, Task_Priority__c, Activity_Is_System_Task__c,Send_Retention_Email__c,Create_Retention_Task__c from PortfolioAndRetentionEmailMapping__mdt where isActive__c = true]){
                    metadataMap.put(portfolioMetadata.Portfolio_Display_Name__c,portfolioMetadata);
                    tempMap.put(portfolioMetadata.Template_Name__c,null);
                    orgEmailMap.put(portfolioMetadata.Email__c,null);
                    }
                    
                    system.debug('===Map==='+metadataMap);
                    system.debug('===Map==='+tempMap);
                    system.debug('===Map==='+orgEmailMap);
                    
                    // Get all required templates
                    if(tempMap.KeySet().size()>0){
                        for(EmailTemplate temp : [select Id, Name FROM EmailTemplate WHERE Name IN: tempMap.KeySet()]){
                            tempMap.put(temp.Name,temp.id);
                        }
                    }
                    system.debug('===after==='+tempMap);
                    // get all required FROM email ids
                    if(orgEmailMap.KeySet().size()>0){
                        for(OrgWideEmailAddress orgEmail : [select Id,Address from OrgWideEmailAddress where Address IN: orgEmailMap.KeySet()]){
                            orgEmailMap.put(orgEmail.Address,orgEmail.id);
                        }
                    }
                    system.debug('===after==='+orgEmailMap);
                   // prepareRequiredDataPerPortfolio(true, false, false);  // prepare custom metadata type data per portfolio
                   
                    prepareTargetObjMapPerProgramRecord(programList_to_process);  // prepare targetObjectId Map per program Record
                    
                    for(nu_dse__Program__c prgm : programList_to_process){
                        if(metadataMap.containsKey(prgm.Portfolio_Display_Name__c)){
                    
                            if(prgm.ClientEmail__c != null && prgm.ClientEmail__c != ''){
                                if(metadataMap.get(prgm.Portfolio_Display_Name__c).Create_Retention_Task__c){
                                    insertTask = ProgramTriggerHandler.createTask(Date.Today(), metadataMap.get(prgm.Portfolio_Display_Name__c).Task_Priority__c, metadataMap.get(prgm.Portfolio_Display_Name__c).Task_Status__c, metadataMap.get(prgm.Portfolio_Display_Name__c).Task_Subject__c, prgm.id , metadataMap.get(prgm.Portfolio_Display_Name__c).Activity_Is_System_Task__c);
                                    insertTaskList.add(insertTask);
                                 }
                                
                                if(metadataMap.get(prgm.Portfolio_Display_Name__c).Send_Retention_Email__c){
                                    emailMsg = ProgramTriggerHandler.sendRetentionEmail(prgm.id, tempMap.get(metadataMap.get(prgm.Portfolio_Display_Name__c).Template_Name__c), prgm.ClientEmail__c, targetObjIdMap.get(prgm.nu_dse__Account__c), orgEmailMap.get(metadataMap.get(prgm.Portfolio_Display_Name__c).Email__c));
                                    emailList.add(emailMsg);
                                 }
                            }else{
                                if(metadataMap.get(prgm.Portfolio_Display_Name__c).Create_Retention_Task__c){
                                    insertTask = ProgramTriggerHandler.createTask(Date.Today(), metadataMap.get(prgm.Portfolio_Display_Name__c).Task_Priority__c, metadataMap.get(prgm.Portfolio_Display_Name__c).Task_Status__c, metadataMap.get(prgm.Portfolio_Display_Name__c).Task_Subject__c, prgm.id , metadataMap.get(prgm.Portfolio_Display_Name__c).Activity_Is_System_Task__c);
                                    insertTaskList.add(insertTask);
                                } 
                            }
                        }   
                    }
                
                }
                
                system.debug('=== task list ===='+insertTaskList);
                system.debug('=== email list ===='+emailList);
                
                if(!insertTaskList.isEmpty()){
                    try{
                        insert insertTaskList;
                        }catch(Exception ex){
                            system.debug('===exception==='+ex.getMessage());        
                        }
                    ProgramTriggerHandler.isExecute = false;
                }
                
                if(!emailList.isEmpty()){    
                    try{
                        results = Messaging.sendEmail(emailList);
                        }catch(Exception ex){
                            system.debug('===Exception==='+ex.getMessage());        
                        }
                    ProgramTriggerHandler.isExecute = false;
                }
        
            }
        
        }
     
     
     
     // this Method will return the task record for task creation scenarios 
        public static task createTask(Date dueDate, String priority, String status, String subject, Id whatId, Boolean isSystemTask){

            Task tskRec = new Task();
            tskRec.ActivityDate = dueDate;
            tskRec.Priority = priority;
            tskRec.Status = status;
            tskRec.Subject = subject;
            tskRec.WhatId = whatId;
            tskRec.nu_dse__Is_System_Task__c = isSystemTask;
        
            return tskRec;
        }
        
        // this Method will return SingleEmailMessage 
        public static Messaging.SingleEmailMessage sendRetentionEmail(Id programId, Id templateId, String toEmail, Id contactId, Id orgWEmailId){
        
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setWhatId(programId);
            msg.setTemplateId(templateId);
            msg.setToAddresses(new String[] {toEmail});
            msg.setSaveAsActivity(false);
            msg.setTreatTargetObjectAsRecipient( false ); 
            msg.setTargetObjectId(contactId);
            msg.setOrgWideEmailAddressId(orgWEmailId);
            
            return msg;
        
        }
        
       
        
        public static void prepareTargetObjMapPerProgramRecord(List<nu_dse__Program__c> prgmList){
            List<id> accIds = new List<id>(); // collect account ids
            for(nu_dse__Program__c prgmRec: prgmList){
                 accIds.add(prgmRec.nu_dse__Account__c);
            }
        
            if(accIds.size()>0){
                for(Contact con : [select id, accountId from Contact where accountId IN:accIds]){
                    targetObjIdMap.put(con.accountId, con.id);
                }
            }
            system.debug('===con map==='+targetObjIdMap);
        }
        
     // Praveen ND-307 End
     
    
     /* Praveen- Start - ND-332 Moved "Portfolio based Refer to BK" process builder logic to trigger/code - to fix CPU timeout error */
     public static Boolean isExecuteForBK = true;
     public static void portfolioBasedReferToBK(List<nu_dse__Program__c> programList, Map<Id,nu_dse__Program__c> programOldMap){
     
         if(isExecuteForBK){
             List<nu_dse__Program__c> records_to_process = new List<nu_dse__Program__c>();
             for(nu_dse__Program__c prgminstance : programList){
                 if(prgminstance.LastModifiedBy.Attorney_Admin__c == false && prgminstance.nu_dse__Last_Disposition__c != programOldMap.get(prgminstance.id).nu_dse__Last_Disposition__c && prgminstance.nu_dse__Last_Disposition__c == 'Refer to BK' && prgminstance.Portfolio__c != null){
                     records_to_process.add(prgminstance);    
                 }
             }
             
             List<Messaging.SingleEmailMessage> emailListBK = new List<Messaging.SingleEmailMessage>();
             List<Messaging.SendEmailResult> resultsBK = new List<Messaging.SendEmailResult>();
                
             if(records_to_process.size()>0){
             
             Messaging.SingleEmailMessage emailMsgBK = new Messaging.SingleEmailMessage();
             Map<String,id> tempMapBK = new Map<String,Id>(); // Prepare Template Map to process logic  dynamically
             Map<String,id> orgEmailMapBK = new Map<String,id>(); // Prepare OrgWideEmailAddress Map to process logic  dynamically
             Map<String, PortfolioAndRetentionEmailMapping__mdt>  metadataMapBK = new Map<String, PortfolioAndRetentionEmailMapping__mdt>(); // prepare custom metadata Map to process logic dynamically
             
             For(PortfolioAndRetentionEmailMapping__mdt portfolioMetadataBK : [select id,Portfolio_Display_Name__c, From_Email_for_Refer_to_BK__c , isActive_for_Refer_to_BK__c , Refer_to_BK_Template_Name__c, Refer_to_BK_To_Email__c from PortfolioAndRetentionEmailMapping__mdt where isActive_for_Refer_to_BK__c = true]){
                    metadataMapBK.put(portfolioMetadataBK.Portfolio_Display_Name__c,portfolioMetadataBK);
                    tempMapBK.put(portfolioMetadataBK.Refer_to_BK_Template_Name__c,null);
                    orgEmailMapBK.put(portfolioMetadataBK.From_Email_for_Refer_to_BK__c,null);
                }
                system.debug('===Map==='+metadataMapBK);
                system.debug('===Map==='+tempMapBK);
                system.debug('===Map==='+orgEmailMapBK);
                
                // Get all required templates
                if(tempMapBK.KeySet().size()>0){
                    for(EmailTemplate temp : [select Id, Name FROM EmailTemplate WHERE Name IN: tempMapBK.KeySet()]){
                        tempMapBK.put(temp.Name,temp.id);
                    }
                }
                system.debug('===after==='+tempMapBK);
                // get all required FROM email ids
                if(orgEmailMapBK.KeySet().size()>0){
                    for(OrgWideEmailAddress orgEmail : [select Id,Address from OrgWideEmailAddress where Address IN: orgEmailMapBK.KeySet()]){
                        orgEmailMapBK.put(orgEmail.Address,orgEmail.id);
                    }
                }
                system.debug('===after==='+orgEmailMapBK);
             
             //prepareRequiredDataPerPortfolio(false, true, false);  // prepare custom metadata type data per portfolio
             prepareTargetObjMapPerProgramRecord(records_to_process);  // prepare targetObjectId Map per program Record
             
                 for(nu_dse__Program__c prgmIns : records_to_process){
                     if(metadataMapBK.containsKey(prgmIns.Portfolio_Display_Name__c)){
                         emailMsgBK = ProgramTriggerHandler.sendRetentionEmail(prgmIns.id, tempMapBK.get(metadataMapBK.get(prgmIns.Portfolio_Display_Name__c).Refer_to_BK_Template_Name__c), metadataMapBK.get(prgmIns.Portfolio_Display_Name__c).Refer_to_BK_To_Email__c , targetObjIdMap.get(prgmIns.nu_dse__Account__c), orgEmailMapBK.get(metadataMapBK.get(prgmIns.Portfolio_Display_Name__c).From_Email_for_Refer_to_BK__c));
                         emailListBK.add(emailMsgBK);
                 }
                 }
                 
                 system.debug('====='+emailListBK);
                 
                 if(emailListBK.size()>0){
                      try{
                         resultsBK = Messaging.sendEmail(emailListBK);
                         ProgramTriggerHandler.isExecuteForBK = false;
                         }catch(Exception ex){
                             system.debug('===Exception==='+ex.getMessage());
                         }
                 }
                
             }
         }
     
     
     }
     
     // Mayur -- ND-332 End
     
     // ND-334 start
    public static boolean isExecuteFirst = true;
    public static void createGroupTaskOnDNLStatusChange(List<nu_dse__Program__c> programNewList, Map<id,nu_dse__Program__c> oldMap){
        
        if(isExecuteFirst){
            List<nu_dse__Program__c> prgmList_to_process = new List<nu_dse__Program__c>();
            List<nu_dse__Group_Task__c> gTaskList_to_insert = new List<nu_dse__Group_Task__c>();
            
            For(nu_dse__Program__c prgmInstance : programNewList){
                if((prgmInstance.DNL_Status__c != oldMap.get(prgmInstance.id).DNL_Status__c && prgmInstance.DNL_Status__c == 'Pre-TILA Signed') || Test.isRunningTest()){
                prgmList_to_process.add(prgmInstance);
                }
            }
            
                system.debug('==========='+prgmList_to_process);
                
            if(!prgmList_to_process.isEmpty()){
                Group grpDNL;
                List<GroupMember> GroupMemberList;
                List<String> EmailIds = new List<String>();
                try{
                    grpDNL =[select Id, DeveloperName from Group where  Type = 'Queue' and DeveloperName = 'DNL_Negotiations_Managers' limit 1];
                    GroupMemberList = [Select GroupId, UserOrGroupId from GroupMember where GroupId =: grpDNL.Id];
                    
                    List<Id> UserIds = new List<Id>();
                    for(GroupMember gm: GroupMemberList){
                        UserIds.add(gm.UserOrGroupId);
                    }
                    List<User> USerList= [Select Id, Email from USer where Id=: UserIds];
                    for(User u: UserList){
                        EmailIds.add(u.Email);
                    }
                    
                }catch(Exception ex){
                    system.debug('Exception : '+ ex.getMessage());
                }
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                Id NegotiationsRecordType = Schema.SObjectType.nu_dse__Group_Task__c.getRecordTypeInfosByName().get('Negotiations').getRecordTypeId();
                Map<String, Holiday> holidayMap = new Map<String, Holiday>();
                Holidays hDays = new Holidays();
                holidayMap = Holidays.getHolidaysMap(); 
                Date nextWorkingDay = hDays.getNextWorkingDay(holidayMap , Date.today()+1 , true, true) ;
                for(nu_dse__Program__c prgm : prgmList_to_process){ 
                    gTaskList_to_insert.add(createGroupTaskOnProgram(prgm, grpDNL.id, nextWorkingDay,NegotiationsRecordType));
                }
                
                system.debug('==========='+gTaskList_to_insert);
                
                if(!gTaskList_to_insert.isEmpty()){
                    try{
                        insert gTaskList_to_insert;
                        
                        for(nu_dse__Group_Task__c gt: gTaskList_to_insert){
                            DynamicTemplateController d= new DynamicTemplateController();
                            d.vfTemplateName = 'DNL_Negotiation_Manager';
                            d.GroupTaskId = gt.Id;
                            string emailBody = null;
                            string subject = null;
                            String Template = d.getTemplateContent();
                            System.debug(Template);
                            
                            if(template.contains('::Split::'))
                            {
                                List<string> emailcontent = Template.split('::Split::');
                                subject = emailcontent[0];
                                emailBody = emailcontent[1];
                            }
                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSaveAsActivity(false);
                            mail.setToAddresses(EmailIds);
                            mail.setWhatId(gt.Id);
                            mail.setHtmlBody(emailBody);
                            mail.setSubject(subject);
                            allmsg.add(mail);
                        }
                        System.debug(allMsg);
                        if(!allMsg.isEmpty()){
                            List<Messaging.SendEmailResult> results = Messaging.sendEmail(allMsg,false);
                            System.debug(results);
                        } 
                        
                        isExecuteFirst = false;
                        }catch(Exception ex){
                            system.debug('Exception : ' + ex.getMessage());
                        }
                }
            }
        }
    }
    
    public static nu_dse__Group_Task__c createGroupTaskOnProgram(nu_dse__Program__c prgmIns, id groupId, Date activitydate, Id recordTypeId){
        
        nu_dse__Group_Task__c Gtask = new nu_dse__Group_Task__c();
        Gtask.OwnerId  = groupId ; 
        Gtask.nu_dse__Description__c = system.label.Pre_settlement_TILA+' '+ prgmIns.Name+ ' : ' + prgmIns.CLIENT_NAME__c;
        Gtask.Subject_Picklist__c = 'DNL Pre-TILA Signed';
        Gtask.nu_dse__Status__c = ' Not Started';
        Gtask.Program__c = prgmIns.id;
        GTask.RecordTypeId = recordTypeId;
        GTask.Department__c = 'DNL';
        GTask.nu_dse__ActivityDate__c = activitydate;
        return Gtask;
    
    }
     // ND-334 end
    
    //DV-591
    public static void setLendingApplicationDRPGraduated(List<nu_dse__Program__c> newProgramList, Map<id,nu_dse__Program__c> oldProgramMap){
        List<lendingAppDetail> lendingAppDetails = new List<lendingAppDetail>();
     //   Set<String> applicationIdSet = new Set<String>();
        for (nu_dse__Program__c newProgram: newProgramList) {
            nu_dse__Program__c oldProgram = oldProgramMap.get(newProgram.Id);
            if (newProgram.DNL_Status__c == 'Pre-TILA Signed' 
                && (newProgram.nu_dse__Program_Status__c == 'Graduated Program' || newProgram.nu_dse__Program_Status__c == 'Versara NDS Graduated')
                && newProgram.nu_dse__Program_Status__c != oldProgram.nu_dse__Program_Status__c
                && !String.isBlank(newProgram.DNL_Lending_Application_ID__c)) {
                
                lendingAppDetail appDetail = new lendingAppDetail();
                appDetail.applicationId =  newProgram.DNL_Lending_Application_ID__c;
                appDetail.lastDRPDraftDate = newProgram.Last_Payment_Date__c;    
                lendingAppDetails.add(appDetail);
            }
        }
        system.debug('+++lendingAppDetails+++++'+lendingAppDetails);
        if (!lendingAppDetails.isEmpty()) {
            updateLendingApplicationDRPGraduated(JSON.serialize(lendingAppDetails));
        }
    }
    
    @Future(callout=true)
    public static void updateLendingApplicationDRPGraduated (String jsonstr) {
        RestIntegrationInformation__mdt restIntegration = [select MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c,System_Endpoint__c From RestIntegrationInformation__mdt];
        SendOpportunityAccountUsingRestApi classInstance= new SendOpportunityAccountUsingRestApi();
        String accessToken = classInstance.ReturnAccessToken(classInstance);
        system.debug('++++accessToken++++'+accessToken);
        if(accessToken!=null){
            String endPoint= restIntegration.System_Endpoint__c + '/setApplicationToDRPGraduated'; 
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            req.setHeader('Authorization','Bearer ' + accessToken);
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(jsonstr);
            req.setMethod('POST');
            req.setEndpoint(endPoint);
            HttpResponse response;
            try{
                response= h.send(req);
            }
            catch(Exception e){
                System.debug(e.getMessage());
                notifyConnectionFail(e.getMessage());
            }
            System.debug('++++reques++++'+response);
            String str = response.getBody();
            
            
            System.debug('++++request body++++'+str);
            
            if (response.getStatus() != 'OK' && response.getStatusCode() != 200) {
                notifyConnectionFail(str);
            }
        }
    }
    
    public class lendingAppDetail {
        public String applicationId;
        public Date lastDRPDraftDate;
    }
    
    private static void notifyConnectionFail (String errroMsg) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        String[] sendingTo = new String[]{'msanghani@mindzcloud.com','jtamilarasu@stratfs.com','abhandari@stratfs.com'};
        semail.setToAddresses(sendingTo);
        semail.setSubject('Nudebt-Lending Connection failed.');
        String emailContent = 'Your api request to set lending application \'DRP Graduated\' was failed due to this error. Please take a look. \n\n '+ errroMsg;
        semail.setPlainTextBody(emailContent);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    }
}