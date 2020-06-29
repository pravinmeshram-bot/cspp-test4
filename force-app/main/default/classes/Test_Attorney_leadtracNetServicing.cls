@isTest
public class Test_Attorney_leadtracNetServicing {
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
    static void clientWebservice () {
        leadtracNetServicing.GetTrustAccountBalance  GetTrustAccountBalance  = new leadtracNetServicing.GetTrustAccountBalance ();
        leadtracNetServicing.GetDraftsResult   GetDraftsResult   = new leadtracNetServicing.GetDraftsResult  ();
        leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_element   resEle  = new leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitListResponse_element  ();
        leadtracNetServicing.ModifiedDraftPlan   ModifiedDraftPlan   = new leadtracNetServicing.ModifiedDraftPlan  ();
        leadtracNetServicing.GetTrustAccountDetailsResponse_element   respElem  = new leadtracNetServicing.GetTrustAccountDetailsResponse_element  ();
        leadtracNetServicing.ArrayOfTrustAccountBalance   ArrayOfTrustAccountBalance   = new leadtracNetServicing.ArrayOfTrustAccountBalance  ();
        leadtracNetServicing.TrustAccountBalance   TrustAccountBalance   = new leadtracNetServicing.TrustAccountBalance  ();
        leadtracNetServicing.DraftPlan   DraftPlan   = new leadtracNetServicing.DraftPlan  ();
        leadtracNetServicing.CreateUpdateDraftPlanResult   CreateUpdateDraftPlanResult   = new leadtracNetServicing.CreateUpdateDraftPlanResult  ();
        leadtracNetServicing.Result   Result   = new leadtracNetServicing.Result  ();
        leadtracNetServicing.GetDraftsResponse_element   GetDraftsResponse_element   = new leadtracNetServicing.GetDraftsResponse_element  ();
        leadtracNetServicing.GetDraftSplitNameList   GetDraftSplitNameList   = new leadtracNetServicing.GetDraftSplitNameList  ();
        leadtracNetServicing.SetDraftStatusResult   SetDraftStatusResult   = new leadtracNetServicing.SetDraftStatusResult  ();
        leadtracNetServicing.DraftSplit   DraftSplit   = new leadtracNetServicing.DraftSplit  ();
        leadtracNetServicing.UpdateDraftPaymentResult   UpdateDraftPaymentResult   = new leadtracNetServicing.UpdateDraftPaymentResult  ();
        leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitList_element    resEle2   = new leadtracNetServicing.CreateOrUpdateDraftPaymentWithSplitList_element   ();
        leadtracNetServicing.GetActiveDraftPlanResponse_element    DraftSplit2   = new leadtracNetServicing.GetActiveDraftPlanResponse_element   ();
        leadtracNetServicing.ModifiedDraftPlanResult    ModifiedDraftPlanResult    = new leadtracNetServicing.ModifiedDraftPlanResult   ();
        leadtracNetServicing.GetDraftsByFile_element    GetDraftsByFile_element    = new leadtracNetServicing.GetDraftsByFile_element   ();
        leadtracNetServicing.CreateOrUpdateDraftPaymentResponse_element    DraftSplit3   = new leadtracNetServicing.CreateOrUpdateDraftPaymentResponse_element   ();
        leadtracNetServicing.GetDraftsByFileResult    GetDraftsByFileResult    = new leadtracNetServicing.GetDraftsByFileResult   ();
        leadtracNetServicing.ArrayOfDraftPlan    ArrayOfDraftPlan    = new leadtracNetServicing.ArrayOfDraftPlan   ();
        leadtracNetServicing.ArrayOfModifiedDraftPlan    ArrayOfModifiedDraftPlan    = new leadtracNetServicing.ArrayOfModifiedDraftPlan   ();
        leadtracNetServicing.ArrayOfSplit    ArrayOfSplit    = new leadtracNetServicing.ArrayOfSplit   ();
        leadtracNetServicing.GetActiveDraftPlan_element     GetActiveDraftPlan_element     = new leadtracNetServicing.GetActiveDraftPlan_element    ();
        leadtracNetServicing.ArrayOfResultMessage     ArrayOfResultMessage     = new leadtracNetServicing.ArrayOfResultMessage    ();
        leadtracNetServicing.ResultMessage    ResultMessage    = new leadtracNetServicing.ResultMessage   ();
        leadtracNetServicing.SetDraftStatus_element     SetDraftStatus_element     = new leadtracNetServicing.SetDraftStatus_element    ();
        leadtracNetServicing.GetActiveDraftPlanResult    GetActiveDraftPlanResult    = new leadtracNetServicing.GetActiveDraftPlanResult   ();
        leadtracNetServicing.GetActiveDraftPlansResponse_element     respElem4    = new leadtracNetServicing.GetActiveDraftPlansResponse_element    ();
        leadtracNetServicing.GetDraftsByFileResponse_element     fileRep    = new leadtracNetServicing.GetDraftsByFileResponse_element    ();
        leadtracNetServicing.GetTrustAccountDetails_element      fileRep1    = new leadtracNetServicing.GetTrustAccountDetails_element     ();
        leadtracNetServicing.GetDraftSplitListResponse_element      fileRep2   = new leadtracNetServicing.GetDraftSplitListResponse_element     ();
        leadtracNetServicing.Payment     Payment    = new leadtracNetServicing.Payment    ();
        leadtracNetServicing.CreateOrUpdateDraftPlan_element     fileRep9   = new leadtracNetServicing.CreateOrUpdateDraftPlan_element    ();
        leadtracNetServicing.GetActiveDraftPlans_element     GetActiveDraftPlans_element    = new leadtracNetServicing.GetActiveDraftPlans_element    ();
        leadtracNetServicing.ArrayOfGetActiveDraftPlanResult     ArrayOfGetActiveDraftPlanResult    = new leadtracNetServicing.ArrayOfGetActiveDraftPlanResult    ();
        leadtracNetServicing.ArrayOfString     ArrayOfString    = new leadtracNetServicing.ArrayOfString    ();
        leadtracNetServicing.CreateOrUpdateDraftPlanResponse_element     draftPlanElem    = new leadtracNetServicing.CreateOrUpdateDraftPlanResponse_element    ();
        leadtracNetServicing.CreateOrUpdateDraftPayment_element      draftPayment    = new leadtracNetServicing.CreateOrUpdateDraftPayment_element     ();
        leadtracNetServicing.ArrayOfPayment       draftPaymentEleme    = new leadtracNetServicing.ArrayOfPayment      ();
        leadtracNetServicing.GetDrafts_element GetDrafts_element  = new leadtracNetServicing.GetDrafts_element       ();
        leadtracNetServicing.Split  Split   = new leadtracNetServicing.Split ();
        leadtracNetServicing.SetDraftStatusResponse_element respElement8  = new leadtracNetServicing.SetDraftStatusResponse_element       ();
        leadtracNetServicing.ArrayOfDraftSplit ArrayOfDraftSplit  = new leadtracNetServicing.ArrayOfDraftSplit       ();
        leadtracNetServicing.GetDraftSplitList_element  GetDraftSplitList_element   = new leadtracNetServicing.GetDraftSplitList_element        ();
        
        
        
        
        
    }
    @isTest static void webServiceTest () {
        init ();
        Test.startTest();
        clientWebservice ();
        leadtracNetServicing.ServicingSoap  respElement = new leadtracNetServicing.ServicingSoap  ();
        try {    
            respElement.GetDraftSplitList ('test', 'test', 'test', 1);
        } catch (Exception e) {}
        try {    
            respElement.GetActiveDraftPlan ('test', 'test', 'test');
        } catch (Exception e) {}
        
        try {    
            respElement.CreateOrUpdateDraftPlan ('test', 'test', 'test', null);
        } catch (Exception e) {}
        try {    
            respElement.GetDrafts ('test', 'test', System.Now ());
        } catch (Exception e) {}
        try {    
            respElement.SetDraftStatus ('test', 'test', null);
        } catch (Exception e) {}
        try {    
            respElement.GetActiveDraftPlans ('test', 'test', null);
        } catch (Exception e) {}
        try {    
            respElement.GetDraftsByFile ('test', 'test', 'test', System.Now (), System.now ());
        } catch (Exception e) {}
        try {    
            respElement.CreateOrUpdateDraftPaymentWithSplitList ('test', 'test', 'test', null, null);
        } catch (Exception e) {}
        
        try {    
            respElement.CreateOrUpdateDraftPayment ('test', 'test', 'tet', null);
        } catch (Exception e) {}
        try {    
            respElement.GetTrustAccountDetails ('test', 'test', null);
        } catch (Exception e) {}
        Test.stopTest ();
    }
}