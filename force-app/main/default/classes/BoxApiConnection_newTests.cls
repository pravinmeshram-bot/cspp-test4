@isTest
public class BoxApiConnection_newTests {

    public static testMethod void BoxApiConnection_newMethod1() {
    
        String clientSec;
        
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'BoxDocs';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Test.startTest();
        
        BoxApiConnection_new boxConnection = new BoxApiConnection_new('1232213', '21313', '123131', '12312');
        BoxApiConnection_new boxConnection1 = new BoxApiConnection_new();
        boxConnection1.getTimeout();
        boxConnection1.getMaxRequestAttempts();
        boxConnection1.getAsUserId();
        boxConnection1.getBaseUrl();
        boxConnection1.getTokenUrl();
        boxConnection1.getUserAgent();
        boxConnection1.getClientSecret();
        boxConnection1.getClientId();
        
        clientSec = boxConnection1.clientSecret;
        
        BoxApiConnection_new boxConnection12 = new BoxApiConnection_new(null);
        BoxApiConnection_new boxConnection13 = new BoxApiConnection_new(null,null,null);
        boxConnection12.authenticate(null);
        //boxConnection12.refresh();
        Test.stopTest();
        
        //system.assertEquals(clientSec, '234532543254254');
    }
}