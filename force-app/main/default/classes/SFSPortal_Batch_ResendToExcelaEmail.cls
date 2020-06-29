/* Date : 10-07-2019
 * Author : Team IDev
 * Description : Batch class to re-send the non synced documents excela email
 */
public without sharing class SFSPortal_Batch_ResendToExcelaEmail implements Database.Batchable<sObject>, Database.stateful {
    
    List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
    
        return Database.getQueryLocator('SELECT Id, Subject, Action_Performed__c, HtmlBody, Related_Account__c,'
            + ' Attachment_Ids__c, Decision_Made_By__c, Decision_Source__c FROM Emailmessage'
            + ' WHERE Decision_Source__c=\'Portal\' AND Subject LIKE \'%^^^TEST%\'');
    }
    
    public void execute(Database.BatchableContext bc, List<EmailMessage> sentEmailMessageList) {
        
        EmailMessage emailMessage = new EmailMessage();
        
        if(sentEmailMessageList != null && sentEmailMessageList.isEmpty() == FALSE && sentEmailMessageList.size() == 1) {
            
            try {
            
                emailMessage = sentEmailMessageList[0];
            
                List<nu_dse__Program__c> programList = [SELECT Portfolio__r.Excela_Email__c
                    FROM nu_dse__Program__c 
                    WHERE nu_dse__Account__c = :emailMessage.Related_Account__c AND Portfolio__c != null AND Portfolio__r.Excela_Email__c != null
                ];
                
                if (programList != null && programList.isEmpty() == FALSE) {
                    
                    String exisitngSubjectSubject = emailMessage.subject;
                    
                    emailMessage.subject = exisitngSubjectSubject.substringAfter('^^^TEST^^^ ');
                    
                    System.debug('***** emailMessage.subject-->'+ emailMessage.subject);
                    
                    List<Messaging.Emailfileattachment> fileAttachmentList = new List<Messaging.Emailfileattachment>();
                    List<String> contentDocumentIdList = new List<String>();
                    Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                    
                    emailInstance.setToAddresses(new String[]{programList[0].Portfolio__r.Excela_Email__c});
                    emailInstance.setSubject(emailMessage.subject);
                    
                    emailInstance.setHTMLBody(emailMessage.HtmlBody);
                    
                    System.debug('***** Attachment_Ids__c-->' + emailMessage.Attachment_Ids__c);
                    if(emailMessage.Attachment_Ids__c != null) {
                    
                        contentDocumentIdList = String.valueOf(emailMessage.Attachment_Ids__c).split(';');
                        
                        if(contentDocumentIdList.isEmpty() == False) {
                        
                            for (ContentVersion contentVersionInstance: [SELECT Id, VersionData, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId  IN :contentDocumentIdList]) {
                                
                                Messaging.Emailfileattachment fileAttachment = new Messaging.Emailfileattachment();
                                fileAttachment.setFileName(contentVersionInstance.PathOnClient);
                                fileAttachment.setBody(contentVersionInstance.VersionData);
                                fileAttachmentList.add(fileAttachment);
                            }
                        }
                    }
                    
                    emailInstance.setFileAttachments(fileAttachmentList);
                    
                    String subjectToSend = emailInstance.subject;
                    
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                    
                    List<EmailMessage> emailMessageList = [ SELECT Id, subject FROM EmailMessage WHERE subject LIKE : subjectToSend  ORDER BY createdDate DESC LIMIT 1];
                    
                    System.debug('emailMessageList--> ' + emailMessageList );
                    
                    System.debug('subjectToSend --> ' + subjectToSend );
                    
                    System.debug('mailResultList[0].isSuccess()--> ' + mailResultList[0].isSuccess());
                    
                    if(mailResultList[0].isSuccess() == true && emailMessageList.isEmpty() == False) {
                        
                        if (contentDocumentIdList.isEmpty() == FALSE) {
                            
                            emailMessageList[0].Attachment_Ids__c = string.join(contentDocumentIdList,';');
                        }
                        
                        emailMessageList[0].Request_Type__c = 'Document Upload Request';
                        emailMessageList[0].Related_Account__c = emailMessage.Related_Account__c;
                        
                        emailMessageList[0].Decision_Made_By__c = emailMessage.Decision_Made_By__c;
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
                                AND LinkedEntityId = :emailMessage.Id]
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
                            
                                //delete contentDocumentToDeleteList;
                            }
                            
                        }
                    }
                } else {
                    
                    throw new CustomException('Excela email is not populated at Portfolio level');
                }
                                        
            } catch(Exception e) {
            
                errorLogList.add(new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'SFSPortal_Batch_ResendToExcelaEmail.Execute', 
                    nu_dse__Error_Causing_Record_Id__c = emailMessage.Id, nu_dse__Message__c = e.getMessage(), nu_dse__User_Context__c = UserInfo.getUserId()));
            }
            
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
        if(errorLogList.isEmpty() == FALSE) {
            
            insert errorLogList;
        }
    }
}