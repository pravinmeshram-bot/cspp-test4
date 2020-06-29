public class RunBatchesCtrl {

    public  nu_dse__program__c program{get;set;}
    
    public RunBatchesCtrl(){
        
        program = new nu_dse__program__c();
    }
    public static void executeSmsBatch(){
        
      List<AsyncApexJob> smsjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CommunicationNotificationBySMS'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(smsjobs.size()==0){
          nu_dse.Batch_CommunicationNotificationBySMS sms = new nu_dse.Batch_CommunicationNotificationBySMS();
          Database.executeBatch(sms);
        }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'SMS Batch is already running!');
             ApexPages.addMessage(myMsg);
        }
    }
    
    public static void executeEmailBatch(){
      
      List<AsyncApexJob> smsjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CommunicationNotificationByEmail'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(smsjobs.size()==0){
          nu_dse.Batch_CommunicationNotificationByEmail email = new nu_dse.Batch_CommunicationNotificationByEmail();
          Database.executeBatch(email);
        }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Email Batch is already running!');
             ApexPages.addMessage(myMsg);
        }
    }
    
    public static void executeVBBatch(){
          
         List<AsyncApexJob> smsjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CreateDraftPayments'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(smsjobs.size()==0){
          nu_dse.Batch_CreateDraftPayments vb = new nu_dse.Batch_CreateDraftPayments();
          nu_dse.Batch_CreateDraftPayments.processorId = 
          Database.executeBatch(vb);
        }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Voice Broad Cast Batch is already running!');
             ApexPages.addMessage(myMsg);
        }
    }
    
    public  void executeCreateDraftBatch(){
        
        List<AsyncApexJob> draftjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CreateDraftPayments'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(draftjobs.size()==0){
           
            System.debug('processorId: '+  program.nu_dse__Processor__c);
          nu_dse.Batch_CreateDraftPayments.processorId = program.nu_dse__Processor__c; 
          nu_dse.Batch_CreateDraftPayments createDraftPayments = new nu_dse.Batch_CreateDraftPayments(program.BatchDate__c);
          Database.executeBatch(createDraftPayments);
        }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Create Draft Payments Batch is already running!');
             ApexPages.addMessage(myMsg);
        }
    }
    
    public void executeCreateSettlementBatch(){
        
         List<AsyncApexJob> draftjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CreateDraftPayments'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(draftjobs.size()==0){
           
            System.debug('processorId: '+  program.nu_dse__Processor__c);
            nu_dse.Batch_CreateSettlementPayments_GCS.ProcessorId= program.nu_dse__Processor__C;
            nu_dse.Batch_CreateSettlementPayments_GCS batch= new nu_dse.Batch_CreateSettlementPayments_GCS(program.BatchDate__c);
            Database.executeBatch(batch, 1);
          
        }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Create Draft Payments Batch is already running!');
             ApexPages.addMessage(myMsg);
        }
        
    }
    
    public void executeCalfDrafts(){
        
         List<AsyncApexJob> calfdraftjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CreateDraftPayments'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(calfdraftjobs.size()==0){
            System.debug('processorId: '+  program.nu_dse__Processor__c);
            System.debug('BatchDate: '+  program.BatchDate__c);
            nu_dse.Batch_CreateDraftPayments.ProcessorId= program.nu_dse__Processor__C;
            nu_dse.Batch_CreateDraftPayments createCalfDrafts = new nu_dse.Batch_CreateDraftPayments(program.BatchDate__c);
            Database.executeBatch(createCalfDrafts);
          
        }else{
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Calf Draft Batch is already running!');
             ApexPages.addMessage(myMsg);
        }
        
    }
}