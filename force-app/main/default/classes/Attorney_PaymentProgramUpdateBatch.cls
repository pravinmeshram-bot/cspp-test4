global class Attorney_PaymentProgramUpdateBatch implements Database.Batchable<Sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, FileNumber__c, nu_dse__Program__c from nu_dse__Payment__c where nu_dse__Program__c=null and FileNumber__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Payment__c> paymentList){
        List<String> fileNumbers = new List<String>();
        for(nu_dse__Payment__c Payment : paymentList){
            fileNumbers.add(Payment.fileNumber__c);
        }
        List<nu_dse__Program__c> ProgramList = [Select Id, import_Id__c from nu_dse__Program__c where import_Id__c=: FileNumbers];
        Map<String,nu_dse__Program__c> FileProgramMap = new Map<String,nu_dse__Program__c>();
        For(nu_dse__Program__c program : ProgramList){
            FileProgramMap.put(program.import_id__c, program);
        }
        
        List<nu_dse__Payment__c> paymentUpdateList = new List<nu_dse__Payment__c>();
        
        for(nu_dse__Payment__c payment : paymentList){
            if(FileProgramMap.containsKey(payment.FileNumber__c)){
                payment.nu_dse__Program__c = FileProgramMap.get(payment.FileNumber__c).id;
                paymentUpdateList.add(payment);
            }
        }
        Update paymentUpdateList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}