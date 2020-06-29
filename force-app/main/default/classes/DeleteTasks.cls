Global class DeleteTasks {

 /*     @InvocableMethod(label='Delete Task')
    global static List<DeleteTaskResponse> DeleteTasks(List<DeleteTaskRequest> request ){

        List<id> taskIds = new List<Id>(); 
        List<Task> taskDeletelist = new List<Task>(); 
        for(DeleteTaskRequest r: request){
            
            taskIds.add(r.uniqueIdentifier);
            
        }
        
        for(task t: [select id from Task where Unique_Identifier__c in :taskIds]){
            
            taskDeleteList.add(t);
            
        }
        
        list<DeleteTaskResponse> response = new List<DeleteTaskResponse>(); 
        try{
            
             delete taskDeleteList; 
            
            for(Task t: taskDeleteList){
                
                DeleteTaskResponse r = new DeleteTaskResponse(); 
                r.id = t.Id; 
                response.add(r);
            }
            
        }catch(Exception e){
            
                            
                DeleteTaskResponse r = new DeleteTaskResponse(); 
                r.id = null; 
                r.status = 'Error: ' + e.getMessage();
                response.add(r);
        }
       
        return response;
    }
    
    global class DeleteTaskRequest{
       
        @InvocableVariable(required=true)
        global String uniqueIdentifier;
    }
    
    global class DeleteTaskResponse{
        
         @InvocableVariable
        global String Id; 
        @InvocableVariable
        global string status; 
        
    }*/
}