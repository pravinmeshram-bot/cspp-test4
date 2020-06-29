@isTest
public class TradelineStatusUpdateTrigger_Test {
    
    @TestSetup
    public static void testSetupData() {
        
        Id recordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
        Account accountInstance = TestRecordCreator.createAccount('lName', recordTypeId);
        insert accountInstance;
        
        nu_dse__Processor__c processorInstance = TestRecordCreator.createProcessor('Test Processor');
        insert processorInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, processorInstance.Id);
        programInstance.Attorney__c = True;
        programInstance.Import_ID__c = '1231231231';
        insert programInstance;
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Creditor');
        Account creditorAccount = TestRecordCreator.createCreditorAccount(creditorRecordTypeId);
        
        insert creditorAccount;
         
        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
         
        nu_dse__Data_Mapping__c dataMappingInst1 = TestRecordCreator.createDataMapping('nds_AccountStatusToLitDefStage', null, null);
        nu_dse__Data_Mapping__c dataMappingInst2 = TestRecordCreator.createDataMapping('nds_LitDefStageToAccountStatus', null, null);
         
        dataMappingList.add(dataMappingInst1);
        dataMappingList.add(dataMappingInst2);
        
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInst1 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Referred to Lit Defense LHDR', 'Referred_To_Core');  
        //nu_dse__Field_mapping__c fieldMappingInst2 = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Referred to Lit Defense CALF', 'Referred_To_Lit_Def');  
        
        nu_dse__Field_mapping__c fieldMappingInst3 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Referred_To_Lit_Def', 'Referred_To_Lit_Def');  
        nu_dse__Field_mapping__c fieldMappingInst4 = TestRecordCreator.createFieldMapping(dataMappingList[1].Id, 'Lit File Closed – Return to CORE', 'Lit File Closed – Return to CORE');
        
        nu_dse__Field_mapping__c fieldMappingInstWV = TestRecordCreator.createFieldMapping(dataMappingList[0].Id, 'Referred to Lit Defense CALF', '`WrongStatus'); 
        
        fieldMappingList.add(fieldMappingInst1);
        //fieldMappingList.add(fieldMappingInst2);
        fieldMappingList.add(fieldMappingInst3);
        fieldMappingList.add(fieldMappingInst4);
        
        fieldMappingList.add(fieldMappingInstWV);
        
        insert fieldMappingList;
        
        nu_dse__Tradeline__c tradelineInstance1 = TestRecordCreator.createTradeLine(creditorAccount.Id, programInstance.Id);
        //Added below line on 5th Sept 2019 due to validation error
        tradelineInstance1.Applicant_Type__c = 'Applicant';
        insert tradelineInstance1;
        
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Insert1() {
        
        //Is_NDS__c is False...
        nu_dse__Program__c programInstance = [SELECT Id, nu_dse__Account__c FROM nu_dse__Program__c LIMIT 1];
        
        Account creditorAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Creditor' LIMIT 1];
        
        nu_dse__Tradeline__c tradelineInstance1 = TestRecordCreator.createTradeLine(creditorAccount.Id, programInstance.Id);
        //Added below line on 5th Sept 2019 due to validation error
        tradelineInstance1.Applicant_Type__c = 'Applicant';
        tradelineInstance1.Account_Status__c = 'Referred to Lit Defense LHDR';
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        List<User> userList = new List<User>();
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = True);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert tradelineInstance1;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Lit_Def_Stage__c, Account_Status__c
                                                    FROM nu_dse__Tradeline__c 
                                                    WHERE Id = :tradelineInstance1.Id];
        System.assertEquals(tradelineList.isEmpty() , False); 
        System.assertEquals(tradelineList[0].Lit_Def_Stage__c , 'Referred_To_Core');                                             
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Insert2() {
        
        //Is_NDS__c is True...
        nu_dse__Program__c programInstance = [SELECT Id, nu_dse__Account__c FROM nu_dse__Program__c LIMIT 1];
        
        Account creditorAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Creditor' LIMIT 1];
        
        nu_dse__Tradeline__c tradelineInstance1 = TestRecordCreator.createTradeLine(creditorAccount.Id, programInstance.Id);
        tradelineInstance1.Lit_Def_Stage__c = 'Referred_To_Lit_Def';
        //Added below line on 5th Sept 2019 due to validation error
        tradelineInstance1.Applicant_Type__c = 'Applicant';
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser2@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert tradelineInstance1;
        }
        
        Test.stopTest();
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Lit_Def_Stage__c, Account_Status__c
                                                    FROM nu_dse__Tradeline__c 
                                                    WHERE Id = :tradelineInstance1.Id];
        System.assertEquals(tradelineList.isEmpty() , False);
        System.assertEquals(tradelineList[0].Account_Status__c , 'Referred_To_Lit_Def');  
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Update1() {
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Lit_Def_Stage__c, Account_Status__c
                                                    FROM nu_dse__Tradeline__c];
        tradelineList[0].Account_Status__c = 'Referred to Lit Defense LHDR';
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            update tradelineList;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Tradeline__c> tradelineList1 = [SELECT Id, Lit_Def_Stage__c, Account_Status__c
                                                    FROM nu_dse__Tradeline__c 
                                                    WHERE Id = :tradelineList[0].Id];
        System.assertEquals(tradelineList1.isEmpty() , False);
        System.assertEquals(tradelineList1[0].Lit_Def_Stage__c, 'Referred_To_Core');
    }
    
    @isTest
    public static void updateStatusForFieldsTest_Update2() {
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Lit_Def_Stage__c, Account_Status__c
                                                    FROM nu_dse__Tradeline__c];
        tradelineList[0].Lit_Def_Stage__c = 'Referred_To_Lit_Def';
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles',
                                  username='paymentStatusUpdateTrigger_Testuser@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            update tradelineList;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Tradeline__c> tradelineList1 = [SELECT Id, Lit_Def_Stage__c, Account_Status__c
                                                    FROM nu_dse__Tradeline__c 
                                                    WHERE Id = :tradelineList[0].Id];
        System.assertEquals(tradelineList1.isEmpty() , False);
        System.assertEquals(tradelineList1[0].Account_Status__c , 'Referred_To_Lit_Def');  
    }
    
    
    @isTest
    public static void updateStatusForFieldsTest_Exception() {
        
        //Is_NDS__c is False...
        nu_dse__Program__c programInstance = [SELECT Id, nu_dse__Account__c FROM nu_dse__Program__c LIMIT 1];
        
        Account creditorAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Creditor' LIMIT 1];
        
        nu_dse__Tradeline__c tradelineInstance1 = TestRecordCreator.createTradeLine(creditorAccount.Id, programInstance.Id);
        tradelineInstance1.Account_Status__c = 'Referred to Lit Defense CALF';
        //Added below line on 5th Sept 2019 due to validation error
        tradelineInstance1.Applicant_Type__c = 'Applicant';
        List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        List<User> userList = new List<User>();
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='paymentStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = True);
        
        insert nonAttorneyUser;
        
        Test.startTest();
        
        system.runas(nonAttorneyUser) {
            
            insert tradelineInstance1;
        } 
        
        Test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, nu_dse__Message__c, nu_dse__Class_Method__c FROM nu_dse__Error_Log__c where nu_dse__Class_Method__c='tradelineStatusUpdateHandler.updateTradelineStatus'];
        
        System.assertEquals(errorLogList.isEmpty() , False);
        System.assertEquals(errorLogList[0].nu_dse__Class_Method__c , 'tradelineStatusUpdateHandler.updateTradelineStatus');
        System.assertEquals(errorLogList[0].nu_dse__Message__c , 'Lit Def Stage: bad value for restricted picklist field: `WrongStatus;');
    }
    
}