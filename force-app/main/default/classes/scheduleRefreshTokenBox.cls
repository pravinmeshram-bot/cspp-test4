global class scheduleRefreshTokenBox implements Schedulable {

    global void execute(SchedulableContext ctx) {
    string accessToken='';
    string refreshToken='';
    Integer DEFAULT_CALLOUT_TIMEOUT = 60000;
    String HEADER_CONTENT_TYPE = 'Content-Type';
    String HEADER_APPLICATION_ENCODED = 'application/x-www-form-urlencoded';
    
    Box_settings__c settings=new Box_settings__c();
    settings = Box_settings__c.getValues('Daily Report');
    if(settings !=null && settings.Client_id__c != null && settings.Client_Secret__c != null && settings.Refresh_Token__c !=null){
       accessToken=settings.access_token__c;
       refreshToken=settings.Refresh_Token__c;
    } 
        String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';
        BoxApiConnection boxapi =new BoxApiConnection();
        BoxApiRequest request = new BoxApiRequest(boxapi, TOKEN_URL_STRING, 'POST');
        request.shouldAuthenticate = false;
        request.setTimeout(100000);
        String urlParameters = String.format('grant_type=refresh_token&refresh_token={0}&client_id={1}&client_secret={2}',
            new String[] {refreshToken, settings.Client_id__c, settings.Client_Secret__c});
        request.setBody(urlParameters);
        request.addHeader(HEADER_CONTENT_TYPE, HEADER_APPLICATION_ENCODED);
        
        HttpResponse response = request.send();
        system.debug('---217---response------'+response);
        if (response.getStatus() == 'OK') {
            BoxGenericJsonObject authResponse = new BoxGenericJsonObject(response.getBody());
            List<Box_settings__c> lstBOXSettings=new List<Box_settings__c>();
            lstBOXSettings=[select Id,Name,access_token__c,Client_id__c,Client_Secret__c,expires__c,lastRefresh__c,Refresh_Token__c from Box_settings__c where Name='Daily Report']; 
            lstBOXSettings[0].access_token__c=authResponse.getValue('access_token');
            lstBOXSettings[0].Refresh_Token__c=authResponse.getValue('refresh_token');
            lstBOXSettings[0].expires__c=authResponse.getValue('expires_in');
            update lstBOXSettings; 
        } else {
            //throw new BoxApiConnectionException('BoxApiConnection unable to use refresh token to generate new access token: ' + response.toString());
        }
    
    }
    
    
}    

/* 
    // Execute below script to execute schedular every day at 10:50 PM
    scheduleRefreshTokenBox objSRTB = new scheduleRefreshTokenBox();
    // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    String sch = '0 50 22 * * ?';
    String jobID = System.schedule('Box Access Token Refresh', sch, objSRTB);

*/