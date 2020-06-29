/*
 * This class is used to be as helper for many BOX api callout 
 * */
public class SFSPortal_DocumentCenterHelper {	
    public static Map<String,String> headers;
    public static integer maxRequestTimeoutMS = 120000; 
    public SFSPortal_DocumentCenterWrapper.FoldersInfo objWrapperFolderInfo;
    public SFSPortal_DocumentCenterHelper(){}
    
    //Method to generate HTTPRequest for call out
    public static HTTPRequest createHTTPReq(String reqBody, string reqEndPoint, string reqMethod, Map<String,String> headersMap){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(reqEndPoint);
        req.setMethod(reqMethod);
        if(reqBody!=null && reqBody!=''){
            req.setbody(reqBody);
        }
        if(headersMap != null && headersMap.size()>0){
            for(String ss : headersMap.keyset()){
                req.setHeader(ss,headersMap.get(ss));   
            }
        }
        req.setTimeout(maxRequestTimeoutMS);
        return req;
    }    
    //Method to do call out to Box
    public static HTTPResponse sendHttpRequest(HTTPRequest req){
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('****response body:'+res.getBody());
        return res;
    }
	//flter all subfolders based on existing schema
    public SFSPortal_DocumentCenterWrapper.FoldersInfo doFilterBasedOnSettingSchema(SFSPortal_DocumentCenterWrapper.FoldersInfo objWrappFolderInfo){
        system.debug('objWrappFolderInfo>>>'+objWrappFolderInfo);
        objWrapperFolderInfo = new SFSPortal_DocumentCenterWrapper.FoldersInfo();
        List<SFSPortal_DocumentCenterWrapper.entry> ohjEntityList =  new List<SFSPortal_DocumentCenterWrapper.entry>();
        //objWrappFolderInfo.item_collection.entries = new List<SFSPortal_DocumentCenterWrapper.entry>();
        //get All existing subfolder schema
        integer countReduce = 0;
        Map<String, Portal_Box_Document_Mapping__c> mapCategoryTypeToSchema = Portal_Box_Document_Mapping__c.getAll();
        system.debug('mapCategoryTypeToSchema>>>'+mapCategoryTypeToSchema);
        //if(objWrappFolderInfo.item_collection.entries.size()> 0 ){
            for(String PortalDocName : mapCategoryTypeToSchema.keyset()){
                system.debug('mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c>>>'+mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c);
                if(mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c != null){
                    system.debug('BoxName--'+PortalDocName+'AllBoxFolderName>>>>'+mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c.split(';'));
                    for(String boxFolderName :  mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c.split(',')){
                        system.debug('boxFolderName----'+boxFolderName.trim());
                        for(SFSPortal_DocumentCenterWrapper.entry en: objWrappFolderInfo.item_collection.entries){
                            system.debug('en----'+en);
                            if(boxFolderName.trim() == en.name){
                                SFSPortal_DocumentCenterWrapper.entry objItem = en;
                                objItem.category = PortalDocName;
                                ohjEntityList.add(objItem);
                            }
                        }
                    }
                }
            }
            system.debug('objWrappFoldeohjEntityListrInfo>>>'+ohjEntityList);
            objWrappFolderInfo.item_collection.entries = ohjEntityList;
        //}
        system.debug('objWrappFolderInfo>>>'+objWrappFolderInfo);
     
        return objWrappFolderInfo;
    }
	
    //Create HTTP request header
	public static Map<String, String> getRequestHeader(String access_token){
        system.debug('access_token---'+access_token);
        if(String.isNotBlank(access_token)){
			headers=new Map<String,String>();
			headers.put('Content-Type','application/x-www-form-urlencoded');
			headers.put('Accept','application/json');
			headers.put('Authorization','Bearer ' + access_token);
            system.debug('headers!!!'+headers);
			return headers;
		}else{
			return null;
		}			
	}
        
    //get All subfolder details
    public static  Map<String, List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>> doFetchAllSubfolderInfo( Map<String, List<SFSPortal_DocumentCenterWrapper.entry>> mapCategoryToEntries, String access_token, String boxFolderEndPoint){
        system.debug('mapCategoryToEntries!!!'+mapCategoryToEntries);
        Map<String, List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>> mapCategoryToSubFolderEntryInfo = new Map<String, List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>>();
        SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper objSubFolderWrapper;
        //String access_token = 'HJjC6PfKvq6jPw3BNx7t3YH3O29hhcAs';
        headers = getRequestHeader(access_token);
        HTTPResponse res ;
        String resposeBody = '';
        String boxFolderEndPointTemp = '';
        //String requestParam = '/items?fields=name,created_at,modified_at,extension,size,expiring_embed_link';
        String requestParam = '/items?fields=name,created_at,modified_at,extension,size';
        for(String strCategory : mapCategoryToEntries.keySet()){
            for(SFSPortal_DocumentCenterWrapper.entry objWraapEntry : mapCategoryToEntries.get(strCategory)){
                boxFolderEndPointTemp = boxFolderEndPoint + '/' + objWraapEntry.id + requestParam;
                System.debug('boxFolderEndPoint>>>>'+boxFolderEndPoint);
                if(createHTTPReq('', boxFolderEndPointTemp,'GET',headers) != null && createHTTPReq('', boxFolderEndPointTemp,'GET',headers).getMethod().startsWith('GET')){
                    HttpRequest objRequestLabel  = createHTTPReq('', boxFolderEndPointTemp,'GET',headers);
                    res = sendHttpRequest(objRequestLabel); //Callout in for loop as we have fetch all subfolder details
                    system.debug('res!!!!!'+res);
                    if(res.getStatusCode() == 200 && res.getStatus() == 'OK'){
                        resposeBody = res.getBody();
                        string resposeBodyTemp = resposeBody.replace('"limit"','"res_limit"');
                        system.debug(resposeBodyTemp+'resposeBody!!!!@!!!!!');
                        objSubFolderWrapper = (SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper)JSON.deserialize(resposeBodyTemp,SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper.class);                     
                        system.debug('objSubFolderWrapper===='+objSubFolderWrapper);
                        if(!mapCategoryToSubFolderEntryInfo.containsKey(strCategory)){
                            mapCategoryToSubFolderEntryInfo.put(strCategory, new List<SFSPortal_DocumentCenterWrapper.subfolderDetailsWrapper>());
                        }
                        mapCategoryToSubFolderEntryInfo.get(strCategory).add(objSubFolderWrapper);
                    }
                    
                }
            }
        }
        system.debug('mapCategoryToSubFolderEntryInfo>!!!>>'+mapCategoryToSubFolderEntryInfo);
        if(!mapCategoryToSubFolderEntryInfo.isEmpty()){
            return mapCategoryToSubFolderEntryInfo;
        }else{
            return null;
        }
    }
    //generic method to download a file
    public static String downloadSelectedFileHelper(String fileID, String access_token){
        String endpointForFileDownload = 'https://api.box.com/2.0/files/'+fileID+'/content';
        HTTPResponse res ;
        String sFilename='';
        Blob body;
        try{
            headers = getRequestHeader(access_token); 
            system.debug('href----'+headers);
            HttpRequest objRequestLabel  = createHTTPReq('', endpointForFileDownload , 'GET' , headers);
            res = sendHttpRequest(objRequestLabel); 
            if(res.getStatusCode() == 302 && res.getStatus() == 'Found' ){
                system.debug('doc-----'+res.getBody());
                String fileDownloadURL = res.getHeader('Location');
                system.debug('fileDownloadURL----'+fileDownloadURL);
                return fileDownloadURL;
            }else{
                throw new AuraException('Something went wrong while downloading the file - '+res.getStatus());
            }
        }catch(Exception ex){
            throw new AuraException('Something went wrong while downloading the file - '+ex.getMessage());
        }
    }
    //helper method to preview a box file
    public static String getPreviewLinkHelper(String fileID, BoxApiConnection api){
        try{
            BoxFile file = new BoxFile(api, fileID); //create a BoxFile Instanse
            system.debug('file----!!!'+file);
            String previewLink = file.getPreviewLink();
            system.debug('previewLink---!!!'+previewLink);
            if(previewLink.contains('https://')){
                return previewLink;
            }else{
                throw new AuraException('Something went wrong while preview the file :');
            }
        }catch(Exception ex){
            throw new AuraException('Something went wrong while preview the file : '+ex.getMessage());
        }
        
    }
    
}