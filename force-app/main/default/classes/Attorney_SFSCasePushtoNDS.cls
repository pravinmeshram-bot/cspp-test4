global class Attorney_SFSCasePushtoNDS implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{

    global Database.QueryLocator start(Database.BatchableContext BC){
        Set<string> reProcessSFSCaseError = Attorney_StaticVariableUtility.reProcessConfigs('Summon',true);
        return Database.getQueryLocator([Select Id, Integration_Status__c, 
        Court_Name__c, 
        Attorney_Contact__c,
        Number_of_Dependants__c,
        Number_In_Household_Who_Earn_Income__c,
        Client_ever_received_pay_cut_reduction__c,
        Name_Plaintiff_as_in_caption__c, 
        Date_of_Client_last_payment_to_creditor__c, 
        Complaint_type__c,
        Program__r.Portfolio__r.Support_Phone_Number__c, 
        Fax__c, 
        New_Creditor_Name__c,
        Number_of_People_In_Household__c, 
        Has_client_ever_filed_bankruptcy__c, 
        client_garnishments_Court_Ordered__c, 
        Defendant_s_name_as_in_the_caption__c, 
        Amount_of_last_payment_to_creditor__c, 
        Date_of_Service__c, 
        Court_Case_Number__c, 
        Method_of_Service__c,
        Tradeline__c,
        Tradeline__r.Additional_Name__c,
        Tradeline__r.Additional_Relation__c, 
        Program__r.nu_dse__Account__r.campaignId__c,
        Tradeline__r.nds_Last_Statement_Date__c, 
        Tradeline__r.nu_dse__Percentage__c ,
        Tradeline__r.is_cash_or_transfer__c,
        Tradeline__r.nu_dse__Last_Payment_Date__c ,
        Tradeline__r.Ended_On__c ,
        Tradeline__r.CreatedDate,
        Tradeline__r.nu_dse__Original_Debt__c, 
        Tradeline__r.nu_dse__Minimum_Payment_Amount__c, 
        Tradeline__r.nds_statement_included__c, 
        Tradeline__r.nu_dse__Verified_Balance__c, 
        Tradeline__r.nu_dse__Program__r.import_Id__c,
        Tradeline__r.import_Id__c, 
        Tradeline__r.LastModifiedDate,
        Tradeline__r.Applicant_Type__c,
        Tradeline__r.nds_Debt_Type__c,
        Tradeline__r.Negotiation_Status__c,
        Tradeline__r.Account_Status__c, 
        TradeLine__r.Primary_Applicant__c, 
        TradeLine__r.Secondary_Applicant__c,
        TradeLine__r.Secondary_Name_Relation__c from summon__c s where ((Integration_Status__c=:'Failed Client' OR Integration_Status__c=:'Failed Tradeline') and 
                                                                                  (Integration_Reason__c Like:reProcessSFSCaseError OR Integration_Reason_2__c Like:reProcessSFSCaseError)) OR  Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW]);
    }
    
     
    global void execute(Database.BatchableContext BC, List<summon__c> CaseList){
        List<Id> TradelineIds = new List<Id>();
        Map<Id, List<nu_dse__Offer__c>> TradeOfferMap = new Map<Id, List<nu_dse__Offer__c>>();
        for(Summon__c sc: caseList){
            TradelineIds.add(sc.Tradeline__c);
        }
        
        List<nu_dse__Offer__c> allOfferList = [Select Id,Settlement_Status__c,nu_dse__TradeLine__c,LastModifiedDate from nu_dse__Offer__c where nu_dse__TradeLine__c =:TradelineIds AND IsAttorney__c=true AND latest_offer__c=true];
        for(nu_dse__Offer__c offer : allOfferList){
            if(!TradeOfferMap.containsKey(offer.nu_dse__TradeLine__c)){
                TradeOfferMap.put(offer.nu_dse__TradeLine__c,new List<nu_dse__Offer__c>());
            }
            TradeOfferMap.get(offer.nu_dse__TradeLine__c).add(offer);
        }
        
        for(Summon__c sc: CaseList){
            Boolean isFailed = false;
            //Client Update
            Map<String,String> clientUpdMap = new Map<String,String>();
            clientUpdMap.put('Dependants',String.valueOf(sc.Number_of_Dependants__c));
            clientUpdMap.put('FileNumber',String.valueOf(sc.Tradeline__r.nu_dse__Program__r.import_Id__c));
            clientUpdMap.put('PeopleHouseholdIncome',String.valueOf(sc.Number_In_Household_Who_Earn_Income__c));
            clientUpdMap.put('WorkHoursReduction_Select',String.valueOf(sc.Client_ever_received_pay_cut_reduction__c));
            clientUpdMap.put('PeopleHousehold',String.valueOf(sc.Number_of_People_In_Household__c));
            clientUpdMap.put('FiledBankruptcy',String.valueOf(sc.Has_client_ever_filed_bankruptcy__c));
            clientUpdMap.put('WageGarnishments',String.valueOf(sc.client_garnishments_Court_Ordered__c));
            
            leadtracNetClient.ClientServiceSoap clientSoap = new leadtracNetClient.ClientServiceSoap();
            leadtracNetClient.ArrayOfClientProperty propertyArray;
            leadtracNetClient.ClientProperty clientProperty;
            List<leadtracNetClient.ClientProperty> propLst;
            propLst = new List<leadtracNetClient.ClientProperty>();
            propertyArray = new leadtracNetClient.ArrayOfClientProperty();
            
            for(String str: clientUpdMap.keySet()){
                if(clientUpdMap.containsKey(Str)){
                    clientProperty = new leadtracNetClient.ClientProperty();
                    clientProperty.Name = str;
                    clientProperty.Value = clientUpdMap.get(str);
                    propLst.add(clientProperty);    
                }
            }
                
            propertyArray.ClientProperty = propLst;
            try{
                String retunedString = clientSoap.CreateOrUpdateClient(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,sc.Program__r.nu_dse__Account__r.CampaignId__c,propertyArray);
            } catch(Exception e)
            {
                 setIntegrationFields(sc,'Failed Client',
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                System.debug('****exception'+e.getStackTraceString());
                System.debug('****exception'+e.getMessage());
                isFailed = true;
            }
            
            //Debt Update
            
            LeadtracNetDebt.DebtServiceSoap soap = new LeadtracNetDebt.DebtServiceSoap();
            
            LeadtracNetDebt.ArrayOfDebt arrayOfDebt = new LeadtracNetDebt.ArrayOfDebt();
            LeadtracNetDebt.Debt debt = new LeadtracNetDebt.Debt();  
            debt.DebtType = sc.Tradeline__r.nds_Debt_Type__c;
            debt.NegotiationStatus = sc.Tradeline__r.Negotiation_Status__c;
            
            //negotiator not mapped
            
            debt.AccountStatus = sc.Tradeline__r.Account_Status__c;
            debt.PrimaryName = sc.Tradeline__r.Primary_Applicant__c;
            debt.SecondaryName = sc.Tradeline__r.Secondary_Applicant__c;
            debt.SecondaryNameRelation = sc.Tradeline__r.Secondary_Name_Relation__c;
            debt.AdditionalName = sc.Tradeline__r.Additional_Name__c;
            debt.AdditionalRelation = sc.Tradeline__r.Additional_Relation__c;
            debt.OriginalBalance = (sc.Tradeline__r.nu_dse__Original_Debt__c == null) ? 0 : Integer.ValueOf(sc.Tradeline__r.nu_dse__Original_Debt__c);
            debt.MinimumPayment =  (sc.Tradeline__r.nu_dse__Minimum_Payment_Amount__c == null) ? 0 : Integer.ValueOf(sc.Tradeline__r.nu_dse__Minimum_Payment_Amount__c);
            
            debt.IsStatementIncluded=  string.valueof(sc.Tradeline__r.nds_statement_included__c);

        
            debt.VerifiedBalance = (sc.Tradeline__r.nu_dse__Verified_Balance__c == null) ? 0 : Integer.ValueOf(sc.Tradeline__r.nu_dse__Verified_Balance__c);
            debt.LastStatementDate = (sc.Tradeline__r.nds_Last_Statement_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : sc.Tradeline__r.nds_Last_Statement_Date__c;
            debt.InterestRate =  (sc.Tradeline__r.nu_dse__Percentage__c == null) ? 0 : Integer.ValueOf(sc.Tradeline__r.nu_dse__Percentage__c);
            debt.IsCashOrTransfer = sc.Tradeline__r.is_cash_or_transfer__c;
            debt.LastPaymentDate = (sc.Tradeline__r.nu_dse__Last_Payment_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : sc.Tradeline__r.nu_dse__Last_Payment_Date__c;
            debt.EndedOn = (sc.Tradeline__r.Ended_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : sc.Tradeline__r.Ended_On__c;
            debt.CreatedOn = sc.Tradeline__r.CreatedDate;
            debt.ModifiedOn = sc.Tradeline__r.LastModifiedDate;
            debt.ApplicantType = (sc.Tradeline__r.Applicant_Type__c == null) ? sc.Tradeline__r.Applicant_Type__c : (sc.Tradeline__r.Applicant_Type__c.contains('Co-Applicant')) ? 'CoApplicant' : sc.Tradeline__r.Applicant_Type__c; 
            
            List<nu_dse__Offer__c> OfferList = TradeOfferMap.get(sc.Tradeline__c);
            String SettlementStatus = 'None';
            if(OfferList == null || OfferList.isEmpty()){
                SettlementStatus = 'None'; 
            }
            else if(OfferList != null && OfferList.size()==1){
                settlementStatus = OfferList.get(0).Settlement_Status__c;
            } else {
                
                DateTime LastModifiedDate;
                for(nu_dse__Offer__c Offer : OfferList){
                    if(LastModifiedDate == null || LastModifiedDate < Offer.LastModifiedDate){
                        LastModifiedDate = Offer.LastModifiedDate;
                        SettlementStatus = Offer.Settlement_Status__c;
                    }
                }
            }
            
            if(SettlementStatus != '' && SettlementStatus != null && SettlementStatus == 'Payment Plan - Active')
            {
                debt.SettlementStatus = 'Payment_Plan_Active';
            }                
            else if(SettlementStatus != '' && SettlementStatus != null && SettlementStatus == 'Payment Plan - Suspended')
            {
                debt.SettlementStatus = 'Payment_Plan_Suspended';
            }
            else
            {
                debt.SettlementStatus = (string.isBlank(SettlementStatus)) ? SettlementStatus : SettlementStatus.replace(' ','_');
            }
    
            
            // some field values for tralines are not mapped
            debt.DebtId = (sc.Tradeline__r.import_Id__c == null) ? 0 : Long.ValueOf(sc.Tradeline__r.import_Id__c);
            debt.fileNumber = sc.Tradeline__r.nu_dse__Program__r.import_Id__c;
            
            
             leadtracNetDebt.ArrayOfDebtProperty properties = new leadtracNetDebt.ArrayOfDebtProperty();
            properties.DebtProperty = new List<leadtracNetDebt.DebtProperty>();
            
            leadtracNetDebt.DebtProperty property = new leadtracNetDebt.DebtProperty();
            property.Name = 'CourtName';
            Property.Value = sc.Court_Name__c;
                        properties.DebtProperty.add(Property);

                        property = new leadtracNetDebt.DebtProperty();      
                       property.Name = 'CreditorFirmName';
            Property.Value = sc.New_Creditor_Name__c;
                                    properties.DebtProperty.add(Property);

            
            
            property = new leadtracNetDebt.DebtProperty();      
            property.Name = 'CreditorAttorneyContact';
            Property.Value = sc.Attorney_Contact__c;
                        properties.DebtProperty.add(Property);

            property = new leadtracNetDebt.DebtProperty();
                       property.Name = 'CompliantCaptionPlaintiffName';
            Property.Value = sc.Name_Plaintiff_as_in_caption__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'LastPaymentDate';
            Property.Value = String.ValueOf(sc.Date_of_Client_last_payment_to_creditor__c);
                                    properties.DebtProperty.add(Property);

          
          property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'ComplaintType';
            Property.Value = sc.Complaint_type__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'CreditorAttorneyFax';
            Property.Value = sc.Fax__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'CompliantCaptionDefendantName';
            Property.Value = sc.Defendant_s_name_as_in_the_caption__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'LastPaymentAmount';
            Property.Value = sc.Amount_of_last_payment_to_creditor__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'ServiceDate';
            Property.Value = String.ValueOf(sc.Date_of_Service__c);
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'CourtCaseNumber';
            Property.Value = sc.Court_Case_Number__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'ServiceMethod';
            Property.Value = sc.Method_of_Service__c;
                                    properties.DebtProperty.add(Property);

            
            property = new leadtracNetDebt.DebtProperty();
                        property.Name = 'ProgramContactNumber';
            Property.Value = sc.Program__r.Portfolio__r.Support_Phone_Number__c; 
                                    properties.DebtProperty.add(Property);

            
           
            debt.Properties = properties;
            
            List<leadtracNetDebt.Debt> debtList = new List<leadtracNetDebt.Debt>();
            debtList.add(debt);
            arrayOfDebt.debt = debtList;
            
            try{
                LeadtracNetDebt.GetDebtsResult debtResult = new LeadtracNetDebt.GetDebtsResult();  
                debtResult = soap.CreateOrUpdateDebts(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,
                                                          sc.TradeLine__r.nu_dse__Program__r.Import_ID__c, arrayOfDebt);
                                                          
                if(debtResult.IsSuccessful == true)
                {
                    leadtracNetDebt.ArrayOfDebt arrayofDebtResult = debtResult.Debts;
                    List<leadtracNetDebt.Debt> d = arrayofDebtResult.Debt;
                    if(!isFailed){
                        setIntegrationFields(sc,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                    }
                }
                else
                {
                    LeadtracNetDebt.ArrayOfResultMessage arrayResultMessage = debtResult.Messages;
                    List<LeadtracNetDebt.ResultMessage> resultMessage = arrayResultMessage.ResultMessage;
                    if(!isFailed){
                        setIntegrationFields(sc,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessage[0].Message);
                    }
                }
            }
            catch(Exception e)
            {
                 if(!isFailed){
                 setIntegrationFields(sc,'Failed Tradeline',
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                 }
                System.debug('****exception'+e.getStackTraceString());
                System.debug('****exception'+e.getMessage());
            }

        }
        Update CaseList;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    public static void setIntegrationFields(Summon__c SFSCase,string IntegrationStatus,string IntegrationReason)
    {
        string Reason1 = null;
        string Reason2 = null;
        
        if(string.isNotBlank(IntegrationReason))
        {
            if(IntegrationReason.length() <= 250)
            {
                Reason1 = IntegrationReason.subString(0,IntegrationReason.length());
            }
            else if(IntegrationReason.length() > 250)
            {
                Reason1 = IntegrationReason.subString(0,250);
                
                if(IntegrationReason.length() > 500)
                    Reason2 = IntegrationReason.subString(250,500);
                else
                    Reason2 = IntegrationReason.subString(250,IntegrationReason.length());
            }     
        }
        
        
        SFSCase.Integration_Status__c = IntegrationStatus;
        SFSCase.Integration_Reason__c = Reason1;
        SFSCase.Integration_Reason_2__c = Reason2;
    }

}