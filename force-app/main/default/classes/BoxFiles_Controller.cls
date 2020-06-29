global with sharing class BoxFiles_Controller {
 public string pgmid {get;set;}
 public account acc {get;set;}
 public nu_dse__Program__c pgm{get;set;}
 public string sharedlink{get;set;}

    public BoxFiles_Controller(ApexPages.StandardController controller) {
        pgmId = ApexPages.currentPage().getParameters().get('id');
        system.debug('----pgmId -id----'+pgmId );
        if(pgmId != null){
            pgm = [select id,name,nu_dse__account__c from nu_dse__Program__c where id=:pgmId];
        }
        if(pgm != null && pgm.nu_dse__account__c != null){
            acc = [select id,sharedlink__c from account where id=:pgm.nu_dse__account__c];
            if(acc != null && string.isNotBlank(acc.sharedlink__c)){
                sharedlink = acc.sharedlink__c;
            }else{
               sharedlink = null; 
            }
        }
    }
    
    public BoxFiles_Controller() {
        pgmId = ApexPages.currentPage().getParameters().get('pid');
        system.debug('----pgmId -pid----'+pgmId );
        if(pgmId != null){
            pgm = [select id,name,nu_dse__account__c from nu_dse__Program__c where id=:pgmId];
        }
        if(pgm != null && pgm.nu_dse__account__c != null){
            acc = [select id,sharedlink__c from account where id=:pgm.nu_dse__account__c];
            if(acc != null && string.isNotBlank(acc.sharedlink__c)){
                sharedlink = acc.sharedlink__c;
            }else{
               sharedlink = null; 
            }
        }
    }
    
    //@RemoteAction
    public void FilesharingLink(){
        if(String.isBlank(sharedlink) || sharedlink == 'null'){
           List<Box_settings__c> lstBOXSettings=null; 
            string accessToken='';
            string refreshToken='';
            Integer DEFAULT_CALLOUT_TIMEOUT = 60000;
            String HEADER_CONTENT_TYPE = 'Content-Type';
            String HEADER_APPLICATION_ENCODED = 'application/x-www-form-urlencoded';
    
            Box_settings__c settings=new Box_settings__c();
            settings = Box_settings__c.getValues('box');
            if(settings !=null && settings.Client_id__c != null && settings.Client_Secret__c != null && settings.Refresh_Token__c !=null){
               accessToken=settings.access_token__c;
               refreshToken=settings.Refresh_Token__c;
            } 
    
            String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';
            BoxApiConnection_new boxapi =new BoxApiConnection_new();
            BoxApiRequest_new request = new BoxApiRequest_new(boxapi, TOKEN_URL_STRING, 'POST');
            request.shouldAuthenticate = false;
            request.setTimeout(100000);
            String urlParameters = String.format('grant_type=refresh_token&refresh_token={0}&client_id={1}&client_secret={2}',
                new String[] {refreshToken, settings.Client_id__c, settings.Client_Secret__c});
            request.setBody(urlParameters);
           
            request.addHeader(HEADER_CONTENT_TYPE, HEADER_APPLICATION_ENCODED);
            HttpResponse response = request.send();
            if (response != null && response.getStatus() == 'OK') {
                BoxGenericJsonObject authResponse = new BoxGenericJsonObject(response.getBody());
                lstBOXSettings=new List<Box_settings__c>();
                lstBOXSettings=[select Id,Name,access_token__c,Client_id__c,Client_Secret__c,expires__c,lastRefresh__c,Refresh_Token__c from Box_settings__c where Name='box']; 
                lstBOXSettings[0].access_token__c=authResponse.getValue('access_token');
                lstBOXSettings[0].Refresh_Token__c=authResponse.getValue('refresh_token');
                lstBOXSettings[0].expires__c=authResponse.getValue('expires_in');
                accessToken = lstBOXSettings[0].access_token__c;
            } else {
            //throw new BoxApiConnectionException('BoxApiConnection unable to use refresh token to generate new access token: ' + response.toString());
        }
        
        string folderid = [select id,name,BoxFolderId__c from account where id=:acc.id].BoxFolderId__c;
        String EndPointURL='https://api.box.com/2.0/folders/'+folderid+'?Feilds=shared_link';
        String strBody ='{"shared_link":{"access":"open"}}';
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setEndpoint(EndPointURL);
        req.setMethod('PUT');
        req.setBody(strBody);
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse res = http.send(req);
        String strResponse=res.getBody(); 
        JSONParser parser = JSON.createParser(strResponse);
        while((parser.nextToken()) != null) {
            parser.nextToken();
            parser.nextToken();
            parser.nextToken();            
            if(parser.getCurrentName() == 'url'){
                system.debug('@ parser.getText()=>'+parser.getText());
                sharedlink = parser.getText();
            }
        }
        if(String.isNotBlank(sharedlink) && acc != null){
            acc.sharedlink__c = sharedlink;
            update acc;
        }
        if(lstBOXSettings != null && lstBOXSettings.size() > 0)
        update lstBOXSettings;
  
        }
    }
}