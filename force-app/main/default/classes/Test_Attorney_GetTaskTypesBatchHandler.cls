@isTest
public class Test_Attorney_GetTaskTypesBatchHandler {

    static LeadtracNetClient.TaskTypeResult taskTypeResult () {
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        LeadtracNetClient.TaskTypeResult result = new LeadtracNetClient.TaskTypeResult ();
        result.IsSuccessful = true;
        leadtracNetClient.ArrayOfTaskType TaskType = new leadtracNetClient.ArrayOfTaskType ();
        List <leadtracNetClient.TaskType> taskList = new List <leadtracNetClient.TaskType> ();
        leadtracNetClient.TaskType task = new leadtracNetClient.TaskType ();
        task.TaskTypeId = 1;
        task.Name = 'test';
        task.Priority = 'test';
        task.UserAssignmentRequired = 'test';
        task.Category = 'test';
        taskList.add (task);
        taskType.taskType = taskList;
        result.TaskType = taskType;
        return result;
    }
    @isTest static void schedulerTest () {
        Test.startTest ();
        
            Attorney_GetTaskTypesBatchHandler obj = new Attorney_GetTaskTypesBatchHandler ();
            Attorney_GetTaskTypesBatchHandler.taskTypeResult = taskTypeResult ();
            Attorney_GetTaskTypesBatchHandler.getTaskTypes ();
        Test.stopTest ();
    }
}