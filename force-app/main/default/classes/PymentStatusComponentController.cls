global class PymentStatusComponentController {
    
    
    @RemoteAction
    global static List<Payment> getPayments(Id recordId) {
        List<Payment> paymentList = new List<Payment>();
        
        List<nu_dse__Payment__c> records = [SELECT Id, Name, nu_dse__Transaction_Status__c, nu_dse__Schedule_Date__c FROM nu_dse__Payment__c WHERE nu_dse__Program__c = :recordId AND RecordType.DeveloperName = 'Draft' and nu_dse__Transaction_Status__c !='Failed' ORDER BY CreatedDate ASC LIMIT 4];
        
        for(nu_dse__Payment__c p : records) {
            paymentList.add(new Payment(p));
        }
         
        return paymentList;
    }
    
    global class Payment {
        public String name;
        public Date paymentDate;
        public Boolean completed;
        public Boolean pastDue;
        public String status;
        public String dateString;
        
        public Payment(nu_dse__Payment__c payment) {
            this.name = payment.Name;
            this.status = payment.nu_dse__Transaction_Status__c;
            this.completed = payment.nu_dse__Transaction_Status__c == 'Completed';
            if(!this.completed && payment.nu_dse__Schedule_Date__c < System.today()) {
                this.pastDue = true;
            }
            this.dateString = toDateString(payment.nu_dse__Schedule_Date__c, 'MM/dd/YYYY');
        }
    }
    
    global static String toDateString(Date activityDate, String dateFormat) {
        if(activityDate != null) {
            DateTime dt = DateTime.newInstance(activityDate.year(), activityDate.month(), activityDate.day());
            return dt.format(dateFormat);
        }
        return '';
    }
    
}