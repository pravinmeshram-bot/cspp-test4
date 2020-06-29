/**********************************************************************************************************************************************
*  Name        :  SFSPortal_DocumentCenterCtrl                                                                                                *
*  Date        :  04/16/2020                                                                                                                  *
*  Description :  This class is used as DocumentCenter Server side controller                                                                 *
*  Version     :  v1.0                                                                                                                        * 
*  Author      :  MindzCloud                                                                                                                  *                                    
**********************************************************************************************************************************************/
public with sharing class SFSPortal_DocumentCenterCtrl {
	public static String boxGlobalAccessToken = CreateParentAndSubFoldersInBox.getAccessToken();   //get access token for box auth
    public static Map<String,String> headers;                                                      //callout request header
    public static Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();  //get Current context account record
    //method to get all filtered documents
    @AuraEnabled
    public static Map<String, List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>> getSelectedFolderSchema(){
        try{
            headers = new Map<String, String>();
            SFSPortal_DocumentCenterHelper objhandler = new SFSPortal_DocumentCenterHelper();  //helper class object
            String strCurrentUserFolderId ;                                                   //desired box folder ID
            SFSPortal_DocumentCenterWrapper.FoldersInfo objFolderWrapp = new SFSPortal_DocumentCenterWrapper.FoldersInfo();
            Map<String, List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>> mapCategoryToSubFolderEntryInfo = new Map<String, List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>>();  //category vs list of response object
            
            String accountId = accountIdMap.get('primaryAccountId');     //current account id 
            if(String.isNotBlank(accountId)){              
                Map<String, nu_dse__Program__c> mapAccountIdToProgram = new Map<String, nu_dse__Program__c>();
                for(nu_dse__Program__c objProgram : [SELECT Id, nu_dse__Account__r.BoxFolderId__c FROM nu_dse__Program__c WHERE nu_dse__Account__c =: accountId]){
                    mapAccountIdToProgram.put(objProgram.nu_dse__Account__c, objProgram);
                }
                system.debug('mapAccountIdToProgram---'+mapAccountIdToProgram);
                if(mapAccountIdToProgram != null && !mapAccountIdToProgram.isEmpty()){
                    if(mapAccountIdToProgram.get(accountId) != null && mapAccountIdToProgram.get(accountId).nu_dse__Account__r.BoxFolderId__c != null){
                        strCurrentUserFolderId = mapAccountIdToProgram.get(accountId).nu_dse__Account__r.BoxFolderId__c; //fetch from local folder
                    }else{
                        throw new AuraException('Box FolderId is not configured for current account!');
                    }
                }else{
                    throw new AuraException('Program record is not found for current account!');
                }
                system.debug('strCurrentUserFolderId---'+strCurrentUserFolderId+'boxGlobalAccessToken---'+boxGlobalAccessToken);
                Box_settings__c settingCred = Box_settings__c.getValues('box');
                system.debug('settingCred--'+settingCred);
                if(settingCred != null && String.isNotBlank(settingCred.Folder_Endpoint__c)){
                    String Response='';
                    //FoldersInfo folderDetails = new FoldersInfo();
                    Map<String, List<SFSPortal_DocumentCenterWrapper.entry>> mapCategoryToItems = new Map<String, List<SFSPortal_DocumentCenterWrapper.entry>>();
                    Map<String,String>folderNameToIdMap = new Map<String,String>();
                    
                    String boxFolderURL = settingCred.Folder_Endpoint__c +'/' +strCurrentUserFolderId;  //The root folder of a Box account
                    headers = SFSPortal_DocumentCenterHelper.getRequestHeader(boxGlobalAccessToken);
                    system.debug('headers---'+headers);
                    HTTPRequest req = SFSPortal_DocumentCenterHelper.createHTTPReq('', boxFolderURL,'GET',headers);
                    system.debug('req>>>'+req);
                    
                    HTTPResponse res = SFSPortal_DocumentCenterHelper.sendHttpRequest(req);  //do call out to fetch folders details
                    system.debug('res>>>'+res);
                    if(res.getStatusCode() == 200 && res.getStatus() == 'OK'){
                        Response = res.getBody();
                        System.debug('**Folder Response:'+Response);
                        
                        objFolderWrapp = (SFSPortal_DocumentCenterWrapper.FoldersInfo)JSON.deserialize(Response,SFSPortal_DocumentCenterWrapper.FoldersInfo.class);  //parse JSON response
                        system.debug('********objFolderWrapp :'+objFolderWrapp);
                        if(objFolderWrapp !=null && objFolderWrapp.item_collection.entries.size()>0){
                        
                            system.debug('responce1231'+objhandler.doFilterBasedOnSettingSchema(objFolderWrapp));
                            objFolderWrapp   = objhandler.doFilterBasedOnSettingSchema(objFolderWrapp);
                            system.debug('schameWrapperFolder.lstFilterItems>>'+objFolderWrapp);
                            
                            for(SFSPortal_DocumentCenterWrapper.entry objWrapperFolderentry : objFolderWrapp.item_collection.entries){
                                if(objWrapperFolderentry.id != null && objWrapperFolderentry.name != null){
                                    if(!mapCategoryToItems.containsKey(objWrapperFolderentry.category)){
                                        mapCategoryToItems.put(objWrapperFolderentry.category, new List<SFSPortal_DocumentCenterWrapper.entry>());
                                    }
                                    mapCategoryToItems.get(objWrapperFolderentry.category).add(objWrapperFolderentry);
                                }
                            }
                            system.debug('mapCategToRequests----'+mapCategoryToItems);
                            
                            mapCategoryToSubFolderEntryInfo = SFSPortal_DocumentCenterHelper.doFetchAllSubfolderInfo(mapCategoryToItems, boxGlobalAccessToken, (String) settingCred.Folder_Endpoint__c);
                            
                        }
                        
                    }else{
                        throw new AuraException('Box Authorization Failed!' +res.getStatusCode());
                    }
                    system.debug('mapCategoryToSubFolderEntryInfo---'+mapCategoryToSubFolderEntryInfo);
                    if(mapCategoryToSubFolderEntryInfo != null && !mapCategoryToSubFolderEntryInfo.isEmpty()){
                        return mapCategoryToSubFolderEntryInfo;
                    }else{
                        return null;
                    }
                }else{
                    throw new AuraException('Box configuration setting not found!');
                }
            }else{
                throw new AuraException('User not found!'); 
            }
            
        }catch(QueryException Qex){
            throw new AuraException('Something went wrong while fetching the data..'+Qex.getMessage());
        }
        catch(CalloutException Cex){
            throw new AuraException('Something went wrong while making a callout request.. '+Cex.getMessage());
        }
        catch(Exception ex){
            throw new AuraException('Something went wrong.. '+ex.getMessage());
        }
    }
    //method to get download selected file
    @AuraEnabled
    public static String  downloadSelectedFile(String fileId){
        try{
            if(String.isNotBlank(fileId)){
                system.debug('boxGlobalAccessToken1--!!!!'+boxGlobalAccessToken);
                return SFSPortal_DocumentCenterHelper.downloadSelectedFileHelper(fileId, boxGlobalAccessToken);
            }else{
                throw new AuraException('Something went wrong : FileId is not accurate !');
            }
        }catch(CalloutException ex){
            throw new AuraException('Something went wrong..'+ex.getMessage());
        }
    }
    //method to get preview link for selected file
    @AuraEnabled
    public static String getBoxPreviewLink(String fileId){
        try{
            system.debug('boxGlobalAccessToken2--!!!!'+boxGlobalAccessToken);
            if(String.isNotBlank(boxGlobalAccessToken)){
                Box objj = new Box();
                system.debug('sss'+objj.api+'fileId---'+fileId);
                if(String.isNotBlank(fileId) && objj.api != null ){
                    return SFSPortal_DocumentCenterHelper.getPreviewLinkHelper(fileId, objj.api);
                }else{
                    throw new AuraException('Something went wrong while preview the file : - File authorization failed !');
                }
            }else{
                throw new AuraException('Something went wrong while preview the file : - Access Denied !');
            }
        }catch(Exception ec){
            
        }
        return null;

    }
    //method to get Welcome Material Files
    @AuraEnabled
    public static List<ContentDocument> getWelcomeMaterial(){
        List<ContentDocument> lstWelcomeMaterialDocs = new List<ContentDocument>();
        Set<Id> parentIds ;
        Set<Id> tempContentDocumentIds ;
        try{
            if(accountIdMap != null && accountIdMap.get('primaryAccountId') != null){
                
                    for(nu_dse__Program__c objProgram : [SELECT Id, Portfolio__c,nu_dse__Processor__c FROM nu_dse__Program__c WHERE nu_dse__Account__c = :accountIdMap.get('primaryAccountId') LIMIT 1]){
                        parentIds = new Set<Id>();
                        if(objProgram.Portfolio__c != null){
                            parentIds.add(objProgram.Portfolio__c);
                        }
                        if(objProgram.nu_dse__Processor__c != null){
                            parentIds.add(objProgram.nu_dse__Processor__c);
                        }
                    }
                    if(parentIds != null && !parentIds.isEmpty()){
                        tempContentDocumentIds = new Set<Id>();
                        for(ContentDocumentLink objContentDocLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: parentIds AND Visibility='AllUsers' LIMIT 49999]){
                            tempContentDocumentIds.add(objContentDocLink.ContentDocumentId);
                        }
                    }
                    if(tempContentDocumentIds != null && !tempContentDocumentIds.isEmpty()){
                        lstWelcomeMaterialDocs = [SELECT Id, Title, FileType, Description, LastModifiedDate, ContentSize FROM ContentDocument Where Id IN: tempContentDocumentIds order by LastModifiedDate desc LIMIT 49999];
                    }
                return lstWelcomeMaterialDocs;
            }else{
                throw new AuraException('Something went wrong.. Account record not found!');
            }
        }catch(QueryException Qex){
            throw new AuraException('Something went wrong while fetching Welcome material..'+Qex.getMessage());
        }
        catch(Exception ex){
            throw new AuraException('Something went wrong while fetching Welcome material..'+ex.getMessage());
        }
    }
}