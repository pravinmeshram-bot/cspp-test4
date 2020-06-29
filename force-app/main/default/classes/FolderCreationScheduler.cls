global class FolderCreationScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
         
        List<AsyncApexJob> folderjobs= [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'BatchBoxFolderCreation'  and status in ('Queued','Preparing','Processing') limit 1 ];       
     
        if(folderjobs.size()==0){
          BatchBoxFolderCreation bbfc = new BatchBoxFolderCreation();
          database.executebatch(bbfc,1);
        }
        
    }
}