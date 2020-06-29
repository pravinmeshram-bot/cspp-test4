@isTest
public class Test_Attorney_leadtracNetClient {
    static LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
    static void init () {
        
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        
    }
    @isTest static void webServiceTest () {
        init ();
        Test.startTest();
        
        clientWebservice ();
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.searchByStatus2Mock ());
        
        leadtracNetClient.ClientServiceSoap respElement = new leadtracNetClient.ClientServiceSoap ();
        respElement.SearchByStatusHistory ('test', 'test', '1', 1);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.clientsByPhoneNumber2Mock ());
        respElement.GetClientsByPhoneNumber ('test', 'test', '1234567890');
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetStatusListForWorkflowMock ());
        respElement.GetStatusListForWorkflow ('test', 'test', '1234567890');
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.CreateAppointmentMock ());
        respElement.CreateAppointment ('test', 'test', '1234567890', '1', null);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetScheduledAppointmentsMock ());
        respElement.GetScheduledAppointments ('test', 'test', '1234567890', DateTime.Now (), DateTime.Now ());
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.getClientsMock ());
        respElement.GetClients ('test', 'test', null, null);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.getClients2Mock ());
        respElement.GetClientsInStatusWithLimit ('test', 'test', 1, null, 1);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.SearchByStatusMock ());
        respElement.SearchByStatus ('test', 'test', 1);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.ChangeStatusByPropertyMock ());
        respElement.ChangeStatusByProperty ('test', 'test', 'test', null, 1);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetUpdatedClientsWithChangesMock ());
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetClientsInStatusMock ());
        respElement.GetClientsInStatus ('test', 'test', 1, null);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.CancelAppointmentMock ());
        respElement.CancelAppointment ('test', 'test', 'test', 1);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.ChangeClientStatusMock ());
        respElement.ChangeClientStatus('test', 'test', null, 1);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.AddLogEntryMock ());
        respElement.AddLogEntry ('test', 'test', 'test', null);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.SearchByStatusAuditMock ());
        respElement.SearchByStatusAudit ('test', 'test', 1, System.now (), System.Now ());
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetClientMock  ());
        respElement.GetClient ('test', 'test', '1', null);
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.SearchByPropertyMock  ());
        respElement.SearchByProperty ('test', 'test', '1', 'test');
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetUpdatedClientsMock  ());
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetLogEntriesMock  ());
        respElement.GetLogEntries ('test', 'test', 'test', System.Now (), System.now ());
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetTaskTypesMock  ());
        respElement.GetTaskTypes ('test', 'test');
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetTasksMock  ());
       respElement.GetTasks ('test', 'test', null, System.Now (), System.Now ());
  //m  respElement.GetTasks ('test', 'test', null);
        
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.ValidateFormsMock  ());
        respElement.ValidateForms ('test', 'test', 'test');
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.GetCampaignListMock  ());
        respElement.GetCampaignList ('test', 'test');
        
        Test.setMock (WebServiceMock.class, new Test_Attorney_leadtracNetClient.CreateTaskMock  ());
        respElement.CreateTask ('test', 'test', 1,  'Test',  'test', 'String', System.Now (), 1, 'test') ;
        try {
            respElement.AddNote ('test', 'test', 'String', System.Now (), 'test') ;
        } catch (Exception e) {}
        try {
            respElement.GetCompanyLogEntries ('test', 'test', System.now (), System.Now (), 1, null);
        } catch (Exception e) {}
        try {    
            respElement.ClearClientsFromQueue ('test', 'test', null);
        } catch (Exception e) {}
        try {    
            respElement.CreateOrUpdateTask ('test', 'test', null);
        } catch (Exception e) {}
        try {    
            respElement.GetClientsInQueue ('test', 'test', null);
        } catch (Exception e) {}
        try {   
            respElement.CreateOrUpdateClient ('test', 'test', 'test', null);
        } catch (Exception e) {}
        try {   
            respElement.GetLogCategories ('test', 'test');
        } catch (Exception e) {}
        try {    
            respElement.SearchByPhone ('test', 'test', 'test');
        } catch (Exception e) {}
        try {    
            respElement.GetStatusList ('test', 'test');
        } catch (Exception e) {}
        
        Test.stopTest();
    }
    public class CreateTaskMock implements WebServiceMock {
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
                leadtracNetClient.CreateTaskResponse_element respElement = new leadtracNetClient.CreateTaskResponse_element ();
                respElement.CreateTaskResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetCampaignListMock implements WebServiceMock {
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
                leadtracNetClient.GetCampaignListResponse_element respElement = new leadtracNetClient.GetCampaignListResponse_element ();
                respElement.GetCampaignListResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class ValidateFormsMock implements WebServiceMock {
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
                leadtracNetClient.ValidateFormsResponse_element respElement = new leadtracNetClient.ValidateFormsResponse_element ();
                respElement.ValidateFormsResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetTasksMock implements WebServiceMock {
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
                leadtracNetClient.GetTasksResponse_element respElement = new leadtracNetClient.GetTasksResponse_element ();
                respElement.GetTasksResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetTaskTypesMock implements WebServiceMock {
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
                leadtracNetClient.GetTaskTypesResponse_element respElement = new leadtracNetClient.GetTaskTypesResponse_element ();
                respElement.GetTaskTypesResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class GetLogEntriesMock implements WebServiceMock {
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
                leadtracNetClient.GetLogEntriesResponse_element respElement = new leadtracNetClient.GetLogEntriesResponse_element ();
                respElement.GetLogEntriesResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetUpdatedClientsMock implements WebServiceMock {
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
                leadtracNetClient.GetUpdatedClientsResponse_element respElement = new leadtracNetClient.GetUpdatedClientsResponse_element ();
                respElement.GetUpdatedClientsResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class SearchByPropertyMock implements WebServiceMock {
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
                leadtracNetClient.SearchByPropertyResponse_element respElement = new leadtracNetClient.SearchByPropertyResponse_element ();
                respElement.SearchByPropertyResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class GetClientMock implements WebServiceMock {
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
                leadtracNetClient.GetClientResponse_element respElement = new leadtracNetClient.GetClientResponse_element ();
                respElement.GetClientResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class SearchByStatusAuditMock implements WebServiceMock {
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
                leadtracNetClient.SearchByStatusAuditResponse_element respElement = new leadtracNetClient.SearchByStatusAuditResponse_element ();
                respElement.SearchByStatusAuditResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class AddLogEntryMock  implements WebServiceMock {
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
                leadtracNetClient.AddLogEntryResponse_element respElement = new leadtracNetClient.AddLogEntryResponse_element ();
                respElement.AddLogEntryResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class ChangeClientStatusMock  implements WebServiceMock {
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
                leadtracNetClient.ChangeClientStatusResponse_element respElement = new leadtracNetClient.ChangeClientStatusResponse_element ();
                respElement.ChangeClientStatusResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class CancelAppointmentMock implements WebServiceMock {
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
                leadtracNetClient.CancelAppointmentResponse_element respElement = new leadtracNetClient.CancelAppointmentResponse_element ();
                respElement.CancelAppointmentResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetClientsInStatusMock implements WebServiceMock {
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
                leadtracNetClient.GetClientsInStatusResponse_element respElement = new leadtracNetClient.GetClientsInStatusResponse_element ();
                respElement.GetClientsInStatusResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetUpdatedClientsWithChangesMock implements WebServiceMock {
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
                leadtracNetClient.GetUpdatedClientsWithChangesResponse_element respElement = new leadtracNetClient.GetUpdatedClientsWithChangesResponse_element ();
                respElement.GetUpdatedClientsWithChangesResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class ChangeStatusByPropertyMock implements WebServiceMock {
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
                leadtracNetClient.ChangeStatusByPropertyResponse_element respElement = new leadtracNetClient.ChangeStatusByPropertyResponse_element ();
                respElement.ChangeStatusByPropertyResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetPropertyListMock implements WebServiceMock {
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
                leadtracNetClient.GetPropertyListResponse_element respElement = new leadtracNetClient.GetPropertyListResponse_element ();
                respElement.GetPropertyListResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class SearchByStatusMock implements WebServiceMock {
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
                leadtracNetClient.SearchByStatusResponse_element respElement = new leadtracNetClient.SearchByStatusResponse_element ();
                respElement.SearchByStatusResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class getClients2Mock implements WebServiceMock {
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
                leadtracNetClient.GetClientsInStatusWithLimitResponse_element respElement = new leadtracNetClient.GetClientsInStatusWithLimitResponse_element ();
                respElement.GetClientsInStatusWithLimitResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class getClientsMock implements WebServiceMock {
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
                leadtracNetClient.GetClientsResponse_element respElement = new leadtracNetClient.GetClientsResponse_element ();
                respElement.GetClientsResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class GetScheduledAppointmentsMock implements WebServiceMock {
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
                leadtracNetClient.GetScheduledAppointmentsResponse_element respElement = new leadtracNetClient.GetScheduledAppointmentsResponse_element ();
                respElement.GetScheduledAppointmentsResult = null;
                response.put('response_x', respElement);
                
            }
    }
    
    public class CreateAppointmentMock implements WebServiceMock {
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
                leadtracNetClient.CreateAppointmentResponse_element respElement = new leadtracNetClient.CreateAppointmentResponse_element ();
                respElement.CreateAppointmentResult = null;
                response.put('response_x', respElement);
                
            }
    }
    public class searchByStatus2Mock implements WebServiceMock {
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
                leadtracNetClient.SearchByStatusHistoryResponse_element respElement = new leadtracNetClient.SearchByStatusHistoryResponse_element ();
                respElement.SearchByStatusHistoryResult = DateTime.Now ();
                response.put('response_x', respElement);
                
            }
    }
    public class clientsByPhoneNumber2Mock implements WebServiceMock {
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
                leadtracNetClient.GetClientsByPhoneNumberResponse_element respElement = new leadtracNetClient.GetClientsByPhoneNumberResponse_element ();
                respElement.GetClientsByPhoneNumberResult = new leadtracNetClient.GetClientsByPhoneNumberResult ();
                response.put('response_x', respElement); 
                
            }
    }
    public class GetStatusListForWorkflowMock implements WebServiceMock {
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
                leadtracNetClient.GetStatusListForWorkflowResponse_element respElement = new leadtracNetClient.GetStatusListForWorkflowResponse_element ();
                respElement.GetStatusListForWorkflowResult = new leadtracNetClient.ArrayOfStatusItem ();
                response.put('response_x', respElement); 
                
            }
    }
    
    static void clientWebservice () {
        
        leadtracNetClient.Appointment obj = new leadtracNetClient.Appointment ();
        leadtracNetClient.ChangeStatusByPropertyResponse_element element = new leadtracNetClient.ChangeStatusByPropertyResponse_element ();
        leadtracNetClient.ArrayOfAsset assetArray = new leadtracNetClient.ArrayOfAsset ();
        leadtracNetClient.ArrayOfLogEntry ArrayOfLogEntry = new leadtracNetClient.ArrayOfLogEntry ();
        leadtracNetClient.ChangeClientStatusResponse_element clientStatus = new leadtracNetClient.ChangeClientStatusResponse_element ();
        leadtracNetClient.ClientAssignee ClientAssignee = new leadtracNetClient.ClientAssignee ();
        leadtracNetClient.GetClientsInStatusResponse_element statusResponse = new leadtracNetClient.GetClientsInStatusResponse_element ();
        leadtracNetClient.GetClientsInStatusWithLimitResponse_element statusElementResponse = new leadtracNetClient.GetClientsInStatusWithLimitResponse_element ();
        leadtracNetClient.GetCampaignList_element campaignElement = new leadtracNetClient.GetCampaignList_element ();
        leadtracNetClient.TaskType TaskType = new leadtracNetClient.TaskType ();
        leadtracNetClient.Asset Asset = new leadtracNetClient.Asset ();
        leadtracNetClient.GetStatusListForWorkflowResponse_element workFlowresponse = new leadtracNetClient.GetStatusListForWorkflowResponse_element ();
        leadtracNetClient.AddLogEntryResponse_element logEntryResponse = new leadtracNetClient.AddLogEntryResponse_element ();
        leadtracNetClient.GetScheduledAppointments_element appointmentResponse = new leadtracNetClient.GetScheduledAppointments_element ();
        leadtracNetClient.GetPropertyListResponse_element listResponse = new leadtracNetClient.GetPropertyListResponse_element ();
        leadtracNetClient.TaskTypeResult TaskTypeResult = new leadtracNetClient.TaskTypeResult ();
        leadtracNetClient.GetClientsByPhoneNumberResponse_element phoneResponse = new leadtracNetClient.GetClientsByPhoneNumberResponse_element ();
        leadtracNetClient.CreateTaskResponse_element taskResponse = new leadtracNetClient.CreateTaskResponse_element ();
        leadtracNetClient.GetClientsInStatus_element statusclientsResponse = new leadtracNetClient.GetClientsInStatus_element ();
        leadtracNetClient.CreateAppointmentResponse_element appointmentElementResponse = new leadtracNetClient.CreateAppointmentResponse_element ();
        leadtracNetClient.GetLogEntries_element logEntries = new leadtracNetClient.GetLogEntries_element ();
        leadtracNetClient.GetStatusListForWorkflow_element workFlowElement = new leadtracNetClient.GetStatusListForWorkflow_element ();
        leadtracNetClient.ClientProperty propertyResponse = new leadtracNetClient.ClientProperty ();
        leadtracNetClient.CreateOrUpdateClient_element clientResponse = new leadtracNetClient.CreateOrUpdateClient_element ();
        leadtracNetClient.GetLogEntriesResult GetLogEntriesResultResponse = new leadtracNetClient.GetLogEntriesResult ();
        leadtracNetClient.CreateAppointment_element appointmentEleResponse = new leadtracNetClient.CreateAppointment_element ();
        leadtracNetClient.SearchByStatus_element searchElement = new leadtracNetClient.SearchByStatus_element ();
        leadtracNetClient.CancelAppointmentResponse_element cancelAppointmentElement = new leadtracNetClient.CancelAppointmentResponse_element ();
        leadtracNetClient.SearchByStatusAuditResponse_element auditElement = new leadtracNetClient.SearchByStatusAuditResponse_element ();
        leadtracNetClient.SearchByStatusResponse_element auditResponsementElement = new leadtracNetClient.SearchByStatusResponse_element ();
        leadtracNetClient.ArrayOfClientAssignee ArrayOfClientAssignee = new leadtracNetClient.ArrayOfClientAssignee ();
        leadtracNetClient.AddNote_element AddNote_element = new leadtracNetClient.AddNote_element ();
        leadtracNetClient.GetUpdatedClients_element GetUpdatedClients_element = new leadtracNetClient.GetUpdatedClients_element ();
        leadtracNetClient.LogCategory LogCategory = new leadtracNetClient.LogCategory ();
        leadtracNetClient.GetTaskTypesResponse_element GetTaskTypesResponse_element = new leadtracNetClient.GetTaskTypesResponse_element ();
        leadtracNetClient.ArrayOfTask ArrayOfTask = new leadtracNetClient.ArrayOfTask ();
        leadtracNetClient.ResultMessage ResultMessage = new leadtracNetClient.ResultMessage ();
        leadtracNetClient.GetClientsInQueueResponse_element GetClientsInQueueResponse_element = new leadtracNetClient.GetClientsInQueueResponse_element ();
        leadtracNetClient.CancelAppointment_element CancelAppointment_element = new leadtracNetClient.CancelAppointment_element ();
        leadtracNetClient.GetScheduledAppointmentsResult GetScheduledAppointmentsResult = new leadtracNetClient.GetScheduledAppointmentsResult ();
        leadtracNetClient.ArrayOfClientStatus ArrayOfClientStatus = new leadtracNetClient.ArrayOfClientStatus ();
        leadtracNetClient.ValidateForms_element ValidateForms_element = new leadtracNetClient.ValidateForms_element ();
        leadtracNetClient.GetUpdatedClientsResponse_element GetUpdatedClientsResponse_element = new leadtracNetClient.GetUpdatedClientsResponse_element ();
        leadtracNetClient.GetCompanyLogEntriesResponse_element GetCompanyLogEntriesResponse_element = new leadtracNetClient.GetCompanyLogEntriesResponse_element ();
        leadtracNetClient.ArrayOfStatusItem ArrayOfStatusItem = new leadtracNetClient.ArrayOfStatusItem ();
        leadtracNetClient.GetClientsByPhoneNumber_element GetClientsByPhoneNumber_element = new leadtracNetClient.GetClientsByPhoneNumber_element ();
        leadtracNetClient.GetClientResponse_element GetClientResponse_element = new leadtracNetClient.GetClientResponse_element ();
        leadtracNetClient.Task Taskelement = new leadtracNetClient.Task ();
        leadtracNetClient.SearchByStatusAudit_element SearchByStatusAudit_element = new leadtracNetClient.SearchByStatusAudit_element ();
        leadtracNetClient.ArrayOfCampaign ArrayOfCampaign = new leadtracNetClient.ArrayOfCampaign ();
        leadtracNetClient.GetClients_element GetClients_element = new leadtracNetClient.GetClients_element ();
        leadtracNetClient.GetClientsResponse_element GetClientsResponse_element = new leadtracNetClient.GetClientsResponse_element ();
        leadtracNetClient.Result Result = new leadtracNetClient.Result ();
        leadtracNetClient.GetClientsInStatusWithLimit_element  GetClientsInStatusWithLimit_element = new leadtracNetClient.GetClientsInStatusWithLimit_element ();
        leadtracNetClient.GetScheduledAppointmentsResponse_element GetScheduledAppointmentsResponse_element = new leadtracNetClient.GetScheduledAppointmentsResponse_element ();
        leadtracNetClient.GetCampaignListResponse_element GetCampaignListResponse_element = new leadtracNetClient.GetCampaignListResponse_element ();
        leadtracNetClient.Client Client = new leadtracNetClient.Client ();
        leadtracNetClient.SearchByStatusHistory_element SearchByStatusHistory_element = new leadtracNetClient.SearchByStatusHistory_element ();
        leadtracNetClient.LogCategoryResult LogCategoryResult = new leadtracNetClient.LogCategoryResult ();
        leadtracNetClient.AppointmentReservationResult AppointmentReservationResult = new leadtracNetClient.AppointmentReservationResult ();
        leadtracNetClient.GetPropertyList_element GetPropertyList_element = new leadtracNetClient.GetPropertyList_element ();
        leadtracNetClient.SearchByProperty_element SearchByProperty_element = new leadtracNetClient.SearchByProperty_element ();
        leadtracNetClient.GetStatusListResponse_element GetStatusListResponse_element = new leadtracNetClient.GetStatusListResponse_element ();
        leadtracNetClient.ArrayOfLogCategory ArrayOfLogCategory = new leadtracNetClient.ArrayOfLogCategory ();
        leadtracNetClient.GetLogCategories_element GetLogCategories_element = new leadtracNetClient.GetLogCategories_element ();
        leadtracNetClient.ArrayOfResultMessage ArrayOfResultMessage = new leadtracNetClient.ArrayOfResultMessage ();
        leadtracNetClient.GetTaskTypes_element GetTaskTypes_element = new leadtracNetClient.GetTaskTypes_element ();
        leadtracNetClient.SearchByStatusHistoryResponse_element SearchByStatusHistoryResponse_element = new leadtracNetClient.SearchByStatusHistoryResponse_element ();
        leadtracNetClient.Campaign Campaign = new leadtracNetClient.Campaign ();
        leadtracNetClient.GetClientsByPhoneNumberResult GetClientsByPhoneNumberResult = new leadtracNetClient.GetClientsByPhoneNumberResult ();
        leadtracNetClient.ArrayOfClientProperty ArrayOfClientProperty = new leadtracNetClient.ArrayOfClientProperty ();
        leadtracNetClient.SearchByPhone_element SearchByPhone_element = new leadtracNetClient.SearchByPhone_element ();
        leadtracNetClient.AppointmentReservation AppointmentReservation = new leadtracNetClient.AppointmentReservation ();
        leadtracNetClient.GetLogEntriesResponse_element GetLogEntriesResponse_element = new leadtracNetClient.GetLogEntriesResponse_element ();
        leadtracNetClient.GetTasks_element GetTasks_element = new leadtracNetClient.GetTasks_element ();
        leadtracNetClient.GetLogCategoriesResponse_element GetLogCategoriesResponse_element = new leadtracNetClient.GetLogCategoriesResponse_element ();
        leadtracNetClient.SearchByPhoneResponse_element SearchByPhoneResponse_element = new leadtracNetClient.SearchByPhoneResponse_element ();
        leadtracNetClient.CreateTask_element CreateTask_element = new leadtracNetClient.CreateTask_element ();
        leadtracNetClient.ArrayOfClient ArrayOfClient = new leadtracNetClient.ArrayOfClient ();
        leadtracNetClient.StatusItem StatusItem = new leadtracNetClient.StatusItem ();
        leadtracNetClient.CreateOrUpdateClientResponse_element CreateOrUpdateClientResponse_element = new leadtracNetClient.CreateOrUpdateClientResponse_element ();
        leadtracNetClient.ChangeStatusByProperty_element ChangeStatusByProperty_element = new leadtracNetClient.ChangeStatusByProperty_element ();
        leadtracNetClient.GetClient_element GetClient_element = new leadtracNetClient.GetClient_element ();
        leadtracNetClient.GetClientsInQueue_element GetClientsInQueue_element = new leadtracNetClient.GetClientsInQueue_element ();
        leadtracNetClient.LogEntry LogEntry = new leadtracNetClient.LogEntry ();
        leadtracNetClient.ArrayOfAppointment ArrayOfAppointment = new leadtracNetClient.ArrayOfAppointment ();
        leadtracNetClient.GetCompanyLogEntries_element GetCompanyLogEntries_element = new leadtracNetClient.GetCompanyLogEntries_element  ();
        leadtracNetClient.ValidateFormsResponse_element ValidateFormsResponse_element = new leadtracNetClient.ValidateFormsResponse_element ();
        leadtracNetClient.AddLogEntry_element AddLogEntry_element = new leadtracNetClient.AddLogEntry_element ();
        leadtracNetClient.ClientStatus ClientStatusVal = new leadtracNetClient.ClientStatus ();
        leadtracNetClient.ClearClientsFromQueueResponse_element ClearClientsFromQueueResponse_element = new leadtracNetClient.ClearClientsFromQueueResponse_element ();
        leadtracNetClient.GetStatusList_element GetStatusList_element = new leadtracNetClient.GetStatusList_element ();
        leadtracNetClient.AddNoteResponse_element AddNoteResponse_element = new leadtracNetClient.AddNoteResponse_element ();
        leadtracNetClient.ClearClientsFromQueue_element ClearClientsFromQueue_element = new leadtracNetClient.ClearClientsFromQueue_element ();
        leadtracNetClient.GetTasksResponse_element GetTasksResponse_element = new leadtracNetClient.GetTasksResponse_element ();
        leadtracNetClient.GetTaskResult GetTaskResult = new leadtracNetClient.GetTaskResult ();
        leadtracNetClient.ArrayOfString ArrayOfString = new leadtracNetClient.ArrayOfString ();
        leadtracNetClient.SearchByPropertyResponse_element SearchByPropertyResponse_element = new leadtracNetClient.SearchByPropertyResponse_element ();
        leadtracNetClient.ChangeClientStatus_element ChangeClientStatus_element = new leadtracNetClient.ChangeClientStatus_element  ();
        leadtracNetClient.ArrayOfTaskType ArrayOfTaskType = new leadtracNetClient.ArrayOfTaskType ();
        leadtracNetClient.GetUpdatedClientsWithChangesResponse_element GetUpdatedClients = new leadtracNetClient.GetUpdatedClientsWithChangesResponse_element ();
        leadtracNetClient.CreateOrUpdateTaskResponse_element TaskRespResult = new leadtracNetClient.CreateOrUpdateTaskResponse_element ();
        leadtracNetClient.GetUpdatedClientsWithChanges_element TaskUpdatedResult = new leadtracNetClient.GetUpdatedClientsWithChanges_element ();
        leadtracNetClient.ArrayOfUpdatedClient TaskArrayResult = new leadtracNetClient.ArrayOfUpdatedClient();
        leadtracNetClient.CreateOrUpdateTask_element CreateTaskResult = new leadtracNetClient.CreateOrUpdateTask_element ();
        leadtracNetClient.ArrayOfTaskResult ArrayTaskResult = new leadtracNetClient.ArrayOfTaskResult ();
        leadtracNetClient.UpdatedClient UpdatedClient = new leadtracNetClient.UpdatedClient ();
        leadtracNetClient.TaskResult TaskResult = new leadtracNetClient.TaskResult ();
        leadtracNetClient.UpdateTasksResult UpdateTasksResult = new leadtracNetClient.UpdateTasksResult ();
        leadtracNetClient.GetUpdatedClientsResult GetUpdatedClientsResult = new leadtracNetClient.GetUpdatedClientsResult ();
    }
}