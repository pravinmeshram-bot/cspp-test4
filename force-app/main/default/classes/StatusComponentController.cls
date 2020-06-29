global class StatusComponentController implements nu_dse.IDashboardComponent {
    
    public String getComponentName() {
        return 'Status Component';
    }
    
    public ApexPages.Component getComponent(Id recordId) {
        return new Component.Status_Component(recordId = recordId);
    }
    
    @RemoteAction
    global static StatusWraper getStatus(Id recordId) {
        StatusWraper sw = new StatusWraper();
        List<nu_dse__Program__c> pgList = [SELECT Id, nu_dse__Processor_Status__c, nu_dse__CIP_Status__c, nu_dse__OFAC_Status__c FROM nu_dse__Program__c WHERE id = :recordId];
        
        if(!pgList.isEmpty()) {
            sw.processorStatus = new Status(pgList[0].nu_dse__Processor_Status__c, pgList[0].nu_dse__Processor_Status__c == 'Active');
            sw.cipStatus = new Status(pgList[0].nu_dse__CIP_Status__c, pgList[0].nu_dse__CIP_Status__c == 'Verified');
            sw.ofacStatus = new Status(pgList[0].nu_dse__OFAC_Status__c, pgList[0].nu_dse__OFAC_Status__c == 'Verified');
            
            List<nu_dse__Bank_Account__c> ba = [SELECT Id, nu_dse__Status__c FROM nu_dse__Bank_Account__c WHERE nu_dse__Program__c = :recordId];
            if(!ba.isEmpty()) {
                sw.baStatus = new Status(ba[0].nu_dse__Status__c, ba[0].nu_dse__Status__c == 'Active');
            }
        }
        
        return sw;
    }
    
    global class Status {
        public String status;
        public Boolean active;
        
        public Status(String status, Boolean active) {
            this.status = status;
            this.active = active;
        }
    }
    
    global class StatusWraper {
        public Status processorStatus;
        public Status cipStatus;
        public Status ofacStatus;
        public Status baStatus;
    }
    
}