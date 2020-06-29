@isTest
public class CreateCreditorProcessorBatches_Test {
    
    public static String recordTypeNameEquToCreditor = 'Creditor';
    public static String accountSObj = Account.sObjectType.getDescribe().getName();
    
    @isTest 
    static void creditorProcessorInfoBatch_Test() {
        
        List<nu_dse__Processor__c> processorList = new List<nu_dse__Processor__c>();
        nu_dse__Processor__c cftProcessor = createProcessor();
        nu_dse__Processor__c gcsProcessor = createGCSProcessor();
        nu_dse__processor__c ramsProcessor = createRAMSProcessor();
        
        processorList.add(cftProcessor);
        processorList.add(gcsProcessor);
        processorList.add(ramsProcessor);
        
        insert processorList;
        
        //Quering Creditor RecordType From Account
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToCreditor 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        
        List<Account> accountList = new List<Account>();
        Account accStr1;
        Account accStr2;
        
        if (recordTypeList.isEmpty() == False) {
            
            accStr1 = createCreditorAccount(recordTypeList[0].Id);
            accStr1.nu_dse__CFT_Payee_Id__c = '123666';
            accStr1.nu_dse__CFT_Payee_Address_Id__c = '666666';
            accStr1.nu_dse__GCS_Payee_Id__c = '999999';
            accStr1.nu_dse__GCS_Payee_Address_Id__c = '888888';
            accStr1.nu_dse__RAMS_Payee_Id__c = '777777';
            accStr1.nu_dse__RAMS_Payee_Address_Id__c = '321456';
            
            accStr2 = createCreditorAccount(recordTypeList[0].Id);
            accStr2.nu_dse__CFT_Payee_Id__c = '123456';
            accStr2.nu_dse__CFT_Payee_Address_Id__c = '123456';
            accStr2.nu_dse__GCS_Payee_Id__c = '123456';
            accStr2.nu_dse__GCS_Payee_Address_Id__c = '123456';
            accStr2.nu_dse__RAMS_Payee_Id__c = '123456';
            accStr2.nu_dse__RAMS_Payee_Address_Id__c = '123456';
            
            accountList.add(accStr1);
            accountList.add(accStr2);
            
            insert accountList;
        }
        
        List<nu_dse__Creditor_Processor_Info__c> creditorProcessorList = [SELECT Id From nu_dse__Creditor_Processor_Info__c WHERE nu_dse__Account__c = :accStr1.Id];
        delete creditorProcessorList;
        
        //Insert Bank Account
        nu_dse__Bank_Account__c bankAccount = createBankAccount(accStr1.Id, 'SAVING');
        insert bankAccount;
        
        Contact contactInstance = createContact(accStr1.Id);
        insert contactInstance;
        
        Test.startTest();
        
        Batch_CreateCreditorProcessorInfo instance = new Batch_CreateCreditorProcessorInfo(new Set<Id> {cftProcessor.Id, gcsProcessor.Id, ramsProcessor.Id});
        Database.executeBatch(instance, 2);
        
        Test.stopTest();
        
        List<nu_dse__Creditor_Processor_Info__c> creditorProcessorList1 = [SELECT Id, nu_dse__Payee_Id__c, nu_dse__Payee_Address_Id__c From nu_dse__Creditor_Processor_Info__c 
                                                                            WHERE nu_dse__Account__c = :accStr1.Id 
                                                                            AND nu_dse__Processor__c = :cftProcessor.Id];
        System.assertEquals(True, creditorProcessorList1.isEmpty() == False);
        System.assertEquals('123666', creditorProcessorList1[0].nu_dse__Payee_Id__c);
        System.assertEquals('666666', creditorProcessorList1[0].nu_dse__Payee_Address_Id__c);
    }
    
    @isTest 
    static void creditorProcessorBankAccountBatch_Test() {
        
        List<nu_dse__Processor__c> processorList = new List<nu_dse__Processor__c>();
        nu_dse__Processor__c cftProcessor = createProcessor();
        nu_dse__Processor__c gcsProcessor = createGCSProcessor();
        nu_dse__processor__c ramsProcessor = createRAMSProcessor();
        
        processorList.add(cftProcessor);
        processorList.add(gcsProcessor);
        processorList.add(ramsProcessor);
        
        insert processorList;
        
        //Quering Creditor RecordType From Account
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToCreditor 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        
        Account accStr;
        
        if (recordTypeList.isEmpty() == False) {
            
            accStr  = createCreditorAccount(recordTypeList[0].Id);
            insert accStr;
        }
        
        //Insert Bank Account
        nu_dse__Bank_Account__c bankAccount = createBankAccount(accStr.Id, 'SAVING');
        bankAccount.nu_dse__CFT_Payee_Bank_Account_Id__c = '123456';
        bankAccount.nu_dse__GCS_Payee_Bank_Account_Id__c = '123654';
        bankAccount.nu_dse__RAMS_Payee_Bank_Account_Id__c = '321654';
        insert bankAccount;
        
        Contact contactInstance = createContact(accStr.Id);
        insert contactInstance;
        
        Test.startTest();
        
        Batch_CreateCreditorProcessorBankAccount instance = new Batch_CreateCreditorProcessorBankAccount(new Set<Id> {cftProcessor.Id, gcsProcessor.Id, ramsProcessor.Id});
        Database.executeBatch(instance, 1);
        
        Test.stopTest();
        
        List<nu_dse__Creditor_Processor_Info__c> creditorProcessorList = [SELECT Id, nu_dse__Payee_Bank_Account_Id__c From nu_dse__Creditor_Processor_Info__c 
                                                                            WHERE nu_dse__Account__c = :accStr.Id 
                                                                            AND nu_dse__Processor__c = :cftProcessor.Id];
        System.assertEquals(True, creditorProcessorList.isEmpty() == False);
        System.assertEquals('123456', creditorProcessorList[0].nu_dse__Payee_Bank_Account_Id__c);
    }
    
    @isTest 
    static void creditorProcessorContactBatch_Test() {
        
        List<nu_dse__Processor__c> processorList = new List<nu_dse__Processor__c>();
        nu_dse__Processor__c cftProcessor = createProcessor();
        nu_dse__Processor__c gcsProcessor = createGCSProcessor();
        nu_dse__processor__c ramsProcessor = createRAMSProcessor();
        
        processorList.add(cftProcessor);
        processorList.add(gcsProcessor);
        processorList.add(ramsProcessor);
        
        insert processorList;
        
        //Quering Creditor RecordType From Account
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToCreditor 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        
        Account accStr;
        
        if (recordTypeList.isEmpty() == False) {
            
            accStr  = createCreditorAccount(recordTypeList[0].Id);
            insert accStr;
        }
        
        //Insert Bank Account
        nu_dse__Bank_Account__c bankAccount = createBankAccount(accStr.Id, 'SAVING');
        insert bankAccount;
        
        Contact contactInstance = createContact(accStr.Id);
        contactInstance.nu_dse__CFT_Payee_Contact_Id__c = '645879';
        contactInstance.nu_dse__GCS_Payee_Contact_Id__c = '123454';
        contactInstance.nu_dse__RAMS_Payee_Contact_Id__c = '321644';
        insert contactInstance;
        
        Test.startTest();
        
        Batch_CreateCreditorProcessorContact instance = new Batch_CreateCreditorProcessorContact(new Set<Id> {cftProcessor.Id, gcsProcessor.Id, ramsProcessor.Id});
        Database.executeBatch(instance, 1);
        
        Test.stopTest();
        
        List<nu_dse__Creditor_Processor_Info__c> creditorProcessorList = [SELECT Id, nu_dse__Payee_Contact_Id__c From nu_dse__Creditor_Processor_Info__c 
                                                                            WHERE nu_dse__Account__c = :accStr.Id 
                                                                            AND nu_dse__Processor__c = :cftProcessor.Id];
        System.assertEquals(True, creditorProcessorList.isEmpty() == False);
        System.assertEquals('645879', creditorProcessorList[0].nu_dse__Payee_Contact_Id__c);
    }
    
    public static Account createCreditorAccount(Id recTypId) {
    
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403', BillingCountry = 'US',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = recTypId);
        return acct;
    }
    
    public static Contact createContact(Id AccId) {
    
        Contact con = new Contact(LastName = 'Test', Department ='TestDept', Title ='Title', Phone = '9874564447',
                                  MobilePhone = '9874564447', OtherPhone = '9625345652', Fax ='12345671', 
                                  HomePhone = '7589428542', Email = 'Test@SF.com', AccountId = AccId);      
        return con;
    }
    
    public static nu_dse__Bank_Account__c createBankAccount(Id AccId, String AccountType){
        
        nu_dse__Bank_Account__c BnkAcc = New nu_dse__Bank_Account__c(nu_dse__Account__c = AccId, nu_dse__Bank_Name__c = 'Test Bank', nu_dse__Account_Type__c = AccountType, nu_dse__Bank_Account_Number__c = '1245225', nu_dse__Routing_Number__c = '41414141',
                                                                    nu_dse__Holder_s_Name__c = 'TestHolderName');
        return BnkAcc;
    }
    
    public static nu_dse__Processor__c createProcessor(){
        
        nu_dse__Processor__c NewProcessor = New nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True, nu_dse__Type__c = 'CFT', 
                                                                         nu_dse__Username__c = 'cftTest.com', nu_dse__Password__c = 'test',
                                                                         nu_dse__Endpoint__c = 'https://test.com:8433/wsrv/services',
                                                                         nu_dse__Subscriber_Id__c = '123123', nu_dse__Client_Account_Last_Synced_Date_Time__c = system.now(), nu_dse__TradeLine_Last_Synced_Date_Time__c = system.now(),
                                                                         nu_dse__Subscriber_Fee_Id__c = '20123', nu_dse__Bank_Account_Last_Synced_Date_Time__c = system.now());
        return NewProcessor;
    }
    
    public static nu_dse__Processor__c createGCSProcessor() {
        
        nu_dse__Processor__c NewProcessor = New nu_dse__Processor__c(Name = 'GCS', nu_dse__Type__c = 'GCS', 
                                                                         nu_dse__Username__c = 'gcsTest.com', nu_dse__Password__c = 'test',
                                                                         nu_dse__Endpoint__c = 'https://websvctest.globalclientsolutions.com/v3.0/webservices.asmx',
                                                                         nu_dse__Company_Id__c = '9147654098002123');
        return NewProcessor;
    }
    
    public static nu_dse__Processor__c createRAMSProcessor() {
        
        nu_dse__Processor__c NewProcessor = New nu_dse__Processor__c(Name = 'RAMS', nu_dse__Type__c = 'RAMS',
                                                                         nu_dse__Client_Key__c = '4CC47D9E-94FC-4F21-B9E3-C0C45D4A368E',
                                                                         nu_dse__Affiliate_Id__c = '311654',
                                                                         nu_dse__Fee_Split_Group_Id__c = '147',
                                                                         nu_dse__Endpoint__c = 'https://test.com:8433/wsrv/services' );
        return NewProcessor;
    }
}