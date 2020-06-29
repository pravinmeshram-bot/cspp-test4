@isTest
public class Test_Attorney_AsyncLeadtracNetDebt {
    
    @isTest static void testEchoString() {              
        
        Test.startTest ();
            Test.setMock (WebServiceMock.class, new Test_Attorney_AsyncLeadtracNetDebt.GetCreditorByVendorIdResponse_elementMock ());           
            AsyncLeadtracNetDebt.GetCreditorByVendorIdResponse_elementFuture creditbyvendorelement = new AsyncLeadtracNetDebt.GetCreditorByVendorIdResponse_elementFuture ();
            creditbyvendorelement.getValue ();
            
            Test.setMock (WebServiceMock.class, new Test_Attorney_AsyncLeadtracNetDebt.GetCreditorByVendorIdResponse_elementMock ());           
            AsyncLeadtracNetDebt.CreateOrUpdateDebtsResponse_elementFuture debtsrespeelement = new AsyncLeadtracNetDebt.CreateOrUpdateDebtsResponse_elementFuture();
            debtsrespeelement.getValue ();
            
            AsyncLeadtracNetDebt.GetCreditorResponse_elementFuture creditorrespelement= new AsyncLeadtracNetDebt.GetCreditorResponse_elementFuture ();
            creditorrespelement.getValue ();
            
            AsyncLeadtracNetDebt.GetLogEntriesResponse_elementFuture logentry = new AsyncLeadtracNetDebt.GetLogEntriesResponse_elementFuture ();
            logEntry.getValue ();
            
            AsyncLeadtracNetDebt.SetStatusAuditResponse_elementFuture statusaudresp = new AsyncLeadtracNetDebt.SetStatusAuditResponse_elementFuture ();
            statusaudresp.getValue ();
            
            AsyncLeadtracNetDebt.GetPlanHistoryResponse_elementFuture planhistresp = new AsyncLeadtracNetDebt.GetPlanHistoryResponse_elementFuture ();
            planhistresp.getValue ();
            
            AsyncLeadtracNetDebt.GetAccountStatusListResponse_elementFuture accntstatusresp = new AsyncLeadtracNetDebt.GetAccountStatusListResponse_elementFuture ();
            accntstatusresp.getValue ();
            
            AsyncLeadtracNetDebt.GetTasksResponse_elementFuture taskrespele = new AsyncLeadtracNetDebt.GetTasksResponse_elementFuture ();
            taskrespele.getValue ();
            
            AsyncLeadtracNetDebt.GetNegotiationStatusListResponse_elementFuture negotiatestatusresp = new AsyncLeadtracNetDebt.GetNegotiationStatusListResponse_elementFuture ();   
            negotiatestatusresp.getValue ();
            
            AsyncLeadtracNetDebt.GetModifiedDebtsResponse_elementFuture modifieddebtresp = new AsyncLeadtracNetDebt.GetModifiedDebtsResponse_elementFuture ();
            modifieddebtresp.getValue ();
            
            AsyncLeadtracNetDebt.GetDeletedDebtsResponse_elementFuture debtsRespElement = new AsyncLeadtracNetDebt.GetDeletedDebtsResponse_elementFuture();
            debtsRespElement.getValue ();
            
            AsyncLeadtracNetDebt.GetAllModifiedDebtsResponse_elementFuture modifiedDebtsRespElement = new AsyncLeadtracNetDebt.GetAllModifiedDebtsResponse_elementFuture ();
            modifiedDebtsRespElement.getValue ();
            
            AsyncLeadtracNetDebt.CreateOrUpdateCreditorResponse_elementFuture creditorRespElement1 = new AsyncLeadtracNetDebt.CreateOrUpdateCreditorResponse_elementFuture ();
            creditorRespElement1.getValue ();
            
            AsyncLeadtracNetDebt.CreateOrUpdateSettlementPaymentsResponse_elementFuture paymentRespElement = new AsyncLeadtracNetDebt.CreateOrUpdateSettlementPaymentsResponse_elementFuture ();
            paymentRespElement.getValue ();
            
            AsyncLeadtracNetDebt.LookupCreditorByVendorIdResponse_elementFuture vendorRespElement = new AsyncLeadtracNetDebt.LookupCreditorByVendorIdResponse_elementFuture();
            vendorRespElement.getValue ();
            
            AsyncLeadtracNetDebt.GetCreditorByNameResponse_elementFuture creditorNameRespElement = new AsyncLeadtracNetDebt.GetCreditorByNameResponse_elementFuture ();
            creditorNameRespElement.getValue ();
            
            AsyncLeadtracNetDebt.GetStatusAuditResponse_elementFuture auditorRespElement = new AsyncLeadtracNetDebt.GetStatusAuditResponse_elementFuture ();
            auditorRespElement.getValue ();
            
            AsyncLeadtracNetDebt.GetLogCategoriesResponse_elementFuture categoriesRespElement = new AsyncLeadtracNetDebt.GetLogCategoriesResponse_elementFuture ();
            categoriesRespElement.getValue ();
            
            AsyncLeadtracNetDebt.GetDebtStatusAuditResponse_elementFuture auditsRespElement = new AsyncLeadtracNetDebt.GetDebtStatusAuditResponse_elementFuture ();
            auditsRespElement.getValue ();
            
            AsyncLeadtracNetDebt.GetDebtsResponse_elementFuture debtsRespElement1 = new AsyncLeadtracNetDebt.GetDebtsResponse_elementFuture ();
            debtsRespElement1.getValue ();
            
            AsyncLeadtracNetDebt.AddLogEntryResponse_elementFuture logEntryElement = new AsyncLeadtracNetDebt.AddLogEntryResponse_elementFuture ();
            logEntryElement.getValue ();
            
            AsyncLeadtracNetDebt.GetAllModifiedDebtsListResponse_elementFuture debtsListRespElement1 = new AsyncLeadtracNetDebt.GetAllModifiedDebtsListResponse_elementFuture ();
            debtsListRespElement1.getValue ();
            
            System.Continuation continuation = new Continuation (10);
            AsyncLeadtracNetDebt.AsyncDebtServiceSoap obj = new AsyncLeadtracNetDebt.AsyncDebtServiceSoap ();
            obj.beginGetCreditorByVendorId (continuation, 'test', 'test', 'test', 'test');
            obj.beginCreateOrUpdateDebts (continuation, 'test', 'test', 'test', new leadtracNetDebt.ArrayOfDebt ());
            obj.beginGetCreditor (continuation, 'test', 'test', '1');
            obj.beginGetLogEntries (continuation, 'test', 'test', '1', 1, System.Now ());
            obj.beginSetStatusAudit (continuation, 'test', 'test',  1, new leadtracNetDebt.ArrayOfStatusAudit ());
            obj.beginGetPlanHistory (continuation, 'test', 'test',  '1', 1);
            obj.beginGetAccountStatusList (continuation, 'test', 'test');
            obj.beginGetTasks (continuation, 'test', 'test', 'test', System.Now (), System.Now (), 1);
            obj.beginGetNegotiationStatusList (continuation, 'test', 'test');
            obj.beginGetModifiedDebts (continuation, 'test', 'test', System.Now (), System.Now ());
            obj.beginGetDeletedDebts (continuation, 'test', 'test', 'test');
            obj.beginGetAllModifiedDebts (continuation, 'test', 'test', 'test', System.Now (), System.Now ());
            obj.beginCreateOrUpdateCreditor (continuation, 'test', 'test', New leadtracNetDebt.Creditor ());
            obj.beginCreateOrUpdateSettlementPayments (continuation, 'test', 'test', 'test', 1, new leadtracNetDebt.SettlementPlan ());
            obj.beginLookupCreditorByVendorId (continuation, 'test', 'test', 'test');
            obj.beginGetCreditorByName (continuation, 'test', 'test', 'test');
            obj.beginGetStatusAudit (continuation, 'test', 'test', 'test', 1);
            obj.beginGetLogCategories (continuation, 'test', 'test');
            obj.beginGetDebtStatusAudit (continuation, 'test', 'test', new leadtracNetDebt.ArrayOfLong ());
            obj.beginGetDebts (continuation, 'test', 'test', 'test');
            obj.beginAddLogEntry (continuation, 'test', 'test', 'test', 1, new leadtracNetDebt.LogEntry ());
            obj.beginGetAllModifiedDebtsList (continuation, 'test', 'test', new leadtracNetDebt.ArrayOfString (), System.Now (), System.Now ());
        Test.stopTest ();
        
        
    }
    
    public class CreateOrUpdateDebtsResponse_elementMock implements WebServiceMock {
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
           leadtracNetDebt.CreateOrUpdateDebtsResponse_element respElement = new leadtracNetDebt.CreateOrUpdateDebtsResponse_element ();
            
           respElement.CreateOrUpdateDebtsResult = new leadtracNetDebt.GetDebtsResult ();
           response.put('response_x', respElement);
           
        }
    }
    
    public class GetCreditorByVendorIdResponse_elementMock implements WebServiceMock {
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
           leadtracNetDebt.GetCreditorByVendorIdResponse_element respElement = new leadtracNetDebt.GetCreditorByVendorIdResponse_element();
           leadtracNetDebt.GetCreditorResult creditorResult = new leadtracNetDebt.GetCreditorResult (); 
           creditorResult.IsSuccessful = TRUE;
           creditorResult.Creditor = new leadtracNetDebt.Creditor ();
           creditorResult.Messages = new leadtracNetDebt.ArrayOfResultMessage ();
           respElement.GetCreditorByVendorIdResult = creditorResult;
           response.put('response_x', respElement);
           
        }
    }
}