@isTest
public class AddAsset_Test  {
    
    @isTest static void testAddAsset() {
        
        /****Changes for generic record creation****Starts****/
        Velocify_Settings__c settings = TestRecordCreator.createVelocifySettings();
        insert settings;
        
        Account acc = TestRecordCreator.createAccount('Test Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        insert acc;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc.Id, null);
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        insert program;
        
        nu_dse__TradeLine__c tradeLine = TestRecordCreator.createTradeLine(null, program.Id);
        tradeLine.nu_dse__Account__c = acc.Id;
        insert tradeLine;  
        /****Changes for generic record creation****Ends****/      
        
        RestRequest req = new RestRequest();
        req.params.put('clientId', program.Id);
        req.params.put('debtId', tradeLine.Id);
        req.params.put('assetType', 'my_offertype');
        req.params.put('assetFileName','my_filename.jpg');
        req.params.put('assetDescription','my_desc');
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res; 
        
        /*BoxApiConnection api = new BoxApiConnection('clientid', 'clientsecret', 'accessToken', 'refreshToken');
        api.lastRefresh = DateTime.now().getTime() - 5;
        api.expires = api.lastRefresh + 60000;
        BoxApiRequest request = new BoxApiRequest(api,  'https://example.com', 'GET');
        request.setBody('request body', 12);
        request.setTimeout(500);*/
        
        /*req.requestURI ='/AssetService/AddAsset?clientId=123&debtId=1222';
        req.httpMethod = 'POST';
        RestContext.request = req;*/
        
        Test.startTest();
        AddAsset.Response response1 = AddAsset.doPost();
        System.debug(':::Response1:::'+response1);
        Test.stopTest();
    }
    
    @isTest static void testAddAsset1() {
        
        /****Changes for generic record creation****Starts****/
        Velocify_Settings__c settings = TestRecordCreator.createVelocifySettings();
        insert settings;
        
        Account acc = TestRecordCreator.createAccount('Test Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        insert acc;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(acc.Id, null);
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        insert program;
        /****Changes for generic record creation****Ends****/
        
        RestRequest req = new RestRequest();
        req.params.put('clientId', program.Id);
        req.params.put('debtId', '');
        req.params.put('assetType', 'my_offertype');
        req.params.put('assetFileName','my_filename.jpg');
        req.params.put('assetDescription','my_desc');
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res; 
        
        Test.startTest();
        
        try{
            AddAsset.Response response1 = AddAsset.doPost();
        }catch(exception e){
        }
        
        Test.stopTest();
    }   
}