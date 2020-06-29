@istest
public class UpdateRefreshToken_Test implements HttpCalloutMock {

    public static testMethod void RefreshTokenTestMethod() {
        String clientSec;
        Box_settings__c boxSettings = new Box_settings__c();
        boxSettings.Name = 'BoxDocs';
        boxSettings.access_token__c = 'dfdsf2342424';
        boxSettings.Client_Secret__c = '234532543254254';
        boxSettings.Client_id__c = '34242';
        boxSettings.Refresh_Token__c = 'dfdsfwr43543';
        insert boxSettings;
        
        Test.startTest();
        
                
        Test.setMock(HttpCalloutMock.class, new UpdateRefreshToken_Test());
        
        UpdateRefreshtoken boxConnection = new UpdateRefreshtoken(); 
        SchedulableContext ctx;
        boxConnection.execute(ctx);
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