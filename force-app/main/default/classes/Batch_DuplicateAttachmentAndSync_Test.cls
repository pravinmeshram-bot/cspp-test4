@isTest
public class Batch_DuplicateAttachmentAndSync_Test {
    
    @isTest
    public static void createAttachmentFunctionWithDocument() {
        
        Id recordTypeId;
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = 'Client'
                                                                    AND SObjectType = 'Account'
                                                                    AND isActive = True]);
         
        if (recordTypeList.isEmpty() == False) {
            
            recordTypeId = recordTypeList[0].Id;
        }
        
        Account accountInstance = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), 
                                   Phone  = '9845764876', PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', 
                                   PersonMailingCity = 'city', personMailingState = 'AL', personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', 
                                   PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', 
                                   RecordTypeId = recordTypeId, nu_dse__External_CFT_Id__c = '2342342344');
        insert accountInstance;
        
        nu_dse__Processor__c newProcessor = New nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True, nu_dse__Type__c = 'CFT', 
                                                                     nu_dse__Username__c = 'cftTest.com', nu_dse__Password__c = 'test',
                                                                     nu_dse__Endpoint__c = 'https://test.com:8433/wsrv/services',
                                                                     nu_dse__Subscriber_Id__c = '123123', nu_dse__Client_Account_Last_Synced_Date_Time__c = system.now(),
                                                                     nu_dse__TradeLine_Last_Synced_Date_Time__c = system.now(), nu_dse__Subscriber_Fee_Id__c = '20123', 
                                                                     nu_dse__Bank_Account_Last_Synced_Date_Time__c = system.now());
        insert newProcessor;
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c (nu_dse__Account__c = accountInstance.Id, nu_dse__Processor__c = newProcessor.Id, nu_dse__Processor_Status__c = 'Pending Creation');
        insert programInstance;
        
        Attachment newAttachment1 = new Attachment(Name = 'AUTHORIZATION-SPAAAttachmentName', Body = Blob.valueOf('Attachment Body'), ParentId = programInstance.Id);
        Attachment newAttachment2 = new Attachment(Name = 'AUTHORIZATION-SPAAAttachmentName', Body = Blob.valueOf('Attachment Body'), ParentId = programInstance.Id);
        
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(newAttachment1);
        attachmentList.add(newAttachment2);
        
        insert attachmentList;
        
        nu_dse__Document__c documentInst = new nu_dse__Document__c ();
        documentInst.nu_dse__Attachment_Name__c = newAttachment1.Name;
        documentInst.nu_dse__Attachment_Id__c  = Id.valueOf(attachmentList[0].Id);
        documentInst.nu_dse__External_CFT_Id__c = '345345';
        
        nu_dse__Document__c documentInst1 = new nu_dse__Document__c ();
        documentInst1.nu_dse__Attachment_Name__c = newAttachment2.Name;
        documentInst1.nu_dse__Attachment_Id__c  = Id.valueOf(attachmentList[1].Id);
        documentInst1.nu_dse__External_CFT_Id__c = '345345';
        
        List<nu_dse__Document__c> documentList = new List<nu_dse__Document__c> ();
        
        documentList.add(documentInst);
        documentList.add(documentInst1);
        
        insert documentList;
        
        Batch_DuplicateAttachmentAndSync inst = new Batch_DuplicateAttachmentAndSync();
        inst.filterCondition = 'Id = \'' + programInstance.Id + '\'';
        inst.orderingAndLimit = 'LIMIT 1';
        
        Test.startTest();
        
        Database.executeBatch(inst, 200);
        
        Test.stopTest();
        
        List<Attachment> duplicateAttachment = [SELECT Id, Name FROM Attachment WHERE Name = 'Duplicate-AUTHORIZATION-SPAAAttachmentName'];
        
        System.assertEquals(0, duplicateAttachment.size());
        
    }
    
    @isTest
    public static void createAttachmentFunctionWithOutDocument() {
        
        Id recordTypeId;
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = 'Client'
                                                                    AND SObjectType = 'Account'
                                                                    AND isActive = True]);
         
        if (recordTypeList.isEmpty() == False) {
            
            recordTypeId = recordTypeList[0].Id;
        }
        
        Account accountInstance = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), 
                                   Phone  = '9845764876', PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', 
                                   PersonMailingCity = 'city', personMailingState = 'AL', personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', 
                                   PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', 
                                   RecordTypeId = recordTypeId, nu_dse__External_CFT_Id__c = '2342342344');
        insert accountInstance;
        
        nu_dse__Processor__c newProcessor = New nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True, nu_dse__Type__c = 'CFT', 
                                                                     nu_dse__Username__c = 'cftTest.com', nu_dse__Password__c = 'test',
                                                                     nu_dse__Endpoint__c = 'https://test.com:8433/wsrv/services',
                                                                     nu_dse__Subscriber_Id__c = '123123', nu_dse__Client_Account_Last_Synced_Date_Time__c = system.now(),
                                                                     nu_dse__TradeLine_Last_Synced_Date_Time__c = system.now(), nu_dse__Subscriber_Fee_Id__c = '20123', 
                                                                     nu_dse__Bank_Account_Last_Synced_Date_Time__c = system.now());
        insert newProcessor;
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c (nu_dse__Account__c = accountInstance.Id, nu_dse__Processor__c = newProcessor.Id, nu_dse__Processor_Status__c = 'Pending Creation');
        insert programInstance;
        
        Attachment newAttachment1 = new Attachment(Name = 'AUTHORIZATION-SPAAAttachmentName', Body = Blob.valueOf('Attachment Body'), ParentId = programInstance.Id);
        Attachment newAttachment2 = new Attachment(Name = 'AUTHORIZATION-SPAAAttachmentName', Body = Blob.valueOf('Attachment Body'), ParentId = programInstance.Id);
        
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(newAttachment1);
        attachmentList.add(newAttachment2);
        
        insert attachmentList;
        
        Batch_DuplicateAttachmentAndSync inst = new Batch_DuplicateAttachmentAndSync();
        inst.filterCondition = 'Id = \'' + programInstance.Id + '\'';
        inst.orderingAndLimit = 'LIMIT 1';
        
        Test.startTest();
        
        Database.executeBatch(inst, 200);
        
        Test.stopTest();
        
        List<Attachment> duplicateAttachment = [SELECT Id, Name FROM Attachment WHERE Name = 'Duplicate-AUTHORIZATION-SPAAAttachmentName'];
        
        System.assertEquals(1, duplicateAttachment.size());
        
    }
    
    @isTest
    public static void callCreateDuplicateAttachmentQueueable_Error() {
        
        Id recordTypeId;
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = 'Client'
                                                                    AND SObjectType = 'Account'
                                                                    AND isActive = True]);
         
        if (recordTypeList.isEmpty() == False) {
            
            recordTypeId = recordTypeList[0].Id;
        }
        
        Account accountInstance = new Account(FirstName = 'TestAccount1', LastName = 'Test1', PersonBirthDate = System.today().addYears(-18), 
                                   Phone  = '9845764876', PersonMobilePhone = '9625345652', PersonMailingStreet = 'Test Street', 
                                   PersonMailingCity = 'city', personMailingState = 'AL', personMailingpostalcode = '94405', nu_dse__SSN__c = '789-78-7889', 
                                   PersonOtherCity = 'otherCity', PersonOtherState = 'OtherState', PersonMailingCountry = 'US', PersonOtherPostalCode = 'OtherPostalCode', 
                                   RecordTypeId = recordTypeId, nu_dse__External_CFT_Id__c = '2342342344');
        insert accountInstance;
        
        nu_dse__Processor__c newProcessor = New nu_dse__Processor__c(Name = 'CFT', nu_dse__Is_Default__c = True, nu_dse__Type__c = 'CFT', 
                                                                     nu_dse__Username__c = 'cftTest.com', nu_dse__Password__c = 'test',
                                                                     nu_dse__Endpoint__c = 'https://test.com:8433/wsrv/services',
                                                                     nu_dse__Subscriber_Id__c = '123123', nu_dse__Client_Account_Last_Synced_Date_Time__c = system.now(),
                                                                     nu_dse__TradeLine_Last_Synced_Date_Time__c = system.now(), nu_dse__Subscriber_Fee_Id__c = '20123', 
                                                                     nu_dse__Bank_Account_Last_Synced_Date_Time__c = system.now());
        insert newProcessor;
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c (nu_dse__Account__c = accountInstance.Id, nu_dse__Processor__c = newProcessor.Id, nu_dse__Processor_Status__c = 'Pending Creation');
        insert programInstance;
        
        Attachment newAttachment1 = new Attachment();
        Attachment newAttachment2 = new Attachment();
        
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(newAttachment1);
        attachmentList.add(newAttachment2);
        
        //insert attachmentList;
        
        test.startTest();
        
        System.enqueueJob(new CreateDuplicateAttachmentQueueable(attachmentList));
        
        test.stopTest();
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id, Name, nu_dse__Class_Method__c, nu_dse__Message__c FROM nu_dse__Error_Log__c];
        
        System.assertEquals(2, errorLogList.size());
        System.assertEquals('CreateDuplicateAttachmentQueueableJob', errorLogList[0].nu_dse__Class_Method__c);
        System.assertEquals('Required fields are missing: [ParentId, Name, Body];', errorLogList[0].nu_dse__Message__c);
        
    }
    
    @isTest
    public static void callSchedulerClass() {
        
        Integer batchSize = -1;
        String queryFilterCondition = 'Id != null';//Optional condition*
        String orderingAndLimit = 'LIMIT 1';//optional condition*
        
        Schedule_DuplicateAttachmentAndSync scheduleInstance = new Schedule_DuplicateAttachmentAndSync(batchSize, queryFilterCondition, orderingAndLimit );
         // on default constructor batch size is 200
        String sch = '0 0 * * * ?';
        
        Test.startTest(); 
        
        String jobID = system.schedule('Duplicate Attachment creation job', sch, scheduleInstance);
        
        Test.stopTest();
        
    }
}