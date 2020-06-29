global class Attorney_TradelineProgramUpdateBatch implements Database.Batchable<Sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, FileNumber__c, nu_dse__Program__c from nu_dse__TradeLine__c where nu_dse__Program__c=null and FileNumber__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__TradeLine__c> tradelineList){
        List<String> fileNumbers = new List<String>();
        for(nu_dse__TradeLine__c tradeLine : tradelineList){
            fileNumbers.add(tradeline.fileNumber__c);
        }
        List<nu_dse__Program__c> ProgramList = [Select Id, import_Id__c from nu_dse__Program__c where import_Id__c=: FileNumbers];
        Map<String,nu_dse__Program__c> FileProgramMap = new Map<String,nu_dse__Program__c>();
        For(nu_dse__Program__c program : ProgramList){
            FileProgramMap.put(program.import_id__c, program);
        }
        
        List<nu_dse__TradeLine__c> tradelineUpdateList = new List<nu_dse__TradeLine__c>();
        
        for(nu_dse__TradeLine__c tradeLine : tradelineList){
            if(FileProgramMap.containsKey(tradeline.FileNumber__c)){
                tradeLine.nu_dse__Program__c = FileProgramMap.get(tradeline.FileNumber__c).id;
                tradeLineUpdateList.add(tradeLine);
            }
        }
        Update tradelineUpdateList;
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new Attorney_OfferProgramUpdateBatch(),50);
    }
}