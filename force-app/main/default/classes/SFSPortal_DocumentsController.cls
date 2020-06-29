/* Date : 16-10-2018
 * Author : Team IDev
 * Description : Handles to add the Document current program 
 */
public class SFSPortal_DocumentsController {
    
    /* Date : 15-10-2018
     * Description : Method to get AccountId of the current user
     * Invoked From : doInit Method in sendEmailFromDocuments lightning component 
     */
    @AuraEnabled
    public static documentsWrapper getContentDocument() {
        
        documentsWrapper wrapper = new documentsWrapper();
        Map<Id, EmailMessage> AttchamentIdWithEmailMsgIdMap = new Map<Id, EmailMessage>();
        Map<String, Schema.SObjectField> fieldMap = emailMessage.sObjectType.getDescribe().fields.getMap();
        Organization orgDetail = SFSPortal_Utility.getOrgInfo();
        Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
        wrapper.accountId = accountIdMap.get('primaryAccountId');
        
        List<nu_dse__Program__c> programList = [SELECT Id, Name, nu_dse__Account__r.Name, nu_dse__Account__r.Box_Folder_Name__c 
                                                FROM nu_dse__Program__c 
                                                WHERE nu_dse__Account__c = :wrapper.accountId];
                                                
        for(Schema.SObjectField fieldAPI : fieldMap.values()) {
        
             wrapper.helpTextMap.put(String.valueOf(fieldAPI), fieldAPI.getDescribe().getInlineHelpText() != null ? fieldAPI.getDescribe().getInlineHelpText() : '');
        }
        for (EmailMessage emailMsg : [SELECT Id, subject, Request_Type__c, Action_Performed__c, CreatedDate, FromAddress, Attachment_Ids__c 
                                      FROM EmailMessage 
                                      WHERE Action_Performed__c = 'Document Upload' AND Related_Account__c = :wrapper.accountId
                                      ORDER BY createdDate DESC]) {
            
            for ( String attachmentId : emailMsg.Attachment_Ids__c.split(';')) {
                
                AttchamentIdWithEmailMsgIdMap.put(attachmentId, emailMsg);
            }
        }
        String emailSubject = ((orgDetail.IsSandbox == True) ? '^^^TEST^^^ ': '') +programList[0].nu_dse__Account__r.Name +' ('+programList[0].Name + ')';
        String removeboxId = ' to ' + programList[0].nu_dse__Account__r.Box_Folder_Name__c ;
        if (AttchamentIdWithEmailMsgIdMap.isEmpty() == False) {
            
            for (ContentDocument contentDoc : [SELECT Id, Title, CreatedDate 
                                               FROM ContentDocument 
                                               WHERE Id =:AttchamentIdWithEmailMsgIdMap.KeySet() ORDER BY CreatedDate DESC]) {
                
                if (AttchamentIdWithEmailMsgIdMap.ContainsKey(contentDoc.Id)) {
                    
                    wrapper.contentDocWrapList.add(new contentDocumentWrapper(contentDoc.Title, contentDoc.CreatedDate, 
                            AttchamentIdWithEmailMsgIdMap.get(contentDoc.Id).subject.remove(emailSubject).remove(removeboxId), AttchamentIdWithEmailMsgIdMap.get(contentDoc.Id).FromAddress, contentDoc.Id));
                }
            }
        }
        return wrapper;
    }
    
    /* Date : 16-10-2018
     * Description : Method to send Email
     * Invoked From : deleteContentDocument Method in sendEmailFromDocuments lightning component 
     */
    @AuraEnabled 
    public static boolean deleteDocument(String documentId) {
    
        try {
            
            List<ContentDocument> deleteContentDocumentList = new List<ContentDocument>();
            
            if(documentId != null) {
                
                if (documentId.contains(';')) {
                    
                    List<String> contentDocumentIdList = new List<String>();
                    contentDocumentIdList = String.valueOf(documentId).split(';');
                        
                    if(contentDocumentIdList.isEmpty() == False) {
                        
                        for (String contentDocumentId : contentDocumentIdList) {
                            
                            ContentDocument contentDocumentInstance = new ContentDocument(Id = contentDocumentId);
                            deleteContentDocumentList.add(contentDocumentInstance);
                        }
                    }
                } else {
                
                    ContentDocument contentDocumentInstance = new ContentDocument(Id = documentId);
                    deleteContentDocumentList.add(contentDocumentInstance);
                }
                if (deleteContentDocumentList.isEmpty() == False) {
                    
                    delete deleteContentDocumentList;
                }
                return true;
            }
                
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    
    /* Date : 16-10-2018
     * Description : Method to send Email
     * Invoked From : sendEmail Method in sendEmailFromDocuments lightning component 
     */
    @AuraEnabled
    public static documentsWrapper sendEmail(EmailMessage emailMessage, String accountId) {
        
        try {
            
            System.debug('***** emailMessage' + emailMessage);
            System.debug('***** accountId' + accountId);
            Id acctId;
            documentsWrapper wrapper = new documentsWrapper();
            
            if (emailMessage != null && String.isNotBlank(accountId)) {
                
                System.debug('***** emailMessage-->' + emailMessage);
                
                Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                Organization orgDetail = SFSPortal_Utility.getOrgInfo();
                acctId = accountIdMap.get('primaryAccountId');
        
                System.debug('***** acctId' + acctId);
                
                List<nu_dse__Program__c> programList = [SELECT Id, Name, nu_dse__Account__r.Box_Folder_Name__c, nu_dse__Account__r.ClientNumber__c, 
                                                        nu_dse__Account__r.Name, Portfolio__c, Portfolio__r.Excela_Email__c, Portfolio__r.OWD_Email_Name__c,
                                                        Portfolio__r.Name, Portfolio__r.Address__c, Portfolio__r.City__c, Portfolio__r.Dispay_Name__c, 
                                                        Portfolio__r.Domain_URL__c, Portfolio__r.State__c, Portfolio__r.Support_Email__c, Portfolio__r.Support_Fax_Number__c, 
                                                        Portfolio__r.Support_Phone_Number__c, Portfolio__r.Website__c, Portfolio__r.Zipcode__c, Portfolio__r.Logo_Document_Name__c
                                                        FROM nu_dse__Program__c 
                                                        WHERE nu_dse__Account__c = :acctId AND Portfolio__c != null AND Portfolio__r.Excela_Email__c != null ];
                
                System.debug('***** programList-->' + programList);
                
                if (programList != null && programList.isEmpty() == False && acctId != null) {
                    
                    if (emailMessage.subject != 'Other') {
                        
                        emailMessage.TextBody = 'Hello Excela Team, '+emailMessage.subject+ ' - '+programList[0].nu_dse__Account__r.Name+' - '+programList[0].Name;
                    }
                    
                    String selectedSubject = emailMessage.subject;
                    
                    System.debug('***** selectedSubject-->'+ selectedSubject);
                    
                    emailMessage.subject = ((orgDetail.IsSandbox == True) ? '^^^TEST^^^ ': '') +programList[0].nu_dse__Account__r.Name +' ('+programList[0].Name + ')' + ' Requested to upload ' + selectedSubject + ' to ' + programList[0].nu_dse__Account__r.Box_Folder_Name__c;

                    System.debug('***** emailMessage.subject-->'+ emailMessage.subject);
                    
                    List<Messaging.Emailfileattachment> fileAttachmentList = new List<Messaging.Emailfileattachment>();
                    List<String> contentDocumentIdList = new List<String>();
                    Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                    

                    String myEmail = 'ishishir@stratfs.com';  
                    //String myEmail = 'adarshsingh@mindzcloud.com';                    
                    emailInstance.setToAddresses(new String[]{myEmail});
                    /* emailInstance.setToAddresses(new String[]{programList[0].Portfolio__r.Excela_Email__c});*/
                    System.debug('***** emailMessage-->' + emailMessage);
                    System.debug('***** emailMessage.subject-->' + emailMessage.subject);
                    emailInstance.setSubject(emailMessage.subject);
                    
                    emailInstance.setHTMLBody(emailMessage.TextBody + SFSPortal_Utility.getEmailSignature(programList[0].Portfolio__r));
                    
                    System.debug('***** RelatedToId-->' + emailMessage.RelatedToId);
                    if(emailMessage.RelatedToId != null) {
                    
                        contentDocumentIdList = String.valueOf(emailMessage.RelatedToId).split(';');
                        
                        System.debug('***** contentDocumentIdList-->' + contentDocumentIdList);
                        
                        if(contentDocumentIdList.isEmpty() == False) {
                        
                            for (ContentVersion contentVersionInstance: [SELECT Id, VersionData, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId  IN :contentDocumentIdList]) {
                                
                                System.debug('***** contentVersionInstance-->' + contentVersionInstance);
                                
                                Messaging.Emailfileattachment fileAttachment = new Messaging.Emailfileattachment();
                                fileAttachment.setFileName(contentVersionInstance.PathOnClient);
                                fileAttachment.setBody(contentVersionInstance.VersionData);
                                fileAttachmentList.add(fileAttachment);
                            }
                        }
                    }
                    System.debug('***** fileAttachmentList-->' + fileAttachmentList);
                    emailInstance.setFileAttachments(fileAttachmentList);
                    System.debug('***** emailInstance.subject-->' + emailInstance.subject);
                    System.debug('***** emailMessage.subject-->' + emailMessage.subject);
                    String subjectToSend = emailInstance.subject;
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                    System.debug('***** mailResultList-->' + mailResultList);
                    System.debug('**** subjectToSend-->' + subjectToSend);
                    List<EmailMessage> emailMessageList = [ SELECT Id, subject FROM EmailMessage WHERE subject LIKE :subjectToSend  ORDER BY createdDate DESC LIMIT 1];
                    System.debug('***** emailMessageList-->' + emailMessageList);
                    if(mailResultList[0].isSuccess() == true && emailMessageList.isEmpty() == False) {
                    
                        if (contentDocumentIdList.isEmpty() == False) {
                            
                            emailMessageList[0].Attachment_Ids__c = string.join(contentDocumentIdList,';');
                        }
                        emailMessageList[0].Request_Type__c = 'Document Upload Request';
                        emailMessageList[0].Related_Account__c = accountId;
                        emailMessageList[0].Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + String.valueOf(System.now());
                        emailMessageList[0].Decision_Source__c = 'Portal';
                        emailMessageList[0].Action_Performed__c = 'Document Upload';
                        update emailMessageList;
                    
                        /* Reparenting logic */
                        List<ContentDocumentLink> contentDocumentToInsertList = new List<ContentDocumentLink>();
                        List<ContentDocumentLink> contentDocumentToDeleteList = new List<ContentDocumentLink>();
                        System.debug('***** contentDocumentIdList-->' + contentDocumentIdList);
                        
                        if(contentDocumentIdList.isEmpty() == FALSE) {
                        
                            for(ContentDocumentLink documentLink : [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, SystemModstamp,
                                                                    Visibility FROM ContentDocumentLink
                                                                    WHERE ContentDocumentId IN :contentDocumentIdList
                                                                    AND LinkedEntityId = :accountId]) {
                            
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
                    
                    Map<Id, EmailMessage> AttchamentIdWithEmailMsgIdMap = new Map<Id, EmailMessage>();
                    String emailSubject = ((orgDetail.IsSandbox == True) ? '^^^TEST^^^ ': '') +programList[0].nu_dse__Account__r.Name +' ('+programList[0].Name + ')';
                    String removeboxId = ' to ' + programList[0].nu_dse__Account__r.Box_Folder_Name__c ;
                    for (EmailMessage emailMsg : [SELECT Id, subject, Request_Type__c, Action_Performed__c, CreatedDate, FromAddress, Attachment_Ids__c 
                                                FROM EmailMessage 
                                                WHERE Action_Performed__c = 'Document Upload' AND Related_Account__c = :accountIdMap.get('primaryAccountId') 
                                                ORDER BY createdDate DESC]) {
                        
                        for ( String attachmentId : emailMsg.Attachment_Ids__c.split(';')) {
                            
                            AttchamentIdWithEmailMsgIdMap.put(attachmentId, emailMsg);
                        }
                    }
                    if (AttchamentIdWithEmailMsgIdMap.isEmpty() == False) {
                        
                        for (ContentDocument contentDoc : [SELECT Id, Title, CreatedDate FROM ContentDocument WHERE Id =:AttchamentIdWithEmailMsgIdMap.KeySet() ORDER BY CreatedDate DESC]) {
                            
                            if (AttchamentIdWithEmailMsgIdMap.ContainsKey(contentDoc.Id)) {
                                
                                wrapper.contentDocWrapList.add(new contentDocumentWrapper(contentDoc.Title, contentDoc.CreatedDate, 
                                        AttchamentIdWithEmailMsgIdMap.get(contentDoc.Id).subject.remove(emailSubject).remove(removeboxId), AttchamentIdWithEmailMsgIdMap.get(contentDoc.Id).FromAddress, contentDoc.Id));
                            }
                        }
                    }
                    return wrapper;
                } else {
                    
                    throw new AuraHandledException('Excela email is not populated at Portfolio level');
                }
            }                        
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
//=======================================================================
    @AuraEnabled
    public static DefaultFormWrapper1 getDefaultFormIdList1() {
        
        DefaultFormWrapper1 wrapperInstance1 = new DefaultFormWrapper1();
        try {
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            List<Id> ProtfolioAndProcessorIds = new List<Id>();
            List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c,nu_dse__Processor__c FROM nu_dse__Program__c WHERE nu_dse__Account__c = :accountIdMap.get('primaryAccountId')];
            for(nu_dse__Program__c objProgram : programList){
                ProtfolioAndProcessorIds.add(objProgram.Portfolio__c);
                ProtfolioAndProcessorIds.add(objProgram.nu_dse__Processor__c);
            }
            System.debug('***** programList' + programList+'ProtfolioAndProcessorIds>>>'+ProtfolioAndProcessorIds);
            
            if(programList.isEmpty() == FALSE) {
                system.debug('programList[0].Portfolio__c==>'+programList[0].Portfolio__c);   
                Map<ID, ContentDocumentLink> cdlMapIds = new Map<Id, ContentDocumentLink>();
                List<ContentDocumentLink> ContentDocumentLinkList =  [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: ProtfolioAndProcessorIds AND Visibility='AllUsers'];//=:'a2G55000002wXmc' AND Visibility='AllUsers'];// 
                system.debug('ContentDocumentLinkList===>'+ ContentDocumentLinkList);
                for(ContentDocumentLink CDlink : ContentDocumentLinkList){
                    cdlMapIds.put(CDlink.ContentDocumentId, CDlink);  
                }
                
                if(cdlMapIds.isEmpty() == FALSE) {
                    for(ContentDocumentLink CDlink : ContentDocumentLinkList){
                        cdlMapIds.get(CDlink.ContentDocumentId);
                        wrapperInstance1.attachmentList1 = [SELECT Id, Title, FileType, Description, CreatedDate FROM ContentDocument Where Id IN: cdlMapIds.keyset()];
                    }
                }
            } 
        } catch(Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        }
        
        return wrapperInstance1;
        
    }
//=========================================================================  
    /* Date : 16-10-2018
     * Description : Method to get the all the attachments under the portfolio
     * Invoked From : doInit Method in defaultForms lightning component 
     */
  /*  @AuraEnabled
    public static DefaultFormWrapper getDefaultFormIdList() {
        
        DefaultFormWrapper wrapperInstance = new DefaultFormWrapper();
        try {
            
            //List<User> userList = [SELECT Id, Contact.AccountId FROM User WHERE Id = :Userinfo.getUserId()];
            
           // if(userList.isEmpty() == FALSE) {
            
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
           
            List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c,nu_dse__Processor__c FROM nu_dse__Program__c WHERE nu_dse__Account__c = :accountIdMap.get('primaryAccountId')];
            
            System.debug('***** programList' + programList);
            
            if(programList.isEmpty() == FALSE) {
                
                wrapperInstance.attachmentList = [SELECT Id, ContentType, Description, Name FROM Attachment WHERE ParentId = :programList[0].Portfolio__c OR ParentId =:programList[0].nu_dse__Processor__c];
                
                wrapperInstance.urlKeyPrefix = getUrlPathPrefix();
            }
        //}
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        
        return wrapperInstance;
    
    }*/
    
  /*  public static String getUrlPathPrefix() {
        String pathPrefix = '';
        
            Id communityId = Network.getNetworkId();
            if(communityId != null) {
                List<sObject> networkList = Database.query('SELECT UrlPathPrefix FROM Network WHERE Id = :communityId');
                if(!networkList.isEmpty()) {
                    if(networkList[0].get('UrlPathPrefix') != null) {
                        pathPrefix = (String) networkList[0].get('UrlPathPrefix');
                    }
                }
            }
        
        if(pathPrefix != '') {
            pathPrefix = '/' + pathPrefix;
        }
        return pathPrefix;
    }
    */
  /*  public class DefaultFormWrapper {
        
        @AuraEnabled
        public String urlKeyPrefix;
        
        @AuraEnabled
        public List<Attachment> attachmentList = new List<Attachment>();
        
       
        
    }    */
     public class DefaultFormWrapper1 {
        
      /*  @AuraEnabled
        public String urlKeyPrefix;*/
        
        @AuraEnabled
        public List<ContentDocument> attachmentList1 = new List<ContentDocument>();
         
      /*  @AuraEnabled
        public List<ContentDocumentLink> attachmentList2 = new List<ContentDocumentLink>();
      */  
    } 
    public class contentDocumentWrapper {
        @AuraEnabled
        public String docId ;
        
        @AuraEnabled
        public String FileName;
        
        @AuraEnabled
        public DateTime createdDate;
        
        @AuraEnabled
        public String Subject;
        
        @AuraEnabled
        public String emailSent;
        
        public contentDocumentWrapper (String fileName, DateTime createdDate,String subject, String emailSent, String documentId) {
            
            this.fileName = fileName;
            this.createdDate = createdDate;
            this.subject = subject;
            this.emailSent = emailSent;
            this.docId = documentId;
            
        }
    }
    
    public class documentsWrapper {
    
        @AuraEnabled
        public String accountId;
        
        @AuraEnabled
        public Map<String,String> helpTextMap = new Map<String,String>(); 
        
        @AuraEnabled
        public List<contentDocumentWrapper > contentDocWrapList = new List<contentDocumentWrapper>();
    }
}