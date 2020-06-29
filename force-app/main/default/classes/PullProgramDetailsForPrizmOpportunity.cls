@RestResource(urlMapping='/pullProgramDetailsForPrizmOpportunity/*')
global with sharing class PullProgramDetailsForPrizmOpportunity {

    @HttpPost
    global static String doPostProgramPull() {
        
        //Retrieve the response and deserialize the Ids
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;       
        String jsonStr =  req.requestBody.toString();
        List<String> idSet = (List<String>)JSON.deserialize(jsonStr,List<String>.class);
        String returnJSON = null; 
        if(idSet == null || idSet.size() == 0)
            return returnJSON;
        // Declare and instantiate the wrapper classes and corresponding lists for return values.
        opportunityJsonClass oppJson = new opportunityJsonClass();
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_id__c, Name, Program_Type__c, nu_dse__Account__r.Name, nu_dse__Account__r.nu_dse__Co_First_Name__c, 
                                                       nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Trust_Account_Balance__c, nu_dse__Program_Status__c, nu_dse__Account__r.nu_dse__External_RAMS_ID__c, nu_dse__Account__r.nu_dse__External_CFT_ID__c, nu_dse__Account__r.nu_dse__External_GCS_ID__c, Portfolio__r.Name, Attorney__c, nu_dse__Account__r.BoxFolderId__c, nu_dse__Account__r.PersonBirthDate,  nu_dse__Account__r.PersonMailingCountry, nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.PersonEmail,nu_dse__Account__r.PersonMailingStreet,nu_dse__Account__r.ClientNumber__c,nu_dse__Account__r.MiddleName,nu_dse__Account__r.nu_dse__SSN__c,nu_dse__Account__r.PersonMailingCity,nu_dse__Account__r.PersonMailingPostalCode,nu_dse__Account__r.PersonHomePhone,nu_dse__Account__r.PersonMobilePhone,nu_dse__Account__r.nu_dse__Work_Phone__c,nu_dse__Account__r.FirstName,nu_dse__Account__r.LastName,nu_dse__Account__r.nu_dse__CO_Email_Address__c,nu_dse__Account__r.nu_dse__Co_Phone__c,nu_dse__Account__r.nu_dse__Co_SSN__c,nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c, 
                                                       Monthly_Legal_Fee__c,nu_dse__Monthly_Processor_Fee__c,nu_dse__Monthly_Third_Party_Fees__c,Subscribed_to_ALLG__c,nu_dse__Payment_Frequency__c,nu_dse__Reoccurring_Debit_Day__c,nu_dse__Twice_Monthly_Reoccuring_Day__c, 
                                                       Current_Accumulation__c,Versara_First_Funding_Date__c,Beginning_DA_Balance__c,Addn_l_Drafts_During_Funding__c,Current_Admin_Fee__c,Paid_Creditor_Payments__c,Total_Fees__c,Expected_Accumulation__c,Expected_Admin_Fee__c,Total_Creditor_Payments__c,Remaining_Accumulation__c,Remaining_Admin_Fee__c,Remaining_Creditor_Payments__c,Current_Maintenance_Fee__c,nu_dse__Expected_Maintenance_Fees__c,Remaining_Maintenance_Fee__c,Current_Processor_Fee__c,Remaining_Processor_Fee__c,Expected_Processor_Fee__c,Current_Program_Fee__c,Expected_Program_Fee__c,Remaining_Program_Fee__c,Current_Retainer_Fee__c,Remaining_Retainer_Fee__c,Expected_Retainer_Fee__c,Current_Service_Fee__c,Remaining_Service_Fee__c,Expected_Service_Fee__c,Current_Third_Party_Fee__c,Remaining_Third_Party_Fee__c,Expected_Third_Party_Fee__c
                                                       , nu_dse__Processor__r.Name,nu_dse__Processor__r.nu_dse__Type__c,
                                                       //Fields for Draft Fees - DLM 37
                                                       Draft_Amount__c, Paid_Accumulation__c, Paid_Admin_Fee__c,  Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                       Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, Total_Admin_Fee__c,  
                                                       Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                       Total_Third_Party_Fee__c
                                                       
                                                       FROM nu_dse__Program__c Where Id  IN :idSet ];
        oppJson = populateOpportunityMappingsFromProgram(programDetailsList);
       if(oppJson != null)
            	returnJSON = System.JSON.serialize(oppJson, true);
        System.debug(loggingLevel.ERROR, returnJSON);
        return returnJSON;
    }
    
     public static opportunityJsonClass populateOpportunityMappingsFromProgram(List<nu_dse__Program__c> programDetailsList){
        List<Id> programIds = new List<Id>();
        opportunityJsonClass oppJson = new opportunityJsonClass();
        List<opportunityJsonClass.cls_Opportunity> oppClsLst = new List<opportunityJsonClass.cls_Opportunity>();
        if(programDetailsList != null){
            opportunityJsonClass.cls_Opportunity oppCls;

            for(nu_dse__Program__c program: programDetailsList){
                programIds = new List<Id>();
                programIds.add(program.Id);

                oppCls = new opportunityJsonClass.cls_Opportunity();
                oppCls.AccountName = program.nu_dse__Account__r.Name;
                oppCls.PersonBirthDate= String.valueOf(program.nu_dse__Account__r.PersonBirthDate);
                oppCls.FileNumber = program.Import_ID__c;
                oppCls.CoFirstName = program.nu_dse__Account__r.nu_dse__Co_First_Name__c;
                oppCls.CoLastName = program.nu_dse__Account__r.nu_dse__Co_Last_Name__c;
                oppCls.CoSSN = program.nu_dse__Account__r.nu_dse__Co_SSN__c;
                if(program.nu_dse__Account__r.nu_dse__Co_Date_Of_Birth__c != null)
                    oppCls.CoDateOfBirth = String.valueOf(program.nu_dse__Account__r.nu_dse__Co_Date_Of_Birth__c);
                oppCls.CoEmailAddress = program.nu_dse__Account__r.nu_dse__Co_Email_Address__c;
                oppCls.CoPhone = program.nu_dse__Account__r.nu_dse__Co_Phone__c;
                oppCls.BoxFolderId = program.nu_dse__Account__r.BoxFolderId__c;                
                oppCls.ProgramName = program.Name;
                oppCls.ProgramId = program.Id;
                oppCls.ProgramType= program.Program_Type__c;
                oppCls.ProgramStatus = program.nu_dse__Program_Status__c;
                oppCls.ApplicantState= program.nu_dse__Account__r.PersonMailingState;
                oppCls.CashInDedicatedAccount = String.valueOf(program.nu_dse__Trust_Account_Balance__c);  //PDI-730
                oppCls.CurrentBalance = String.valueOf(program.nu_dse__Trust_Account_Balance__c);
                oppCls.TwiceMonthlyReoccuringDay = String.valueOf(program.nu_dse__Twice_Monthly_Reoccuring_Day__c);
                oppCls.ReoccurringDebitDay = String.valueOf(program.nu_dse__Reoccurring_Debit_Day__c);
                oppCls.TotalFee = String.valueOf(program.Total_Fees__c);   //PDI-348
                oppCls.BegDaBalance=String.valueOf(program.Beginning_DA_Balance__c);
                oppCls.AddnlDraftFundng=String.valueOf(program.Addn_l_Drafts_During_Funding__c);
                oppCls.VersaraFundDate=String.valueOf(program.Versara_First_Funding_Date__c);                 
                oppCls.PersonBirthDate= String.valueOf(program.nu_dse__Account__r.PersonBirthDate);
                oppCls.PersonMailingState = program.nu_dse__Account__r.PersonMailingState;
                oppCls.PersonMailingCountry = program.nu_dse__Account__r.PersonMailingCountry;
                oppCls.PersonEmail = program.nu_dse__Account__r.PersonEmail;
                oppCls.PersonMailingStreet = program.nu_dse__Account__r.PersonMailingStreet;
                oppCls.ClientNumber = program.nu_dse__Account__r.ClientNumber__c;
                oppCls.MiddleName = program.nu_dse__Account__r.MiddleName;
                oppCls.AccountSSN = program.nu_dse__Account__r.nu_dse__SSN__c;
                oppCls.PersonMailingCity = program.nu_dse__Account__r.PersonMailingCity;
                oppCls.PersonMailingPostalCode = program.nu_dse__Account__r.PersonMailingPostalCode;
                oppCls.PersonHomePhone = program.nu_dse__Account__r.PersonHomePhone;
                oppCls.PersonMobilePhone = program.nu_dse__Account__r.PersonMobilePhone;
                oppCls.AccountWorkPhone = program.nu_dse__Account__r.nu_dse__Work_Phone__c;
                oppCls.FirstName = program.nu_dse__Account__r.FirstName;
                oppCls.LastName = program.nu_dse__Account__r.LastName;
                oppCls.ProcessorName = program.nu_dse__Processor__r.nu_dse__Type__c;
                
                if(oppCls.ProcessorName == 'RAMS'){
                    oppCls.PaymentAccountNumber = program.nu_dse__Account__r.nu_dse__External_RAMS_ID__c;
                    oppCls.ProcessorName = 'RAM';
                } else if(oppCls.ProcessorName == 'GCS'){
                    oppCls.PaymentAccountNumber = program.nu_dse__Account__r.nu_dse__External_GCS_ID__c;
                } else if(oppCls.ProcessorName == 'CFT'){
                    oppCls.PaymentAccountNumber = program.nu_dse__Account__r.nu_dse__External_CFT_ID__c;
                }
                
                if(program.Attorney__c){
                    oppCls.PortfolioType = 'Attorney';
                    
                }
                else{
                    oppCls.PortfolioType = 'Timberline';
                }
                oppCls.LawFirmName = program.Portfolio__r.Name;
                oppCls.MonthlyLegalFee = String.valueOf(program.Monthly_Legal_Fee__c);
                oppCls.MonthlyProcessorFee = String.valueOf(program.nu_dse__Monthly_Processor_Fee__c);
                oppCls.MonthlyThirdPartyFees = String.valueOf(program.nu_dse__Monthly_Third_Party_Fees__c);
                oppCls.SubscribedToALLG = String.valueOf(program.Subscribed_to_ALLG__c);
                oppCls.RecurringDebitDay = String.valueOf(program.nu_dse__Reoccurring_Debit_Day__c);
                oppCls.TwiceMonthlyRecurringDay = String.valueOf(program.nu_dse__Twice_Monthly_Reoccuring_Day__c);

                 NuDebtProgramWrapper nuDebtProgramWrapper = new  NuDebtProgramWrapper();
            List<opportunityJsonClass.cls_Payments> paymentsClsLst;
            List<opportunityJsonClass.cls_TradeLines> tradeLineLst;
            System.debug('****'+programIds);           
            
            //--------------------------------
            // Get Tradelines details
            // --------------------------------           
            nuDebtProgramWrapper.tradelines = PullDataForPrizmLead.getTradeLineDetails(programIds);
            System.debug('*****Tradelist'+ nuDebtProgramWrapper.tradelines);
            oppCls.Tradelines = populateOppTradelinesDetails(nuDebtProgramWrapper.tradelines);
            //--------------------------------
            // Get Payment Details
            //--------------------------------            
            nuDebtProgramWrapper.payments = PullDataForPrizmLead.getPaymentDetails(programIds);
            if(nuDebtProgramWrapper.payments != null)
            	oppCls.Payments = populateOppPaymentDetails(nuDebtProgramWrapper.payments);
            //-----------------------
            // Get Bank Account details
            oppCls.BankAccounts = populateOppBankAccountDetails(programIds);
            //--------------------------------
            // Get Draft fees Details
            //--------------------------------            
            if(nuDebtProgramWrapper.payments != null)
                    oppCls = populateOppDraftFeesDetails(oppCls, program);
            //-----------------------
            
                oppClsLst.add(oppCls);             
                
            }
            
           
        }
        
       // 
        
        oppJson.Opportunity = oppClsLst;
        return oppJson;
    }
    //--------------------------------------------------------------------------------
    public static opportunityJsonClass.cls_Opportunity populateOppDraftFeesDetails(opportunityJsonClass.cls_Opportunity oppCls, nu_dse__Program__c program){
        if(program != null){
             oppCls.PaidAccumulation = String.valueOf(program.Current_Accumulation__c);
            oppCls.DraftAmt = String.valueOf(program.Draft_Amount__c);   //@PDI-714
            oppCls.PaidAdminFee = String.valueOf(program.Current_Admin_Fee__c );
            oppCls.PaidCreditorPayments = String.valueOf(program.Paid_Creditor_Payments__c);
            oppCls.PaidMaintenanceFee = String.valueOf(program.Current_Maintenance_Fee__c);
            oppCls.PaidProcessorFee = String.valueOf(program.Current_Processor_Fee__c);
            oppCls.PaidProgramFee = String.valueOf(program.Current_Program_Fee__c);
            oppCls.PaidRetainerFee = String.valueOf(program.Current_Retainer_Fee__c);
            oppCls.PaidServiceFee= String.valueOf(program.Current_Service_Fee__c);
            oppCls.PaidThirdPartyFee = String.valueOf(program.Current_Third_Party_Fee__c);
            oppCls.TotalAccumulation = String.valueOf(program.Expected_Accumulation__c);
            oppCls.TotalAdminFee = String.valueOf(program.Expected_Admin_Fee__c);
            oppCls.TotalCreditorPayments = String.valueOf(program.Total_Creditor_Payments__c);
            oppCls.TotalMaintenanceFee = String.valueOf(program.nu_dse__Expected_Maintenance_Fees__c);
            oppCls.TotalProcessorFee= String.valueOf(program.Expected_Processor_Fee__c);
            oppCls.TotalProgramFee = String.valueOf(program.Expected_Program_Fee__c);
            oppCls.TotalRetainerFee = String.valueOf(program.Expected_Retainer_Fee__c);
            oppCls.TotalServiceFee = String.valueOf(program.Expected_Service_Fee__c);
            oppCls.TotalThirdPartyFee = String.valueOf(program.Expected_Third_Party_Fee__c);
            oppCls.RemainingAccumulation = String.valueOf(program.Remaining_Accumulation__c);
            oppCls.RemainingAdminFee = String.valueOf(program.Remaining_Admin_Fee__c);
            oppCls.RemainingCreditorPayments = String.valueOf(program.Remaining_Creditor_Payments__c);
            oppCls.RemainingMaintenanceFee = String.valueOf(program.Remaining_Maintenance_Fee__c);
            oppCls.RemainingProcessorFee = String.valueOf(program.Remaining_Processor_Fee__c);
            oppCls.RemainingProgramFee = String.valueOf(program.Remaining_Program_Fee__c);
            oppCls.RemainingRetainerFee = String.valueOf(program.Remaining_Retainer_Fee__c);
            oppCls.RemainingServiceFee = String.valueOf(program.Remaining_Service_Fee__c);
            oppCls.RemainingThirdPartyFee = String.valueOf(program.Remaining_Third_Party_Fee__c);        
        }
        return oppCls;
    }
    //--------------------------------------------------------------------------------
    public static List<opportunityJsonClass.cls_Payments> populateOppPaymentDetails(List<NuDebtProgramWrapper.PaymentsWrapper> payments){
        
        List<opportunityJsonClass.cls_Payments> paymentsClsLst = new List<opportunityJsonClass.cls_Payments>();
        opportunityJsonClass.cls_Payments paymentsCls;
         for(NuDebtProgramWrapper.PaymentsWrapper pay: payments){
                paymentsCls = new opportunityJsonClass.cls_Payments();
                paymentsCls.Id = pay.paymentsId;
                paymentsCls.Name = pay.Name;
                paymentsCls.FileNumber = pay.fileNumber;
                paymentsCls.NFSDate = pay.NFSDate;
                paymentsCls.PaymentStatus = pay.PaymentStatus;
                paymentsCls.PaymentType = pay.PaymentType;
                paymentsCls.ScheduleDate = pay.ScheduleDate;
                paymentsCls.TotalAmount = pay.TotalAmount;
                paymentsCls.TansMethod = pay.TransMethod;
                paymentsCls.TransactionStatus = pay.TransactionStatus;
                System.debug('##paymentsCls.TransactionStatus:'+paymentsCls.TransactionStatus +'trade.isNewTrade__c:'+paymentsCls.TransactionStatus);
				paymentsCls.PayRecType = pay.PayRecType;
              
                
                paymentsClsLst.add(paymentsCls);   
            }
            return paymentsClsLst;        
    }
    
      public static List<opportunityJsonClass.cls_Tradelines> populateOppTradelinesDetails(List<NuDebtProgramWrapper.TradelinesWrapper> tradelines){
        
          
        List<opportunityJsonClass.cls_Tradelines> tradeLineLst=new list<opportunityJsonClass.cls_Tradelines>();  
          opportunityJsonClass.cls_TradeLines tradeLineCls = new opportunityJsonClass.cls_TradeLines();
          List<NuDebtProgramWrapper.PaymentsWrapper> oppSetPaymentLst = new List<NuDebtProgramWrapper.PaymentsWrapper>();
          List<opportunityJsonClass.cls_SettelmentPayments> settelmentPaymentClsLst = new List<opportunityJsonClass.cls_SettelmentPayments>();
            for(NuDebtProgramWrapper.TradelinesWrapper trade:tradelines){
                tradeLineCls = new opportunityJsonClass.cls_TradeLines();
                tradeLineCls.Id = trade.tradelinesId;
                tradeLineCls.Name = trade.Name;
                tradeLineCls.FileNumber = trade.fileNumber;  
                tradeLineCls.CurrentStage = trade.CurrentStage;
                tradelineCls.LitigationStage = trade.LitigationStage;
                tradelineCls.DNLEstimatedSettlement = trade.DNLEstimatedSettlement;
                tradeLineCls.NewCreditor = trade.NewCreditor;
                
                tradeLineCls.OriginalAccountNumber = trade.OriginalAccountNumber;
                
                tradeLineCls.isNewTrade='true';  //DV-60
                tradeLineCls.SFSCurrentBalance = trade.SFSCurrentBalance;   
                tradeLineCls.NewAccountNumber = trade.NewAccountNumber;  
                tradeLineCls.isNewTrade='false';  //DV-60
                tradeLineCls.TradeImportID = trade.TradeImportId; 
                tradeLineCls.OriginalDebt = trade.OriginalDebt;
                tradeLineCls.OriginalCreditorName = trade.OriginalCreditorName;
                tradeLineCls.OfferStatus = trade.OfferStatus;
                tradeLineCls.OfferAmount = trade.OfferAmount;   //DV-129 
                tradeLineCls.OfferProgramFee = trade.OfferProgramFee ;  //DV-129
                tradelineCls.DNLFundsForFees = trade.DNLFundsForFees;
                tradelineCls.DNLFundstoClient = trade.DNLFundstoClient;
                tradelineCls.DNLDisbursementDate = trade.DNLDisbursementDate;
                tradelineCls.DNLDisbursementAmount = trade.DNLDisbursementAmount;
                tradelineCls.DNLSettlementFees = trade.DNLSettlementFees;               
                tradelineCls.SettlementAmountPaid = trade.SettlementAmountPaid;
                tradelineCls.AmountPaid = trade.AmountPaid;
                tradelineCls.isLastDebt = trade.isLastDebt;  //PDI-1019
                tradelineCls.DNLfirstSettelment = trade.DNLfirstSettelment;  //PDI-1043
                oppSetPaymentLst = trade.settlementPayments;
               if(oppSetPaymentLst != null){                   
                        settelmentPaymentClsLst = new List<opportunityJsonClass.cls_SettelmentPayments>();
                        for(NuDebtProgramWrapper.PaymentsWrapper pay: oppSetPaymentLst){
                            opportunityJsonClass.cls_SettelmentPayments settelmentPaymentCls = new opportunityJsonClass.cls_SettelmentPayments();    
                            settelmentPaymentCls.Id = pay.paymentsId;
                            settelmentPaymentCls.FileNumber = pay.FileNumber;
                            settelmentPaymentCls.PaymentStatus = pay.PaymentStatus;
                            settelmentPaymentCls.TransactionMethod = pay.TransMethod;
                            settelmentPaymentCls.PaymentType = pay.PaymentType;
                            settelmentPaymentCls.TotalAmount = pay.TotalAmount;
                            settelmentPaymentCls.ScheduleDate = pay.ScheduleDate;
                            settelmentPaymentClsLst.add(settelmentPaymentCls);
                            
                        }  
                        tradeLineCls.SettelmentPayments =  settelmentPaymentClsLst;
                }
                tradeLineLst.add(tradeLineCls);
            }
           return tradeLineLst;
    }
    
    public static opportunityJsonClass.cls_BankAccount populateOppBankAccountDetails(List<Id> programIds){
        
        List<nu_dse__Bank_Account__c> bankAccountList = [Select Id,Name,Opportunity__c,nu_dse__Account__c,nu_dse__Account_Type__c,nu_dse__Bank_Account_Number__c,nu_dse__Bank_Name__c,nu_dse__City__c,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c,nu_dse__State__c,nu_dse__Telephone__c,nu_dse__Zip__c from nu_dse__Bank_Account__c where nu_dse__Program__c IN :programIds];
        
        List<opportunityJsonClass.cls_BankAccount> bankAccountclsList = new List<opportunityJsonClass.cls_BankAccount>();
		opportunityJsonClass.cls_BankAccount bankAccountcls = new opportunityJsonClass.cls_BankAccount();
        if(bankAccountList != null && !bankAccountList.isEmpty()){
            for(nu_dse__Bank_Account__c bankAccount:bankAccountList){
                bankAccountcls.BankAccountId = bankAccount.Id;
                bankAccountcls.Name = bankAccount.Name;
                bankAccountcls.Account = bankAccount.nu_dse__Account__c;
                bankAccountcls.AccountType = bankAccount.nu_dse__Account_Type__c;
                bankAccountcls.BankAccountNumber= bankAccount.nu_dse__Bank_Account_Number__c;
                bankAccountcls.BankName= bankAccount.nu_dse__Bank_Name__c;
                bankAccountcls.City= bankAccount.nu_dse__City__c;
                bankAccountcls.HolderName= bankAccount.nu_dse__Holder_s_Name__c;
                bankAccountcls.RoutingNumber= bankAccount.nu_dse__Routing_Number__c;
                bankAccountcls.State = bankAccount.nu_dse__State__c;
                bankAccountcls.Telephone = bankAccount.nu_dse__Telephone__c;
                bankAccountcls.zip=bankAccount.nu_dse__Zip__c;  //PDI-759
                bankAccountclsList.add(bankAccountcls);
            }
        }
        return bankAccountcls;
    }
}