@isTest
public class Test_Attorney_CreateOrUpdateNDSWrkFlow {
    
    public static testmethod void testMethod1(){
        
        User u1 = new User();
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
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'NDSPushCredentials';
        insert credentials1;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        insert batchJobTimings;
        
        Account acc = new Account ();
        acc.Name = 'Test';
        acc.NDS_File_Number__c = '1234';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c ();
        program.Import_ID__c = '1234';
        program.nu_dse__Account__c = acc.Id;
        program.Attorney__c= true;
        insert program;
        
        System.runAs(u1){
            Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSWrkFlow.LeadTraceNetClineMock());
            Attorney_StaticVariableUtility.apiuser = false;
            WorkFlow__c workFlowRec = new WorkFlow__c ();
            workFlowRec.FileNumber__c = '1234';
            workFLowRec.Program__c = program.id;
            workFlowRec.Name = 'Test';
            workFlowRec.Workflow_Status__c = 'Test';
            
            insert workFlowRec;
        }
    }
    
    public static testmethod void testMethod2(){
        
        User u1 = new User();
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
        
        LeadTracCredentials__c credentials1 = new LeadTracCredentials__c ();
        credentials1.ClientEndPointURL__c = 'www.test.com';
        credentials1.DebtEndPointURL__c = 'www.test.com';
        credentials1.EndpointURL__c = 'www.test.com';
        credentials1.PaymentEndPointURL__c = 'www.test.com';
        credentials1.Password__c = 'testing';
        credentials1.UserName__c = 'Testing';
        credentials1.Name = 'NDSPushCredentials';
        insert credentials1;
        
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        insert batchJobTimings;
        
        Account acc = new Account ();
        acc.Name = 'Test';
        acc.NDS_File_Number__c = '1234';
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c ();
        program.Import_ID__c = '1234';
        program.nu_dse__Account__c = acc.Id;
        program.Attorney__c= true;
        insert program;
        
        System.runAs(u1){
            //Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSWrkFlow.LeadTraceNetClineMock());
            Attorney_StaticVariableUtility.apiuser = false;
            WorkFlow__c workFlowRec = new WorkFlow__c ();
            workFlowRec.FileNumber__c = '1234';
            workFLowRec.Program__c = program.id;
            workFlowRec.Name = 'Test';
            workFlowRec.Workflow_Status__c = 'Test';
            
            insert workFlowRec;
        }
    }
    
    public without sharing class LeadTraceNetClineMock implements WebServiceMock{
        
        public void doInvoke(Object stub,Object request_x,Map<String,Object> response,String endpoint,
                             String soapAction,
                             String requestName,
                             String responseNS,
                             String responseName,
                             String responseType)
        {
            /*   leadtracNetClient.StatusItem si= new leadtracNetClient.StatusItem();
si.WorkflowId = '1234';
si.Name = 'Test';
si.StatusId = long.valueOf('123');
leadtracNetClient.StatusItem[] StatusItemList = new List<leadtracNetClient.StatusItem>();
leadtracNetClient.ArrayOfStatusItem workFlowResult = new leadtracNetClient.ArrayOfStatusItem();
workFlowResult.StatusItem=StatusItemList;
leadtracNetClient.GetStatusListForWorkflowResponse_element respElement =new leadtracNetClient.GetStatusListForWorkflowResponse_element();
respElement.GetStatusListForWorkflowResult = workFlowResult;
response.put('response_x', respElement);
*/ 
            if(soapAction.endsWithIgnoreCase('GetStatusList')){
                leadtracNetClient.StatusItem si= new leadtracNetClient.StatusItem();
                si.WorkflowId = '1234';
                si.WorkflowName = 'Test';
                si.Name = 'Test';
                si.StatusId = long.valueOf('123');
                leadtracNetClient.StatusItem[] StatusItemList = new List<leadtracNetClient.StatusItem>();
                StatusItemList.add(si);
                leadtracNetClient.ArrayOfStatusItem workFlowResult = new leadtracNetClient.ArrayOfStatusItem();
                workFlowResult.StatusItem=StatusItemList;
                leadtracNetClient.GetStatusListResponse_element respElement =new leadtracNetClient.GetStatusListResponse_element();
                respElement.GetStatusListResult = workFlowResult;
                response.put('response_x', respElement);
            }
            else if(soapAction.endsWithIgnoreCase('ChangeClientStatus')){
                leadtracNetClient.ChangeClientStatusResponse_element respElement =new leadtracNetClient.ChangeClientStatusResponse_element();
                respElement.ChangeClientStatusResult = 'Success';
                response.put('response_x', respElement);
            }
        }
    }
}