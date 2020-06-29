@isTest
public class TaskTrigger_Test {

    @testsetup 
    public static void setupTestData() {
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Client');
                                                                    
        Account accStr = TestRecordCreator.createAccount(clientRecordTypeId );  
        accStr.PersonHomePhone = '7854123652';   
        accStr.Phone = null;
        accStr.PersonEmail = 'test@test.com';
        insert accStr;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.Portfolio__c = portfolio.Id;
        prgm.ClientEmail__c = 'test@test.com';
        insert prgm;
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Creditor');
                     
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = creditorRecordTypeId
                                   
                                  );
        insert acct;
        
        
    }
    
    @isTest
    static void testBatchExecution(){
                        
        Test.startTest();          
        
        List<StopTaskCreationInDisposition__mdt > deleteTask = new List<StopTaskCreationInDisposition__mdt >{
            new StopTaskCreationInDisposition__mdt (
                    //Last_disposition_value__c = 'Reactivate Client',
                    Task_Status_to_Delete__c = 'Completed',
                    Active__c = true
            )
        };
        CustomMetadataGenerator.queryStrResultMap.put('SELECT Id, Task_Status_to_Delete__c FROM StopTaskCreationInDisposition__mdt WHERE Active__c = True', JSON.serialize(deleteTask)); //Last_disposition_value__c,
         
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c limit 1];     
        
        Task taskInstance = TestRecordCreator.createTask(programList[0].Id);
        taskInstance.Subject = 'Reactivate Client';
        taskInstance.Status = 'Completed';
        insert taskInstance;
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id FROM Task];     
        //System.assertEquals(False, taskList.isEmpty());  
    }
    
    @isTest
    static void testStopDuplicateTaskCreation() {
        
        Test.startTest();          
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'TEST_CreidtorAcc' LIMIT 1];
        
        nu_dse__TradeLine__c trd = new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = programList[0].Id;
        trd.nu_dse__Original_Debt__c = 2.0;
        trd.nu_dse__Original_Account_Number__c = '123654789658';
        trd.nu_dse__New_Account_Number__c = '987654321654';
        trd.SFS_Current_Balance__c = 1;
       // trd.nu_dse__Original_Creditor__c = accList[0].Id;
       // trd.nu_dse__New_Creditor__c = accList[0].Id;//un-commented out on Mar-14-2019
        insert trd;
        
        nu_dse__offer__c offerInst1 = TestRecordCreator.createOffer(programList[0].Id, trd.Id, 1, 1, 1, 1);
        nu_dse__offer__c offerInst2 = TestRecordCreator.createOffer(programList[0].Id, trd.Id, 1, 1, 1, 1);
        
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c> ();
        offerList.add(offerInst1);
        offerList.add(offerInst2);
        
        insert offerList;  
        
        Task taskInstance = TestRecordCreator.createTask(offerList[0].Id);
        taskInstance.Subject = 'Obtain Creditor Auth';
        insert taskInstance;
        
        Task taskInstance1 = TestRecordCreator.createTask(offerList[0].Id);
        taskInstance1.Subject = 'Obtain Creditor Auth';
        
        Task taskInstance2 = TestRecordCreator.createTask(offerList[1].Id);
        taskInstance2.Subject = 'Obtain Creditor Auth123123';
        
        List<Task> taskInstanceList = new List<Task>();
        
        taskInstanceList.add(taskInstance1);
        taskInstanceList.add(taskInstance2);
        
        insert taskInstanceList;
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id FROM Task WHERE WhatId =: offerList[0].Id AND Subject = 'Obtain Creditor Auth'];     
        system.debug('taskList ---->'+taskList );
        System.assertEquals(1, taskList.size());  
    }
    
    @isTest
    static void test_sendClientSurveyEmail(){
    
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'TEST_CreidtorAcc' LIMIT 1];
        
        Task taskInstance = TestRecordCreator.createTask(programList[0].Id);
        taskInstance.Department__c = 'Negotiations';
        taskInstance.Supplemental__c = 'Sent Client Survey';
        taskInstance.IsNote__c = true;
        taskInstance.Program__c = null ;
        insert taskInstance;
        
        Task taskInstance1 = TestRecordCreator.createTask(programList[0].Id);
        taskInstance1.Department__c = 'Negotiations';
        taskInstance.IsNote__c = true;
        taskInstance.Program__c = null;
        insert taskInstance1;
        
        taskInstance1.Supplemental__c = 'Sent Client Survey';
        taskInstance.Program__c = null;
        taskInstance.IsNote__c = true;
        update taskInstance1;
    
    }
}