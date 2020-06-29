@isTest
public class Test_Attorney_AsyncLeadtracNetServicing {
    
    @isTest static void testEchoString() {              
        
        Test.startTest ();
            AsyncLeadtracNetServicing.GetDraftSplitListResponse_elementFuture creditbyvendorelement = new AsyncLeadtracNetServicing.GetDraftSplitListResponse_elementFuture ();
            creditbyvendorelement.getValue ();
            
            AsyncLeadtracNetServicing.GetActiveDraftPlanResponse_elementFuture debtsrespeelement = new AsyncLeadtracNetServicing.GetActiveDraftPlanResponse_elementFuture();
            debtsrespeelement.getValue ();
            
            AsyncLeadtracNetServicing.CreateOrUpdateDraftPlanResponse_elementFuture creditorrespelement= new AsyncLeadtracNetServicing.CreateOrUpdateDraftPlanResponse_elementFuture();
            creditorrespelement.getValue ();
            
            AsyncLeadtracNetServicing.GetDraftsResponse_elementFuture logentry = new AsyncLeadtracNetServicing.GetDraftsResponse_elementFuture ();
            logEntry.getValue ();
            
            AsyncLeadtracNetServicing.SetDraftStatusResponse_elementFuture statusaudresp = new AsyncLeadtracNetServicing.SetDraftStatusResponse_elementFuture ();
            statusaudresp.getValue ();
            
            AsyncLeadtracNetServicing.GetActiveDraftPlansResponse_elementFuture planhistresp = new AsyncLeadtracNetServicing.GetActiveDraftPlansResponse_elementFuture ();
            planhistresp.getValue ();
            
            AsyncLeadtracNetServicing.GetDraftsByFileResponse_elementFuture accntstatusresp = new AsyncLeadtracNetServicing.GetDraftsByFileResponse_elementFuture ();
            accntstatusresp.getValue ();
            
            AsyncLeadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_elementFuture taskrespele = new AsyncLeadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_elementFuture ();
            taskrespele.getValue ();
            
            AsyncLeadtracNetServicing.GetModifiedDraftPlansResponse_elementFuture negotiatestatusresp = new AsyncLeadtracNetServicing.GetModifiedDraftPlansResponse_elementFuture ();   
            negotiatestatusresp.getValue ();
            
            AsyncLeadtracNetServicing.CreateOrUpdateDraftPaymentResponse_elementFuture modifieddebtresp = new AsyncLeadtracNetServicing.CreateOrUpdateDraftPaymentResponse_elementFuture ();
            modifieddebtresp.getValue ();
            
            AsyncLeadtracNetServicing.GetTrustAccountDetailsResponse_elementFuture debtsRespElement = new AsyncLeadtracNetServicing.GetTrustAccountDetailsResponse_elementFuture ();
            debtsRespElement.getValue ();
            System.Continuation continuation = new Continuation (10);
            AsyncLeadtracNetServicing.AsyncServicingSoap obj = new AsyncLeadtracNetServicing.AsyncServicingSoap ();
            obj.beginGetDraftSplitList (continuation, 'test', 'test', 'test', 1);
            obj.beginGetActiveDraftPlan (continuation, 'test', 'test', 'test');
            obj.beginCreateOrUpdateDraftPlan (continuation, 'test', 'test', '1', new leadtracNetServicing.DraftPlan ());
            obj.beginGetDrafts (continuation, 'test', 'test', System.now ());
            obj.beginSetDraftStatus (continuation, 'test', 'test', new leadtracNetServicing.DraftPlan ());
            obj.beginGetActiveDraftPlans (continuation, 'test', 'test', new leadtracNetServicing.ArrayOfString ());
            obj.beginGetDraftsByFile (continuation, 'test', 'test', 'test', System.Now (), System.now ());
            obj.beginCreateOrUpdateDraftPaymentWithSplitList (continuation, 'test', 'test', 'test', new leadtracNetServicing.Payment (), new leadtracNetServicing.ArrayOfString ());
            obj.beginGetModifiedDraftPlans (continuation, 'test', 'test', System.now (), System.now ());
            obj.beginCreateOrUpdateDraftPayment (continuation, 'test', 'test', 'test', new leadtracNetServicing.Payment ());
            obj.beginGetTrustAccountDetails (continuation, 'test', 'test', new leadtracNetServicing.ArrayOfString ());
        Test.stopTest ();
        
    }
}