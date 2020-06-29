global class SFSCASEController {

      @RemoteAction
    global static List<SFSCase> getsfsCases(Id recordId) {
        
        List<SFSCase> SFSCaseList = new List<SFSCase>();
        
        //Tradeline #, Tradeline Name, Legal Status, Hot Potato, Who it’s assigned to, SFS Case Status and Date Created.
        List<Summon__c> sfsCases = [SELECT Id, Name, Tradeline__r.Name,Tradeline__r.nu_dse__Tradeline_Name__c , Tradeline__r.Litigation_Stage__c ,Hot_Potato__c, Owner.Name,Status__c,CreatedDate  FROM Summon__c  WHERE Program__c  = :recordId ];
        
        for(Summon__c sfscase : sfsCases) {
            SFSCaseList.add(new SFSCase(sfscase));
        }
        
        return SFSCaseList;
    }
    
    
    global class SFSCase {
        public String name;
        public string tradelinenumber;
        public String tradelinename;
        public string legal_status; 
        public string hot_potato; 
        public string owner; 
        public string status; 
        public string createddate;
        public String recordId;
        
        public SFSCase(Summon__c sfscase) {
            
            this.name = sfscase.Name;
            this.tradelinenumber = sfscase.Tradeline__r.Name;
            if(sfscase.Tradeline__r.nu_dse__Tradeline_Name__c != null){
                         
                this.tradelinename = sfscase.Tradeline__r.nu_dse__Tradeline_Name__c;
  
            }else{
                
                this.tradelinename = '-';
            }
            this.legal_status = sfscase.Tradeline__r.Litigation_Stage__c ;
            this.hot_potato = sfscase.Hot_Potato__c;
            this.owner = sfscase.owner.name;
            this.status = sfscase.Status__c;
            this.createddate = (sfscase.CreatedDate).format('yyyy-MM-dd');
 
            this.recordId = sfscase.Id;
            
           
        }
    }
}