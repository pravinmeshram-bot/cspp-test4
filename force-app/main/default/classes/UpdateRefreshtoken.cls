global class UpdateRefreshtoken implements Schedulable {

    global void execute(SchedulableContext ctx) {
    Integer DEFAULT_CALLOUT_TIMEOUT = 60000;
    String HEADER_CONTENT_TYPE = 'Content-Type';
    String HEADER_APPLICATION_ENCODED = 'application/x-www-form-urlencoded';
    
    Box_settings__c settings=new Box_settings__c();
    settings = Box_settings__c.getValues('BoxDocs');
    if(settings !=null && String.isNotBlank(settings.Client_id__c) && String.isNotBlank(settings.Client_Secret__c) && String.isNotBlank(settings.Refresh_Token__c)){
       String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';
        BoxApiConnection_new boxapi =new BoxApiConnection_new();
        BoxApiRequest_new request = new BoxApiRequest_new(boxapi, TOKEN_URL_STRING, 'POST');
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
            settings.access_token__c=authResponse.getValue('access_token');
            settings.Refresh_Token__c=authResponse.getValue('refresh_token');
            settings.expires__c=authResponse.getValue('expires_in');
            update settings; 
        } else {
            //throw new BoxApiConnectionException('BoxApiConnection unable to use refresh token to generate new access token: ' + response.toString());
            settings.Last_Refresh_Date__c = system.now();
            if(response.getBody().length() > 255)
                settings.Error_Message__c = response.getBody().subString(0,255);
           else
               settings.Error_Message__c = response.getBody();
               
           update settings;
        }
        
        }
        
    }
}