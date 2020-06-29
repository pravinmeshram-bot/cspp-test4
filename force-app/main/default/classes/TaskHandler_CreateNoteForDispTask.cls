public class TaskHandler_CreateNoteForDispTask {

    // creates a Note when IsNote checkbox is set to true in a Task that is created from NuDebt Client Page Disposition Bar.
    
    public static void createNotes(List<Task> newList) {
    	//String programKeyfix = nu_dse__Program__c.sObjectType.getDescribe().getKeyPrefix();
        List<Note> notesToBeCreated = new List<Note>();
        List<CaseComment> CommentsToBeCreated = new List<CaseComment>();
        
        //set<String> programIds = new set<String>();
        for (Task dispTask : newList) {
            if(dispTask.SOP__c == null){
            	//Changes done by Uchit for Case Email reply issue: Added condition to bypass the note creation when task is related to Case
                String sObjName = '';
                if(dispTask.WhatId != null)
                    sObjName = dispTask.WhatId.getSObjectType().getDescribe().getName();
                if (String.isNotBlank(dispTask.WhatId)  && dispTask.IsNote__c == true  && !'Case'.equalsIgnoreCase(sObjName)) {                   
                    Note taskNote = new Note();
                    taskNote.ParentId = dispTask.WhatId;
                    taskNote.Title = dispTask.Subject;
                    taskNote.Body = dispTask.Description;
                    notesToBeCreated.add(taskNote);
                } /*else if('Case'.equalsIgnoreCase(sObjName) && dispTask.IsNote__c == true){
                    CaseComment cm = new CaseComment();
                    cm.CommentBody = dispTask.Description;
                    cm.ParentId = dispTask.WhatId;
                    cm.IsPublished = true;
                    CommentsToBeCreated.add(cm);
                }*/
                
                /*if(dispTask.whatId != null && String.valueOf(dispTask.whatId).startsWith(programKeyfix)){
                    programIds.add(dispTask.whatId);
                }*/
            }
        }
        
        /*if(programIds != null && programIds.size()>0){
            map<Id, nu_dse__Program__c> programMap = new map<Id, nu_dse__Program__c>([Select Id, Name, nu_dse__Last_Disposition__c 
                                                                                      From nu_dse__Program__c 
                                                                                      Where Id IN: programIds]);
            if(programMap != null && programMap.size()>0){
                for (Task dispTask : newList) {
                	
                }
            }
        }*/
        if(!notesToBeCreated.isEmpty()){
            insert notesToBeCreated;
        }
            
        /*if(!CommentsToBeCreated.isEmpty())
            insert CommentsToBeCreated;*/
    }
}