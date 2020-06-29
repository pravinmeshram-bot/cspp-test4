/* Date : 05-02-2019
 * Author : Team IDev
 * Description : MockHandler
 */

@isTest
global class SFSPortal_MockHandler implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        
        system.debug('mockkk::'+req.getEndpoint());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        TwilioConfig__c twilioConfig = TwilioConfig__c.getInstance();
        
        if(req.getEndpoint().Equals('https://verify.twilio.com/v2/Services/' + twilioConfig.ApplicationSid__c + '/Verifications')) {
            
            res.setStatusCode(201);
        }
        
        return res; 
    }
}