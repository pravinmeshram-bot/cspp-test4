@isTest
public class PaymentTrigHandler_Test {
    
    @testSetup static void setup() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Carolina Legal Services', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Attorney__c = false;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'Management Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer; 
        
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        list<nu_dse__Payment__c> paymentList = new list<nu_dse__Payment__c>();
        for(Integer i=1; i<3; i++){
            paymentList.add(new nu_dse__Payment__c(RecordTypeId = draftRecordTypeId, nu_dse__Transaction_Status__c = 'In Progress',
                                                          nu_dse__Schedule_Date__c=System.Today().addDays(i), nu_dse__Offer__c=offer.Id,
                                                          nu_dse__Program__c=testProgram.Id, nu_dse__Amount__c=100));
        }
        insert paymentList;
    }
    
    static testmethod void testUpdate(){
        List<nu_dse__Payment__c> payments =  [SELECT Id, nu_dse__program__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c FROM nu_dse__Payment__c];
        
        test.startTest();
            payments[0].nu_dse__Schedule_Date__c=System.Today().addDays(4);
            update payments[0];
        test.stopTest();
    }
    
    static testmethod void testDelete(){
        List<nu_dse__Payment__c> payments =  [SELECT Id, nu_dse__program__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c FROM nu_dse__Payment__c];
        
        test.startTest();
            delete payments[0];
        test.stopTest();
    }
}