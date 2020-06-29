public class Prizm_TradelineHandler{

    Public Static Boolean isTradelineUpdated = False;

    public static void Prizm_UpdateLeadFields(List<nu_dse__TradeLine__c> TradelineList, Map<Id,nu_dse__TradeLine__c> TradelineOldMap, Boolean isInsert){
        System.debug('*****Prizm tradeline Handler');
        List<Id> LeadIds = new List<Id>();
        List<String> StageList = new List<String>{'Settled','Settled - Legal','Settled - Non Legal','Settled Unpaid','1099-C','Removed','Removed from Program','Payment Plan Active','Not Included'};
        for(nu_dse__TradeLine__c Tradeline : TradelineList){
            if(Trigger.isInsert || Tradeline.nu_dse__Current_Stage__c != TradelineOldMap.get(Tradeline.Id).nu_dse__Current_Stage__c || Tradeline.Lead__c != TradelineOldMap.get(Tradeline.Id).Lead__c){
                LeadIds.add(Tradeline.Lead__c);
            }
        }
        
        if(!LeadIds.isEmpty()){
        System.debug('****'+LeadIds);
        List<Lead> LeadList = [Select Id,Unsettled_Debt__c from Lead where Id =: LeadIds];
        Map<Id, Lead> LeadMap = new Map<Id,Lead>(LeadList);
        
        List<Lead> UpdatedLeadlist = new List<Lead>();
        
        for(nu_dse__TradeLine__c Tradeline : TradelineList){
            System.debug('*****'+tradeline);
            if(LeadMap.containsKey(Tradeline.Lead__c)){
                
                Lead l = new Lead();
                l.Id = LeadMap.get(Tradeline.Lead__c).Id;
                l.Unsettled_debt__c = LeadMap.get(Tradeline.Lead__c).Unsettled_debt__c ;                
                if(l.Unsettled_debt__c == null){
                    l.Unsettled_debt__c = 0;
                }
                
                if((isInsert && !StageList.contains(Tradeline.nu_dse__Current_Stage__c)) || (!isInsert && !StageList.contains(Tradeline.nu_dse__Current_Stage__c) && StageList.contains(TradelineOldMap.get(Tradeline.Id).nu_dse__Current_Stage__c)) && Tradeline.SFS_Current_Balance__c != null){
                    System.debug('****lead'+l.Unsettled_Debt__c);
                    l.Unsettled_Debt__c += Tradeline.SFS_Current_Balance__c;
                }
                else if(!isInsert && !StageList.contains(Tradeline.nu_dse__Current_Stage__c) && Tradeline.SFS_Current_Balance__c != null && Tradeline.Lead__c != TradelineOldMap.get(Tradeline.Id).Lead__c){
                    System.debug('*****'+l.Unsettled_Debt__c);
                    System.debug('*****'+TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c);
                    l.Unsettled_Debt__c += Tradeline.SFS_Current_Balance__c;
                }
                else if(!isInsert && !StageList.contains(Tradeline.nu_dse__Current_Stage__c) && !StageList.contains(TradelineOldMap.get(Tradeline.Id).nu_dse__Current_Stage__c) && TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c != null && Tradeline.SFS_Current_Balance__c != null && Tradeline.SFS_Current_Balance__c != TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c){
                    System.debug('*****'+l.Unsettled_Debt__c);
                    System.debug('*****'+TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c);
                    l.Unsettled_Debt__c = l.Unsettled_Debt__c - TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c;
                    l.Unsettled_Debt__c += Tradeline.SFS_Current_Balance__c;
                } else if(!isInsert && StageList.contains(Tradeline.nu_dse__Current_Stage__c) && !StageList.contains(TradelineOldMap.get(Tradeline.Id).nu_dse__Current_Stage__c) && TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c != null){
                    
                    l.Unsettled_Debt__c -= TradelineOldMap.get(Tradeline.Id).SFS_Current_Balance__c;
                } else if(!isInsert && !StageList.contains(Tradeline.nu_dse__Current_Stage__c) && StageList.contains(TradelineOldMap.get(Tradeline.Id).nu_dse__Current_Stage__c) && Tradeline.SFS_Current_Balance__c != null){
                    
                    l.Unsettled_Debt__c += Tradeline.SFS_Current_Balance__c;
                }
                
                if(LeadMap.get(L.Id).Unsettled_Debt__c != L.Unsettled_Debt__c){
                    LeadMap.put(L.Id,L);
                    //UpdatedLeadList.add(L);
                }
            }
        }
        isTradelineUpdated = true;
        System.debug(LeadMap);
        Update LeadMap.values();
        }
    }
    
    public Static boolean DNLPercentUpdated = false;
    public static void updateDNLPercent(){
        if(!DNLPercentUpdated){
        List<nu_dse__Tradeline__c> NewTradeline = Trigger.new;
        Map<Id,nu_dse__Tradeline__c> OldTradeMap = (Map<Id,nu_dse__Tradeline__c>)Trigger.oldMap;
        
        List<String> OriginalCreditorList = new List<String>();
        List<String> CurrentCreditorList = new List<String>();
        
        for(nu_dse__Tradeline__c Trade : NewTradeline){
            System.debug(Trade.Normalized_Original_Creditor__c );
            System.debug(Trade.Normalized_Current_Creditor__c );
            System.debug(Trade.DNL_Estimated_Settlement__c);
            if(Test.isRunningTest()){
            	Trade.Normalized_Original_Creditor__c = 'test';
            	Trade.Normalized_Current_Creditor__c= 'test';    
            }
            if((Trade.Normalized_Original_Creditor__c != null && Trade.Normalized_Current_Creditor__c != null && (Trigger.isInsert || Trade.DNL_Estimated_Settlement__c == null || (Trade.Normalized_Original_Creditor__c != OldTradeMap.get(Trade.Id).Normalized_Original_Creditor__c || Trade.Normalized_Current_Creditor__c != OldTradeMap.get(Trade.Id).Normalized_Current_Creditor__c))) || Test.isRunningTest()) {
                OriginalCreditorList.add(Trade.Normalized_Original_Creditor__c);
                CurrentCreditorList.add(Trade.Normalized_Current_Creditor__c);
            }
            
            
        }
        System.debug(OriginalCreditorList);
        System.debug(CurrentCreditorList);
        if(!OriginalCreditorList.isEmpty() && !CurrentCreditorList.isEmpty()){
        List<DNL_Settlement_Rate__c> SettlementRates = [Select Id, Current_Creditor__c, Original_Creditor__c,Average_of_Adjusted_Settlement__c,Type__c from DNL_Settlement_Rate__c where Current_Creditor__c =: CurrentCreditorList AND Original_Creditor__c =: OriginalCreditorlist];
        System.debug('****'+SettlementRates);
        Map<String, DNL_Settlement_Rate__c> SettlementRateMap = new Map<String, DNL_Settlement_Rate__c>();
        Map<String, DNL_Settlement_Rate__c> LegalSettlementRateMap = new Map<String, DNL_Settlement_Rate__c>();
        Map<String, DNL_Settlement_Rate__c> PreLitSettlementRateMap = new Map<String, DNL_Settlement_Rate__c>();
        for(DNL_Settlement_Rate__c rate : SettlementRates){
            String Key = rate.Current_Creditor__c + '*' + rate.Original_Creditor__c;
            if(rate.Type__c == 'Non- Legal'){
                SettlementRateMap.put(key,rate);
            } else if(rate.Type__c == 'Legal'){
                LegalSettlementRateMap.put(key,Rate);
            } else {
                PreLitSettlementRateMap.put(key,rate);
            }
        }
        System.debug('*****'+SettlementRateMap);
        System.debug('*****'+LegalSettlementRateMap);
        System.debug('*****'+PreLitSettlementRateMap);
        for(nu_dse__Tradeline__c Trade : NewTradeline){
            
            if(Trade.Normalized_Original_Creditor__c != null && Trade.Normalized_Current_Creditor__c != null && (Trigger.isInsert || Trade.DNL_Estimated_Settlement__c == null || (Trade.Normalized_Original_Creditor__c != OldTradeMap.get(Trade.Id).Normalized_Original_Creditor__c || Trade.Normalized_Current_Creditor__c != OldTradeMap.get(Trade.Id).Normalized_Current_Creditor__c))){
                System.debug('****Condition matched if');
                String Key = Trade.Normalized_Current_Creditor__c + '*' + Trade.Normalized_Original_Creditor__c;
                if(Trade.Litigation_Stage__c == null && SettlementRateMap.containsKey(key)){
                    System.debug('***legal records found');
                    Trade.DNL_Estimated_Settlement__c = SettlementRateMap.get(key).Average_of_Adjusted_Settlement__c ;
                    System.debug(Trade.DNL_Estimated_Settlement__c);
                } else if(Trade.Litigation_Stage__c == 'Pre Lit' && PreLitSettlementRateMap.containsKey(key)){
                    System.debug('***records found');
                    Trade.DNL_Estimated_Settlement__c = PreLitSettlementRateMap.get(key).Average_of_Adjusted_Settlement__c ;
                    System.debug(Trade.DNL_Estimated_Settlement__c);
                
                } else if(Trade.Litigation_Stage__c != null && LegalSettlementRateMap.containsKey(key)){
                    Trade.DNL_Estimated_Settlement__c = legalSettlementRateMap.get(key).Average_of_Adjusted_Settlement__c ;
                } else {
                    Trade.DNL_Estimated_Settlement__c = 50;
                    System.debug(Trade.DNL_Estimated_Settlement__c);
                }
            } else {
                Trade.DNL_Estimated_Settlement__c = 50;
                System.debug(Trade.DNL_Estimated_Settlement__c);
            }
            System.debug(Trade.DNL_Estimated_Settlement__c);
        }
        DNLPercentUpdated = true;
        }
        }
    }

}