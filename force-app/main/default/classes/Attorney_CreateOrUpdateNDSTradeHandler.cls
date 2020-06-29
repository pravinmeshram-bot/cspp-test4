public without sharing class Attorney_CreateOrUpdateNDSTradeHandler{
    
    public static void populateGCSIdOnProspect(){
        List<nu_dse__Tradeline__c> TradelineList = (List<nu_dse__Tradeline__c>)Trigger.new;
        Map<Id,nu_dse__Tradeline__c> TradelineMap = (Map<Id,nu_dse__Tradeline__c>)Trigger.oldMap;
        
        List<Id> TradelineIds = new List<Id>();
        for(nu_dse__Tradeline__c Tradeline: TradelineList){
            if(Tradeline.nu_dse__Prospect__c != null && ((Trigger.isInsert && Tradeline.nu_dse__Program__c != null) || (Trigger.isUpdate && (Tradeline.nu_dse__Program__c != TradelineMap.get(Tradeline.Id).nu_dse__Program__c || Tradeline.nu_dse__Prospect__c != TradelineMap.get(Tradeline.Id).nu_dse__Prospect__c)))){
                TradelineIds.add(Tradeline.Id);
            }
        }
        
        if(!TradelineIds.isEmpty()){
            List<nu_dsE__Tradeline__c> Tradelines = [Select Id, nu_dse__Program__r.nu_dse__Account__r.nu_dse__External_GCS_Id__c,nu_dse__Prospect__c, nu_dse__Prospect__r.External_GCS_Id__c from nu_dse__Tradeline__c where Id=:TradelineIds];
            List<nu_dse__Prospect__c> ProspectList = new List<nu_dse__Prospect__c>();
            
            for(nu_dse__Tradeline__c Tradeline: Tradelines){
                if(Tradeline.nu_dse__Program__r.nu_dse__Account__r.nu_dse__External_GCS_Id__c != Tradeline.nu_dse__Prospect__r.External_GCS_Id__c){
                    nu_dse__Prospect__c Prospect = new nu_dse__prospect__c();
                    Prospect.Id = Tradeline.nu_dsE__Prospect__c;
                    Prospect.External_GCS_Id__c = Tradeline.nu_dse__Program__r.nu_dse__Account__r.nu_dsE__External_GCS_Id__C;
                    ProspectList.add(Prospect);
                }
            }
            if(!ProspectList.isEMpty()){
                Update ProspectList;
            }
        }
    }
    
    //changes for NMI - 532 by Rajesh
    
    Public Static Boolean isProgramUpdated = False;
    public static void UpdateProgramFuturePayments(){
        if(!isProgramUpdated){
            System.debug('*****Tradeline After Update');
            List<nu_dse__Tradeline__c> TradeList = (List<nu_dse__Tradeline__c>)Trigger.new;
            Map<Id,nu_dse__Tradeline__c> TradeOldMap = (Map<Id,nu_dse__Tradeline__c>)Trigger.OldMap;
            List<Id> ProgramIds = new List<Id>();
            for(nu_dse__Tradeline__c trade : TradeList){
                if((trade.Future_Payment_Count__c > 0 && trade.Future_Payment_Count__c != TradeOldMap.get(Trade.Id).Future_Payment_Count__c) || (trade.Future_Payment_Total_Amount__c > 0 && trade.Future_Payment_Total_Amount__c != TradeOldMap.get(Trade.Id).Future_Payment_Total_Amount__c) || (trade.Future_Payment_Amount__c > 0 && trade.Future_Payment_Amount__c != TradeOldMap.get(Trade.Id).Future_Payment_Amount__c)){
                    ProgramIds.add(Trade.nu_dse__Program__c);
                }
            }
            System.debug('*****'+ProgramIds);
            if(!ProgramIds.isEmpty()){
                List<nu_dse__Tradeline__c> AllTradelineList = [Select Id,Future_Payment_Count__c,Future_Payment_Total_Amount__c,Future_Payment_Amount__c, nu_dse__Program__c from nu_dse__Tradeline__c where nu_dse__Program__c =: ProgramIds];
                
                Map<Id,nu_dse__Program__c> ProgramMap = new Map<Id,nu_dse__Program__c>();
                for(nu_dse__Tradeline__c Tradeline : AllTradelineList){
                    
                    nu_dse__Program__c Program = new nu_dse__Program__c();
                    Program.Future_Payment_Count__c = 0;
                    Program.Future_Payment_Total_Amount__c = 0;
                    Program.Future_Payment_Amount__c = 0;
                    if(ProgramMap.containsKey(Tradeline.nu_dse__Program__c)){
                        Program = ProgramMap.get(Tradeline.nu_dse__Program__c);
                    } else {
                        Program.Id = Tradeline.nu_dse__Program__c;
                    }
                    
                    if(Tradeline.Future_Payment_Count__c != null)
                        Program.Future_Payment_Count__c += Tradeline.Future_Payment_Count__c;
                    if(Tradeline.Future_Payment_Amount__c != null)
                        Program.Future_Payment_Amount__c += Tradeline.Future_Payment_Amount__c;
                    if(Tradeline.Future_Payment_Total_Amount__c != null)
                        Program.Future_Payment_Total_Amount__c += Tradeline.Future_Payment_Total_Amount__c;            
                        
                    ProgramMap.Put(Program.Id,Program);
                }
                System.debug('*****'+ProgramMap);
                Update ProgramMap.values();
                isProgramUpdated = true;
            }
        }
    }
    
    
    public static boolean CreditorUpdated = false;
    public static void UpdateCreditorData(List<nu_dse__Tradeline__c> TradelineList, Map<Id,nu_dse__Tradeline__c> TradelineNewMap,Map<Id,nu_dse__Tradeline__c> TradelineOldMap){
        if(!CreditorUpdated){
        System.debug('****Here');
        List<String> CreditorNameList = new List<String>();
        List<String> NegotiatorIds = new List<String>();
        
        for(nu_dse__Tradeline__c tradeline : TradelineList){
            if(Trigger.isInsert || tradeline.nds_Original_Creditor_Name__c != TradelineOldMap.get(tradeline.Id).nds_Original_Creditor_Name__c || tradeline.nds_Current_Creditor_Name__c != TradelineOldMap.get(tradeline.Id).nds_Current_Creditor_Name__c || tradeline.nu_dse__New_Creditor__c != TradelineOldMap.get(tradeline.Id).nu_dse__New_Creditor__c || tradeline.nu_dse__Original_Creditor__c != TradelineOldMap.get(tradeline.Id).nu_dse__Original_Creditor__c){
                if(Tradeline.isAttorney__c){
                    CreditorNameList.add(tradeline.nds_Original_Creditor_Name__c);
                    CreditorNameList.add(tradeline.nds_Current_Creditor_Name__c);
                } else {
                    String CurrentCreditor = '';
                    String OriginalCreditor = '';
                    if(tradeline.nu_dse__New_Creditor__c != null)
                        CreditorNameList.add(tradeline.Current_and_Original_Creditor_Name__c.substringBefore('*'));
                    if(tradeline.nu_dse__Original_Creditor__c != null)
                        CreditorNameList.add(tradeline.Current_and_Original_Creditor_Name__c.substringAfter('*'));
                }
            }
            if(tradeline.NDS_Negotiator_Id__c != null){
                NegotiatorIds.add(tradeline.NDS_Negotiator_Id__c);
            }
        }
        
        if(!CreditorNameList.isEmpty()){
        List<NDS_User_List__c> NDSUsers = [Select Id,User_Id__c,Email__c from NDS_User_List__c where User_Id__c=:NegotiatorIds];
        List<String> UserEmails = new List<String>();
        Map<String,String> NDSUserMap = new Map<String,String>();
        for(NDS_User_List__c NDSUser : NDSUsers){
            UserEmails.add(NDSUser.Email__c);
            NDSUserMap.put(NDSUser.User_Id__c,NDSUser.Email__c);
        }
        
        List<User> UserList = [Select Id,Name,Email from User where Email=:UserEmails];
        Map<String,User> EmailUserMap = new Map<String,User>();
        for(User u : UserList){
            EmailUserMap.put(u.Email, u);
        }
        
        System.debug('****CreditorNameList'+CreditorNameList);
        List<Creditor_Standardization__c> CreditorList = [Select Id, Name, Aggressiveness__c,Category__c,Creditor_Name__c,Creditor_Type__c from Creditor_Standardization__c where Creditor_Name__c =: CreditorNameList];
        Map<String,Creditor_Standardization__c> CreditorMap = new Map<String,Creditor_Standardization__c>();
        for(Creditor_Standardization__c Creditor : CreditorList){
            if(Creditor.Creditor_Name__c != null){
                CreditorMap.put(Creditor.Creditor_Name__c.toLowerCase(),Creditor);
            }
        }
        System.debug('****CreditorMap'+CreditorMap);
        For(nu_dse__Tradeline__c tradeline : TradelineList){
            System.debug('***for loop');
            String CurrentCreditor = '';
            String OriginalCreditor = '';
            if(tradeline.nu_dse__New_Creditor__c != null)
                CurrentCreditor = tradeline.Current_and_Original_Creditor_Name__c.substringBefore('*');
            if(tradeline.nu_dse__Original_Creditor__c != null)
                OriginalCreditor = tradeline.Current_and_Original_Creditor_Name__c.substringAfter('*');
            
            if(tradeline.nds_Original_Creditor_Name__c != null && CreditorMap.containsKey(tradeline.nds_Original_Creditor_Name__c.toLowerCase()) && Tradeline.isAttorney__c){
                System.debug('***Original Creditor');
                tradeline.Normalized_Original_Creditor__c = CreditorMap.get(tradeline.nds_Original_Creditor_Name__c.toLowerCase()).Name;
                tradeline.Original_Creditor_Aggressiveness__c= CreditorMap.get(tradeline.nds_Original_Creditor_Name__c.toLowerCase()).Aggressiveness__c;
                tradeline.Original_Creditor_Category__c= CreditorMap.get(tradeline.nds_Original_Creditor_Name__c.toLowerCase()).Category__c;
                tradeline.Original_Creditor_Type__c= CreditorMap.get(tradeline.nds_Original_Creditor_Name__c.toLowerCase()).Creditor_Type__c;
            } else if(OriginalCreditor != null && CreditorMap.containsKey(OriginalCreditor.toLowerCase()) && !Tradeline.isAttorney__c){
                System.debug('***Original Creditor');
                tradeline.Normalized_Original_Creditor__c = CreditorMap.get(OriginalCreditor.toLowerCase()).Name;
                tradeline.Original_Creditor_Aggressiveness__c= CreditorMap.get(OriginalCreditor.toLowerCase()).Aggressiveness__c;
                tradeline.Original_Creditor_Category__c= CreditorMap.get(OriginalCreditor.toLowerCase()).Category__c;
                tradeline.Original_Creditor_Type__c= CreditorMap.get(OriginalCreditor.toLowerCase()).Creditor_Type__c;
            }
            if(tradeline.nds_Current_Creditor_Name__c != null && CreditorMap.containsKey(tradeline.nds_Current_Creditor_Name__c.toLowerCase()) && Tradeline.isAttorney__c){
                System.debug('****Current Creditor');
                //S20-340 - Tiago commented
                //tradeline.Normalized_Current_Creditor__c = CreditorMap.get(tradeline.nds_Current_Creditor_Name__c.toLowerCase()).Name;
                tradeline.Current_Creditor_Aggressiveness__c= CreditorMap.get(tradeline.nds_Current_Creditor_Name__c.toLowerCase()).Aggressiveness__c;
                tradeline.Current_Creditor_Category__c= CreditorMap.get(tradeline.nds_Current_Creditor_Name__c.toLowerCase()).Category__c;
                tradeline.Current_Creditor_Type__c= CreditorMap.get(tradeline.nds_Current_Creditor_Name__c.toLowerCase()).Creditor_Type__c;
            } else if(CurrentCreditor != null && CreditorMap.containsKey(CurrentCreditor.toLowerCase()) && !tradeline.isAttorney__c){
                System.debug('****Current Creditor');
                //S20-340 - Tiago commented
                //tradeline.Normalized_Current_Creditor__c = CreditorMap.get(CurrentCreditor.toLowerCase()).Name;
                tradeline.Current_Creditor_Aggressiveness__c= CreditorMap.get(CurrentCreditor.toLowerCase()).Aggressiveness__c;
                tradeline.Current_Creditor_Category__c= CreditorMap.get(CurrentCreditor.toLowerCase()).Category__c;
                tradeline.Current_Creditor_Type__c= CreditorMap.get(CurrentCreditor.toLowerCase()).Creditor_Type__c;
            }
            
            if(Attorney_StaticVariableUtility.apiuser){
                if(tradeline.NDS_Negotiator_Id__c != null && NDSUserMap.containsKey(tradeline.NDS_Negotiator_Id__c) && EmailUserMap.containsKey(NDSUserMap.get(tradeline.NDS_Negotiator_Id__c))){
            //       tradeline.Negotiator__c = EmailUserMap.get(NDSUserMap.get(tradeline.NDS_Negotiator_Id__c)).Id;
                } else {
            //        tradeline.Negotiator__c = null;
                }
            }
        }
        }
        creditorUpdated = true;
        }
    }

    public static void CreateOrUpdateNDSTradeLine(List<nu_dse__TradeLine__c> ObjTradeLineList, Map<Id,nu_dse__TradeLine__c> ObjTradeLineOldMap, Map<Id, nu_dse__Tradeline__c> ObjTradelineNewMap){
        system.debug('###triggerStep1::');
        Boolean IsInsert = false;
        Boolean IsOriginalBalanceChanged = false;
        List<nu_dse__TradeLine__c> updateTradeLineList = new List<nu_dse__TradeLine__c>();
        
        Set<string> reProcessErrorMessage = Attorney_StaticVariableUtility.reProcessConfigs('TradeLine',false);
        
        List<nu_dse__Offer__c> offerList = [Select Id,Settlement_Status__c,nu_dse__TradeLine__c,LastModifiedDate from nu_dse__Offer__c where nu_dse__TradeLine__c =:ObjTradelineNewMap.keySet() AND IsAttorney__c=true AND latest_offer__c=true];
        
        Map<Id,List<nu_dse__Offer__c>> TradelineOfferMap = new Map<Id,List<nu_dse__Offer__c>>();
        for(nu_dse__Offer__c offer : OfferList){
            if(!TradelineOfferMap.containsKey(offer.nu_dse__TradeLine__c)){
                TradelineOfferMap.put(offer.nu_dse__TradeLine__c,new List<nu_dse__Offer__c>());
            }
            TradelineOfferMap.get(offer.nu_dse__TradeLine__c).add(offer);
        }
       
        for(nu_dse__TradeLine__c ObjTradeLine: ObjTradeLineList){
            
            System.debug('****'+ObjTradeLine.IsAttorney__c);
            System.debug('****'+Attorney_StaticVariableUtility.apiuser);
            if(ObjTradeLine.IsAttorney__c == true && Attorney_StaticVariableUtility.apiuser == false)
            {
                System.debug('****Attorney');
                if(string.isBlank(ObjTradeLine.nu_dse__New_Creditor__c)  && string.isBlank(ObjTradeLine.nu_dse__Original_Creditor__c) && string.isBlank(ObjTradeLine.nu_dse__Sales_Creditor_Name__c))
                    return;
                
                if(ObjTradeLine.Import_Id__c==Null)
                    IsInsert = true;
                else
                    IsInsert = false; 
                
                System.debug('****isInsert'+isInsert);
                System.debug('****ObjTradeLine.Account_Status__c'+ObjTradeLine.Account_Status__c);
                
                if((IsInsert==false && ObjTradeLine.IsRelatedRecordEligibleForPick__c==true && 
                    (ObjTradeLine.nu_dse__New_Creditor__c!=ObjTradeLineOldMap.get(ObjTradeLine.Id).nu_dse__New_Creditor__c 
                     || ObjTradeLine.nds_Debt_Type__c != ObjTradeLineOldMap.get(ObjTradeLine.Id).nds_Debt_Type__c
                     || ObjTradeLine.Negotiation_Status__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Negotiation_Status__c
                                          || ObjTradeLine.Negotiation_Stage__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Negotiation_Stage__c

                     || ObjTradeLine.Negotiator__c != ObjTradeLineOldMap.get(ObjTradeLine.id).Negotiator__c
                     || ObjTradeLine.Account_Status__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Account_Status__c
                     || ObjTradeLine.Primary_Applicant__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Primary_Applicant__c
                     || ObjTradeLine.Secondary_Applicant__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Secondary_Applicant__c
                     || ObjTradeLine.Secondary_Name_Relation__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Secondary_Name_Relation__c
                     || ObjTradeLine.Additional_Name__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Additional_Name__c
                     || ObjTradeLine.Additional_Relation__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Additional_Relation__c
                     || ObjTradeLine.nu_dse__Minimum_Payment_Amount__c!= ObjTradeLineOldMap.get(ObjTradeLine.id).nu_dse__Minimum_Payment_Amount__c
                                          || ObjTradeLine.nds_statement_included__c!= ObjTradeLineOldMap.get(ObjTradeLine.id).nds_statement_included__c
                     || ObjTradeLine.Negotiation_Note__c!= ObjTradeLineOldMap.get(ObjTradeLine.id).Negotiation_Note__c
                     || (ObjTradeLine.nu_dse__Include_In_The_Program__c != ObjTradeLineOldMap.get(ObjTradeLine.id).nu_dse__Include_In_The_Program__c && ObjTradeLine.nu_dse__Include_In_The_Program__c == False)

                                          || ObjTradeLine.Lit_Def_Stage__c!= ObjTradeLineOldMap.get(ObjTradeLine.id).Lit_Def_Stage__c
                                          || ObjTradeLine.Other_Stage__c!= ObjTradeLineOldMap.get(ObjTradeLine.id).Other_Stage__c
                                          || ObjTradeLine.Litigation_Stage__c!= ObjTradeLineOldMap.get(ObjTradeLine.id).Litigation_Stage__c


                     || ObjTradeLine.nu_dse__Verified_Balance__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).nu_dse__Verified_Balance__c
                     || ObjTradeLine.nds_Last_Statement_Date__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).nds_Last_Statement_Date__c
                     || ObjTradeLine.nu_dse__Percentage__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).nu_dse__Percentage__c
                     || ObjTradeLine.is_cash_or_transfer__c != ObjTradeLineOldMap.get(ObjTradeLine.id).is_cash_or_transfer__c
                     || ObjTradeLine.nu_dse__Last_Payment_Date__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).nu_dse__Last_Payment_Date__c
                     || ObjTradeLine.Ended_On__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).Ended_On__c
                     || ObjTradeLine.nu_dse__Sales_Creditor_Name__c!=ObjTradeLineOldMap.get(ObjTradeLine.id).nu_dse__Sales_Creditor_Name__c
             //        || ObjTradeLine.nu_dse__Current_Stage__c!=ObjTradeLineOldMap.get(ObjTradeLine.Id).nu_dse__Current_Stage__c
                     || ObjTradeLine.nu_dse__Original_Debt__c !=ObjTradeLineOldMap.get(ObjTradeLine.Id).nu_dse__Original_Debt__c 

                     || ObjTradeLine.SFS_Current_Balance__c!=ObjTradeLineOldMap.get(ObjTradeLine.Id).SFS_Current_Balance__c
                     || ObjTradeLine.Applicant_Type__c!=ObjTradeLineOldMap.get(ObjTradeLine.Id).Applicant_Type__c
                     || ObjTradeLine.nu_dse__New_Account_Number__c!=ObjTradeLineOldMap.get(ObjTradeLine.Id).nu_dse__New_Account_Number__c)) //Condition 1
                   || (IsInsert==true && ObjTradeLine.IsRelatedRecordEligibleForPick__c==true) // Condition 2
                   || (objTradeLine.Integration_Status__c == Attorney_StaticVariableUtility.INTEGRATION_FAILED && string.isNotBlank(ObjTradeLine.Integration_Reason__c) 
                       && reProcessErrorMessage.size() > 0  && ObjTradeLine.IsRelatedRecordEligibleForPick__c==true
                       && (Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,objTradeLine.Integration_Reason__c) || 
                           Attorney_StaticVariableUtility.reProcessRecordCheck(reProcessErrorMessage,objTradeLine.Integration_Reason_2__c)))//condition 3
                   || (IsInsert==true && string.isBlank(ObjTradeLine.Integration_Status__c) && ObjTradeLine.IsRelatedRecordEligibleForPick__c==true))//condition 4
                {
                    System.debug('****Inside if, values changed');
                    
                    if(IsInsert==false && ObjTradeLine.nu_dse__Original_Debt__c  != ObjTradeLineOldMap.get(ObjTradeLine.Id).nu_dse__Original_Debt__c)
                        IsOriginalBalanceChanged = true;
                    else
                       IsOriginalBalanceChanged = false; 

                      
                    System.enqueueJob(new AsynCallToNDSDebt(ObjTradeLine.Id, TradelineOfferMap.get(ObjTradeLine.Id),IsOriginalBalanceChanged,IsInsert));
                    
                    //Sync Update - Integration Status to Initiated
                    nu_dse__TradeLine__c objTradeLineUpd = new nu_dse__TradeLine__c(Id=ObjTradeLine.Id);
                    setIntegrationFields(objTradeLineUpd,Attorney_StaticVariableUtility.INTEGRATION_INITIATED,null);
                    updateTradeLineList.add(objTradeLineUpd);
                } 
                
            }
        }
        System.debug('***After if');
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
        update updateTradeLineList;
    }
    
    public static LeadtracNetDebt.ArrayOfDebt doTradeLineMapping(nu_dse__TradeLine__c ObjTradeLine, List<nu_dse__Offer__c> offerList,Boolean IsOriginalBalanceChanged, Boolean IsInsert)
    {
        system.debug('###step2::');
        LeadtracNetDebt.ArrayOfDebt arrayOfDebt = new LeadtracNetDebt.ArrayOfDebt();
        LeadtracNetDebt.Debt debt = new LeadtracNetDebt.Debt();  
        debt.DebtType = ObjTradeLine.nds_Debt_Type__c;
        debt.NegotiationStatus = ObjTradeLine.Negotiation_Status__c;
        if(!string.isBlank(ObjTradeLine.negotiator__c)){
        List<User> userLst = [select id,Name, Email from User where Id =: ObjTradeLine.Negotiator__c];
        if(!UserLst.isEmpty()){
            String validEmail = '';
            if(UserLst[0].Email.contains('@example.com')){
                validEmail = UserLst[0].Email.remove('@example.com');  
                validEmail = validEmail.replace('=','@');
            }else
                validEmail = UserLst[0].Email;
            if(validEmail != NULL && validEmail != ''){
               List<NDS_User_List__c> NDSUsrLst = [Select Id,User_Name__c,Email__c,User_Id__c from NDS_User_List__c where Email__c =: validEmail];       
               if(!NDSUsrLst.isEmpty()){
                   debt.Negotiator= NDSUsrLst[0].User_Id__c;    
               }else{
                   debt.Negotiator = '0000';    
               }
            }
        }
        }else{
            debt.Negotiator = '0000';    
        } 
        System.debug('******Negotiator'+debt.Negotiator);
        debt.AccountStatus = ObjTradeLine.Account_Status__c;
        debt.PrimaryName = ObjTradeLine.Primary_Applicant__c;
        debt.SecondaryName = ObjTradeLine.Secondary_Applicant__c;
        debt.SecondaryNameRelation = ObjTradeLine.Secondary_Name_Relation__c;
        debt.AdditionalName = ObjTradeLine.Additional_Name__c;
        debt.AdditionalRelation = ObjTradeLine.Additional_Relation__c;
        debt.OriginalBalance = (ObjTradeLine.nu_dse__Original_Debt__c == null) ? 0 : Integer.ValueOf(ObjTradeLine.nu_dse__Original_Debt__c);
        debt.MinimumPayment =  (ObjTradeLine.nu_dse__Minimum_Payment_Amount__c == null) ? 0 : Integer.ValueOf(ObjTradeLine.nu_dse__Minimum_Payment_Amount__c);
                
                if(ObjTradeLine.Negotiation_Note__c != 'Data Clean Up Needed in NDS')
                {
                debt.NegotiationNote=  ObjTradeLine.Negotiation_Note__c;
                }

        debt.IsStatementIncluded=  string.valueof(ObjTradeLine.nds_statement_included__c);

        
        debt.VerifiedBalance = (ObjTradeLine.nu_dse__Verified_Balance__c == null) ? 0 : Integer.ValueOf(ObjTradeLine.nu_dse__Verified_Balance__c);
        debt.LastStatementDate = (ObjTradeLine.nds_Last_Statement_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : ObjTradeLine.nds_Last_Statement_Date__c;
        debt.InterestRate =  (ObjTradeLine.nu_dse__Percentage__c == null) ? 0 : Integer.ValueOf(ObjTradeLine.nu_dse__Percentage__c);
        debt.IsCashOrTransfer = ObjTradeLine.is_cash_or_transfer__c;
        debt.LastPaymentDate = (ObjTradeLine.nu_dse__Last_Payment_Date__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : ObjTradeLine.nu_dse__Last_Payment_Date__c;
        debt.EndedOn = (ObjTradeLine.Ended_On__c == null) ? Attorney_StaticVariableUtility.DEFAULTDATETIME : ObjTradeLine.Ended_On__c;
        debt.CreatedOn = ObjTradeLine.CreatedDate;
        debt.ModifiedOn = ObjTradeLine.LastModifiedDate;
        debt.ApplicantType = (ObjTradeLine.Applicant_Type__c == null) ? ObjTradeLine.Applicant_Type__c : (ObjTradeLine.Applicant_Type__c.contains('Co-Applicant')) ? 'CoApplicant' : ObjTradeLine.Applicant_Type__c;
        //debt.SettlementStatus = ObjTradeLine.nu_dse__Current_Stage__c; 
       // debt.SettlementStatus = 'None'; 
        debt.DebtId = (ObjTradeLine.import_Id__c == null) ? 0 : Long.ValueOf(ObjTradeLine.import_Id__c);
        debt.fileNumber = ObjTradeLine.nu_dse__Program__r.import_Id__c;
        
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
        
        System.debug('++++++++++++++++++++++3.debt.DebtId ' + debt.DebtId);
        

        List<Id> creditorIds = new List<Id>();
        string salesCreditorName = null;
        
        if(ObjTradeLine.nu_dse__New_Creditor__c != null)
            creditorIds.add(ObjTradeLine.nu_dse__New_Creditor__c);
        
        if(IsOriginalBalanceChanged != true)
        {           
            if((ObjTradeLine.nu_dse__Original_Creditor__c != null && IsInsert == true) || (ObjTradeLine.nu_dse__Original_Creditor__c != null && !checkCreditorExistence(ObjTradeLine.nu_dse__Program__r.import_Id__c) && IsInsert == false))
                creditorIds.add(ObjTradeLine.nu_dse__Original_Creditor__c);
            
            if(ObjTradeLine.nu_dse__New_Creditor__c == null && ObjTradeLine.nu_dse__Original_Creditor__c == null && ObjTradeLine.nu_dse__Sales_Creditor_Name__c != null)
                salesCreditorName = ObjTradeLine.nu_dse__Sales_Creditor_Name__c;
        }
        
        System.debug('++++++++++++++++++++++4. creditorIds ' + creditorIds);
        
        if((creditorIds!=null && creditorIds.size() > 0) || salesCreditorName != null)
        {
            List<LeadtracNetDebt.DebtCreditor> debtCreditorList = new List<LeadtracNetDebt.DebtCreditor>();
            if(creditorIds.size() > 0)
            {
                Map<Id,Account> accCreditorMap = new Map<Id,Account>([Select id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode from Account where id IN:creditorIds]);
                //for(Account accCreditor : )
                //{
                    //System.debug('++++++++++++++++++++++5. accCreditor Name' + accCreditor.Name);
                    if(ObjTradeLine.nu_dse__Original_Creditor__c != null && AccCreditorMap.containsKey(ObjTradeLine.nu_dse__Original_Creditor__c) && !Test.isRunningTest()){
                        LeadtracNetDebt.DebtCreditor debtCreditor = doCheckCreditor(AccCreditorMap.get(ObjTradeLine.nu_dse__Original_Creditor__c),ObjTradeLine,false,true);
                        System.debug('++++++++++++++++++++++5a. debtCreditor ' + debtCreditor);
                        System.debug('++++++++++++++++++++++5a. debtCreditor ' + debtCreditor.level);
                        debtCreditorList.add(debtCreditor);
                    }
                    if(ObjTradeLine.nu_dse__New_Creditor__c != null && AccCreditorMap.containsKey(ObjTradeLine.nu_dse__New_Creditor__c) && !Test.isRunningTest()){
                        LeadtracNetDebt.DebtCreditor debtCreditor = doCheckCreditor(AccCreditorMap.get(ObjTradeLine.nu_dse__New_Creditor__c),ObjTradeLine,false,false);
                        System.debug('++++++++++++++++++++++5a. debtCreditor ' + debtCreditor);
                        System.debug('++++++++++++++++++++++5a. debtCreditor ' + debtCreditor.level);
                        debtCreditorList.add(debtCreditor);
                    }
                    //System.debug('++++++++++++++++++++++5a. debtCreditor ' + debtCreditor);
                    System.debug('++++++++++++++++++++++5b. debtCreditorList ' + debtCreditorList);
                    
                //}
            }
            else if(salesCreditorName!=null)
            {
                Account salesCreditor = new Account();
                salesCreditor.Name =  salesCreditorName; 
                
                LeadtracNetDebt.DebtCreditor debtSalesCreditor = doCheckCreditor(salesCreditor,ObjTradeLine,false,true);
                debtCreditorList.add(debtSalesCreditor);
            }
            
            LeadtracNetDebt.ArrayOfDebtCreditor  arrayofDebtCreditor = new LeadtracNetDebt.ArrayOfDebtCreditor();
            arrayofDebtCreditor.DebtCreditor = debtCreditorList;
            debt.CreditorHistory = arrayofDebtCreditor;
            
            System.debug('++++++++++++++++++++++5b. Final - debt.CreditorHistory ' + debt.CreditorHistory);
        }
        system.debug('###Debt::'+debt);
        List<leadtracNetDebt.Debt> debtList = new List<leadtracNetDebt.Debt>();
        debtList.add(debt);
        arrayOfDebt.debt = debtList;

        return arrayOfDebt;
    }
    
    public static LeadtracNetDebt.DebtCreditor doCheckCreditor(Account objAccount,nu_dse__TradeLine__c ObjTradeLine,Boolean IsCreditorCreated,Boolean isOriginal)
    {
        
        LeadtracNetDebt.DebtServiceSoap soap = new LeadtracNetDebt.DebtServiceSoap();
        LeadtracNetDebt.DebtCreditor debtCreditor = new LeadtracNetDebt.DebtCreditor();
        LeadtracNetDebt.GetCreditorListResult creditNameListResult = new LeadtracNetDebt.GetCreditorListResult(); 
        
        System.debug('***'+Attorney_StaticVariableUtility.credentials.UserName__c);
        System.debug('***'+Attorney_StaticVariableUtility.credentials.Password__c);
        System.debug('***'+objAccount.Name);
        
        creditNameListResult = soap.GetCreditorByName(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,objAccount.Name);    
        Boolean IsMatchFound = false;
        
        System.debug('****'+creditNameListResult);
        
        if(creditNameListResult != NULL && creditNameListResult.Creditors != null && creditNameListResult.Creditors.Creditor != null)
        {
            for(leadtracNetDebt.Creditor credit:creditNameListResult.Creditors.Creditor){
                
                if(credit.Address1 == objAccount.BillingStreet && credit.City == objAccount.BillingCity && 
                   credit.State == objAccount.BillingState && credit.Zip == objAccount.BillingPostalCode)
                {        
                    System.debug('++++++++++++++++++++++6. Match Found ' + credit.Name);
                    IsMatchFound = true;
                    debtCreditor  = doCreditorMapping(objAccount,ObjTradeLine,credit,isOriginal);
                }
            }
        }
        
        if(IsMatchFound == false && IsCreditorCreated == false)
        {
            System.debug('++++++++++++++++++++++7. Match not found - Created Creditor ' + objAccount.Name);
            debtCreditor  = CreateOrUpdateCreditor(objAccount,ObjTradeLine,isOriginal);
        }

        System.debug('++++++++++++++++++++++9. debtCreditor ' + debtCreditor);
        System.debug('++++++++++++++++++++++9. debtCreditor ' + debtCreditor.level);
        return debtCreditor;
    }
    
    
    public static LeadtracNetDebt.DebtCreditor doCreditorMapping(Account objAccount,nu_dse__TradeLine__c ObjTradeLine,leadtracNetDebt.Creditor credit, Boolean isOriginal)
    {
        System.debug('do creditor mapping');
        LeadtracNetDebt.Creditor creditor = new LeadtracNetDebt.Creditor();
        creditor.CreditorId = credit.CreditorId;
        creditor.CreditorType = credit.CreditorType;
        creditor.Name = credit.Name;
        creditor.Address1 = credit.Address1;
        creditor.Address2 = credit.Address2;
        creditor.City = credit.City;
        creditor.State = credit.State;
        creditor.Zip = credit.Zip;
        creditor.OfficePhone = credit.OfficePhone;
  /*      creditor.OfficeExt = ObjTradeLine.nds_Current_Creditor_Office_Ext__c;
        creditor.FaxPhone = ObjTradeLine.nds_Current_Creditor_Fax__c;
        creditor.Email = ObjTradeLine.nds_Current_Creditor_Email__c;
        creditor.Note = ObjTradeLine.nds_Current_Creditor_Note__c;*/
        creditor.OfficeExt = credit.OfficeExt;
        creditor.FaxPhone = credit.FaxPhone;
        creditor.Email = credit.Email;
        creditor.Note = credit.Note;
        creditor.ContactName = credit.ContactName;
        creditor.CreatedOn = credit.CreatedOn;
        creditor.ModifiedOn = credit.ModifiedOn;
        
        LeadtracNetDebt.DebtCreditor debtCreditor = new LeadtracNetDebt.DebtCreditor();
        
        if(objAccount.Id == ObjTradeLine.nu_dse__Original_Creditor__c && objAccount.Id != null && isOriginal)
        {
             debtCreditor.Amount = ObjTradeLine.nu_dse__Original_Debt__c;
             
             if(ObjTradeLine.nu_dse__Original_Account_Number__c != 'Data Clean Up Needed in NDS')
                {
             debtCreditor.AccountNumber = ObjTradeLine.nu_dse__Original_Account_Number__c;
             }
             debtCreditor.Level = 0;
         //    debtCreditor.POASent = debtCredit.POASent; Fix Pending

        }
        else if (objAccount.Id == ObjTradeLine.nu_dse__New_Creditor__c && objAccount.Id != null && !isOriginal)
        {
             debtCreditor.Amount = ObjTradeLine.SFS_Current_Balance__c;
             
             if(ObjTradeLine.nu_dse__New_Account_Number__c != 'Data Clean Up Needed in NDS')
                {
             debtCreditor.AccountNumber = ObjTradeLine.nu_dse__New_Account_Number__c;
             }
             debtCreditor.Level = 1; //Commenting this sends original as current and current as original
         //    debtCreditor.POASent = debtCredit.POASent; Fix Pending
        } 
        else if(objAccount.Id == null)
        {
            debtCreditor.Amount = ObjTradeLine.nu_dse__Original_Debt__c;
            if(ObjTradeLine.nu_dse__Original_Account_Number__c != 'Data Clean Up Needed in NDS')
{
            debtCreditor.AccountNumber = ObjTradeLine.nu_dse__Original_Account_Number__c;
            }
            debtCreditor.Level = 0;
        }
       
    //    debtCreditor.POASent = FALSE; //Fix Pending
        debtCreditor.CreatedOn =  system.now();
        debtCreditor.ModifiedOn = system.now();
        
        debtCreditor.Creditor = creditor; 
        System.debug(debtCreditor);
        System.debug(debtCreditor.level);
        return debtCreditor;
    }
    
    public static Boolean checkCreditorExistence(string filenumber)
    {
        Boolean IsCountExist = false; 
        LeadtracNetDebt.DebtServiceSoap soap = new LeadtracNetDebt.DebtServiceSoap();
        LeadtracNetDebt.DebtCreditor debtCreditor = new LeadtracNetDebt.DebtCreditor();
        LeadtracNetDebt.GetDebtsResult  getDebtsResult = new LeadtracNetDebt.GetDebtsResult();
        getDebtsResult = soap.GetDebts(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,filenumber);
        
        if(getDebtsResult.IsSuccessful == true)
        {
            leadtracNetDebt.ArrayOfDebt arrayDebt = getDebtsResult.Debts;
            
            List<leadtracNetDebt.Debt> debtList = arrayDebt.Debt;
            
            if(debtList.size() > 0)
            {
                IsCountExist = true;
            }   
        }
        
        return IsCountExist;
    }
    
    
    public static LeadtracNetDebt.DebtCreditor CreateOrUpdateCreditor(Account objAccount,nu_dse__TradeLine__c ObjTradeLine,Boolean isOriginal)
    {
        System.debug('do creditor mapping');
        LeadtracNetDebt.DebtServiceSoap soap = new LeadtracNetDebt.DebtServiceSoap();
        LeadtracNetDebt.DebtCreditor debtCreditor = new LeadtracNetDebt.DebtCreditor();
        LeadtracNetDebt.Creditor creditor = new LeadtracNetDebt.Creditor();
        creditor.CreditorId = Attorney_StaticVariableUtility.DEFAULTCREDITORID;
        //creditor.CreditorType = credit.CreditorType;
        creditor.CreditorType = 'Creditor';
        creditor.Name = objAccount.Name;
        creditor.Address1 = objAccount.BillingStreet;
        //creditor.Address2 = objAccount.Address2;
        creditor.City = objAccount.BillingCity;
        creditor.State = objAccount.BillingState;
        creditor.Zip = objAccount.BillingPostalCode;
  /*      creditor.OfficePhone = ObjTradeLine.nds_Current_Creditor_Office_Ext__c;
        creditor.OfficeExt = ObjTradeLine.nds_Current_Creditor_Office_Ext__c;
        creditor.FaxPhone = ObjTradeLine.nds_Current_Creditor_Fax__c;
        creditor.Email = ObjTradeLine.nds_Current_Creditor_Email__c;
        creditor.Note = ObjTradeLine.nds_Current_Creditor_Note__c;   */
        creditor.CreatedOn = System.now();
        creditor.ModifiedOn = System.now();
        
        System.debug('++++++++++++++++++++++7b. creditor' + creditor);
        
        LeadtracNetDebt.GetCreditorResult creditorResult = new LeadtracNetDebt.GetCreditorResult();
        creditorResult = soap.CreateOrUpdateCreditor(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,creditor); 
        
        
         if(creditorResult.IsSuccessful == true)
         {
             System.debug('++++++++++++++++++++++8. Creditor Created' + objAccount.Name);
             debtCreditor = doCheckCreditor(objAccount,ObjTradeLine,True,isOriginal);
         }
        System.debug(debtCreditor);
        return debtCreditor;
        
    }
    
    public static void setIntegrationFields(nu_dse__TradeLine__c ObjTradeLine,string IntegrationStatus,string IntegrationReason)
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
        
        
        ObjTradeLine.Integration_Status__c = IntegrationStatus;
        ObjTradeLine.Integration_Reason__c = Reason1;
        ObjTradeLine.Integration_Reason_2__c = Reason2;
    }
    
     public class AsynCallToNDSDebt implements Queueable,Database.AllowsCallouts {
                 
        Id ObjTradeLineId; 
        List<nu_dse__Offer__c> offerList;
        Boolean IsOriginalBalanceChanged;
        Boolean  IsInsert;
        public AsynCallToNDSDebt(Id ObjTradeLineId, List<nu_dse__Offer__c> offerList,Boolean IsOriginalBalanceChanged,Boolean IsInsert)
        {
            this.ObjTradeLineId = ObjTradeLineId;
            this.offerList = offerList;
            this.IsOriginalBalanceChanged = IsOriginalBalanceChanged;
            this.IsInsert = IsInsert;
        }
        
        public void execute(QueueableContext context) {
        //Added by Uchit for ND-13
            Batch_Data__c AsyncTradeMethod = Attorney_StaticVariableUtility.getAsyncMethodData('AsynCallToNDSDebt');
            DateTime now = System.now();
            if(AsyncTradeMethod != null &&  ( AsyncTradeMethod.Last_Execution_Time__c == null || AsyncTradeMethod.Last_Execution_Time__c.Day() != now.Day() || AsyncTradeMethod.Number_Of_Callouts__c == null)){
                AsyncTradeMethod.Number_Of_Callouts__c = String.valueOf(0);
                AsyncTradeMethod.Number_of_records_processed__c = 0;
            }
          if(!Test.isRunningTest()){
                AsyncTradeMethod.Number_Of_Callouts__c = String.valueOf(Integer.valueOf(AsyncTradeMethod.Number_Of_Callouts__c) + 1);
                AsyncTradeMethod.Number_of_records_processed__c++;
            AsyncTradeMethod.Last_Execution_Time__c = System.now();
          }
            //Update AsyncTradeMethod;
            
            system.debug('###step5::');
            nu_dse__TradeLine__c ObjTradeLine = [Select import_Id__c,Integration_Status__c,Integration_Reason__c,nu_dse__New_Creditor__c,nds_Debt_Type__c,Negotiation_Status__c,Negotiator__c,
                                                 Account_Status__c,Primary_Applicant__c,Secondary_Applicant__c,Secondary_Name_Relation__c,Additional_Name__c,
                                                 Additional_Relation__c,nu_dse__Minimum_Payment_Amount__c,Negotiation_Note__c, nds_statement_included__c,nu_dse__Verified_Balance__c,
                                                 nds_Last_Statement_Date__c,nu_dse__Percentage__c,is_cash_or_transfer__c,nu_dse__Last_Payment_Date__c,
                                                 Ended_On__c,nu_dse__Program__c,CreatedDate,LastModifiedDate,Applicant_Type__c,FileNumber__c,
                                                 nds_Current_Creditor_Office_Ext__c,nds_Current_Creditor_Fax__c,nds_Current_Creditor_Email__c,
                                                 nds_Current_Creditor_Note__c,nu_dse__Original_Creditor__c,nu_dse__Program__r.Import_ID__c,nu_dse__Original_Debt__c,
                                                 nu_dse__Original_Account_Number__c,SFS_Current_Balance__c,nu_dse__New_Account_Number__c,nu_dse__Sales_Creditor_Name__c 
                                                 from nu_dse__TradeLine__c where id=:ObjTradeLineId];
            
            try
            {
                LeadtracNetDebt.DebtServiceSoap soap = new LeadtracNetDebt.DebtServiceSoap();
                LeadtracNetDebt.ArrayOfDebt arrayOfDebt = doTradeLineMapping(ObjTradeLine,OfferList,IsOriginalBalanceChanged,IsInsert);
                LeadtracNetDebt.GetDebtsResult debtResult = new LeadtracNetDebt.GetDebtsResult();  
                
                System.debug('++++++++++++++++++++++10. arrayOfDebt ' + arrayOfDebt);
                debtResult = soap.CreateOrUpdateDebts(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,
                                                      ObjTradeLine.nu_dse__Program__r.Import_ID__c, arrayOfDebt); 

               
                 System.debug('++++++++++++++++++++++11. debtResult ' + debtResult);
                
                if(debtResult.IsSuccessful == true)
                {
                    leadtracNetDebt.ArrayOfDebt arrayofDebtResult = debtResult.Debts;
                    List<leadtracNetDebt.Debt> d = arrayofDebtResult.Debt;
                    
                     if(ObjTradeLine.Import_Id__c == null)
                     {
                         
                         ObjTradeLine.Import_ID__c = string.valueOf(d[0].DebtId);
                     //    ObjTradeLine.External_Id__c = string.valueOf(d[0].DebtId);
                         System.debug('++++++++++++++++++++++12. DebtId' + string.valueOf(d[0].DebtId));
                     }
                    
                    setIntegrationFields(ObjTradeLine,Attorney_StaticVariableUtility.INTEGRATION_SUCCESS,null);
                    
                    if(d[0].Properties != null && d[0].Properties.DebtProperty != null){
                        for(leadtracNetDebt.DebtProperty property: d[0].Properties.DebtProperty){
                            if(property.Name != null && property.Name.equalsIgnoreCase('Reference.LeadNumber')){
                               ObjTradeLine.Litigation_File_Number__c = property.value; 
                            }
                        }
                    }
                }
                else
                {
                    LeadtracNetDebt.ArrayOfResultMessage arrayResultMessage = debtResult.Messages;
                    List<LeadtracNetDebt.ResultMessage> resultMessage = arrayResultMessage.ResultMessage;
                    setIntegrationFields(ObjTradeLine,Attorney_StaticVariableUtility.INTEGRATION_FAILED,resultMessage[0].Message);
                }
            }
            catch(Exception e)
            {
                 setIntegrationFields(ObjTradeLine,Attorney_StaticVariableUtility.INTEGRATION_FAILED,
                                     Attorney_StaticVariableUtility.INTERNAL_ERROR_PREFIX + e.getMessage() + '\n' + 
                                     Attorney_StaticVariableUtility.INTERNAL_STACK_TRACE + e.getStackTraceString());
                System.debug('****exception'+e.getStackTraceString());
                System.debug('****exception'+e.getMessage());
            }

         Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
            
            update ObjTradeLine;
           
             if(!Test.isRunningTest()){
                 Update AsyncTradeMethod; } 
             
        }
    } 
    
    //PDI-731
    
    /*Commented for deployment
    public static void UpdateOriginalCreditor(list<nu_dse__TradeLine__c> lstTrade){
       set<string> NormOrgCred=new set<String>();
       set<String> SalesCredName=new set<String>();
        for(nu_dse__TradeLine__c trade:lstTrade){
            NormOrgCred.add(trade.Normalized_Original_Creditor__c);
            SalesCredName.add(trade.nu_dse__Sales_Creditor_Name__c);
        }
       
        map<String,Account> mapNormOrgCred=new map<String,Account>();
        map<String,Account> mapSalesCred=new map<String,Account>();
        
        /*for(Account ac:[Select name from Account where name in:NormOrgCred]){
            mapNormOrgCred.put(ac.name,ac);
           // mapSalesCred.put(trade.nu_dse__Sales_Creditor_Name__c,trade.nu_dse__Original_Creditor__c);
        }
        for(Account ac:[Select name from Account where name in:SalesCredName]){
            mapSalesCred.put(ac.name,ac);
        }*

        //changes for soql query exception ~ Starts
        if (NormOrgCred.isEmpty() == False || SalesCredName.isEmpty() == False) {
            
            for(Account ac:[Select name from Account where name in:NormOrgCred OR name in:SalesCredName]){
            
                if (NormOrgCred.contains(ac.name)) {
                    
                    mapNormOrgCred.put(ac.name,ac);
                   // mapSalesCred.put(trade.nu_dse__Sales_Creditor_Name__c,trade.nu_dse__Original_Creditor__c);
                }
                
                if (SalesCredName.contains(ac.name)) {
                    mapSalesCred.put(ac.name,ac);
                }                
            }
        }
        //changes for soql query exception ~ Ends
        system.debug('mapNormOrgCred'+mapNormOrgCred);
        System.debug('mapSalesCred'+mapSalesCred);
        
        for(nu_dse__TradeLine__c trade1:lstTrade){
        
            if(mapNormOrgCred.containsKey(trade1.Normalized_Original_Creditor__c) 
            && (trade1.Normalized_Original_Creditor__c!=null || trade1.Normalized_Original_Creditor__c!='')){
            
               trade1.nu_dse__Original_Creditor__c= mapNormOrgCred.get(trade1.Normalized_Original_Creditor__c).id;
               system.debug('trade1.nu_dse__Original_Creditor__c'+trade1.nu_dse__Original_Creditor__c);
            }
            else if(mapSalesCred.containsKey(trade1.nu_dse__Sales_Creditor_Name__c))
            {
              trade1.nu_dse__Original_Creditor__c= mapSalesCred.get(trade1.nu_dse__Sales_Creditor_Name__c).id; 
              system.debug('trade1.nu_dse__Original_Creditor__c'+trade1.nu_dse__Original_Creditor__c);
            }
        }                   
    }*/
}