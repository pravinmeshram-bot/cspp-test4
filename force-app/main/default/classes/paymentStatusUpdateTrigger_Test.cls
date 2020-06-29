@isTest
public class paymentStatusUpdateTrigger_Test {
    
    @TestSetup
    public static void testSetupData() {
        
        List<PaymentStatusMapping__c> psmList = new List<PaymentStatusMapping__c>();
        
        PaymentStatusMapping__c psm = new PaymentStatusMapping__c();
        psm.Type__c = 'nds_PaymentStatusToTransactionStatus';
        psm.Source_Field__c = 'Canceled';
        psm.Target_Field__c = 'Cancelled';
        psm.Name = '1';
        psmList.add(psm);
        
        PaymentStatusMapping__c psm4 = new PaymentStatusMapping__c();
        psm4.Type__c = 'nds_TransactionStatusToPaymentStatus';
        psm4.Source_Field__c = 'Cancelled';
        psm4.Target_Field__c = 'Canceled';
        psm4.Name = '5';
        psmList.add(psm4);
        
        PaymentStatusMapping__c psm1 = new PaymentStatusMapping__c();
        psm1.Type__c = 'nds_TransactionStatusToPaymentStatus';
        psm1.Source_Field__c = 'Failed';
        psm1.Target_Field__c = 'NSF';
        psm1.Name = '2';
        psmList.add(psm1);
        
        PaymentStatusMapping__c psm2 = new PaymentStatusMapping__c();
        psm2.Type__c = 'nds_TransactionMethodToPaymentType';
        psm2.Source_Field__c = 'DRAFT';
        psm2.Target_Field__c = 'Other';
        psm2.Name = '3';
        psmList.add(psm2);
        
        PaymentStatusMapping__c psm3 = new PaymentStatusMapping__c();
        psm3.Type__c = 'nds_PaymentTypeToTransactionMethod';
        psm3.Source_Field__c = 'ManualCheck';
        psm3.Target_Field__c = 'DRAFT';
        psm3.Name = '4';
        psmList.add(psm3);
        
        PaymentStatusMapping__c psm5 = new PaymentStatusMapping__c();
        psm5.Type__c = 'nds_PaymentTypeToTransactionMethod';
        psm5.Source_Field__c = 'ACH';
        psm5.Target_Field__c = 'P_ACH';
        psm5.Name = '6';
        psmList.add(psm5);
        
        insert psmList;
        
        Id recordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
        Account accountInstance = TestRecordCreator.createAccount('lName', recordTypeId);
        insert accountInstance;
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createProcessor('Test Processor');
        insert processorInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, processorInstance.Id);
        programInstance.Attorney__c = True;
        programInstance.Import_ID__c = '1231231231';
        programInstance.Draft_Plan_ID__c = '3216549870';
        insert programInstance;
         
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
         
        nu_dse__Data_Mapping__c dataMappingInst1 = TestRecordCreator.createDataMapping('nds_TransactionStatusToPaymentStatus', null, null);
        nu_dse__Data_Mapping__c dataMappingInst2 = TestRecordCreator.createDataMapping('nds_PaymentStatusToTransactionStatus', null, null);
        nu_dse__Data_Mapping__c dataMappingInst3 = TestRecordCreator.createDataMapping('nds_TransactionMethodToPaymentType', null, null);
        nu_dse__Data_Mapping__c dataMappingInst4 = TestRecordCreator.createDataMapping('nds_PaymentTypeToTransactionMethod', null, null);
         
        dataMappingList.add(dataMappingInst1);
        dataMappingList.add(dataMappingInst2);
        dataMappingList.add(dataMappingInst3);
        dataMappingList.add(dataMappingInst4);
         
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInst1 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Cancelled', 'Canceled');  
        nu_dse__Field_mapping__c fieldMappingInst2 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Completed', 'Cleared');  
        nu_dse__Field_mapping__c fieldMappingInst3 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Failed', 'NSF');  
        nu_dse__Field_mapping__c fieldMappingInst4 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'In Progress', 'Processing');
        
        nu_dse__Field_mapping__c fieldMappingInst5 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Canceled', 'Cancelled');  
        nu_dse__Field_mapping__c fieldMappingInst6 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Cleared', 'Cleared');  
        nu_dse__Field_mapping__c fieldMappingInst7 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'NSF', 'Failed');
        nu_dse__Field_mapping__c fieldMappingInst8 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Processing', 'In Progress');
        
        //nu_dse__Field_mapping__c fieldMappingInst9 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'DRAFT_BY_CHECK', 'Phone');  
        nu_dse__Field_mapping__c fieldMappingInst10 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'DRAFT', 'Other');  
        //nu_dse__Field_mapping__c fieldMappingInst11 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'PHONE', 'Phone');  
        nu_dse__Field_mapping__c fieldMappingInst12 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'CHECK_STD', 'ManualCheck');
         
        nu_dse__Field_mapping__c fieldMappingInst13 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'ACH', 'P_ACH');  
        nu_dse__Field_mapping__c fieldMappingInst14 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'SecondDayCheck', 'DRAFT_BY_CHECK');  
        nu_dse__Field_mapping__c fieldMappingInst15 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'ManualCheck', 'DRAFT');  
       // nu_dse__Field_mapping__c fieldMappingInst16 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'Phone', 'PHONE');    
        
        nu_dse__Field_mapping__c fieldMappingInstWV = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Scheduled', '`WrongStatus'); 
        
        fieldMappingList.add(fieldMappingInst1);
        fieldMappingList.add(fieldMappingInst2);
        fieldMappingList.add(fieldMappingInst3);
        fieldMappingList.add(fieldMappingInst4);
        
        fieldMappingList.add(fieldMappingInst5);
        fieldMappingList.add(fieldMappingInst6);
        fieldMappingList.add(fieldMappingInst7);
        fieldMappingList.add(fieldMappingInst8);
        
        //fieldMappingList.add(fieldMappingInst9);
        fieldMappingList.add(fieldMappingInst10);
        //fieldMappingList.add(fieldMappingInst11);
        fieldMappingList.add(fieldMappingInst12);
        
        fieldMappingList.add(fieldMappingInst13);
        fieldMappingList.add(fieldMappingInst14);
        fieldMappingList.add(fieldMappingInst15);
        //fieldMappingList.add(fieldMappingInst16);
        fieldMappingList.add(fieldMappingInstWV);
        
        insert fieldMappingList;
        
        Id paymentRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstance.Id, 'In Progress', 'Deposit', paymentRecordTypeId, null);
        paymentInstance1.nu_dse__Transaction_Method__c = 'DRAFT';
        paymentInstance1.Payment_Status__c = 'Canceled';
        paymentInstance1.NDS_Payment_Type__c = 'ACH';
        
        nu_dse__Payment__c paymentInstance2 = TestRecordCreator.createPayment(programInstance.Id, 'Cancelled', 'Deposit', paymentRecordTypeId, null);
        paymentInstance2.Payment_Status__c = 'Processing';
        paymentInstance2.NDS_Payment_Type__c = 'ManualCheck';
        
        paymentList.add(paymentInstance1);
        paymentList.add(paymentInstance2);
        
        insert paymentList;
        
        LeadTracCredentials__c leadTracInst = new LeadTracCredentials__c();
        leadTracInst.Name = 'LeadTrackCredentials';
        leadTracInst.EndpointURL__c = 'http://sandbox.testEndUrl';
        
        insert leadTracInst;
        
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Insert1() {
        
        //Is_NDS__c is False...
        nu_dse__Program__c programInstance = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Id paymentRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstance.Id, 'In Progress', 'Deposit', paymentRecordTypeId, null);
        paymentInstance1.nu_dse__Transaction_Method__c = 'DRAFT';
        paymentInstance1.Payment_Status__c = 'Canceled';
        paymentInstance1.NDS_Payment_Type__c = 'ACH';
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles',
                                  username='paymentStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert paymentInstance1;
        } 
        
        Test.stopTest();
        
        System.debug('*paymentList-->'+paymentList);
        
        List<nu_dse__Payment__c> paymentList1 = [SELECT Id, Payment_Status__c, NDS_Payment_Type__c, 
                                                nu_dse__Transaction_Status__c, 
                                                nu_dse__Transaction_Method__c 
                                                FROM nu_dse__Payment__c
                                                WHERE Id = : paymentInstance1.Id];
        
        //System.assertEquals(paymentList1[0].Payment_Status__c,'Processing');
        //System.assertEquals(paymentList1[0].NDS_Payment_Type__c,'Other');
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Insert2() {
        
        //Is_NDS__c is True...
        nu_dse__Program__c programInstance = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Id paymentRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstance.Id, 'Cancelled', 'Deposit', paymentRecordTypeId, null);
        paymentInstance1.Payment_Status__c = 'Processing';
        paymentInstance1.NDS_Payment_Type__c = 'ManualCheck';
        paymentInstance1.nu_dse__Transaction_Method__c = 'DRAFT_BY_CHECK';
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser2@testorg.com', Attorney_Admin__c = True);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert paymentInstance1;
        }
        
        Test.stopTest();
        
        System.debug('*paymentList-->'+paymentList);
        
        List<nu_dse__Payment__c> paymentList1 = [SELECT Id, Payment_Status__c, NDS_Payment_Type__c, 
                                                nu_dse__Transaction_Status__c,
                                                nu_dse__Transaction_Method__c 
                                                FROM nu_dse__Payment__c
                                                WHERE Id = : paymentInstance1.Id];
        
        //System.assertEquals(paymentList1[0].nu_dse__Transaction_Status__c,'In Progress');
        //System.assertEquals(paymentList1[0].nu_dse__Transaction_Method__c,'DRAFT');
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Update() {
        
        List<nu_dse__Payment__c> paymentList = [SELECT Id, nu_dse__Transaction_Status__c, nu_dse__Transaction_Method__c, 
                                                Payment_Status__c, NDS_Payment_Type__c
                                                FROM nu_dse__Payment__c LIMIT 2];
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            System.debug('Entered:-->'+paymentList);
            
            paymentList[0].nu_dse__Transaction_Status__c = 'Failed';
            paymentList[0].nu_dse__Transaction_Method__c = 'DRAFT';
            
            paymentList[1].Payment_Status__c = 'Cleared';
            paymentList[1].NDS_Payment_Type__c = 'ACH';
            
            Test.setMock(WebServiceMock.Class, new LeadTraceNetClientMock());
            update paymentList;
        } 
        
        Test.stopTest();
        
        List<Id> paymentIdList = new List<Id>();
        paymentIdList.add(paymentList[0].Id);
        paymentIdList.add(paymentList[1].Id);
        
        List<nu_dse__Payment__c> paymentList1 = [SELECT Id, Payment_Status__c, NDS_Payment_Type__c, 
                                                nu_dse__Transaction_Status__c, 
                                                nu_dse__Transaction_Method__c 
                                                FROM nu_dse__Payment__c
                                                WHERE Id IN :paymentIdList ORDER BY LastModifiedDate Asc];
        
        
        //System.assertEquals(paymentList1[0].Payment_Status__c, 'NSF');
        //System.assertEquals(paymentList1[0].NDS_Payment_Type__c, 'Other');
        
        //System.assertEquals(paymentList1[1].nu_dse__Transaction_Status__c,'Cleared');
        //System.assertEquals(paymentList1[1].nu_dse__Transaction_Method__c,'P_ACH');
        
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Exception() {
        
        //Is_NDS__c is False...
        nu_dse__Program__c programInstance = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        
        Id paymentRecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Draft');
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c paymentInstance1 = TestRecordCreator.createPayment(programInstance.Id, 'Scheduled', 'Deposit', paymentRecordTypeId, null);
        paymentInstance1.nu_dse__Transaction_Method__c = 'PHONE';
        paymentInstance1.Payment_Status__c = 'Canceled';
        paymentInstance1.NDS_Payment_Type__c = 'ACH';
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert paymentInstance1;
        } 
        
        Test.stopTest();
        
        System.debug('*paymentList-->'+paymentList);
        
        List<nu_dse__Payment__c> paymentList1 = [SELECT Id, Payment_Status__c, NDS_Payment_Type__c, 
                                                nu_dse__Transaction_Status__c, 
                                                nu_dse__Transaction_Method__c 
                                                FROM nu_dse__Payment__c
                                                WHERE Id = : paymentInstance1.Id];
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Message__c, nu_dse__Class_Method__c FROM nu_dse__Error_Log__c];
        
        //System.assertEquals(errorLogList.isEmpty() , False);
        //System.assertEquals(errorLogList[0].nu_dse__Class_Method__c , 'PaymentStatusUpdateHandler-PaymentDML');
        //System.assertEquals(errorLogList[0].nu_dse__Message__c , 'Payment Status: bad value for restricted picklist field: `WrongStatus;');
       
    }
    
    public without sharing class LeadTraceNetClientMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            
            leadtracNetClient.CreateOrUpdateClientResponse_element respElement =new leadtracNetClient.CreateOrUpdateClientResponse_element();
            respElement.CreateOrUpdateClientResult = 'TestResult';
            response.put('response_x', respElement);
            
        }
    }     
}