global class Attorney_TaskProgramUpdateBatch implements Database.Batchable<Sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, FileNumber__c, whatId from Task where whatId=null and FileNumber__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Task> TaskList){
        List<String> fileNumbers = new List<String>();
        for(Task task1 : taskList){
            fileNumbers.add(Task1.fileNumber__c);
        }
        List<nu_dse__Program__c> ProgramList = [Select Id, import_Id__c from nu_dse__Program__c where import_Id__c=: FileNumbers];
        Map<String,nu_dse__Program__c> FileProgramMap = new Map<String,nu_dse__Program__c>();
        For(nu_dse__Program__c program : ProgramList){
            FileProgramMap.put(program.import_id__c, program);
        }
        
        List<Task> taskUpdateList = new List<Task>();
        
        for(Task task1 : taskList){
            if(FileProgramMap.containsKey(task1.FileNumber__c)){
                Task1.whatId = FileProgramMap.get(task1.FileNumber__c).id;
                taskUpdateList.add(task1);
            }
        }
        Update taskUpdateList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}