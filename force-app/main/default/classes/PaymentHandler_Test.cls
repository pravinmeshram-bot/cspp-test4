@isTest
public class PaymentHandler_Test implements HttpCalloutMock {

    public static String paymentSObj = nu_dse__Payment__c.sObjectType.getDescribe().getName();
    
    
      static testmethod void modifyLeadsPaymentstestmethod(){
       	
         
          
          nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        nu_dse__Payment__c testPayment = new nu_dse__Payment__c(nu_dse__Program__c = program.id,nu_dse__Amount__c = 2000, nu_dse__Schedule_Date__c= system.today(), RecordTypeId= '01241000000jtbp');
        insert testPayment;
        
    }
    
    
    @isTest static void testCreateProposal() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        nu_dse__Field_mapping__c fieldMapping = new nu_dse__Field_mapping__c();
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
        
        List<RecordType> rectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Draft' AND 
                       SObjectType =: paymentSObj AND isActive = True];
        
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();   
        
        if (!rectypeList.isEmpty()) {    
                
            nu_dse__Payment__c payment= new nu_dse__Payment__c();
            payment.nu_dse__Program__c = program.id;
            payment.nu_dse__transaction_status__c = 'In Progress';
            payment.nu_dse__Amount__c = 1000;
            payment.nu_dse__Schedule_Date__c = System.Today();
            payment.RecordTypeId = rectypeList[0].Id;
            paymentList.add(payment);
            
            nu_dse__Payment__c payment1= new nu_dse__Payment__c();
            payment1.nu_dse__Program__c = program.id;
            payment1.nu_dse__transaction_status__c = 'In Progress';
            payment1.nu_dse__Amount__c = 1000;
            payment1.nu_dse__Schedule_Date__c = System.Today();
            payment1.RecordTypeId = rectypeList[0].Id;
            paymentList.add(payment1);
            
            nu_dse__Payment__c payment2= new nu_dse__Payment__c();
            payment2.nu_dse__Program__c = program.id;
            payment2.nu_dse__transaction_status__c = 'In Progress';
            payment2.nu_dse__Amount__c = 1000;
            payment2.nu_dse__Schedule_Date__c = System.Today();
            payment2.RecordTypeId = rectypeList[0].Id;
            paymentList.add(payment2);
            
            nu_dse__Payment__c payment3= new nu_dse__Payment__c();
            payment3.nu_dse__Program__c = program.id;
            payment3.nu_dse__transaction_status__c = 'In Progress';
            payment3.nu_dse__Amount__c = 1000;
            payment3.nu_dse__Schedule_Date__c = System.Today();
            payment3.RecordTypeId = rectypeList[0].Id;
            paymentList.add(payment3);
        }
        insert paymentList;
        
        paymentList[0].nu_dse__transaction_status__c = 'Completed';
        paymentList[1].nu_dse__transaction_status__c = 'Completed';
        paymentList[2].nu_dse__transaction_status__c = 'Completed';
        paymentList[3].nu_dse__transaction_status__c = 'Completed';
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new PaymentHandler_Test());
        update paymentList;
        
        Test.stopTest();  
        
        List<nu_dse__Payment__c> payments = [SELECT Id, Name, nu_dse__transaction_status__c FROM nu_dse__Payment__c]; 
        system.assertEquals(payments[0].nu_dse__transaction_status__c, 'Completed');
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
    
    static testmethod void modifyLeadsPaymentstest(){
        List<nu_dse__Payment__c> pmntId =  [SELECT Id, nu_dse__program__c, nu_dse__Amount__c, nu_dse__Schedule_Date__c FROM nu_dse__Payment__c];
        List<Id> pmtId = new List<Id>();
        
        for(nu_dse__Payment__c pymtId: pmntId){
            pmtId.add(pymtId.Id);
        }
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
            settings.Username__c = 'velocifyapi@stratfs.com';
            settings.Password__c = 'hSh0BoeJ';
            insert settings;
        
        test.startTest();
        	//PaymentHandler PH = new PaymentHandler();
        	PaymentHandler.modifyLeadsPayments(pmtId);
        test.stopTest();
    }

}