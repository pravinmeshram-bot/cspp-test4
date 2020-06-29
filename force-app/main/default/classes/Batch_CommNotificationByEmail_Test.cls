@isTest
public class Batch_CommNotificationByEmail_Test {
    
    @testsetup static void setupTestData() {
        
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
        
        Contact contactRec = new Contact(LastName = 'Test Contact', Email = 'test@123mail.com');
        insert contactRec;
        
        nu_dse__Communication_Notification_Settings__c communicationNotifSetting = new nu_dse__Communication_Notification_Settings__c();
        communicationNotifSetting.nu_dse__Email_Daily_Limit__c = 10;
        communicationNotifSetting.nu_dse__Email_Hourly_Limit__c = 10;
        insert communicationNotifSetting;
        
        nu_dse__Communication_Template__c commTemp = new nu_dse__Communication_Template__c();
        commTemp.nu_dse__Action_Type__c = 'Email Alert';
        insert commTemp;
        
        Task commTask = new Task();
        commTask.ActivityDate = System.today();
        commTask.nu_dse__Communication_Template__c = commTemp.Id;
        commTask.nu_dse__Communication_Sent__c = false;
        commTask.Status = 'Not Started';
        insert commTask;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Client');
        
        Account accStr = TestRecordCreator.createAccount('Test Account', clientRecordTypeId);
        insert accStr;
        
        EmailTemplate validEmailTemplate = new EmailTemplate();
        
        system.runAs(user1) {
        
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.Subject = 'Your Subject Here';
            insert validEmailTemplate;
        }
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.nu_dse__Processor_Status__c = 'No Account';
        prgm.nu_dse__Program_Status__c = 'Active Client';
        insert prgm;
        
        nu_dse__Payment__c payment = TestRecordCreator.createPayments(prgm.Id);
        insert payment;
        
        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
        insert prospect;
        
        nu_dse__Communication_Template__c communicationTemp = TestRecordCreator.createCommunicationTemplate('Email Alert');
        communicationTemp.nu_dse__Email_Template_Id__c = validEmailTemplate.Id;
        insert communicationTemp;
        
        List<Task> tasksList = new List<Task>();
        Task taskRec1 = TestRecordCreator.createTask(user1.Id, prgm.Id);
        taskRec1.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec1);
        
        Task taskRec2 = TestRecordCreator.createTask(user1.Id, prgm.Id);
        taskRec2.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec2);
        
        Task taskRec3 = TestRecordCreator.createTask(user1.Id, prospect.Id);
        taskRec3.nu_dse__Communication_Template__c = communicationTemp.Id;
        tasksList.add(taskRec3);
        insert tasksList;
    }
    
    @isTest
    public static void executeEmailBatchTest() {
    
        Test.startTest();
            Database.executeBatch(new Batch_CommunicationNotificationByEmail());
        Test.stopTest();
    }
    
    @isTest
    public static void executeScheduler() {
        
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new ScheduleCommunicationNotificationEmail());
        Test.stopTest();
        
    }
}