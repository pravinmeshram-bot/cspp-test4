public class Attorney_GetDebts {
    
    public static leadtracNetDebt.ModifiedDebtsResult respdebt;
    public static leadtracNetDebt.ArrayOfGetDebtsResult debtsResArray;
    public static List<LeadTracProgramType__mdt> getLeadtrackProgramLst(){
        List<LeadTracProgramType__mdt> leadtrckProgramTypeLst = [Select Id,Label,Parameter__c FROM LeadTracProgramType__mdt Where Active__c = TRUE and Parameter__c = 'Program Type'];    
        return leadtrckProgramTypeLst;
    }
    Public static String getUserIdById(String UserId){
        //Added By Ramesh
        List<NDS_User_List__c> NDSUserLst = [select id,name,Email__c,User_Name__c from NDS_User_List__c where User_Id__c =: UserId]; 
        system.debug('###NDSUserLst::'+NDSUserLst);
        if(!NDSUserLst.isEmpty()){
            String UatEmail = String.ValueOf(NDSUserLst[0].Email__c).replace('@','=')+'@example.com';
            List<User> usr = [select id,Name from User where Email =: NDSUserLst[0].Email__c Or Email =: UatEmail];
            system.debug('###User::'+usr);
            String SalesUserId;
            if(!usr.isEmpty())
                SalesUserId = usr[0].Id;
            return SalesUserId;
        }
        return '';
    }
    
    /*  public Static List<Payment_Status_Mapping__mdt> PaymentStatusMappingList = [Select Id, MasterLabel, DeveloperName, Transition_Status__c from Payment_Status_Mapping__mdt];
public static String PaymentStatusMapping(String PaymentStatus){
//Map<String,Payment_Status_Mapping__mdt> PaymentStatusMapping = new Map<String,Payment_Status_Mapping__mdt>();
if(PaymentStatus == null || PaymentStatus == '' || PaymentStatus == 'None')
{
return null;
}

for(Payment_Status_Mapping__mdt psm : Attorney_GetDebts.PaymentStatusMappingList){
//PaymentStatusMapping.put(psm.MasterLabel, psm);
if(PaymentStatus.equalsIgnoreCase(psm.MasterLabel)){
return psm.Transition_Status__c;
}
}
return PaymentStatus;
}*/
    public static String checkEmail(String inputEmail){
        if(inputEmail == null)
            return null;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(inputEmail);
        if(MyMatcher.matches()){
            return inputEmail;
        }
        return 'invalid@email.com';
    } 
    public static void fetchAndprocessDebts(DateTime startTime, DateTime endTime, String sysLogId, List<String> debtFileNumberLst,Id batchJobId){
        /*****Intialiaing and framing request to make GETModidiedDebt callout, it will give all the fileNumbers which are modified between given Start time and end time.*****/
        String errorString = '';    
        //try{
        leadtracNetDebt debt1 = new leadtracNetDebt();
        leadtracNetDebt.DebtServiceSoap debtsoap1 = new leadtracNetDebt.DebtServiceSoap();
        LeadTracCredentials__c credentials = LeadTracCredentials__c.getValues('LeadTrackCredentials');
        leadtracNetDebt.ArrayOfModifiedDebt debtsArray = new leadtracNetDebt.ArrayOfModifiedDebt();
        
        NextBatchJobTimings__c NextBatchTimings = NextBatchJobTimings__c.getInstance();
        
        List<nu_dse__Program__c> progLst = new List<nu_dse__Program__c>();
        progLst = [select id,import_id__c from nu_dse__Program__c where import_id__c IN: debtFileNumberLst];
        
        List<nu_dse__Tradeline__c> TradelineList = [Select Id,nu_dse__Original_Debt__c,Import_Id__c from nu_dse__Tradeline__c where FileNumber__c =: debtFileNumberLst];
        Map<String,nu_dse__Tradeline__c> ExistingTradelineMap = new Map<String,nu_dse__Tradeline__c>();
        for(nu_dse__Tradeline__c Tradeline: TradelineList){
            if(!ExistingTradelineMap.containsKey(Tradeline.Import_Id__c)){
                ExistingTradelineMap.put(Tradeline.Import_Id__c,Tradeline);
            }
        }
        
        Map<String,nu_dse__Program__c> fileProgMap = new Map<String,nu_dse__Program__c>();
        for(nu_dse__Program__c prog: progLst)
            fileProgMap.put(prog.import_Id__c,prog);   
        system.debug('Mayur' +fileProgMap);
        
        /********Intialiazing the object and collection of object instances to insert the data****/
        Map<String,List<nu_dse__TradeLine__c>> fileTradeLineMap = new Map<String,List<nu_dse__TradeLine__c>>();
        nu_dse__TradeLine__c debtRec;
        List<nu_dse__TradeLine__c> debtRecLst;
        
        Map<String,List<nu_dse__Offer__c>> TradeLineOfferMap = new Map<String,List<nu_dse__Offer__c>>();
        nu_dse__Offer__c offerRec;
        List<nu_dse__Offer__c> offerRecLst;
        
        leadtracNetDebt.ArrayOfDebt debtArray;
        leadtracNetDebt.ArrayOfDebtCreditor arrayCreditorHis;
        leadtracNetDebt.SettlementPlan settlement;
        List<nu_dse__Offer__c> offerAllRecLst = new List<nu_dse__Offer__c>();
        List<nu_dse__TradeLine__c> debtAllRecLst = new List<nu_dse__TradeLine__c>();
        Set<String> debtIdSet = new Set<String>();
        List<nu_dse__Payment__c> paymentsLst = new List<nu_dse__Payment__c>();
        Set<String> offerIdSet = new Set<String>();
        /******************************Parsing response to create TradeLine(Debt), Settelement(Offer) and Payment(Offer)***********************************/
        leadtracNetDebt.ArrayOfString fileArray = new leadtracNetDebt.ArrayOfString();
        List<String> fileNameSet = new List<String>();
        Set<String> fileNameUnique = new Set<String>();
        if(debtsArray.ModifiedDebt != NULL)
            for(leadtracNetDebt.ModifiedDebt debt: debtsArray.ModifiedDebt)
            fileNameUnique.add(debt.fileNumber); 
        fileNameSet.addAll(debtFileNumberLst);
        system.debug('###RameshfileNameSet::'+fileNameSet);   
        fileArray.string_x = fileNameSet;
        system.debug('###fileArray::'+fileArray);
        
        //Changes made by Vaibhav as part of NMI-902
        
        if(!Test.isRunningTest () && NextBatchTimings.DayLightStarted__c)
        { 
            debtsResArray = debtsoap1.GetAllModifiedDebtsList(credentials.UserName__c,credentials.Password__c,fileArray,StartTime,EndTime);
        }
        else if(!Test.isRunningTest ())
        {
            debtsResArray = debtsoap1.GetAllModifiedDebtsList(credentials.UserName__c,credentials.Password__c,fileArray,StartTime.addhours(-1),EndTime.addhours(-1));
        }
        
        // if(!Test.isRunningTest ())
        // debtsResArray = debtsoap1.GetAllModifiedDebtsList(credentials.UserName__c,credentials.Password__c,fileArray,StartTime.addhours(-1),EndTime.addhours(-1));
        
        system.debug('###debtsResArray::'+debtsResArray);
        leadtracNetDebt.ArrayOfDebt arrayDets = new leadtracNetDebt.ArrayOfDebt ();
        leadtracNetDebt.ArrayOfPayment arrayPayment = new leadtracNetDebt.ArrayOfPayment ();
        
        Set<String> allDebtIdSet= new Set<String>();
        Id paymentRecordTypeId = SystemUtils.getRecordTypeID('nu_dse__Payment__c','Settlement');
        if(debtsResArray.GetDebtsResult != NULL)
            for(leadtracNetDebt.GetDebtsResult resDebt: debtsResArray.GetDebtsResult){
                arrayDets = new leadtracNetDebt.ArrayOfDebt();
                arrayDets = resDebt.Debts;
                if(arrayDets.Debt != NULL) // MAYUR
                    for(leadtracNetDebt.Debt debtResp: arrayDets.Debt){
                        //system.debug('###RameshDebtId::'+debtResp.debtId);
                        debtIdSet.add(String.ValueOf(debtResp.DebtId));
                        /***********Loading response data into Tradeline(Debt)**********/
                        debtRec = new nu_dse__TradeLine__c(); 
                        //system.debug('###debtId::'+debtResp.DebtId);
                        if(debtResp.DebtId != NULL){
                            
                            debtRec.import_id__c = string.valueOf(debtResp.DebtId); 
                            //  debtRec.External_Id__c = string.valueOf(debtResp.DebtId); 
                        }
                        debtRec.nds_Debt_Type__c = debtResp.DebtType;
                        debtRec.negotiation_status__c = debtResp.NegotiationStatus; // changes by Mayur per Bhasu
                        system.debug('###Negotiator::'+debtResp.Negotiator);
                        /*        if(debtResp.Negotiator != NULL && debtResp.Negotiator != ''){
if(getUserIdById(debtResp.Negotiator) != '')
debtRec.Negotiator__c = getUserIdById(debtResp.Negotiator);    
}else{
debtRec.Negotiator__c = NULL;    
}*/
                        
                        /*      if(debtResp.Negotiator != NULL && debtResp.Negotiator != ''){
debtRec.NDS_Negotiator_Id__c = debtResp.Negotiator; 
}*/
                        
                        /*if(debtResp.SettlementStatus == 'None')
debtRec.nu_dse__Current_Stage__c = '--None--';
else
debtRec.nu_dse__Current_Stage__c = debtResp.SettlementStatus;*/
                        debtRec.Account_Status__c = debtResp.AccountStatus; //Changes by Mayur as per new mapping by Bhasu
                        debtRec.Primary_Applicant__c = debtResp.PrimaryName;
                        debtRec.Secondary_Applicant__c = debtResp.SecondaryName;
                        debtRec.Secondary_Name_Relation__c = debtResp.SecondaryNameRelation;
                        
                        
                        if(debtResp.NegotiationNote != NULL && debtResp.NegotiationNote != '' && debtResp.NegotiationNote.Length() < 5001 && !String.ValueOf(debtResp.NegotiationNote).contains('Data Clean Up'))
                        {
                            debtRec.Negotiation_Note__c = debtResp.NegotiationNote;
                        }
                        else if(debtResp.NegotiationNote != NULL && debtResp.NegotiationNote != '' && !String.ValueOf(debtResp.NegotiationNote).contains('Data Clean Up')){
                            debtRec.Negotiation_Note__c = debtResp.NegotiationNote.subString(0,4999);
                        }
                        
                        
                        debtRec.nds_statement_included__c = boolean.valueof(debtResp.IsStatementIncluded);
                        debtRec.Additional_Name__c = debtResp.AdditionalName;
                        debtRec.Additional_Relation__c = debtResp.AdditionalRelation;
                        if(debtResp.ApplicantType == 'CoApplicant')
                        {
                            debtRec.Applicant_Type__c = 'Co-Applicant';
                        }
                        else if(debtResp.ApplicantType == 'Individual')
                        {
                            debtRec.Applicant_Type__c = 'Applicant';
                            
                        }
                        else
                        {
                            debtRec.Applicant_Type__c =  debtResp.ApplicantType;
                        }
                        if(!ExistingTradelineMap.containsKey(debtRec.Import_Id__c) || ExistingTradelineMap.get(debtRec.Import_Id__c).nu_dse__Original_Debt__c == null ||  ExistingTradelineMap.get(debtRec.Import_Id__c).nu_dse__Original_Debt__c == 0){
                            if(debtResp.OriginalBalance != null )
                            {
                                debtRec.nu_dse__Original_Debt__c = debtResp.OriginalBalance;
                            }
                            else
                            {
                                debtRec.nu_dse__Original_Debt__c = 0;
                                
                            }
                        }
                        debtRec.nu_dse__Minimum_Payment_Amount__c = debtResp.MinimumPayment;
                        debtRec.nu_dse__Verified_Balance__c = debtResp.VerifiedBalance;
                        debtRec.nds_Last_Statement_Date__c = Date.ValueOf(debtResp.LastStatementDate);
                        debtRec.nu_dse__Last_Payment_Date__c = date.valueOf(debtResp.LastPaymentDate);
                        debtRec.Ended_On__c = date.valueOf(debtResp.EndedOn);
                        debtRec.nu_dse__Percentage__c = debtResp.InterestRate;
                        debtRec.Last_Modified_By_NDS__c = System.Now();
                        if(debtResp.IsCashOrTransfer = True)
                            debtRec.is_cash_or_transfer__c = True;
                        else
                            debtRec.is_cash_or_transfer__c = False;
                        //debtRec.nu_dse__New_Account_Number__c = debtResp.AccountNumber;
                        //debtRec.nds_Current_Creditor_Amount__c = debtResp.Amount;
                        //debtRec.nds_Current_Creditor_POA_Sent__c = debtResp.POASent;
                        //debtRec.nds_Current_Creditor_Level__c = 1;
                        if(fileProgMap.containsKey(debtResp.FileNumber))
                            debtRec.nu_dse__Program__c = fileProgMap.get(debtResp.FileNumber).Id;
                        debtRec.FileNumber__c = debtResp.FileNumber;
                        debtRec.Attorney__c = TRUE;
                        //     debtRec.nu_dse__Original_Debt__c = debtResp.OriginalBalance;  
                        arrayCreditorHis = new leadtracNetDebt.ArrayOfDebtCreditor();
                        arrayCreditorHis = debtResp.CreditorHistory;
                        
                        //Properties Reference Lead number
                        
                        if(debtResp.Properties != null && debtResp.Properties.DebtProperty != null){
                            for(leadtracNetDebt.DebtProperty property: debtResp.Properties.DebtProperty){
                                if(property.Name != null && property.Name.equalsIgnoreCase('Reference.LeadNumber')){
                                   debtRec.Litigation_File_Number__c = property.value; 
                                }
                            }
                        }
                        
                        Integer size = 0;
                        if(arrayCreditorHis != NULL)
                            size = arrayCreditorHis.DebtCreditor.size();
                        Integer count =1;
                        if(size > 0)
                            for(leadtracNetDebt.DebtCreditor debtCreditor: arrayCreditorHis.DebtCreditor){
                                system.debug('###debtCreditor::'+debtCreditor);
                                
                                leadtracNetDebt.Creditor creditor = new leadtracNetDebt.Creditor();
                                creditor = debtCreditor.Creditor;
                                if(size == count){
                                    //debtRec.Current_Creditor_Id__c = creditor.CreditorId;
                                    
                                    debtRec.SFS_Current_Balance__c = debtCreditor.Amount;
                                    //  debtRec.nds_Current_Creditor_Amount__c = debtCreditor.Amount;
                                    
                                    
                                    if(debtCreditor.AccountNumber != NULL && debtCreditor.AccountNumber != '' && debtCreditor.AccountNumber.Length() < 31 && debtCreditor.AccountNumber != 'Data Clean Up Needed in NDS')
                                    {
                                        debtRec.nu_dse__New_Account_Number__c = debtCreditor.AccountNumber;
                                    }
                                    else if(debtCreditor.AccountNumber != NULL && debtCreditor.AccountNumber != '' && debtCreditor.AccountNumber != 'Data Clean Up Needed in NDS'){
                                        debtRec.nu_dse__New_Account_Number__c = debtCreditor.AccountNumber.subString(0,30);
                                        if(debtCreditor.AccountNumber.length() < 5001 && debtCreditor.AccountNumber != 'Data Clean Up Needed in NDS')
                                            debtRec.NDS_New_Account_Number__c = debtCreditor.AccountNumber;
                                        else
                                            debtRec.NDS_New_Account_Number__c = debtCreditor.AccountNumber.subString(0,4999);
                                    }
                                    
                                    debtRec.nds_Current_Creditor_Type__c = creditor.CreditorType;
                                    debtRec.nds_Current_Creditor_Name__c = creditor.Name;
                                    debtRec.nds_Current_Creditor_Address1__c = creditor.Address1;
                                    debtRec.nds_Current_Creditor_Address2__c = creditor.Address2;
                                    debtRec.nds_Current_Creditor_Contact_Name__c = creditor.ContactName;
                                    debtRec.nds_Current_Creditor_City__c = creditor.city;
                                    debtRec.nds_Current_Creditor_State__c = creditor.state;
                                    debtRec.nds_Current_Creditor_Zip__c = creditor.zip;
                                    debtRec.nds_Current_Creditor_Office__c= creditor.OfficePhone;
                                    debtRec.nds_Current_Creditor_Office_Ext__c = creditor.OfficeExt;
                                    debtRec.nds_Current_Creditor_Fax__c = creditor.FaxPhone;
                                    debtRec.nds_Current_Creditor_Email__c = checkEmail(creditor.Email);                     
                                    debtRec.nds_Current_Creditor_Note__c = creditor.Note;
                                    debtRec.nds_Current_Creditor_Level__c = debtCreditor.Level;
                                    if(debtCreditor.POASent != NULL)
                                        debtRec.nds_Current_Creditor_POA_Sent__c = debtCreditor.POASent;
                                    
                                    
                                    
                                }
                                if(count == 1){    
                                    //debtRec.Original_Creditor_Id__c = creditor.CreditorId;
                                    //    debtRec.nu_dse__Original_Debt__c = debtCreditor.Amount;
                                    
                                    //Changes made by Mayur as part of Data Issues Project
                                    if(debtCreditor.AccountNumber != NULL && debtCreditor.AccountNumber != '' && debtCreditor.AccountNumber.Length() < 31 && debtCreditor.AccountNumber != 'Data Clean Up Needed in NDS')
                                    {
                                        debtRec.nu_dse__Original_Account_Number__c = debtCreditor.AccountNumber;
                                    }
                                    else if(debtCreditor.AccountNumber != NULL && debtCreditor.AccountNumber != '' && debtCreditor.AccountNumber != 'Data Clean Up Needed in NDS'){
                                        debtRec.nu_dse__Original_Account_Number__c = debtCreditor.AccountNumber.subString(0,30);
                                        if(debtCreditor.AccountNumber.length() < 5001 && debtCreditor.AccountNumber != 'Data Clean Up Needed in NDS')
                                            debtRec.NDS_Original_Account_Number__c = debtCreditor.AccountNumber;
                                        else
                                            debtRec.NDS_Original_Account_Number__c = debtCreditor.AccountNumber.subString(0,4999);
                                    }
                                    
                                    
                                    debtRec.nds_Original_Creditor_Type__c = creditor.CreditorType;
                                    debtRec.nds_Original_Creditor_Name__c = creditor.Name;
                                    debtRec.nds_Original_Creditor_Address1__c = creditor.Address1;
                                    debtRec.nds_Original_Creditor_Address2__c = creditor.Address2;
                                    debtRec.nds_Original_Creditor_City__c = creditor.city;
                                    debtRec.nds_Original_Creditor_Contact_Name__c = creditor.ContactName;
                                    debtRec.nds_Original_Creditor_State__c = creditor.state;
                                    debtRec.nds_Original_Creditor_Zip__c = creditor.zip;
                                    debtRec.nds_Original_Creditor_Office__c= creditor.OfficePhone;
                                    debtRec.nds_Original_Creditor_Office_Ext__c = creditor.OfficeExt;
                                    debtRec.nds_Original_Creditor_Fax__c = creditor.FaxPhone;
                                    debtRec.nds_Original_Creditor_Email__c = checkEmail(creditor.Email);                               
                                    debtRec.nds_Original_Creditor_Note__c = creditor.Note;
                                    debtRec.nds_Original_Creditor_Level__c = debtCreditor.Level;
                                    if(debtCreditor.POASent != NULL)
                                        debtRec.nds_Original_Creditor_POA_Sent__c = debtCreditor.POASent;
                                }
                                count++;
                            }
                        /**********Loading Offer Data ***********/
                        //system.debug('###debtResp.SettlementPlan::'+debtResp.SettlementPlan);
                        if(debtResp.SettlementPlan != NULL){
                            settlement = new leadtracNetDebt.SettlementPlan();
                            settlement = debtResp.SettlementPlan;
                            system.debug('###debtId::'+debtResp.FileNumber+'_'+debtResp.DebtId);
                            offerRec = new nu_dse__Offer__c();
                            
                            offerRec.DebtId__c = String.ValueOf(debtResp.DebtId);
                            //  offerRec.Import_Id__c = String.ValueOf(settlement.PlanId);
                            offerRec.NDS_Offer_Id__c = String.ValueOf(settlement.PlanId);
                            offerRec.Suspended_On__c = settlement.SuspendedOn;
                            offerRec.nu_dse__Valid_Until__c = Date.ValueOf(settlement.CompletedOn);
                            offerRec.nu_dse__First_Payment_Date__c = Date.ValueOf(settlement.ActivatedOn);
                            offerRec.NDS_Created_By__c = String.ValueOf(settlement.CreatedBy);
                            
                            offerRec.nu_dse__TradeLine__c = null;
                            offerRec.FileNumber__c = debtResp.FileNumber;
                            
                           /* If(debtResp.AccountStatus!= NULL && debtResp.AccountStatus == 'Attorney Review - Approved')
                            {
                                offerRec.nu_dse__Status__c = 'To Payment Processing';
                            }*/
                            
                            
                            //  offerRec.External_Id__c = String.ValueOf(settlement.PlanId); 
                            if(NextBatchTimings.Update_Offer_Status__c){
                                if(settlement.Status != '' && settlement.Status != null && settlement.Status == 'Payment_Plan_Active')
                                {
                                    offerRec.nu_dse__Status__c = 'Payment Plan - Active';
                                    
                                }
                                
                                else if(settlement.Status != '' && settlement.Status != null && settlement.Status == 'Payment_Plan_Suspended')
                                {
                                    offerRec.nu_dse__Status__c = 'Payment Plan - Suspended';
                                    
                                }
                                
                                else if(settlement.Status != '' && settlement.Status != null && settlement.Status == 'Cancelled')
                                {
                                    offerRec.nu_dse__Status__c = 'Canceled';
                                }
                                else if(settlement.Status != '' && settlement.Status != null && settlement.Status == 'Canceled by New Offer')
                                {
                                    offerRec.nu_dse__Status__c = 'Canceled';
                                }                                                       
                                else
                                {
                                    offerRec.nu_dse__Status__c= (string.isBlank(settlement.Status )) ? settlement.Status : settlement.Status.replace('_',' ');
                                }
                            }
                            offerRec.Ended_On__c = settlement.EndedOn;
                            offerRec.Last_Modified_By_NDS__c = System.Now();
                            
                            if(fileProgMap.containsKey(debtResp.FileNumber))
                                offerRec.nu_dse__Program__c = fileProgMap.get(debtResp.FileNumber).Id;
                            
                            offerAllRecLst.add(offerRec);
                            arraypayment = new leadtracNetDebt.ArrayOfPayment();
                            arraypayment = settlement.Payments;
                            system.debug('###PaymentRec123::'+arraypayment);
                            if(arraypayment.Payment != NULL)
                                for(leadtracNetDebt.Payment pay: arraypayment.Payment){
                                    system.debug('###PaymentRec1234::'+pay);
                                    nu_dse__Payment__c paymentRec = new nu_dse__Payment__c();
                                    //paymentRec.import_Id__c = String.ValueOf(pay.PaymentId);
                                    //paymentRec.External_Id__c = String.ValueOf(pay.PaymentId);
                                    paymentRec.Attorney_Payment_Id__c = String.ValueOf(pay.PaymentId);
                                    //   paymentRec.nu_dse__External_GCS_ID__c = String.ValueOf(pay.PaymentId);
                                    //   paymentRec.External_Id__c= String.ValueOf(pay.PaymentId);                                  
                                    
                                    paymentRec.nu_dse__Schedule_Date__c = Date.ValueOf(pay.DueOn);
                                    //       paymentRec.Attorney__c = TRUE;
                                    offerIdSet.add(String.ValueOf(settlement.PlanId));
                                    if(fileProgMap.containsKey(debtResp.FileNumber))
                                        paymentRec.nu_dse__Program__c = fileProgMap.get(debtResp.FileNumber).Id;
                                    paymentRec.offerId__c = String.ValueOf(settlement.PlanId);
                                    //VendorId;
                                    //     paymentRec.nu_dse__Payment_Sequence_Number__c = pay.Number_x;
                                    paymentRec.nu_dse__Amount__c = pay.Amount;
                                    
                                    //paymentRec.recordtypeid = '01241000000jtbs';
                                    paymentRec.recordtypeid = paymentRecordTypeId;
                                    //paymentRec.nu_dse__Transaction_Status__c = Attorney_GetClients.PaymentStatusMapping(pay.Status);
                                    paymentRec.Payment_Status__c = pay.Status;
                                    paymentRec.Statused_On__c = pay.StatusedOn;
                                    paymentRec.Attorney__c = TRUE;
                                    paymentRec.filenumber__c = debtResp.FileNumber;
                                    
                                    paymentRec.Status_Reason__c = pay.StatusReason;
                                    paymentRec.nds_Payment_Type__c = pay.PaymentType;
                                    paymentRec.Payment_Type_Data__c = pay.PaymentTypeData;
                                    paymentRec.Last_Modified_By_NDS__c = System.Now();
                                    //StatusedOn;
                                    //StatusReason;
                                    //PaymentType;
                                    //PaymentTypeData;
                                    paymentsLst.add(paymentRec);
                                }
                        }
                        debtAllRecLst.add(debtRec);   
                        allDebtIdSet.add(debtRec.import_Id__c);
                    }
                
            }
        Set<String> exstDebtIdSet = new Set<String>();
        List<nu_dse__TradeLine__c> exsttradeLst = [Select Id,Name, Import_Id__c,FileNumber__c FROM nu_dse__TradeLine__c where Import_Id__c IN: allDebtIdSet];
        system.debug('###debtAllRecLst::'+debtAllRecLst);
        for(nu_dse__TradeLine__c trade: exsttradeLst)
            exstDebtIdSet.add(trade.Import_Id__c);    
        Map<String,nu_dse__TradeLine__c> TradelineMap = new Map<String,nu_dse__TradeLine__c>();
        Set<String> tradeLineSet = new Set<String>();
        Set<String> currentCreditNameSet = new Set<String>();
        Set<String> currentCreditStreetSet = new Set<String>();
        Set<String> originalCreditNameSet = new Set<String>();
        Set<String> originalCreditStreetSet = new Set<String>();
        if(!debtAllRecLst.isEmpty()){
            List<nu_dse__TradeLine__c> insTradeLst = new List<nu_dse__TradeLine__c>();
            List<nu_dse__TradeLine__c> updTradeLst = new List<nu_dse__TradeLine__c>();
            for(nu_dse__TradeLine__c trade: debtAllRecLst){
                if(exstDebtIdSet.contains(trade.import_id__c)){
                    updTradeLst.add(trade);
                }
                else{
                    system.debug('###newTrade::'+trade);
                    insTradeLst.add(trade);
                    if(trade.nds_Current_Creditor_Name__c != NULL)
                        currentCreditNameSet.add(trade.nds_Current_Creditor_Name__c);
                    if(trade.nds_Current_Creditor_Address1__c != NULL)
                        currentCreditStreetSet.add(trade.nds_Current_Creditor_Address1__c);
                    if(trade.nds_Original_Creditor_Name__c != NULL)
                        originalCreditNameSet.add(trade.nds_Original_Creditor_Name__c);
                    if(trade.nds_Original_Creditor_Address1__c != NULL)
                        originalCreditStreetSet.add(trade.nds_Original_Creditor_Address1__c);
                }        
            }
            system.debug('###currentCreditNameSet::'+currentCreditNameSet.size());
            system.debug('###currentCreditNameSet::'+currentCreditStreetSet.size());
            system.debug('###currentCreditNameSet::'+originalCreditNameSet.size());
            system.debug('###currentCreditNameSet::'+originalCreditStreetSet.size());
            system.debug('###insTradeLst::'+insTradeLst);
            if(!updTradeLst.isEmpty() && nextBatchTimings.Load_Tradelines__c == true){
                Schema.SObjectField f = nu_dse__TradeLine__c.Import_Id__c;
                Database.UpsertResult[] cr = Database.upsert(updTradeLst, f, false);
                system.debug('###cr::'+cr);
                
                for(Database.upsertResult saveRec: cr){
                    if(!saveRec.isSuccess()){
                        for(Database.Error err : saveRec.getErrors())
                            errorString += err;
                    }else{
                        tradeLineSet.add(saveRec.getId());
                    }
                }
                if(errorString != ''){
                    CalloutException e = new CalloutException();
                    e.setMessage(errorString);
                    throw e;
                }
            }
            if(!insTradeLst.isEmpty()){
                system.debug('###currentCreditNameSet::'+currentCreditNameSet);
                system.debug('###currentCreditStreetSet::'+currentCreditStreetSet );
                List<Account> currentAccLst = [Select Id,Name,BillingStreet From Account Where Name IN: currentCreditNameSet AND BillingStreet IN: currentCreditStreetSet AND RecordtypeId = '01241000000jtbg'];
                system.debug('###currentAccLst::'+currentAccLst);
                List<Account> originalAccLst = [Select Id,Name,BillingStreet From Account Where Name IN: originalCreditNameSet AND BillingStreet IN: originalCreditStreetSet AND RecordtypeId = '01241000000jtbg'];
                Map<String,Account> currentAccMap = new Map<String,Account>();
                Map<String,Account> originalAccMap = new Map<String,Account>();
                Account newAcc;
                List<Account> newAccLst = new List<Account>();
                if(!currentAccLst.isEmpty())
                    for(Account acc: currentAccLst)
                    currentAccMap.put(acc.Name+'_'+acc.BillingStreet,acc);
                if(!originalAccLst.isEmpty())
                    for(Account acc: originalAccLst)
                    originalAccMap.put(acc.Name+'_'+acc.BillingStreet,acc);
                system.debug('###currentAccMap::'+currentAccMap);
                system.debug('###originalAccMap::'+originalAccMap);
                Id accountRecordtypeId = SystemUtils.getRecordTypeID('Account','Creditor');
                /*  for(nu_dse__TradeLine__c trade: insTradeLst){
system.debug('###trade.nds_Current_Creditor_Name__ctrade.nds_Current_Creditor_Address1__c::'+trade.nds_Current_Creditor_Name__c+'_'+trade.nds_Current_Creditor_Address1__c);
if(currentAccMap.containsKey(trade.nds_Current_Creditor_Name__c+'_'+trade.nds_Current_Creditor_Address1__c))
trade.nu_dse__New_Creditor__c = currentAccMap.get(trade.nds_Current_Creditor_Name__c+'_'+trade.nds_Current_Creditor_Address1__c).Id;
else if(!currentAccMap.containsKey(trade.nds_Current_Creditor_Name__c+'_'+trade.nds_Current_Creditor_Address1__c)){
if(trade.nds_Current_Creditor_Name__c != NULL){
newAcc = new Account();
newAcc.Name = trade.nds_Current_Creditor_Name__c;
newAcc.BillingStreet = trade.nds_Current_Creditor_Address1__c;
newAcc.BillingCity = trade.nds_Current_Creditor_City__c;
newAcc.BillingState = trade.nds_Current_Creditor_State__c;
newAcc.BillingPostalCode = trade.nds_Current_Creditor_Zip__c;
//newAcc.RecordTypeId = '01241000000jtbg';
newAcc.RecordTypeId = accountRecordtypeId;
newAcc.nu_dse__CFT_Synced__c = TRUE;
newAcc.nu_dse__RAMS_Synced__c = TRUE;
newAcc.nu_dse__GCS_Synced__c = TRUE;
//newAcc.NDS_File_Number__c = trade.FileNumber__c;
newAccLst.add(newAcc);
}    
}
if(originalAccMap.containsKey(trade.nds_Original_Creditor_Name__c+'_'+trade.nds_Original_Creditor_Address1__c))
trade.nu_dse__Original_Creditor__c = originalAccMap.get(trade.nds_Original_Creditor_Name__c+'_'+trade.nds_Original_Creditor_Address1__c).Id;
else if(!originalAccMap.containsKey(trade.nds_Original_Creditor_Name__c+'_'+trade.nds_Original_Creditor_Address1__c)){
if(trade.nds_Original_Creditor_Name__c != NULL){
newAcc = new Account();
newAcc.Name = trade.nds_Original_Creditor_Name__c;
newAcc.BillingStreet = trade.nds_Original_Creditor_Address1__c;
newAcc.BillingCity = trade.nds_Original_Creditor_City__c;
newAcc.BillingState = trade.nds_Original_Creditor_State__c;
newAcc.BillingPostalCode = trade.nds_Original_Creditor_Zip__c;
//newAcc.RecordTypeId = '01241000000jtbg';
newAcc.RecordTypeId = accountRecordtypeId;
newAcc.nu_dse__CFT_Synced__c = TRUE;
newAcc.nu_dse__RAMS_Synced__c = TRUE;
newAcc.nu_dse__GCS_Synced__c = TRUE;
//newAcc.NDS_File_Number__c = trade.FileNumber__c;
newAccLst.add(newAcc);    
}
}               
}



if(!newAccLst.isEmpty()){
currentAccMap = new Map<String,Account>();
//Schema.SObjectField accountIns = Account.NDS_File_Number__c;
/*  Database.saveResult[] accSaveRes = Database.Insert(newAccLst); By Mayur to not create new creditors
system.debug('###accSaveRes::'+accSaveRes);
for(Database.saveResult saveRes: accSaveRes){
if(saveRes.issuccess())
newAccIdSet.add(saveRes.getId());    
}
List<Account> currentNewAccLst = [Select Id,Name,BillingStreet FROM Account WHERE ID IN: newAccIdSet]; 
system.debug('###currentNewAccLst::'+currentNewAccLst);
if(!currentNewAccLst.isEmpty())
for(Account currentAcc: currentNewAccLst)
currentAccMap.put(currentAcc.Name+'_'+currentAcc.BillingStreet,currentAcc);    

system.debug('###currentAccMap::'+currentAccMap);
for(nu_dse__TradeLine__c trade: insTradeLst){
if(currentAccMap.containsKey(trade.nds_Current_Creditor_Name__c+'_'+trade.nds_Current_Creditor_Address1__c))
trade.nu_dse__New_Creditor__c = currentAccMap.get(trade.nds_Current_Creditor_Name__c+'_'+trade.nds_Current_Creditor_Address1__c).Id;  
if(currentAccMap.containsKey(trade.nds_Original_Creditor_Name__c+'_'+trade.nds_Original_Creditor_Address1__c))
trade.nu_dse__Original_Creditor__c = currentAccMap.get(trade.nds_Original_Creditor_Name__c+'_'+trade.nds_Original_Creditor_Address1__c).Id;  
}
}*/
                system.debug('###insTradeLsttttttt::'+insTradeLst);
                if(nextBatchTimings.Load_Tradelines__c == true){
                    Database.saveResult[] savRes = Database.Insert(insTradeLst,false);
                    system.debug('###savResinssss::'+savRes);
                    
                    for(Database.saveResult saveRec: savRes){
                        if(!saveRec.isSuccess()){
                            for(Database.Error err : saveRec.getErrors())
                                errorString += err;
                        }else{
                            tradeLineSet.add(saveRec.getId());
                        }
                    }
                    if(errorString != '' && !Test.isRunningTest()){
                        CalloutException e = new CalloutException();
                        e.setMessage(errorString);
                        throw e;
                    }
                }   
            } 
        }
        
        
        
        
        system.debug('###tradeLineSet::'+tradeLineSet);           
        List<nu_dse__TradeLine__c> tradeLst = [Select Id,Name, Import_Id__c,FileNumber__c FROM nu_dse__TradeLine__c where Id IN: tradeLineSet];
        system.debug('###tradeLst::'+tradeLst); 
        for(nu_dse__TradeLine__c trade: tradeLst)
            TradelineMap.put(trade.Import_Id__c, trade);  
        
        system.debug('###TradelineMap::'+TradelineMap);
        
        system.debug('###offerAllRecLst::'+offerAllRecLst);
        for(nu_dse__Offer__c offer: offerAllRecLst){
            if(TradelineMap.containsKey(offer.DebtId__c))
                Offer.nu_dse__TradeLine__c = TradelineMap.get(offer.DebtId__c).Id;
        }
        if(!offerAllRecLst.isEmpty() && nextBatchTimings.Load_Offers__c == true){
            system.debug('###offerAllRecLst::'+offerAllRecLst);
            
            Schema.SObjectField offer = nu_dse__Offer__c.NDS_Offer_Id__c;
            
            Database.UpsertResult[] offerResults = Database.upsert(offerAllRecLst, offer, false);
            System.Debug ('=========='+offerResults );
            
            
            for(Database.UpsertResult saveRec: offerResults){
                if(!saveRec.isSuccess()){
                    for(Database.Error err : saveRec.getErrors())
                        errorString += err;
                }
            }
            if(errorString != '' && !Test.isRunningTest()){
                CalloutException e = new CalloutException();
                e.setMessage(errorString);
                throw e;
            }
        }
        
        List<nu_dse__Offer__c> offerLst = [Select Id,NDS_OFFER_ID__C FROM nu_dse__Offer__c WHERE NDS_OFFER_ID__C IN: offerIdSet];
        Map<String,nu_dse__Offer__c> offerMap = new Map<String,nu_dse__Offer__c>();
        for(nu_dse__Offer__c offer: offerLst)
            offerMap.Put(offer.NDS_OFFER_ID__C, offer);
        system.debug('###offerMap::'+offerMap);
        for(nu_dse__Payment__c pays: paymentsLst){
            if(offerMap.containsKey(pays.offerId__c))
                pays.nu_dse__Offer__c = offerMap.get(pays.offerId__c).Id;
        }
        if(!paymentsLst.isEmpty() && nextBatchTimings.Load_Settlements__c == true){
            system.debug('###paymentsLst::'+paymentsLst);
            Schema.SObjectField payUpsrt = nu_dse__Payment__c.Attorney_Payment_Id__c;
            Database.UpsertResult[] offerResults = Database.upsert(paymentsLst, payUpsrt, false); 
            system.debug('###offerResults::'+offerResults);
            
            for(Database.UpsertResult saveRec: offerResults){
                if(!saveRec.isSuccess()){
                    for(Database.Error err : saveRec.getErrors())
                        errorString += err;
                }
            }
            if(errorString != ''){
                CalloutException e = new CalloutException();
                e.setMessage(errorString);
                throw e;
            }
        }
        /*}catch(Exception e){
system.debug('###Exception::'+e.getMessage());

System_Log__c SL = new System_Log__c();
SL.Id = sysLogId;
SL.Exception_Description__c = e.getMessage()+ '\n\n' + e.getStackTraceString();
SL.Status__c = 'Failed';
Update SL;
System.abortJob(BatchjobId);
} */
    }
    
}