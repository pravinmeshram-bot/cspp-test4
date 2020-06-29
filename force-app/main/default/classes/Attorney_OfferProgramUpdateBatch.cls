global class Attorney_OfferProgramUpdateBatch implements Database.Batchable<Sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, FileNumber__c, nu_dse__Program__c from nu_dse__Offer__c where nu_dse__Program__c=null and FileNumber__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Offer__c> offerList){
        List<String> fileNumbers = new List<String>();
        for(nu_dse__Offer__c offer : offerList){
            fileNumbers.add(offer.fileNumber__c);
        }
        List<nu_dse__Program__c> ProgramList = [Select Id, import_Id__c from nu_dse__Program__c where import_Id__c=: FileNumbers];
        Map<String,nu_dse__Program__c> FileProgramMap = new Map<String,nu_dse__Program__c>();
        For(nu_dse__Program__c program : ProgramList){
            FileProgramMap.put(program.import_id__c, program);
        }
        
        List<nu_dse__Offer__c> offerUpdateList = new List<nu_dse__Offer__c>();
        
        for(nu_dse__Offer__c offer : offerList){
            if(FileProgramMap.containsKey(offer.FileNumber__c)){
                offer.nu_dse__Program__c = FileProgramMap.get(offer.FileNumber__c).id;
                offerUpdateList.add(offer);
            }
        }
        Update offerUpdateList;
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new Attorney_PaymentProgramUpdateBatch(),50);
        Database.executeBatch(new Attorney_TaskProgramUpdateBatch(),50);
        Database.executeBatch(new Attorney_GroupTaskProgramUpdateBatch(),50);
    }
}