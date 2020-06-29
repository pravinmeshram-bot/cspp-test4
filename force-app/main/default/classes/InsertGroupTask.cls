global class InsertGroupTask {
    
    static Map<String, Id> queueId = new Map<String, Id>();
    static Map<String, Id> templateMap = new Map<String, Id>();
    static Boolean mapConstructed = False;
    static Map<String, Holiday> holidayMap = new Map<String, Holiday>();
    static Map<Id, String> taskDescriptionByProgramIdMap = new Map<Id, String>();
    static Map<Id, String> taskSupplementalByProgramIdMap = new Map<Id, String>();
    
    @InvocableMethod(label='Insert Group Task')
    global static List<CreateGroupTaskResponse> invoke(List<CreateGroupTaskRequest> request ){
        
        if (mapConstructed == False) {
            queueId = getQueueMap();
            templateMap = getTemplateMap(); 
            holidayMap = Holidays.getHolidaysMap();
            taskDescriptionByProgramIdMap = getTaskDescriptionByProgramIdMap(request);
            mapConstructed = True;
        }
        
        set<String> parentIdsList = new set<String>();
        set<String> subjectList = new set<String>();
        set<String> ownerList = new set<String>();
        for(CreateGroupTaskRequest tr: request) {
            parentIdsList.add(tr.parentId);
            subjectList.add(tr.subject);
            subjectList.add('contact client request (CS Ob calls)');
            if (queueId.isEmpty() == False && String.isNotBlank(tr.queueName) && queueId.ContainsKey(tr.queueName) && queueId.get(tr.queueName) != null) {
                ownerList.add(queueId.get(tr.queueName)); 
            } else  if (tr.ownerId != null) {
                ownerList.add(tr.ownerId); 
            }
            
            if (queueId.isEmpty() == False && queueId.ContainsKey('CS_Outbound') && queueId.get('CS_Outbound') != null) {
                ownerList.add(queueId.get('CS_Outbound')); 
            }
        }
        
        map<String, nu_dse__Group_Task__c> existingGTMap = new map<String, nu_dse__Group_Task__c>();
        list<nu_dse__Group_Task__c> existingGTs = [Select Id, Name, nu_dse__Subject__c, OwnerId, nu_dse__Related_To__c,
                                                   Program__c, Program__r.OwnerId
                                                   From nu_dse__Group_Task__c 
                                                   Where nu_dse__Subject__c IN: subjectList AND 
                                                   OwnerId IN: ownerList AND 
                                                   nu_dse__Status__c !='Completed' AND
                                                   nu_dse__Related_To__c IN: parentIdsList];
        if(existingGTs != null && existingGTs.size()>0){
            for(nu_dse__Group_Task__c gt: existingGTs){
                existingGTMap.put(gt.nu_dse__Subject__c+'~'+gt.OwnerId+'~'+gt.nu_dse__Related_To__c, gt);
                existingGTMap.put(gt.nu_dse__Subject__c+'~'+gt.Program__r.OwnerId+'~'+gt.nu_dse__Related_To__c, gt);
                
            }
        }
        
        List<nu_dse__Group_Task__c> groupTaskUpsertList = new List<nu_dse__Group_Task__c>(); 
        String programKeyPrefix = nu_dse__Program__c.sObjectType.getDescribe().getKeyPrefix();
        
        for (CreateGroupTaskRequest tr: request) {
            System.debug(tr);
            Boolean isGTExist = false;
            Date activityDate = tr.activityDate; 
            activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
            system.debug('date getting from holaday  => '+activityDate);
            nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c(IsDispositionTask__c=true);
            
            Boolean isSupplement = false;
            if(taskSupplementalByProgramIdMap.ContainsKey(tr.parentId) && taskSupplementalByProgramIdMap.Get(tr.parentId) != Null){
                String supplementVal=taskSupplementalByProgramIdMap.Get(tr.parentId);
                if(supplementVal.equalsIgnoreCase('outbound call requested')){
                    isSupplement=true;
                }
            }
            
            if(isSupplement || test.isRunningTest()){
                // Supplement GT
                System.debug('is supplement');
                nu_dse__Group_Task__c supplementGroupTask = new nu_dse__Group_Task__c(IsDispositionTask__c = true);
                if (queueId.isEmpty() == False && queueId.ContainsKey('CS_Outbound') && queueId.get('CS_Outbound') != null) {
                    supplementGroupTask.ownerId = queueId.get('CS_Outbound'); 
                } else  if (tr.ownerId != null) {
                    supplementGroupTask.ownerId = tr.ownerId; 
                }
                
                if(existingGTMap != null && existingGTMap.size()>0){
                    System.debug(existingGTMap);
                    if(existingGTMap.containsKey('contact client request (CS Ob calls)~'+supplementGroupTask.ownerId+'~'+tr.parentId)){
                        System.debug('1st if');
                        isGTExist=true;
                    }
                    
                    if((tr.programOwner != null && tr.programOwner.trim().length()> 0) && existingGTMap.containsKey('contact client request (CS Ob calls)~'+tr.programOwner+'~'+tr.parentId)){
                        System.debug('2nd if');
                        isGTExist=true;
                    }
                }
                
                if(String.valueOf(tr.parentId).startsWith(programKeyPrefix)){
                    supplementGroupTask.Program__c = tr.parentId;
                }
                supplementGroupTask.nu_dse__Related_To__c = tr.parentId;
                supplementGroupTask.nu_dse__Unique_Identifier__c = tr.uniqueIdentifier + 'Outbound';
                supplementGroupTask.nu_dse__Subject__c = 'contact client request (CS Ob calls)';
                supplementGroupTask.Subject_Picklist__c = 'contact client request (CS Ob calls)';
                //supplementGroupTask.nu_dse__ActivityDate__c = System.Today().addDays(4);
                supplementGroupTask.nu_dse__ActivityDate__c =   Holidays.getNextWorkingDay(holidayMap, System.Today().addDays(4));
                
                
                if (!taskDescriptionByProgramIdMap.isEmpty() && taskDescriptionByProgramIdMap.containsKey(tr.parentId) && taskDescriptionByProgramIdMap.get(tr.parentId) != null) {
                    supplementGroupTask.nu_dse__Description__c = taskDescriptionByProgramIdMap.get(tr.parentId);
                }
                
                if(!isGTExist){
                    System.debug('supplemental group task insert');
                    groupTaskUpsertList.add(supplementGroupTask);
                }
                isGTExist =false;
            }
            
            if(true){
            
                System.debug('regular group task');
                // All regular GT from Process Builder
                if(queueId.isEmpty() == False && String.isNotBlank(tr.queueName) && queueId.ContainsKey(tr.queueName) && queueId.get(tr.queueName) != null) {
                    groupTaskInstance.ownerId = queueId.get(tr.queueName); 
                } else  if (tr.ownerId != null) {
                    groupTaskInstance.ownerId = tr.ownerId; 
                }
                if(existingGTMap != null && existingGTMap.size()>0){
                    if(existingGTMap.containsKey(tr.subject+'~'+groupTaskInstance.ownerId+'~'+tr.parentId)){
                        isGTExist=true;
                    }
                    
                    if((tr.programOwner != null && tr.programOwner.trim().length()> 0) && existingGTMap.containsKey(tr.subject+'~'+tr.programOwner+'~'+tr.parentId)){
                        isGTExist=true;
                    }
                }
                groupTaskInstance.nu_dse__Subject__c = tr.subject; 
                groupTaskInstance.nu_dse__ActivityDate__c = activityDate; 
            system.debug('Actuall date on gt => '+groupTaskInstance.nu_dse__ActivityDate__c);
            
            if (!taskDescriptionByProgramIdMap.isEmpty() && taskDescriptionByProgramIdMap.containsKey(tr.parentId) && taskDescriptionByProgramIdMap.get(tr.parentId) != null) {
                groupTaskInstance.nu_dse__Description__c = taskDescriptionByProgramIdMap.get(tr.parentId);
            }
            
            groupTaskInstance.nu_dse__Unique_Identifier__c = tr.uniqueIdentifier;
            if(String.valueOf(tr.parentId).startsWith(programKeyPrefix)){
                groupTaskInstance.Program__c = tr.parentId;
            }
            groupTaskInstance.nu_dse__Related_To__c = tr.parentId;
            system.debug('+++++taskDescriptionByProgramIdMap+++++'+taskDescriptionByProgramIdMap);
            system.debug('+++++desc+++++'+taskDescriptionByProgramIdMap.get(tr.parentId));  
            
            
            if (templateMap.isEmpty() == False && templateMap.containsKey(tr.templateName) 
                && templateMap.get(tr.templateName) != null) {
                    
                    groupTaskInstance.nu_dse__Communication_Template__c = templateMap.get(tr.templateName);
                    
                } else if (tr.templateId != null) {
                    
                    groupTaskInstance.nu_dse__Communication_Template__c = tr.templateId;
                }
            
            if (String.isNotBlank(tr.subjectPicklist)) {
                groupTaskInstance.Subject_Picklist__c = tr.subjectPicklist;
            }
            
            /*if (String.isNotBlank(tr.description)) {
                groupTaskInstance.nu_dse__Description__c = tr.description;
            }*/          
            
            if (String.isNotBlank(tr.status)) {
                groupTaskInstance.nu_dse__Status__c = tr.status;
            }
            
            if(!isGTExist){
                groupTaskUpsertList.add(groupTaskInstance);
            }
            }
        }
        
        List<CreateGroupTaskResponse>  response = new List<CreateGroupTaskResponse>(); 
        try{
            System.debug(groupTaskUpsertList);
            insert groupTaskUpsertList; 
            System.debug(groupTaskUpsertList);
            for (nu_dse__Group_Task__c  grouptask: groupTaskUpsertList) {
                CreateGroupTaskResponse tresponse =  new CreateGroupTaskResponse();
                
                tresponse.Id = grouptask.Id; 
                if(!groupTask.nu_dse__subject__c.contains('contact client'))
                    response.add(tresponse);
            }
        }catch(Exception e){
            CreateGroupTaskResponse tresponse =  new CreateGroupTaskResponse();
            tresponse.error = 'Upsert Failed';
            response.add(tresponse);
            System.debug('upsert failed');
        }
        //System.debug(response);
        return response; 
        
    }
    
    global class CreateGroupTaskRequest {
        
        @InvocableVariable(required=true)
        global String uniqueIdentifier;
        @InvocableVariable
        global Id templateId;
        @InvocableVariable
        global String templateName;
        @InvocableVariable(required=true)
        global String subject; 
        @InvocableVariable(required=true) 
        global Date activityDate;
        @InvocableVariable(required=true) 
        global Id parentId; 
        @InvocableVariable
        global String status; 
        @InvocableVariable
        global Id ownerId = UserInfo.getUserId(); 
        @InvocableVariable
        global String queueName; 
        @InvocableVariable
        global String subjectPicklist;
        @InvocableVariable
        global String description;
        @InvocableVariable
        global String programOwner;
    } 
    
    global class CreateGroupTaskResponse{
        
        @InvocableVariable
        global String Id; 
        @InvocableVariable
        global String error; 
    }
    
    global static Map<String,id> getQueueMap(){
        
        Map<String,id> queueName = new Map<string,id>(); 
        
        for (Group q: [select id,Name,DeveloperName, Type, Email, ownerId from Group where Type='Queue']) {
            
            queueName.put(q.developerName, q.id);
        }
        return queueName; 
    }
    global static Map<string,id> getTemplateMap(){
        
        Map<string,id> template = new Map<String,id>();
        
        for (nu_dse__Communication_Template__c temp: [select id, name from nu_dse__Communication_Template__c]) {
            
            template.put(temp.name,temp.id);
        }
        return template; 
    }
    
    global static Map<Id, String> getTaskDescriptionByProgramIdMap(List<CreateGroupTaskRequest> requests){
        Set<Id> programIds = new Set<Id>();
        for (CreateGroupTaskRequest request: requests) {
            programIds.add(request.parentId);
        }
        
        taskDescriptionByProgramIdMap = new Map<Id, String>();
        taskSupplementalByProgramIdMap = new Map<Id, String>();

        for (Task singalTask: [Select Id, Description,Supplemental__c, Program__c From Task Where Program__c =:programIds Order By CreatedDate DESC]) {
            if (!taskDescriptionByProgramIdMap.containsKey(singalTask.Program__c)) {
                taskDescriptionByProgramIdMap.put(singalTask.Program__c, singalTask.Description);
            } else {
                continue;
            }
             if (!taskSupplementalByProgramIdMap.containsKey(singalTask.Program__c)) {
                taskSupplementalByProgramIdMap.put(singalTask.Program__c, singalTask.Supplemental__c);
            } else {
                continue;
            }
            
        }
        return taskDescriptionByProgramIdMap;
    }
}