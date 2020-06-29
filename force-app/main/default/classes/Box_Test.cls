@isTest
public class Box_Test {
    
    private static String accessToken = 'accesstoken';
    private static String refreshToken = 'refreshtoken';
    private static String clientId = 'clientid';
    private static String clientSecret = 'clientsecret';
    private static String authCode = 'authcode';
    
    static testMethod void testBox() {
    
        /****Changes for generic record creation****Starts****/
        Account acc = TestRecordCreator.createAccount('Test Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.nu_dse__client_number__c = 111222;
        insert acc;
               
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc.Id, null);
        program.External_Id__c= 'Test_CreateTaskData'; 
        insert program; 
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(null, null);
        insert tradeLine;
        /****Changes for generic record creation****Ends****/
        
        Box_settings__c box1 = new Box_settings__c(Name = 'Box',Client_id__c = 'clientid', Client_Secret__c = 'clientsecret' , Refresh_Token__c = 'refreshtoken', access_token__c = 'accesstoken' );
        insert box1;
        
        Test.startTest();
        
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
        
        BoxApiConnection apiURL = new BoxApiConnection();
        apiURL.baseUrl = 'https://www.box.com/s/vspke7y05sb214wjokpk';
        apiURL.maxRequestAttempts = 1;
        BoxApiConnection.settings = box1;
        BoxApiConnection api1 = new BoxApiConnection(accessToken);
        BoxApiConnection api2 = new BoxApiConnection(clientId, clientSecret);
        BoxApiConnection api3 = new BoxApiConnection(clientId, clientSecret, accessToken, refreshToken);
        BoxApiConnection api4 = new BoxApiConnection(clientId, clientSecret, authCode);
        
        System.assertEquals('T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl', api4.accessToken);
        
        String mockResponseBody = '{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Old folder name","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/vspke7y05sb214wjokpk","download_url":null,"vanity_url":null,"is_password_enabled":false,"unshared_at":null,"download_count":0,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"folder_upload_email":{"access":"open","email":"upload.Picture.k13sdz1@u.box.com"},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},"item_status":"active","item_collection":{"total_count":1,"entries":[{"type":"file","id":"5000948880","sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg"}],"offset":0,"limit":100}}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'OK', 200));
        
        /*BoxApiConnection api = new BoxApiConnection('accesstoken');
        BoxFolder folderToCopy = new BoxFolder(api, '11446498');
        BoxFolder destination = new BoxFolder(api, '0');
        BoxFolder folder = BoxFolder.getRootFolder(api);
        BoxApiConnection apiFromFolder = folder.getApi();*/
        
        BoxApiConnection api = new BoxApiConnection('clientid', 'clientsecret', 'accessToken', 'refreshToken');
        api.lastRefresh = DateTime.now().getTime() - 5;
        api.expires = api.lastRefresh + 60000;
        BoxApiRequest request = new BoxApiRequest(api,  'https://example.com', 'GET');
        request.setBody('request body', 12);
        request.setTimeout(500);
        
        Box boxResp = new Box();
        boxResp.api = api;
        system.debug('Box---->'+boxResp.api);
        boxResp.uploadFilesToBox(program, 'text', 'test\\.Record', 'Test description', Blob.valueOf('Unit Test Attachment Body'));
        
        Test.stopTest();
    }
}