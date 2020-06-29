public class Box {

    private id clientId{get;set;}
    
    private id debtId{get;set;}
    
    private BoxFolder clientfolder;
    
    private static final String boxCredentialFolderName = 'Box_Cred';
    
    public integer offset{get;set;}
    
    public integer limits{get;set;}
    
    public BoxApiConnection api{get;set;}
    
    public static List<nu_dse__Program__c> UpdatePrograms =  new List<nu_dse__Program__c>();
    
    public static List<Account> updateAccounts = new LIst<Account>();
    
    public static list<nu_dse__Tradeline__c> updateDebts = new list<nu_dse__Tradeline__c>();
    
    public static list<nu_dse__Error_log__c> errorLogs = new List<nu_dse__Error_log__c>(); 
    
    public Box(){
         
        Map<String, String> credential = getBoxCredential();
    
        String encriptionName = 'SHA1';
        String privatekey = credential.get('privatekey'); 
        String enterpriseId = credential.get('enterpriseId');
        String publicKeyId = credential.get('publicKeyId');
        String clientId = credential.get('clientId');
        String clientSecret = credential.get('clientSecret');
        String accessToken;
        
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyId);
        preferences.setPrivateKey(privateKey);
        try {
            BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppUserConnection(enterpriseId, clientId, clientSecret, preferences);
            accessToken = api.accessToken;
            System.debug('AccessToken:'+ accessToken);
        } catch(Exception e) {
            System.debug('exception: ' + e);
        }
        
        offset = 0; 
        limits = 100; 
        api = new BoxApiConnection(accessToken); 
        
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
    
    public  BoxFile.Info uploadFilesToBox(sobject parent/* client or debt*/, string docType, String fileName, String description, blob filebody){
        
        BoxFile.Info fileinfo ; 
        
        
         if(fileName.split('\\.').size()>0){
                
                filename = fileName.split('\\.')[0]+String.valueOf(System.dateTime.now())+'.'+fileName.split('\\.')[1];
                
            }else{
                
                fileName = fileName + string.valueOf(system.dateTime.now().formatGMT('YYYY-MM-dd HH:mm:ss'));
            }
        /*
         * Check if sObject is program or tradeline. IF program then upload the file under client FolderDocType, else upload under debt folder doctype. 
         */ 
        try{
          if(parent.getSObjectType()==Schema.nu_dse__Program__c.getSObjectType()){
            
            nu_dse__Program__c client = (nu_dse__Program__c)parent;
             
            Account personAccount = new Account(id=client.nu_dse__Account__c);
              
            String clientFolderId;
            String debtFolderId; 
            String docTypeFolderId;
            boxItem.Info clientFolderResponse; 
            BoxItem.Info debtFolderResponse;
            BoxItem.Info docTypeFolderResponse; 

          try{        
            if(!this.isFolderExist(string.valueOf(client.nu_dse__Account__r.clientnumber__c),'0')){
                
                try{
                    
                    clientFolderResponse = createFolder(String.valueOf(client.nu_dse__Account__r.clientnumber__c),'0');
                    
                    clientFolderId = clientFolderResponse.getValue('id');
                                     
                }catch(Exception e){
                    
                    
                    throw new boxException('ClientFolder Creation Failed!');
                }
            }else{
                
                clientFolderId = this.getFolderId(String.valueOf(client.nu_dse__Account__r.clientnumber__c),'0');
                
            }
            
            if(clientFolderId != null && clientFolderId !=''){
                
                 client.client_folder_Id__c = clientFolderId;
                 
                 personAccount.BoxFolderId__c = clientFolderId ; 
                
                 UpdatePrograms.add(client);
                
                 updateAccounts.add(personAccount);
                
            }else{
                
                throw new boxException('ClientFolder Creation Failed!');
            }
               
                
                System.debug('Client FolderId'+ clientFolderId);
                
                // Validate if doctype exists under Client folder
                if(!isFolderExist(docType,clientFolderId)){
                    
                    docTypeFolderResponse = createFolder(docType,clientFolderId);
                     
                    docTypeFolderId = docTypeFolderResponse.getValue('id');
                   
                    
                    
                }else{
                    
                    docTypeFolderId = this.getFolderId(docType, clientFolderId); 
                }
            
            
            
                 if(docTypeFolderId != null && docTypeFolderId !=''){
                        
                   
                     if(!this.isFileExist(fileName,docTypeFolderId)){
                         
                         fileinfo= this.upload(fileName, docTypeFolderId ,filebody);
                         
                     }else{
                         
                         throw new BoxException('File already Exist');
                     }
                        
                        
                  }
                    
            
        }catch(Exception e){
            
            throw new BoxException('Client Upload Failed!');
        }
           
        }
          else if(parent.getsObjectType() == schema.nu_dse__TradeLine__c.getSObjectType()){
            
            
            nu_dse__TradeLine__c debt = (nu_dse__TradeLine__c)parent;
                
            nu_dse__Program__c program = new nu_dse__Program__c(id=debt.nu_dse__Program__c);
              
            Account personAccount = new Account(id=debt.nu_dse__Program__r.nu_dse__Account__c);
            
            String clientFolderId;
            String debtFolderId; 
            String docTypeFolderId;
            boxItem.Info clientFolderResponse; 
            BoxItem.Info debtFolderResponse;
            BoxItem.Info docTypeFolderResponse; 
           
            try{
                if(this.isFolderExist(String.valueOf(debt.nu_dse__Program__r.nu_dse__Account__r.clientnumber__c), '0')){
                    
                    try{
                        
                        clientFolderId = this.getFolderId(string.valueOf(debt.nu_dse__Program__r.nu_dse__Account__r.clientnumber__c),'0'); 
                        
                        System.debug('Client Folder Id::'+ clientFolderId);
                        
                    }catch(Exception e){
                        
                        throw new BoxException('getClientFolder Id Failed !');
                        
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'Box.uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                    }
                   
                    
                }
                else{
                    
                    try{
                        
                     clientFolderResponse = createFolder(String.valueOf(debt.nu_dse__Program__r.nu_dse__Account__r.clientnumber__c),'0');
                    
                     clientFolderId = clientFolderResponse.getValue('id');
                        
                    }catch(Exception e){
                        
                        throw new BoxException('Folder Creation failed!');
                        
                        
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'Box.uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                    }
                    
                }
                  
                System.debug('ClientFolderId:::'+ clientFolderId);
                if(ClientFolderId != null && clientFolderId !=''){
                    
                  program.client_folder_Id__c = clientFolderId;
                  
                  personAccount.BoxFolderId__c = clientFolderId ; 

                  UpdatePrograms.add(program);
                    
                  updateAccounts.add(personAccount);
                    
                }else{
                    
                    nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                    log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                    log.nu_dse__Message__c = 'Client Folder creation Failed';
                    log.nu_dse__Stack_Trace__c = '';
                    errorLogs.add(log);
                    
                    throw new  BoxException('Client Folder creation Failed');
                    
                    
                }
                  
                  /*
                   * Create Folder for debt.
                   */ 
               
                if(!this.isFolderExist2(debt.name,clientFolderId)){
              
                    try{
                        
                        debtFolderResponse = createFolder(debt.name,clientFolderId);
                  
                        debtFolderId =  debtFolderResponse.getValue('id');
                        
                    }catch(Exception e){
                        
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                        
                        throw new BoxException('Debt Folder creation failed! ');
                    }
                  
                    
                }else{
                    
                    try{
                        
                        debtFolderId = this.getFolderId2(debt.name,clientFolderId);
                        
                    }catch(Exception e){
                        
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                        
                        throw new BoxException('GetFolderId  failed !');
                    }
                    
                }
                
                System.debug('Debt Folder Id: '+debtFolderId );
                
                if(debtFolderId != null && debtFolderId != ''){
                     debt.Box_Folder_Id__c = debtFolderId; 
                  
                     updateDebts.add(debt);
                
                }else{
                    
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                        log.nu_dse__Message__c = 'Debt Folder creation Failed';
                        log.nu_dse__Stack_Trace__c = '';
                        errorLogs.add(log);
                    
                        throw new BoxException('Debt Folder creation Failed');
                    
                }
                
                /*
                 * create a folder for debtType
                 */ 
                System.debug('Creating doctype folder');
                
                if(!this.isFolderExist2(docType,debtFolderId)){
                    
                    try{
                       docTypeFolderResponse = createFolder(docType,debtFolderId);
                
                       docTypeFolderId = docTypeFolderResponse.getValue('id');
                
                     }catch(Exception e){
                         
                         
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                    
                        throw new BoxException(docType+ ' folder Creation failed');
                     }
                }else{
                    
                    
                    try{
                        
                        docTypeFolderId = this.getFolderId2(docType,debtFolderId);
                        
                    }catch(Exception e){
                        
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                        
                        throw new BoxException('GetFolderId  failed !');
                    }
                }
                
                System.debug('DocType FolderId: '+ docTypeFolderId);
                  /*
                   * All Folders created, now upload the file. 
                   * 
                   */  
                if(!isFileExist(fileName,docTypeFolderId)) {
                try{
                    
                  fileInfo = this.upload(fileName,docTypeFolderId,filebody);
               
                }catch(exception e){
                    
                    
                        nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                        log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                        log.nu_dse__Message__c = e.getMessage();
                        log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                        errorLogs.add(log);
                    
                       throw new BoxException('File Upload Failed !');
                }
                }
            
            }catch(Exception e){
                
                
                 nu_dse__Error_log__c  log = new nu_dse__Error_log__c(); 
                 log.nu_dse__Class_Method__c = 'uploadFilesToBox'; 
                 log.nu_dse__Message__c = e.getMessage();
                 log.nu_dse__Stack_Trace__c = e.getStackTraceString();
                 errorLogs.add(log);
                
                 throw new BoxException('Debt upload Failed');
            }
        }
        }catch(Exception e){
            
             updateSettings();
            
            throw new CustomException(e.getStackTraceString());
        }
       
         handleDML();
        
        return fileInfo; 
    }
  
    private BoxItem.Info createFolder(String folderName, string parentId){
        
        // if parent is null then new folder is created under rootfolder. 
        parentId = parentId == '' ? '0' : parentId; 
        
        BoxFolder folder = new BoxFolder(api,parentId);
        
        BoxItem.Info response = folder.createFolder(folderName);
        
        return response; 
    }
    
    private Boolean isFolderExist(String foldername, String parentId){
        
 
        
        BoxSearch s = new BoxSearch(api, parentId);  
        LIst<BoxItem.Info> searchResults ;
        try{
         searchResults   = s.search(EncodingUtil.urlEncode(foldername, 'UTF-8'),'folder');
            
            System.debug('SearchResults::'+ searchResults);
            
        }catch(exception e){
            
            System.debug('Exception caught');
            
            return false; 
        }
      
        if(searchResults !=null){
            
          for(BoxItem.Info i: searchResults){
            
            System.debug('name: '+i.getValue('name'));
            
            if(i.getvalue('name').equalsIgnoreCase(folderName)){
                
                System.debug('::: in validation');
                return true; 
            }
            
        }
            
        }
        
        return false; 
    }

    private boolean isFolderExist2(String foldername, String parentId){

        
       BoxFolder folder = new BoxFolder(api,parentId); 
        
       System.debug('Get All sub folder of root.');
        
       List<BoxItem.Info> childrens = folder.getChildren();
        
       System.debug('Number of sub folder under root: '+ childrens.size());
        
        for(BoxItem.Info info: childrens){
            
            String folder_name='';
            
           
            if(info.getValue('type').equalsIgnoreCase('folder')){
                
                System.debug('****Flolder Name: '+ info.getValue('name'));
                System.debug('etag:'+info.getValue('etag'));
                System.debug('id:'+info.getValue('id'));
                System.debug('sequence_id:'+info.getValue('sequence_id'));
                System.debug('type:'+info.getValue('type'));
                 System.debug('Info:'+info.children.keyset());
                 
                folder_Name = info.getvalue('name');
                if(folder_name.equalsIgnoreCase(folderName)){
                    
                    return true; 
                }
            }
        }
        
        return false; 
        
    }
    
    private boolean isFileExist(String fileName, String parentId){
        
         BoxSearch s = new BoxSearch(api, parentId); 
        LIst<BoxItem.Info> searchResults ;
        try{
         searchResults   = s.search(EncodingUtil.urlEncode(fileName, 'UTF-8'),'file');
            
            System.debug('SearchResults::'+ searchResults);
            
        }catch(exception e){
            
            System.debug('Exception caught');
            
            return false; 
        }
      
        if(searchResults !=null){
            
          for(BoxItem.Info i: searchResults){
            
            System.debug(i.getValue('name'));
            
            if(i.getvalue('name').equalsIgnoreCase(fileName)){
                
                System.debug('::: in validation');
                return true; 
            }
            
        }
            
        }
        
        return false; 
    }
    
    
    private String getFolderId(String foldername, String parentId){
        
         BoxSearch s = new BoxSearch(api, parentId); 
        LIst<BoxItem.Info> searchResults = s.search(EncodingUtil.urlEncode(foldername, 'UTF-8'),'folder');
        
        for(BoxItem.Info i: searchResults){
            
            System.debug(i.getValue('name'));
            
            if(i.getvalue('name').equalsIgnoreCase(folderName)){
                
                System.debug('::: in validation');
                return  i.getValue('id');
            }
            
        }
        
        return null; 
    }
    
    public String getFolderId2(String folderName, String parentId){
        
       
        BoxFolder folder = new BoxFolder(api,parentId); 
        
       List<BoxItem.Info> childrens = folder.getChildren();
        
        for(BoxItem.Info info: childrens){
            
            String folder_name='';
            
            if(info.getValue('type').equalsIgnoreCase('folder')){
                
                System.debug('In Folder Type');
                folder_Name = info.getvalue('name');
                System.debug('Folder Name::'+ folder_name + 'searching folder name: '+ folderName);
                
                if(folder_name.equalsIgnoreCase(folderName)){
                    
                    System.debug('Folder name Matched!');
                    
                    return info.getValue('id'); 
                }
            }
        }
        System.debug('Throwing error now !');
       // throw new BoxException('Folder  Not found!');
        return null; 
        
    }
    
    private BoxFile.info upload(String fileName, String parentFolderId, blob filebody ){
        
          BoxFolder folder = new BoxFolder(api, parentFolderId);
             
         BoxFile.Info uploadResponse =  folder.uploadFile(filebody, fileName);
        
        return uploadResponse; 
    }
    
    Public class BoxException extends exception{} 
    
    public static void handleDML(){
        
        System.debug('Program::::'+  UpdatePrograms );
        if(UpdatePrograms.size()>0){
            
            update UpdatePrograms;
        }
        
        if(updateAccounts.size()>0){
            
            update updateAccounts; 
        }
        
        if(updateDebts.size() >0){
            
             update updateDebts; 
        }
        
        if(BoxApiConnection.settings != null){
            
          updateSettings();
        }
       
        if(errorLogs.size()>0){
            
            update errorLogs;
        }
        
        
    }
    
    public static void updateSettings(){
        
        if(BoxApiConnection.settings != null){
            
            update BoxApiConnection.settings; 
        }
    }
   
}