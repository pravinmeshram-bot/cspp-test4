global class BatchBoxFolderCreation implements Database.Batchable < sObject > , Database.Stateful, Database.AllowsCallouts {
    global string PortfolioName;
    global string folderEndpoint;
    global string folderSearchEndpoint;
    global string boxFolderId;
    global string boxFolderName;
    global string rootFolderId;
    global string boxRootFolderId;
    global String sourceFolderIdToCopy;
    global List < Account > start(Database.BatchableContext BC) {

        Box_settings__c boxSettings = Box_settings__c.getValues('box');
        
        if (boxSettings != null) {
            folderEndpoint = boxSettings.Folder_Endpoint__c;
            folderSearchEndpoint = boxSettings.FolderSearch_Endpoint__c;
            sourceFolderIdToCopy = boxSettings.Source_FolderId_to_Copy__c;
            if(string.isBlank(sourceFolderIdToCopy)) {
                sourceFolderIdToCopy = '101280323887';
            }
             
            folderEndpoint += '/'+sourceFolderIdToCopy+'/copy?';
        }
        
        String query = '';
        query = 'SELECT Id, BoxFolderId__c, Box_Folder_Name__c FROM Account WHERE RecordType.DeveloperName = \'Client\' AND BoxFolderId__c = null and id = \'0012i00000Af8Bi\' AND Test_Client__c = false';  
       
        return Database.query(query);
    }

    global void execute(Database.BatchableContext BC, List < Account > scope) {
        String access_token;
        Boolean updateSetting = false;
        Box_settings__c settings = Box_settings__c.getValues('box');
        if(settings !=null && settings.access_token__c != null && settings.Last_Refresh_Date__c != null){
          Integer lifetimeMinutes = settings.Access_Token_Lifetime__c != null ? Integer.valueOf(settings.Access_Token_Lifetime__c) : 30;
            DateTime tokenLifeTime = settings.Last_Refresh_Date__c.addMinutes(lifetimeMinutes);
            if (tokenLifeTime > system.now()){
                system.debug('++++settings.access_token__c+++'+settings.access_token__c);
                access_token = settings.access_token__c;
            } else {
                access_token = CreateParentAndSubFoldersInBox.getAccessToken();
                updateSetting = true;
                settings.access_token__c = access_token;
                settings.Last_Refresh_Date__c = system.now();
            }
        } else {
            access_token = CreateParentAndSubFoldersInBox.getAccessToken();
            updateSetting = true;
            settings.access_token__c = access_token;
            settings.Last_Refresh_Date__c = system.now();        
        }
        
        if (scope != null && !scope.isEmpty()) {
            Account objAccount = scope[0];
            
            system.debug('++++access_token++++'+access_token);
            system.debug('--->objAccount ' + objAccount);

            List < nu_dse__program__c > pgm = [Select id, name, nu_dse__account__c, portfolio__c, portfolio__r.boxfolderId__c from nu_dse__program__c where nu_dse__account__c =: objAccount.Id];

            system.debug('--->pgm ' + pgm);

            RootFolderId = '';

            if (!pgm.isEmpty()) {

                if (pgm[0].portfolio__c != null && pgm[0].portfolio__r.boxfolderId__c != null) {
                    RootFolderId = pgm[0].portfolio__r.boxfolderId__c;
                }

            }

            system.debug('--->RootFolderId ' + RootFolderId);

            If(RootFolderId != '') {
                // Search box with current client folder name
                HttpRequest request0 = new HttpRequest();
                string folderNameQuery = '"' + objAccount.Box_Folder_Name__c + '"';
                
                string finalSearchEndpoint = folderSearchEndpoint + '?query=' + folderNameQuery + '&type=folder&ancestor_folder_ids='+RootFolderId+'&limit=10&fields=id,name,parent';
                system.debug('------finalSearchEndpoint ----' + finalSearchEndpoint);
                request0.setEndpoint(finalSearchEndpoint);
                request0.setMethod('GET');
                request0.setHeader('Authorization', 'Bearer ' + access_token);

                Http p0 = new Http();
                HttpResponse response0 = new HttpResponse();
                response0 = p0.send(request0);

                boxFolderId = '';
                boxFolderName = '';
                boxRootFolderId = '';
                
                system.debug('---Response from Folder Search'+response0.getBody());
                
                if (string.isNotBlank(response0.getBody())) {
                    
                    //Serialize response into wrapper inorder to support bulkified results. (entries node is a list)
                    BoxResponse boxResponseInstance = (BoxResponse)JSON.deserialize(response0.getBody(), BoxResponse.class);
                    System.debug('boxEntries-->'+boxResponseInstance);
                    
                    //Looping the entries node in the response and compare it with rootfolder id. If it matches then populate boxfolderId, boxfolderName and rootfolderId.
                    if(boxResponseInstance != null && boxResponseInstance.entries != null) {
                        
                        for (EntriesClass boxWrapperInstance : boxResponseInstance.entries) {
                            
                            if (boxWrapperInstance.parent != null && boxWrapperInstance.parent.id == RootFolderId) {
                                
                                boxRootFolderId = boxWrapperInstance.parent.id;
                                boxFolderId = boxWrapperInstance.id;
                                boxFolderName = boxWrapperInstance.name;
                            }
                        }
                    }
                }

                system.debug('-------boxFolderId' + boxFolderId);
                System.debug('boxFolderId--->' + boxFolderId);
                System.debug('boxFolderName--->' + boxFolderName);
                System.debug('boxRootFolderId--->' + boxRootFolderId);
                
                //replaced condition boxFolderId == '' to String.isBlank(boxFolderId) - in order to check empty string and null as well.
                if (String.isBlank(boxFolderId) == True && response0 != null && (response0.getStatusCode() == 200 || response0.getStatusCode() == 201) && String.isNotBlank(response0.getBody())) {
                    CreateParentAndSubFoldersInBox.Folder folder_info = new CreateParentAndSubFoldersInBox.Folder(objAccount.Box_Folder_Name__c, RootFolderId);
                    
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(folderEndpoint);
                    system.debug('::folderEndpoint' + folderEndpoint);
                    request.setMethod('POST');
                    request.setHeader('Authorization', 'Bearer ' + access_token);
                    String body = JSON.serialize(folder_info);
                    System.debug(body);
                    request.setBody(body);

                    Http p = new Http();
                    HttpResponse response = new HttpResponse();
                    response = p.send(request);
                    System.debug('response--->' + response);
                    System.debug('responseBody--->' + response.getBody());


                    if (response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 201) && String.isNotBlank(response.getBody())) {

                        String parentFolderId = CreateParentAndSubFoldersInBox.getFolderId(response.getBody());

                        objAccount.BoxFolderId__c = parentFolderId;
                        objAccount.Create_Box_Folder__c = false;
                        update objAccount;
                    }
                }
                
                //if boxfoldername and rootFolderId matches then update the Account record.
                if (boxFolderName == objAccount.Box_Folder_Name__c && boxRootFolderId == RootFolderId) {
                    objAccount.BoxFolderId__c = boxFolderId;
                    update objAccount;
                }

            }
            if(updateSetting) {
                update settings;
            }
        }
    }
    global void finish(Database.BatchableContext BC) {}
    
    
    public class BoxResponse {
        
        public List<EntriesClass> entries;
    }
    
    public class EntriesClass {
        public String id;
        public String name;
        public ParentClass parent;
        
    }
    
    public class ParentClass {
        
        public string id;    
    }
    
}