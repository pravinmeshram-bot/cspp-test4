global class BatchBoxMissingFolderCreation implements Database.Batchable < sObject > , Database.Stateful, Database.AllowsCallouts{
	global List<String> masterFolders;
    global String folderEndpoint;
    global String sourceFolderIdToCopy;
    global String failedBoxFolders;
    //global String access_token;
    global List < Account > start(Database.BatchableContext BC) {
        String documentName = 'BOX Client Folder Missing Report';
        String access_token;
        failedBoxFolders = '';
        List<Document> docs = [SELECT Body, BodyLength, ContentType, Url from Document WHERE Name LIKE :documentName];
        Set<String> clientNumbers = new Set<String>();
        if(docs.isEmpty() == false) {
            Document doc = docs[0];
            String csvBody = doc.body.toString();
            String[] lineList = csvBody.split('\n');
            String[] splitRow = lineList[0].split(',');
            Integer i = 0;
            Integer clientNumberIndex;
            for(String col: splitRow) {
                if (col.trim() == 'Client Number') {
                    clientNumberIndex = i;
                }
                i++;
            }

            for(String line : lineList) {
                String[] rows = line.split(',');
                String clientNumber = rows[clientNumberIndex];
                if (clientNumber.trim() != 'Client Number') {
                    clientNumbers.add(clientNumber.trim());
                }
            }
        }
        
        Box_settings__c boxSettings = Box_settings__c.getValues('box');
        Boolean tokenUpdated = false;
        if (boxSettings != null) {
            folderEndpoint = boxSettings.Folder_Endpoint__c;
            sourceFolderIdToCopy = boxSettings.Source_FolderId_to_Copy__c;
            if(string.isBlank(sourceFolderIdToCopy)) {
                sourceFolderIdToCopy = '101280323887';
            }
            
            if(boxSettings.access_token__c != null && boxSettings.Last_Refresh_Date__c != null){
                Integer lifetimeMinutes = boxSettings.Access_Token_Lifetime__c != null ? Integer.valueOf(boxSettings.Access_Token_Lifetime__c) : 30;
                DateTime tokenLifeTime = boxSettings.Last_Refresh_Date__c.addMinutes(lifetimeMinutes);
                if (tokenLifeTime > system.now()){
                    access_token = boxSettings.access_token__c;
                } else {
                    access_token = CreateParentAndSubFoldersInBox.getAccessToken();
                    tokenUpdated = true;
                    boxSettings.access_token__c = access_token;
                    boxSettings.Last_Refresh_Date__c = system.now();
                }
            } else {
                access_token = CreateParentAndSubFoldersInBox.getAccessToken();
                tokenUpdated = true;
                boxSettings.access_token__c = access_token;
                boxSettings.Last_Refresh_Date__c = system.now();
            }    
        }  
        masterFolders = new List<String>();
        String masterFolderEndpoint = folderEndpoint + '/'+sourceFolderIdToCopy+'?';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(masterFolderEndpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer '+access_token);
        
        Http p = new Http();
        HttpResponse response = new HttpResponse();
        response = p.send(request);
        
        if (response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
            JSONParseBOXResponse jsonResponse = JSONParseBOXResponse.parse(response.getBody());
            
            for (JSONParseBOXResponse.cls_entries children: jsonResponse.item_collection.entries) {
                masterFolders.add(children.Name);
            }
            
            if (tokenUpdated) {
                update boxSettings;
            }
            system.debug('++++clientNumbers++'+clientNumbers); 
            String query = '';
            query = 'SELECT Id, BoxFolderId__c, Box_Folder_Name__c FROM Account WHERE RecordType.DeveloperName = \'Client\' AND Box_Folder_Name__c IN : clientNumbers';  
            
            if (!Test.isRunningTest()) {
                return Database.query(query);
            } else {
                return Database.query('SELECT Id, BoxFolderId__c, Box_Folder_Name__c FROM Account');
            }
        } else {
            failedBoxFolders += 'Failed to retrive master folder copy';
            return null;
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List < Account > scope) {
        if (scope != null && !scope.isEmpty()) {
            String access_token;
            Box_settings__c boxSettings = Box_settings__c.getValues('box');
            Boolean tokenUpdated = false;

			if((boxSettings != null && boxSettings.access_token__c != null && boxSettings.Last_Refresh_Date__c != null) || Test.isRunningTest()){
				Integer lifetimeMinutes = boxSettings.Access_Token_Lifetime__c != null ? Integer.valueOf(boxSettings.Access_Token_Lifetime__c) : 30;
				DateTime tokenLifeTime = boxSettings.Last_Refresh_Date__c.addMinutes(lifetimeMinutes);
				if (tokenLifeTime > system.now()){
					access_token = boxSettings.access_token__c;
				} else {
					access_token = CreateParentAndSubFoldersInBox.getAccessToken();
					tokenUpdated = true;
					boxSettings.access_token__c = access_token;
					boxSettings.Last_Refresh_Date__c = system.now();
				}
			}   
            
            for (Account acc: scope) {
                system.debug('+++scope++++'+acc);
                Set<String> missingClientFolders = new Set<String>();
                String clientFolderEndpoint = folderEndpoint + '/'+acc.BoxFolderId__c+'?';
                HttpRequest request = new HttpRequest();
                request.setEndpoint(clientFolderEndpoint);
                request.setMethod('GET');
                request.setHeader('Authorization', 'Bearer '+access_token);
            
                Http p = new Http();
                HttpResponse response = new HttpResponse();
                response = p.send(request);
            	
                if (response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {
                
                    JSONParseBOXResponse jsonResponse = JSONParseBOXResponse.parse(response.getBody());
                    Set<String> clientFolders = new Set<String>();
                    for (JSONParseBOXResponse.cls_entries children: jsonResponse.item_collection.entries) {
                        clientFolders.add(children.Name);
                    }
                    
                    for (String masterFolder: masterFolders) {
                        if (!clientFolders.contains(masterFolder)) {
                            missingClientFolders.add(masterFolder);
                        }
                    }
                    
                    for (string folderName : missingClientFolders) {
                                            
                        CreateParentAndSubFoldersInBox.Folder folder_info = new CreateParentAndSubFoldersInBox.Folder(folderName, acc.BoxFolderId__c);
                        
                        HttpRequest request1=new HttpRequest();
                        request1.setEndpoint(folderEndpoint); 
                        request1.setMethod('POST');
                        request1.setHeader('Authorization', 'Bearer ' + access_token);
                        String body1 = JSON.serialize(folder_info);
                        System.debug(body1);
                        request1.setBody(body1);
                        Http p1 = new Http();
                        HttpResponse response1 = p1.send(request1);
                        system.debug('##response1-> '+response1);
                        system.debug('::Response::'+response1.getBody());
                        
                        if (response1 == null || response1.getStatus() != 'Created' || String.isBlank(response1.getBody())) {
                            failedBoxFolders += acc.Box_Folder_Name__c+',';  
                        }
                    }
                } else {
                    failedBoxFolders += acc.Box_Folder_Name__c+',';
                }
        	}
            if (tokenUpdated) {
                update boxSettings;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if (!String.isEmpty(failedBoxFolders)) {
            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'BatchBoxMissingFolderCreation', 
                                                                     nu_dse__Message__c = failedBoxFolders, 
                                                                     nu_dse__Stack_Trace__c  = 'These are the failed box folder ids to process.', 
                                                                     nu_dse__User_Context__c = userInfo.getName());
            insert errorLog;
        }
        
    }
}