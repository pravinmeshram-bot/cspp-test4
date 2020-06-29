@isTest
public class Test_Attorney_leadtracNetDebt {
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
        leadtracNetDebt.CreateOrUpdateSettlementPaymentPlanResult obj = new leadtracNetDebt.CreateOrUpdateSettlementPaymentPlanResult ();
        leadtracNetDebt.GetStatusAuditResult obj1 = new leadtracNetDebt.GetStatusAuditResult ();
        leadtracNetDebt.GetCreditorResponse_element obj2 = new leadtracNetDebt.GetCreditorResponse_element ();
        leadtracNetDebt.Task obj3 = new leadtracNetDebt.Task ();
        leadtracNetDebt.CreateOrUpdateCreditorResponse_element obj4 = new leadtracNetDebt.CreateOrUpdateCreditorResponse_element ();
        leadtracNetDebt.ArrayOfCreditor obj5 = new leadtracNetDebt.ArrayOfCreditor ();
        leadtracNetDebt.ArrayOfLogEntry obj6 = new leadtracNetDebt.ArrayOfLogEntry ();
        leadtracNetDebt.LinkDebtStatusAudit obj7 = new leadtracNetDebt.LinkDebtStatusAudit ();
        leadtracNetDebt.GetDebts_element obj8 = new leadtracNetDebt.GetDebts_element ();
        leadtracNetDebt.ArrayOfLinkDebtStatusAudit obj9 = new leadtracNetDebt.ArrayOfLinkDebtStatusAudit ();
        leadtracNetDebt.ArrayOfStatusAudit obj10 = new leadtracNetDebt.ArrayOfStatusAudit ();
        leadtracNetDebt.GetCreditorByName_element obj11 = new leadtracNetDebt.GetCreditorByName_element ();
        leadtracNetDebt.Result obj12 = new leadtracNetDebt.Result ();
        leadtracNetDebt.CreateOrUpdateDebtsResponse_element obj13 = new leadtracNetDebt.CreateOrUpdateDebtsResponse_element ();
        leadtracNetDebt.Debt obj14 = new leadtracNetDebt.Debt ();
        leadtracNetDebt.GetPlanHistory_element obj15 = new leadtracNetDebt.GetPlanHistory_element ();
        leadtracNetDebt.DebtProperty obj16 = new leadtracNetDebt.DebtProperty ();
        leadtracNetDebt.AddLogEntryResponse_element obj17 = new leadtracNetDebt.AddLogEntryResponse_element ();
        leadtracNetDebt.GetDebtsResult obj18 = new leadtracNetDebt.GetDebtsResult ();
        leadtracNetDebt.GetCreditorListResult obj19 = new leadtracNetDebt.GetCreditorListResult ();
        leadtracNetDebt.GetStatusListResult obj20 = new leadtracNetDebt.GetStatusListResult ();
        leadtracNetDebt.GetPlanHistoryResponse_element obj21 = new leadtracNetDebt.GetPlanHistoryResponse_element ();
        leadtracNetDebt.LookupCreditorByVendorId_element obj22 = new leadtracNetDebt.LookupCreditorByVendorId_element ();
        leadtracNetDebt.GetDebtTaskResult obj23 = new leadtracNetDebt.GetDebtTaskResult ();
        leadtracNetDebt.GetDeletedDebtsResponse_element obj24 = new leadtracNetDebt.GetDeletedDebtsResponse_element ();
        
        leadtracNetDebt.ArrayOfLogCategory obj25 = new leadtracNetDebt.ArrayOfLogCategory ();
        leadtracNetDebt.ArrayOfDebtProperty obj26 = new leadtracNetDebt.ArrayOfDebtProperty ();
        leadtracNetDebt.GetCreditorByVendorId_element obj27 = new leadtracNetDebt.GetCreditorByVendorId_element ();
        leadtracNetDebt.GetLogCategories_element obj28 = new leadtracNetDebt.GetLogCategories_element ();
        leadtracNetDebt.DebtFile obj29 = new leadtracNetDebt.DebtFile ();
        leadtracNetDebt.ArrayOfResultMessage obj30 = new leadtracNetDebt.ArrayOfResultMessage ();
        leadtracNetDebt.GetDebtStatusAuditsResult obj31 = new leadtracNetDebt.GetDebtStatusAuditsResult ();
        
        leadtracNetDebt.GetAccountStatusList_element obj32 = new leadtracNetDebt.GetAccountStatusList_element ();
        leadtracNetDebt.CreateOrUpdateSettlementPaymentsResponse_element obj33 = new leadtracNetDebt.CreateOrUpdateSettlementPaymentsResponse_element ();
        leadtracNetDebt.Payment obj34 = new leadtracNetDebt.Payment ();
        leadtracNetDebt.ArrayOfDebtFile obj35 = new leadtracNetDebt.ArrayOfDebtFile ();
        leadtracNetDebt.DebtTask obj36 = new leadtracNetDebt.DebtTask ();
        leadtracNetDebt.LookupCreditorByVendorIdResponse_element obj37 = new leadtracNetDebt.LookupCreditorByVendorIdResponse_element ();
        leadtracNetDebt.GetCreditor_element obj38 = new leadtracNetDebt.GetCreditor_element ();
        leadtracNetDebt.CreateOrUpdateSettlementPayments_element obj39 = new leadtracNetDebt.CreateOrUpdateSettlementPayments_element ();
        
        leadtracNetDebt.GetAllModifiedDebtsResponse_element obj40 = new leadtracNetDebt.GetAllModifiedDebtsResponse_element ();
        leadtracNetDebt.SettlementPlan obj41 = new leadtracNetDebt.SettlementPlan ();
        leadtracNetDebt.ArrayOfPayment obj42 = new leadtracNetDebt.ArrayOfPayment ();
        leadtracNetDebt.SetStatusAudit_element obj43 = new leadtracNetDebt.SetStatusAudit_element ();
        leadtracNetDebt.Split obj44 = new leadtracNetDebt.Split ();
        leadtracNetDebt.GetLogEntries_element obj45 = new leadtracNetDebt.GetLogEntries_element ();
        leadtracNetDebt.Creditor obj46 = new leadtracNetDebt.Creditor ();
        leadtracNetDebt.GetAccountStatusListResponse_element obj47 = new leadtracNetDebt.GetAccountStatusListResponse_element ();
        leadtracNetDebt.GetLogEntriesResponse_element obj48 = new leadtracNetDebt.GetLogEntriesResponse_element ();
        leadtracNetDebt.GetTasks_element obj49 = new leadtracNetDebt.GetTasks_element ();
        leadtracNetDebt.GetLogCategoriesResponse_element obj50 = new leadtracNetDebt.GetLogCategoriesResponse_element ();
        leadtracNetDebt.GetModifiedDebtsResponse_element obj51 = new leadtracNetDebt.GetModifiedDebtsResponse_element ();
        leadtracNetDebt.ArrayOfDebt obj52 = new leadtracNetDebt.ArrayOfDebt ();
        
        leadtracNetDebt.GetNegotiationStatusList_element obj53 = new leadtracNetDebt.GetNegotiationStatusList_element ();
        leadtracNetDebt.GetCreditorResult obj54 = new leadtracNetDebt.GetCreditorResult ();
        leadtracNetDebt.StatusAudit obj55 = new leadtracNetDebt.StatusAudit ();
        leadtracNetDebt.GetDebtStatusAuditResponse_element obj56 = new leadtracNetDebt.GetDebtStatusAuditResponse_element ();
        leadtracNetDebt.ArrayOfDebtCreditor obj57 = new leadtracNetDebt.ArrayOfDebtCreditor ();
        leadtracNetDebt.GetModifiedDebts_element obj58 = new leadtracNetDebt.GetModifiedDebts_element ();
        leadtracNetDebt.GetStatusAuditResponse_element obj59 = new leadtracNetDebt.GetStatusAuditResponse_element ();
        leadtracNetDebt.GetCreditorByVendorIdResponse_element obj60 = new leadtracNetDebt.GetCreditorByVendorIdResponse_element ();
        
        leadtracNetDebt.CreateOrUpdateCreditor_element obj61 = new leadtracNetDebt.CreateOrUpdateCreditor_element ();
        leadtracNetDebt.ArrayOfGetDebtsResult obj62 = new leadtracNetDebt.ArrayOfGetDebtsResult ();
        leadtracNetDebt.SetStatusAuditResponse_element obj63 = new leadtracNetDebt.SetStatusAuditResponse_element ();
        leadtracNetDebt.ArrayOfDebtTask obj64 = new leadtracNetDebt.ArrayOfDebtTask ();
        leadtracNetDebt.LogEntry obj65 = new leadtracNetDebt.LogEntry ();
        leadtracNetDebt.GetAllModifiedDebts_element obj66 = new leadtracNetDebt.GetAllModifiedDebts_element ();
        leadtracNetDebt.LogCategory obj67 = new leadtracNetDebt.LogCategory ();
        leadtracNetDebt.AddLogEntry_element obj68 = new leadtracNetDebt.AddLogEntry_element ();
        leadtracNetDebt.SetStatusAuditResult obj69 = new leadtracNetDebt.SetStatusAuditResult ();
        leadtracNetDebt.DebtCreditor obj70 = new leadtracNetDebt.DebtCreditor ();
        
        leadtracNetDebt.LogDebtCategoryResult obj71 = new leadtracNetDebt.LogDebtCategoryResult ();
        leadtracNetDebt.GetPlanHistoryResult obj72 = new leadtracNetDebt.GetPlanHistoryResult ();
        leadtracNetDebt.ModifiedDebt obj73 = new leadtracNetDebt.ModifiedDebt ();
        leadtracNetDebt.GetAllModifiedDebtsList_element obj74 = new leadtracNetDebt.GetAllModifiedDebtsList_element ();
        leadtracNetDebt.ModifiedDebtsResult obj75 = new leadtracNetDebt.ModifiedDebtsResult ();
        leadtracNetDebt.ArrayOfSplit obj76 = new leadtracNetDebt.ArrayOfSplit ();
        
        leadtracNetDebt.CreateOrUpdateDebts_element obj77 = new leadtracNetDebt.CreateOrUpdateDebts_element ();
        leadtracNetDebt.GetStatusAudit_element obj78 = new leadtracNetDebt.GetStatusAudit_element ();
        leadtracNetDebt.ResultMessage  obj79 = new leadtracNetDebt.ResultMessage ();
        leadtracNetDebt.GetDebtStatusAudit_element obj80 = new leadtracNetDebt.GetDebtStatusAudit_element ();
        leadtracNetDebt.GetTasksResponse_element obj81 = new leadtracNetDebt.GetTasksResponse_element ();
        leadtracNetDebt.ArrayOfSettlementPlan obj82 = new leadtracNetDebt.ArrayOfSettlementPlan ();
        leadtracNetDebt.GetNegotiationStatusListResponse_element obj83 = new leadtracNetDebt.GetNegotiationStatusListResponse_element ();
        leadtracNetDebt.ArrayOfModifiedDebt obj84 = new leadtracNetDebt.ArrayOfModifiedDebt ();
        leadtracNetDebt.ArrayOfString obj85 = new leadtracNetDebt.ArrayOfString ();
        leadtracNetDebt.GetDeletedDebts_element obj86 = new leadtracNetDebt.GetDeletedDebts_element ();
        leadtracNetDebt.GetDebtsResponse_element obj87 = new leadtracNetDebt.GetDebtsResponse_element ();
        leadtracNetDebt.GetCreditorByNameResponse_element obj88 = new leadtracNetDebt.GetCreditorByNameResponse_element();
        leadtracNetDebt.GetDebtLogEntriesResult obj89 = new leadtracNetDebt.GetDebtLogEntriesResult ();
        leadtracNetDebt.GetAllModifiedDebtsListResponse_element obj90 = new leadtracNetDebt.GetAllModifiedDebtsListResponse_element ();
        
        leadtracNetDebt.ArrayOfLong obj91 = new leadtracNetDebt.ArrayOfLong ();
        leadtracNetDebt.ArrayOfCriteria obj92 = new leadtracNetDebt.ArrayOfCriteria ();
        leadtracNetDebt.Criteria obj93 = new leadtracNetDebt.Criteria ();
        
        
    }
    @isTest static void webServiceTest () {
        init ();
        Test.startTest();
        clientWebservice ();
        leadtracNetDebt.DebtServiceSoap respElement = new leadtracNetDebt.DebtServiceSoap ();
        try {    
            respElement.GetCreditorByVendorId ('test', 'test', 'test', 'test');
        } catch (Exception e) {}
        try {    
            respElement.CreateOrUpdateDebts('test', 'test', 'test', null);
        } catch (Exception e) {}
        try {    
            respElement.GetCreditor('test', 'test', 'test');
        } catch (Exception e) {}
        
        try {    
            respElement.GetLogEntries('test', 'test', 'test', 1, System.now ());
        } catch (Exception e) {}
        
        try {    
            respElement.SetStatusAudit('test', 'test', 1, null);
        } catch (Exception e) {}
        try {    
            respElement.GetPlanHistory('test', 'test', 'test', 1);
        } catch (Exception e) {}
        
        try {    
            respElement.GetAccountStatusList('test', 'test');
        } catch (Exception e) {}
        
        try {    
            respElement.GetTasks('test', 'test', 'test', System.now (), System.Now (), 1);
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetNegotiationStatusList ('test', 'test');
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetModifiedDebts('test', 'test', System.now (), System.Now (), null);
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetDeletedDebts('test', 'test', 'test');
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetAllModifiedDebts('test', 'test', 'test', System.Now (), System.Now ());
            
        } catch (Exception e) {}
        
        try {    
            respElement.CreateOrUpdateCreditor('test', 'test', null);
            
        } catch (Exception e) {}
        
        try {    
            respElement.CreateOrUpdateSettlementPayments('test', 'test', 'test', 1, null);
            
        } catch (Exception e) {}
        
        try {    
            respElement.LookupCreditorByVendorId('test', 'test', 'test');
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetCreditorByName('test', 'test', 'test');
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetStatusAudit ('test', 'test', 'test', 1);
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetLogCategories('test', 'test');
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetDebtStatusAudit('test', 'test', null);
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetDebts('test', 'test', 'test');
            
        } catch (Exception e) {}
        
        try {    
            respElement.AddLogEntry('test', 'test', 'test', 1, null);
            
        } catch (Exception e) {}
        
        try {    
            respElement.GetAllModifiedDebtsList('test', 'test', null, System.Now (), System.Now ());
            
        } catch (Exception e) {}
        
        
        Test.stopTest ();
    }
}