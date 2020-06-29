public without sharing class SFSPortal_ContactUsController {
   
    /* Date : 09-10-2018
     * Description : Method to send the message to custom Email toaddress and update custom field value on EmailMessageObject
     * Invoked From : onSendMail Method in contactUs lightning component 
     */
    
    @AuraEnabled
    public static void sendMail(EmailMessage message, String accountId) {
        
        try {
            
            List<Messaging.Emailfileattachment> fileAttachmentList = new List<Messaging.Emailfileattachment>();
            List<String> contentDocumentIdList = new List<String>();
            Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
            
            List<nu_dse__Program__c> programList = [SELECT Id, Name, Portfolio__c, Portfolio__r.Logo_Document_Name__c, 
                Portfolio__r.Dispay_Name__c, Portfolio__r.Excela_Email__c, Portfolio__r.OWD_Email_Name__c, Portfolio__r.Name, 
                Portfolio__r.Address__c, Portfolio__r.City__c, Portfolio__r.Domain_URL__c, Portfolio__r.State__c, 
                Portfolio__r.Support_Email__c, Portfolio__r.Support_Fax_Number__c, Portfolio__r.Support_Phone_Number__c, 
                Portfolio__r.Website__c, Portfolio__r.Zipcode__c, Portfolio__r.Feedback_Email__c
                FROM nu_dse__Program__c
                WHERE nu_dse__Account__c =: accountId AND Portfolio__c != null LIMIT 1
            ]; 
            
            if(programList.isEmpty() == False) {
            
                if(String.valueOf(message.Request_Subject__c).equalsIgnoreCase('Estimate to Complete')) {
            
                    nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c(
                        nu_dse__Subject__c = 'Client is requesting a payment estimate to complete the program.',
                        Subject_Picklist__c = 'Estimate to complete program (ETCP Docs Request)',
                        nu_dse__Related_To__c = programList[0].Id,
                        Program__c = programList[0].Id,
                        nu_dse__Status__c = 'Not Started',
                        nu_dse__ActivityDate__c = System.today().addDays(1)
                    );
                    
                    
                    /* Populating Decision Source and Made By */
                    groupTaskInstance.Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + String.valueOf(System.now());
                    groupTaskInstance.Decision_Source__c = 'Portal';
                    
                    List<Group> groupList = [select Id from Group where Type = 'Queue' AND DeveloperName = 'Payment_Processing' LIMIT 1];
                    
                    if(groupList.isEmpty() == FALSE) {
                    
                        groupTaskInstance.OwnerId = groupList[0].Id;
                    }
    
                    insert groupTaskInstance;
                    
                    System.debug('**** message.RelatedToId-->' + message.RelatedToId);
                    
                    if(message.RelatedToId != null) {
                        
                        List<ContentDocumentLink> insertContentDocumentLinkList = new List<ContentDocumentLink>();
                        List<ContentDocumentLink> deleteContentDocumentLinkList = new List<ContentDocumentLink>();
                        
                        contentDocumentIdList = String.valueOf(message.RelatedToId).split(';');
                        
                        if(contentDocumentIdList.isEmpty() == False) {
                        
                            for (ContentDocumentLink contentDocInstance: [SELECT Id, ShareType, Visibility, ContentDocumentId 
                                FROM ContentDocumentLink 
                                WHERE ContentDocumentId  IN :contentDocumentIdList AND LinkedEntityId = :accountId]
                            ) {
                            
                                ContentDocumentLink contentDoc = contentDocInstance.clone();
                                contentDoc.LinkedEntityId = groupTaskInstance.Id;
                                insertContentDocumentLinkList.add(contentDoc);
                                
                                ContentDocumentLink contentDocumentLinkInstance = new ContentDocumentLink(Id = contentDocInstance.Id);
                                deleteContentDocumentLinkList.add(contentDocumentLinkInstance);
                            }
                            
                            System.debug('**** insertContentDocumentLinkList-->' + insertContentDocumentLinkList);
                            
                            if(insertContentDocumentLinkList.isEmpty() == FALSE) {
                            
                                insert insertContentDocumentLinkList;
                            }
                            
                            System.debug('**** deleteContentDocumentLinkList-->' + deleteContentDocumentLinkList);
                            
                            if(deleteContentDocumentLinkList.isEmpty() == FALSE) {
                            
                                delete deleteContentDocumentLinkList;
                            }
                            
                        }
                    }
                    
                } else {
                
                    if(String.valueOf(message.Request_Subject__c).equalsIgnoreCase('Feedback')) {
                    
                        if(programList[0].Portfolio__r.Feedback_Email__c != null) {
                            
                            emailInstance.setToAddresses(new String[]{programList[0].Portfolio__r.Feedback_Email__c});
                        } else {
                        
                            throw new CustomException('Feedback Email is not populated in portfolio');
                        }
                    } else {
                    
                        if(programList[0].Portfolio__r.Support_Email__c != null) {
                            
                            emailInstance.setToAddresses(new String[]{programList[0].Portfolio__r.Support_Email__c});
                        } else {
                        
                            throw new CustomException('Support Email is not populated in portfolio');
                        }
                    }
                    
                    String subjectToSend = programList[0].Name+' '+message.Request_Subject__c;
                    
                    emailInstance.setSubject(programList[0].Name+' '+message.Request_Subject__c); 
                    emailInstance.setHTMLBody(message.TextBody + SFSPortal_Utility.getEmailSignature(programList[0].Portfolio__r));
                    
                    if(message.RelatedToId != null) {
                    
                        contentDocumentIdList = String.valueOf(message.RelatedToId).split(';');
                        
                        if(contentDocumentIdList.isEmpty() == False) {
                        
                            for (ContentVersion contentVersionInstance: [SELECT Id, VersionData, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId  IN :contentDocumentIdList]) {
                            
                                Messaging.Emailfileattachment fileAttachment = new Messaging.Emailfileattachment();
                                fileAttachment.setFileName(contentVersionInstance.PathOnClient);
                                fileAttachment.setBody(contentVersionInstance.VersionData);
                                fileAttachmentList.add(fileAttachment);
                            }
                        }
                        emailInstance.setFileAttachments(fileAttachmentList);
                    }
                    
                    /* Getting org wide email address based on the diplay name */
                    
                    /*
                    if(programList.isEmpty() == FALSE && String.isNotBlank(programList[0].Portfolio__r.OWD_Email_Name__c) == TRUE) {
                       
                        Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(programList[0].Portfolio__r.OWD_Email_Name__c);
                        
                        if(owdEmailId != null) {
                        
                            emailInstance.setOrgWideEmailAddressId(owdEmailId);
                        }
                    }
                    */
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                    system.debug('Message****'+message.Subject);
                    
                    system.debug('subjectToSend****'+subjectToSend);
                    
                    List<EmailMessage> emailMessageList = [ SELECT Id, Subject FROM EmailMessage WHERE subject LIKE :subjectToSend ORDER BY createdDate DESC LIMIT 1];
                    System.debug('***** emailMessageList-->' + emailMessageList);
                    Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                    
                    if(mailResultList[0].isSuccess() == true && emailMessageList.isEmpty() == False && accountIdMap != null 
                        && accountIdMap.ContainsKey('userAccountId') && accountIdMap.get('userAccountId') != null) {
                        
                        if (contentDocumentIdList.isEmpty() == False) {
                                    
                            emailMessageList[0].Attachment_Ids__c = string.join(contentDocumentIdList,';');
                        }
                        emailMessageList[0].Request_Type__c = 'Support Request';
                        emailMessageList[0].Related_Account__c = accountIdMap.get('userAccountId');
                        emailMessageList[0].Request_Subject__c = message.Request_Subject__c;
                        
                        /* Populating Decision Source and Made By */
                        emailMessageList[0].Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + String.valueOf(System.now());
                        emailMessageList[0].Decision_Source__c = 'Portal';
                        emailMessageList[0].Action_Performed__c = 'Contact Us';
                        
                        update emailMessageList; 
                        
                        
                        /* Reparenting logic */
                        
                        List<ContentDocumentLink> contentDocumentToInsertList = new List<ContentDocumentLink>();
                        List<ContentDocumentLink> contentDocumentToDeleteList = new List<ContentDocumentLink>();
                        
                        System.debug('***** contentDocumentIdList-->' + contentDocumentIdList);
                        
                        if(contentDocumentIdList.isEmpty() == FALSE) {
                        
                            for(ContentDocumentLink documentLink : [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, SystemModstamp,
                                Visibility FROM ContentDocumentLink
                                WHERE ContentDocumentId IN :contentDocumentIdList AND LinkedEntityId = :accountIdMap.get('userAccountId')]
                            ) {
                            
                                ContentDocumentLink contentDoc = documentLink.clone();
                                contentDoc.LinkedEntityId = emailMessageList[0].Id;
                                contentDocumentToInsertList.add(contentDoc);
                                
                                ContentDocumentLink contentDocumentLinkInstance = new ContentDocumentLink(Id = documentLink.Id);
                                contentDocumentToDeleteList.add(contentDocumentLinkInstance);
                            }
                            
                            System.debug('***** contentDocumentToInsertList-->' + contentDocumentToInsertList);
                            
                            if(contentDocumentToInsertList.isEmpty() == FALSE) {
                            
                                insert contentDocumentToInsertList;
                            }
                            
                            System.debug('***** contentDocumentToDeleteList-->' + contentDocumentToDeleteList);
                            if(contentDocumentToDeleteList.isEmpty() == FALSE) {
                            
                                delete contentDocumentToDeleteList;
                            }
                            
                        }
                        
                    } 
                }
            }
        } catch(Exception e) {
            
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_ContactUsController.sendMail', 
                null, e.getMessage(), e.getStackTraceString()
            );
            */
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Date : 09-10-2018
     * Description : Method to get the picklist value and get the current user AccountId
     * Invoked From : doInit Method in contactUs lightning component 
     */
     
    @AuraEnabled
    public static ContactUsDefaultWrapper getDefaultValue() {
        
        ContactUsDefaultWrapper wrapper = new ContactUsDefaultWrapper();
        
        Map<String, Schema.SObjectField> fieldMap = emailMessage.sObjectType.getDescribe().fields.getMap();
            
            for(Schema.SObjectField fieldAPI : fieldMap.values()) {
                    
                wrapper.helpTextMap.put(String.valueOf(fieldAPI), fieldAPI.getDescribe().getInlineHelpText() != null ? fieldAPI.getDescribe().getInlineHelpText() : '');
            }

        
        for( Schema.PicklistEntry pickListVal : emailMessage.Request_Subject__c.getDescribe().getPicklistValues()) {
       
            wrapper.CSP97List.add(pickListVal.getLabel());
            
        }  
        Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
        
        if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
            
            if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                
                wrapper.accountId = accountIdMap.get('primaryAccountId');
            
                List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c FROM nu_dse__Program__c WHERE nu_dse__Account__c =: wrapper.accountId ]; 
                
                if(programList.isEmpty() == False) {
                    
                    List<Portfolio__c> portfolioList = [SELECT Support_Email__c, Support_Fax_Number__c, Support_Phone_Number__c, 
                        Address__c, City__c, State__c, Zipcode__c FROM Portfolio__c WHERE Id =: programList[0].Portfolio__c];
                    
                    if(portfolioList.isEmpty() == False) {
                        
                        wrapper.portfolioInstance = portfolioList[0] ;
                    }
                }
            }
        }
        return wrapper;
    }
 
    /* Date : 17-10-2018
     * Description : Method to delete the document of given documentId
     * Invoked From : onDelete Method in contactUs lightning component 
     */   
    
    @AuraEnabled 
    public static void deleteDocument(String deleteDocumentId) {
    
        try {
            
            if(deleteDocumentId != null) {
            
                ContentDocument contentDocumentInstance = new ContentDocument(Id = deleteDocumentId);
                delete contentDocumentInstance ;
            }
                
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public class ContactUsDefaultWrapper {
        
        @AuraEnabled
        public List<String> preferredMethodList = new List<String>() ;
                             
        @AuraEnabled
        public List<String> contactTypeList = new List<String>() ;
        
        @AuraEnabled
        public List<String> CSP97List = new List<String>() ;
                    
        @AuraEnabled
        public String accountId ;  
        
        @AuraEnabled
        public Portfolio__c portfolioInstance ;     
        
        @AuraEnabled
        public Map<String,String> helpTextMap = new Map<String,String>();           
    }
}