public class uploadBoxFilesNew{
    public String accessToken{get;set;}
     public string pgmid {get;set;}
     public account acc {get;set;}
     public string pgm{get;set;}
     public string folderid{get;set;}
     public static Box_settings__c settings{get;set;}
     public boolean generateNewToken {get; set;}

     public uploadBoxFilesNew(){
         pgmId = ApexPages.currentPage().getParameters().get('pid');
         if(pgmId != null){
            pgm = [select id,name,nu_dse__account__c from nu_dse__Program__c where id=:pgmId].nu_dse__account__c;
        }
          if(pgm != null){
           folderid = [select id,name,BoxFolderId__c from account where id=:pgm ].BoxFolderId__c;
          }
        generateNewToken = false;
     }
    //@RemoteAction
    public void getAccessToken(){
        system.debug('+++++++'+generateNewToken);
        // get the box custom setting and use the stored access token
        settings = Box_settings__c.getValues('box');
        if(settings !=null && settings.access_token__c != null && settings.Last_Refresh_Date__c != null  && !generateNewToken){
        	Integer lifetimeMinutes = settings.Access_Token_Lifetime__c != null ? Integer.valueOf(settings.Access_Token_Lifetime__c) : 30;
            DateTime tokenLifeTime = settings.Last_Refresh_Date__c.addMinutes(lifetimeMinutes);
            if (tokenLifeTime > system.now()){
                system.debug('++++settings.access_token__c+++'+settings.access_token__c);
                accessToken = settings.access_token__c;
                return;
            }
        }
        Map<String, String> credential = new Map<String, String>();
        List<Document> docs = [SELECT Body, BodyLength, ContentType, Url from Document WHERE Name = 'Box Cred'];
        if(docs.isEmpty() == false) {
            String[] lineList = (docs[0].Body.toString()).split('\n');
            Map<String, String> pairMap = new Map<String, String>();
            for(String line : lineList) {
                system.debug('line-->'+line);
                String[] split = line.split('=', 2);
                system.debug('split-->'+split);
                if(split.size() == 2) {
                    pairMap.put(split[0].trim(), split[1].trim());
                }
            }           
            credential = pairMap;
        }

        String encriptionName = 'SHA1';
        String privatekey = credential.get('privatekey'); 
        String enterpriseId = credential.get('enterpriseId');
        String userId = '257193021';
        String publicKeyId = credential.get('publicKeyId');
        String clientId = credential.get('clientId');
        String clientSecret = credential.get('clientSecret');
        
        BoxJwtEncryptionPreferences preferences = new BoxJwtEncryptionPreferences();
        preferences.setPublicKeyId(publicKeyId);
        preferences.setPrivateKey(privateKey);
        try {
            BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppUserConnection(enterpriseId, clientId, clientSecret, preferences);
            //BoxPlatformApiConnection api = BoxPlatformApiConnection.getAppEnterpriseConnection(userId, clientId, clientSecret, preferences);
            accessToken = api.accessToken;
            system.debug('+++accessToken++'+accessToken);
            settings.access_token__c = accessToken;
            settings.Last_Refresh_Date__c = system.now();
            
            update settings;
        } catch(Exception e) {
            System.debug('exception: ' + e);
        }
    } 
}