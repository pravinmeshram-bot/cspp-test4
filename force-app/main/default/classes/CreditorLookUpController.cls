public without sharing class CreditorLookUpController {



    public List<Creditor_Lookup__c> CreditorLookUpList;
    public List<SelectOption> OriginalCreditorList{get;set;}
    public String SelectedOriginalCreditor{get;set;}
    public String SelectedCurrentCreditor{get;set;}
    public List<SelectOption> CurrentCreditorList;//{get;set;}
    public List<SelectOption> isLitigation{get;set;}
    public String isLitigationSelected{get;set;}

    public List<String> CurrentCreditorValues = new List<String>();
    public List<String> OriginalCreditorValues = new List<String>();

    public CreditorLookUpController() {
        
        OriginalCreditorList = new List<SelectOption>();
        List<AggregateResult> CreditorLookupList = [Select count(Id), Original_Creditor__c from Creditor_Lookup__c Group By Original_Creditor__c];
        //OriginalCreditorList.add(new SelectOption('','None'));
        for(AggregateResult ar: CreditorLookUpList){
            String option = (String)ar.get('Original_Creditor__c');
            OriginalCreditorList.add(new SelectOption(option.toLowerCase(),(String)ar.get('Original_Creditor__c')));
            OriginalCreditorValues.add(option.toLowerCase());
        }
        
        isLitigation = new List<SelectOption>();
        
        isLitigation.add(new SelectOption('No','No'));
        isLitigation.add(new SelectOption('Yes','Yes'));
        if((SelectedOriginalCreditor == '' || SelectedOriginalCreditor == null || !OriginalCreditorValues.contains(SelectedOriginalCreditor) || !CurrentCreditorValues.contains(SelectedCurrentCreditor)) && !OriginalCreditorList.isEmpty()){
            SelectedOriginalCreditor = OriginalCreditorList.get(0).getValue();
        }
        if(isLitigationSelected == '' || isLitigationSelected == null){
           isLitigationSelected = 'No'; 
        }
        CurrentCreditorList = getCurrentCreditorList();
        
        if((SelectedCurrentCreditor == '' || SelectedCurrentCreditor== null || !CurrentCreditorValues.contains(SelectedCurrentCreditor)) && !CurrentCreditorList.isEmpty()){
            SelectedCurrentCreditor = CurrentCreditorList.get(0).getValue();
        }
    }

    
    public CreditorLookUpController(ApexPages.StandardController controller) {
                
        String TradeId = ApexPages.currentPage().getParameters().get('id');
                
        nu_dse__Tradeline__c Tradeline = [Select Id, Normalized_Current_Creditor__c, Normalized_Original_Creditor__c from nu_dse__Tradeline__c where id =: TradeId]; 

        if(Tradeline.Normalized_Original_Creditor__c != null)
        SelectedOriginalCreditor = Tradeline.Normalized_Original_Creditor__c.toLowerCase();
        if(Tradeline.Normalized_Current_Creditor__c != null)
        SelectedCurrentCreditor = Tradeline.Normalized_Current_Creditor__c.toLowerCase();
                
        OriginalCreditorList = new List<SelectOption>();
        List<AggregateResult> CreditorLookupList = [Select count(Id), Original_Creditor__c from Creditor_Lookup__c Group By Original_Creditor__c];
        
        for(AggregateResult ar: CreditorLookUpList){
            String option = (String)ar.get('Original_Creditor__c');
            OriginalCreditorList.add(new SelectOption(option.toLowerCase(),option));
            OriginalCreditorValues.add(option.toLowerCase());
        }
        isLitigation = new List<SelectOption>();
        isLitigation.add(new SelectOption('No','No'));
        isLitigation.add(new SelectOption('Yes','Yes'));
        CurrentCreditorList = getCurrentCreditorList();
        if((SelectedOriginalCreditor == '' || SelectedOriginalCreditor == null || !OriginalCreditorValues.contains(SelectedOriginalCreditor) || !CurrentCreditorValues.contains(SelectedCurrentCreditor)) && !OriginalCreditorList.isEmpty()){
            SelectedOriginalCreditor = OriginalCreditorList.get(0).getValue();
        }
        if(isLitigationSelected == '' || isLitigationSelected == null){
           isLitigationSelected = 'No'; 
        }
        CurrentCreditorList = getCurrentCreditorList();
        
        if(Tradeline.Normalized_Current_Creditor__c != null)
        SelectedCurrentCreditor = Tradeline.Normalized_Current_Creditor__c.toLowerCase();
        
        if((SelectedCurrentCreditor == '' || SelectedCurrentCreditor== null || !CurrentCreditorValues.contains(SelectedCurrentCreditor)) && !CurrentCreditorList.isEmpty()){
            SelectedCurrentCreditor = CurrentCreditorList.get(0).getValue();
        }
    }
    
    public List<SelectOption> getCurrentCreditorList(){
        
        String query= 'Select count(Id), Current_Creditor__c from Creditor_Lookup__c';
        if(SelectedOriginalCreditor != null && SelectedOriginalCreditor != '') {
            query += ' where Original_Creditor__c =: SelectedOriginalCreditor';
        }
        query += ' GROUP BY Current_Creditor__c';
        
        List<AggregateResult> CreditorList = (List<AggregateResult>)Database.query(query);
        List<SelectOption> CurrentList = new List<SelectOption>();
        CurrentCreditorValues.clear();
       // CurrentList.add(new SelectOption('','None'));
        for(AggregateResult ar:CreditorList){
            String option = (String)ar.get('Current_Creditor__c');
            CurrentList.add(new SelectOption(option.toLowerCase(),(String)ar.get('Current_Creditor__c')));
            CurrentCreditorValues.add(option.toLowerCase());
        }
        System.debug(SelectedCurrentCreditor);
        System.debug(CurrentCreditorValues.contains(SelectedCurrentCreditor));
        if(CurrentList != null && !CurrentList.isEmpty() && !CurrentCreditorValues.contains(SelectedCurrentCreditor)){
            SelectedCurrentCreditor = CurrentList.get(0).getValue();
            System.debug('here'+SelectedCurrentCreditor);
        }
         
        System.debug(CurrentList);
        CreditorLookUpList=getCreditorLookUpList();
        return CurrentList;
    }
    
    public List<Creditor_Lookup__c> getCreditorLookUpList(){
    
        String query = 'Select Id, Original_Creditor__c, Current_Creditor__c, Average_Settlement_Percentage__c, Best_Single_Settlement__c, Median_Settlement_Percentage__c,Settlement_Terms__c,Worst_Single_Offer__c,NUmber_of_Offers_Frequency__c from Creditor_Lookup__c';
        
        if((SelectedOriginalCreditor != null && SelectedOriginalCreditor != '') || (SelectedCurrentCreditor != null && SelectedCurrentCreditor != '') || (isLitigationSelected != null && isLitigationSelected != '')){
            query += ' where';
            boolean putAnd = false;
            if(SelectedOriginalCreditor != null && SelectedOriginalCreditor != ''){
                query += ' Original_Creditor__c=:SelectedOriginalCreditor';
                putAnd = true;
            }
            if(SelectedCurrentCreditor != null && SelectedCurrentCreditor != ''){
                if(putAnd) query += ' AND';
                query += ' Current_Creditor__c =:SelectedCurrentCreditor';
                putAnd = True;
            }
            if(isLitigationSelected != null && isLitigationSelected != '' && isLitigationSelected == 'Yes'){
                if(putAnd) query += ' AND';
                query += ' Is_Lit__c=true';
            } else if(isLitigationSelected != null && isLitigationSelected != '' && isLitigationSelected == 'No'){
                if(putAnd) query += ' AND';
                query += ' Is_Lit__c=false';
            }
        }
        List<Creditor_Lookup__c> CreditorList = (List<Creditor_Lookup__c>)Database.query(query);
        System.debug(SelectedCurrentCreditor);
        System.debug(CreditorList);
        System.debug(query);
        CreditorLookUpList=CreditorList;
        return CreditorList;
    }
    
    public void refreshPicklists(){
        System.debug('Original Creditor'+ SelectedOriginalCreditor);
        getCurrentCreditorList();
    }
    
    public void refreshData(){
        System.debug('Original Creditor'+ SelectedOriginalCreditor);
        
    }

    /*@AuraEnabled
    public static List<String> getOriginalCreditors(){
        
        List<String> OriginalCreditors= new List<String>();
        List<AggregateResult> CreditorLookupList = [Select count(Id), Original_Creditor__c from Creditor_Lookup__c Group By Original_Creditor__c];
        //OriginalCreditors.add(new SelectOption(None'));
        for(AggregateResult ar: CreditorLookUpList){
            System.debug(ar);
            OriginalCreditors.add((String)ar.get('Original_Creditor__c'));
        }
        return OriginalCreditors;
    }*/
}