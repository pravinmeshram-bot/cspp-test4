@isTest
public class Batch_CommunicationNotifyByEmail_Test {
    
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
        
        /****Changes for generic record creation****Starts****/
        Account accStr1 = TestRecordCreator.createAccount('Test Account 1', TestRecordCreator.getRecordTypeId('Account' ,'Client'));
        accStr1.PersonEmail = 'test@test.com';
        accStr1.phone = '9879879877';
        insert accStr1;
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE AccountId  =: accStr1.Id];
        nu_dse__Communication_Notification_Settings__c communicationNotifSetting = TestRecordCreator.createCommunicationNotificationSettings();
        if (conList.isEmpty() == False) {
            
            communicationNotifSetting.nu_dse__Default_Prospect_Contact_Id__c = conList[0].Id;
        }
        insert communicationNotifSetting;
        
        nu_dse__Communication_Template__c commTemp = TestRecordCreator.createCommunicationTemplate('Email Alert');
        insert commTemp;
        
        Task commTask = TestRecordCreator.createTask(null);
        commTask.ActivityDate = System.today();
        commTask.nu_dse__Communication_Template__c = commTemp.Id;
        commTask.nu_dse__Communication_Sent__c = false;
        commTask.Status = 'Not Started';
        insert commTask;
        
        Task commTask1 = TestRecordCreator.createTask(null);
        commTask1.ActivityDate = System.today();
        commTask1.nu_dse__Communication_Template__c = commTemp.Id;
        commTask1.nu_dse__Communication_Sent__c = false;
        commTask1.Status = 'Not Started';
        insert commTask1;
        
        nu_dse__Holidays_Settings__c holidaySetting = TestRecordCreator.createholidaySetting();
        insert holidaySetting;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;
        
        Account accStr = TestRecordCreator.createAccount('Test Account', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accStr.PersonEmail = 'test@test.com';
        accStr.phone = '9879879877';
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
        
        nu_dse__Communication_Template__c communicationTemp = TestRecordCreator.createCommunicationTemplate('Email Alert');
        communicationTemp.nu_dse__Email_Template_Id__c = validEmailTemplate.Id;
        insert communicationTemp;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram(accStr.Id, processor.Id, 'No Account');
        prgm.Portfolio__c = portfolio.Id;
        prgm.nu_dse__Program_Status__c = 'Active Client';
        insert prgm;
        
        nu_dse__Payment__c payment = TestRecordCreator.createPayments(prgm.Id);
        insert payment;
        
        nu_dse__Prospect__c prospect = TestRecordCreator.createProspect();
        prospect.nu_dse__Email_Address__c = 'test@test.com';
        insert prospect;
        
        Account acct = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account' ,'Creditor'));
        acct.phone = '9879879877';
        acct.nu_dse__CFT_Synced__c = TRUE;
        insert acct;
        
        nu_dse__TradeLine__c trd = TestRecordCreator.createTradeLine(acct.Id, prgm.id);
        trd.nu_dse__New_Account_Number__c = '987654321654';
        trd.nu_dse__New_Creditor__c = acct.Id;//un-commented out on Mar-14-2019
        insert trd;
        /****Changes for generic record creation****Ends****/
        
    }
    
    @isTest
    public static void executeEmailBatchTest() {
        
        Test.startTest();
        
            executeEmailBatch();
        
        Test.stopTest();
        
    }
    public static void executeEmailBatch(){
        
        List<nu_dse__Program__c> programList = [Select Id FROM nu_dse__Program__c];
        
        List<nu_dse__Prospect__c> prospectList = [Select Id FROM nu_dse__Prospect__c];
        
        List<nu_dse__Tradeline__c> tradelineList = [Select Id FROM nu_dse__Tradeline__c];
        
        List<nu_dse__Payment__c> paymentList = [Select Id FROM nu_dse__Payment__c];
        
        List<contact> conList = [SELECT Id FROM Contact];
        
        List<nu_dse__Communication_Template__c> commTempList = [SELECT Id FROM nu_dse__Communication_Template__c WHERE nu_dse__Action_Type__c = 'Email Alert'];
        
        List<User> userList = [SELECT Id FROM USER WHERE Username like 'puser000@test.com%'];
        
        nu_dse__offer__c offerInst = TestRecordCreator.createOffer(programList[0].Id, tradelineList[0].Id, 1, 1, 1, 1);
        insert offerInst;
        
        List<Task> tasksList = new List<Task>();
        Task taskRec1 = TestRecordCreator.createTask(userList[0].Id, programList[0].Id);
        taskRec1.nu_dse__Communication_Template__c = commTempList[0].Id;
        taskRec1.nu_dse__Communication_Sent__c = false;
        tasksList.add(taskRec1);
        
        Task taskRec4 = TestRecordCreator.createTask(userList[0].Id, paymentList[0].Id);
        taskRec4.nu_dse__Communication_Template__c = commTempList[0].Id;
        taskRec4.nu_dse__Communication_Sent__c = false;
        tasksList.add(taskRec4);
        
        Task taskRec2 = TestRecordCreator.createTask(userList[0].Id, programList[0].Id);
        taskRec2.nu_dse__Communication_Template__c = commTempList[0].Id;
        taskRec2.nu_dse__Communication_Sent__c = false;
        tasksList.add(taskRec2);
        
        Task taskRec3 = TestRecordCreator.createTask(userList[0].Id, prospectList[0].Id);
        taskRec3.nu_dse__Communication_Template__c = commTempList[0].Id;
        taskRec3.nu_dse__Communication_Sent__c = false;
        tasksList.add(taskRec3);
        
        Task taskRec5 = TestRecordCreator.createTask(userList[0].Id, offerInst.Id);
        taskRec5.nu_dse__Communication_Template__c = commTempList[0].Id;
        taskRec5.nu_dse__Communication_Sent__c = false;
        tasksList.add(taskRec5);
        
        Task taskRec6 = TestRecordCreator.createTask(userList[0].Id, offerInst.Id);
        taskRec6.nu_dse__Communication_Template__c = commTempList[0].Id;
        taskRec6.nu_dse__Communication_Sent__c = false;
        taskRec6.whoId = conList[0].Id;
        tasksList.add(taskRec6);
        
        insert tasksList;
        
        List<AsyncApexJob> smsjobs  = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors,  ApexClass.Name FROM AsyncApexJob where  ApexClass.Name = 'Batch_CommunicationNotificationByEmail'  and status in ('Queued','Preparing','Processing') limit 1 ];       
        
        if(smsjobs.size()==0){
            Batch_CommunicationNotificationByEmail email = new Batch_CommunicationNotificationByEmail();
            Database.executeBatch(email);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Email Batch is already running!');
            ApexPages.addMessage(myMsg);
        }
    }
    
    @isTest
    public static void paramSetExceution() {
        
        Test.startTest();
            
            List<nu_dse__Program__c> programList = [Select Id FROM nu_dse__Program__c];
        
            List<nu_dse__Prospect__c> prospectList = [Select Id FROM nu_dse__Prospect__c];
            
            List<nu_dse__Tradeline__c> tradelineList = [Select Id FROM nu_dse__Tradeline__c];
            
            List<nu_dse__Payment__c> paymentList = [Select Id FROM nu_dse__Payment__c];
            
            List<contact> conList = [SELECT Id FROM Contact];
            
            List<nu_dse__Communication_Template__c> commTempList = [SELECT Id FROM nu_dse__Communication_Template__c WHERE nu_dse__Action_Type__c = 'Email Alert'];
            
            List<User> userList = [SELECT Id FROM USER WHERE Username like 'puser000@test.com%'];
            
            nu_dse__offer__c offerInst = TestRecordCreator.createOffer(programList[0].Id, tradelineList[0].Id, 1, 1, 1, 1);
            insert offerInst;
            
            List<Task> tasksList = new List<Task>();
            Task taskRec1 = TestRecordCreator.createTask(userList[0].Id, programList[0].Id);
            taskRec1.nu_dse__Communication_Template__c = commTempList[0].Id;
            taskRec1.nu_dse__Communication_Sent__c = false;
            tasksList.add(taskRec1);
            
            Task taskRec4 = TestRecordCreator.createTask(userList[0].Id, paymentList[0].Id);
            taskRec4.nu_dse__Communication_Template__c = commTempList[0].Id;
            taskRec4.nu_dse__Communication_Sent__c = false;
            tasksList.add(taskRec4);
            
            Task taskRec2 = TestRecordCreator.createTask(userList[0].Id, programList[0].Id);
            taskRec2.nu_dse__Communication_Template__c = commTempList[0].Id;
            taskRec2.nu_dse__Communication_Sent__c = false;
            tasksList.add(taskRec2);
            
            Task taskRec3 = TestRecordCreator.createTask(userList[0].Id, prospectList[0].Id);
            taskRec3.nu_dse__Communication_Template__c = commTempList[0].Id;
            taskRec3.nu_dse__Communication_Sent__c = false;
            tasksList.add(taskRec3);
            
            Task taskRec5 = TestRecordCreator.createTask(userList[0].Id, offerInst.Id);
            taskRec5.nu_dse__Communication_Template__c = commTempList[0].Id;
            taskRec5.nu_dse__Communication_Sent__c = false;
            tasksList.add(taskRec5);
            
            Task taskRec6 = TestRecordCreator.createTask(userList[0].Id, offerInst.Id);
            taskRec6.nu_dse__Communication_Template__c = commTempList[0].Id;
            taskRec6.nu_dse__Communication_Sent__c = false;
            taskRec6.whoId = conList[0].Id;
            tasksList.add(taskRec6);
            
            insert tasksList;
            
            Set<Id> taskId = new Set<Id>();
            
            for(Task t : tasksList) {
                taskId.add(t.Id);
            }
            
            Database.executeBatch(new Batch_CommunicationNotificationByEmail(taskId));
        
        Test.stopTest();
        
    }
}