@isTest
global class MakePaymentComponent_Test {
    
    @isTest static void tetsGetPayments() {
    
        Id clientRecTypeId;
        String message;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Account acc = new Account();
        acc.nu_dse__client_number__c = 111222;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        insert acc;
               
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program; 
        
        Map<String, RecordTypeInfo> recDraft = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName();
        Id recordType1;
        if(recDraft.containsKey('Draft')) {
            recordType1 = recDraft.get('Draft').recordTypeId;
        }
        System.debug('::recDraft:: '+recDraft);
        System.debug('::recDraft:: '+recordType1);
        List<nu_dse__Payment__c> recPayment1 = new List<nu_dse__Payment__c> {new nu_dse__Payment__c (
                                                                                nu_dse__Transaction_Status__c='Failed',
                                                                                RecordTypeId=recordType1,
                                                                                nu_dse__Payment_Type__c='Deposit',nu_dse__Dont_Consider__c=false,
                                                                                nu_dse__Program__c=program.Id, nu_dse__Schedule_Date__c=system.Today()),
                                                                             new nu_dse__Payment__c ( 
                                                                                 RecordTypeId=recordType1,
                                                                                 nu_dse__Payment_Type__c='Deposit',nu_dse__Dont_Consider__c=false,
                                                                                 nu_dse__Program__c=program.Id, nu_dse__Schedule_Date__c=system.Today())   
                                                                   };
        insert recPayment1;
        System.debug('::recPayment1:: '+recPayment1);
        Test.startTest();
            List<MakePaymentComponent.Payment> payment1 = MakePaymentComponent.getPayments(program.Id);
            MakePaymentComponent.makePayment(program.Id, recPayment1[1].Id);
        Test.stopTest();
        
        List<nu_dse__Payment__c> newPayment = [SELECT nu_dse__Dont_Consider__c FROM nu_dse__Payment__c WHERE  nu_dse__Transaction_Status__c='Pending'];
        System.debug('::newPayment::'+newPayment);
        System.assertEquals(newPayment[0].nu_dse__Dont_Consider__c, True);
        System.assertEquals(payment1[0].status, 'Failed');
        
    }
}