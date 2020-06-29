@isTest
public class Test_Attorney_GetDebts {
    static void init () {
        LeadTracCredentials__c credentials = new LeadTracCredentials__c ();
        credentials.ClientEndPointURL__c = 'www.test.com';
        credentials.DebtEndPointURL__c = 'www.test.com';
        credentials.EndpointURL__c = 'www.test.com';
        credentials.PaymentEndPointURL__c = 'www.test.com';
        credentials.Password__c = 'testing';
        credentials.UserName__c = 'Testing';
        credentials.Name = 'LeadTrackCredentials';
        insert credentials;
        
        NDS_User_List__c NDSUser = new NDS_User_List__c();
        NDSUser.email__C = 'abc@abc.com';
        NDSUser.Last_Name__c = 'test';
        NDSUser.User_Id__c = '1234';
        insert NDSUser;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c ();
        pgm.import_id__c = '1';
        insert pgm;
        
        NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchJobTimings.Load_Tradelines__c = true;
                batchJobTimings.Load_Offers__c = true;

        batchJobTimings.Load_Settlements__c = true;

        insert batchJobTimings;
    }
    
    static leadtracNetDebt.ModifiedDebtsResult debtsResult () {
        leadtracNetDebt.ModifiedDebtsResult result = new leadtracNetDebt.ModifiedDebtsResult ();
        leadtracNetDebt.ArrayOfModifiedDebt debtsArray = new leadtracNetDebt.ArrayOfModifiedDebt ();
        List <leadtracNetDebt.ModifiedDebt> listOfDebts = new List <leadtracNetDebt.ModifiedDebt> ();
        leadtracNetDebt.ModifiedDebt debt = new leadtracNetDebt.ModifiedDebt ();
        debt.FileNumber = '1';
        debt.DebtId = 1;
        debt.DebtCreatedOn = DateTime.now ();
        debt.DebtModifiedOn = DateTime.Now ();
        debt.SettlementPlanId = 1;
        debt.SettlementPlanStatus = 'New';
        debt.SettlementPlanSuspendedOn = DateTime.Now ();
        debt.SettlementPlanCompletedOn = DateTime.Now ();
        debt.SettlementPlanActivatedOn = DateTime.Now ();
        debt.SettlementPlanCreatedOn = DateTime.Now ();
        debt.SettlementPlanModifiedOn = DateTime.Now ();
        debt.LastStatusedPaymentModifiedOn = DateTime.Now ();
        
        listOfDebts.add (debt);
        debtsArray.ModifiedDebt = listOfDebts;
        result.IsSuccessful = 'true';
        result.Messages = 'test';
        
        result.ModifiedDebts = debtsArray;
        return result;
    }
    static leadtracNetDebt.ArrayOfGetDebtsResult allDebtsResult () {
        leadtracNetDebt.ArrayOfGetDebtsResult result = new leadtracNetDebt.ArrayOfGetDebtsResult ();
        List <leadtracNetDebt.GetDebtsResult> listOfResults = new List <leadtracNetDebt.GetDebtsResult> ();
        leadtracNetDebt.GetDebtsResult debt = new leadtracNetDebt.GetDebtsResult ();
        leadtracNetDebt.ArrayOfDebt debtArray = new leadtracNetDebt.ArrayOfDebt ();
        List <leadtracNetDebt.Debt> listDebt = new List <leadtracNetDebt.Debt> ();
        leadtracNetDebt.Debt debtVal = new leadtracNetDebt.Debt ();
        debtVal.DebtId = 1;
        debtVal.VendorId = '1';
        debtVal.DebtType = 'Test';
        debtVal.NegotiationStatus = 'test';
        debtVal.SettlementStatus = 'test';
        debtVal.AccountStatus = 'test';
        debtVal.PrimaryName = 'test';
        debtVal.SecondaryName = 'test';
        debtVal.SecondaryNameRelation = 'test';
        debtVal.AdditionalName = 'test';
        debtVal.AdditionalRelation = 'test';
        debtVal.ApplicantType = 'test';
        debtVal.OriginalBalance = 100;
        debtVal.IsStatementIncluded = 'true';
        debtVal.MinimumPayment = 50;
        debtVal.VerifiedBalance = 50;
        debtval.LastStatementDate = Date.today ();
        debtVal.InterestRate = 1;
        debtVal.IsCashOrTransfer = false;
        debtval.LastPaymentDate = Date.Today ();
        debtVal.EndedOn = Date.Today ();
        debtVal.fileNumber = '1';
        debtVal.CreatedOn = DateTime.Now ();
        debtVal.ModifiedOn = DateTime.Now ();
        leadtracNetDebt.ArrayOfDebtCreditor creditHis = new leadtracNetDebt.ArrayOfDebtCreditor ();
        List <leadtracNetDebt.DebtCreditor> listOfCredits = new List <leadtracNetDebt.DebtCreditor> ();
        leadtracNetDebt.DebtCreditor credit = new leadtracNetDebt.DebtCreditor ();
        leadtracNetDebt.Creditor c = new  leadtracNetDebt.Creditor ();
        c.VendorId = '1';
        c.CreditorId = '1';
        c.CreditorType = 'test';
        c.Name = 'test';
        c.Address1 = 'test';
        c.Address2 = 'test';
        c.City = 'test';
        c.State = 'test';
        c.Zip = '500049';
        c.OfficePhone = '1234567890';
        c.OfficeExt = '1';
        c.FaxPhone = '123456';
        c.Email = 'test@test.com';
        c.Note = 'test';
        c.ContactName = 'Test';
        c.CreatedOn = DateTime.Now ();
        c.ModifiedOn = DateTime.Now ();
        credit.Creditor = c;
        credit.AssignmentDate = DateTime.Now ();
        credit.AccountNumber = '1';
        credit.Amount = 100;
        credit.POASent = False;
        credit.CreatedOn = DateTime.Now ();
        credit.ModifiedOn = DateTime.Now ();
        credit.Level = 1;
        listOfCredits.add (credit);
        credithis.DebtCreditor = listOfCredits;
        debtVal.CreditorHistory = creditHis;
        
        leadtracNetDebt.SettlementPlan plan = new  leadtracNetDebt.SettlementPlan ();
        plan.PlanId = 1;
        plan.Status = 'New';
        plan.SuspendedOn = DateTime.Now ();
        plan.CompletedOn = DateTime.Now ();
        plan.ActivatedOn = DateTime.Now ();
        plan.CreatedOn = DateTime.now ();
        plan.ModifiedOn = DateTime.now ();
        plan.EndedOn = DateTime.now ();
        leadtracNetDebt.ArrayOfPayment Payments = new leadtracNetDebt.ArrayOfPayment ();
        List <leadtracNetDebt.Payment> paymentList = new List <leadtracNetDebt.Payment> ();
        leadtracNetDebt.Payment payment = new leadtracNetDebt.Payment ();
        payment.PaymentId = 1;
        payment.PlanId = 1;
        payment.CreatedOn = DateTime.now ();
        payment.ModifiedOn = DateTime.now ();
        payment.vendorId = '1';
        payment.DueOn = DateTime.Now ();
        payment.Number_x = 1;
        payment.Amount = 100;
        payment.Status = 'New';
        payment.StatusedOn = DateTime.now ();
        payment.StatusReason = 'test';
        payment.PaymentType = 'test';
        payment.PaymentTypeData = 'test';
        paymentList.add (payment);
        
        payments.payment = paymentList;
        leadtracNetDebt.ArrayOfSplit splitArray = new leadtracNetDebt.ArrayOfSplit (); 
        List <leadtracNetDebt.Split> splitList = new List <leadtracNetDebt.Split> ();
        leadtracNetDebt.Split split = new leadtracNetDebt.Split ();
        split.SplitId = 1;
        split.VendorId = '1';
        split.Name = 'test';
        split.Amount = 100;
        split.CreatedOn = DateTime.now ();
        split.ModifiedOn = DateTime.Now ();
        
        payment.SPlits = splitArray;
        plan.Payments = Payments;
        debtVal.SettlementPlan = plan;
        
        leadtracNetDebt.ArrayOfDebtProperty Properties = new  leadtracNetDebt.ArrayOfDebtProperty ();
        debtVal.Properties = Properties;
        
        listDebt.add (debtVal);
        debtArray.Debt = listDebt;
        debt.Debts = debtArray;
        
        leadtracNetDebt.ArrayOfResultMessage messagesArray = new leadtracNetDebt.ArrayOfResultMessage ();
        List <leadtracNetDebt.ResultMessage> messageList = new List <leadtracNetDebt.ResultMessage> ();
        leadtracNetDebt.ResultMessage message = new leadtracNetDebt.ResultMessage ();
        message.MessageType = 'test';
        message.Message = 'test';
        messageList.add (message);
        
        MessagesArray.ResultMessage = messageList;
        debt.Messages = messagesArray;
        listOfResults.add (debt);
        debt.IsSuccessful = TRUE;
        result.GetDebtsResult = listOfResults;
        return result;
    }
    @isTest static void schedulerTest () {
        init ();
        Test.startTest ();
            
            Attorney_GetDebts debtsObj = new Attorney_GetDebts();
            Attorney_GetDebts.respdebt = debtsResult ();
            Attorney_GetDebts.debtsResArray = allDebtsResult ();
            Attorney_GetDebts.getLeadtrackProgramLst ();
            List<String> debtFileNumberLst = new  List<String> ();
            debtFileNumberLst.add ('1');
            try {
                Attorney_GetDebts.fetchAndprocessDebts(System.Now ().addMinutes (10), System.Now ().addMinutes (30), null, debtFileNumberLst , null);
                Attorney_GetDebts.getUserIdById('1234');
            }
            catch (Exception e) {}
        Test.stoptest ();
    }
    
    
}