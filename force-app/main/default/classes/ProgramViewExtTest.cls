@isTest
public class ProgramViewExtTest {
    static testmethod void ProgramView(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'); 
            
        Id recTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTyPeId();
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
       
        Account accObj = new Account();
        accObj.Firstname = 'test1 ';
        accObj.Lastname = 'test ';
        accObj.RecordTypeId = recTypeId;
        insert accObj;
        
        nu_dse__Program__c pgm= new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accObj.id;
        pgm.external_id__c = '11223344';
        insert pgm;
        
        nu_dse__TradeLine__c trd= new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = pgm.id;
        trd.nu_dse__Original_Debt__c = 2.0;
        insert trd;
        
        nu_dse__Offer__c ofr= new nu_dse__Offer__c();
        ofr.nu_dse__TradeLine__c = trd.id; 
        ofr.nu_dse__Program__c = pgm.id;
        insert ofr;
        
        nu_dse__Payment__c payment= new nu_dse__Payment__c();
        payment.nu_dse__Program__c = pgm.id;
        insert payment;
     
        Test.setCurrentPageReference(new PageReference('Page.ProgramView')); 
        System.currentPageReference().getParameters().put('id', accObj.id);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accObj);
        ProgramViewExt newProgramView = new ProgramViewExt(sc);
        Test.stopTest();
    }

}