global with sharing class testVFClass2 {

    public PageReference Refresh() {
        return null;
    }


    public String document { get; set; }
    public String Titles{get;set;}
    public String Bd{get;set;}
    public List<Account> acclist{set; get;}
    public String dealId{get;set;}
    public Boolean isGrouptask{get;set;}
    public String groupView{get;set;}
    public String taskView{get;set;}
    public String eventView{get;set;}
    public Boolean istask{get;set;}
    public Boolean isevent{get;set;}
    public List<nu_dse__Group_Task__c> openGroupTaskList{set; get;}
    public List<nu_dse__Group_Task__c> closeGroupTaskList{set; get;}
    public nu_dse__Group_Task__c createGroupTask{set; get;}
    public task scheduleTask{set; get;}
    public event scheduleEvent{set; get;}
    public List<task> openTaskList{set; get;}
    public List<task> ClosedTaskList { get; set;}
    public List<Event> openEventList{set; get;}
    public List<Event> ClosedEventList { get; set; }
    public List<task> openNoteList{set; get;}
    public List<task> ClosedNoteList { get; set; }
    public List<task> openAttTaskList{set; get;}
    public List<task> closedAttTaskList{set; get;}
    public static Id groupTaskId {get; set;}
    public Id TaskId {get; set;}
    public Id EventId {get; set;}
    global Id RecordId {get; set;}
    public Boolean NewNote { get; set; }
    public Boolean NewNotesID{ get; set; }
    public List<nu_dse__group_task__history> GroupTaskHistoryList { get; set; }
    public List<Attachment> GroupTaskAttachmentList { get; set; }
    public Note nt = new Note();
    public List<Note> GroupTaskNoteList { get; set; }
    public List<Note> GroupTaskNoteList1 { get; set; }
    Public Attachment myfile { get; set; }
    public blob fileBlob {get;set;}
    //public String fileName {get;set;}
    public String taskAttachmentList{get;set;}
    
    public nu_dse__Group_Task__c groupTask {get;set;}
    public String Error {get;set;}
    
    public testVFClass2 () {
        initialize();
    }
    
    private void initialize(){
        RecordId = apexpages.currentpage().getparameters().get('recordId');
        system.debug('RecordId' + RecordId);
        NewNote=false;
        NewNotesID=false;
        /* the Boolen to show and hide the create group Task Modal */
        this.isGrouptask = False;
        this.groupView = '';
        //createGroupTask = new nu_dse__Group_Task__c();
        /* the Boolen to show and hide the Task Modal */
        this.istask = False;
        this.taskView = '';
        this.scheduleTask= new task();
        
        
        if (RecordId != null) {
            getData();
        }
    }
    
    private static List<nu_dse__Group_Task__c> getGroupTask(Boolean isOpen, Id recordId){
        List<nu_dse__Group_Task__c> lstTaskToReturn = new List<nu_dse__Group_Task__c> ();
        
        /*String fifteenDigitId = '';
        String eighteenDigitId = recordId;
        
        if(eighteenDigitId!=NULL && eighteenDigitId.length() == 18){
            fifteenDigitId = String.valueOf(eighteenDigitId).substring(0, 15);
        }else{
            fifteenDigitId = eighteenDigitId;
            Id recId = recordId;
            eighteenDigitId = recId;
        }*/
        
        if(isOpen){
            /*lstTaskToReturn = [SELECT Id, nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, 
                    nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c 
                    FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c NOT IN ('Completed', 'Canceled') AND 
                    (nu_dse__Related_To__c =: fifteenDigitId OR nu_dse__Related_To__c =: eighteenDigitId)];*/
            lstTaskToReturn = [SELECT Id, nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, 
                    nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c 
                    FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c NOT IN ('Completed', 'Canceled') AND 
                     Program__c =: recordId order by nu_dse__ActivityDate__c desc];
        }else{
            /*lstTaskToReturn = [SELECT Id,nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, 
                    nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c 
                    FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c  IN ('Completed', 'Canceled') AND 
                    (nu_dse__Related_To__c =: fifteenDigitId OR nu_dse__Related_To__c =: eighteenDigitId)];*/
            lstTaskToReturn = [SELECT Id,nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, 
                    nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c 
                    FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c  IN ('Completed', 'Canceled') AND 
                    Program__c =: recordId order by LastModifiedDate desc];
        }
        
        return lstTaskToReturn;
    }
    
    Public Void getdata() {
    
        //Open & Closed group task
        this.openGroupTaskList = new List<nu_dse__Group_Task__c>();
        this.openGroupTaskList  = getGroupTask(true, recordId);
        this.closeGroupTaskList = new List<nu_dse__Group_Task__c>();
        this.closeGroupTaskList = getGroupTask(false, recordId);
        
        //Open & Closed task
        this.openTaskList = new List<task>();
        this.openTaskList = [SELECT Subject, ActivityDate, Status, Priority, Description, CreatedById, OwnerId 
                    FROM task WHERE Status NOT IN ('Completed', 'Canceled') AND is_attorney_notes__c = false
                       AND IsNote__c = FALSE AND WhatId =: recordId order by  ActivityDate desc];
        
        this.ClosedTaskList = new List<task>();
        this.ClosedTaskList = [SELECT Subject, ActivityDate, Status, Priority, Description, CreatedById, OwnerId 
                        FROM task WHERE Status IN ('Completed', 'Canceled') AND is_attorney_notes__c = false
                        AND IsNote__c = FALSE AND WhatId =: RecordId order by CreatedDate desc]; 
        
        //Open & Closed Event
        this.openEventList= new List<Event>();
        this.openEventList= [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description 
                        FROM Event WHERE StartDateTime >= TODAY AND WhatId =: RecordId order by  ActivityDate desc];
        
        this.ClosedEventList = new List<Event>();
        this.ClosedEventList = [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description 
                        FROM Event WHERE StartDateTime < TODAY AND WhatId =: RecordId order by  ActivityDate desc]; 
        
        //Open & Closed Note
      //  this.openNoteList= new List<task>();
        //this.openNoteList= [SELECT Subject, ActivityDate, Status, Priority, Description,CreatedById,OwnerId,CreatedDate 
          //              FROM task WHERE Status NOT IN ('Completed', 'Canceled') AND IsNote__c = TRUE AND WhatId =: RecordId order by CreatedDate desc]; 
        
        //this.ClosedNoteList = new List<task>();
        //this.ClosedNoteList = [SELECT Subject, ActivityDate, Status, Priority, Description,CreatedById,OwnerId,CreatedDate
          //              FROM task WHERE Status IN ('Completed', 'Canceled') AND IsNote__c = TRUE AND WhatId =: RecordId order by  CreatedDate desc ];
        
        //Open & Closed Attorney task
        this.openAttTaskList = new List<task>();            
        this.openAttTaskList = [Select Id, subject, status, ActivityDate, Excela_TradeLine__r.Name, Priority, description, OwnerId
                        from task where is_attorney_notes__c = true and recordtype.name = 'Attorney Notes' AND IsNote__c = false
                        AND Status NOT IN ('Completed', 'Canceled') AND Program__c =: RecordId order by Attorney_Notes_Created_Date__c desc];
        
        this.closedAttTaskList = new List<task>();      
        this.closedAttTaskList = [Select Id, subject, status, ActivityDate, Excela_TradeLine__c, Excela_TradeLine__r.Name, Priority, description, OwnerId
                        from task where is_attorney_notes__c = true and recordtype.name = 'Attorney Notes' AND IsNote__c = false
                        AND Program__c =: RecordId order by Attorney_Notes_Created_Date__c desc];
     
    }
    
    @RemoteAction
    global Static String getGroupTask(String recordId){
        List<GroupTaskWrapper> gtList = new List<GroupTaskWrapper>();
        for(nu_dse__Group_Task__c gtItem : getGroupTask(true, recordId))
                                              
        {
            GroupTaskWrapper gtWrap = new GroupTaskWrapper();
            gtWrap.Id = gtItem.Id;
            gtWrap.NUDSESubject = (gtItem.nu_dse__Subject__c != null ? gtItem.nu_dse__Subject__c : '');
            if(gtItem.nu_dse__ActivityDate__c != null){
                gtWrap.NUDSEActivityDate = String.valueOf(gtItem.nu_dse__ActivityDate__c.month() + '/' + gtItem.nu_dse__ActivityDate__c.day() + '/' + gtItem.nu_dse__ActivityDate__c.year());
            }
            gtWrap.NUDSEType = (gtItem.nu_dse__Type__c != null ? gtItem.nu_dse__Type__c : '');
            gtWrap.NUDSEDescription = (gtItem.nu_dse__Description__c != null ? gtItem.nu_dse__Description__c : '');
            gtWrap.NUDSEStatus = (gtItem.nu_dse__Status__c != null ? gtItem.nu_dse__Status__c : '');
            gtWrap.NDSCreatedBy = (gtItem.NDS_Created_By__c != null ? gtItem.NDS_Created_By__c : '');
            gtWrap.NDSAssigned = (gtItem.NDS_Assigned__c != null ? gtItem.NDS_Assigned__c : '');
            gtWrap.OwnerName = (gtItem.Owner_Name__c != null ? gtItem.Owner_Name__c : '');
            gtList.add(gtWrap);
        }
        
        return JSON.serialize(gtList);
    }
    
    @RemoteAction
    global Static String getGroupTaskHistory(String recordId){
        List<GroupTaskHistoryWrapper> gthList = new List<GroupTaskHistoryWrapper>();
        for(nu_dse__Group_Task__c gthItem : getGroupTask(false, recordId)){
            GroupTaskHistoryWrapper gthWrap = new GroupTaskHistoryWrapper();
            gthWrap.Id = gthItem.Id;
            gthWrap.NUDSESubject = (gthItem.nu_dse__Subject__c != null ? gthItem.nu_dse__Subject__c : '');
            if(gthItem.nu_dse__ActivityDate__c != null){
                gthWrap.NUDSEActivityDate = String.valueOf(gthItem.nu_dse__ActivityDate__c.month() + '/' + gthItem.nu_dse__ActivityDate__c.day() + '/' + gthItem.nu_dse__ActivityDate__c.year());
            }
            gthWrap.NUDSEType = (gthItem.nu_dse__Type__c != null ? gthItem.nu_dse__Type__c : '');
            gthWrap.NUDSEDescription = (gthItem.nu_dse__Description__c != null ? gthItem.nu_dse__Description__c : '');
            gthWrap.NUDSEStatus = (gthItem.nu_dse__Status__c != null ? gthItem.nu_dse__Status__c : '');
            gthWrap.NDSCreatedBy = (gthItem.NDS_Created_By__c != null ? gthItem.NDS_Created_By__c : '');
            gthWrap.NDSAssigned = (gthItem.NDS_Assigned__c != null ? gthItem.NDS_Assigned__c : '');
            gthWrap.OwnerName = (gthItem.Owner_Name__c != null ? gthItem.Owner_Name__c : '');
            gthList.add(gthWrap);
        }
        
        return JSON.serialize(gthList);
    }
    
    @RemoteAction
    global Static String getOpenTask(String recordId){
        List<OpenTaskWrapper> taskList = new List<OpenTaskWrapper>();
        if(String.isNotBlank(recordId)){
            for(Task tItem : [SELECT Id, Subject, ActivityDate, Status, Priority, Description, CreatedBy.Name, Owner.Name FROM task WHERE Status NOT IN ('Completed', 'Canceled') AND IsNote__c = FALSE AND WhatId =: recordId order by  ActivityDate desc])
            {
                OpenTaskWrapper otWrap = new OpenTaskWrapper();
                otWrap.Id = tItem.Id;
                otWrap.Subject = (tItem.Subject != null ? tItem.Subject : '');
                if(tItem.ActivityDate != null){
                    otWrap.ActivityDate = String.valueOf(tItem.ActivityDate.month() + '/' + tItem.ActivityDate.day() + '/' + tItem.ActivityDate.year());
                }
                otWrap.Status = (tItem.Status != null ? tItem.Status : '');
                otWrap.Priority = (tItem.Priority != null ? tItem.Priority : '');
                otWrap.Description = (tItem.Description != null ? tItem.Description : '');
                otWrap.CreatedBy = (tItem.CreatedBy.Name != null ? tItem.CreatedBy.Name : '');
                otWrap.Owner = (tItem.Owner.Name != null ? tItem.Owner.Name : '');
                taskList.add(otWrap);
            }
        }
        return JSON.serialize(taskList);
    }
    
    @RemoteAction
    global Static String getOpenTaskHistory(String recordId){
        List<OpenTaskWrapper> taskList = new List<OpenTaskWrapper>();
        if(String.isNotBlank(recordId)){
            for(Task tItem : [SELECT Id, Subject, ActivityDate, Status, Priority, Description, CreatedBy.Name, Owner.Name FROM task WHERE Status IN ('Completed', 'Canceled') AND IsNote__c = FALSE AND WhatId =: recordId order by  LastModifiedDate desc]){
                OpenTaskWrapper otWrap = new OpenTaskWrapper();
                otWrap.Id = tItem.Id;
                otWrap.Subject = (tItem.Subject != null ? tItem.Subject : '');
                if(tItem.ActivityDate != null){
                    otWrap.ActivityDate = String.valueOf(tItem.ActivityDate.month() + '/' + tItem.ActivityDate.day() + '/' + tItem.ActivityDate.year());
                }
                otWrap.Status = (tItem.Status != null ? tItem.Status : '');
                otWrap.Priority = (tItem.Priority != null ? tItem.Priority : '');
                otWrap.Description = (tItem.Description != null ? tItem.Description : '');
                otWrap.CreatedBy = (tItem.CreatedBy.Name != null ? tItem.CreatedBy.Name : '');
                otWrap.Owner = (tItem.Owner.Name != null ? tItem.Owner.Name : '');
                taskList.add(otWrap);
            }
        }
        return JSON.serialize(taskList);
    }
    
     @RemoteAction
    global Static String getOpenEvent(String recordId){
        List<OpenEventWrapper> openEventList = new List<OpenEventWrapper>();
        if(String.isNotBlank(recordId)){
            for(Event evItem : [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description FROM Event WHERE StartDateTime >= TODAY AND WhatId =: RecordId order by  ActivityDate desc]){
                OpenEventWrapper evWrap = new OpenEventWrapper();
                evWrap.Id = evItem.Id;
                evWrap.Subject = evItem.Subject;
                if(evItem.ActivityDate != null){
                    evWrap.ActivityDate = String.valueOf(evItem.ActivityDate.month() + '/' + evItem.ActivityDate.day() + '/' + evItem.ActivityDate.year());
                }
                if(evItem.StartDateTime != null){
                    evWrap.StartDateTime = String.valueOf(evItem.StartDateTime.month() + '/' + evItem.StartDateTime.day() + '/' + evItem.StartDateTime.year());
                }
                if(evItem.EndDateTime != null){
                    evWrap.EndDateTime = String.valueOf(evItem.EndDateTime.month() + '/' + evItem.EndDateTime.day() + '/' + evItem.EndDateTime.year());
                }
                evWrap.Description = evItem.Description;
                openEventList.add(evWrap);
            }
        }
        return JSON.serialize(openEventList);
    }
    
    @RemoteAction
    global Static String getEventHistory(String recordId){
        List<OpenEventWrapper> openEventList = new List<OpenEventWrapper>();
        if(String.isNotBlank(recordId)){
            for(Event evItem : [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description FROM Event WHERE StartDateTime < TODAY AND WhatId =: RecordId]){
                OpenEventWrapper evWrap = new OpenEventWrapper();
                evWrap.Id = evItem.Id;
                evWrap.Subject = evItem.Subject;
                if(evItem.ActivityDate != null){
                    evWrap.ActivityDate = String.valueOf(evItem.ActivityDate.month() + '/' + evItem.ActivityDate.day() + '/' + evItem.ActivityDate.year());
                }
                if(evItem.StartDateTime != null){
                    evWrap.StartDateTime = String.valueOf(evItem.StartDateTime.month() + '/' + evItem.StartDateTime.day() + '/' + evItem.StartDateTime.year());
                }
                if(evItem.EndDateTime != null){
                    evWrap.EndDateTime = String.valueOf(evItem.EndDateTime.month() + '/' + evItem.EndDateTime.day() + '/' + evItem.EndDateTime.year());
                }
                evWrap.Description = evItem.Description;
                openEventList.add(evWrap);
            }
        }
        return JSON.serialize(openEventList);
    }
    
     @RemoteAction
     global Static String getOpenNotes(String recordId){
        List<OpenNotesWrapper> openNotesList = new List<OpenNotesWrapper>();
        if(String.isNotBlank(recordId)){
            for(Task ntItem :  [SELECT Id, Subject, ActivityDate, Status, Priority, Description,CreatedDate, CreatedBy.Name, Owner.Name FROM task WHERE Status NOT IN ('Completed', 'Canceled') AND IsNote__c = true AND WhatId =: recordId order by  ActivityDate desc]){
                 OpenNotesWrapper ntWrap = new OpenNotesWrapper();
                ntWrap.Id = ntItem.Id;
                ntWrap.Subject = (ntItem.Subject != null ? ntItem.Subject : '');
                if(ntItem.ActivityDate != null){
                    ntWrap.ActivityDate = String.valueOf(ntItem.ActivityDate.month() + '/' + ntItem.ActivityDate.day() + '/' + ntItem.ActivityDate.year());
                }
                ntWrap.Status = (ntItem.Status != null ? ntItem.Status : '');
                ntWrap.Priority = (ntItem.Priority != null ? ntItem.Priority : '');
                ntWrap.Description = (ntItem.Description != null ? ntItem.Description : '');
                ntWrap.CreatedBy = (ntItem.CreatedBy.Name != null ? ntItem.CreatedBy.Name : '');
                ntWrap.CreatedDate = String.valueOf(ntItem.CreatedDate.month() + '/' + ntItem.CreatedDate.day() + '/' + ntItem.CreatedDate.year());
                ntWrap.Owner = (ntItem.Owner.Name != null ? ntItem.Owner.Name : '');
                openNotesList.add(ntWrap);
            }
        }
        return JSON.serialize(openNotesList);
    }
    
    @RemoteAction
     global Static String getNotestHistory(String recordId){
        List<OpenNotesWrapper> openNotesList = new List<OpenNotesWrapper>();
        if(String.isNotBlank(recordId)){
            for(Task ntItem :  [SELECT Id, Subject, ActivityDate, Status, Priority, Description,LastModifiedDate, CreatedBy.Name, Owner.Name FROM task WHERE Status IN ('Completed', 'Canceled') AND IsNote__c = true AND WhatId =: recordId order by  LastModifiedDate desc]){
                 OpenNotesWrapper ntWrap = new OpenNotesWrapper();
                ntWrap.Id = ntItem.Id;
                ntWrap.Subject = (ntItem.Subject != null ? ntItem.Subject : '');
                if(ntItem.ActivityDate != null){
                    ntWrap.ActivityDate = String.valueOf(ntItem.ActivityDate.month() + '/' + ntItem.ActivityDate.day() + '/' + ntItem.ActivityDate.year());
                }
                ntWrap.Status = (ntItem.Status != null ? ntItem.Status : '');
                ntWrap.Priority = (ntItem.Priority != null ? ntItem.Priority : '');
                ntWrap.Description = (ntItem.Description != null ? ntItem.Description : '');
                ntWrap.LastModifiedDate = String.valueOf(ntItem.LastModifiedDate.month() + '/' + ntItem.LastModifiedDate.day() + '/' + ntItem.LastModifiedDate.year());
                ntWrap.CreatedBy = (ntItem.CreatedBy.Name != null ? ntItem.CreatedBy.Name : '');
                ntWrap.Owner = (ntItem.Owner.Name != null ? ntItem.Owner.Name : '');
                openNotesList.add(ntWrap);
            }
        }
        return JSON.serialize(openNotesList);
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
    
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }  
    
    /****   To view Group Task ***/
    public void viewGroupTask() {
        system.debug('groupTaskId >> ' + groupTaskId);
        if (String.isNotBlank(groupTaskId)) {
            system.debug('groupTaskId >> ' + groupTaskId);
            dynamicqueryGroupTask();
            isGrouptask = True;
            groupView = 'View';
            myfile = new Attachment();
            GetGroupTaskInfo();   
        }
    }
    
    @RemoteAction
    global Static String getTaskAttachments(String taskIdForAttachments) {
        return null;
    }
    
    @RemoteAction
    global Static String getGTInfo(String groupTaskId) {
        system.debug('groupTaskId >> ' + groupTaskId);
        GTInfoWrapper gtInfoWrap = new GTInfoWrapper();
        List<NoteWrapper> noteList = new List<NoteWrapper>();
        List<GTHistoryWrapper> gtHisList = new  List<GTHistoryWrapper>();
        List<GTAttachment> attList = new List<GTAttachment>();
        for(Note nItem : [SELECT Id,Title,Body,CreatedDate,CreatedById,CreatedBy.Name, ParentId FROM Note WHERE ParentId=: groupTaskId order by CreatedDate desc] ){
            NoteWrapper nWrap = new NoteWrapper();
            nWrap.ParentId = nItem.ParentId;
            nWrap.Title = nItem.Title;
            nWrap.Body = nItem.Body;
            nWrap.CreatedBy = nItem.CreatedBy.Name;
            nWrap.noteId = nItem.Id;
            nWrap.CreatedDate = String.valueOf(nItem.CreatedDate.month() + '/' + nItem.CreatedDate.day() + '/' + nItem.CreatedDate.year());
            noteList.add(nWrap);
        }
        
        for(nu_dse__group_task__history gtHistory : [SELECT 
                    Id, OldValue, NewValue, CreatedDate,CreatedById,CreatedBy.Name, Field, ParentId 
                        FROM nu_dse__group_task__history WHERE ParentId=: groupTaskId order by CreatedDate desc]){
            GTHistoryWrapper gth = new GTHistoryWrapper(gtHistory);
            /*gth.ParentId = gtHistory.ParentId;
            gth.Field = gtHistory.Field;
            gth.CreatedDate = String.valueOf(gtHistory.CreatedDate.month() + '/' + gtHistory.CreatedDate.day() + '/' + gtHistory.CreatedDate.year());
            gth.CreatedBy = gtHistory.CreatedBy.Name;*/
            gtHisList.add(gth);
        }
        
        for(Attachment attItem : [SELECT Id, Name,ParentId FROM Attachment WHERE ParentId=: groupTaskId]){
            GTAttachment att = new GTAttachment();
            att.Id = attItem.Id;
            att.Name = attItem.Name;
            att.ParentId = attItem.ParentId;
            attList.add(att);
        }
        
        //Added by Uchit for S20-278
        for(ContentDocumentLink attItem : [SELECT ContentDocument.title,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: groupTaskId]){
            GTAttachment att = new GTAttachment();
            att.Id = attItem.ContentDocumentId;
            att.Name = attItem.ContentDocument.Title;
            att.ParentId = attItem.LinkedEntityId;
            attList.add(att);
            System.debug(attItem);
        }
        
        if(noteList != null && !noteList.isEmpty()){
           gtInfoWrap.noteList = noteList;
        }
        if(gtHisList != null && !gtHisList.isEmpty()){
           gtInfoWrap.gthList = gtHisList;
        }
        if(attList != null && !attList.isEmpty()){
           gtInfoWrap.attchList = attList;
        }
        
        system.debug('noteList >> ' + noteList);
        system.debug('gtHisList >> ' + gtHisList);
        system.debug('attList >> ' + attList);
        system.debug('gtInfoWrap >> ' + JSON.serialize(gtInfoWrap));
        
        return JSON.serialize(gtInfoWrap);
        
    }
    
    public void GetGroupTaskInfo() {
        system.debug('groupTaskId >> ' + groupTaskId);
        GroupTaskNoteList = new List<Note>();
        GroupTaskNoteList  = [SELECT Title,Body,CreatedDate,CreatedById, ParentId FROM Note WHERE ParentId=: groupTaskId order by CreatedDate desc];
        
        GroupTaskHistoryList = new List<nu_dse__group_task__history>();
        GroupTaskHistoryList = [SELECT CreatedDate,CreatedById,Field, ParentId FROM nu_dse__group_task__history WHERE ParentId=: groupTaskId order by CreatedDate desc]; 
        
        GroupTaskAttachmentList = new List<Attachment>();
        GroupTaskAttachmentList = [SELECT Id, Name,ParentId FROM Attachment WHERE ParentId=: groupTaskId]; 
        
        system.debug('GroupTaskNoteList >> ' + GroupTaskNoteList);
        system.debug('GroupTaskHistoryList >> ' + GroupTaskHistoryList);
        system.debug('GroupTaskAttachmentList >> ' + GroupTaskAttachmentList);
    }
    
    /** Edit Group Task Modal **/
    public void EditGroupTask() {
            
        if (String.isNotBlank(groupTaskId)) {
            
            dynamicqueryGroupTask();
            this.isGrouptask = True;
            this.groupView = 'Edit';
            myfile = new Attachment();
            this.GetGroupTaskInfo();
        }
    }
    public void dynamicqueryGroupTask() {
        
        String query = 'SELECT Id';
        createGroupTask = new nu_dse__Group_Task__c();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__CreateGroupTask','nu_dse__Group_Task__c');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
        }
        query += ',(Select Id, Name From Attachments) FROM nu_dse__Group_Task__c WHERE ID =: groupTaskId order by CreatedDate desc';
        List<nu_dse__Group_Task__c> sobjList = Database.query(query);
        if (sobjList.isEmpty() == False) {
            
            createGroupTask = sobjList[0];
        }
       // this.isGrouptask = True;
       system.debug('createGroupTask >> ' + createGroupTask);
    }
    
    /** To Open the Group Task */
    public void CreateGroupTask() {
        system.debug('In CreateGroupTask');
        createGroupTask = new nu_dse__Group_Task__c();
        this.isGrouptask = true;
        myfile = new Attachment();
        this.groupView = 'New';
        createGroupTask.nu_dse__Related_To__c = RecordId;
        createGroupTask.Program__c = RecordId;
        createGroupTask.OwnerId = UserInfo.getUserId();
        System.debug('CreateGroupTask >> '  + CreateGroupTask);
    }
    
    /** To Cancel the Group Task In Modal */
    public void cancelGroupTaskModal() {
        
        createGroupTask = new nu_dse__Group_Task__c();
        this.isGrouptask = false;
        this.groupView = '';
    }
    
    /* To Save the Group Task In Modal */
    public void saveGroupTaskModal() {
         
         String fileName = apexpages.currentpage().getparameters().get('param1');
         String fileType = apexpages.currentpage().getparameters().get('param2');
         String myString = apexpages.currentpage().getparameters().get('param3');
         System.debug('fileName'+fileName);
         System.debug('fileType'+fileType);
         System.debug('myString'+myString);
         system.debug('fileName >> ' +fileName);
         system.debug('fileBlob >> ' +fileBlob);
         
        /* if(createGroupTask.owner != null){
            upsert createGroupTask;
         }*/
         //this.myfile = new Attachment();
         upsert createGroupTask;
         
         if (createGroupTask.Id != null && String.isNotBlank(fileName)) {
             
             List<String> blobList = myString.split(',', 2);
             
             Attachment attachmentInstance = new Attachment();
             attachmentInstance.parentId = createGroupTask.Id;
             attachmentInstance.name=fileName;
             attachmentInstance.ContentType=fileType;
             //attachmentInstance.body = fileBlob;
             
             if (blobList.size() == 2) {
                 attachmentInstance.body = EncodingUtil.base64Decode(blobList[1]);
             }
             
             insert attachmentInstance;
             System.debug('attachmentInstance'+attachmentInstance);
         }
         
         createGroupTask = new nu_dse__Group_Task__c();
         this.isGrouptask = false;
         this.groupView = '';
    }
    
     /****   To view Task ***/
    public void viewTask() {
                
        if (String.isNotBlank(this.TaskId)) {
            
            dynamicqueryTask();
            this.taskView = 'View';
             this.istask = True;
            
        }
    }
    
    /** Close Task link function 
     ** @Developer : MindzCloud
     ** This function is called through action function to close a task
    **/
    public void closeTask() {
        if (String.isNotBlank(this.TaskId)) {
            Task taskToClose = new Task();
            taskToClose.Id = this.taskId;
            taskToClose.Status = 'Completed';
            update taskToClose;
            
            dynamicqueryTask();
        }
    }
    
    /** Edit Task Modal **/
    public void EditTask() {
            
        if (String.isNotBlank(this.TaskId)) {
            
            dynamicqueryTask();
            this.taskView = 'Edit';
            this.istask = True;
        }
    }
    
    public void dynamicqueryTask() {
        
        String query = 'SELECT Id';
        this.scheduleTask = new task();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__Activity_Tab_Edit','task');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
        }
        query += ', (Select Id, Name from Attachments) FROM task WHERE ID =: TaskId order by CreatedDate desc';
        system.debug('--query: ' + query);
        List<task> sobjList = Database.query(query);
        system.debug('--sobjectList : ' + sobjList);
        if (sobjList.isEmpty() == False) {
            
            this.scheduleTask = sobjList[0];
            if(scheduleTask.attachments != null){
                taskAttachmentList = JSON.serialize(scheduleTask.attachments);
            }else{
                taskAttachmentList = '';
            }
            system.debug('--taskAttachmentList ' + taskAttachmentList) ;
        }
        
    }
    
    /** To Open the Task */
    public void scheduleTask() {
  
      this.scheduleTask= new task();
      this.istask = True;
      this.taskView = 'New';
       this.scheduleTask.WhatId = RecordId;
    }
    
    /** To Cancel the Task In Modal */
    public void cancelTaskModal() {
        
        this.scheduleTask = new task();
        this.istask = false;
        this.taskView = '';
        
            }
    
    /* To Save the Task In Modal */
    public void saveTaskModal() {
         
         upsert scheduleTask;
         
         String fileName = apexpages.currentpage().getparameters().get('taskAttachFileName');
         String fileType = apexpages.currentpage().getparameters().get('taskAttachFileType');
         String myString = apexpages.currentpage().getparameters().get('taskAttachBody');
         System.debug('--fileName : ' + fileName);
         System.debug('--fileType : '+ fileType);
         System.debug('myString: ' + myString);
         system.debug('--fileBlob >> ' + fileBlob);
         
         if (scheduleTask.Id != null && String.isNotBlank(fileName)) {
            
            List<Task> lstTaskToAttach = [Select Id, OwnerId from Task where Id = :scheduleTask.Id order by CreatedDate desc];
             
             List<String> blobList = myString.split(',', 2);
             
             Attachment attachmentInstance = new Attachment();
             attachmentInstance.parentId = scheduleTask.Id;
             attachmentInstance.name=fileName;
             attachmentInstance.ContentType=fileType;
             //attachmentInstance.body = fileBlob;
             
             if(lstTaskToAttach != null && lstTaskToAttach.size() == 1){
                attachmentInstance.ownerId = lstTaskToAttach[0].ownerId;
             }
             
             if (blobList.size() == 2) {
                 attachmentInstance.body = EncodingUtil.base64Decode(blobList[1]);
             }
             
             insert attachmentInstance;
             System.debug('--attachmentInstance'+attachmentInstance);
         }
         
         this.istask = false;
         this.scheduleTask= new task();
         this.taskView = '';
    }
    
     /****   To view Event Modal ***/
    public void viewEvent() {
                
        if (String.isNotBlank(this.EventId)) {
            
            dynamicqueryEvent();
            this.eventView = 'View';
        }
    }
    
    /** Edit Group Task Modal **/
    public void EditEvent() {
            
        if (String.isNotBlank(this.EventId)) {
            
            dynamicqueryEvent();
            this.eventView = 'Edit';
        }
    }
    public void dynamicqueryEvent() {
        
        String query = 'SELECT Id';
        this.scheduleEvent = new event();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__Activity_Tab_Event_Fields','event');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
        }
        query += ' FROM event WHERE ID =: EventId';
                
        List<event> sobjList = Database.query(query);
                
        if (sobjList.isEmpty() == False) {
            
            this.scheduleEvent = sobjList[0];
        }
        this.isevent = True;
    }
    
    /** To Open the Event */
    public void scheduleEvent() {
  
      this.scheduleEvent = new event();
      this.isevent = True;
      this.eventView  = 'New';
      this.scheduleEvent.WhatId = RecordId;
    }
    
    /** To Cancel the Event In Modal */
    public void canceleventModal() {
        
        this.isevent = false;
        this.eventView  = '';
    }
    
    /* To Save the Event In Modal */
    public void saveeventModal() {
         try{
             upsert scheduleEvent;
             this.isevent = false;
             this.scheduleEvent= new event();
             this.eventView = '';
         }
         catch(Exception ex){
             this.Error = ex.getMessage();
         }
    }
    
    public void CreateNote() {
    
         this.NewNote = true;
         this.NewNotesID = true;  
         this.Titles='';
         this.Bd=''; 
    }
    
    
    public void CreateNotesSave() {    
        Note nt = new Note();
        //nt.id = RecordId;
        nt.Title = Titles;
        nt.Body  = Bd;
        nt.ParentId=grouptaskid;
        insert nt;
        nt.clear();
        this.NewNote = false;
        this.NewNotesID = false;
        GetGroupTaskInfo();    
    }
    public void cancelNotes() {
        
        this.NewNote = false;
        this.NewNotesID = false;
    }
    
    
    public void  refreshNotesApex() {
        /*PageReference pg = new PageReference('/apex/ActivityTabNew5_2?recordId='+RecordId); 
        pg.setRedirect(true);
        return pg;*/
        initialize();
    }
           
       
    
    global class GroupTaskWrapper{
        public String Id {get;set;}
        public String NUDSESubject {get;set;}
        public String NUDSEActivityDate  {get;set;}
        public String NUDSEType  {get;set;}
        public String NUDSEDescription {get;set;}
        public String NUDSEStatus {get;set;}
        public String NDSCreatedBy {get;set;}
        public String NDSAssigned {get;set;}
        public String OwnerName {get;set;}
    }
    
    global class GroupTaskHistoryWrapper{
        public String Id {get;set;}
        public String NUDSESubject {get;set;}
        public String NUDSEActivityDate  {get;set;}
        public String NUDSEType  {get;set;}
        public String NUDSEDescription {get;set;}
        public String NUDSEStatus {get;set;}
        public String NDSCreatedBy {get;set;}
        public String NDSAssigned {get;set;}
        public String OwnerName {get;set;}
    }
    
    global class OpenTaskWrapper{
        public String Id {get;set;}
        public String Subject {get;set;}
        public String ActivityDate {get;set;}
        public String Status {get;set;}
        public String Priority {get;set;}
        public String Description {get;set;}
        public String CreatedBy {get;set;}
        public String Owner {get;set;}
    }
    
    global class OpenEventWrapper{
        public String Id {get;set;}
        public String Subject {get;set;}
        public String ActivityDate {get;set;}
        public String StartDateTime {get;set;}
        public String EndDateTime {get;set;}
        public String Description {get;set;}
    }
    
    global class NoteWrapper{
        public String ParentId {get;set;}
        public String Title {get;set;}
        public String Body {get;set;}
        public String CreatedBy {get;set;}
        public String CreatedDate {get;set;}
        public String noteId {get;set;}
    }
    
    global class OpenNotesWrapper{
        public String Id {get;set;}
        public String Subject {get;set;}
        public String ActivityDate {get;set;}
        public String Status {get;set;}
        public String Priority {get;set;}
        public String Description {get;set;}
        public String CreatedBy {get;set;}
        public String CreatedDate {get;set;}
        public String LastModifiedDate {get;set;}
        public String Owner {get;set;}
        
    }
    
    global class GTHistoryWrapper{
        public String ParentId {get;set;}
        public String Field {get;set;}
        public String CreatedBy {get;set;}
        public String CreatedDate {get;set;}
        
        public GTHistoryWrapper(nu_dse__group_task__history gtHistory){
            this.ParentId = gtHistory.ParentId;
            this.Field = 'changed ' + gtHistory.Field + 'from ' + gtHistory.OldValue + ' to ' + gtHistory.newValue;
            this.CreatedDate = String.valueOf(gtHistory.CreatedDate.month() + '/' + gtHistory.CreatedDate.day() + '/' + gtHistory.CreatedDate.year());
            this.CreatedBy = gtHistory.CreatedBy.Name;
        }
    }   
    
    global class GTAttachment{
        public String Id {get;set;}
        public String Name {get;set;}
        public String ParentId {get;set;}
    }
    
    global class GTInfoWrapper{
        public List<NoteWrapper> noteList {get;set;}
        public List<GTHistoryWrapper> gthList {get;set;}
        public List<GTAttachment> attchList {get;set;}
    }
    
    
    
}