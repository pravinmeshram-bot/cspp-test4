global class Attorney_ProgramFeeTemplateUpdateBatch implements Database.Batchable<Sobject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
    //Changes made by Rajesh for NMI - 496
      //  Id ProgramId = 'a0L4100000F3SP6';
        String query = 'Select Id,GCS_Policy_Group__c,Settlement_Fee__c,Estimated_Settlement__c,Program_type__c,nu_dse__Total_Debt_Included__c,nds_Estimated_Total_Debt__c,nu_dse__Fee_Template__c from nu_dse__Program__c where Attorney__c=TRUE  AND (Estimated_Settlement__c > 0) AND (Settlement_Fee__c > 0) AND (GCS_Policy_Group__c != NULL) AND (Program_type__c != NULL) AND (nu_dse__Total_Debt_Included__c > 0 OR NDS_ESTIMATED_TOTAL_DEBT__c > 0) AND (nu_dse__Fee_Template__c = NULL)  order by Portfolio__r.name'; // AND id=:ProgramId
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<nu_dse__Program__c> programList){
       
        system.debug('###programList::'+programList);
        Set<String> feeGroupIdSet = new Set<String>();
        Set<Decimal> serviceFeePercentageSet = new Set<Decimal>();
        Set<Decimal> settlementPctSet = new Set<Decimal>();
        Set<String> programeNameSet = new Set<String>();
        
        for(nu_dse__Program__c prog: programList){
            feeGroupIdSet.add(prog.GCS_Policy_Group__c);
            serviceFeePercentageSet.add(prog.Settlement_Fee__c);
            settlementPctSet.add(prog.Estimated_Settlement__c);
            programeNameSet.add(prog.Program_type__c);    
        }
        List<LeadTracProgramType__mdt> leadTracPrgTypesLst = [Select Label,Portfolio_name__c,RAMS__c FROM LeadTracProgramType__mdt WHERE Label IN: programeNameSet];
        Set<String> portifolioNameSet = new Set<String>();
        Map<String,String> portifolioProgMap = new Map<String,String>();
        Map<String,LeadTracProgramType__mdt> LeadTracProgramTypeMap = new Map<String,LeadTracProgramType__mdt>();
        for(LeadTracProgramType__mdt progType: leadTracPrgTypesLst){
            portifolioNameSet.add(progType.Portfolio_name__c);
            portifolioProgMap.put(progType.Label, progType.Portfolio_name__c);
            LeadTracProgramTypeMap.put(progType.Label,progType);
        }
        system.debug('###feeGroupIdSet::'+feeGroupIdSet);    
        List<nu_dse__Fee_Template__c> feeTemLst = new List<nu_dse__Fee_Template__c>();
        feeTemLst = [select Id,Name,Debt_Amount__c,Program_Type__c,portfolio_name__c,nu_dse__Settlement_Pct__c,Service_Fee_Percentage__c,nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c FROM nu_dse__Fee_Template__c WHERE portfolio_name__c IN: portifolioNameSet
        AND nu_dse__Settlement_Pct__c IN: settlementPctSet AND Service_Fee_Percentage__c IN: serviceFeePercentageSet
        AND (nu_dse__GCS_Fee_Group_Id__c IN: feeGroupIdSet OR nu_dse__RAMS_Fee_Group_Id__c IN: feeGroupIdSet)];
        system.debug('###feeTemLst::'+feeTemLst);
        Map<String,List<nu_dse__Fee_Template__c>> feeTempLstMap = new Map<String,List<nu_dse__Fee_Template__c>>();
        Map<String,List<nu_dse__Fee_Template__c>> RAMSTempLstMap = new Map<String,List<nu_dse__Fee_Template__c>>();
        for(nu_dse__Fee_Template__c feeTemp: feeTemLst){
            String key = feeTemp.portfolio_name__c+'-'+Integer.valueOf(feeTemp.nu_dse__Settlement_Pct__c)+'-'+Integer.valueOf(feeTemp.Service_Fee_Percentage__c)+'-'+feeTemp.nu_dse__GCS_Fee_Group_Id__c;
            System.debug(Key);
            if(feeTempLstMap.containsKey(key)){
                List<nu_dse__Fee_Template__c> feeTempLst = feeTempLstMap.get(key);
                feeTempLst.add(feeTemp);
                feeTempLstMap.put(key,feeTempLst);    
            }else{
                feeTempLstMap.put(key, new List<nu_dse__Fee_Template__c> {feeTemp});    
            }
            if(feeTemp.nu_dse__RAMS_Fee_Group_Id__c != null){
                String RAMSKey = feeTemp.portfolio_name__c+'-'+Integer.valueOf(feeTemp.nu_dse__Settlement_Pct__c)+'-'+Integer.valueOf(feeTemp.Service_Fee_Percentage__c)+'-'+feeTemp.nu_dse__RAMS_Fee_Group_Id__c;
                if(!RAMSTempLstMap.containsKey(RAMSKey)){
                    RAMSTempLstMap.put(RAMSKey,new List<nu_dse__Fee_Template__c>());
                }
                RAMSTempLstMap.get(RAMSKey).add(feeTemp);
            }
        }
        system.debug('###feeTempLstMap::'+feeTempLstMap);
        for(nu_dse__Program__c prog: programList){
            String key = portifolioProgMap.get(prog.Program_type__c)+'-'+Integer.valueOf(prog.Estimated_Settlement__c)+'-'+Integer.valueOf(prog.Settlement_Fee__c)+'-'+prog.GCS_Policy_Group__c;
            system.debug('###key::'+key);
            if(feeTempLstMap.containsKey(key) || RAMSTempLstMap.containsKey(key)){
                List<nu_dse__Fee_Template__c> feetempLst;
                if(LeadTracProgramTypeMap.get(prog.Program_type__c) != null && LeadTracProgramTypeMap.get(prog.Program_type__c).RAMS__c && RAMSTempLstMap.ContainsKey(Key)){
                    feetempLst = RAMSTempLstMap.get(Key);
                } else if(!LeadTracProgramTypeMap.get(prog.Program_type__c).RAMS__c && feeTempLstMap.containsKey(key)){
                    feetempLst = feeTempLstMap.get(key); 
                }
                system.debug('###feetempLst::'+feetempLst);
                if(feeTempLst != null){
                for(nu_dse__Fee_Template__c feeTemp: feetempLst){
                If(prog.nu_dse__Total_Debt_Included__c > 0)
                {
                    if(prog.nu_dse__Total_Debt_Included__c >= 30000 && feeTemp.Debt_Amount__c == 'Over 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)                        
                        prog.nu_dse__Fee_Template__c = feeTemp.Id;
                        
                    else if(prog.nu_dse__Total_Debt_Included__c < 30000 && feeTemp.Debt_Amount__c == 'Under 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)                        
                        prog.nu_dse__Fee_Template__c = feeTemp.Id;  
                        
              
                    system.debug('###Prog::'+prog);
                 }   
                    else
                    {
                    
                    if(prog.nds_Estimated_Total_Debt__c>= 30000 && feeTemp.Debt_Amount__c == 'Over 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)
                                              prog.nu_dse__Fee_Template__c = feeTemp.Id;
                        

                    else if(prog.nds_Estimated_Total_Debt__c < 30000 && feeTemp.Debt_Amount__c == 'Under 30000' && prog.Program_Type__c == feeTemp.Program_Type__c)                        
                        prog.nu_dse__Fee_Template__c = feeTemp.Id;           
                        

                    }
                }
                }
            }
        }
        
        update programList;
        
    }
    
    global void finish(Database.BatchableContext BC){
        List<System_log__c> systemLogLst = [Select Status__c,JobRunning__c FROM System_Log__c Where jobRunning__c = TRUE AND Category__c = 'Program'];
        if(!systemLogLst.isEmpty()){
            systemLogLst[0].jobRunning__c = FALSE;
            Update systemLogLst[0];     
        }
    }
}