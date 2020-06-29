@isTest
public class Test_Attorney_CreateOrUpdateNDSTaskHdlr {
    
    
    
    @isTest static void HandlerTest () {

        Task tsk = new Task ();
        List<Task> taskList = new List<Task>();
        Map<Id, Task> taskMap = new Map<Id,Task>();

        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        
        Test.startTest ();
        
        Portfolio__c p = new Portfolio__c();
        p.Name = 'Royal';
        p.Active_Status__c = true;
        insert p;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '9761';
        pgm.Program_Type__c = 'Royal';
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        insert pgm;
        
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = false;
        tsk.WhatId = pgm.Id;
        //tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.ActivityDate = Date.Today ();
        insert tsk;
        
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = false;
        
        tsk = [SELECT Id,WhatId, Task_ID__c,
                    Subject , Description , Attorney__c,
                    Subject__c , Priority , ActivityDate  
                    FROM Task WHERE ID =: tsk.ID ];
        taskList.add (tsk);
        Tsk.ActivityDate = Date.Today ().addDays (2);
        Tsk.Task_Id__c = '8672';
        Tsk.Attorney__c = true;
        Tsk.Subject = 'Test2';
        tsk.Subject__c = '1099c on File';
        Tsk.Priority = 'Medium';
        Tsk.Description = 'Testing2';
        
        update tsk;
        
        nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
        taskType.TaskName__c = tsk.Subject__c ;
        taskType.TaskTypeId__c = '6451';
        insert taskType;
        
        TaskMap.put (Tsk.id, Tsk);
            Attorney_StaticVariableUtility.apiUser = false;

            Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateNDSTaskHdlr.webserviceTaskTypeMock ());
        //    Attorney_CreateOrUpdateNDSTaskHandler.CreateOrUpdateNDSTask (taskList, TaskMap);
            Attorney_CreateOrUpdateNDSTaskHandler.setIntegrationFields (Tsk, 'Initiated', 'Testing');
            Attorney_CreateOrUpdateNDSTaskHandler.CreateNDSAddLogEntry (taskList, TaskMap);
            set<Id> taskIds = new set<Id>();
            taskIds.add(Tsk.Id); 
        
            Map<Id,nu_dse__Program__c> progMap = new Map<Id,nu_dse__Program__c> ();
            progMap.put(Tsk.WhatId,pgm);
        
        
        //    Attorney_CreateOrUpdateNDSTaskHandler.AsynCallToNDSTask obj = new Attorney_CreateOrUpdateNDSTaskHandler.AsynCallToNDSTask (taskIds, progMap);
        //    String jobId = System.enqueueJob(obj);
        Test.stopTest ();
    }
    
    @isTest static void HandlerTest1 () {
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        Task tsk = new Task ();
        List<Task> taskList = new List<Task>();
        Map<Id, Task> taskMap = new Map<Id,Task>();
        
        Portfolio__c p = new Portfolio__c();
        p.Name = 'Royal';
        p.Active_Status__c = true;
        insert p;
        
        Test.startTest ();
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Program_Type__c = 'Royal';
        pgm.Import_ID__c = '2345';
        Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        insert pgm;
        
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = false;
        tsk.WhatId = pgm.Id;
        tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.ActivityDate = Date.Today ();
        insert tsk;
        
        
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = false;
        tsk = [SELECT Id,WhatId, Task_ID__c,
                    Subject , Description , Attorney__c,
                    Subject__c , Priority , ActivityDate , isNote__c, nu_dse__Is_noted__c 
                    FROM Task WHERE ID =: tsk.ID ];
        //Tsk.Task_Id__c = '2';
        taskList.add (tsk);
        Task Tsk1 = new Task();
        Tsk1.Id = tsk.Id;
        Tsk1.ActivityDate = Date.Today ().addDays (2);
        Tsk1.Task_Id__c = '2';
        Tsk1.Subject = 'Test2';
        tsk1.Subject__c = '1099c on File';
        Tsk1.Priority = 'Medium';
        Tsk1.Description = 'Testing2';
        
        update tsk1;
        
        nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
        taskType.TaskName__c = tsk.Subject__c ;
        taskType.TaskTypeId__c = '2564';
        insert taskType;
        
        TaskMap.put (Tsk.id, Tsk1);
            Attorney_StaticVariableUtility.apiUser = false;

            Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateNDSTaskHdlr.webserviceTaskTypeMock ());
    //        Attorney_CreateOrUpdateNDSTaskHandler.CreateOrUpdateNDSTask (taskList, TaskMap);
            Attorney_CreateOrUpdateNDSTaskHandler.setIntegrationFields (Tsk, 'Initiated', 'Testing');
            Attorney_CreateOrUpdateNDSTaskHandler.CreateNDSAddLogEntry (taskList, TaskMap);
            set<Id> taskIds = new set<Id>();
            taskIds.add(Tsk.Id); 
        
            Map<Id,nu_dse__Program__c> progMap = new Map<Id,nu_dse__Program__c> ();
            progMap.put(Tsk.WhatId,pgm);
        
    //        Attorney_CreateOrUpdateNDSTaskHandler.AsynCallToNDSTask obj = new Attorney_CreateOrUpdateNDSTaskHandler.AsynCallToNDSTask (taskIds, progMap);
    //        String jobId = System.enqueueJob(obj);
        Test.stopTest ();
    }
    
    @isTest static void HandlerTest2 () {
        System.debug('*******************');
        Profile p = [Select Id from Profile where name='System Administrator'];
        //TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey]
        User u = new User();
        u.Attorney_Admin__c = false;
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
        
        System.runAs(u){
        
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
        Task tsk = new Task ();
        List<Task> taskList = new List<Task>();
        Map<Id, Task> taskMap = new Map<Id,Task>();
        
        Portfolio__c p1 = new Portfolio__c();
        p1.Name = 'Royal';
        p1.Active_Status__c = true;
        insert p1;
        
        Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        Test.startTest ();
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '3432';
        pgm.Program_Type__c = 'Royal';
        insert pgm;
        
        
        tsk.WhatId = pgm.Id;
        //tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.ActivityDate = Date.Today ();
        
        System.debug('****TestMethod2 insert');
        
        insert tsk;
        
        
        
        tsk = [SELECT WhatId, Task_ID__c,
                    Subject , Description , Attorney__c,
                    Subject__c , Priority , ActivityDate  
                    FROM Task WHERE ID =: tsk.ID ];
        taskList.add (tsk);
        Tsk.ActivityDate = Date.Today ().addDays (2);
        Tsk.Task_Id__c = '2';
        Tsk.Subject = 'Test2';
        tsk.Subject__c = '1099c on File';
        Tsk.Priority = 'Medium';
        Tsk.Description = 'Testing2';
        System.debug('******Test Method 2 Update');
        update tsk;
        
        nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
        taskType.TaskName__c = tsk.Subject__c ;
        taskType.TaskTypeId__c = '3435';
        insert taskType;
        
        TaskMap.put (Tsk.id, Tsk);
            Attorney_StaticVariableUtility.apiUser = false;

            Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateNDSTaskHdlr.webserviceTaskTypeMock ());
   //         Attorney_CreateOrUpdateNDSTaskHandler.CreateOrUpdateNDSTask (taskList, TaskMap);
            Attorney_CreateOrUpdateNDSTaskHandler.setIntegrationFields (Tsk, 'Initiated', 'Testing');
            Attorney_CreateOrUpdateNDSTaskHandler.CreateNDSAddLogEntry (taskList, TaskMap);
            set<Id> taskIds = new set<Id>();
            taskIds.add(Tsk.Id); 
        
            Map<Id,nu_dse__Program__c> progMap = new Map<Id,nu_dse__Program__c> ();
            progMap.put(Tsk.WhatId,pgm);
        
  //          Attorney_CreateOrUpdateNDSTaskHandler.AsynCallToNDSTask obj = new Attorney_CreateOrUpdateNDSTaskHandler.AsynCallToNDSTask (taskIds, progMap);
  //          String jobId = System.enqueueJob(obj);
        Test.stopTest ();
        }
    }
    
    @isTest static void HandlerTest3 () {
        Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        Profile p = [Select Id from Profile where name='System Administrator'];
        //TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey]
        User u = new User();
        u.Attorney_Admin__c = false;
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
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
            LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
            
        Task tsk = new Task ();
        List<Task> taskList = new List<Task>();
        Map<Id, Task> taskMap = new Map<Id,Task>();
        
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
            
        Portfolio__c p1 = new Portfolio__c();
        p1.Name = 'Royal';
        p1.Active_Status__c = true;
        insert p1;
            
        Test.startTest ();
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '4343';
            pgm.Program_Type__c = 'Royal';
        insert pgm;
        
        NDS_User_List__c NDSUser = new NDS_User_List__c();
        NDSUser.Email__c = 'test12387@test1234.com';
            NDSUser.User_Name__c = 'tes1234';
            //NDSUser.IsActive__c = true;
            NDSUser.First_Name__c = 'test';
            NDSUser.Last_Name__c = 'test';
        insert NDSUser;
        tsk.WhatId = pgm.Id;
        //tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.ActivityDate = Date.Today ();
        tsk.IsNote__c = true;
        tsk.Attorney__c = true;
            tsk.Description = 'Hi';
            tsk.UserName__c ='test1234';
            system.debug('testmethod insert');
        insert tsk;
        
        
        
        tsk = [SELECT WhatId, Task_ID__c,
                    Subject , Description , Attorney__c,
                    Subject__c , Priority , ActivityDate , isNote__c 
                    FROM Task WHERE ID =: tsk.ID ];
        taskList.add (tsk);
        Tsk.ActivityDate = Date.Today ().addDays (2);
        Tsk.Task_Id__c = '312';
        Tsk.Subject = 'Test2';
        tsk.Subject__c = '1099c on File';
        Tsk.Priority = 'Medium';
        Tsk.Description = 'Testing2';
        system.debug('testmethod update');
            Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = false;
            update tsk;
        system.debug('testmethod updated');
        nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
        taskType.TaskName__c = tsk.Subject__c ;
        taskType.TaskTypeId__c = '4';
        insert taskType;
        
        TaskMap.put (Tsk.id, Tsk);
            Attorney_StaticVariableUtility.apiUser = false;

            Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateNDSTaskHdlr.webserviceTaskTypeMock ());
            System.debug('testmethod createorupdate');
            Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
 //           Attorney_CreateOrUpdateNDSTaskHandler.CreateOrUpdateNDSTask (taskList, TaskMap);
            System.debug('testmethod integrationfields');
            //Attorney_CreateOrUpdateNDSTaskHandler.setIntegrationFields (Tsk, 'Initiated', 'Testing');
            System.debug('testmethod logentry');
            Attorney_CreateOrUpdateNDSTaskHandler.CreateNDSAddLogEntry (taskList, TaskMap);
            
        Test.stopTest ();
        }
    }
    
    @isTest static void HandlerTest4 () {
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
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'NDSPushCredentials';
        insert credentials;
        
            LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'LeadTrackCredentials';
        insert credentials1;
         
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
            
        Task tsk = new Task ();
        List<Task> taskList = new List<Task>();
        Map<Id, Task> taskMap = new Map<Id,Task>();
        
            Portfolio__c p1 = new Portfolio__c();
        p1.Name = 'Royal';
        p1.Active_Status__c = true;
        insert p1;
            
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
        Test.startTest ();
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.Attorney__c = TRUE;
        pgm.Import_ID__c = '1234';
            pgm.Program_Type__c = 'Royal';
        insert pgm;
        
        NDS_User_List__c NDSUser = new NDS_User_List__c();
        NDSUser.Email__c = 'test12387@test1234.com';
            NDSUser.User_Name__c = 'test1234';
            //NDSUser.IsActive__c = true;
            NDSUser.First_Name__c = 'test';
            NDSUser.Last_Name__c = 'test';
        insert NDSUser;
        tsk.WhatId = pgm.Id;
        //tsk.Task_Id__c = '1';
        tsk.Subject = 'Test';
        tsk.Description = 'Testing';
        tsk.Subject__c = 'Mark Account as Settled';
        tsk.Priority = 'High';
        tsk.ActivityDate = Date.Today ();
        tsk.nu_dse__Is_Noted__c = true;
        tsk.Attorney__c = true;
            tsk.Description = 'Hi';
            tsk.UserName__c ='test1234';
            //tsk.Task_Id__c = '1234';
            system.debug('testmethod insert');
        insert tsk;
        
        taskList.add(tsk);
            Attorney_CreateOrUpdateNDSTaskHandler.UpdateAttorneyFlag(TaskList, true, new Map<Id,Task>());
        
        tsk = [SELECT WhatId, Task_ID__c,
                    Subject , Description , Attorney__c,
                    Subject__c , Priority , ActivityDate , isNote__c 
                    FROM Task WHERE ID =: tsk.ID ];
        taskList.clear();
            taskList.add (tsk);
        Tsk.ActivityDate = Date.Today ().addDays (2);
        Tsk.Task_Id__c = '3345';
        Tsk.Subject = 'Test2';
        tsk.Subject__c = '1099c on File';
        Tsk.Priority = 'Medium';
        Tsk.Description = 'Testing2';
        system.debug('testmethod update');
        Attorney_StaticVariableUtility.isTaskTriggerExecuted = false;
            Attorney_StaticVariableUtility.isProgramTriggerExecuted = true;
            update tsk;
        system.debug('testmethod updated');
        nu_dse_Task_Type__c taskType = new nu_dse_Task_Type__c ();
        taskType.TaskName__c = tsk.Subject__c ;
        taskType.TaskTypeId__c = '4';
        insert taskType;
        
        TaskMap.put (Tsk.id, Tsk);
            Attorney_StaticVariableUtility.apiUser = false;

            Test.setMock (WebServiceMock.class, new Test_Attorney_CreateOrUpdateNDSTaskHdlr.webserviceTaskTypeMock ());
            Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
            Attorney_StaticVariableUtility.isGrpTaskTriggerExecuted = true;
            Attorney_CreateOrUpdateNDSTaskHandler.CreateNDSAddLogEntry (taskList, TaskMap);
        Test.stopTest ();
        }
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