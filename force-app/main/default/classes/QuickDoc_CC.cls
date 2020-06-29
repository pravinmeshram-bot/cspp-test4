public class QuickDoc_CC 
{

    public QuickDoc_CC(ApexPages.StandardController controller) {

    }

    public boolean displayPopup {get; set;}
    public String selectedRecordType{get;set;}
    //added by shalini -  selected status value
    public String selectedCCFHeaderStatus{get;set;}
    public boolean showCreate{get;set;}
    // Added by Lavanya for INC000101170300 - For Community Buyer 19/2017
    public boolean userpermission{get;set;}
    //End
    public String cpmoString='CPMO';//Sonar
    public String noneString='--None--';//Sonar
    public String draftString='Draft';//Sonar
    public String marketInputSting='Market Input in Progress';//Sonar
    public String marketInputComplete='Market Input Complete';//Sonar
    public String submittedString = 'Submitted';
    public string Acc {get; set;}
    
    public QuickDoc_CC(){
        showCreate = false; //This should be assigned as false default
        //Added by Lavanya for INC000101170300 - For Community Buyer 19/2017
        userpermission = true;
        //end
       // system.debug('userAssignedPerSetList=====>'+userAssignedPerSetList);
        
    Acc = ApexPages.currentPage().getParameters().get('CF00N18000000wpdZ');
    system.debug('K@@@'+Acc);
        
    }     
    
    
    public List<selectoption> getrecordTypes()
    {
        List<SelectOption> options=new List<SelectOption>();
        List<RecordType> recordTypesTempList=[select name,DeveloperName from recordtype where sobjecttype='Quick_Doc__c' And IsActive=True];
        options.add(new selectoption(noneString,noneString));
        for(recordtype rt : recordTypesTempList)
        {
            options.add(new selectoption(rt.DeveloperName,rt.name));
        }
        return options;
    }
    public pagereference newCCF()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_AccountReview1?action=New&Account='+Acc);
            page.setRedirect(true);
            return page;
            
        
    }
    
    public pagereference Onboarding ()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_OnboardingCall?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
            
        
    }
    
    public pagereference Strategy ()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_StrategyCall?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
            
        
    }
    
    public pagereference SettlementSpread()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_SettlementSpreadSheet?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
            
        
    }
    
    public pagereference PendingCancellation ()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_PendingCancellation?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
    }
    
    public pagereference Documents ()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_Documents?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
    }
    
    public pagereference Miscellaneous ()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_Miscellaneous?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
    }
    
    public pagereference Payments ()
    {
        Pagereference page;
        
            page=new Pagereference('/apex/QD_Payments?action=New&recordtype='+selectedRecordType);
            page.setRedirect(true);
            return page;
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    Public void Accrecord() {
        Acc = ApexPages.currentPage().getParameters().get('CF00N18000000wpdZ');
    system.debug('K@@@'+Acc);
    }
    
    
    
    
}