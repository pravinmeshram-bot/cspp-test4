@isTest
public class OfferStatusComponentController_Test implements HttpCalloutMock {
            
    @isTest static void testOfferStatusComponentController() {
        
        // uncommented out the below code on oct10-2017
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
                
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        //program.External_Id__c= 'Test_CreateTaskData'; 
        program.External_Id__c= '11223344'; // Modified on oct03-2017
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        nu_dse__TradeLine__c trd = new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = program.id;
        trd.nu_dse__Original_Debt__c = 2.0;
        insert trd;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__Status__c = 'Pending Client Approval';
        offer.nu_dse__Program__c = program.Id;
        offer.nu_dse__TradeLine__c = trd.Id;
        insert offer;
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new OfferStatusComponentController_Test());
        List<OfferStatusComponentController.Offer> offerCtrl = OfferStatusComponentController.getOffer(program.Id);
        OfferStatusComponentController.offer ofr = new OfferStatusComponentController.offer(offer); 
        Test.stopTest();
        
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
}