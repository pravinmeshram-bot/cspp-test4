public class Batch_DuplicateAttachmentAndSync implements Database.Batchable<SObject> {
    
    public String filterCondition = '';
    public String orderingAndLimit = '';
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
         
        String query = 'SELECT Id FROM nu_dse__Program__c WHERE nu_dse__Synced_With_Processor__c = True AND nu_dse__Account__r.nu_dse__External_CFT_Id__c != null';
         
        if (String.isNotBlank(filterCondition) == True) {
            
            query = 'SELECT Id FROM nu_dse__Program__c WHERE (' + filterCondition + ') AND (nu_dse__Synced_With_Processor__c = True AND nu_dse__Account__r.nu_dse__External_CFT_Id__c != null)';
            //query = 'SELECT Id FROM nu_dse__Program__c WHERE ' + filterCondition;
        }
        
        if (String.isNotBlank(orderingAndLimit) == True) {
            
            query += ' ' + orderingAndLimit;
        }
        
        System.debug('query-->'+query);
        
        return Database.getQueryLocator(query);
    }
     
     public void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programList) {
         
         Set<Id> programIdSet = new Set<Id> ();
         
         System.debug('Entered-->');
         
         try {
             
             for (nu_dse__Program__c programInstance : programList) {
                 
                 programIdSet.add(programInstance.Id);
             }
             System.debug('programIdSet-->'+programIdSet);
             
             if (programIdSet.isEmpty() == False) {
                 
                 Map<Id, Attachment> attachmentMap = new Map<Id, Attachment> ();
                 Set<Id> programWithRecentlyCreatedAttachment = new Set<Id> ();
                 
                 for (Attachment attachmentInst : [SELECT Id, Name, ParentId, ContentType, Body FROM Attachment 
                                                     WHERE ParentId IN :programIdSet 
                                                     AND Name LIKE 'AUTHORIZATION-SPAA%' ORDER BY CreatedDate DESC]) {
                     
                     if (programWithRecentlyCreatedAttachment.contains(attachmentInst.ParentId) == False) {
                         
                         attachmentMap.put(attachmentInst.Id, attachmentInst);
                         programWithRecentlyCreatedAttachment.add(attachmentInst.parentId);
                     }
                 }
                 
                 System.debug('attachmentMap-->'+attachmentMap);
                 
                 for (nu_dse__Document__c documentInst : [SELECT Id, nu_dse__Attachment_Name__c, nu_dse__Attachment_Id__c, nu_dse__External_CFT_Id__c 
                                                             FROM nu_dse__Document__c WHERE nu_dse__Attachment_Id__c IN :attachmentMap.keySet()
                                                             AND nu_dse__Attachment_Name__c LIKE 'AUTHORIZATION-SPAA%' AND nu_dse__External_CFT_Id__c != null]) {
                     
                     if (attachmentMap.containsKey(documentInst.nu_dse__Attachment_Id__c) == True
                         && attachmentMap.get(documentInst.nu_dse__Attachment_Id__c).Name == documentInst.nu_dse__Attachment_Name__c) {
                         
                         attachmentMap.remove(documentInst.nu_dse__Attachment_Id__c);
                     }
                 }
                 
                 if (attachmentMap.isEmpty() == False) {
                     
                     System.enqueueJob(new CreateDuplicateAttachmentQueueable(attachmentMap.values()));
                 }
                 
             }
         
         } catch (Exception e) {
             
             nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_DuplicateAttachmentAndSync', nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), nu_dse__User_Context__c = userInfo.getName());
             insert errorlog;
         }
     }
     
     public void finish(Database.BatchableContext BC) {
         
         
     }
}