global class Attorney_GroupTaskProgramUpdateBatch implements Database.Batchable<Sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, FileNumber__c, Program__c from nu_dse__Group_Task__c where Program__c=null and FileNumber__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Group_Task__c> groupTaskList){
        List<String> fileNumbers = new List<String>();
        for(nu_dse__Group_Task__c groupTask : groupTaskList){
            fileNumbers.add(groupTask.fileNumber__c);
        }
        List<nu_dse__Program__c> ProgramList = [Select Id, import_Id__c from nu_dse__Program__c where import_Id__c=: FileNumbers];
        Map<String,nu_dse__Program__c> FileProgramMap = new Map<String,nu_dse__Program__c>();
        For(nu_dse__Program__c program : ProgramList){
            FileProgramMap.put(program.import_id__c, program);
        }
        
        List<nu_dse__Group_Task__c> groupTaskUpdateList = new List<nu_dse__Group_Task__c>();
        
        for(nu_dse__Group_Task__c groupTask : groupTaskList){
            if(FileProgramMap.containsKey(groupTask.FileNumber__c)){
                groupTask.Program__c = FileProgramMap.get(groupTask.FileNumber__c).id;
                groupTaskUpdateList.add(groupTask);
            }
        }
        Update groupTaskUpdateList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}