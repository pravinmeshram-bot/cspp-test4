public class SendOpportunityAccountUsingRestApi {
    
    public static void OpportunityBeforeInsert(){
        
        Set<String> oppLeadIdSet = new Set<String>();
        Map<String,Id> oppLeadIdMap = new Map<String,Id>();
        
        for(Opportunity opp: (List<Opportunity>)Trigger.new){
            oppLeadIdSet.add(opp.DNL_Lead_ID__c);
            oppLeadIdMap.put(opp.DNL_Lead_ID__c,opp.Id);
               
        }
        
        List<Lead> leadList = new List<Lead>([select id,Name,DNL_Lead_ID__c,NDS_File_Number__c,(select id,Name from TradeLines__r),(select Id,name from Payments__r) FROM Lead WHERE DNL_Lead_ID__c IN: oppLeadIdSet]);
        Map<String,Lead> leadMap = new Map<String,Lead>();
        for(lead l : LeadList){
            leadMap.put(l.DNL_Lead_ID__c,L);
        }
        
        for(Opportunity opp: (List<Opportunity>)Trigger.new){
            if(leadMap.containsKey(opp.DNL_Lead_Id__c)){
                opp.Debt_Count__c = leadMap.get(opp.DNL_Lead_Id__c).Tradelines__r.size();
                
            }
        }
        
    }
    
    public static void CopyTradelinePaymentsFromLead(List<Opportunity> oppnewLst){
        Set<String> oppLeadIdSet = new Set<String>();
        Map<String,Id> oppLeadIdMap = new Map<String,Id>();
        
        Map<Id,Id> ProgramOpportunityMap = new Map<Id,Id>();
        List<Id> ProgramIds = new List<Id>();
        
        for(Opportunity opp: oppNewLst){
            oppLeadIdSet.add(opp.DNL_Lead_ID__c);
            oppLeadIdMap.put(opp.DNL_Lead_ID__c,opp.Id);
            if(opp.Program_Id__c != null && opp.DNL_Lead_ID__c != null){
                ProgramIds.add(opp.Program_Id__c);
                ProgramOpportunityMap.put(opp.Program_Id__c,opp.Id);
            }
        }
        system.debug('###oppLeadIdMap::'+oppLeadIdMap);
        List<Lead> leadLst = [select id,Name,DNL_Lead_ID__c,NDS_File_Number__c,(select id,Name from TradeLines__r),(select Id,name from Payments__r) FROM Lead WHERE DNL_Lead_ID__c IN: oppLeadIdSet];
        List<nu_dse__Payment__c> paymentToInsertLst = new List<nu_dse__Payment__c>();
        List<nu_dse__TradeLine__c> tradeToInsertLst = new List<nu_dse__TradeLine__c>();
        nu_dse__Payment__c pay1;
        nu_dse__TradeLine__c trade1;
        for(Lead led: leadLst){
            System.debug('****'+led.Tradelines__r.size());
            for(nu_dse__Payment__c pay: led.Payments__r){
                pay.Opportunity__c = oppLeadIdMap.get(led.DNL_Lead_ID__c);
                pay.FileNumber__c = led.NDS_File_Number__c;
                paymentToInsertLst.add(pay);
            }
            for(nu_dse__TradeLine__c trade: led.TradeLines__r){
                //trade1.nu_dse__Original_Debt__c = 1000;
                trade.Opportunity__c = oppLeadIdMap.get(led.DNL_Lead_ID__c);
                trade.FileNumber__c = led.NDS_File_Number__c;
                tradeToInsertLst.add(trade);
            }
        }
        if(!tradeToInsertLst.isEmpty())
            Update tradeToInsertLst;
        if(!paymentToInsertLst.isEmpty())
            Update paymentToInsertLst; 
            
        List<nu_dse__Bank_Account__c> BankAccountList = [select id, nu_dse__Program__c,Opportunity__c from nu_dse__Bank_Account__c where nu_dse__Program__c =: ProgramIds];
        for(nu_dse__Bank_Account__c bankAccount : BankAccountList){
            bankAccount.opportunity__c = ProgramOpportunityMap.get(BankAccount.nu_dse__Program__c);
        }
        update bankAccountList;
        
    }
    public class deserializeResponse{
        public String id;
        public String access_token;   
        
    }
    public String ReturnAccessToken(SendOpportunityAccountUsingRestApi Acc){
        RestIntegrationInformation__mdt restIntegration = [select MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
        String reqbody = 'grant_type=password&client_id='+restIntegration.Consumer_Key__c+'&client_secret='+restIntegration.Client_Secret__c+'&username='+restIntegration.Username__c+'&password='+restIntegration.Password__c; 
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
       
        req.setEndpoint(restIntegration.AccesstokenURL__c); //Change "ap4" in url to your Target Org Instance 
        if(!test.isRunningTest()){
        HttpResponse res=h.send(req);
        //System.debug(res.getBody()+'###1203res');
        deserializeResponse resp1=(deserializeResponse)JSON.deserialize(res.getBody(),deserializeResponse.class);
        System.debug(resp1+'###1203deserializeresponse');
        return resp1.access_token;
        }
        else{
            return 'test';
        }
    }

   //@future(callout=true)
    public static void createOpportunityAccount(String jsonStr){
        RestIntegrationInformation__mdt restIntegration = [select MasterLabel,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c,System_Endpoint__c From RestIntegrationInformation__mdt];
        SendOpportunityAccountUsingRestApi acc1= new SendOpportunityAccountUsingRestApi();
        String accessToken=acc1.ReturnAccessToken(acc1);
        System.debug(accessToken+'###0012');
        if(accessToken!=null){
            String endPoint= restIntegration.System_Endpoint__c + '/CreateOrUpdateRecord'; 
            //String jsonstr= getOppDataJSON(oppLst); //@
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(jsonstr);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            system.debug('REQUEST'+req2);
            if(!Test.isRunningTest()){
                HttpResponse res2;
                try{
                    //HttpResponse res2=h2.send(req2);
                    res2=h2.send(req2);
                }
                catch(Exception e){
                    System.debug(e.getMessage());
                }
            // PDI-794 : Line 130 to 145
            String str=res2.getBody();
            System.debug(str+'###Getstring');
            List<Opportunity> FinlstOpp=new List<Opportunity>();
            map<Id,String> mapOppIdSalesRep=(map<Id,String>)System.JSON.deserialize(str, map<Id,String>.class);
            System.debug('##@mapOppIdSalesRep'+mapOppIdSalesRep);
            set<Id> oppsId=mapOppIdSalesRep.keySet();
            List<Opportunity> lstOpp=[Select id,Sales_Rep__c from Opportunity where id in: oppsId];
                for(Opportunity op:lstOpp){
                    if(mapOppIdSalesRep.containsKey(op.Id)){
                        op.Sales_Rep__c=mapOppIdSalesRep.get(op.Id);
                        System.debug('##@op.Sales_Rep__c'+op.Sales_Rep__c);
                        FinlstOpp.add(op);
                    }
                } 
                if(FinlstOpp.size()>0)
                    update FinlstOpp; 
           
            System.debug(res2+'###1203createresp');
            }
        }
    }
    
    @future(callout=true)
    public static Void getOppDataJSON(Set<Id> oppIds){
        system.debug('###started::');
        
        List<opportunity> oppWithAccLst = [Select Id,Name,Loan_Term__c,Lead_Group__c,Debt_Count__c,Last_Draft__c,DRP_File_Number__c,CloseDate,StageName,Account.Name,Account.nu_dse__Co_First_Name__c,Account.nu_dse__Co_Last_Name__c,Segment__c,Campaign_Type__c,Program_Id__r.Name,Program_Type__c,Enroll_Date__c,Additional_months_with_loan__c,Unsettled_Debt__c,Client_Age_Formula__c,Program_Length__c,Remaining_Months_in_Program__c,Loan_Amount__c,Applicant_State__c,Unpaid_Program_Fees_with_DNL__c,Unpaid_Program_Fees_without_Loan__c,Cash_In_Dedicated_Account__c,Program_Id__r.Attorney__c,Program_Id__r.Portfolio__r.Name,Program_Id__r.nu_dse__Trust_Account_Balance__c,Program_Id__r.nu_dse__Program_Status__c,Program_Id__c,Program_Id__r.nu_dse__Processor__r.name,Program_Id__r.nu_dse__Processor__r.nu_dse__Type__c,
            account.nu_dse__External_RAMS_ID__c,account.nu_dse__External_CFT_ID__c,account.nu_dse__Co_Address_Line__c,account.nu_dse__Co_Postal_Code__c,account.nu_dse__Co_State__c,account.nu_dse__External_GCS_ID__c,account.nu_dse__CO_SSN_ENC__c,account.nu_dse__Co_City__c,Program_Id__r.nu_dse__Payment_Frequency__c,Program_Id__r.nu_dse__Reoccurring_Debit_Day__c, Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c,Account.BoxFolderId__c,Account.PersonBirthDate,Account.PersonMailingCountry, Account.PersonMailingState, Account.PersonEmail,Account.PersonMailingStreet,Account.ClientNumber__c,Account.MiddleName,Account.nu_dse__SSN__c,Account.PersonMailingCity,Account.PersonMailingPostalCode,Account.PersonHomePhone,Account.PersonMobilePhone,Account.nu_dse__Work_Phone__c,Account.LastName,Account.FirstName,Account.nu_dse__CO_Email_Address__c,Account.nu_dse__Co_Phone__c,Account.nu_dse__Co_SSN__c,Account.nu_dse__Co_Date_of_Birth__c,
            Program_Id__r.Current_Accumulation__c,Program_Id__r.Draft_Amount__c,Program_Id__r.Current_Admin_Fee__c,Program_Id__r.Paid_Creditor_Payments__c,Program_Id__r.Expected_Accumulation__c,Program_Id__r.Expected_Admin_Fee__c,Program_Id__r.Total_Fees__c,Program_Id__r.Total_Creditor_Payments__c,Program_Id__r.Remaining_Accumulation__c,Program_Id__r.Remaining_Admin_Fee__c,Program_Id__r.Remaining_Creditor_Payments__c,Program_Id__r.Current_Maintenance_Fee__c,Program_Id__r.nu_dse__Expected_Maintenance_Fees__c,Program_Id__r.Remaining_Maintenance_Fee__c,Program_Id__r.Current_Processor_Fee__c,Program_Id__r.Remaining_Processor_Fee__c,Program_Id__r.Expected_Processor_Fee__c,Program_Id__r.Current_Program_Fee__c,Program_Id__r.Expected_Program_Fee__c,Program_Id__r.Remaining_Program_Fee__c,Program_Id__r.Current_Retainer_Fee__c,Program_Id__r.Remaining_Retainer_Fee__c,Program_Id__r.Expected_Retainer_Fee__c,Program_Id__r.Current_Service_Fee__c,Program_Id__r.Remaining_Service_Fee__c,Program_Id__r.Expected_Service_Fee__c,Program_Id__r.Current_Third_Party_Fee__c,Program_Id__r.Remaining_Third_Party_Fee__c,Program_Id__r.Expected_Third_Party_Fee__c,
            (Select Id,name,nds_Current_Creditor_Name__c,nds_Original_Creditor_Name__c,Normalized_Original_Creditor__c,nu_dse__Sales_Creditor_Name__c,Normalized_Current_Creditor__c,nu_dse__Current_Stage__c,SFS_Current_Balance__c,nu_dse__Original_Creditor__r.Name,nu_dse__Original_Account_Number__c,nu_dse__New_Creditor__r.Name,nu_dse__New_Account_Number__c,FileNumber__c,nu_dse__Original_Debt__c,Import_ID__c,Litigation_Stage__c,DNL_Estimated_Settlement__c From TradeLines__r where (NOT nu_dse__Current_Stage__c like 'Settled%')),
            (Select Id,name,NSF_Date__c,Payment_Status__c,nu_dse__Transaction_Method__c,nu_dse__Payment_Type__c,nu_dse__Schedule_Date__c,nu_dse__Total_Amount__c,Recordtype.Name,FileNumber__c,nu_dse__Transaction_Status__c From Payments__r where Recordtype.Name = 'Draft' OR Recordtype.Name = 'Settlement' OR Recordtype.Name = 'Loan' OR Recordtype.Name = 'Refund Loan') ,  // OR Recordtype.Name = 'Draft'
            (Select Id,Name,Opportunity__c,nu_dse__Account__c,nu_dse__Account_Type__c,nu_dse__Bank_Account_Number__c,nu_dse__Bank_Name__c,nu_dse__City__c,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c,nu_dse__State__c,nu_dse__Telephone__c,nu_dse__Zip__c from Bank_Accounts__r),
            (Select Id,Subject,Status,Tasks_Category__c,ActivityDate,WhatId,Priority,Type,Description,Due_Date_Time__c from Tasks where Status != 'Completed' AND Status != 'Cancelled')  //Added Tasks_Category__c,Segment__c Field by @sandip PDI-687:Campaign_Type__c
            FROM Opportunity Where Id IN:oppIds];
        Set<Id> tradeLineIds = new Set<Id>();
        Id TradeId;
        for(Opportunity opp: oppWithAccLst){
            for(nu_dse__TradeLine__c trade: opp.TradeLines__r){
                tradeLineIds.add(trade.Id);
                TradeId = opp.TradeLines__r[0].Id;
            }    
        }
        //@PDI-717
        List<nu_dse__Offer__c> offerLst = [select id,Name,nu_dse__TradeLine__c,Is_Last_Debt__c,DNL_First_Settlement__c,nu_dse__Program_Fee__c,nu_dse__Status__c,nu_dse__Offer_Amount__c,Settlement_Amount_Paid__c,DNL_Funds_For_Fees__c,DNL_Funds_to_Clients__c,DNL_Disbursement_Date__c,DNL_Disbursement_Amount__c,DNL_Settlement_Fees__c,Amount_Paid__c FROM nu_dse__Offer__c where nu_dse__TradeLine__c IN: tradeLineIds AND (nu_dse__Status__c = 'Accepted' OR nu_dse__Status__c='Payment Plan - Active' OR nu_dse__Status__c='Settled')];  //OR nu_dse__Status__c='Payment Plan - Active' OR nu_dse__Status__c='Settled' @PDI-717
        String dummyOffer = '';
        /*if(offerLst.isEmpty()){
            nu_dse__Offer__c offer = new nu_dse__Offer__c();
            offer.nu_dse__TradeLine__c = TradeId;
            Insert offer; 
            dummyOffer = offer.Id; 
            offerLst.add(offer);  
        }*/
        Set<Id> offerIds = new Set<Id>();
        Map<Id,nu_dse__Offer__c> tradeLineOfferMap = new Map<Id,nu_dse__Offer__c>();
        for(nu_dse__Offer__c offer: offerLst){
            tradeLineOfferMap.put(offer.nu_dse__TradeLine__c,offer);
            offerIds.add(offer.Id);  
        }  
        String dummyPay ='';
        List<nu_dse__Payment__c> paymentLst = [select id,name,FileNumber__c,nu_dse__Offer__c,Payment_Status__c,nu_dse__Total_Amount__c,nu_dse__Payment_Type__c,nu_dse__Schedule_Date__c,nu_dse__Transaction_Method__c from nu_dse__Payment__c where nu_dse__Offer__c IN: offerIds];    // RecordType.Name = 'Settlement' AND nu_dse__Offer__c IN: offerIds
        /*if(paymentLst.isEmpty()){
            nu_dse__Payment__c pay = new nu_dse__Payment__c();
            pay.nu_dse__Offer__c = dummyOffer;
            Insert pay; 
            dummyPay = pay.Id;
            paymentLst.add(pay);   
        } */   
        system.debug('###paymentLst::'+paymentLst);
        Map<Id,List<nu_dse__Payment__c>> tradeSettPayMap = new Map<Id,List<nu_dse__Payment__c>>();
        for(nu_dse__Payment__c pay: paymentLst){
            if(tradeSettPayMap.containskey(pay.nu_dse__Offer__c)){
                List<nu_dse__Payment__c> locLst = tradeSettPayMap.get(pay.nu_dse__Offer__c);
                locLst.add(pay);
                tradeSettPayMap.put(pay.nu_dse__Offer__c,locLst);
            }else{
                tradeSettPayMap.put(pay.nu_dse__Offer__c, new List<nu_dse__Payment__c>{pay}); 
            }
        }   
        system.debug('###tradeSettPayMap::'+tradeSettPayMap);
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
            oppCls.CampaignType=opp.Campaign_Type__c; //@PDI-687
            oppCls.ProgramName = opp.Program_Id__r.Name;
            oppCls.ProgramId = opp.Program_Id__c;
            oppCls.ProgramType= opp.Program_Type__c;
            oppCls.ProgramStatus = opp.Program_Id__r.nu_dse__Program_Status__c;
            oppCls.EnrollmentDate= String.valueOf(opp.Enroll_Date__c);
            oppCls.AddnlMonthsWithLoan= String.valueOf(opp.Additional_months_with_loan__c);
            oppCls.UnsettledDebt= String.valueOf(opp.Unsettled_Debt__c);
            oppCls.ClientAge= String.valueOf(opp.Client_Age_Formula__c);
            oppCls.ProgramLength= String.valueOf(opp.Program_Length__c);
                        oppCls.RemainingMonths= String.valueOf(opp.Remaining_Months_in_Program__c);
            oppCls.LoanTerm = String.valueOf(opp.Loan_Term__c);
            oppCls.DebtCount = String.valueOf(opp.Debt_Count__c);
            oppCls.LoanAmount= String.valueOf(opp.Loan_Amount__c);
            oppCls.ApplicantState= opp.Applicant_State__c;
            oppCls.UnpaidProgramFeeWithDNL = String.valueOf(opp.Unpaid_Program_Fees_with_DNL__c);
            oppCls.UnpaidProgramFeeWODNL = String.valueOf(opp.Unpaid_Program_Fees_without_loan__c);
            oppCls.CashInDedicatedAccount = String.valueOf(opp.Cash_In_Dedicated_Account__c);
            oppCls.BoxFolderId = opp.Account.BoxFolderId__c;
            oppCls.CurrentBalance = String.valueOf(opp.Program_Id__r.nu_dse__Trust_Account_Balance__c);
            //Account field
            oppCls.AccountName = opp.Account.Name;
            oppCls.CoFirstName = opp.Account.nu_dse__Co_First_Name__c;
            oppCls.CoLastName = opp.Account.nu_dse__Co_Last_Name__c;
            system.debug('@@@oppCls.CoFirstName '+oppCls.CoFirstName+'oppCls.CoLastName: '+oppCls.CoLastName);
            oppCls.CoSSN = opp.Account.nu_dse__CO_SSN_ENC__c;   
            if(opp.Account.nu_dse__Co_Date_Of_Birth__c != null)
                 oppCls.CoDateOfBirth = String.valueOf(opp.Account.nu_dse__Co_Date_Of_Birth__c);
            oppCls.CoEmailAddress = opp.Account.nu_dse__Co_Email_Address__c;
            oppCls.CoPhone = opp.Account.nu_dse__Co_Phone__c;
            //DV-336 [CoCity-CoAddrline2]
            oppCls.CoCity = opp.Account.nu_dse__Co_City__c;
            oppCls.CoState = opp.Account.nu_dse__Co_State__c;
            oppCls.CoPostalCode = opp.Account.nu_dse__Co_Postal_Code__c;
            oppCls.CoCountry = opp.Account.PersonMailingCountry;
            oppCls.CoAddrline1=opp.Account.nu_dse__Co_Address_Line__c;
            
            oppCls.ProcessorName = opp.Program_Id__r.nu_dse__Processor__r.nu_dse__Type__c;
            //oppCls.SalesRep = opp.Sales_Rep__c;
            oppCls.TwiceMonthlyReoccuringDay = String.valueOf(opp.Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c);
            oppCls.ReoccurringDebitDay = String.valueOf(opp.Program_Id__r.nu_dse__Reoccurring_Debit_Day__c);
            oppCls.LastDraft = String.valueOf(opp.Last_Draft__c);
            oppCls.LeadGroup = opp.Lead_Group__c;
            oppCls.Segment = opp.Segment__c;  
            if(opp.Program_Id__r.nu_dse__Payment_Frequency__c == 'Twice Monthly')
                oppCls.PaymentFrequency = 'Twice-a-Month';
            else
                oppCls.PaymentFrequency = opp.Program_Id__r.nu_dse__Payment_Frequency__c;
            
            //oppCls.RemainingMo = String.valueOf(opp.RemainingMo__c);
            
            //,,,,,,,,Program_Id__r.Paid_Retainer_Fee__c,,Program_Id__r.Total_Retainer_Fee__c,Program_Id__r.Paid_Service_Fee__c,,,,,,
            
            oppCls.PaidAccumulation = String.valueOf(opp.Program_Id__r.Current_Accumulation__c);
            oppCls.DraftAmt = String.valueOf(opp.Program_Id__r.Draft_Amount__c);   //@PDI-714
            oppCls.PaidAdminFee = String.valueOf(opp.Program_Id__r.Current_Admin_Fee__c );
            oppCls.PaidCreditorPayments = String.valueOf(opp.Program_Id__r.Paid_Creditor_Payments__c);
            oppCls.PaidMaintenanceFee = String.valueOf(opp.Program_Id__r.Current_Maintenance_Fee__c);
            oppCls.PaidProcessorFee = String.valueOf(opp.Program_Id__r.Current_Processor_Fee__c);
            oppCls.PaidProgramFee = String.valueOf(opp.Program_Id__r.Current_Program_Fee__c);
            oppCls.PaidRetainerFee = String.valueOf(opp.Program_Id__r.Current_Retainer_Fee__c);
            oppCls.PaidServiceFee= String.valueOf(opp.Program_Id__r.Current_Service_Fee__c);
            oppCls.PaidThirdPartyFee = String.valueOf(opp.Program_Id__r.Current_Third_Party_Fee__c);
            oppCls.TotalAccumulation = String.valueOf(opp.Program_Id__r.Expected_Accumulation__c);
            oppCls.TotalAdminFee = String.valueOf(opp.Program_Id__r.Expected_Admin_Fee__c);
            oppCls.TotalCreditorPayments = String.valueOf(opp.Program_Id__r.Total_Creditor_Payments__c);
            oppCls.TotalMaintenanceFee = String.valueOf(opp.Program_Id__r.nu_dse__Expected_Maintenance_Fees__c);
            oppCls.TotalProcessorFee= String.valueOf(opp.Program_Id__r.Expected_Processor_Fee__c);
            oppCls.TotalProgramFee = String.valueOf(opp.Program_Id__r.Expected_Program_Fee__c);
            oppCls.TotalRetainerFee = String.valueOf(opp.Program_Id__r.Expected_Retainer_Fee__c);
            oppCls.TotalServiceFee = String.valueOf(opp.Program_Id__r.Expected_Service_Fee__c);
            oppCls.TotalThirdPartyFee = String.valueOf(opp.Program_Id__r.Expected_Third_Party_Fee__c);
            oppCls.RemainingAccumulation = String.valueOf(opp.Program_Id__r.Remaining_Accumulation__c);
            oppCls.RemainingAdminFee = String.valueOf(opp.Program_Id__r.Remaining_Admin_Fee__c);
            oppCls.RemainingCreditorPayments = String.valueOf(opp.Program_Id__r.Remaining_Creditor_Payments__c);
            oppCls.RemainingMaintenanceFee = String.valueOf(opp.Program_Id__r.Remaining_Maintenance_Fee__c);
            oppCls.RemainingProcessorFee = String.valueOf(opp.Program_Id__r.Remaining_Processor_Fee__c);
            oppCls.RemainingProgramFee = String.valueOf(opp.Program_Id__r.Remaining_Program_Fee__c);
            oppCls.RemainingRetainerFee = String.valueOf(opp.Program_Id__r.Remaining_Retainer_Fee__c);
            oppCls.RemainingServiceFee = String.valueOf(opp.Program_Id__r.Remaining_Service_Fee__c);
            oppCls.RemainingThirdPartyFee = String.valueOf(opp.Program_Id__r.Remaining_Third_Party_Fee__c);
            
            
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
            //oppCls.Phone=opp.Account.Phone;  //@
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
            
            oppCls.Tasks = opp.Tasks;
            System.debug('****'+opp.Tasks);
            if(opp.Program_Id__r.Attorney__c){
                oppCls.PortfolioType = 'Attorney';
            }
            else{
                oppCls.PortfolioType = 'Timberline';
            }
            system.debug('@@opp.Program_Id__r.Portfolio__r.Name '+opp.Program_Id__r.Portfolio__r.Name);
            oppCls.LawFirmName = opp.Program_Id__r.Portfolio__r.Name;
            System.debug('@@oppCls.LawFirmName '+oppCls.LawFirmName);
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
               
                if(pay.RecordType.Name=='Settlement' || test.isRunningTest())  //@ 743
                   paymentsCls.PayRecType='Settlement';
                else if(pay.RecordType.Name=='Draft')
                   paymentsCls.PayRecType='Draft'; 
                else if(pay.RecordType.Name=='Loan' || test.isRunningTest())
                   paymentsCls.PayRecType='Loan';
                else if(pay.RecordType.Name=='Refund Loan')
                   paymentsCls.PayRecType='Refund Loan'; 
                
                paymentsClsLst.add(paymentsCls);   
            }
            oppCls.Payments = paymentsClsLst;
            System.debug(PaymentsClsLst);
            for(nu_dse__TradeLine__c trade: opp.TradeLines__r){
                tradeLineCls = new opportunityJsonClass.cls_TradeLines();
                tradeLineCls.Id = trade.Id;
                tradeLineCls.Name = trade.Name;
                tradeLineCls.FileNumber = trade.FileNumber__c;  
                tradeLineCls.CurrentStage = trade.nu_dse__Current_Stage__c;
                tradelineCls.LitigationStage = trade.Litigation_Stage__c;
                tradelineCls.DNLEstimatedSettlement = String.valueOf(trade.DNL_Estimated_Settlement__c);
                tradeLineCls.NewAccountNumber = trade.nu_dse__New_Account_Number__c;
                //tradeLineCls.NewCreditor = trade.nds_Current_Creditor_Name__c;  //Change for PDI-788
                //PDI-788_B: Line 356 to 359
                if(trade.Normalized_Current_Creditor__c!=null || trade.Normalized_Current_Creditor__c!='')
                    tradeLineCls.NewCreditor = trade.Normalized_Current_Creditor__c;
                if(trade.Normalized_Current_Creditor__c==null)
                    tradeLineCls.NewCreditor=trade.nds_Current_Creditor_Name__c;
                
                tradeLineCls.OriginalAccountNumber = trade.nu_dse__Original_Account_Number__c;
                tradeLineCls.SFSCurrentBalance = String.ValueOf(trade.SFS_Current_Balance__c); 
                tradeLineCls.TradeImportID = trade.Import_ID__c; 
                tradeLineCls.OriginalDebt = String.ValueOf(trade.nu_dse__Original_Debt__c);
                //tradeLineCls.OriginalCreditorName = trade.nu_dse__Original_Creditor__r.Name;  //Change for PDI-788
                //PDI-788: Line:361 to 364
                if(trade.Normalized_Original_Creditor__c!=null || trade.Normalized_Original_Creditor__c!='')
                   tradeLineCls.OriginalCreditorName = trade.Normalized_Original_Creditor__c;
                if(trade.Normalized_Original_Creditor__c==null)
                   tradeLineCls.OriginalCreditorName=trade.nu_dse__Sales_Creditor_Name__c;
                system.debug('###tradeLineCls.OriginalCreditorName:'+tradeLineCls.OriginalCreditorName);
                system.debug('###trade.nu_dse__Sales_Creditor_Name__c:'+trade.nu_dse__Sales_Creditor_Name__c);
                
                if(tradeLineOfferMap.containskey(trade.id)){
                    nu_dse__Offer__c offer = tradeLineOfferMap.get(trade.Id);
                    tradeLineCls.OfferAmount = String.ValueOf(offer.nu_dse__Offer_Amount__c);
                    tradeLineCls.OfferStatus = offer.nu_dse__Status__c;
                    tradeLineCls.OfferProgramFee = String.valueOf(offer.nu_dse__Program_Fee__c);
                    tradelineCls.DNLFundsForFees = String.valueOf(Offer.DNL_Funds_For_Fees__c);
                    tradelineCls.DNLFundstoClient = String.valueOf(Offer.DNL_Funds_to_Clients__c);
                    tradelineCls.DNLDisbursementDate = String.valueOf(offer.DNL_Disbursement_Date__c);
                    tradelineCls.DNLDisbursementAmount = String.valueOf(offer.DNL_Disbursement_Amount__c);
                    tradelineCls.DNLSettlementFees = String.valueOf(offer.DNL_Settlement_Fees__c);
                    tradelineCls.SettlementAmountPaid = String.valueOf(offer.Settlement_Amount_Paid__c);
                    tradelineCls.AmountPaid = String.valueOf(offer.Amount_Paid__c);
                    //tradelineCls.isLastDebt = (offer.Is_Last_Debt__c) ? 'true' : 'false';  //PDI-1019
                    //tradelineCls.DNLfirstSettelment = (offer.DNL_First_Settlement__c) ? 'true' : 'false';  //PDI-1043
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
            }
            oppCls.TradeLines = tradeLineLst;
            
            opportunityJsonClass.cls_BankAccount bankAccountcls = new opportunityJsonClass.cls_BankAccount();
            if(opp.Bank_Accounts__r != null && !opp.Bank_Accounts__r.isEmpty()){
                nu_dse__Bank_Account__c bankAccount = opp.Bank_Accounts__r[0];
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
            }
            oppCls.BankAccounts = bankAccountCls;
            System.debug('****'+oppCls.BankAccounts);
            oppClsLst.add(oppCls);
            oppJson.Opportunity = oppClsLst;
        }
        String jsonStr = System.JSON.serialize(oppJson, true);
        system.debug('###jsonStr::'+jsonStr);
        createOpportunityAccount(jsonStr);
    }
}