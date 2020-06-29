@isTest
public class BoxSearchTests implements HttpCalloutMock {

    public static testMethod void BoxSearchMethod() {
    
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new BoxSearchTests());
        
        BoxApiConnection api = new BoxApiConnection('clientid', 'clientsecret', 'accessToken', 'refreshToken');
        api.lastRefresh = DateTime.now().getTime() - 5;
        api.expires = api.lastRefresh + 60000;
        BoxApiRequest request = new BoxApiRequest(api,  'https://example.com', 'GET');
        request.setBody('request body', 12);
        request.setTimeout(500);
        HttpResponse finalResponse = request.send();
        BoxSearch boxSearchInstance = new BoxSearch(api, 'Test');
        boxSearchInstance.search('Test Query', 'Test');
        boxSearchInstance.getObjectType();
        Test.stopTest();
    }
    
     public HTTPResponse respond(HTTPRequest req) {
     
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         //res.setBody('');
         res.setStatusCode(300);
         return res;
     }
}