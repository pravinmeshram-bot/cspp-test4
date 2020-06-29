@isTest

public class InsertGroupTask_Test{

    static testMethod void testClass() {
        
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        insert programInstance;
        
        nu_dse__Communication_Template__c communicationTempProgram = TestRecordCreator.createCommunicationTemplate('SMS');
        communicationTempProgram.Name = 'test Template';
        communicationTempProgram.nu_dse__SMS_Body__c = '{Home_Phone__c}';
        communicationTempProgram.nu_dse__From__c = '8596547852';
        communicationTempProgram.nu_dse__Action_Type__c = 'Voice Broadcast';
        communicationTempProgram.nu_dse__TwiML__c = 'www.google.com';
 
        insert communicationTempProgram;
        
        List<InsertGroupTask.CreateGroupTaskRequest> createGroupTaskRequestList = new List<InsertGroupTask.CreateGroupTaskRequest>();
        
        InsertGroupTask.CreateGroupTaskRequest createGroupTaskRequest = new InsertGroupTask.CreateGroupTaskRequest();
        createGroupTaskRequest.uniqueIdentifier = programInstance.Id+'_test';
        createGroupTaskRequest.subject = 'Test';
        createGroupTaskRequest.activityDate = system.today();
        createGroupTaskRequest.parentId = programInstance.Id;
        createGroupTaskRequest.templateName = 'test Template';
        createGroupTaskRequest.subjectPicklist = 'None';
        createGroupTaskRequest.description = 'Test Description';
        createGroupTaskRequest.status = 'In Progress';
        createGroupTaskRequest.queueName = 'Amerlink';
        createGroupTaskRequestList.add(createGroupTaskRequest);
        
        InsertGroupTask.CreateGroupTaskRequest createGroupTaskRequest1 = new InsertGroupTask.CreateGroupTaskRequest();
        createGroupTaskRequest1.uniqueIdentifier = programInstance.Id+'_test1';
        createGroupTaskRequest1.subject = 'Test';
        createGroupTaskRequest1.activityDate = system.today();
        createGroupTaskRequest1.parentId = programInstance.Id;
        createGroupTaskRequest1.templateId = communicationTempProgram.Id;
        createGroupTaskRequest1.ownerId = UserInfo.getUserId();
        createGroupTaskRequest1.subjectPicklist = 'None';
        
        createGroupTaskRequestList.add(createGroupTaskRequest1);
        
        InsertGroupTask.invoke(createGroupTaskRequestList);
        
        List<InsertGroupTask.CreateGroupTaskRequest> createGroupTaskRequestList1 = new List<InsertGroupTask.CreateGroupTaskRequest>();
        
        InsertGroupTask.CreateGroupTaskRequest GroupTaskRequest = new InsertGroupTask.CreateGroupTaskRequest();
        GroupTaskRequest.uniqueIdentifier = programInstance.Id+'_test';
        GroupTaskRequest.subject = 'Test';
        GroupTaskRequest.activityDate = system.today();
        GroupTaskRequest.parentId = programInstance.Id;
        GroupTaskRequest.templateName = 'test Template';
        GroupTaskRequest.subjectPicklist = 'None';
        GroupTaskRequest.status = 'Pending';
        GroupTaskRequest.queueName = 'Amerlink';
        createGroupTaskRequestList1.add(GroupTaskRequest);
        InsertGroupTask.invoke(createGroupTaskRequestList1 );
    }
}