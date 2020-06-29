public class ClientFolderCreation {
   @TestVisible private static String FOLDER_URL = 'https://api.box.com/2.0/folders';
   public static String refreshToken;
   public static String accessToken;
   //public static String clientId;
   //public static String clientSecret;
    private class ParentFolder {
        public String id;
        public ParentFolder(String id) {
            this.id = id;
        }
    }
    
    private class Folder {
        public String name;
        ParentFolder parent;
        
        public Folder(String name, String parentId) {
            this.name = name;
            this.parent = new ParentFolder(parentId);
        }
    }
    
    /**
    * Static method to create the folder inside of the box account
    * 
    * @param accountId The account id to create the folder for
    */
    @Future(callout = true)
    public static void createFolder(String clientNumber,Id accountId) {
        //if (Box_settings__c.getValues('box') == null) {
        //    return;
        //}
        String access_token = '';
        Box_settings__c objBoxsettings = getNewAuthTokens();
        if(objBoxsettings != null)
            access_token = objBoxsettings.access_token__c;
        Folder folder_info = new Folder(clientNumber, '0');
        HttpRequest request=new HttpRequest();
        request.setEndpoint(FOLDER_URL); 
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + access_token);
        String body = JSON.serialize(folder_info);
        System.debug(body);
        request.setBody(body);
        
        Http p = new Http();
        HttpResponse response = new HttpResponse();
        
        if (Test.isRunningTest() == False) {
            response = p.send(request);
        } else { // developed below code on oct03 to set as response in test class context
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"type":"folder","id":"39729917219","sequence_id":"0","etag":"0","name":"CL-26774","created_at":"2017-10-03T04:53:00-07:00","modified_at":"2017-10-03T04:53:00-07:00","description":"","size":0,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"257193021","name":"Test Name","login":"test@name1.com"},"modified_by":{"type":"user","id":"257193021","name":"Test Name","login":"testName1@stratfs.com"},"trashed_at":null,"purged_at":null,"content_created_at":"2017-10-03T04:53:00-07:00","content_modified_at":"2017-10-03T04:53:00-07:00","owned_by":{"type":"user","id":"257193021","name":"Test Name","login":"testname@stratfs.com"},"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},"item_status":"active","item_collection":{"total_count":0,"entries":[],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}');
            response.setStatusCode(200);
            response.setStatus('Created');
        }
        system.debug('##Response Body-> '+response);
        system.debug('##Response Body--> '+response.getBody());
        list<string> foldernames = new list<string>{'1099c','Add Remove Debt','Bank Info','Bank Levy','Bankruptcy','Notifications','Call Logs','Cancellation Notice','Collection Notice','Creditor Notifications','Customer Correspondence','Death Notifications','Hardship Letters','Legal Garnishments','Legal Judgments','Legal Property Lien','Legal Settlements & Stipulations','Legal Summons','Legal- other','LOR – Fax Confirmation','Payment Schedule Adjustments','Power of Attorney','Releases','Satisfaction Letters','Settlement Letters','Settlement Offer','Statements','Updated Contracts','Original Contracts'};
        if(response != null && response.getStatusCode() == 201){
            if(String.isNotBlank(response.getBody()) && !response.getBody().contains('error')){
                String folderId = getFolderId(response.getBody());
                Account objAcc = new Account(Id=accountId,BoxFolderId__c=folderId);
                for(string f:foldernames){
                    Folder folder_info1 = new Folder(f, folderId);
                    HttpRequest request1=new HttpRequest();
                    request1.setEndpoint(FOLDER_URL); 
                    request1.setMethod('POST');
                    request1.setHeader('Authorization', 'Bearer ' + access_token);
                    String body1 = JSON.serialize(folder_info1);
                    System.debug(body1);
                    request1.setBody(body1);
                    Http p1 = new Http();
                    HttpResponse response1 = p1.send(request1);
                    system.debug('##response1-> '+response1);
                }
                update objAcc;
                system.debug('##objAcc-> '+objAcc);
            }
        }
        if(objBoxsettings != null)
            update objBoxsettings;
    }
    
    public static String getFolderId(String responseBody){
        String folderId=null;
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
    
    /*public static void getExistingAuthTokens(){
        Box_settings__c settings = Box_settings__c.getValues('box');
        if(settings != null){
            //clientId = settings.Client_id__c;
            //clientSecret = settings.Client_Secret__c;
            refreshToken = settings.Refresh_Token__c;
            accessToken = settings.access_token__c;
            system.debug('@@ refreshToken->'+refreshToken);
            system.debug('@@ accessToken->'+accessToken);
        }
    }*/
    
    /*public static void updateAuthTokens(){
        Box_settings__c settings = Box_settings__c.getValues('box');
        if(settings != null){
            if(String.isNotBlank(refreshToken) && String.isNotBlank(accessToken)){
                settings.Refresh_Token__c = refreshToken;
                settings.access_token__c = accessToken;
                
                update settings;
            }
        }
    }*/
    
    //@Future(callout = true)
    public static Box_settings__c getNewAuthTokens(){
        Integer DEFAULT_CALLOUT_TIMEOUT = 60000;
        String HEADER_CONTENT_TYPE = 'Content-Type';
        String HEADER_APPLICATION_ENCODED = 'application/x-www-form-urlencoded';
        Box_settings__c settings = Box_settings__c.getValues('box');
        if(settings !=null && String.isNotBlank(settings.Client_id__c) && String.isNotBlank(settings.Client_Secret__c) && String.isNotBlank(settings.Refresh_Token__c)){
           String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';
            BoxApiConnection boxapi =new BoxApiConnection();
            BoxApiRequest request = new BoxApiRequest(boxapi, TOKEN_URL_STRING, 'POST');
            request.shouldAuthenticate = false;
            request.setTimeout(100000);
            String urlParameters = String.format('grant_type=refresh_token&refresh_token={0}&client_id={1}&client_secret={2}',
                new String[] {settings.Refresh_Token__c, settings.Client_id__c, settings.Client_Secret__c});
            request.setBody(urlParameters);
            request.addHeader(HEADER_CONTENT_TYPE, HEADER_APPLICATION_ENCODED);
            HttpResponse response = request.send();
            system.debug('---217---response------'+response);
            if (response.getStatus() == 'OK') {
                BoxGenericJsonObject authResponse = new BoxGenericJsonObject(response.getBody());
                accessToken=authResponse.getValue('access_token');
                refreshToken=authResponse.getValue('refresh_token');
                if(settings != null){
                    settings.access_token__c=accessToken;
                    settings.Refresh_Token__c=refreshToken;
                    system.debug('---146---settings------'+settings);
                    //update settings;
                }
            }
        }
        return settings;
    }
}