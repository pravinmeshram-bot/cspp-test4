public with sharing class Attorney_NotesUtility {
	
	public static String endpoint ;
	public static String resource ;
	public static String username ;
	public static String password ;
	public static DateTime startDate;
    public static DateTime endDate;
	public static Integer duration ;
	public static Integer notesBatchSize ;
    public static Attorney_Notes_API_Config__c config;
	
	@future(callout=true)
	public static void getAttorneyNotes_Future(){ 
		getAttorneyNotes();
	}
	
    public static void getAttorneyNotes(){
    	HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http h = new Http();
        try{
            config = [Select Id, Endpoint__c, Resource__c, Username__c, Password__c, Timestamp_Duration__c, API_Batch_Size__c, Last_Timestamp__c from Attorney_Notes_API_Config__c limit 1];
            startDate = getStartTimestampForAPICall(config);
            if(config != null && config.Endpoint__c != null && config.Resource__c != null && config.Username__c != null && config.Password__c != null &&
                config.Timestamp_Duration__c != null && config.API_Batch_Size__c != null && config.Last_Timestamp__c != null && startDate != null){
                endpoint = config.Endpoint__c;
                resource = config.Resource__c;
                username = config.Username__c;
                password = config.Password__c;
                duration = Integer.valueOf(config.Timestamp_Duration__c);
                notesBatchSize = Integer.valueOf(config.API_Batch_Size__c);
                endDate = startDate.addMinutes(duration);
                
                String formattedStartDate = startDate.addSeconds(1).format('MM/dd/YYYY HH:mm:ss');
                String formattedEndDate = endDate.format('MM/dd/YYYY HH:mm:ss');
                String parameters = '?reportParameters=' + EncodingUtil.urlEncode('StartDate=' + formattedStartDate + ';EndDate=' + formattedEndDate,'UTF-8');
                
                req.setEndpoint(endpoint + resource + parameters);
                req.setMethod('GET');
                req.setTimeout(120000);
                
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                system.debug('authorizationHeader: '+authorizationHeader);
                req.setHeader('Authorization', authorizationHeader);            
        
                req.setHeader('Content-Type', 'application/json');
                system.debug('##request:'+req);
                res = h.send(req);
                //system.debug('##res:'+res.getBody());
                list<NotesWrapper> notesList = (list<NotesWrapper>) JSON.deserialize(res.getBody(), list<NotesWrapper>.class);
                system.debug('##res notesList:'+notesList.size());
                if(notesList != null && notesList.size() <= notesBatchSize){
                    createAttorneyNotes(notesList);
                }
            }else{
            	//Configuration missing
            	String errorMessage = 'API batch  is not invoked as configuration is missing, please check Attorney Notes API Config custom settings.';
            	System.debug('##Error:'+errorMessage);
            	createLog(errorMessage, errorMessage);
            }
        }catch(Exception ex){
            System.debug('##Exception:'+ex);
            System.debug('##Exception:'+ex.getStackTraceString());
            createLog(ex.getMessage(),ex.getStackTraceString());
        }
    }
    
    private static void createAttorneyNotes(list<NotesWrapper> notesList){
    	Id attorneyNotesTaskRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attorney Notes').getRecordTypeId();
        list<Task> attorneyNotes = new list<Task>();
        set<String> fileNumbers = new set<String>();
        set<String> debtIds = new set<String>();
        map<String, nu_dse__Program__c> fileNumberProgramMap;
        map<String, nu_dse__TradeLine__c> debtIdTradeLineMap;
        Datetime nextTimestamp = startDate;
        
        //Create file number and debtid maps
        for(NotesWrapper notes: notesList){
        	if(notes.Fusion_File_Number_lead != null && notes.Fusion_File_Number_lead != ''){
        		fileNumbers.add(notes.Fusion_File_Number_lead);
        	}
        	
        	if(notes.Debt_Id != null && notes.Debt_Id != ''){
        		debtIds.add(notes.Debt_Id);
        	}
        }
        fileNumberProgramMap = getPrograms(fileNumbers);
        debtIdTradeLineMap = getTradeLines(debtIds);
        //Create Task
        for(NotesWrapper notes: notesList){
        	Task attNotesTask = new Task(
        		RecordTypeId = attorneyNotesTaskRTId,
        		Is_Attorney_Notes__c = true,
        		Category__c = notes.Category,
        		Attorney_Notes_Lit_Def_File_Number__c = notes.Lit_Def_File_Number,
        		Attorney_Notes_Fusion_File_Number_Lead__c = notes.Fusion_File_Number_lead,
        		Attorney_Notes_Debt_Id__c = notes.Debt_Id,
                Subject = notes.Client_Name + ' - ' + notes.Category,
                Status = 'Completed'
        	);
        	
        	//Description field only supports 255 character length
        	if(notes.Message_pix500 != null && notes.Message_pix500.length() > 255){
        		attNotesTask.Description = notes.Message_pix500.subString(0,254);
        	}else{
        		attNotesTask.Description = notes.Message_pix500;	
        	}
        	
            if(notes.Created != ''){
           		attNotesTask.Attorney_Notes_Created_Date__c = parseTimestamp(notes.Created);
                attNotesTask.ActivityDate = parseTimestamp(notes.Created).date();
                if(nextTimestamp < attNotesTask.Attorney_Notes_Created_Date__c){
                    nextTimestamp = attNotesTask.Attorney_Notes_Created_Date__c;
                }
        	}
        	
        	//If lookup records not found just create task record with null value
        	if(debtIdTradeLineMap.containsKey(notes.Debt_Id)){
        		attNotesTask.Excela_Tradeline__c = debtIdTradeLineMap.get(notes.Debt_Id).Id;
        	}
        	if(fileNumberProgramMap.containsKey(notes.Fusion_File_Number_lead))
        	{
        		attNotesTask.Program__c = fileNumberProgramMap.get(notes.Fusion_File_Number_lead).Id;
        		attNotesTask.WhatId = fileNumberProgramMap.get(notes.Fusion_File_Number_lead).Id;
        	}
        	attorneyNotes.add(attNotesTask);
        }
        
        if(attorneyNotes.size() > 0){
        	insert attorneyNotes;
        }else{
            nextTimestamp = endDate;
        }
        if(nextTimestamp <= System.now()){
	        config.Last_Timestamp__c = nextTimestamp;
	        system.debug('##nextTimestamp:'+nextTimestamp);
	        update config;
        }
    }
    
    private static map<String, nu_dse__Program__c> getPrograms(set<String> fileNumbers){
    	map<String, nu_dse__Program__c> fileNumberProgramMap = new map<String, nu_dse__Program__c>();
    	for(nu_dse__Program__c prog : [Select Id, Import_ID__c from nu_dse__Program__c
    									where Import_ID__c IN: fileNumbers]){
    		fileNumberProgramMap.put(prog.Import_ID__c, prog);
    	}
    	return fileNumberProgramMap;
    }
    
    private static map<String, nu_dse__TradeLine__c> getTradeLines(set<String> debtIds){
    	map<String, nu_dse__TradeLine__c> debtIdTradeLineMap = new map<String, nu_dse__TradeLine__c>();
    	for(nu_dse__TradeLine__c trdln : [Select Id, Import_ID__c from nu_dse__TradeLine__c
    									where Import_ID__c IN: debtIds]){
    		debtIdTradeLineMap.put(trdln.Import_ID__c, trdln);
    	}
    	return debtIdTradeLineMap;
    }
    
    
    public static DateTime getStartTimestampForAPICall(Attorney_Notes_API_Config__c config){
    	Id attorneyNotesTaskRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Attorney Notes').getRecordTypeId();
        DateTime startDate;
        if(config.Last_Timestamp__c != null && config.Last_Timestamp__c <= System.now()){
        	startDate = config.Last_Timestamp__c;
        }else if(config.Last_Timestamp__c != null && config.Last_Timestamp__c > System.now()){
        	list<Task> taskList = [Select Id, Attorney_Notes_Created_Date__c from Task 
    							where RecordTypeId =: attorneyNotesTaskRTId
    							AND Is_Attorney_Notes__c = true
    							order by Attorney_Notes_Created_Date__c desc limit 1];
	    	if(!taskList.isEmpty()){
	    		startDate = taskList[0].Attorney_Notes_Created_Date__c;
	    	}
        }
    	
        system.debug('##startDate:'+startDate.format());
    	return startDate;
    }
    
    public static void createLog(String message, String stackTrace){
        System_Log__c sLog = new System_Log__c();
        sLog.Exception_Message__c = message;
        sLog.Exception_Description__c = stackTrace;
        sLog.Category__c = 'Attorney Notes';
        sLog.Start_Time__c = startDate;
        sLog.End_Time__c = endDate;
        sLog.Status__c = 'Error';
        insert sLog;
    }
	
    
    private static Datetime parseTimestamp(String timestampStr){
        Datetime timestamp;
        list<String> timestampSplit = timestampStr.split(' ',2);
        String dStr = timestampSplit[0];
        String tStr = timestampSplit[1];
        list<String> timeSplit = tStr.split(' ',2);
        String hmsStr = timeSplit[0];
        String period = timeSplit[1];
        list<String> hhmmss = hmsStr.split(':', 3);
        String dtFormatted = dStr + ' ' +
                            hhmmss[0] + ':' + hhmmss[1] + ' ' + period;
        
        timestamp = Datetime.parse(dtFormatted);
        timestamp = timestamp.addSeconds(Integer.valueOf(hhmmss[2]));
        return timestamp;
    }
    
    public class NotesWrapper{
	    public String Lit_Def_File_Number {get;set;}
		public String Fusion_File_Number_lead {get;set;}
		public String Client_Name {get;set;}
		public String Debt_Id {get;set;}
		public String Created {get;set;}
		public String Category {get;set;}
		public String Message_pix500 {get;set;}
    }
}