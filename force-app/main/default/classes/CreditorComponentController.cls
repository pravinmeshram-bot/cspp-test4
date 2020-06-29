global class CreditorComponentController {
    
    @RemoteAction
    global static List<Creditor> getCreditors(Id recordId) {
        
        List<Creditor> creditorList = new List<Creditor>();
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Name, nu_dse__Tradeline_Name__c, nu_dse__New_Creditor__r.Name, nu_dse__New_Account_Number__c, nu_dse__Original_Creditor__r.Name, nu_dse__Original_Account_Number__c FROM nu_dse__Tradeline__c WHERE nu_dse__Program__c = :recordId];
        
        for(nu_dse__Tradeline__c tradeline : tradelineList) {
            creditorList.add(new Creditor(tradeline));
        }
        
        return creditorList;
    }
    
    
    global class Creditor {
        
        public String name;
        public Boolean verified = false;
        public String recordId;
        
        public String originalCreditor = '';
        public String originalAccountNum = '';
        
        public String newCreditor = '';
        public String newAccountNumber = '';
        
        public Creditor(nu_dse__Tradeline__c tradeline) {
            
            this.name = tradeline.Name;
            /*
            This is commented out since we use 4 coloums for creditors and its account number. mar-05
            if(tradeline.nu_dse__Tradeline_Name__c != null) {
                this.name = tradeline.nu_dse__Tradeline_Name__c;
            }*/
        
            this.recordId = tradeline.Id;
            
            if(tradeline.nu_dse__Original_Creditor__c != null || tradeline.nu_dse__New_Creditor__c != null) {
                this.verified = true;
            }
            
            if (tradeline.nu_dse__Original_Creditor__c != null) {
                
                if (String.isNotBlank(tradeline.nu_dse__Original_Creditor__r.Name)) {
                    
                    this.originalCreditor = tradeline.nu_dse__Original_Creditor__r.Name;
                }
                
                if (String.isNotBlank(tradeline.nu_dse__Original_Account_Number__c)) {
                    
                    this.originalAccountNum = tradeline.nu_dse__Original_Account_Number__c;
                }
            }
            
            if (tradeline.nu_dse__New_Creditor__c != null) {
                
                if (String.isNotBlank(tradeline.nu_dse__New_Creditor__r.Name)) {
                    
                    this.newCreditor = tradeline.nu_dse__New_Creditor__r.Name;
                }
                
                if (String.isNotBlank(tradeline.nu_dse__New_Account_Number__c)) {
                    
                    this.newAccountNumber = tradeline.nu_dse__New_Account_Number__c;
                }
            }
        }
    }
}