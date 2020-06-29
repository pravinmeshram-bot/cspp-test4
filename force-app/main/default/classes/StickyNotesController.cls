global with sharing class StickyNotesController implements nu_dse.IDashboardComponent {
    global String getComponentName() {
        return 'Sticky Notes';
    }
    
    global ApexPages.Component getComponent(Id parentId) {
        return new Component.Sticky_Note(recordId = parentId);
    }
    
    @RemoteAction
    global static List<Notes> getNotes(Id whatId) {
        List<Task> taskList = [SELECT Id, Subject, Description, ActivityDate FROM Task WHERE WhatId = :whatId AND  nu_dse__Is_Sticky_Note__c = true ORDER BY CreatedDate LIMIT 4];
        
        List<Notes> noteList = new List<Notes>();
        
        for(Task task : taskList) {
            noteList.add(new Notes(task));
        }
        
        return noteList;
    }
    
    global class Notes {
        public String subject;
        public Id recordId;
        public String description;
        public Date activityDate;
        
        global Notes(Task task) {
            this.subject = task.Subject;
            this.recordId = task.Id;
            this.description = task.Description;
            this.activityDate = task.ActivityDate;
        }
    }
}