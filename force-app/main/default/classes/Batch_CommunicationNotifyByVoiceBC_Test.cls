@isTest
public class Batch_CommunicationNotifyByVoiceBC_Test {

    public static String recordTypeNameEquToClient = 'Client';//PaymentProcessor.recordTypeNameEquToClient;
    public static String accountSObj = Account.sObjectType.getDescribe().getName();//PaymentProcessor.accountObj.getName();
    
    static testMethod void testCommunicationNotifyByVoiceBC() {
        
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
        communication.nu_dse__Voice_BC_Daily_Limit__c = 2; 
        communication.nu_dse__Voice_BC_Hourly_Limit__c =2;
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
        prgm.Home_Phone__c = '8547265395';
        prgm.Cell_Phone__c = '3652147852';
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
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
        communicationTempProgram.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProgram.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempProgram;
        
        nu_dse__Communication_Template__c communicationTempPayment = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempPayment.nu_dse__SMS_Body__c = '{Attorney__c}';
        communicationTempPayment.nu_dse__From__c = '2365214578';
        communicationTempPayment.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempPayment.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempPayment;
        
        nu_dse__Communication_Template__c communicationTempProspect = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempProspect.nu_dse__SMS_Body__c = '{Email_Address_2__c}';
        communicationTempProspect.nu_dse__From__c = '8965125478';
        communicationTempProspect.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProspect.nu_dse__TwiML__c = 'www.google.com';
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
        
        Test.startTest();
            
            Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new ScheduleCommunicationNotificationVoiceBC());
            Database.executeBatch(new Batch_CommunicationNotificationByVoiceBC(new Set<ID>{taskRec1.Id, taskRec2.Id, taskRec3.Id}));
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals(taskList[0].status, 'Completed');
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyByVoiceBC1() {
        
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
        communication.nu_dse__Voice_BC_Daily_Limit__c = 2; 
        communication.nu_dse__Voice_BC_Hourly_Limit__c =2;
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
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.nu_dse__Processor_Status__c = 'No Account';
        prgm.Home_Phone__c = '8547265395';
        prgm.Cell_Phone__c = '3652147852';
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Creditor');
                     
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = creditorRecordTypeId, nu_dse__CFT_Synced__c = TRUE);
        insert acct;
        
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
        communicationTempProgram.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProgram.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempProgram;
        
        nu_dse__Communication_Template__c communicationTempPayment = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempPayment.nu_dse__SMS_Body__c = '{Attorney__c}';
        communicationTempPayment.nu_dse__From__c = '2365214578';
        communicationTempPayment.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempPayment.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempPayment;
        
        nu_dse__Communication_Template__c communicationTempProspect = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempProspect.nu_dse__SMS_Body__c = '{Email_Address_2__c}';
        communicationTempProspect.nu_dse__From__c = '8965125478';
        communicationTempProspect.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProspect.nu_dse__TwiML__c = 'www.google.com';
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
        
        Test.startTest();
            
            Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new ScheduleCommunicationNotificationVoiceBC());
            Database.executeBatch(new Batch_CommunicationNotificationByVoiceBC());
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals(taskList[0].status, 'Completed');
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyByVoiceBC2() {
        
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
        communication.nu_dse__Voice_BC_Daily_Limit__c = 2; 
        communication.nu_dse__Voice_BC_Hourly_Limit__c =2;
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
        prgm.Home_Phone__c = '8547265395';
        prgm.Cell_Phone__c = '3652147852';
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
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
        communicationTempProgram.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProgram.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempProgram;
        
        nu_dse__Communication_Template__c communicationTempPayment = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempPayment.nu_dse__SMS_Body__c = '{Attorney__c}';
        communicationTempPayment.nu_dse__From__c = '2365214578';
        communicationTempPayment.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempPayment.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempPayment;
        
        nu_dse__Communication_Template__c communicationTempProspect = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempProspect.nu_dse__SMS_Body__c = '{Email_Address_2__c}';
        communicationTempProspect.nu_dse__From__c = '8965125478';
        communicationTempProspect.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProspect.nu_dse__TwiML__c = 'www.google.com';
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
        
        Test.startTest();
            
            Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new ScheduleCommunicationNotificationVoiceBC());
            Database.executeBatch(new Batch_CommunicationNotificationByVoiceBC());
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        //system.AssertEquals(taskList[0].status, 'Completed');
        //System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
    
    static testMethod void testCommunicationNotifyByVoiceBCOffer() {
        
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
        communication.nu_dse__Voice_BC_Daily_Limit__c = 2;
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
        accStr.PersonHomePhone = '7854123652';   
        accStr.Phone = null;
        
        Account accStr2 = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr2.Phone = '7854123652';
        
        Account accStr3 = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr3.PersonHomePhone = null;   
        accStr3.Phone = null;
        accStr3.PersonMobilePhone = '7854123652';
        
        List<Account> accList = new List<Account> ();
        accList.add(accStr);
        accList.add(accStr2);
        accList.add(accStr3);
        
        insert accList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.Portfolio__c = portfolio.Id;
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm.nu_dse__Processor_Status__c = 'No Account';
        
        nu_dse__Program__c prgm2 = TestRecordCreator.createProgram();
        prgm2.nu_dse__Account__c = accStr2.Id;
        prgm2.nu_dse__Processor__c = processor.Id;
        prgm2.Portfolio__c = portfolio.Id;
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm2.nu_dse__Processor_Status__c = 'No Account';
        
        nu_dse__Program__c prgm3 = TestRecordCreator.createProgram();
        prgm3.nu_dse__Account__c = accStr3.Id;
        prgm3.nu_dse__Processor__c = processor.Id;
        prgm3.Portfolio__c = portfolio.Id;
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm3.nu_dse__Processor_Status__c = 'No Account';
        
        List<nu_dse__Program__c> progList = new List<nu_dse__Program__c> ();
        progList.add(prgm);
        progList.add(prgm2);
        progList.add(prgm3);
        
        insert progList;
        
        Id creditorRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Creditor');
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = creditorRecordTypeId, nu_dse__CFT_Synced__c = TRUE);
        insert acct;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeline(acct.Id, prgm.Id);
        
        nu_dse__TradeLine__c tradeline2 = TestRecordCreator.createTradeline(acct.Id, prgm.Id);
        
        nu_dse__TradeLine__c tradeline3 = TestRecordCreator.createTradeline(acct.Id, prgm.Id);
        
        List<nu_dse__TradeLine__c> tradelineList = new List<nu_dse__TradeLine__c>();
        tradelineList.add(tradeline);
        tradelineList.add(tradeline2);
        tradelineList.add(tradeline3);
        
        insert tradelineList;
        
        nu_dse__offer__c offerInst = TestRecordCreator.createOffer(prgm.Id, tradeline.Id, 1, 1, 1, 1);
        nu_dse__offer__c offerInst2 = TestRecordCreator.createOffer(prgm2.Id, tradeline2.Id, 1, 1, 1, 1);
        nu_dse__offer__c offerInst3 = TestRecordCreator.createOffer(prgm3.Id, tradeline3.Id, 1, 1, 1, 1);
        
        List<nu_dse__offer__c> offerList = new List<nu_dse__offer__c>();
        offerList.add(offerInst);
        offerList.add(offerInst2);
        offerList.add(offerInst3);
        
        insert offerList;
        
        nu_dse__Communication_Template__c communicationTemp = TestRecordCreator.createCommunicationTemplate('Voice Broadcast');
        communicationTemp.nu_dse__TwiML__c = 'Test Message';
        communicationTemp.nu_dse__Action_Type__c = 'Voice Broadcast';
        insert communicationTemp;
        
        List<Voice_Recordings__c> voiceRecs = new List<Voice_Recordings__c>{
            new Voice_Recordings__c(
                Communication_Template__c = communicationTemp.Id,
                twilio_answer_type__c = 'human',
                External_Id__c = 'a02k34bbj2h34',
                Recording_Name__c = 'Human Recording',
                Portfolio__c = portfolio.Id
            ),
            new Voice_Recordings__c(
                Communication_Template__c = communicationTemp.Id,
                twilio_answer_type__c = 'machine',
                External_Id__c = 'a02ghg7g2h34',
                Recording_Name__c = 'Machine Recording',
                Portfolio__c = portfolio.Id
            )
        };
        
        insert voiceRecs;
        
        List<Task> tasksList = new List<Task>();
        Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
        taskRec1.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec1);
        
        Task taskRec2 = TestRecordCreator.createTask(user1.Id, offerInst.Id);
        taskRec2.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec2);
        
        Task taskRec = TestRecordCreator.createTask(user1.Id, offerInst.Id);
        taskRec.nu_dse__Communication_Template__c = communicationTemp.Id;
        taskRec.nu_dse__Phone__c = '7854125896';
        tasksList.add(taskRec);
        
        Task taskRec3 = TestRecordCreator.createTask(user1.Id, offerInst2.Id);
        taskRec3.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec3);
        
        Task taskRec4 = TestRecordCreator.createTask(user1.Id, offerInst3.Id);
        taskRec4.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec4);
        
        insert tasksList;
        
        Test.startTest();
            
            /*Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new ScheduleCommunicationNotificationVoiceBC());*/
            Database.executeBatch(new Batch_CommunicationNotificationByVoiceBC());
        
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Subject, Status, nu_dse__Communication_Sent__c FROM Task WHERE Id = :tasksList[0].Id];
        system.AssertEquals(taskList[0].status, 'Completed');
        System.assertEquals(True, taskList[0].nu_dse__Communication_Sent__c);  
    }
}