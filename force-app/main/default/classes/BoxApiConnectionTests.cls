@isTest
public class BoxApiConnectionTests {
    private static String accessToken = 'accesstoken';
    private static String refreshToken = 'refreshtoken';
    private static String clientId = 'clientid';
    private static String clientSecret = 'clientsecret';
    private static String authCode = 'authcode';

    public static testmethod void testConstructors() {
        Test.startTest();
        BoxApiConnection api1 = new BoxApiConnection(accessToken);
        BoxApiConnection api2 = new BoxApiConnection(clientId, clientSecret);
        BoxApiConnection api3 = new BoxApiConnection(clientId, clientSecret, accessToken, refreshToken);
        Test.stopTest();
    }

    public static testmethod void testAuthenticateFromCode() {
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        Test.startTest();
        BoxApiConnection api = new BoxApiConnection(clientId, clientSecret, authCode);
        Test.stopTest();
        System.assertEquals('T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl', api.accessToken);
    }

    public static testmethod void testGetAccessTokenWithoutRefresh() {
        Test.startTest();
        BoxApiConnection api = new BoxApiConnection(accessToken);
        String currentAccessToken = api.getAccessToken();
        Test.stopTest();
        System.assertEquals(accessToken, currentAccessToken);
    }
    
    public static testmethod void testGetAccessTokenWithRefresh() {
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        Test.startTest();
        BoxApiConnection api = new BoxApiConnection(clientId, clientSecret, accessToken, refreshToken);
        api.expires = 500;
        api.lastRefresh = DateTime.now().getTime() - 1000;
        String currentAccessToken = api.getAccessToken();
        Test.stopTest();
        System.assertEquals('T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl', currentAccessToken);
    }
    
    public static testmethod void testGetAccessTokenWithRefresh1() {
        
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'box';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Test.startTest();
        BoxApiConnection api = new BoxApiConnection();
        api.getBaseUrl();
        api.getBaseUploadUrl();
        api.setAsUserId(String.valueOf(UserInfo.getUserId()));
        Test.stopTest();
    }
}