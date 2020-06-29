@RestResource(urlMapping='/pullOpportunitydetails/*')
global class pullOpportunitydetailsClass{
    //public static boolean isNewTradeLine=False;   //PDI-948
    @HttpPost
    global static String pullOpportunitydetails() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String opportunityId;
        String jsonStr = '';
        ///services/apexrest/pullOpportunitydetails?oppId=123
        //opportunityId = RestContext.request.params.get('oppId');
        opportunityId = RestContext.request.requestBody.toString();
        System.debug('opportunityId: '+opportunityId);
        if(opportunityId != NULL){
            List<String> oppIdSet = (List<String>)JSON.deserialize(opportunityId,List<String>.class);
            UpdateNewTradeNPay(oppIdSet); 
            jsonStr = getOppDataJSON(oppIdSet);
            system.debug('###JsonStr::'+jsonStr);
        }
        return jsonStr;
    }
     
      public static void UpdateNewTradeNPay(List<String> opSetId)  
       {
          
          List<Opportunity> opplst=[Select id,Program_ID__c,DRP_File_Number__c From Opportunity where id in: opSetId];
          set<Id> prgSetId=new set<Id>();
          for(Opportunity op:opplst){
            prgSetId.add(op.Program_ID__c);
          }
          
          List<nu_dse__TradeLine__c> tradeToInsertLst = new List<nu_dse__TradeLine__c>();
            
          List<nu_dse__TradeLine__c> lstTrade=[SELECT id, 
                                                      name, 
                                                      nu_dse__program__c, 
                                                      filenumber__c, 
                                                      isnewtrade__c, 
                                                      opportunity__c 
                                                 FROM nu_dse__tradeline__c 
                                                WHERE nu_dse__program__c IN : prgSetId 
                                                  AND opportunity__c = NULL 
                                                  AND nu_dse__include_in_the_program__c = TRUE ]; 
                                                  
        // map<id,nu_dse__TradeLine__c> opptradeMap=new map<id,nu_dse__TradeLine__c>([Select ]);        
         system.debug('###New TradeLines::'+lstTrade);
           if(!opplst.isEmpty()){
               for(Opportunity op:opplst)
               {
                   if(!lstTrade.isEmpty()){
                       
                       for(nu_dse__TradeLine__c trade:lstTrade){
                           trade.Opportunity__c = op.id;
                           trade.FileNumber__c = op.DRP_File_Number__c;  
                           trade.isNewTrade__c=True;
                           tradeToInsertLst.add(trade);
                       }
                   }
                   system.debug('tradeToInsertLst'+tradeToInsertLst);
                   
               }
           }
           
         if(!tradeToInsertLst.isEmpty())
            Update tradeToInsertLst;
         
      } 
      
      public static String getOppDataJSON(List<String> oppIdSet){
        system.debug('###started::');
          //Program_Id__r.DA_Cash_for_DNL_Post_TILA__c   @PDI-736
       
        List<opportunity> oppWithAccLst = [SELECT id, 
                                                  NAME, 
                                                  program_id__c, 
                                                  last_draft__c, 
                                                  lead_group__c, 
                                                  drp_file_number__c, 
                                                  remaining_months_in_program__c, 
                                                  loan_term__c, 
                                                  debt_count__c, 
                                                  closedate, 
                                                  stagename, 
                                                  account.NAME, 
                                                  account.nu_dse__co_first_name__c, 
                                                  account.nu_dse__co_last_name__c, 
                                                  program_id__r.NAME, 
                                                  program_type__c, 
                                                  enroll_date__c, 
                                                  additional_months_with_loan__c, 
                                                  unsettled_debt__c, 
                                                  client_age_formula__c, 
                                                  program_length__c, 
                                                  loan_amount__c, 
                                                  applicant_state__c, 
                                                  unpaid_program_fees_with_dnl__c, 
                                                  unpaid_program_fees_without_loan__c, 
                                                  cash_in_dedicated_account__c, 
                                                  program_id__r.nu_dse__trust_account_balance__c, 
                                                  program_id__r.nu_dse__program_status__c, 
                                                  account.nu_dse__external_rams_id__c, 
                                                  account.nu_dse__external_cft_id__c, 
                                                  account.nu_dse__external_gcs_id__c, 
                                                  program_id__r.portfolio__r.NAME, 
                                                  program_id__r.attorney__c, 
                                                  account.boxfolderid__c, 
                                                  program_id__r.monthly_legal_fee__c, 
                                                  program_id__r.nu_dse__monthly_processor_fee__c, 
                                                  program_id__r.nu_dse__monthly_third_party_fees__c, 
                                                  program_id__r.subscribed_to_allg__c, 
                                                  program_id__r.nu_dse__payment_frequency__c, 
                                                  program_id__r.nu_dse__reoccurring_debit_day__c, 
                                                  program_id__r.nu_dse__twice_monthly_reoccuring_day__c, 
                                                  account.personbirthdate, 
                                                  account.personmailingcountry, 
                                                  account.personmailingstate, 
                                                  account.personemail, 
                                                  account.personmailingstreet, 
                                                  account.clientnumber__c, 
                                                  account.middlename, 
                                                  account.nu_dse__ssn__c, 
                                                  account.personmailingcity, 
                                                  account.personmailingpostalcode, 
                                                  account.personhomephone, 
                                                  account.personmobilephone, 
                                                  account.nu_dse__work_phone__c, 
                                                  account.firstname, 
                                                  account.lastname, 
                                                  account.nu_dse__co_email_address__c, 
                                                  account.nu_dse__co_phone__c, 
                                                  account.nu_dse__co_ssn__c, 
                                                  account.nu_dse__co_date_of_birth__c, 
                                                  // program_id__r.da_cash_for_dnl_post_tila__c, 
                                                  program_id__r.current_accumulation__c, 
                                                  program_id__r.versara_first_funding_date__c, 
                                                  program_id__r.beginning_da_balance__c, 
                                                  program_id__r.addn_l_drafts_during_funding__c, 
                                                  program_id__r.current_admin_fee__c, 
                                                  program_id__r.paid_creditor_payments__c, 
                                                  program_id__r.total_fees__c, 
                                                  program_id__r.expected_accumulation__c, 
                                                  program_id__r.expected_admin_fee__c, 
                                                  program_id__r.total_creditor_payments__c, 
                                                  program_id__r.remaining_accumulation__c, 
                                                  program_id__r.remaining_admin_fee__c, 
                                                  program_id__r.remaining_creditor_payments__c, 
                                                  program_id__r.current_maintenance_fee__c, 
                                                  program_id__r.nu_dse__expected_maintenance_fees__c, 
                                                  program_id__r.remaining_maintenance_fee__c, 
                                                  program_id__r.current_processor_fee__c, 
                                                  program_id__r.remaining_processor_fee__c, 
                                                  program_id__r.expected_processor_fee__c, 
                                                  program_id__r.current_program_fee__c, 
                                                  program_id__r.expected_program_fee__c, 
                                                  program_id__r.remaining_program_fee__c, 
                                                  program_id__r.current_retainer_fee__c, 
                                                  program_id__r.remaining_retainer_fee__c, 
                                                  program_id__r.expected_retainer_fee__c, 
                                                  program_id__r.current_service_fee__c, 
                                                  program_id__r.remaining_service_fee__c, 
                                                  program_id__r.expected_service_fee__c, 
                                                  program_id__r.current_third_party_fee__c, 
                                                  program_id__r.remaining_third_party_fee__c, 
                                                  program_id__r.expected_third_party_fee__c,             
                                                  (SELECT id, 
                                                          NAME, 
                                                          nds_current_creditor_name__c, 
                                                          nds_original_creditor_name__c, 
                                                          normalized_current_creditor__c, 
                                                          normalized_original_creditor__c,
                                                          nu_dse__sales_creditor_name__c, 
                                                          nu_dse__current_stage__c, 
                                                          sfs_current_balance__c, 
                                                          nu_dse__original_creditor__r.NAME, 
                                                          nu_dse__original_account_number__c, 
                                                          nu_dse__new_creditor__r.NAME, //DV-577
                                                   		  nu_dse__new_creditor__c, //DV-577
                                                          SFSPortal_Original_Creditor__c,//DV-577
                                                          nu_dse__new_account_number__c, 
                                                          filenumber__c, 
                                                          nu_dse__original_debt__c, 
                                                          import_id__c, 
                                                          litigation_stage__c, 
                                                          isnewtrade__c, 
                                                          dnl_estimated_settlement__c 
                                                     FROM tradelines__r ),
                                                  (SELECT id, 
                                                          NAME, 
                                                          nsf_date__c, 
                                                          payment_status__c, 
                                                          nu_dse__transaction_status__c, 
                                                          nu_dse__transaction_method__c, 
                                                          nu_dse__payment_type__c, 
                                                          nu_dse__schedule_date__c, 
                                                          nu_dse__total_amount__c, 
                                                          filenumber__c, 
                                                          recordtype.NAME 
                                                     FROM payments__r 
                                                    WHERE recordtype.NAME = 'Draft' 
                                                          OR recordtype.NAME = 'Settlement' 
                                                          OR recordtype.NAME = 'Loan' 
                                                          OR recordtype.NAME = 'Refund Loan' ) 
                                                  FROM Opportunity Where Id IN: oppIdSet];
        
        Set<Id> tradeLineIds = new Set<Id>();
        for(Opportunity opp: oppWithAccLst){
            for(nu_dse__TradeLine__c trade: opp.TradeLines__r){
                tradeLineIds.add(trade.Id);
            }    
        }
        List<nu_dse__Offer__c> offerLst = [SELECT id, 
                                                  name, 
                                                  nu_dse__tradeline__c, 
                                                  is_last_debt__c, 
                                                  dnl_first_settlement__c, 
                                                  nu_dse__program_fee__c, 
                                                  nu_dse__status__c, 
                                                  nu_dse__offer_amount__c, 
                                                  dnl_funds_for_fees__c, 
                                                  dnl_funds_to_clients__c, 
                                                  dnl_disbursement_date__c, 
                                                  dnl_disbursement_amount__c, 
                                                  dnl_settlement_fees__c, 
                                                  settlement_amount_paid__c, 
                                                  amount_paid__c 
                                           FROM   nu_dse__offer__c 
                                           WHERE  nu_dse__tradeline__c IN: tradeLineIds 
                                             AND nu_dse__status__c = 'Accepted' ];
        Set<Id> offerIds = new Set<Id>();
        Map<Id,nu_dse__Offer__c> tradeLineOfferMap = new Map<Id,nu_dse__Offer__c>();
        for(nu_dse__Offer__c offer: offerLst){
            tradeLineOfferMap.put(offer.nu_dse__TradeLine__c,offer);
            offerIds.add(offer.Id);  
        }  
        
        List<nu_dse__Payment__c> paymentLst = [SELECT id, 
                                                  name, 
                                                  filenumber__c, 
                                                  nu_dse__offer__c, 
                                                  payment_status__c, 
                                                  nu_dse__total_amount__c, 
                                                  nu_dse__payment_type__c, 
                                                  nu_dse__schedule_date__c, 
                                                  nu_dse__transaction_method__c 
                                           FROM   nu_dse__payment__c 
                                           WHERE  nu_dse__offer__c IN: offerIds ];    
        
        Map<Id,List<nu_dse__Payment__c>> tradeSettPayMap = new Map<Id,List<nu_dse__Payment__c>>();
        for(nu_dse__Payment__c pay: paymentLst){
            if(tradeSettPayMap.containskey(pay.nu_dse__Offer__c) || test.isRunningTest()){
                List<nu_dse__Payment__c> locLst = tradeSettPayMap.get(pay.nu_dse__Offer__c);
                locLst.add(pay);
                tradeSettPayMap.put(pay.nu_dse__Offer__c,locLst);
            }else{
                tradeSettPayMap.put(pay.nu_dse__Offer__c, new List<nu_dse__Payment__c>{pay}); 
            }
        }   
        opportunityJsonClass oppJson = new opportunityJsonClass();
        
        opportunityJsonClass.cls_Opportunity oppCls;
        opportunityJsonClass.cls_Payments paymentsCls;
        opportunityJsonClass.cls_TradeLines tradeLineCls;
        opportunityJsonClass.cls_SettelmentPayments settelmentPaymentCls;
        
        List<opportunityJsonClass.cls_Opportunity> oppClsLst = new List<opportunityJsonClass.cls_Opportunity>();
        List<opportunityJsonClass.cls_Payments> paymentsClsLst;
        List<opportunityJsonClass.cls_TradeLines> tradeLineLst;
        List<opportunityJsonClass.cls_SettelmentPayments> settelmentPaymentClsLst;
        
        for(Opportunity opp: oppWithAccLst){
            paymentsClsLst = new List<opportunityJsonClass.cls_Payments>();
            tradeLineLst = new List<opportunityJsonClass.cls_TradeLines>();
            oppCls = new opportunityJsonClass.cls_Opportunity();
            oppCls.Id = opp.Id;
            oppCls.Name = opp.Name;
            oppCls.FileNumber = opp.DRP_File_Number__c;
            oppCls.CloseDate = String.ValueOf(opp.CloseDate);   
            oppCls.Stage = opp.StageName;
            oppCls.AccountName = opp.Account.Name;
            oppCls.CoFirstName = opp.Account.nu_dse__Co_First_Name__c;
            oppCls.CoLastName = opp.Account.nu_dse__Co_Last_Name__c;
            oppCls.CoSSN = opp.Account.nu_dse__Co_SSN__c;
            if(opp.Account.nu_dse__Co_Date_Of_Birth__c != null)
            oppCls.CoDateOfBirth = String.valueOf(opp.Account.nu_dse__Co_Date_Of_Birth__c);
            oppCls.CoEmailAddress = opp.Account.nu_dse__Co_Email_Address__c;
            oppCls.CoPhone = opp.Account.nu_dse__Co_Phone__c;
            oppCls.RemainingMonths= String.valueOf(opp.Remaining_Months_in_Program__c);
            oppCls.LoanTerm = String.valueOf(opp.Loan_Term__c);
            oppCls.DebtCount = String.valueOf(opp.Debt_Count__c);
            oppCls.BoxFolderId = opp.Account.BoxFolderId__c;
            
            oppCls.ProgramName = opp.Program_Id__r.Name;
            oppCls.ProgramId = opp.Program_Id__c;
            oppCls.ProgramType= opp.Program_Type__c;
            oppCls.ProgramStatus = opp.Program_Id__r.nu_dse__Program_Status__c;
            //PDI-785
            /*if((string.valueOf(opp.Program_Id__r.DA_Cash_for_DNL_Post_TILA__c))!='' || (string.valueOf(opp.Program_Id__r.DA_Cash_for_DNL_Post_TILA__c))!=null)
              oppCls.DACashforDNLPostTILA=string.valueOf(opp.Program_Id__r.DA_Cash_for_DNL_Post_TILA__c); 
            else 
              oppCls.DACashforDNLPostTILA='';  */
                
            oppCls.EnrollmentDate= String.valueOf(opp.Enroll_Date__c);
            oppCls.AddnlMonthsWithLoan= String.valueOf(opp.Additional_months_with_loan__c);
            oppCls.UnsettledDebt= String.valueOf(opp.Unsettled_Debt__c);
            oppCls.ClientAge= String.valueOf(opp.Client_Age_Formula__c);
            oppCls.ProgramLength= String.valueOf(opp.Program_Length__c);
            oppCls.LoanAmount= String.valueOf(opp.Loan_Amount__c);
            oppCls.ApplicantState= opp.Applicant_State__c;
            oppCls.UnpaidProgramFeeWithDNL = String.valueOf(opp.Unpaid_Program_Fees_with_DNL__c);
            oppCls.UnpaidProgramFeeWODNL = String.valueOf(opp.Unpaid_Program_Fees_without_loan__c);
            //oppCls.CashInDedicatedAccount = String.valueOf(opp.Cash_In_Dedicated_Account__c);  @For PDI-730
            oppCls.CashInDedicatedAccount = String.valueOf(opp.Program_Id__r.nu_dse__Trust_Account_Balance__c);  //PDI-730
            oppCls.CurrentBalance = String.valueOf(opp.Program_Id__r.nu_dse__Trust_Account_Balance__c);
            oppCls.TwiceMonthlyReoccuringDay = String.valueOf(opp.Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c);
            oppCls.ReoccurringDebitDay = String.valueOf(opp.Program_Id__r.nu_dse__Reoccurring_Debit_Day__c);
            oppCls.LastDraft = String.valueOf(opp.Last_Draft__c);
            oppCls.LeadGroup = opp.Lead_Group__c;
            
            //oppCls.PaidAccumulation = String.valueOf(opp.Program_Id__r.Current_Accumulation__c);  //DV-129
            //oppCls.PaidAdminFee = String.valueOf(opp.Program_Id__r.Current_Admin_Fee__c );    //DV-129
            //oppCls.PaidCreditorPayments = String.valueOf(opp.Program_Id__r.Paid_Creditor_Payments__c);  //DV-129
            //oppCls.PaidMaintenanceFee = String.valueOf(opp.Program_Id__r.Current_Maintenance_Fee__c);  //DV-129
            //oppCls.PaidProcessorFee = String.valueOf(opp.Program_Id__r.Current_Processor_Fee__c);  //DV-129
            //oppCls.PaidProgramFee = String.valueOf(opp.Program_Id__r.Current_Program_Fee__c);  //DV-129
            //oppCls.PaidRetainerFee = String.valueOf(opp.Program_Id__r.Current_Retainer_Fee__c);  //DV-129
            //oppCls.PaidServiceFee= String.valueOf(opp.Program_Id__r.Current_Service_Fee__c);  //DV-129
            //oppCls.PaidThirdPartyFee = String.valueOf(opp.Program_Id__r.Current_Third_Party_Fee__c);  //DV-129
            //oppCls.TotalAccumulation = String.valueOf(opp.Program_Id__r.Expected_Accumulation__c);
            //oppCls.TotalAdminFee = String.valueOf(opp.Program_Id__r.Expected_Admin_Fee__c);
            //oppCls.TotalCreditorPayments = String.valueOf(opp.Program_Id__r.Total_Creditor_Payments__c);
            //oppCls.TotalMaintenanceFee = String.valueOf(opp.Program_Id__r.nu_dse__Expected_Maintenance_Fees__c);
            //oppCls.TotalProcessorFee= String.valueOf(opp.Program_Id__r.Expected_Processor_Fee__c);
            //oppCls.TotalProgramFee = String.valueOf(opp.Program_Id__r.Expected_Program_Fee__c);
            //oppCls.TotalRetainerFee = String.valueOf(opp.Program_Id__r.Expected_Retainer_Fee__c);
            //oppCls.TotalServiceFee = String.valueOf(opp.Program_Id__r.Expected_Service_Fee__c);
            //oppCls.TotalThirdPartyFee = String.valueOf(opp.Program_Id__r.Expected_Third_Party_Fee__c);
            oppCls.TotalFee = String.valueOf(opp.Program_Id__r.Total_Fees__c);   //PDI-348
            //PDI-1044
            oppCls.BegDaBalance=String.valueOf(opp.Program_Id__r.Beginning_DA_Balance__c);
            oppCls.AddnlDraftFundng=String.valueOf(opp.Program_Id__r.Addn_l_Drafts_During_Funding__c);
            oppCls.VersaraFundDate=String.valueOf(opp.Program_Id__r.Versara_First_Funding_Date__c); //@1044
            //oppCls.RemainingAccumulation = String.valueOf(opp.Program_Id__r.Remaining_Accumulation__c);  /DV-129
            //oppCls.RemainingAdminFee = String.valueOf(opp.Program_Id__r.Remaining_Admin_Fee__c);
            //oppCls.RemainingCreditorPayments = String.valueOf(opp.Program_Id__r.Remaining_Creditor_Payments__c);
            //oppCls.RemainingMaintenanceFee = String.valueOf(opp.Program_Id__r.Remaining_Maintenance_Fee__c);
            //oppCls.RemainingProcessorFee = String.valueOf(opp.Program_Id__r.Remaining_Processor_Fee__c);
            //oppCls.RemainingProgramFee = String.valueOf(opp.Program_Id__r.Remaining_Program_Fee__c);
            //oppCls.RemainingRetainerFee = String.valueOf(opp.Program_Id__r.Remaining_Retainer_Fee__c);
            //oppCls.RemainingServiceFee = String.valueOf(opp.Program_Id__r.Remaining_Service_Fee__c);
            //oppCls.RemainingThirdPartyFee = String.valueOf(opp.Program_Id__r.Remaining_Third_Party_Fee__c);
            
            oppCls.PersonBirthDate= String.valueOf(opp.Account.PersonBirthDate);
            oppCls.PersonMailingState = opp.Account.PersonMailingState;
            oppCls.PersonMailingCountry = opp.Account.PersonMailingCountry;
            oppCls.PersonEmail = opp.Account.PersonEmail;
            oppCls.PersonMailingStreet = opp.Account.PersonMailingStreet;
            oppCls.ClientNumber = opp.Account.ClientNumber__c;
            oppCls.MiddleName = opp.Account.MiddleName;
            oppCls.AccountSSN = opp.Account.nu_dse__SSN__c;
            oppCls.PersonMailingCity = opp.Account.PersonMailingCity;
            oppCls.PersonMailingPostalCode = opp.Account.PersonMailingPostalCode;
            oppCls.PersonHomePhone = opp.Account.PersonHomePhone;
            oppCls.PersonMobilePhone = opp.Account.PersonMobilePhone;
            oppCls.AccountWorkPhone = opp.Account.nu_dse__Work_Phone__c;
            oppCls.FirstName = opp.Account.FirstName;
            oppCls.LastName = opp.Account.LastName;
            
            if(oppCls.ProcessorName == 'RAMS'){
                oppCls.PaymentAccountNumber = opp.Account.nu_dse__External_RAMS_ID__c;
                oppCls.ProcessorName = 'RAM';
            } else if(oppCls.ProcessorName == 'GCS'){
                oppCls.PaymentAccountNumber = opp.Account.nu_dse__External_GCS_ID__c;
            } else if(oppCls.ProcessorName == 'CFT'){
                oppCls.PaymentAccountNumber = opp.Account.nu_dse__External_CFT_ID__c;
            }
            
            if(opp.Program_Id__r.Attorney__c){
                oppCls.PortfolioType = 'Attorney';
                
            }
            else{
                oppCls.PortfolioType = 'Timberline';
            }
            oppCls.LawFirmName = opp.Program_Id__r.Portfolio__r.Name;
            oppCls.MonthlyLegalFee = String.valueOf(opp.Program_Id__r.Monthly_Legal_Fee__c);
            oppCls.MonthlyProcessorFee = String.valueOf(opp.Program_Id__r.nu_dse__Monthly_Processor_Fee__c);
            oppCls.MonthlyThirdPartyFees = String.valueOf(opp.Program_Id__r.nu_dse__Monthly_Third_Party_Fees__c);
            oppCls.SubscribedToALLG = String.valueOf(opp.Program_Id__r.Subscribed_to_ALLG__c);
           // Commented for DV-129
            /*if(opp.Program_Id__r.nu_dse__Payment_Frequency__c == 'Twice Monthly')
                oppCls.PaymentFrequency = 'Twice-a-Month';
            else
                oppCls.PaymentFrequency = opp.Program_Id__r.nu_dse__Payment_Frequency__c; */
            oppCls.RecurringDebitDay = String.valueOf(opp.Program_Id__r.nu_dse__Reoccurring_Debit_Day__c);
            oppCls.TwiceMonthlyRecurringDay = String.valueOf(opp.Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c);

            
            for(nu_dse__Payment__c pay: opp.Payments__r){
                paymentsCls = new opportunityJsonClass.cls_Payments();
                paymentsCls.Id = pay.Id;
                paymentsCls.Name = pay.Name;
                paymentsCls.FileNumber = pay.FileNumber__c;
                paymentsCls.NFSDate = String.ValueOf(pay.NSF_Date__c);
                paymentsCls.PaymentStatus = pay.Payment_Status__c;
                paymentsCls.PaymentType = pay.nu_dse__Payment_Type__c;
                paymentsCls.ScheduleDate = String.ValueOf(pay.nu_dse__Schedule_Date__c);
                paymentsCls.TotalAmount = String.ValueOf(pay.nu_dse__Total_Amount__c);
                paymentsCls.TansMethod = pay.nu_dse__Transaction_Method__c;
                paymentsCls.TransactionStatus = pay.nu_dse__Transaction_Status__c;
                System.debug('##paymentsCls.TransactionStatus:'+paymentsCls.TransactionStatus +'trade.isNewTrade__c:'+paymentsCls.TransactionStatus);
                
                if(pay.RecordType.Name=='Settlement')  //@ 743
                   paymentsCls.PayRecType='Settlement';
                else if(pay.RecordType.Name=='Draft')
                   paymentsCls.PayRecType='Draft'; 
                else if(pay.RecordType.Name=='Loan')
                   paymentsCls.PayRecType='Loan';
                else if(pay.RecordType.Name=='Refund Loan')
                   paymentsCls.PayRecType='Refund Loan'; //@743
                
                paymentsClsLst.add(paymentsCls);   
            }
            oppCls.Payments = paymentsClsLst;
           List<nu_dse__TradeLine__c> lsttrade=new list<nu_dse__TradeLine__c>();  
            for(nu_dse__TradeLine__c trade: opp.TradeLines__r){
                tradeLineCls = new opportunityJsonClass.cls_TradeLines();
                tradeLineCls.Id = trade.Id;
                tradeLineCls.Name = trade.Name;
                tradeLineCls.FileNumber = trade.FileNumber__c;  
                tradeLineCls.CurrentStage = trade.nu_dse__Current_Stage__c;
                tradelineCls.LitigationStage = trade.Litigation_Stage__c;
                tradelineCls.DNLEstimatedSettlement = String.valueOf(trade.DNL_Estimated_Settlement__c);
                
               //Commented for DV-129
               /* if(trade.Normalized_Current_Creditor__c!=null || trade.Normalized_Current_Creditor__c!='')
                    tradeLineCls.NewCreditor = trade.Normalized_Current_Creditor__c;
                if(trade.Normalized_Current_Creditor__c==null)
                    tradeLineCls.NewCreditor=trade.nds_Current_Creditor_Name__c; */
                
                //DV-577 start
                if(trade.nu_dse__New_Creditor__c !=null){
                    tradeLineCls.NewCreditor = trade.nu_dse__New_Creditor__r.NAME;
                }else{
                   if(trade.Normalized_Current_Creditor__c != null){
                      tradeLineCls.NewCreditor = trade.Normalized_Current_Creditor__c;
                   }else{
                      tradeLineCls.NewCreditor = trade.nds_Current_Creditor_Name__c;
                      
                   }
                }
                System.debug('new creditor -----:'+tradeLineCls.NewCreditor);
                //DV-577 end
                
                

                System.debug('##tradeLineCls.SFSCurrentBalance-I:'+tradeLineCls.SFSCurrentBalance +'trade.isNewTrade__c:'+trade.isNewTrade__c);
                if(trade.isNewTrade__c==True)    //PDI-948 & DV-129
                {
                  tradeLineCls.isNewTrade='true';  //DV-60
                  tradeLineCls.SFSCurrentBalance = String.ValueOf(trade.SFS_Current_Balance__c);   
                  tradeLineCls.NewAccountNumber = trade.nu_dse__New_Account_Number__c;  
                  //tradeLineCls.NewCreditor = trade.nds_Current_Creditor_Name__c;  DV-530 (Commented because acceptance criteria is to get this value from normalized current creditor)
                }
                else 
                    tradeLineCls.isNewTrade='false';  //DV-60
                System.debug('###@@tradeLineCls.isNewTrade:'+tradeLineCls.isNewTrade);
                System.debug('##tradeLineCls.SFSCurrentBalance-II:'+tradeLineCls.SFSCurrentBalance+'trade.isNewTrade__c:'+trade.isNewTrade__c);    
                tradeLineCls.TradeImportID = trade.Import_ID__c; 
                tradeLineCls.OriginalDebt = String.ValueOf(trade.nu_dse__Original_Debt__c);
                //tradeLineCls.OriginalCreditorName = trade.nu_dse__Original_Creditor__r.Name;  //Change for PDI-788 @
                //PDI-788: Line:233 to 236
                System.debug('##trade.Normalized_Original_Creditor__c'+trade.Normalized_Original_Creditor__c);
                if(trade.Normalized_Original_Creditor__c!=null || trade.Normalized_Original_Creditor__c!='')
                   tradeLineCls.OriginalCreditorName = trade.Normalized_Original_Creditor__c;
                if(trade.Normalized_Original_Creditor__c==null)
                   tradeLineCls.OriginalCreditorName=trade.nu_dse__Sales_Creditor_Name__c;
                system.debug('###tradeLineCls.OriginalCreditorName:'+tradeLineCls.OriginalCreditorName);
                system.debug('###trade.nu_dse__Sales_Creditor_Name__c:'+trade.nu_dse__Sales_Creditor_Name__c);
                if(tradeLineOfferMap.containskey(trade.id)){
                    nu_dse__Offer__c offer = tradeLineOfferMap.get(trade.Id);
                    //tradeLineCls.OfferAmount = String.ValueOf(offer.nu_dse__Offer_Amount__c);   //DV-129
                    tradeLineCls.OfferStatus = offer.nu_dse__Status__c;
                    if(trade.isNewTrade__c==True){
                        
                        tradeLineCls.OfferAmount = String.ValueOf(offer.nu_dse__Offer_Amount__c);   //DV-129 
                        tradeLineCls.OfferProgramFee = String.valueOf(offer.nu_dse__Program_Fee__c);  //DV-129
                        //trade.isNewTrade__c=False;
                        //lsttrade.add(trade);
                    }
                   system.debug('###@trade.isNewTrade__c:'+trade.isNewTrade__c +'  lsttrade:-'+lsttrade);
                   // tradeLineCls.OfferProgramFee = String.valueOf(offer.nu_dse__Program_Fee__c);  //DV-129
                    tradelineCls.DNLFundsForFees = String.valueOf(Offer.DNL_Funds_For_Fees__c);
                    tradelineCls.DNLFundstoClient = String.valueOf(Offer.DNL_Funds_to_Clients__c);
                    tradelineCls.DNLDisbursementDate = String.valueOf(offer.DNL_Disbursement_Date__c);
                    tradelineCls.DNLDisbursementAmount = String.valueOf(offer.DNL_Disbursement_Amount__c);
                    tradelineCls.DNLSettlementFees = String.valueOf(offer.DNL_Settlement_Fees__c);
                    System.debug('##@tradelineCls.DNLDisbursementDate: '+tradelineCls.DNLDisbursementDate); 
                    System.debug('##@tradelineCls.DNLDisbursementAmount: '+tradelineCls.DNLDisbursementAmount);
                    System.debug('##@tradelineCls.DNLSettlementFees: '+tradelineCls.DNLSettlementFees);
                    
                    tradelineCls.SettlementAmountPaid = String.valueOf(offer.Settlement_Amount_Paid__c);
                    tradelineCls.AmountPaid = String.valueOf(offer.Amount_Paid__c);
                    tradelineCls.isLastDebt = (offer.Is_Last_Debt__c) ? 'true' : 'false';  //PDI-1019
                    tradelineCls.DNLfirstSettelment = (offer.DNL_First_Settlement__c) ? 'true' : 'false';  //PDI-1043
                   if(tradeSettPayMap.containskey(offer.Id)){
                        List<nu_dse__Payment__c> payLst = tradeSettPayMap.get(offer.Id);
                        settelmentPaymentClsLst = new List<opportunityJsonClass.cls_SettelmentPayments>();
                        for(nu_dse__Payment__c pay: payLst){ 
                            settelmentPaymentCls = new opportunityJsonClass.cls_SettelmentPayments();    
                            settelmentPaymentCls.Id = pay.Id;
                            settelmentPaymentCls.FileNumber = pay.FileNumber__c;
                            settelmentPaymentCls.PaymentStatus = pay.Payment_Status__c;
                            settelmentPaymentCls.TransactionMethod = pay.nu_dse__Transaction_Method__c;
                            settelmentPaymentCls.PaymentType = pay.nu_dse__Payment_Type__c;
                            settelmentPaymentCls.TotalAmount = String.valueOf(pay.nu_dse__Total_Amount__c);
                            settelmentPaymentCls.ScheduleDate = String.valueOf(pay.nu_dse__Schedule_Date__c);
                            settelmentPaymentClsLst.add(settelmentPaymentCls);
                            
                        }  
                        tradeLineCls.SettelmentPayments =  settelmentPaymentClsLst;
                    }
                }
                tradeLineLst.add(tradeLineCls);
                //DV-60
                if(trade.isNewTrade__c==true){
                    trade.isNewTrade__c=false;
                    lsttrade.add(trade);
                }
            }
            oppCls.TradeLines = tradeLineLst;
            oppClsLst.add(oppCls);
            if(lsttrade.size()>0)
                update lsttrade;  //
            oppJson.Opportunity = oppClsLst;
        }
        String jsonStr = System.JSON.serialize(oppJson, true);
        system.debug('###jsonStr::'+jsonStr);
        return jsonStr;
    }
}