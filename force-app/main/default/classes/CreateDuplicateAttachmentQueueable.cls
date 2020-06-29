public class CreateDuplicateAttachmentQueueable implements Queueable {
    
    public List<Attachment> attachmentListToInsert = new List<Attachment>();
    
    public CreateDuplicateAttachmentQueueable(List<Attachment> attachmentList) {
        
        if (attachmentList.isEmpty() == False) {
            
            attachmentListToInsert = attachmentList;
        }
        
    }
    
    public void execute(QueueableContext QC) {
        
        List<Attachment> attachmentInsertList = new List<Attachment>();
        List<Attachment> attachmentUpdateList = new List<Attachment>();      
        
        List<nu_dse__Error_log__c> errorlogList = new List<nu_dse__Error_log__c> ();
        
        try {
            
            for (Attachment attachmentInst : attachmentListToInsert) {
                 
                Attachment tempInst = attachmentInst.clone();
                attachmentInsertList.add(tempInst);
            }
             
            Database.SaveResult[] attachmentInsertResultList = Database.insert(attachmentInsertList, false);
            integer i = 0;
            
            for (Database.SaveResult sr : attachmentInsertResultList) {
                
                String errMsg = '';
                if (sr.isSuccess() == False) {
                    
                    for(Database.Error err : sr.getErrors()) {
                    
                        errMsg += err.getMessage() + '; ';
                    }
                    
                    nu_dse__Error_log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'CreateDuplicateAttachmentQueueableJob', 
                                                                                nu_dse__Message__c = errMsg, 
                                                                                nu_dse__User_Context__c = UserInfo.getUserId(), 
                                                                                nu_dse__Error_Causing_Record_Id__c = attachmentListToInsert[i].Id);
                    errorlogList.add(errorLog);
                
                } else {
                    
                    attachmentListToInsert[i].Name = 'Duplicate-' + attachmentListToInsert[i].Name;
                    attachmentUpdateList.add(attachmentListToInsert[i]);
                }
                i++;
            }
            
            if (attachmentUpdateList.isEmpty() == False) {
                
                update attachmentUpdateList;
            }
        
        } catch (Exception e) {
            
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'CreateDuplicateAttachmentQueueableJob', nu_dse__Message__c = e.getMessage(),nu_dse__Stack_Trace__c = e.getStackTraceString(),nu_dse__User_Context__c = UserInfo.getName());
            errorlogList.add(errorLog);
        }
        
        if (errorlogList.isEmpty() == False) {
            
            insert errorlogList;
        }
        
    }
}