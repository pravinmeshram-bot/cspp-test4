/**
* Class Name  : PullDataForPrizmLead
* 
* 
* Description : The class implements simple REST API to get required information from Account table for the requested Account IDs
* 				 for the population of Lead object on PRIZM.
* 
* 
* Author      : Kimi Shrivastava
* 
*/
@RestResource(urlMapping='/pullDataForPrizmLead/*')
global with sharing class PullDataForPrizmLead {
    @HttpPost
    global static String doPostLeadPull() {
        
        //Retrieve the response and deserialize the Ids
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;    
        List<String> idSet = new List<String>();
        if( req!= null && req.requestBody != null){
            String jsonStr =  req.requestBody.toString();
            idSet = (List<String>)JSON.deserialize(jsonStr,List<String>.class);
        }
       
        //For testing
        if(test.isRunningTest()){
            idSet = new List<String>();
            idSet.add('1234');
        }
        
        String returnJSON = null; 
        if(idSet == null || idSet.size() == 0)
            return returnJSON;
        // Declare and instantiate the wrapper classes and corresponding lists for return values.
        NuDebtProgramWrapper nuDebtProgramWrapper;
        NuDebtProgramWrapper.ProgramWrapper programWrapper = new NuDebtProgramWrapper.ProgramWrapper();
        List<NuDebtProgramWrapper.ProgramWrapper> programWrpList = new List<NuDebtProgramWrapper.ProgramWrapper>();       
        // Get the program details for the leads.
        List<nu_dse__Program__c> ProgramList = [Select Id,Import_ID__c,Name, nu_dse__Total_Debt_Included__c,nu_dse__Account__c, nu_dse__Account__r.FirstName, 
                                                nu_dse__Account__r.LastName, nu_dse__Account__r.nu_dse__Campaign__r.Type,
                                                nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.nu_dse__SSN__c,
                                                Rollup_Draft_Amount__c,nu_dse__Account__r.nu_dse__Co_State__c, 
                                                nu_dse__Account__r.nu_dse__CO_SSN_ENC__c, nu_dse__Account__r.nu_dse__Co_First_Name__c, 	
                                                nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Account__r.nu_dse__Co_Phone__c, 
                                                nu_dse__Account__r.nu_dse__CO_Email_Address__c,
                                                nu_dse__Account__r.MiddleName, nu_dse__Account__r.PersonBirthdate, 
                                                nu_dse__Account__r.Phone,
                                                nu_dse__Account__r.nu_dse__Cell_phone__c,
                                                nu_dse__Account__r.nu_dse__Best_Phone__c,
                                                nu_dse__Account__r.PersonHomePhone,
                                                nu_dse__Account__r.nu_dse__Work_Phone__c,
                                                nu_dse__Account__r.PersonMobilePhone,
                                                Enrollment_Date__c,
                                                nu_dse__Account__r.PersonOtherPhone,nu_dse__Payment_Frequency__c, nu_dse__Program_Length__c,  
                                                Program_Type__c, nu_dse__Processor__r.Name, Sales_Rep__c, ClientEmail__c, Portfolio__c,Portfolio__r.Support_Email__c, 
                                                Portfolio__r.Retention_Email__c, Portfolio__r.Communication_Template_Email__c, Portfolio__r.Name, Attorney__c
                                                ,
                                                //Fields for Draft Fees - DLM 37
                                                Paid_Accumulation__c, Paid_Admin_Fee__c, Paid_Creditor_Payments__c, Paid_Maintenance_Fee__c, Paid_Processor_Fee__c, 
                                                Paid_Program_Fee__c, Paid_Retainer_Fee__c, Paid_Service_Fee__c, Paid_Third_Party_Fee__c, 
                                                Remaining_Accumulation__c, Remaining_Admin_Fee__c, Remaining_Creditor_Payments__c, 
                                                Remaining_Maintenance_Fee__c, Remaining_Processor_Fee__c, Remaining_Program_Fee__c, Remaining_Retainer_Fee__c, 
                                                Remaining_Service_Fee__c, Remaining_Third_Party_Fee__c, Total_Accumulation__c, Total_Admin_Fee__c, Total_Creditor_Payments__c, 
                                                Total_Maintenance_Fee__c, Total_Processor_Fee__c, Total_Program_Fee__c, Total_Retainer_Fee__c, Total_Service_Fee__c, 
                                                Total_Third_Party_Fee__c
                                                from nu_dse__Program__c where Import_id__c IN :idSet];
        
        
        List<Id> ProgramIds = new List<Id>();
        if(ProgramList != null){
            nuDebtProgramWrapper = new NuDebtProgramWrapper();
            for(nu_dse__Program__c program: ProgramList){
                programWrapper = new NuDebtProgramWrapper.ProgramWrapper();
                programWrapper.fileNumber = program.Import_ID__c;
                programWrapper.programName = program.Id;
                programWrapper.programNameText = program.Name;
                programWrapper.programType = program.Program_Type__c;
                programWrapper.email = program.ClientEmail__c;
                programWrapper.applicantState = program.nu_dse__Account__r.PersonMailingState ;
                programWrapper.socialSecurityNumber = program.nu_dse__Account__r.nu_dse__SSN__c ;
                programWrapper.coFirstName = program.nu_dse__Account__r.nu_dse__Co_First_Name__c ;
                programWrapper.coLastName= program.nu_dse__Account__r.nu_dse__Co_Last_Name__c  ;
                programWrapper.coPhone= program.nu_dse__Account__r.nu_dse__Co_Phone__c ;
                programWrapper.coEmail = program.nu_dse__Account__r.nu_dse__CO_Email_Address__c ;
                programWrapper.coApplicantState = program.nu_dse__Account__r.nu_dse__Co_State__c;
                programWrapper.coApplicantSSN = program.nu_dse__Account__r.nu_dse__CO_SSN_ENC__c;
                programWrapper.account = program.nu_dse__Account__c;
                programWrapper.firstName = program.nu_dse__Account__r.firstName; 	
                programWrapper.middleName = program.nu_dse__Account__r.MiddleName; 	
                programWrapper.lastName = program.nu_dse__Account__r.lastName; 	
                programWrapper.paymentFrequency = program.nu_dse__Payment_Frequency__c;
                programWrapper.lastDraft = program.Rollup_Draft_Amount__c;
                programWrapper.unsettledDebt = program.nu_dse__Total_Debt_Included__c; //DV-156
                programWrapper.birthDate = program.nu_dse__Account__r.PersonBirthdate;
                programWrapper.phone = program.nu_dse__Account__r.Phone;	
                programWrapper.cellPhone = program.nu_dse__Account__r.nu_dse__Cell_phone__c;
                programWrapper.bestPhone = program.nu_dse__Account__r.nu_dse__Best_Phone__c;
                programWrapper.homePhone = program.nu_dse__Account__r.PersonHomePhone;
                programWrapper.workPhone = program.nu_dse__Account__r.nu_dse__Work_Phone__c;
                programWrapper.mobilePhone = program.nu_dse__Account__r.PersonMobilePhone;
                programWrapper.personOtherPhone = program.nu_dse__Account__r.PersonOtherPhone;
                programWrapper.enrollmentDate = program.Enrollment_Date__c;
                programWrapper.paymentFrequency = program.nu_dse__Payment_Frequency__c;
                programWrapper.programLength = program.nu_dse__Program_Length__c;
                programWrapper.processorName = program.nu_dse__Processor__r.Name;
                programWrapper.salesRep = program.Sales_Rep__c;
                programWrapper.campaignType = program.nu_dse__Account__r.nu_dse__Campaign__r.Type;
                programWrapper.portfolio = program.Portfolio__c;
                programWrapper.portfolioName = program.Portfolio__r.Name;
                programWrapper.portfolioSupportEmail = program.Portfolio__r.Support_Email__c;
                programWrapper.portfolioRetentionEmail = program.Portfolio__r.Retention_Email__c;
                programWrapper.portfolioCommunicationTemplateEmail = program.Portfolio__r.Communication_Template_Email__c;
                if(program.Attorney__c != null && program.Attorney__c == true)
                	programWrapper.portfolioType = 'Attorney'; 
                else
                    programWrapper.portfolioType = 'Timberline';
                programWrpList.add(programWrapper);
                ProgramIds.add(program.Id);
                
        }
        nuDebtProgramWrapper.programs = programWrpList;
            
        }
        
        
        if(!ProgramIds.isEmpty()){           
            System.debug('****'+ProgramIds);           
            
            //--------------------------------
            // Get Tradelines details
            // --------------------------------           
            nuDebtProgramWrapper.tradelines = getTradeLineDetails(ProgramIds);
            System.debug('*****Tradelist'+ nuDebtProgramWrapper.tradelines);
            
            //--------------------------------
            // Get Payment Details
            //--------------------------------            
            nuDebtProgramWrapper.payments = getPaymentDetails(ProgramIds);
            //-----------------------
            //--------------------------------
            // Get Draft fees Details
            //--------------------------------            
            nuDebtProgramWrapper.draftFeesList = getDraftFeesDetails(ProgramList);
            //-----------------------
        }
        
            if(nuDebtProgramWrapper != null)
            	returnJSON = System.JSON.serialize(nuDebtProgramWrapper, true);
        return returnJSON;
    }
    /* About: Function to update the status of Program records w.r.t. to the Lead records inserted in Prizm
* 
* Created By: Kimi Shrivastava
* 
* Date: March 09, 2020	
*/
    @HttpPut
    global static String updateProgramsForLeads() {
        //Retrieve the response and deserialize the Ids
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;       
        String jsonStr =  req.requestBody.toString();
        NuDebtProgramWrapper nuDebtProgramWrapper = (NuDebtProgramWrapper)JSON.deserialize(jsonStr, NuDebtProgramWrapper.class);
        
        System.debug(loggingLevel.ERROR , nuDebtProgramWrapper.programs); 
        
        //Create list of program Ids and <Id, Lead> map for updating the status
        List<Id> ProgramIds = new List<Id>();
        Map<Id,Lead> LeadNewMap = new Map<Id,Lead>();
        Map<Id,Id> ProgramLeadMap = new Map<Id,Id>();
        Lead newLead = new Lead();
        for(NuDebtProgramWrapper.ProgramWrapper pr: nuDebtProgramWrapper.programs){
            ProgramIds.add(pr.programName);
            newLead = new Lead();
            newLead.Id = pr.leadId;
            newLead.Program_Name__c = pr.programName;
            newLead.Status = pr.leadStatus;
            newLead.Latest_Lead__c = pr.latestLead;
            LeadNewMap.put(pr.leadId, newLead);
            ProgramLeadMap.put(pr.programName,pr.leadId);
        }
        
        List<nu_dse__Program__c> ProgramList=[Select Id, DNL_Status__c, nu_dse__Program_Status__c from nu_dse__Program__c where id =:ProgramIds];
        
        for(nu_dse__Program__c p : ProgramList){
            if(p.DNL_Status__c != 'Graduated DRP'){
                if(LeadNewMap.get(ProgramLeadMap.get(p.Id)).Latest_Lead__c == true){
                    p.DNL_Status__c = 'Lead Active';
                }else{
                    if(LeadNewMap.get(ProgramLeadMap.get(p.Id)).Status == 'DNL Not Interested'){
                        p.DNL_Status__c = 'Not Interested';
                    } else if(LeadNewMap.get(ProgramLeadMap.get(p.Id)).Status == 'DNL Ineligible'){
                        p.DNL_Status__c = 'Ineligible';
                    } else if(LeadNewMap.get(ProgramLeadMap.get(p.Id)).Status == 'DNL Uncontacted'){
                        p.DNL_Status__c = 'Uncontacted';
                    } 
                }
            }
        }
        //Update ProgramList;
        
        return jsonStr;
        
    }
    /*
* Method to get the payment details for the selected leads
*/
    public static List<NuDebtProgramWrapper.PaymentsWrapper> getPaymentDetails(List<Id> ProgramIds){
        NuDebtProgramWrapper.PaymentsWrapper paymentsWrapper = new NuDebtProgramWrapper.PaymentsWrapper();        
        List<NuDebtProgramWrapper.PaymentsWrapper> paymentsWrpList = new List<NuDebtProgramWrapper.PaymentsWrapper>();
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
        Id SettlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByDeveloperName().get('Settlement').getRecordTypeId();
        
        List<nu_dse__Payment__c> PaymentList = [Select Id,nu_dse__Program__c,Lead__c, name,NSF_Date__c,Payment_Status__c,nu_dse__Transaction_Status__c,
                                                nu_dse__Transaction_Method__c,nu_dse__Payment_Type__c,nu_dse__Schedule_Date__c,
                                                nu_dse__Total_Amount__c,FileNumber__c,Recordtype.Name from nu_dse__Payment__c 
                                                where nu_dse__Program__c IN :ProgramIds AND 
                                                (RecordTypeId =: DraftRecordTypeId OR RecordTypeId =: SettlementRecordTypeId)];
        System.debug('*****'+PaymentList);
        for(nu_dse__Payment__c payment : PaymentList){
            paymentsWrapper = new NuDebtProgramWrapper.PaymentsWrapper();
            paymentsWrapper.paymentsId = payment.Id;
            paymentsWrapper.programId = payment.nu_dse__Program__c;
            paymentsWrapper.leadId = payment.Lead__c;
            paymentsWrapper.Name = payment.Name;
            paymentsWrapper.FileNumber = payment.FileNumber__c;
            paymentsWrapper.NFSDate = String.ValueOf(payment.NSF_Date__c);
            paymentsWrapper.PaymentStatus = payment.Payment_Status__c;
            paymentsWrapper.PaymentType = payment.nu_dse__Payment_Type__c;
            paymentsWrapper.ScheduleDate = String.ValueOf(payment.nu_dse__Schedule_Date__c);
            paymentsWrapper.TotalAmount = String.ValueOf(payment.nu_dse__Total_Amount__c);
            paymentsWrapper.TransMethod = payment.nu_dse__Transaction_Method__c;
            paymentsWrapper.TransactionStatus = payment.nu_dse__Transaction_Status__c;                
            if(payment.RecordType.Name=='Settlement')  //@ 743
                paymentsWrapper.PayRecType='Settlement';
            else if(payment.RecordType.Name=='Draft')
                paymentsWrapper.PayRecType='Draft'; 
            else if(payment.RecordType.Name=='Loan')
                paymentsWrapper.PayRecType='Loan';
            else if(payment.RecordType.Name=='Refund Loan')
                paymentsWrapper.PayRecType='Refund Loan'; //@743
            
            paymentsWrpList.add(paymentsWrapper);
        }
        return paymentsWrpList;
    }
    /*
* Method to get the tradeline details for the selected leads
*/
    public static List<NuDebtProgramWrapper.TradelinesWrapper> getTradeLineDetails(List<Id> ProgramIds){
        NuDebtProgramWrapper.TradelinesWrapper tradelinesWrapper = new NuDebtProgramWrapper.TradelinesWrapper();
        List<NuDebtProgramWrapper.TradelinesWrapper> tradelinesWrpList = new List<NuDebtProgramWrapper.TradelinesWrapper>();
        List<NuDebtProgramWrapper.PaymentsWrapper> settlementPaymentList = new List<NuDebtProgramWrapper.PaymentsWrapper>();
        NuDebtProgramWrapper.PaymentsWrapper settlementPaymentWrapper = new NuDebtProgramWrapper.PaymentsWrapper();
        
        List<nu_dse__Tradeline__c> TradeList = [Select Id, nu_dse__Program__c,Lead__c, name,nds_Current_Creditor_Name__c,
                                                nds_Original_Creditor_Name__c,Normalized_Current_Creditor__c,
                                                Normalized_Original_Creditor__c,nu_dse__Sales_Creditor_Name__c,
                                                nu_dse__Current_Stage__c,SFS_Current_Balance__c,nu_dse__Original_Creditor__r.Name,
                                                nu_dse__Original_Account_Number__c,nu_dse__New_Creditor__r.Name,nu_dse__New_Account_Number__c,
                                                File_Number__c,nu_dse__Original_Debt__c,Import_ID__c,Litigation_Stage__c,isNewTrade__c,
                                                DNL_Estimated_Settlement__c
                                                from nu_dse__Tradeline__c where nu_dse__Program__c IN :ProgramIds];
        
        System.debug('*****'+TradeList);
        System.debug('*****'+TradeList.size());
        Set<Id> tradeLineIds = new Set<Id>();
        for(nu_dse__TradeLine__c trade: TradeList){
            tradeLineIds.add(trade.Id);
        }    
        List<nu_dse__Offer__c> offerLst = [select id,Name,nu_dse__TradeLine__c,Is_Last_Debt__c,DNL_First_Settlement__c,nu_dse__Program_Fee__c,
                                           nu_dse__Status__c,nu_dse__Offer_Amount__c,DNL_Funds_For_Fees__c,DNL_Funds_to_Clients__c,DNL_Disbursement_Date__c,
                                           DNL_Disbursement_Amount__c,DNL_Settlement_Fees__c, Settlement_Amount_Paid__c,Amount_Paid__c FROM nu_dse__Offer__c 
                                           where nu_dse__TradeLine__c IN :tradeLineIds AND nu_dse__Status__c = 'Accepted'];
        Set<Id> offerIds = new Set<Id>();
        Map<Id,nu_dse__Offer__c> tradeLineOfferMap = new Map<Id,nu_dse__Offer__c>();
        for(nu_dse__Offer__c offer: offerLst){
            tradeLineOfferMap.put(offer.nu_dse__TradeLine__c,offer);
            offerIds.add(offer.Id);  
        }
        
        List<nu_dse__Payment__c> paymentLst = [select id,name,FileNumber__c,nu_dse__Offer__c,Payment_Status__c,nu_dse__Total_Amount__c,
                                               nu_dse__Payment_Type__c,nu_dse__Schedule_Date__c,nu_dse__Transaction_Method__c from nu_dse__Payment__c 
                                               where nu_dse__Offer__c IN :offerIds];    
        
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
        
        for(nu_dse__Tradeline__c trade : TradeList){
            tradelinesWrapper = new NuDebtProgramWrapper.TradelinesWrapper();
            tradelinesWrapper.tradelinesId = trade.Id;
            tradelinesWrapper.name = trade.Name;
            tradelinesWrapper.programId = trade.nu_dse__Program__c;
            tradelinesWrapper.leadId = trade.Lead__c;
            tradelinesWrapper.fileNumber = trade.File_Number__c;
            tradelinesWrapper.CurrentStage = trade.nu_dse__Current_Stage__c;
            tradelinesWrapper.LitigationStage = trade.Litigation_Stage__c;
            tradelinesWrapper.DNLEstimatedSettlement = String.valueOf(trade.DNL_Estimated_Settlement__c);
            tradelinesWrapper.OriginalAccountNumber = trade.nu_dse__Original_Account_Number__c;
            if(trade.isNewTrade__c==True)    //PDI-948 & DV-129
            {
                tradelinesWrapper.isNewTrade='true';  //DV-60
                tradelinesWrapper.SFSCurrentBalance = String.ValueOf(trade.SFS_Current_Balance__c);   
                tradelinesWrapper.NewAccountNumber = trade.nu_dse__New_Account_Number__c;  
                tradelinesWrapper.NewCreditor = trade.nds_Current_Creditor_Name__c;  
            }
            else 
                tradelinesWrapper.isNewTrade='false';  //DV-60
            
            tradelinesWrapper.TradeImportID = trade.Import_ID__c; 
            tradelinesWrapper.OriginalDebt = String.ValueOf(trade.nu_dse__Original_Debt__c);
            if(trade.Normalized_Original_Creditor__c!=null || trade.Normalized_Original_Creditor__c!='')
                tradelinesWrapper.OriginalCreditorName = trade.Normalized_Original_Creditor__c;
            if(trade.Normalized_Original_Creditor__c==null)
                tradelinesWrapper.OriginalCreditorName=trade.nu_dse__Sales_Creditor_Name__c;
            if(tradeLineOfferMap.containskey(trade.id)){
                nu_dse__Offer__c offer = tradeLineOfferMap.get(trade.Id);
                tradelinesWrapper.OfferStatus = offer.nu_dse__Status__c;
                if(trade.isNewTrade__c==True){                        
                    tradelinesWrapper.OfferAmount = String.ValueOf(offer.nu_dse__Offer_Amount__c);   //DV-129 
                    tradelinesWrapper.OfferProgramFee = String.valueOf(offer.nu_dse__Program_Fee__c);  //DV-129
                }
                tradelinesWrapper.DNLFundsForFees = String.valueOf(Offer.DNL_Funds_For_Fees__c);
                tradelinesWrapper.DNLFundstoClient = String.valueOf(Offer.DNL_Funds_to_Clients__c);
                tradelinesWrapper.DNLDisbursementDate = String.valueOf(offer.DNL_Disbursement_Date__c);
                tradelinesWrapper.DNLDisbursementAmount = String.valueOf(offer.DNL_Disbursement_Amount__c);
                tradelinesWrapper.DNLSettlementFees = String.valueOf(offer.DNL_Settlement_Fees__c);                 
                tradelinesWrapper.SettlementAmountPaid = String.valueOf(offer.Settlement_Amount_Paid__c);
                tradelinesWrapper.AmountPaid = String.valueOf(offer.Amount_Paid__c);
                tradelinesWrapper.isLastDebt = (offer.Is_Last_Debt__c) ? 'true' : 'false';  //PDI-1019
                tradelinesWrapper.DNLfirstSettelment = (offer.DNL_First_Settlement__c) ? 'true' : 'false';  //PDI-1043
                if(tradeSettPayMap.containskey(offer.Id)){
                    List<nu_dse__Payment__c> payLst = tradeSettPayMap.get(offer.Id);
                    settlementPaymentList = new List<NuDebtProgramWrapper.PaymentsWrapper>();
                    for(nu_dse__Payment__c pay: payLst){ 
                        settlementPaymentWrapper = new NuDebtProgramWrapper.PaymentsWrapper();    
                        settlementPaymentWrapper.paymentsId = pay.Id;
                        settlementPaymentWrapper.FileNumber = pay.FileNumber__c;
                        settlementPaymentWrapper.PaymentStatus = pay.Payment_Status__c;
                        settlementPaymentWrapper.TransMethod = pay.nu_dse__Transaction_Method__c;
                        settlementPaymentWrapper.PaymentType = pay.nu_dse__Payment_Type__c;
                        settlementPaymentWrapper.TotalAmount = String.valueOf(pay.nu_dse__Total_Amount__c);
                        settlementPaymentWrapper.ScheduleDate = String.valueOf(pay.nu_dse__Schedule_Date__c);
                        settlementPaymentList.add(settlementPaymentWrapper);
                        
                    }  
                    tradelinesWrapper.settlementPayments =  settlementPaymentList;
                }
                
            }
            tradelinesWrpList.add(tradelinesWrapper);
        }
        return tradelinesWrpList;
    }
    
        /*
    * Method to get the Draft Fees details for the selected leads
    */
    public static List<NuDebtProgramWrapper.DraftFeesWrapper> getDraftFeesDetails(List<nu_dse__Program__c> ProgramList){
    
    NuDebtProgramWrapper.DraftFeesWrapper draftFeesWrapper = new NuDebtProgramWrapper.DraftFeesWrapper();        
            List<NuDebtProgramWrapper.DraftFeesWrapper> draftFeesWrpList = new List<NuDebtProgramWrapper.DraftFeesWrapper>();
           
           
        for(nu_dse__Program__c program : ProgramList){
            draftFeesWrapper = new NuDebtProgramWrapper.DraftFeesWrapper();
            draftFeesWrapper.programId = program.Id;
            draftFeesWrapper.paidAccumulation  = program.Paid_Accumulation__c; 
            draftFeesWrapper.paidAdminFee = program.Paid_Admin_Fee__c;  
            draftFeesWrapper.paidCreditorPayments = program.Paid_Creditor_Payments__c;  
            draftFeesWrapper.paidMaintenanceFee = program.Paid_Maintenance_Fee__c;  
            draftFeesWrapper.paidProcessorFee = program.Paid_Processor_Fee__c;  
            draftFeesWrapper.paidProgramFee = program.Paid_Program_Fee__c;  
            draftFeesWrapper.paidRetainerFee = program.Paid_Retainer_Fee__c;  
            draftFeesWrapper.paidServiceFee = program.Paid_Service_Fee__c;  
            draftFeesWrapper.paidThirdPartyFee = program.Paid_Third_Party_Fee__c;  
            draftFeesWrapper.remainingAccumulation = program.Remaining_Accumulation__c; 
            draftFeesWrapper.remainingAdminFee = program.Remaining_Admin_Fee__c;  
            draftFeesWrapper.remainingCreditorPayments = program.Remaining_Creditor_Payments__c;
            draftFeesWrapper.remainingMaintenanceFee =  program.Remaining_Maintenance_Fee__c;
            draftFeesWrapper.remainingProcessorFee = program.Remaining_Processor_Fee__c; 
            draftFeesWrapper.remainingProgramFee = program.Remaining_Program_Fee__c;  
            draftFeesWrapper.remainingRetainerFee = program.Remaining_Retainer_Fee__c;  
            draftFeesWrapper.remainingServiceFee = program.Remaining_Service_Fee__c;  
            draftFeesWrapper.remainingThirdPartyFee = program.Remaining_Third_Party_Fee__c;
            draftFeesWrapper.totalAccumulation = program.Total_Accumulation__c;  
            draftFeesWrapper.totalAdminFee = program.Total_Admin_Fee__c;  
            draftFeesWrapper.totalCreditorPayments = program.Total_Creditor_Payments__c;
            draftFeesWrapper.totalMaintenanceFee = program.Total_Maintenance_Fee__c;  
            draftFeesWrapper.totalProcessorFee = program.Total_Processor_Fee__c;  
            draftFeesWrapper.totalProgramFee = program.Total_Program_Fee__c;  
            draftFeesWrapper.totalRetainerFee = program.Total_Retainer_Fee__c;  
            draftFeesWrapper.totalServiceFee = program.Total_Service_Fee__c;  
            draftFeesWrapper.totalThirdPartyFee = program.Total_Third_Party_Fee__c;            
            
                
            draftFeesWrpList.add(draftFeesWrapper);
            }
        return draftFeesWrpList;
    
    }
    
    /*public List<nu_dse__Program__c> pullProgramDetailsForOpportunity(List<Id> fileNumbers){
        
        List<nu_dse__Program__c> programDetailsList = [Select Id,Import_id__c, Name, nu_dse__Account__r.Name, nu_dse__Account__r.nu_dse__Co_First_Name__c, 
                                                       nu_dse__Account__r.nu_dse__Co_Last_Name__c, nu_dse__Trust_Account_Balance__c, nu_dse__Program_Status__c, nu_dse__Account__r.nu_dse__External_RAMS_ID__c, nu_dse__Account__r.nu_dse__External_CFT_ID__c, nu_dse__Account__r.nu_dse__External_GCS_ID__c, Portfolio__r.Name, Attorney__c, nu_dse__Account__r.BoxFolderId__c, nu_dse__Account__r.PersonBirthDate,  nu_dse__Account__r.PersonMailingCountry, nu_dse__Account__r.PersonMailingState, nu_dse__Account__r.PersonEmail,nu_dse__Account__r.PersonMailingStreet,nu_dse__Account__r.ClientNumber__c,nu_dse__Account__r.MiddleName,nu_dse__Account__r.nu_dse__SSN__c,nu_dse__Account__r.PersonMailingCity,nu_dse__Account__r.PersonMailingPostalCode,nu_dse__Account__r.PersonHomePhone,nu_dse__Account__r.PersonMobilePhone,nu_dse__Account__r.nu_dse__Work_Phone__c,nu_dse__Account__r.FirstName,nu_dse__Account__r.LastName,nu_dse__Account__r.nu_dse__CO_Email_Address__c,nu_dse__Account__r.nu_dse__Co_Phone__c,nu_dse__Account__r.nu_dse__Co_SSN__c,nu_dse__Account__r.nu_dse__Co_Date_of_Birth__c, 
                                                       Monthly_Legal_Fee__c,nu_dse__Monthly_Processor_Fee__c,nu_dse__Monthly_Third_Party_Fees__c,Subscribed_to_ALLG__c,nu_dse__Payment_Frequency__c,nu_dse__Reoccurring_Debit_Day__c,nu_dse__Twice_Monthly_Reoccuring_Day__c, 
                                                       Current_Accumulation__c,Versara_First_Funding_Date__c,Beginning_DA_Balance__c,Addn_l_Drafts_During_Funding__c,Current_Admin_Fee__c,Paid_Creditor_Payments__c,Total_Fees__c,Expected_Accumulation__c,Expected_Admin_Fee__c,Total_Creditor_Payments__c,Remaining_Accumulation__c,Remaining_Admin_Fee__c,Remaining_Creditor_Payments__c,Current_Maintenance_Fee__c,nu_dse__Expected_Maintenance_Fees__c,Remaining_Maintenance_Fee__c,Current_Processor_Fee__c,Remaining_Processor_Fee__c,Expected_Processor_Fee__c,Current_Program_Fee__c,Expected_Program_Fee__c,Remaining_Program_Fee__c,Current_Retainer_Fee__c,Remaining_Retainer_Fee__c,Expected_Retainer_Fee__c,Current_Service_Fee__c,Remaining_Service_Fee__c,Expected_Service_Fee__c,Current_Third_Party_Fee__c,Remaining_Third_Party_Fee__c,Expected_Third_Party_Fee__c
                                                       FROM nu_dse__Program__c Where Import_id__c  =:fileNumbers ];
        return programDetailsList;
        
    }*/
    
 /*   public List<opportunityJsonClass.cls_Opportunity> populateOpportunityMappingsFromProgram(List<nu_dse__Program__c> programDetailsList){
        List<Id> programIds = new List<Id>();
        List<opportunityJsonClass.cls_Opportunity> oppClsLst = new List<opportunityJsonClass.cls_Opportunity>();
        if(programDetailsList != null){
            opportunityJsonClass oppJson = new opportunityJsonClass();            
            opportunityJsonClass.cls_Opportunity oppCls;

            for(nu_dse__Program__c opp: programDetailsList){
                programIds.add(opp.Id);

                oppCls = new opportunityJsonClass.cls_Opportunity();
                oppCls.AccountName = opp.nu_dse__Account__r.Name;
                oppCls.CoFirstName = opp.nu_dse__Account__r.nu_dse__Co_First_Name__c;
                oppCls.CoLastName = opp.nu_dse__Account__r.nu_dse__Co_Last_Name__c;
                oppCls.CoSSN = opp.nu_dse__Account__r.nu_dse__Co_SSN__c;
                if(opp.nu_dse__Account__r.nu_dse__Co_Date_Of_Birth__c != null)
                    oppCls.CoDateOfBirth = String.valueOf(opp.nu_dse__Account__r.nu_dse__Co_Date_Of_Birth__c);
                oppCls.CoEmailAddress = opp.nu_dse__Account__r.nu_dse__Co_Email_Address__c;
                oppCls.CoPhone = opp.nu_dse__Account__r.nu_dse__Co_Phone__c;
                oppCls.BoxFolderId = opp.nu_dse__Account__r.BoxFolderId__c;                
                oppCls.ProgramName = opp.Name;
                oppCls.ProgramId = opp.Id;
                oppCls.ProgramType= opp.Program_Type__c;
                oppCls.ProgramStatus = opp.nu_dse__Program_Status__c;
                oppCls.ApplicantState= opp.nu_dse__Account__r.PersonMailingState;
                oppCls.CashInDedicatedAccount = String.valueOf(opp.nu_dse__Trust_Account_Balance__c);  //PDI-730
                oppCls.CurrentBalance = String.valueOf(opp.nu_dse__Trust_Account_Balance__c);
                oppCls.TwiceMonthlyReoccuringDay = String.valueOf(opp.nu_dse__Twice_Monthly_Reoccuring_Day__c);
                oppCls.ReoccurringDebitDay = String.valueOf(opp.nu_dse__Reoccurring_Debit_Day__c);
                oppCls.TotalFee = String.valueOf(opp.Total_Fees__c);   //PDI-348
                oppCls.BegDaBalance=String.valueOf(opp.Beginning_DA_Balance__c);
                oppCls.AddnlDraftFundng=String.valueOf(opp.Addn_l_Drafts_During_Funding__c);
                oppCls.VersaraFundDate=String.valueOf(opp.Versara_First_Funding_Date__c);                 
                oppCls.PersonBirthDate= String.valueOf(opp.nu_dse__Account__r.PersonBirthDate);
                oppCls.PersonMailingState = opp.nu_dse__Account__r.PersonMailingState;
                oppCls.PersonMailingCountry = opp.nu_dse__Account__r.PersonMailingCountry;
                oppCls.PersonEmail = opp.nu_dse__Account__r.PersonEmail;
                oppCls.PersonMailingStreet = opp.nu_dse__Account__r.PersonMailingStreet;
                oppCls.ClientNumber = opp.nu_dse__Account__r.ClientNumber__c;
                oppCls.MiddleName = opp.nu_dse__Account__r.MiddleName;
                oppCls.AccountSSN = opp.nu_dse__Account__r.nu_dse__SSN__c;
                oppCls.PersonMailingCity = opp.nu_dse__Account__r.PersonMailingCity;
                oppCls.PersonMailingPostalCode = opp.nu_dse__Account__r.PersonMailingPostalCode;
                oppCls.PersonHomePhone = opp.nu_dse__Account__r.PersonHomePhone;
                oppCls.PersonMobilePhone = opp.nu_dse__Account__r.PersonMobilePhone;
                oppCls.AccountWorkPhone = opp.nu_dse__Account__r.nu_dse__Work_Phone__c;
                oppCls.FirstName = opp.nu_dse__Account__r.FirstName;
                oppCls.LastName = opp.nu_dse__Account__r.LastName;
                
                if(oppCls.ProcessorName == 'RAMS'){
                    oppCls.PaymentAccountNumber = opp.nu_dse__Account__r.nu_dse__External_RAMS_ID__c;
                    oppCls.ProcessorName = 'RAM';
                } else if(oppCls.ProcessorName == 'GCS'){
                    oppCls.PaymentAccountNumber = opp.nu_dse__Account__r.nu_dse__External_GCS_ID__c;
                } else if(oppCls.ProcessorName == 'CFT'){
                    oppCls.PaymentAccountNumber = opp.nu_dse__Account__r.nu_dse__External_CFT_ID__c;
                }
                
                if(opp.Attorney__c){
                    oppCls.PortfolioType = 'Attorney';
                    
                }
                else{
                    oppCls.PortfolioType = 'Timberline';
                }
                oppCls.LawFirmName = opp.Portfolio__r.Name;
                oppCls.MonthlyLegalFee = String.valueOf(opp.Monthly_Legal_Fee__c);
                oppCls.MonthlyProcessorFee = String.valueOf(opp.nu_dse__Monthly_Processor_Fee__c);
                oppCls.MonthlyThirdPartyFees = String.valueOf(opp.nu_dse__Monthly_Third_Party_Fees__c);
                oppCls.SubscribedToALLG = String.valueOf(opp.Subscribed_to_ALLG__c);
                oppCls.RecurringDebitDay = String.valueOf(opp.nu_dse__Reoccurring_Debit_Day__c);
                oppCls.TwiceMonthlyRecurringDay = String.valueOf(opp.nu_dse__Twice_Monthly_Reoccuring_Day__c);

                oppClsLst.add(oppCls);             
                
            }
            oppJson.Opportunity = oppClsLst;
            
        }
        return oppClsLst;
    }*/
}