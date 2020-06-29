public class CreateParentAndSubFoldersInBox {
//public class CreateParentAndSubFoldersInBox implements Queueable, Database.AllowsCallouts {
    
    public List<Account> createFolderAccountList= new List<Account>();
    private static final String boxCredentialFolderName = 'Box_Cred';
    
    public static List<String> folderNamesList = new List<String>{'1099c','Add Remove Debt','Bank Info','Bank Levy',
                                                              'Bankruptcy','Notifications','Call Logs','Cancellation Notice',
                                                              'Collection Notice','Creditor Notifications','Customer Correspondence',
                                                              'Death Notifications','Hardship Letters','Legal Garnishments',
                                                              'Legal Judgments','Legal Property Lien','Legal Settlements & Stipulations',
                                                              'Legal Summons','Legal- other','LOR – Fax Confirmation','Payment Schedule Adjustments',
                                                              'Power of Attorney','Releases','Satisfaction Letters','Settlement Letters',
                                                              'Settlement Offer','Statements','Updated Contracts','Original Contracts'};
    
    public static String getAccessToken() {
        
        Map<String, String> credential = getBoxCredential();
        system.debug('credential---'+credential);
        String encriptionName = 'SHA1';
        String privatekey = credential.get('privatekey');
        //String enterpriseId = '6427355896';
        String enterpriseId = credential.get('enterpriseId');
        String publicKeyId = credential.get('publicKeyId');
        String clientId = credential.get('clientId');
        String clientSecret = credential.get('clientSecret');
        String accessToken;
        
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyId);
        preferences.setPrivateKey(privateKey);
        system.debug('preferences!!!!'+preferences);
        try {
            
            BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppUserConnection(enterpriseId, clientId, clientSecret, preferences);
           
            accessToken = api.accessToken;
            
        } catch(Exception e) {
            
            System.debug('exception: ' + e);
        }
        
        System.debug('accessToken##'+ accessToken);
        return accessToken;
    }
    
    @future(callout = true)
    public static void createProspectFolder(Set<Id> prospectIdSet) {
        
        List<nu_dse__Prospect__c> prospectList = new List<nu_dse__Prospect__c>();
        List<nu_dse__Prospect__c> prospectToUpdateList = new List<nu_dse__Prospect__c>();
        
        try {
        
            Box_settings__c boxSettings = Box_settings__c.getValues('box');
            String folderEndpoint;
            
            if (boxSettings != null) {
            
                 folderEndpoint = boxSettings.Folder_Endpoint__c;
            }
            
            String access_token = getAccessToken();
            system.debug('access_token-->'+access_token);
            
            if (prospectIdSet.isEmpty() == False) {
            
                for (nu_dse__Prospect__c prospect : [SELECT Id, Name,Portfolio__r.boxfolderId__c,BoxFolderId__c, nu_dse__First_Name__c, nu_dse__Last_Name__c 
                                                         FROM nu_dse__Prospect__c WHERE Id IN :prospectIdSet]) {
                
                    prospectList.add(prospect);
                    System.debug('::prospectList::'+prospectList);
                }
            }
            
            /* Updated on 07-03-2018
             * To get the root folder id from Box Settings custom settings with FolderUpdate record
             */
          
           /* Commented to pull the rootfolder value based on portoflio name, restructuring the box folders
            String rootFolderId = '47510948398';
            
            Box_settings__c boxSettings_FolderUpdate = Box_settings__c.getValues('FolderUpdate');
            
            if(boxSettings_FolderUpdate != null && boxSettings_FolderUpdate.RootFolderId__c != null) {
            
                rootFolderId = boxSettings_FolderUpdate.RootFolderId__c;
            }
            */
            
            
            string rootFolderId = '';
            
            if (prospectList.isEmpty() == False && folderEndpoint != null && access_token != null) {
                
                for (nu_dse__Prospect__c prospect : prospectList) {
                    
                    rootFolderId = prospect.Portfolio__r.boxfolderId__c;
                    
                    system.debug('----rootFolderId '+rootFolderId );
                    system.debug('----prospect.boxfolderid__c'+prospect.boxfolderid__c);
                    
                    if(rootFolderId != '' && (prospect.boxfolderid__c == null || prospect.boxfolderid__c == '') ){
                    
                        Folder folder_info = new Folder(prospect.Name + '-' + prospect.nu_dse__First_Name__c + ' ' + prospect.nu_dse__Last_Name__c, rootFolderId);
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(folderEndpoint);
                        system.debug('::folderEndpoint'+folderEndpoint);
                        request.setMethod('POST');
                        request.setHeader('Authorization', 'Bearer ' + access_token);
                        String body = JSON.serialize(folder_info);
                        System.debug(body);
                        request.setBody(body);
            
                        Http p = new Http();
                        HttpResponse response = new HttpResponse();
                        response = p.send(request);
                        System.debug('response--->'+response);
                        System.debug('responseBody--->'+response.getBody());
                        
                        if (response != null && response.getStatusCode() == 201 && String.isNotBlank(response.getBody())) {
                        
                            String parentFolderId = getFolderId(response.getBody());
                            
                            for (string folderName : folderNamesList) {
                            
                                Folder folder_info1 = new Folder(folderName, parentFolderId);
                                
                                HttpRequest request1=new HttpRequest();
                                request1.setEndpoint(folderEndpoint); 
                                request1.setMethod('POST');
                                request1.setHeader('Authorization', 'Bearer ' + access_token);
                                String body1 = JSON.serialize(folder_info1);
                                System.debug(body1);
                                request1.setBody(body1);
                                Http p1 = new Http();
                                HttpResponse response1 = p1.send(request1);
                                system.debug('##response1-> '+response1);
                                system.debug('::Response::'+response1.getBody());
                            }
                            
                            nu_dse__Prospect__c prospectToUpdate = new nu_dse__Prospect__c(Id = prospect.Id, BoxFolderId__c = parentFolderId);
                            prospectToUpdateList.add(prospectToUpdate);
                        }
                   }
                    
                }
                
                if (prospectToUpdateList.isEmpty() == False) {
                    system.debug('prospectToUpdateList '+prospectToUpdateList);
                    update prospectToUpdateList;
                }
            }
        } catch(Exception e) {
        
            system.debug('Error messgae-->'+e.getMessage());
            system.debug('Stack trace-->'+e.getStackTraceString());
        }
    }
    
   
   /* Nov 06 2018 
      This logic is commented because this is no more requried and 
      all the folder creation for accounts are handled through batch class
     
    //For creating Folder and subfolder in BOX.
    public CreateParentAndSubFoldersInBox (List<Account> accountList) {
        
        if (accountList!= null && accountList.isEmpty() != null) {
            
            createFolderAccountList.addAll(accountList);
        }
    }
    
    //Converted from Future to queueable...
    public void execute(QueueableContext context) {
        
        createAccountFolder(createFolderAccountList);
    }
    
    //This method is invoked by the BoxFolderBulkCreationBatch2...
    public static void createAccountFolder(List<Account> createFolderAccountList) {
        
        List<account> accToUpdateList = new list<account>();
        
        try {
            
            Box_settings__c boxSettings = Box_settings__c.getValues('box');
            String folderEndpoint;
            
            if (boxSettings != null) {
            
                 folderEndpoint = boxSettings.Folder_Endpoint__c;
            }
            
            String access_token = getAccessToken();
            system.debug('access_token-->'+access_token);
           
           // if (accountId != null || accountId != '') {
            
             //  acc = [SELECT Id, Name, BoxFolderId__c,Box_Folder_Name__c FROM account WHERE Id =:accountId];
                
           // }
            //String rootFolderId = '47510948398';
            
           // Box_settings__c boxSettings_FolderUpdate = Box_settings__c.getValues('FolderUpdate');
            
            //if (boxSettings_FolderUpdate != null && boxSettings_FolderUpdate.RootFolderId__c != null) {
            
           //     rootFolderId = boxSettings_FolderUpdate.RootFolderId__c;
           // }
            
            string rootFolderId = '';
            
            if (folderEndpoint != null && access_token != null) {
            
                for (Account acc : createFolderAccountList) {
                    
                   list<nu_dse__program__c> pgm = [select id,name,Portfolio__r.boxfolderId__c from nu_dse__program__c where nu_dse__Account__c=:acc.id];
                    
                    
                    if(!pgm.isEmpty()){
                    
                         rootFolderId = pgm[0].Portfolio__r.boxfolderId__c;
                         
                    }
                    if( rootFolderId  != ''){            
                        
                        Folder folder_info = new Folder(acc.Box_Folder_Name__c, rootFolderId);
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(folderEndpoint);
                        system.debug('::folderEndpoint'+folderEndpoint);
                        request.setMethod('POST');
                        request.setHeader('Authorization', 'Bearer ' + access_token);
                        String body = JSON.serialize(folder_info);
                        System.debug(body);
                        request.setBody(body);
            
                        Http p = new Http();
                        HttpResponse response = new HttpResponse();
                        response = p.send(request);
                        System.debug('response--->'+response);
                        System.debug('responseBody--->'+response.getBody());
                        
                        if (response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode() == 204) && String.isNotBlank(response.getBody())) {
                        
                            String parentFolderId = getFolderId(response.getBody());
                            
                            for (string folderName : folderNamesList) {
                            
                                Folder folder_info1 = new Folder(folderName, parentFolderId);
                                
                                HttpRequest request1=new HttpRequest();
                                request1.setEndpoint(folderEndpoint); 
                                request1.setMethod('POST');
                                request1.setHeader('Authorization', 'Bearer ' + access_token);
                                String body1 = JSON.serialize(folder_info1);
                                System.debug(body1);
                                request1.setBody(body1);
                                Http p1 = new Http();
                                HttpResponse response1 = p1.send(request1);
                                system.debug('##response1-> '+response1);
                                system.debug('::Response::'+response1.getBody());
                            }
                            
                            account accountToUpdate = new account(Id = acc.Id, BoxFolderId__c = parentFolderId);
                            accToUpdateList.add(accountToUpdate);
                        }
                    
                   }
                }
                
                if (accToUpdateList.isEmpty() == False) {
                    
                    system.debug('accToUpdateList '+accToUpdateList);
                    
                    update accToUpdateList;
                }
            }
            
        } catch(Exception e) {
        
            system.debug('Error messgae-->'+e.getMessage());
            system.debug('Stack trace-->'+e.getStackTraceString());
            
            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'CreateParentAndSubFoldersInBox', 
                                                                     nu_dse__Message__c = e.getMessage(), 
                                                                     nu_dse__Stack_Trace__c  = e.getStackTraceString(), 
                                                                     nu_dse__User_Context__c = userInfo.getName());
            insert errorLog;
        }
    }
    
    */
    
    public static String getFolderId(String responseBody) {
        
        String folderId = null;
        JSONParser parser = JSON.createParser(responseBody);
        while((parser.nextToken()) != null) {
            if(parser.getCurrentName() == 'id'){
                system.debug('@ parser.getText()=>'+parser.getText());
                parser.nextToken();
                folderId = parser.getText();
                break;
            }
        }
        system.debug('---folderId----'+folderId);
        return folderId;
    }
    
    public static Map<String, String> getBoxCredential() {
        //BoxCredential credential = new BoxCredential();
        List<Document> docs = [SELECT Body, BodyLength, ContentType, Url from Document WHERE Name LIKE :boxCredentialFolderName];
        if(docs.isEmpty() == false) {
            return getMapFromDocument(docs[0]);
        }
        return new Map<String, String>();
    }
    
    private static Map<String, String> getMapFromDocument(Document doc) {
        String[] lineList = (doc.Body.toString()).split('\n');
        Map<String, String> pairMap = new Map<String, String>();
        for(String line : lineList) {
            system.debug('line-->'+line);
            String[] split = line.split('=', 2);
            system.debug('split-->'+split);
            if(split.size() == 2) {
                pairMap.put(split[0].trim(), split[1].trim());
            }
        }
        
        return pairMap;
    }
    
    @future(callout = true)
    public static void saveAccessToken(String accessToken, String currentTime) {
        Box_settings__c settings = Box_settings__c.getValues('box');
        settings.access_token__c = accessToken;
        settings.Last_Refresh_Date__c = DateTime.valueOf(currentTime);
        update settings;
    }
    
    private class ParentFolder {
        public String id;
        public ParentFolder(String id) {
            this.id = id;
        }
    }
    
    public class Folder {
        public String name;
        ParentFolder parent;
        
        public Folder(String name, String parentId) {
            this.name = name;
            this.parent = new ParentFolder(parentId);
        }
    }
}