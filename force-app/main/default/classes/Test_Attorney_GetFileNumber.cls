@isTest
public class Test_Attorney_GetFileNumber {
    
    @testSetup
    static void createData(){
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        FileNumberData__c file1 = new FileNumberData__c();
        file1.Completed__c = false;
        file1.Name = '1234';
        file1.Type__c = 'Draft';
        insert file1;
        
        FileNumberData__c file2 = new FileNumberData__c();
        file2.Completed__c = false;
        file2.Name = '1235';
        file2.Type__c = 'Client';
        insert file2;
        
        FileNumberData__c file3 = new FileNumberData__c();
        file3.Completed__c = false;
        file3.Name = '1236';
        file3.Type__c = 'Debt';
        insert file3;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchJobTimings.Load_clients__c = true;
        batchJobTimings.Load_Draft_Payments__c = true;
        batchJobTimings.Load_TradeLines__c = true;
        insert batchJobTimings;
        
        nu_dse__Program__c program = new nu_dse__Program__c ();
        program.Import_ID__c = '1234';
        insert program;
        
        nu_dse__Bank_Account__c bankAcc = new nu_dse__Bank_Account__c ();
        bankAcc.Import_ID__c = '1234';
        insert bankAcc;
        
        WorkFlow__c workFlowRec = new WorkFlow__c ();
        workFlowRec.FileNumber__c = '1234';
        insert workFlowRec;
        
        nu_dse__Group_Task__c grouptask = new nu_dse__Group_Task__c ();
        groupTask.FileNumber__c = '1234';
        groupTask.Subject_Picklist__c = '1099c on File';
        insert groupTask;
        
        Task taskRec = new Task ();
        taskRec.FileNumber__c = '1234';
        taskRec.subject = 'test';
        insert taskRec;
        
        Account acc = new Account ();
        acc.Name = 'Test';
        
        acc.NDS_File_Number__c = '1234';
        
        insert acc;
        
        
        
    }
    
    @isTest
    static void getFileNumberTest(){
        System_Log__c sysLog = new System_Log__c();
        sysLog.Category__c = 'File'; 
        sysLog.Start_Time__c = system.now()-1;
        sysLog.End_Time__c  = system.now();
        sysLog.Batch_Start__c = system.now();
        Insert sysLog;
        Test.startTest();
        Attorney_GetFileNumber.getLeadtrackProgramLst(true);
        Attorney_StaticVariableUtility.apiUser = false;
        Test.setMock (WebServiceMock.class, new Test_Attorney_GetFileNumber.webserviceClientsMock ());
        
        Attorney_GetFileNumber.getFileNumbers(System.now()-1, System.now(), SysLog.Id, null,true);
        Test.stopTest();
    }
    
    @isTest
    static void getFileNumberTest1(){
        System_Log__c sysLog = new System_Log__c();
        sysLog.Category__c = 'File'; 
        sysLog.Start_Time__c = system.now()-1;
        sysLog.End_Time__c  = system.now();
        sysLog.Batch_Start__c = system.now();
        Insert sysLog;
        Test.startTest();
        Attorney_GetFileNumber.getLeadtrackProgramLst(true);
        Attorney_StaticVariableUtility.apiUser = false;
        Attorney_GetFileNumber.getFileNumbers(System.now()-1, System.now(), SysLog.Id, null,true);
        Test.stopTest();
    }
    
    public class webserviceClientsMock implements WebServiceMock {
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
                if(soapAction.endsWith('GetUpdatedClients')){  
                    /*leadtracNetClient.GetUpdatedClientsResult result = new leadtracNetClient.GetUpdatedClientsResult ();
LeadtracNetClient.ArrayOfResultMessage messageArray = new LeadtracNetClient.ArrayOfResultMessage ();
List <leadtracNetClient.ResultMessage> messageList = new List <leadtracNetClient.ResultMessage> ();


leadtracNetClient.ArrayOfUpdatedClient clientArray = new leadtracNetClient.ArrayOfUpdatedClient ();
List <leadtracNetClient.UpdatedClient> updatedClients = new List <leadtracNetClient.UpdatedClient> ();
leadtracNetClient.UpdatedClient updatedClient = new leadtracNetClient.UpdatedClient ();
updatedClient.fileNumber = '1234';

leadtracNetClient.UpdatedClient updatedClient1 = new leadtracNetClient.UpdatedClient ();
updatedClient1.fileNumber = '1235';

leadtracNetClient.UpdatedClient updatedClient2 = new leadtracNetClient.UpdatedClient ();
updatedClient2.fileNumber = '1236';

updatedClients.add (updatedClient);
updatedClients.add (updatedClient1);
updatedClients.add (updatedClient2);

clientArray.UpdatedClient = updatedClients;
result.UpdatedClients = clientArray;*/
                    
                    LeadtracNetClient.ArrayOfString result1 = new LeadtracNetClient.ArrayOfString();
                    result1.string_x = new String[]{'1234','1235','1236'};
                        
                        LeadtracNetClient.GetUpdatedClientsResponse_element respElement = new LeadtracNetClient.GetUpdatedClientsResponse_element ();
                    respElement.GetUpdatedClientsResult =  result1;
                    response.put('response_x', respElement);
                    
                }
                if(soapAction.endsWith('GetModifiedDebts')){  
                    leadtracNetDebt.ModifiedDebtsResult result = new leadtracNetDebt.ModifiedDebtsResult();    
                    result.isSuccessful = 'Successful';
                    
                    leadtracNetDebt.ArrayOfModifiedDebt modifiedDebtArray =new leadtracNetDebt.ArrayOfModifiedDebt();
                    leadtracNetDebt.ModifiedDebt[] modifiedDebts = new leadtracNetDebt.ModifiedDebt[]{};
                    
                    leadtracNetDebt.ModifiedDebt modifiedDebt3 = new leadtracNetDebt.ModifiedDebt();
                    modifiedDebt3.fileNumber = '1234';
                    modifiedDebts.add(modifiedDebt3);
                    
                    leadtracNetDebt.ModifiedDebt modifiedDebt1 = new leadtracNetDebt.ModifiedDebt();
                    modifiedDebt1.fileNumber = '1235';
                    modifiedDebts.add(modifiedDebt1);
                    
                    leadtracNetDebt.ModifiedDebt modifiedDebt2 = new leadtracNetDebt.ModifiedDebt();
                    modifiedDebt2.fileNumber = '1236';
                    modifiedDebts.add(modifiedDebt2);
                    
                    
                    
                    modifiedDebtArray.ModifiedDebt = modifiedDebts;
                    result.modifiedDebts= modifiedDebtArray;
                    LeadtracNetDebt.GetModifiedDebtsResponse_element respElement = new LeadtracNetDebt.GetModifiedDebtsResponse_element ();
                    respElement.GetModifiedDebtsResult =  result;
                    response.put('response_x', respElement);
                    
                }
            }
        
        
    }
}