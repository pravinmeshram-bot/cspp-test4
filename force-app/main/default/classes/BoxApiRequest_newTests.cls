@isTest
public class BoxApiRequest_newTests implements HttpCalloutMock {

    public static testMethod void BoxApiRequest_newMethod1() {
    
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new BoxApiRequest_newTests());
        
        BoxApiRequest_new boxReq = new BoxApiRequest_new('www.google.com', 'Test');
        boxReq.setMultipartFormBody(Blob.valueOf('Test Body'), 'Test File');
        boxReq.setTimeout(100);
        HttpResponse httpRes = boxReq.send();
        boxReq.addJsonContentTypeHeader();
        boxReq.setBody('Test body');
        boxReq.setBody('Test body', 4);
        BoxApiRequest_new.getBoxResourceResponseBody(httpRes, 'Test String');
        BoxApiRequest_new.ensureBoxResourceResponseCode(httpRes, 'Test String', new Set<Integer> {200, 201, 202});
        HttpResponse res = new HttpResponse();
         res.setHeader('Location', 'www.test.com');
        boxReq.handleRedirect( res);
        Test.stopTest();
        
        system.AssertEquals(httpRes.getStatusCode(), 300);
    }
    
     public HTTPResponse respond(HTTPRequest req) {
     
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         //res.setBody('');
         res.setStatusCode(300);
         return res;
     }
}