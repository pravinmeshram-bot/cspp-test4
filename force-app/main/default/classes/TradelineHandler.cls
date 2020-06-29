public class TradelineHandler { 
    // For S20-136 - Amit Goyal - Starts here
    public static void updateIncludedintheProgram(List<nu_dse__TradeLine__c> newList, Map<Id, nu_dse__TradeLine__c> oldMap) {
        if(newList != null && newList.size()>0){
            for(nu_dse__TradeLine__c tl: newList){
                if(tl.nu_dse__Current_Stage__c=='Removed from Program' || tl.nu_dse__Current_Stage__c=='Add Debt Incomplete-ATD/ACH Not Returned'){
                    tl.nu_dse__Include_In_The_Program__c=false;
                }else{
                    tl.nu_dse__Include_In_The_Program__c=true;
                }
            }
        }
    }
    // For S20-136 - Amit Goyal - Ends here
    
    // If the Litigation Stage field has any non-null values, then Lit Def Stage is updated as Referred to Pre-Lit
    public static void updateLitDefStage(Map<Id, nu_dse__TradeLine__c> oldMap, List<nu_dse__TradeLine__c> newList, Boolean isInsert, Boolean isUpdate) {
        
        for (nu_dse__TradeLine__c tradelineTobeUpdated: newList) {
            
            if (((isUpdate && (tradelineTobeUpdated.Litigation_Stage__c != oldMap.get(tradelineTobeUpdated.Id).Litigation_Stage__c)) ||
                 isInsert) && String.isNotBlank(tradelineTobeUpdated.Litigation_Stage__c)) {
                     
                     tradelineTobeUpdated.Lit_Def_Stage__c = 'Referred_To_Pre_Lit';
                 }
        }
    }
    
    public static void updateResponseDate(Map<Id, nu_dse__TradeLine__c> oldTradelinesMap, List<nu_dse__TradeLine__c> newTradelineList) {
        //As per ticket S20-90, changing normalized creditor
        //@Author: MindzCloud Developer 
        set<Id> setAccountId = new set<Id>();
        set<String> setNewCreditor = new set<String>();
        map<String, String> mapNormalizedCreditor = new map<String, String>();
        
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) {           
            if (oldTradelinesMap !=NULL && tradelineInstance.Response_Date__c != NULL && (tradelineInstance.Response_Date__c != oldTradelinesMap.get(tradelineInstance.Id).Response_Date__c) 
                && (tradelineInstance.Excela_Response_Date__c == oldTradelinesMap.get(tradelineInstance.Id).Excela_Response_Date__c)) {
                    
                    tradelineInstance.Excela_Response_Date__c = tradelineInstance.Response_Date__c;
                }
            
            //As per ticket S20-90, changing normalized creditor
            //@Author: MindzCloud Developer            
            if(String.isNotBlank(tradelineInstance.nu_dse__New_Creditor__c)){                
                setAccountId.add(tradelineInstance.nu_dse__New_Creditor__c);
            }            
            
        }
        //As per ticket S20-90, changing normalized creditor
        //@Author: MindzCloud Developer
        //Get Normalized creditor from Creditor_Standardization__c and generate mapNormalizedCreditor 
        //Changes made for S20-503 by uchit
        if(setAccountId.isEmpty()){
            return;
        }
        
        map<Id, Account> mapAccount = new map<Id, Account>([Select Id, Name from Account where Id IN :setAccountId]);
        for(Id accId: mapAccount.keySet()){
            setNewCreditor.add(mapAccount.get(accId).Name);
        }
        
        List<Creditor_Standardization__c> lstCreditorStandardization = [Select Id, Name, Creditor_Name__c from Creditor_Standardization__c
                                                                        where Creditor_Name__c In :setNewCreditor];

        If(lstCreditorStandardization != null && lstCreditorStandardization.size() > 0){
            for(Creditor_Standardization__c credStand :  lstCreditorStandardization){
                if(credStand.Creditor_Name__c != null){
                    mapNormalizedCreditor.put(credStand.Creditor_Name__c.toUpperCase(), credStand.Name);
                }
            }
        }
       
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) {
            if(tradelineInstance.nu_dse__New_Creditor__c != null){
                Account acc = mapAccount.get(tradelineInstance.nu_dse__New_Creditor__c);
                if(acc != null ){
                    String normCredName = acc.Name;
                    String normalizedCurrentCreditor = mapNormalizedCreditor.get(normCredName.toUpperCase());
                    if(normalizedCurrentCreditor != null && normalizedCurrentCreditor != ''){                        
                        tradelineInstance.Normalized_Current_Creditor__c = normalizedCurrentCreditor;                        
                    }else{                        
                        tradelineInstance.Normalized_Current_Creditor__c = tradelineInstance.nds_Current_Creditor_Name__c;
                    }
                }
            }else{                                       
                tradelineInstance.Normalized_Current_Creditor__c = tradelineInstance.nds_Current_Creditor_Name__c;
            }
        }        
    }  
    //As per ticket S20-340
    //@Author: Tiago Barbosa dos Santos entire method updateCreditorStandardization
    public static void updateCreditorStandardization(Map<Id, nu_dse__TradeLine__c> oldTradelinesMap, List<nu_dse__TradeLine__c> newTradelineList) {
        set<String> setCurrentCreditor = new set<String>();
        map<String, String> mapNormalizedCreditor = new map<String, String>();
        
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) {            
            if(String.isNotBlank(tradelineInstance.nu_dse__New_Creditor__c)){                
                continue;                
            }
            
            if(String.isNotBlank(tradelineInstance.nds_Current_Creditor_Name__c))
            {
                setCurrentCreditor.add(tradelineInstance.nds_Current_Creditor_Name__c);
            }   
            
            if(String.isBlank(tradelineInstance.nds_Current_Creditor_Name__c) && tradelineInstance.nu_dse__New_Creditor__c == null){
                tradelineInstance.Normalized_Current_Creditor__c = '';
            }
        }       
        
        if(setCurrentCreditor.isEmpty()){            
            return;
        }
        
        List<Creditor_Standardization__c> lstCreditorStandardization = [Select Id, Name, Creditor_Name__c from Creditor_Standardization__c
                                                                       where Creditor_Name__c In :setCurrentCreditor];
                
        for(Creditor_Standardization__c creditorStandard : lstCreditorStandardization){            
            if(String.isNotBlank(creditorStandard.Creditor_Name__c)){
                mapNormalizedCreditor.put(creditorStandard.Creditor_Name__c.toUpperCase(), creditorStandard.Name);
            }            
        }
        
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) {            
            if(String.isNotBlank(tradelineInstance.nu_dse__New_Creditor__c)){
                continue;
            }
            if(String.isNotBlank(tradelineInstance.nds_Current_Creditor_Name__c))
            {                  
                tradelineInstance.Normalized_Current_Creditor__c = mapNormalizedCreditor.get(tradelineInstance.nds_Current_Creditor_Name__c.toUpperCase());
            }                                 
        }            
    }
    
    //S20-25
    //Private function to process all tradeline whose stage is payment plan active. 
    //Find all related cases to mark completed
    @TestVisible 
    private static void processCasesToComplete(List<nu_dse__TradeLine__c> newTradelineList, set<Id> setTradelineToProcessForCase){
        map<Id, nu_dse__TradeLine__c> mapTradelineWithOffer;
        map<Id, List<Summon__c>> mapTradelineCases = new map<Id, List<Summon__c>>();
        
        mapTradelineWithOffer = new map<Id, nu_dse__TradeLine__c>([Select Id, (Select Renegotiable__c, Type_of_Settlement__c 
                                                                               From nu_dse__Offers__r where Latest_Offer__c = true) 
                                                                   From nu_dse__TradeLine__c n where Id IN :setTradelineToProcessForCase]);
        
        //Get list of cases (summon ) for the selected tradelines      
        List<Summon__c> lstCases = [Select Id, Case_Status__c, Tradeline__c from Summon__c 
                                    where Tradeline__c In :setTradelineToProcessForCase];
        
        //Generate map of tradeline and its associated cases
        if(lstCases != null && lstCases.size() > 0){
            for(Summon__c summon: lstCases){
                List<Summon__c> lstSummon = mapTradelineCases.get(summon.Tradeline__c);
                if(lstSummon == null){
                    lstSummon = new List<Summon__c>();
                    mapTradelineCases.put(summon.Tradeline__c, lstSummon);
                }
                lstSummon.add(summon);
            }
        }
        
        List<Summon__c> lstCasesToUpdate = new List<Summon__c>();
        
        for(Id tradelineId : mapTradelineWithOffer.keySet()){
            nu_dse__TradeLine__c trad = mapTradelineWithOffer.get(tradelineId);
            if(trad.nu_dse__Offers__r != null && trad.nu_dse__Offers__r.size() > 0){
                Boolean isValid = true;
                //Iterate on all offers to check for validity
                for(nu_dse__Offer__c offer: trad.nu_dse__Offers__r){
                    //Check for offer validity
                    if(offer.Type_of_Settlement__c == 'Temp PPA' || offer.Renegotiable__c == true){
                        isValid = false;
                    }
                }
                if(isValid){
                    list<Summon__c> lstSummonToProcess = mapTradelineCases.get(trad.Id);
                    if(lstSummonToProcess != null && lstSummonToProcess.size() > 0){
                        for(Summon__c sum: lstSummonToProcess){
                            sum.Case_Status__c = 'Completed';
                            lstCasesToUpdate.add(sum);
                        }
                    }
                }
            }//End of If
        }//End of for loop
        
        if(lstCasesToUpdate != null && lstCasesToUpdate.size() > 0){
            system.debug('--lstCasesToUpdate : ' + lstCasesToUpdate);
            update lstCasesToUpdate;
        }
    }
    @TestVisible 
    public static void changesRelatedToCases(List<nu_dse__TradeLine__c> newTradelineList){
        set<Id> setTradelineToProcessForCase = new set<Id>();
        
        //As per ticket to mark cases as complete for all payment plac active traeline
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) {
            if(tradelineInstance.nu_dse__Current_Stage__c == 'Payment Plan Active'){
                setTradelineToProcessForCase.add(tradelineInstance.Id);
            }
            
        }
        if(setTradelineToProcessForCase.size() > 0){
            processCasesToComplete(newTradelineList, setTradelineToProcessForCase);
        }
    }
    
    
    
    //S20-373 ****Starts****
   public static void changesRelatedToSummonsGroupTask(Map<Id, nu_dse__TradeLine__c> oldTradelinesMap, List<nu_dse__TradeLine__c> newTradelineList) 
    {
        System.debug('Started summons group task');
             
        Set<Id> tradelineForSummonsGroupUpdate = new Set<Id>();
        Set<Id> tradelineForSummonsGroupCreate = new Set<Id>();
        Set<Id> tradelineForSummonsGroupDelete = new Set<Id>();
        Set<Id> ProgramIDs = new Set<Id>();
        Map<Id, nu_dse__TradeLine__c> filteredTradelineMap = new Map<Id, nu_dse__TradeLine__c>();
        String P_name;
         for (nu_dse__TradeLine__c tradelineInstance : newTradelineList)
         {
             if(tradelineInstance.nu_dse__Program__c != null)
             {
               ProgramIDs.add(tradelineInstance.nu_dse__Program__c);
                }
         }
        Map<Id,nu_dse__Program__c> programmap = new Map<Id,nu_dse__Program__c>([Select id,Portfolio__c,Portfolio__r.Name from nu_dse__Program__c where Id in:ProgramIDs ]);
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) 
        {
             System.debug('Calling current tradeline');
            //  System.debug('tradelineInstance.Excela_Response_Date__c--->'+tradelineInstance.Excela_Response_Date__c);
            // System.debug('tradelineInstance.Litigation_Stage__c--->'+tradelineInstance.Litigation_Stage__c);
            // System.debug('tradelineInstance.IsSummonCreated__c--->'+tradelineInstance.IsSummonCreated__c);
            
            /*    if (tradelineInstance.Excela_Response_Date__c != NULL
&& (tradelineInstance.Excela_Response_Date__c != oldTradelinesMap.get(tradelineInstance.Id).Excela_Response_Date__c)) {

tradelineForSummonsGroupUpdate.add(tradelineInstance.Id);  
filteredTradelineMap.put(tradelineInstance.Id, tradelineInstance);  
}*/
            
            if (tradelineInstance.nu_dse__Program__c != NULL
                && (tradelineInstance.Litigation_Stage__c != oldTradelinesMap.get(tradelineInstance.Id).Litigation_Stage__c)){ 
                    
                    if (oldTradelinesMap.get(tradelineInstance.Id).Litigation_Stage__c == 'Summons' 
                        && tradelineInstance.Litigation_Stage__c == NULL && tradelineInstance.IsSummonCreated__c == TRUE) {
                            
                            tradelineForSummonsGroupDelete.add(tradelineInstance.Id);
                            filteredTradelineMap.put(tradelineInstance.Id, tradelineInstance); 
                            
                        } else if (String.isNotBlank(tradelineInstance.Litigation_Stage__c) && tradelineInstance.Litigation_Stage__c == 'Summons'
                                 && tradelineInstance.IsSummonCreated__c == FALSE  ) {
                                      
                                      tradelineForSummonsGroupCreate.add(tradelineInstance.Id);  
                                      filteredTradelineMap.put(tradelineInstance.Id, tradelineInstance);
                                      System.debug('enter filteredTradelineMap' +filteredTradelineMap);
                                     
                                      P_name = programmap.get(tradelineInstance.nu_dse__Program__c).Portfolio__r.Name;
                                                         System.debug('cheking Portfolio name'+P_name);
                                  }                
                }
        }
       // System.debug('filteredTradelineMap--->'+filteredTradelineMap);
       // System.debug('tradelineForSummonsGroupCreate--->'+tradelineForSummonsGroupCreate);
       // System.debug('tradelineForSummonsGroupUpdate--->'+tradelineForSummonsGroupUpdate);
       // System.debug('tradelineForSummonsGroupDelete--->'+tradelineForSummonsGroupDelete);
        
        if (filteredTradelineMap.isEmpty() == False) 
        {
         System.debug('Starting group task creation on current tradeline');   
            List<nu_dse__Group_Task__c> summonsToCreate = new List<nu_dse__Group_Task__c>();
            List<nu_dse__Group_Task__c> summonsToDelete = new List<nu_dse__Group_Task__c>();
           // List<nu_dse__Group_Task__c> summonsToUpdate = new List<nu_dse__Group_Task__c>();
          //  List<nu_dse__TradeLine__c> tradelinesToUpdate = new List<nu_dse__TradeLine__c>();
            group queueObj=[select id,name from Group  where name='Lit Support Operations' and Type = 'Queue'];
            
            
            if (tradelineForSummonsGroupCreate.isEmpty() == False) 
            {
              // Portfolio_Name__c pname = Portfolio_Name__c.getValues(P_name);
              //  System.debug('cheking custom setting '+pname);
                for(Portfolio_Name__c pname : Portfolio_Name__c.getAll().values())
                {
                    System.debug('cheking custom setting '+pname.Name);
                    if(pname.Name == P_name)
                    {
                        for (Id tradelineId : tradelineForSummonsGroupCreate) 
                        {
                            
                            System.debug('cheking no. of tradelines'+tradelineId);
                            
                            nu_dse__Group_Task__c GtInstance = new nu_dse__Group_Task__c();
                            
                            GtInstance.nu_dse__Subject__c= 'Summons Strategy Outbound Call';
                            GtInstance.Subject_Picklist__c= 'Summons Consultation Call';
                            GtInstance.nu_dse__Description__c= 'Summons Consultation Call';
                            GtInstance.Program__c = filteredTradelineMap.get(tradelineId).nu_dse__Program__c;
                            GtInstance.OwnerId = queueObj.id;
                            GtInstance.nu_dse__Status__c = 'Not Started';
                            GtInstance.nu_dse__ActivityDate__c = Date.Today() +1;
                            // GtInstance.nu_dse__Related_To__c = tradelineId;
                            GtInstance.Excela_Tradeline__c = tradelineId;
                            // GtInstance.nu_dse__Related_To__c = tradelineId;
                            summonsToCreate.add(GtInstance);
                            System.debug('Group task successfully created');
                           // filteredTradelineMap.get(tradelineId).IsSummonCreated__c = TRUE;
                            // tradelinesToUpdate.add(new nu_dse__TradeLine__c(Id = tradelineId, IsSummonCreated__c = TRUE));
                        }
                    }else{
                        System.debug('Custom setting value not available'+P_name);
                    }
        }
                
                
                //if(Portfolio_Name__c.getValues(P_name).Name != null)
               // {
                  //  String statusCode = Portfolio_Name__c.getValues(P_name).Name;
                  //  System.debug('cheking custom setting '+statusCode);
                
                
            }
           
            
            
            if (tradelineForSummonsGroupDelete.isEmpty() == False )
            {
                
                for(nu_dse__Group_Task__c GT : [SELECT Id,nu_dse__Subject__c ,nu_dse__Status__c, Excela_Tradeline__c, Subject_Picklist__c FROM nu_dse__Group_Task__c 
                                                WHERE Excela_Tradeline__c IN :tradelineForSummonsGroupDelete  ]) 
                {
                    
                    
                    if (tradelineForSummonsGroupDelete.contains(GT.Excela_Tradeline__c)) 
                    {
                        
                        if (GT.nu_dse__Status__c != 'Completed') 
                        {
                            
                            summonsToDelete.add(GT);
                            system.debug('Deleted grp task'+summonsToDelete );
                          /*  nu_dse__TradeLine__c tradeline = new nu_dse__TradeLine__c(Id = GT.Excela_Tradeline__c, IsSummonCreated__c = False);
                            
                            filteredTradelineMap.get(GT.Excela_Tradeline__c).IsSummonCreated__c = False;
                            
                             if (filteredTradelineMap.get(GT.Excela_Tradeline__c).Account_Status__c == 'Summons') 
{

filteredTradelineMap.get(GT.Excela_Tradeline__c).Account_Status__c = '';

tradeline.Account_Status__c = '';
}*/
                            
                            //  tradelinesToUpdate.add(tradeline);
                            
                        } else 
                        {
                            
                            //Related SFS Case is completed
                            // filteredTradelineMap.get(GT.Excela_Tradeline__c).addError('Litigation Stage cannot be changed to \'--None--\'');
                        }                                               
                    }                    
                }
            }
            System.debug('summonsToCreate--->'+summonsToCreate);
            //System.debug('summonsToUpdate--->'+summonsToUpdate);
            System.debug('summonsToDelete--->'+summonsToDelete);
            //System.debug('tradelinesToUpdate--->'+tradelinesToUpdate);
            
            //  if (tradelinesToUpdate.isEmpty() == False) {
            
            //   update tradelinesToUpdate;
            // }
            
            if (summonsToCreate.isEmpty() == False ) {
                
                insert summonsToCreate;
                System.debug('inserted Group task '+summonsToCreate);
            }
            
            //   if (summonsToUpdate.isEmpty() == False) {
            
            //      update summonsToUpdate;
            //  }
            
            if (summonsToDelete.isEmpty() == False) {
                
                delete summonsToDelete;
            }
            System.debug('Closing for grptask creation on tradelines');
            
        }
        
    }
    //S20-373 ****Ends****
    //S20-37 ****Starts****
    public static void changesRelatedToSummons(Map<Id, nu_dse__TradeLine__c> oldTradelinesMap, List<nu_dse__TradeLine__c> newTradelineList) {
        
        Set<Id> tradelineForSummonsUpdate = new Set<Id>();
        Set<Id> tradelineForSummonsCreate = new Set<Id>();
        Set<Id> tradelineForSummonsDelete = new Set<Id>();
        Map<Id, nu_dse__TradeLine__c> filteredTradelineMap = new Map<Id, nu_dse__TradeLine__c>();
        
        for (nu_dse__TradeLine__c tradelineInstance : newTradelineList) {
            
            System.debug('tradelineInstance.Excela_Response_Date__c--->'+tradelineInstance.Excela_Response_Date__c);
            System.debug('tradelineInstance.Litigation_Stage__c--->'+tradelineInstance.Litigation_Stage__c);
            System.debug('tradelineInstance.IsSummonCreated__c--->'+tradelineInstance.IsSummonCreated__c);
            
            if (tradelineInstance.Excela_Response_Date__c != NULL
                && (tradelineInstance.Excela_Response_Date__c != oldTradelinesMap.get(tradelineInstance.Id).Excela_Response_Date__c)) {
                    
                tradelineForSummonsUpdate.add(tradelineInstance.Id);  
                filteredTradelineMap.put(tradelineInstance.Id, tradelineInstance);  
            }
            
            if (tradelineInstance.nu_dse__Program__c != NULL
                && (tradelineInstance.Litigation_Stage__c != oldTradelinesMap.get(tradelineInstance.Id).Litigation_Stage__c)){ 
                    
                if (oldTradelinesMap.get(tradelineInstance.Id).Litigation_Stage__c == 'Summons' 
                    && tradelineInstance.Litigation_Stage__c == NULL && tradelineInstance.IsSummonCreated__c == TRUE) {
                        
                    tradelineForSummonsDelete.add(tradelineInstance.Id);
                    filteredTradelineMap.put(tradelineInstance.Id, tradelineInstance);
                    
                } else if (String.isNotBlank(tradelineInstance.Litigation_Stage__c) && tradelineInstance.Litigation_Stage__c == 'Summons'
                   && tradelineInstance.IsSummonCreated__c == FALSE) {
                       
                   tradelineForSummonsCreate.add(tradelineInstance.Id);  
                   filteredTradelineMap.put(tradelineInstance.Id, tradelineInstance);                   
               }             
            }
        }
        System.debug('filteredTradelineMap--->'+filteredTradelineMap);
        System.debug('tradelineForSummonsCreate--->'+tradelineForSummonsCreate);
        System.debug('tradelineForSummonsUpdate--->'+tradelineForSummonsUpdate);
        System.debug('tradelineForSummonsDelete--->'+tradelineForSummonsDelete);
        
        if (filteredTradelineMap.isEmpty() == False) {
            
            List<Summon__c> summonsToCreate = new List<Summon__c>();
            List<Summon__c> summonsToDelete = new List<Summon__c>();
            List<Summon__c> summonsToUpdate = new List<Summon__c>();
            List<nu_dse__TradeLine__c> tradelinesToUpdate = new List<nu_dse__TradeLine__c>();
            
            if (tradelineForSummonsCreate.isEmpty() == False) {
                
                for (Id tradelineId : tradelineForSummonsCreate) {
                    
                    Summon__c summonInstance = new Summon__c();
                    summonInstance.Client_Email__c = filteredTradelineMap.get(tradelineId).Client_Email__c;
                    summonInstance.Program__c = filteredTradelineMap.get(tradelineId).nu_dse__Program__c;
                    summonInstance.Response_Date__c = filteredTradelineMap.get(tradelineId).Excela_Response_Date__c;
                    summonInstance.Subject__c = 'New Legal File';
                    summonInstance.Tradeline__c = tradelineId;
                    summonsToCreate.add(summonInstance);
                    //filteredTradelineMap.get(tradelineId).IsSummonCreated__c = TRUE;
                    tradelinesToUpdate.add(new nu_dse__TradeLine__c(Id = tradelineId, IsSummonCreated__c = TRUE));
                }
            }
            
            if (tradelineForSummonsDelete.isEmpty() == False || tradelineForSummonsUpdate.isEmpty() == False) {
                
                for (Summon__c summon : [SELECT Id, Response_Date__c, Tradeline__c, Case_Status__c FROM Summon__c 
                                        WHERE Tradeline__c IN :tradelineForSummonsDelete OR Tradeline__c IN :tradelineForSummonsUpdate]) {
                                            
                    if (tradelineForSummonsUpdate.contains(summon.Tradeline__c) && summon.Response_Date__c == NULL
                        && tradelineForSummonsDelete.contains(summon.Tradeline__c) == FALSE) {
                            
                        summon.Response_Date__c = filteredTradelineMap.get(summon.Tradeline__c).Excela_Response_Date__c;
                        summonsToUpdate.add(summon);                        
                    } 
                    
                    if (tradelineForSummonsDelete.contains(summon.Tradeline__c)) {
                        
                        if (summon.Case_Status__c != 'Completed') {
                            
                            summonsToDelete.add(summon);
                            
                            nu_dse__TradeLine__c tradeline = new nu_dse__TradeLine__c(Id = summon.Tradeline__c, IsSummonCreated__c = False);
                            
                            //filteredTradelineMap.get(summon.Tradeline__c).IsSummonCreated__c = False;
                            
                            if (filteredTradelineMap.get(summon.Tradeline__c).Account_Status__c == 'Summons') {
                                
                                //filteredTradelineMap.get(summon.Tradeline__c).Account_Status__c = '';
                                
                                tradeline.Account_Status__c = '';
                            }
                            
                            //S20-458 ****Starts****  Uncheck the check box If Summon is going to be deleted.
                            if (filteredTradelineMap.get(summon.Tradeline__c).Assign_Litigation_Support_Management__c == True) {
                                
                                tradeline.Assign_Litigation_Support_Management__c = False;
                            }
                            //S20-458 ****Ends**** 
                            
                            tradelinesToUpdate.add(tradeline);
                            
                        } else {
                            
                            //Related SFS Case is completed
                            filteredTradelineMap.get(summon.Tradeline__c).addError('Litigation Stage cannot be changed to \'--None--\'');
                        }                                               
                    }                    
                }
            }
            System.debug('summonsToCreate--->'+summonsToCreate);
            System.debug('summonsToUpdate--->'+summonsToUpdate);
            System.debug('summonsToDelete--->'+summonsToDelete);
            System.debug('tradelinesToUpdate--->'+tradelinesToUpdate);
            
            if (tradelinesToUpdate.isEmpty() == False) {
                
                update tradelinesToUpdate;
            }
            
            if (summonsToCreate.isEmpty() == False) {
                
                insert summonsToCreate;
            }
            
            if (summonsToUpdate.isEmpty() == False) {
                
                update summonsToUpdate;
            }
            
            if (summonsToDelete.isEmpty() == False) {
                
                delete summonsToDelete;
            }
        }
    }
    //S20-37 ****Ends****
    
    //S20-458 ****Starts**** Updating Assign_Litigation_Support_Management__c to True.
    public static void checkingLitigationStageForAssigningLitSupport(Map<Id, nu_dse__TradeLine__c> oldTradelinesMap, List<nu_dse__TradeLine__c> newTradelineList) {
        
        Set<String> litigationStagesSet = new Set<String>();
        
        for (Lit_Stage_Value_For_LitSupportManagement__mdt litStageInstance : [SELECT Id, MasterLabel FROM Lit_Stage_Value_For_LitSupportManagement__mdt]) {
                    
            litigationStagesSet.add(litStageInstance.MasterLabel);
        }
        
        for (nu_dse__Tradeline__c tradelineInstance :newTradelineList) {
            
            if ((tradelineInstance.Litigation_Stage__c != oldTradelinesMap.get(tradelineInstance.Id).Litigation_Stage__c)
                && litigationStagesSet.contains(tradelineInstance.Litigation_Stage__c) == True 
                && tradelineInstance.Assign_Litigation_Support_Management__c == False){ 
                        
                tradelineInstance.Assign_Litigation_Support_Management__c = True;
            }
        }
    }
    //S20-458 ****Ends****
}