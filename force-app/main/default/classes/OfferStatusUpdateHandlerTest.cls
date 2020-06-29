@isTest
public class OfferStatusUpdateHandlerTest {

    @TestSetup
    public static void setup() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
         
        nu_dse__Data_Mapping__c dataMappingInst1 = TestRecordCreator.createDataMapping('nds_OfferSettlementStatusToOfferStatus', null, null);
        nu_dse__Data_Mapping__c dataMappingInst2 = TestRecordCreator.createDataMapping('nds_OfferSettlementStatusToTradelineCurrentStage', null, null);
        nu_dse__Data_Mapping__c dataMappingInst3 = TestRecordCreator.createDataMapping('nds_OfferSettlementStatusToTradelineSettlementStatus', null, null);
        nu_dse__Data_Mapping__c dataMappingInst4 = TestRecordCreator.createDataMapping('nds_OfferStatusToOfferSettlementStatus', null, null);
        nu_dse__Data_Mapping__c dataMappingInst5 = TestRecordCreator.createDataMapping('nds_OfferStatusToTradelineCurrentStage', null, null);
        nu_dse__Data_Mapping__c dataMappingInst6 = TestRecordCreator.createDataMapping('nds_OfferStatusToTradelineSettlementStatus', null, null);
         
        dataMappingList.add(dataMappingInst1);
        dataMappingList.add(dataMappingInst2);
        dataMappingList.add(dataMappingInst3);
        dataMappingList.add(dataMappingInst4);
        dataMappingList.add(dataMappingInst5);
        dataMappingList.add(dataMappingInst6);
         
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInst1 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'To Payment Processing', 'Payment Plan - Active');  
        nu_dse__Field_mapping__c fieldMappingInst2 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Negotiator Declined', 'Incomplete');  
        nu_dse__Field_mapping__c fieldMappingInst3 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Settled', 'Settled');  
        
        nu_dse__Field_mapping__c fieldMappingInst4 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'To Payment Processing', 'Payment Plan - Active: Temp PPA');
        nu_dse__Field_mapping__c fieldMappingInst5 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Negotiator Declined', 'Negotiator Declined');  
        nu_dse__Field_mapping__c fieldMappingInst6 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Settled', 'Settled');  
        
        nu_dse__Field_mapping__c fieldMappingInst7 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'To Payment Processing', 'Client Approved');
        nu_dse__Field_mapping__c fieldMappingInst8 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'Negotiator Declined', 'Offer Made');
        //nu_dse__Field_mapping__c fieldMappingInst9 = TestRecordCreator.createFieldMapping(dataMappingList[2].Id, 'Settled', 'Settled');  
        
        nu_dse__Field_mapping__c fieldMappingInst10 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'Accepted', 'To Payment Processing');  
        nu_dse__Field_mapping__c fieldMappingInst11 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'Incomplete', 'Negotiator Declined');  
        nu_dse__Field_mapping__c fieldMappingInst12 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'Close', 'Testing'); 
        nu_dse__Field_mapping__c fieldMappingInst13 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'Reserved', 'Incomplete'); 
        
        nu_dse__Field_mapping__c fieldMappingInst14 = TestRecordCreator.createFieldMapping(dataMappingList[4].Id, 'Accepted', 'Payment Plan - Active: Temp PPA');
        nu_dse__Field_mapping__c fieldMappingInst15 = TestRecordCreator.createFieldMapping(dataMappingList[4].Id, 'Cancelled', 'Cancelled');  
        //nu_dse__Field_mapping__c fieldMappingInst16 = TestRecordCreator.createFieldMapping(dataMappingList[4].Id, 'Payments Department Denied', 'Negotiator Declined');  
        nu_dse__Field_mapping__c fieldMappingInst17 = TestRecordCreator.createFieldMapping(dataMappingList[4].Id, 'Incomplete', 'Removed'); 
         
        nu_dse__Field_mapping__c fieldMappingInst18 = TestRecordCreator.createFieldMapping(dataMappingList[5].Id, 'Accepted', 'Management Approved'); 
        nu_dse__Field_mapping__c fieldMappingInst19 = TestRecordCreator.createFieldMapping(dataMappingList[5].Id, 'Offer Made', 'Settled');
        nu_dse__Field_mapping__c fieldMappingInst20 = TestRecordCreator.createFieldMapping(dataMappingList[5].Id, 'Incomplete', 'Client Late - Offer Expired');   
         
        nu_dse__Field_mapping__c fieldMappingInstWV1 = TestRecordCreator.createFieldMapping(dataMappingList[3].Id, 'Settled', '`WrongStatus'); 
        nu_dse__Field_mapping__c fieldMappingInstWV2 = TestRecordCreator.createFieldMapping(dataMappingList[4].Id, 'Payments Department Denied', '`WrongStatus'); 
        
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
        fieldMappingList.add(fieldMappingInst11);
        
        fieldMappingList.add(fieldMappingInst12);
        fieldMappingList.add(fieldMappingInst13);
        fieldMappingList.add(fieldMappingInst14);
        fieldMappingList.add(fieldMappingInst15);
        
        //fieldMappingList.add(fieldMappingInst16);
        fieldMappingList.add(fieldMappingInst17);
        fieldMappingList.add(fieldMappingInst18);
        fieldMappingList.add(fieldMappingInst19);
        fieldMappingList.add(fieldMappingInst20);
        
        fieldMappingList.add(fieldMappingInstWV1);
        fieldMappingList.add(fieldMappingInstWV2);
        
        insert fieldMappingList;    
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
         
        nu_dse__Program__c programInstance = new nu_dse__Program__c();
        programInstance.Attorney__c = TRUE;
        programInstance.Import_ID__c = '1231231231';
        //programInstance.First_Year_Workflow_Ran__c=true;
        programInstance.nu_dse__Program_Status__c='New File';
        programList.add(programInstance);
        
        Insert programList;
        
        List<nu_dse__Tradeline__c> tradeList = new List<nu_dse__Tradeline__c>();
        
        nu_dse__Tradeline__c tradeInstance = new nu_dse__Tradeline__c();
        tradeInstance.nu_dse__Current_Stage__c = 'Negotiator Declined';
        tradeInstance.Settlement_Status__c = 'Offer Made';
        tradeInstance.nu_dse__Original_Debt__c = 25000;
        tradeInstance.Attorney__c = TRUE;
        tradeInstance.nu_dse__Program__c =programInstance.Id;
        tradeList.add(tradeInstance);
        
        Insert tradeList;
        
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        nu_dse__Offer__c offerInstance1 = new nu_dse__Offer__c();
        offerInstance1.nu_dse__Status__c = 'Accepted';
        offerInstance1.Settlement_Status__c = 'To Payment Processing';
        //offerInstance1.Is_NDS__c = True;
        offerInstance1.nu_dse__Tradeline__c = tradeInstance.Id;
        offerList.add(offerInstance1);
        
        nu_dse__Offer__c offerInstance2 = new nu_dse__Offer__c();
        offerInstance2.nu_dse__Status__c = 'Accepted';
        offerInstance2.Settlement_Status__c = 'To Payment Processing';
        //offerInstance2.Is_NDS__c = True;
        offerInstance2.nu_dse__Tradeline__c = tradeInstance.Id;
        offerList.add(offerInstance2);
        
        nu_dse__Offer__c offerInstance5 = new nu_dse__Offer__c();
        offerInstance5.nu_dse__Status__c = 'Accepted';
        offerInstance5.Settlement_Status__c = 'To Payment Processing';
        //offerInstance5.Is_NDS__c = FALSE;
        offerInstance5.nu_dse__Tradeline__c = tradeInstance.Id;
        offerList.add(offerInstance5);
        
        Insert offerList;
   }
    
    @isTest
    static void updateOfferStatusTest_Insert1() {
    
         /*       
        List<nu_dse__Tradeline__c> tradeInstanceList = [SELECT id,nu_dse__Current_Stage__c, Settlement_Status__c, nu_dse__Original_Debt__c,
                                                        Attorney__c, nu_dse__Program__c FROM nu_dse__Tradeline__c];
        */
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c();
        programInstance.Attorney__c = TRUE;
        programInstance.Import_ID__c = '1231231213';
        
        insert programInstance;
        
        nu_dse__Tradeline__c tradeInstance = new nu_dse__Tradeline__c();
        tradeInstance.nu_dse__Current_Stage__c = 'Negotiator Declined';
        tradeInstance.Settlement_Status__c = 'Offer Made';
        tradeInstance.nu_dse__Original_Debt__c = 25000;
        tradeInstance.Attorney__c = TRUE;
        tradeInstance.nu_dse__Program__c =programInstance.Id;
        
        insert tradeInstance;
        List<nu_dse__Tradeline__c> tradeInstanceList = new List<nu_dse__Tradeline__c>();
        tradeInstanceList.add(tradeInstance);
        
        //to pass error
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        nu_dse__Offer__c offerInstance = new nu_dse__Offer__c();
        offerInstance.nu_dse__Status__c = 'Accepted';
        offerInstance.Settlement_Status__c = 'To Payment Processing';
        //offerInstance.Is_NDS__c = FALSE;
        offerInstance.nu_dse__Tradeline__c = tradeInstanceList[0].Id;
        offerList.add(offerInstance);
        
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert offerList;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Offer__c> offerList1 = [SELECT Id, nu_dse__Status__c, Settlement_Status__c, 
                                                 nu_dse__Tradeline__c 
                                                 FROM nu_dse__Offer__c
                                                 WHERE Id = :offerList[0].Id]; 
                                                 
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, nu_dse__Current_Stage__c, Settlement_Status__c
                                                        FROM nu_dse__Tradeline__c 
                                                        WHERE Id = :tradeInstanceList[0].Id];
        
        System.assertEquals(offerList1.isEmpty() , False);
        System.assertEquals('To Payment Processing' ,offerList1[0].Settlement_Status__c);
        System.assertEquals(tradelineList.isEmpty() , False);
        System.assertEquals('Payment Plan - Active' ,tradelineList[0].nu_dse__Current_Stage__c);
        System.assertEquals('Management Approved' ,tradelineList[0].Settlement_Status__c);
        
    }
    
    @isTest
    static void updateOfferStatusTest_Update1() {
        
        List<nu_dse__Offer__c> offerInstance3 = [SELECT Id, name, Payment_Terms__c, Source_of_Settlement__c, 
                                                    Source_of_Payment__c, nu_dse__Status__c, nu_dse__Tradeline__c, Settlement_Status__c 
                                                    FROM nu_dse__Offer__c];
        
        offerInstance3[0].nu_dse__Status__c = 'Incomplete';
        offerInstance3[0].Payment_Terms__c = 'Settlement';
        offerInstance3[0].Source_of_Payment__c = 'Client Direct';
        offerInstance3[0].Source_of_Settlement__c = 'Client Direct Offer';
        
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False,
                                  Attorney_Ignore_Validation__c = True);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            update offerInstance3;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Offer__c> offerList1 = [SELECT Id, nu_dse__Status__c, Settlement_Status__c, 
                                                 nu_dse__Tradeline__c 
                                                 FROM nu_dse__Offer__c
                                                 WHERE Id = :offerInstance3[0].Id]; 
                                                 
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, nu_dse__Current_Stage__c, Settlement_Status__c
                                                        FROM nu_dse__Tradeline__c 
                                                        WHERE Id = :offerInstance3[0].nu_dse__Tradeline__c];
        
        System.assertEquals(offerList1.isEmpty() , False);
        System.assertEquals('Negotiator Declined' ,offerList1[0].Settlement_Status__c);
        /*
        System.assertEquals(tradelineList.isEmpty() , False);
        System.assertEquals('Removed' ,tradelineList[0].nu_dse__Current_Stage__c);
        System.assertEquals('Client Late - Offer Expired' ,tradelineList[0].Settlement_Status__c);
        */
        
   }
    
    @isTest
    static void updateOfferStatusTest_Exception1() {
        
        /*
        List<nu_dse__Tradeline__c> tradeInstanceList = [SELECT id,nu_dse__Current_Stage__c, Settlement_Status__c, nu_dse__Original_Debt__c,
                                                        Attorney__c, nu_dse__Program__c FROM nu_dse__Tradeline__c];
        */
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c();
        programInstance.Attorney__c = TRUE;
        programInstance.Import_ID__c = '1231231213';
        
        insert programInstance;
        
        nu_dse__Tradeline__c tradeInstance = new nu_dse__Tradeline__c();
        tradeInstance.nu_dse__Current_Stage__c = 'Negotiator Declined';
        tradeInstance.Settlement_Status__c = 'Offer Made';
        tradeInstance.nu_dse__Original_Debt__c = 25000;
        tradeInstance.Attorney__c = TRUE;
        tradeInstance.nu_dse__Program__c =programInstance.Id;
        
        insert tradeInstance;
        
        List<nu_dse__Tradeline__c> tradeInstanceList = new List<nu_dse__Tradeline__c>();
        tradeInstanceList.add(tradeInstance);
        
        //to pass error
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        nu_dse__Offer__c offerInstance1 = new nu_dse__Offer__c();
        offerInstance1.nu_dse__Status__c = 'Settled';
        //offerInstance1.Is_NDS__c = FALSE;
        offerInstance1.nu_dse__Tradeline__c = tradeInstanceList[0].Id;
        offerList.add(offerInstance1);
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles',
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert offerList;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Stack_Trace__c, nu_dse__Message__c, nu_dse__Class_Method__c FROM nu_dse__Error_Log__c];
        
        System.assertEquals(errorLogList.isEmpty() , False);
        System.assertEquals(errorLogList[0].nu_dse__Class_Method__c , 'OfferStatusUpdateHandler-OfferDML');
        //System.assertEquals(errorLogList[0].nu_dse__Message__c , 'Settlement Status: bad value for restricted picklist field: `WrongStatus;');
        
    }
    
    /*
    @isTest
    static void updateOfferStatusTest_Insert2() {
    
        List<nu_dse__Tradeline__c> tradeInstanceList = [SELECT id,nu_dse__Current_Stage__c, Settlement_Status__c, nu_dse__Original_Debt__c,
                                                        Attorney__c, nu_dse__Program__c FROM nu_dse__Tradeline__c];
        
        //to pass error
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        nu_dse__Offer__c offerInstance = new nu_dse__Offer__c();
        offerInstance.nu_dse__Status__c = 'Accepted';
        offerInstance.Settlement_Status__c = 'To Payment Processing';
        //offerInstance.Is_NDS__c = FALSE;
        offerInstance.nu_dse__Tradeline__c = tradeInstanceList[0].Id;
        offerList.add(offerInstance);
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles',
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = TRUE);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert offerList;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Offer__c> offerList1 = [SELECT Id, nu_dse__Status__c, Settlement_Status__c, 
                                                 nu_dse__Tradeline__c 
                                                 FROM nu_dse__Offer__c
                                                 WHERE Id = :offerList[0].Id]; 
                                                 
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, nu_dse__Current_Stage__c, Settlement_Status__c
                                                        FROM nu_dse__Tradeline__c 
                                                        WHERE Id = :tradeInstanceList[0].Id];
        
        System.assertEquals(offerList1.isEmpty() , False);
        System.assertEquals('Payment Plan - Active' ,offerList1[0].nu_dse__Status__c);
        System.assertEquals(tradelineList.isEmpty() , False);
        System.assertEquals('Payment Plan - Active: Temp PPA' ,tradelineList[0].nu_dse__Current_Stage__c);
        System.assertEquals('Client Approved' ,tradelineList[0].Settlement_Status__c);
        
    }
    */
    
    
    @isTest
    static void updateOfferStatusTest_Exception2() {
        /*
        List<nu_dse__Tradeline__c> tradeInstanceList = [SELECT id,nu_dse__Current_Stage__c, Settlement_Status__c, nu_dse__Original_Debt__c,
                                                        Attorney__c, nu_dse__Program__c FROM nu_dse__Tradeline__c];
        */
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c();
        programInstance.Attorney__c = TRUE;
        programInstance.Import_ID__c = '1231231213';
        
        insert programInstance;
        
        nu_dse__Tradeline__c tradeInstance = new nu_dse__Tradeline__c();
        tradeInstance.nu_dse__Current_Stage__c = 'Negotiator Declined';
        tradeInstance.Settlement_Status__c = 'Offer Made';
        tradeInstance.nu_dse__Original_Debt__c = 25000;
        tradeInstance.Attorney__c = TRUE;
        tradeInstance.nu_dse__Program__c =programInstance.Id;
        
        insert tradeInstance;
        
        List<nu_dse__Tradeline__c> tradeInstanceList = new List<nu_dse__Tradeline__c>();
        tradeInstanceList.add(tradeInstance);
        
        //to pass error
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        nu_dse__Offer__c offerInstance1 = new nu_dse__Offer__c();
        //offerInstance1.Settlement_Status__c = 'Settled'; commented on sept 11...
        offerInstance1.nu_dse__Status__c = 'Payments Department Denied';
        //offerInstance1.Is_NDS__c = FALSE;
        offerInstance1.nu_dse__Tradeline__c = tradeInstanceList[0].Id;
        offerList.add(offerInstance1);
        
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles',
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert offerList;
        }
        
        Test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Stack_Trace__c, nu_dse__Message__c, nu_dse__Class_Method__c FROM nu_dse__Error_Log__c];
        
        System.assertEquals(errorLogList.isEmpty(), False);
        System.assertEquals(errorLogList[0].nu_dse__Class_Method__c , 'OfferStatusUpdateHandler-TradelineDML');
        System.assertEquals(errorLogList[0].nu_dse__Message__c , 'Current Stage: bad value for restricted picklist field: `WrongStatus;');
    
    }
    
}