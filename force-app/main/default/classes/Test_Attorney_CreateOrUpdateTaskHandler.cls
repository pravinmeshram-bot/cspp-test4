@isTest
public class Test_Attorney_CreateOrUpdateTaskHandler {
    static List <nu_dse__Group_Task__c> grouptaskList = new List <nu_dse__Group_Task__c> ();
    static Map <Id, nu_dse__Group_Task__c> groupTaskMap = new Map <Id, nu_dse__Group_Task__c> ();
    static nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c ();
    static User u1 = new User();
    static void init () {
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '6Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1';
        insert pgm;
        
        groupTask.Program__c = pgm.Id;
        //groupTask.Task_Id__c = '1';
        groupTask.nu_dse__Subject__c = 'Test';
        groupTask.nu_dse__Description__c = 'Testing';
        groupTask.Subject_Picklist__c = '30 Day In-House Follow Up';
        groupTask.Priority__c = 'High';
        groupTask.nu_dse__ActivityDate__c = Date.Today ();
        groupTask.Integration_Reason__c='sdjkskdbv';
        groupTask.ownerId=u1.id;
        //Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted= true;
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted= false;
        insert groupTask;
        
        
        
        groupTask = [SELECT Program__c, Task_ID__c, IsRelatedRecordEligibleForPick__c,
                     nu_dse__Subject__c , nu_dse__Description__c , IsAttorney__c,
                     Subject_Picklist__c , Priority__c , nu_dse__ActivityDate__c  
                     FROM nu_dse__Group_Task__c WHERE ID =: groupTask.ID ];
        grouptaskList.add (groupTask);
        groupTask.nu_dse__ActivityDate__c = Date.Today ().addDays (2);
        groupTask.Task_Id__c = '2';
        groupTask.nu_dse__Subject__c = 'Test2';
        groupTask.Subject_Picklist__c = '1099c on File';
        groupTask.Priority__c = 'Medium';
        groupTask.nu_dse__Description__c = 'Testing2';
        groupTask.nu_dse__Subject__c = 'Test2';
        groupTask.Integration_Reason__c='sdjkskdbv';
        update groupTask;
        
        nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
        taskType.TaskName__c = groupTask.Subject_Picklist__c ;
        taskType.TaskTypeId__c = '1';
        insert taskType;
        
        
        
        groupTaskMap.put (groupTask.id, groupTask);
    }
    @isTest static void schedulerTest () {
        
        Test.startTest ();
        init ();
        Set<Id> groupTaskIds = new Set<Id>();
        groupTaskIds.add(groupTask.id);
        Attorney_StaticVariableUtility.apiUser = false;
        Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateTaskHandler.webserviceTaskTypeMock ());
        Attorney_CreateOrUpdateNDSGrpTaskHandler.CreateOrUpdateNDSGrpTask (grouptaskList, groupTaskMap);
        Attorney_CreateOrUpdateNDSGrpTaskHandler.setIntegrationFields (groupTask, 'Initiated', 'Testing');
        Attorney_CreateOrUpdateNDSGrpTaskHandler.AsynCallToNDSGroupTask obj = new Attorney_CreateOrUpdateNDSGrpTaskHandler.AsynCallToNDSGroupTask (groupTaskIds);
        String jobId = System.enqueueJob(obj);
        Test.stopTest ();
    }
    
    @isTest static void schedulerTest1 () {
        
        Profile p = [Select Id from Profile where name='System Administrator'];
        //TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey]
        User u = new User();
        u.Attorney_Admin__c = true;
        u.Alias = 'test133';
        u.Email = 'test@test.com';
        u.Username = 'test12387@test1234.com';
        u.LastName = 'test';
        u.ProfileId = p.id;
        u.IsActive = true;
        u.TimeZoneSidKey = 'America/New_York';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        system.runAs(u){
        Test.startTest ();
        init ();
        Set<Id> groupTaskIds = new Set<Id>();
        groupTaskIds.add(groupTask.id);
        System.debug(groupTask.id);
        System.debug('****'+[Select Task_Id__c,Integration_Status__c,Integration_Reason__c,Program__r.Import_Id__c,owner.email,nu_dse__ActivityDate__c,nu_dse__Subject__c,nu_dse__Description__c,OwnerId,Owner.Name,
                                                      TaskTypeId__c,CreatedDate,LastModifiedDate,Priority__c,Subject_Picklist__c,Completed_On__c from nu_dse__Group_Task__c where id=:groupTaskIds]);
        
        System.debug('****'+[Select Task_Id__c,Integration_Status__c,Integration_Reason__c,Program__r.Import_Id__c,owner.email,nu_dse__ActivityDate__c,nu_dse__Subject__c,nu_dse__Description__c,OwnerId,Owner.Name,
                                                      TaskTypeId__c,CreatedDate,LastModifiedDate,Priority__c,Subject_Picklist__c,Completed_On__c from nu_dse__Group_Task__c where id=:groupTask.Id]);
       
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        Attorney_StaticVariableUtility.apiUser = false;
        Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateTaskHandler.webserviceTaskTypeMock ());
        Attorney_CreateOrUpdateNDSGrpTaskHandler.CreateOrUpdateNDSGrpTask (grouptaskList, groupTaskMap);
        Attorney_CreateOrUpdateNDSGrpTaskHandler.setIntegrationFields (groupTask, 'Initiated', 'sdjkskdbv njnbkjnbknbk jdvkjnvjbnkjfn wjnkjnvjernv jfjvnkjenvjfnk jvnkejnvkjenrejk evnkjnfkjnkjvn vnkjnvrejvnrkjn vrrekjvnrjnvrjnvrkj vrjknvrkjnkjvrnkjvn rjnvkrjvnrkjn nkbvrkebvrehvbrhvbrhb vjrvbkerbvkrbvbureiuev bureivbriuvubriurbiuhggnegrurgbvb rvkrehurihiuhughvvkjrekj');
        Attorney_CreateOrUpdateNDSGrpTaskHandler.AsynCallToNDSGroupTask obj = new Attorney_CreateOrUpdateNDSGrpTaskHandler.AsynCallToNDSGroupTask (groupTaskIds);
        String jobId = System.enqueueJob(obj);
        Test.stopTest ();
        }
    }
    
    @isTest static void schedulerTest2 () {
        
        
        Test.startTest ();
        init ();
        Set<Id> groupTaskIds = new Set<Id>();
        groupTaskIds.add(groupTask.id);
        
        u1.email = 'test=test.com@example.com';
        update u1;
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        Attorney_StaticVariableUtility.apiUser = false;
        Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateTaskHandler.webserviceTaskTypeMock ());
        Attorney_CreateOrUpdateNDSGrpTaskHandler.CreateOrUpdateNDSGrpTask (grouptaskList, groupTaskMap);
        Attorney_CreateOrUpdateNDSGrpTaskHandler.setIntegrationFields (groupTask, 'Initiated', 'sdjkskdbv njnbkjnbknbk jdvkjnvjbnkjfn wjnkjnvjernv jfjvnkjenvjfnk jvnkejnvkjenrejk evnkjnfkjnkjvn vnkjnvrejvnrkjn vrrekjvnrjnvrjnvrkj vrjknvrkjnkjvrnkjvn rjnvkrjvnrkjn nkbvrkebvrehvbrhvbrhb vjrvbkerbvkrbvbureiuev bureivbriuvubriurbiuhggnegrurgbvb rvkrehurihiuhughvvkjrekj');
        Attorney_CreateOrUpdateNDSGrpTaskHandler.AsynCallToNDSGroupTask obj = new Attorney_CreateOrUpdateNDSGrpTaskHandler.AsynCallToNDSGroupTask (groupTaskIds);
        String jobId = System.enqueueJob(obj);
        Test.stopTest ();
    }
    
    public class webserviceTaskTypeMock implements WebServiceMock {
        public void doInvoke (
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
                
                leadtracNetClient.UpdateTasksResult result = new leadtracNetClient.UpdateTasksResult ();
                LeadtracNetClient.ArrayOfResultMessage messageArray = new LeadtracNetClient.ArrayOfResultMessage ();
                List <leadtracNetClient.ResultMessage> messageList = new List <leadtracNetClient.ResultMessage> ();
                leadtracNetClient.ResultMessage message = new leadtracNetClient.ResultMessage ();
                message.MessageType = 'Test';
                message.Message = 'test';                    
                messageList.add (message);
                messageArray.ResultMessage = messageList;
                result.Messages = messageArray;
                
                leadtracNetClient.ArrayOfTaskResult taskArray = new leadtracNetClient.ArrayOfTaskResult ();
                List <leadtracNetClient.TaskResult> listOfTasks = new List <leadtracNetClient.TaskResult> ();
                leadtracNetClient.TaskResult taskResult = new leadtracNetClient.TaskResult ();
                taskResult.IsSuccessful = True;
                leadtracNetClient.Task task = new leadtracNetClient.Task ();
                task.FileNumber = '1';
                task.TaskId = 1;
                task.ScheduledOnUTC = DateTime.Now ();
                task.Subject = 'test';
                task.Description = 'test';
                task.AssignedAs = 'Test';
                task.AssignedTo = 'test';
                task.RemindMinutesBefore = 2;
                task.CompletedOn = DateTime.Now ();
                task.CreatedOn = DateTime.Now ();
                task.ModifiedOn = DateTime.Now ();
                leadtracNetClient.TaskType taskType = new leadtracNetClient.TaskType ();
                taskType.Category = 'test';
                taskType.TaskTypeId = 1;
                taskType.Name = 'Test';
                taskType.Priority = 'high';
                taskType.UserAssignmentRequired = 'TRUE';
                task.TaskType = taskType;
                taskResult.Task = task;
                taskResult.Messages = messageArray;
                listOfTasks.add (taskResult);
                taskArray.TaskResult = ListOfTasks;
                result.Tasks = taskArray;
                result.IsSuccessful = TRUE;
                
                LeadtracNetClient.CreateOrUpdateTaskResponse_element respElement = new LeadtracNetClient.CreateOrUpdateTaskResponse_element ();
                respElement.CreateOrUpdateTaskResult =  result;
                response.put('response_x', respElement);
                
            }
    }
    
}