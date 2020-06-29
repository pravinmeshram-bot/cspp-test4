public class DispositionTaskTriggerHandler {
    
    public static void handleAfterInsert(Map<Id, Task> newTasks){
        if(newTasks != null && newTasks.size()>0){
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = nu_dse__Program__c.nu_dse__Disposition__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
            
            system.debug('### dispositions size: '+pickListValuesList.size());
            
            for(Task tsk: newTasks.values()){
                for(String str: pickListValuesList){
                    if(tsk.Subject.startsWith(str)){
                        if(tsk.Subject.length()==str.length() && tsk.Department__c != NULL){
                            system.debug('Task does not contain sub-disposition');
                            tsk.adderror('Task does not contain Sub-Disposition');
                            break;
                        }else{
                            system.debug('Task contains sub-disposition');
                            break;
                        }
                    }
                }
            }
        }
    }
}