/* Account Trigger Handler to update folder name of the client from 'prospect name' to 'boxfoldername' field value as client folder name 
testtstfgtasdfsdgfsajdgfukasfhkilsdbjfildsjflisjdfbjslifnjsd*/

public class AccountHandler {
    
    public static void updateFolderName(List<Account> newAccountList) {
        
        Map<String, String> clientAndFolderMap = new Map<String, String>();
        
        if (newAccountList != null && newAccountList.isEmpty() == False) {
            
            for (Account acc :  newAccountList) {
                
                if (String.isNotBlank(acc.BoxFolderId__c)) { 
                    
                    clientAndFolderMap.put(acc.Box_Folder_Name__c, acc.BoxFolderId__c);
                 }

            }
        }
        
        system.debug('clientAndFolderMap-->'+clientAndFolderMap);
        
        if (clientAndFolderMap.isEmpty() == False) {
            
            updateFolder(clientAndFolderMap);
        }
    }
    
    
    
  /* Nov 06 2018 test
     This logic is commented because this is no more requried and 
     all the folder creation for accounts are handledd through batch class
     
    public static void CreateFolders(Map <Id, Account> newAccountIdAndAccountMap) {
    
        try {
        
            if (newAccountIdAndAccountMap != null && newAccountIdAndAccountMap.isEmpty() == False) {
                
                System.enqueuejob(new  CreateParentAndSubFoldersInBox(newAccountIdAndAccountMap.values()));
                //System.enqueuejob(new QueueableClassToCreateFoldersInBox(newAccountIdAndAccountMap));
            }
            
        } catch (exception e) {
            
            nu_dse__Error_Log__c errorLog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'AccountHandler.CreateFolders', 
                                                                     nu_dse__Message__c = e.getMessage(), 
                                                                     nu_dse__Stack_Trace__c  = e.getStackTraceString(), 
                                                                     nu_dse__User_Context__c = userInfo.getName());
            insert errorLog;
        }
    } */
    
    @future(callout = true)
    public static void updateFolder(Map<String, String> clientAndFolderIdMap) {
        
        List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
        
        try {
        
            Box_settings__c boxSettings = Box_settings__c.getValues('box');
            String folderEndpoint;
            
            if (boxSettings != null) {
            
                 folderEndpoint = boxSettings.Folder_Endpoint__c;
            }
            
            system.debug('folderEndpoint--->'+folderEndpoint);
            String access_token = CreateParentAndSubFoldersInBox.getAccessToken();
            system.debug('access_token-->'+access_token);
            
            if (clientAndFolderIdMap != null && clientAndFolderIdMap.isEmpty() == False ) {
                
                String strResponse;
                Map<String, Object> errorMessage = new Map<String, Object>();
                for (String clientNumber : clientAndFolderIdMap.KeySet()) {
                    
                    if (clientAndFolderIdMap.containsKey(clientNumber)) {
                    
                        String EndPointURL = folderEndpoint+'/'+clientAndFolderIdMap.get(clientNumber);


                        String strBody = '{"name": "'+ clientNumber +'"}';
                        HttpRequest req = new HttpRequest();
                        req.setHeader('Authorization', 'Bearer ' + access_token);
                        req.setEndpoint(EndPointURL);
                        req.setMethod('PUT');
                        req.setBody(strBody);
                        req.setTimeout(120000);
                        Http http = new Http();
                        HttpResponse res = http.send(req);
                        
                        system.debug('----strResponse---'+strResponse);
                        
                        if (res != null && res.getStatusCode() != 200 && String.isNotBlank(res.getBody())) {
                            
                            errorMessage = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        }
                    }
                }
                
                if (errorMessage.isEmpty() == False) {
                    
                    if (errorMessage.Containskey('message')) {
                    
                        nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'AccountHandler.updateFolder', 
                                                                         nu_dse__Message__c = 'Error: '+errorMessage.get('message')); 
                        errorLogList.add(errorlog);
                    }
                }
            }
        } Catch (Exception e) {
            
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'AccountHandler.updateFolder', 
                                                                     nu_dse__Message__c = e.getMessage(), 
                                                                     nu_dse__Stack_Trace__c  = e.getStackTraceString(), 
                                                                     nu_dse__User_Context__c = userInfo.getName());
            errorLogList.add(errorlog);
        }
        
        if (errorLogList.isEmpty() == False) {
            
            insert errorLogList;
        }
    }
}