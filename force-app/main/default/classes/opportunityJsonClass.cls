public class opportunityJsonClass{
    public cls_Opportunity[] Opportunity;
    public class cls_Opportunity {
        public String Id;   //0060S0000068D7WQAU
        public String Name; //RameshNewOpp4
        public String FileNumber;   //65165161651651
        public String CloseDate;    //2018-08-03
        public String Stage;    //Prospecting
        public String AccountName;
        public String CampaignType;   //@PDI-687
        public String CoFirstName;
        public String CoLastName;
        public String CoSSN;
        public String CoDateOfBirth;
        public String CoEmailAddress;
        public String CoPhone;
        public String CoCity; //DV-336
        public String CoState;
        public String CoCountry;
        public String CoPostalCode;
        public String CoAddrline1;
        
        public String ProgramName;
        public String ProgramId;
        public string ProgramType;
        public String ProgramStatus;
        public string EnrollmentDate;
        public string AddnlMonthsWithLoan;
        public string UnsettledDebt;
        public string ClientAge;
        public String ProgramLength;
        public String LoanAmount;
        public String LoanTerm;
        public String DebtCount;
        public String ApplicantState;
        public String CurrentBalance;
        public String RemainingMonths;
        public String SalesRep;
        public String TwiceMonthlyReoccuringDay;
        public String ReoccurringDebitDay;
        public String LastDraft;
        public String LeadGroup;
        
        public String PaidAccumulation;
        public String DraftAmt;  //@PDI-714
        public String PaidAdminFee;
        public String PaidCreditorPayments;
        public String PaidMaintenanceFee;
        public String PaidProcessorFee;
        public String PaidProgramFee;
        public String PaidRetainerFee;
        public String PaidServiceFee;
        public String PaidThirdPartyFee;
        public String TotalAccumulation;
        public String TotalAdminFee;
        public String TotalCreditorPayments;
        public String TotalMaintenanceFee;
        public String TotalProcessorFee;
        public String TotalProgramFee;
        public String TotalRetainerFee;
        public String TotalServiceFee;
        public String TotalThirdPartyFee;
        public String TotalFee;       //@
        public String BegDaBalance;  //PDI-1044
        public String AddnlDraftFundng;  //PDI-1044
        public String VersaraFundDate;  //PDI-1044
        
        public String RemainingAccumulation;
        public String RemainingAdminFee;
        public String RemainingCreditorPayments;
        public String RemainingMaintenanceFee;
        public String RemainingProcessorFee;
        public String RemainingProgramFee;
        public String RemainingRetainerFee;
        public String RemainingServiceFee;
        public String RemainingThirdPartyFee;
        
        public String FirstName;
        public String LastName;
        public String PersonBirthDate;
        public String PersonMailingState;
        public String PersonMailingCountry;
        public String PersonEmail;
        public String PersonMailingStreet;
        public String ClientNumber;
        public String MiddleName;
        public String AccountSSN;
        public String PersonMailingCity;
        public String PersonMailingPostalCode;
        public String PersonHomePhone;
        public String PersonMobilePhone;
        public String AccountWorkPhone;
        //public String Phone; //@
        public String BoxFolderId;
        public String PortfolioType;
        public String ProcessorName;
        public String LawFirmName;
        public String PaymentAccountNumber;
        
        public String UnpaidProgramFeeWithDNL;
        public String UnpaidProgramFeeWODNL;
        public String CashInDedicatedAccount;
        public String Segment;  
        
        
        public cls_Payments[] Payments;
        public cls_TradeLines[] TradeLines;
        Public cls_BankAccount BankAccounts;
        public Task[] Tasks;
        
        //Pull only field
        public String MonthlyLegalFee;
        public String MonthlyProcessorFee;
        public String MonthlyThirdPartyFees;
        public String SubscribedToALLG;
        public String PaymentFrequency;
        public String RecurringDebitDay;
        public String TwiceMonthlyRecurringDay;
        
        public cls_Opportunity(){
            Id ='';
            Name ='';
            FileNumber = '';
            CloseDate ='';
            Stage = '';
            AccountName = '';
            CoFirstName = '';
            CoLastName ='';
            CoSSN = '';
            CoDateOfBirth = '';
            CoEmailAddress = '';
            CoPhone = '';
            CoCity='';
            CoState='';
            CoCountry='';
            CoPostalCode='';
            CoAddrline1='';
            
            ProgramId = '';
            ProgramType = '';
            ProgramStatus = '';
            ProgramName = '';
            EnrollmentDate = '';
            AddnlMonthsWithLoan = '';
            UnsettledDebt = '';
            ClientAge ='';
            ProgramLength ='';
            LoanAmount = '';
            CampaignType='';  //@PDI-687
            LoanTerm = '';
            DebtCount = '';
            ApplicantState = '';
            UnpaidProgramFeeWithDNL = '';
            UnpaidProgramFeeWODNL = '';
            CashInDedicatedAccount = '';
            CurrentBalance = '';
            RemainingMonths = '';
            SalesRep = '';
            TwiceMonthlyReoccuringDay = '';
            ReoccurringDebitDay = '';
            LastDraft = '';
            LeadGroup = '';
            
            PaidAccumulation = '';
            DraftAmt='';  //@PDI-714
            PaidAdminFee = '';
            PaidCreditorPayments = '';
            PaidMaintenanceFee = '';
            PaidProcessorFee = '';
            PaidProgramFee = '';
            PaidRetainerFee = '';
            PaidServiceFee= '';
            PaidThirdPartyFee = '';
            TotalAccumulation = '';
            TotalAdminFee = '';
            TotalCreditorPayments = '';
            TotalMaintenanceFee = '';
            TotalProcessorFee='';
            TotalProgramFee = '';
            TotalRetainerFee = '';
            TotalServiceFee = '';
            TotalThirdPartyFee = '';
            TotalFee='';     
            BegDaBalance='';
            AddnlDraftFundng='';
            VersaraFundDate='';
            RemainingAccumulation = '';
            RemainingAdminFee = '';
            RemainingCreditorPayments = '';
            RemainingMaintenanceFee = '';
            RemainingProcessorFee = '';
            RemainingProgramFee ='';
            RemainingRetainerFee = '';
            RemainingServiceFee = '';
            RemainingThirdPartyFee = '';
            Segment=''; 
            
                        
            FirstName = '';
            LastName = '';
            PersonBirthDate= '';
            PersonMailingState = '';
            PersonMailingCountry = '';
            PersonEmail = '';
            PersonMailingStreet = '';
            ClientNumber = '';
            MiddleName = '';
            AccountSSN = '';
            PersonMailingCity = '';
            PersonMailingPostalCode = '';
            PersonHomePhone = '';
            PersonMobilePhone = '';
            AccountWorkPhone = '';
           // Phone='';
            BoxFolderId = '';
            PortfolioType = '';
            ProcessorName = '';
            LawfirmName = '';
            PaymentAccountNumber = '';
            
            //pull only fees
            MonthlyLegalFee = '';
            MonthlyProcessorFee = '';
            MonthlyThirdPartyFees = '';
            SubscribedToALLG = '';
            PaymentFrequency = '';
            RecurringDebitDay = '';
            TwiceMonthlyRecurringDay = '';
        }
        
    }
    public class cls_Payments {
        public String Id;   //a0I0S000000gavEUAQ
        public String Name; //2299482
        public String FileNumber;
        public string paymentImportID;
        public String NFSDate;
        public String PaymentStatus;
        public String PaymentType;
        public String ScheduleDate;
        public String TotalAmount;
        public String TansMethod;
        public String TransactionStatus;
        //public boolean isSettlement; //@PDI-694
        public String PayRecType;  //PDI-743
        
        public cls_Payments(){
            Id = '';
            Name = '';
            FileNumber = '';
            paymentImportID = '';
            NFSDate = '';
            PaymentStatus = '';
            PaymentType = '';
            ScheduleDate = '';
            TotalAmount = '';
            TansMethod = '';    
            TransactionStatus = '';
            //isSettlement=False;  //@PDI-694
            PayRecType='';
        }
    }
    public class cls_TradeLines {
        public String Id;   //a0Q0S000000UcR7UAK
        public String Name; //TL-00151106
        public String FileNumber;
        public string tradeImportID;
        public String OriginalDebt;    //5124.00
        public String OfferAmount;  //0.00
        public String OfferStatus;  //Accepted
        public String OfferProgramFee;
        public String CurrentStage;
        public String LitigationStage;
        public String DNLEstimatedSettlement;
        public String NewAccountNumber;
        public string NewCreditor;
        public string OriginalAccountNumber;
        public string OriginalCreditorName;
        public string SFSCurrentBalance;
        public String DNLFundstoClient;
        public String DNLFundsforFees;
        public String DNLDisbursementAmount;
        public String DNLDisbursementDate;
        public String DNLSettlementFees;
        public String SettlementAmountPaid;
        public String AmountPaid;
        public String isLastDebt;
        public String DNLfirstSettelment; //PDI-1043
        public String isNewTrade;  //DV-60
        public cls_SettelmentPayments[] SettelmentPayments;
        
        public cls_TradeLines(){
            Id = '';
            Name = '';
            FileNumber = '';    
            tradeImportID = '';
            OriginalDebt = '';
            OfferAmount = '';  //0.00
            OfferStatus = '';  //Accepted
            OfferProgramFee = '';
            CurrentStage = '';
            LitigationStage = '';
            DNLEstimatedSettlement = '';
            NewAccountNumber = '';
            NewCreditor = '';
            OriginalAccountNumber = '';
            OriginalCreditorName = '';
            SFSCurrentBalance = '';
            DNLFundstoClient = '';
            DNLFundsforFees = '';
            DNLDisbursementAmount = '';
            DNLDisbursementDate = '';
            DNLSettlementFees = '';
            SettlementAmountPaid = '';
            AmountPaid = '';
            isLastDebt='';
            DNLfirstSettelment='';
            isNewTrade='';
        }
    }
    public class cls_SettelmentPayments {
        public String Id;   //a0I0S000000gbEJUAY
        public String AttorneyPaymentId;    //2300665
        public String FileNumber;
        public String ScheduleDate;
        public String PaymentStatus;
        public String TotalAmount;
        public String PaymentType;
        public String TransactionMethod;
        
        public cls_SettelmentPayments(){
            Id = '';
            AttorneyPaymentId = '';
            FileNumber = '';
            ScheduleDate = '';
            PaymentStatus = '';
            TotalAmount = '';
            PaymentType = '';
            TransactionMethod = '';
        }
    }
    
    public class cls_BankAccount{
        
        public string Account;
        public string AccountType;
        public string Name;
        public string BankAccountNumber;
        public string BankName;
        public string City;
        public string HolderName;
        public string RoutingNumber;
        public string Telephone;
        public string State;
        public string zip;
        public string BankAccountId;
        
        public cls_BankAccount(){
            Account = '';
            AccountType= '';
            Name= '';
            BankAccountNumber= '';
            BankName= '';
            City= '';
            HolderName= '';
            RoutingNumber= '';
            Telephone = '';
            State ='';
            zip = '';
            BankAccountId = '';
        }
    }
    
    public class cls_Task{
        public String subject;
        public String ActivityDate;
        public String OwnerId;
        public String Description;
        public STring WhatId;
        public String Status;
        public String Task_Category;
        
        public cls_Task(){
            subject = '';
            ActivityDate = '';
            OwnerId = '';
            Description = '';
            WhatId = '';
            Status = '';
            Task_Category='';
        }
    }
    
    public static opportunityJsonClass parse(String json){
        return (opportunityJsonClass) System.JSON.deserialize(json, opportunityJsonClass.class);
    }

    /*static testMethod void testParse() {
        String json=        '{"Opportunity":[{"Id":"0060S0000068D7WQAU","Name":"RameshNewOpp4","FileNumber":"65165161651651","CloseDate":"2018-08-03","Stage":"Prospecting"}]}';
        fromJSON obj = parse(json);
        System.assert(obj != null);
    }*/
}