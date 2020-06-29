@isTest
public class Batch_CommunicationNotifyBySMS_Test {

    public static String recordTypeNameEquToClient = 'Client';//PaymentProcessor.recordTypeNameEquToClient;
    public static String accountSObj =  Account.sObjectType.getDescribe().getName();//PaymentProcessor.accountObj.getName();
    
    static testMethod void testCommunicationNotifyBySMS() {
        
        User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        TwilioConfig__c twiloConfig = new TwilioConfig__c(AccountSid__c = 'ACc9666444c8cd2c77c12c44c401e89d62', AuthToken__c = 'a3e3f3b348addd6992a76b7f0d3a909a');
        insert twiloConfig;
                
        nu_dse__Communication_Notification_Settings__c communication = TestRecordCreator.createCommunicationNotificationSettings();
        insert communication;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToClient 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
                                                                    
        Account accStr = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        accStr.PersonEmail = 'a@test.com';
        insert accStr;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.nu_dse__Processor_Status__c = 'No Account';
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm.Home_Phone__c = '8547265395';
        prgm.Cell_Phone__c = '3652147852';
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
        Test.startTest();
            
            nu_dse__Payment__c payment = TestRecordCreator.createPayments(prgm.Id);
            payment.Attorney__c = true;
            insert payment;
            
            nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
            prospect.nu_dse__Home_Phone__c = '9867345623';
            prospect.Email_Address_2__c = 'a@test.com';
            insert prospect;
                   
            nu_dse__Communication_Template__c communicationTempProgram = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempProgram.nu_dse__SMS_Body__c = '{Home_Phone__c}';
            communicationTempProgram.nu_dse__From__c = '8596547852';
            insert communicationTempProgram;
            
            nu_dse__Communication_Template__c communicationTempPayment = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempPayment.nu_dse__SMS_Body__c = '{Attorney__c}';
            communicationTempPayment.nu_dse__From__c = '2365214578';
            insert communicationTempPayment;
            
            nu_dse__Communication_Template__c communicationTempProspect = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempProspect.nu_dse__SMS_Body__c = '{Email_Address_2__c}';
            communicationTempProspect.nu_dse__From__c = '8965125478';
            insert communicationTempProspect;
            
            List<Task> tasksList = new List<Task>();
            Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
            taskRec1.nu_dse__Communication_Template__c = communicationTempProgram.Id;
            tasksList.add(taskRec1);
            
            Task taskRec2 = TestRecordCreator.createTask(user1.Id, payment.Id);
            taskRec2.nu_dse__Communication_Template__c = communicationTempPayment.Id;
            tasksList.add(taskRec2);
            
            Task taskRec3 = TestRecordCreator.createTask(user1.Id, prospect.Id);
            taskRec3.nu_dse__Communication_Template__c = communicationTempProspect.Id;
            tasksList.add(taskRec3);
            
            insert tasksList;
            
            Database.executeBatch(new Batch_CommunicationNotificationBySMS(new Set<Id>{taskRec1.Id, taskRec2.Id, taskRec3.Id}));
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals('Completed', taskList[0].status);
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyBySMS1() {
        
        User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        nu_dse__Communication_Notification_Settings__c communication = TestRecordCreator.createCommunicationNotificationSettings();
        insert communication;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToClient 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
                                                                    
        Account accStr = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        accStr.PersonEmail = 'a@test.com';
        accStr.Phone = null;
        insert accStr;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Creditor');
                         
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = creditorRecordTypeId, nu_dse__CFT_Synced__c = TRUE);
        insert acct;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.nu_dse__Processor_Status__c = 'No Account';
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm.Home_Phone__c = '8547265395';
        prgm.Cell_Phone__c = '3652147852';
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
        Test.startTest();
            
            
            nu_dse__TradeLine__c trd = new nu_dse__TradeLine__c();
            trd.nu_dse__program__c = prgm.id;
            trd.nu_dse__Original_Debt__c = 2.0;
            trd.nu_dse__Original_Account_Number__c = '123654789658';
            trd.nu_dse__New_Account_Number__c = '987654321654';
            trd.nu_dse__Original_Creditor__c = acct.Id;
            trd.nu_dse__New_Creditor__c = acct.Id;//un-commented out on Mar-14-2019
            insert trd;
            
            nu_dse__offer__c offerInst = TestRecordCreator.createOffer(prgm.Id, trd.Id, 1, 1, 1, 1);
            insert offerInst;
            
            nu_dse__Payment__c payment = TestRecordCreator.createPayments(prgm.Id);
            payment.Attorney__c = true;
            insert payment;
            
            nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
            prospect.nu_dse__Cell_Phone__c = '9867345623';
            prospect.Email_Address_2__c = 'a@test.com';
            insert prospect; 
            
            nu_dse__Communication_Template__c communicationTempProgram = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempProgram.nu_dse__SMS_Body__c = '{Home_Phone__c}';
            communicationTempProgram.nu_dse__From__c = '8596547852';
            insert communicationTempProgram;
            
            nu_dse__Communication_Template__c communicationTempPayment = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempPayment.nu_dse__SMS_Body__c = '{Attorney__c}';
            communicationTempPayment.nu_dse__From__c = '2365214578';
            insert communicationTempPayment;
            
            nu_dse__Communication_Template__c communicationTempProspect = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempProspect.nu_dse__SMS_Body__c = '{Email_Address_2__c}';
            communicationTempProspect.nu_dse__From__c = '8965125478';
            insert communicationTempProspect;
            
            List<Task> tasksList = new List<Task>();
            Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
            taskRec1.nu_dse__Communication_Template__c = communicationTempProgram.Id;
            tasksList.add(taskRec1);
            
            Task taskRec2 = TestRecordCreator.createTask(user1.Id, payment.Id);
            taskRec2.nu_dse__Communication_Template__c = communicationTempPayment.Id;
            tasksList.add(taskRec2);
            
            Task taskRec3 = TestRecordCreator.createTask(user1.Id, prospect.Id);
            taskRec3.nu_dse__Communication_Template__c = communicationTempProspect.Id;
            tasksList.add(taskRec3);
            
            Task taskRec4 = TestRecordCreator.createTask(user1.Id, offerInst.Id);
            taskRec4.nu_dse__Communication_Template__c = communicationTempPayment.Id;
            taskRec4.nu_dse__Communication_Sent__c = false;
            tasksList.add(taskRec4);
            
            insert tasksList;
            
            Database.executeBatch(new Batch_CommunicationNotificationBySMS());
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals('Completed', taskList[0].status);
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyBySMS2() {
        
        User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        nu_dse__Communication_Notification_Settings__c communication = TestRecordCreator.createCommunicationNotificationSettings();
        communication.nu_dse__SMS_Daily_Limit__c = 2;
        insert communication;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToClient 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
                                                                    
        Account accStr = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr.PersonHomePhone = '7894561235';   
        accStr.PersonEmail = 'a@test.com';
        accStr.Phone = null;
        insert accStr;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.nu_dse__Processor_Status__c = 'No Account';
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm.Home_Phone__c = '8547265395';
        prgm.Cell_Phone__c = '3652147852';
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
        Test.startTest();
            
            nu_dse__Payment__c payment = TestRecordCreator.createPayments(prgm.Id);
            payment.Attorney__c = true;
            insert payment;
            
            nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
            prospect.nu_dse__Work_Phone__c = '9867345623';
            prospect.Email_Address_2__c = 'a@test.com';
            insert prospect;
            
            nu_dse__Communication_Template__c communicationTempProgram = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempProgram.nu_dse__SMS_Body__c = '{Home_Phone__c}';
            communicationTempProgram.nu_dse__From__c = '8596547852';
            insert communicationTempProgram;
            
            nu_dse__Communication_Template__c communicationTempPayment = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempPayment.nu_dse__SMS_Body__c = '{Attorney__c}';
            communicationTempPayment.nu_dse__From__c = '2365214578';
            insert communicationTempPayment;
            
            nu_dse__Communication_Template__c communicationTempProspect = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTempProspect.nu_dse__SMS_Body__c = '{Email_Address_2__c}';
            communicationTempProspect.nu_dse__From__c = '8965125478';
            insert communicationTempProspect;
            
            List<Task> tasksList = new List<Task>();
            Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
            taskRec1.nu_dse__Communication_Template__c = communicationTempProgram.Id;
            tasksList.add(taskRec1);
            
            Task taskRec2 = TestRecordCreator.createTask(user1.Id, payment.Id);
            taskRec2.nu_dse__Communication_Template__c = communicationTempPayment.Id;
            tasksList.add(taskRec2);
            
            Task taskRec3 = TestRecordCreator.createTask(user1.Id, prospect.Id);
            taskRec3.nu_dse__Communication_Template__c = communicationTempProspect.Id;
            tasksList.add(taskRec3);
            
            Task taskRec = TestRecordCreator.createTask(user1.Id, payment.Id);
            taskRec.nu_dse__Communication_Template__c = communicationTempPayment.Id;
            taskRec.nu_dse__Phone__c = '7854125896';
            tasksList.add(taskRec);
            
            insert tasksList;
            
            Database.executeBatch(new Batch_CommunicationNotificationBySMS());
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals('Completed', taskList[0].status);
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyBySMSOffer() {
        
        User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        nu_dse__Communication_Notification_Settings__c communication = TestRecordCreator.createCommunicationNotificationSettings();
        insert communication;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToClient 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Creditor');
                                                             
        Account accStr = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        accStr.PersonEmail = 'a@test.com';
        accStr.Phone = null;
        accStr.PersonHomePhone = '9845764876';
        insert accStr;
                     
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = creditorRecordTypeId, nu_dse__CFT_Synced__c = TRUE);
        insert acct;
        
        Test.startTest();
            
            nu_dse__Program__c prgm = TestRecordCreator.createProgram();
            prgm.nu_dse__Account__c = accStr.Id;
            prgm.nu_dse__Processor__c = processor.Id;
            prgm.nu_dse__Processor_Status__c = 'No Account';
            prgm.nu_dse__Program_Status__c = 'Active Client';
            insert prgm;
            
            nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeline(acct.Id, prgm.Id);
            insert tradeline;
            
            nu_dse__offer__c offerInst = TestRecordCreator.createOffer(prgm.Id, tradeline.Id, 1, 1, 1, 1);
            insert offerInst;
            
            nu_dse__Communication_Template__c communicationTemp = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTemp.nu_dse__SMS_Body__c = 'Test Message : {Name}';
            insert communicationTemp;
            
            List<Task> tasksList = new List<Task>();
            Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
            taskRec1.nu_dse__Communication_Template__c = communicationTemp.Id;
            tasksList.add(taskRec1);
            
            Task taskRec2 = TestRecordCreator.createTask(user1.Id, offerInst.Id);
            taskRec2.nu_dse__Communication_Template__c = communicationTemp.Id;
            tasksList.add(taskRec2);
            
            insert tasksList;
            
            Database.executeBatch(new Batch_CommunicationNotificationBySMS());
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals('Completed', taskList[0].status);
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyBySMSOfferSchedule() {
        
        User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        nu_dse__Communication_Notification_Settings__c communication = TestRecordCreator.createCommunicationNotificationSettings();
        insert communication;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :recordTypeNameEquToClient 
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
                                                                    
        Account accStr = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        accStr.PersonEmail = 'a@test.com';
        accStr.Phone = null;
        accStr.PersonHomePhone = '9845764876';
        insert accStr;
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Creditor');
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = creditorRecordTypeId, nu_dse__CFT_Synced__c = TRUE);
        insert acct;
        
        Test.startTest();
            
            nu_dse__Program__c prgm = TestRecordCreator.createProgram();
            prgm.nu_dse__Account__c = accStr.Id;
            prgm.nu_dse__Processor__c = processor.Id;
            prgm.nu_dse__Processor_Status__c = 'No Account';
            prgm.nu_dse__Program_Status__c = 'Active Client';
            insert prgm;
            
            nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeline(acct.Id, prgm.Id);
            insert tradeline;
            
            nu_dse__offer__c offerInst = TestRecordCreator.createOffer(prgm.Id, tradeline.Id, 1, 1, 1, 1);
            insert offerInst;
            
            nu_dse__Communication_Template__c communicationTemp = TestRecordCreator.createCommunicationTemplate('SMS');
            communicationTemp.nu_dse__SMS_Body__c = 'Test Message : {Name}';
            insert communicationTemp;
            
            List<Task> tasksList = new List<Task>();
            Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
            taskRec1.nu_dse__Communication_Template__c = communicationTemp.Id;
            tasksList.add(taskRec1);
            
            Task taskRec2 = TestRecordCreator.createTask(user1.Id, offerInst.Id);
            taskRec2.nu_dse__Communication_Template__c = communicationTemp.Id;
            tasksList.add(taskRec2);
            
            insert tasksList;
            
            Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new ScheduleCommunicationNotificationSMS());
            
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals('Completed', taskList[0].status);
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
}