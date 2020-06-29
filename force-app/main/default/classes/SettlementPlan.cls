public class SettlementPlan {
    
    public Boolean isSucess { get; set; }
    
    public Integer indexVar { get; set; }
    
    public Date dat {get;set;}
    
    public String errorMessage { get; set; }
    
    public String baseURL{ get; set; }
    
    public String CurrentDate{ get; set; }
    
    public Boolean isError { get; set; }
    public Boolean isErrorduedate { get; set; }
    
    public Boolean isFeeApplicable { get; set; }
    
    public String recordType { get; set; }
        
    public Decimal autoAdjustmentSettlmentamount { get; set; }
    
    public Decimal autoAdjustmentFeeamount { get; set; }
    
    public List<nu_dse__Payment__c> paymentList {get;set;}
    
    public Map<Id, String> recordTypeMap {get;set;}
    
    public List<PaymentWrapper> paymentWrapperList {get;set;}
    
    public List<nu_dse__Offer__c> offerList {get;set;}
    
    public Decimal offerAmount {get;set;}
    
    public Decimal offerFeeAmount {get;set;}
    
    public Id offerId {get;set;}
    
    // ND-390
    public Boolean isModify_Flag {get;set;}

    public Map<string,profile> profileMap = new Map<string,profile>();
    // ND-390
    
    public SettlementPlan() {
        
        this.isFeeApplicable = false;
        this.indexVar = 0;
        this.isError = false;
        this.isErrorduedate = false;
        this.errorMessage  = '';
        this.offerAmount = 0;
        this.offerFeeAmount = 0;
        this.recordTypeMap = new Map<Id,String>();
        this.autoAdjustmentSettlmentamount = 0;
        this.autoAdjustmentFeeamount = 0;
        this.paymentList = new List<nu_dse__Payment__c>();
        this.paymentWrapperList = new List<PaymentWrapper>();
        this.offerList = new List<nu_dse__Offer__c>();
        this.offerId = ApexPages.currentPage().getParameters().get('id');
        String str=  System.Url.getSalesforceBaseUrl().toExternalForm();
        str = str.remove('c.') ; 
        str = str.substringBeforeLast('.visual') + '.salesforce.com/'+offerId;
        getOfferList();
        this.baseURL = str;
        Datetime currentDateVal = System.now();
        
        this.CurrentDate = currentDateVal.format('yyyy-MM-dd');
        this.isModify_Flag = false;
        
        if (offerList.isEmpty() == False) {
            
            for (nu_dse__Payment__c payment : [SELECT Id, Name, nu_dse__Amount__c, nu_dse__Admin_Fee__c, nu_dse__Transaction_Status__c, 
                                               nu_dse__Processor_Fee__c, Processor__c, nu_dse__Monthly_Third_Party_Fees__c, nu_dse__Offer__r.Portfolio_Name__c,
                                               nu_dse__Schedule_Date__c, nu_dse__Total_Other_Fee__c, nu_dse__Payment_Type__c, RecordTypeId,Due_Date__c, 
                                               nu_dse__Total_Amount__c, nu_dse__Offer__c, RecordType.DeveloperName,
                                               nu_dse__Offer__r.DNL_Status__c FROM nu_dse__Payment__c  // ND-390 - Uchit
                                               WHERE nu_dse__Offer__c =:offerList[0].Id AND (((nu_dse__Offer__r.Portfolio_Name__c = 'Timberline' 
                                               OR nu_dse__Offer__r.Portfolio_Name__c = 'Royal') AND (RecordType.DeveloperName = 'Settlement'
                                               OR RecordType.DeveloperName = 'Fee')) OR RecordType.DeveloperName = 'Settlement') ORDER BY nu_dse__Schedule_Date__c , RecordTypeID, nu_dse__Transaction_Status__c ASC]) {
                
                if ((payment.nu_dse__Offer__r.Portfolio_Name__c == 'Royal' || payment.nu_dse__Offer__r.Portfolio_Name__c == 'Timberline') 
                                    && payment.RecordType.DeveloperName == 'Fee') {
            
                    this.isFeeApplicable = true;
                }
                
                if (recordTypeMap.ContainsKey(payment.RecordTypeId) == False) {
                    
                    recordTypeMap.put(payment.RecordTypeId, payment.RecordType.DeveloperName);
                }
                if (payment.nu_dse__Amount__c != null && payment.RecordType.DeveloperName == 'Settlement') {
                
                    this.autoAdjustmentSettlmentamount  += payment.nu_dse__Amount__c;
                } 
                if (payment.nu_dse__Amount__c != null && payment.RecordType.DeveloperName == 'Fee') {
                
                    this.autoAdjustmentFeeamount += payment.nu_dse__Amount__c;
                } 
                PaymentWrapper paymentWrap = new PaymentWrapper();
                paymentWrap.sobjectId = payment.Id;
                Datetime myDT = payment.nu_dse__Schedule_Date__c.addDays(1);
                Datetime Duedt = payment.Due_Date__c.addDays(1);
                paymentWrap.scheduledDate = myDT.format('yyyy-MM-dd');
                paymentWrap.duedate = Duedt.format('yyyy-MM-dd');
                
                paymentWrapperList.add(paymentWrap);
                this.paymentList.add(payment);
            } 
            
            // ND-390 Uchit
            String proName =[Select Id, Name from Profile where Id=:UserInfo.getProfileId()].Name;
            system.debug('===profile Name==='+proName);
            prepareDNLProfileMap();
            if(profileMap.containsKey(proName)){
            isModify_Flag = true;   
            }else{
            isModify_Flag = false;  
            }
            system.debug('===='+isModify_Flag);
            // ND-390 Uchit             
        }
    }
    
    // ND-390
    public void prepareDNLProfileMap(){
    
        for(Profile pro : [Select Id, Name from Profile where Name IN ('DNL Negotiations','DNL Negotiations Director','DNL Negotiations Manager','DNL Negotiations Manager_SFPlatform','DNL Negotiations Team Member','DNL Negotiations_SF Platform','DNL Payment Processor','DNL Payments Manager','DNL Payments Team Member', 'System Administrator')]){
        profileMap.put(pro.Name,pro);
        }
        system.debug('====='+profileMap.Keyset());
    }
    //ND-390
    
    public void getOfferList() {
        
        for (nu_dse__Offer__c offer : [SELECT Id, nu_dse__Offer_Amount__c, nu_dse__Program_Fee__c, nu_dse__Status__c, Portfolio_Name__c FROM nu_dse__Offer__c 
                                       WHERE nu_dse__Status__c != 'To Payment Processing' AND Id =: ApexPages.currentPage().getParameters().get('id')]) {
            
            if (offer.nu_dse__Offer_Amount__c != null) {
                
                this.offerAmount = offer.nu_dse__Offer_Amount__c;
            }
            if (offer.nu_dse__Program_Fee__c != null) {
                
                this.offerFeeAmount = offer.nu_dse__Program_Fee__c;
            }
            this.offerList.add(offer);
        }
    
    }
    
    public void autoPaymentAdjustments() {
        
        system.debug('*******');
        this.autoAdjustmentSettlmentamount = 0;
        this.autoAdjustmentFeeamount = 0;
        for (nu_dse__Payment__c payment : this.paymentList) {
            
            if (payment.nu_dse__Amount__c != null && recordTypeMap.get(payment.RecordTypeId) == 'Settlement') {
                
                this.autoAdjustmentSettlmentamount  += payment.nu_dse__Amount__c;
            }
            if (payment.nu_dse__Amount__c != null && recordTypeMap.get(payment.RecordTypeId) == 'Fee') {
                
                this.autoAdjustmentFeeamount += payment.nu_dse__Amount__c;
            }
        }
    }
    
    public void deletePayment() {
        
        system.debug('******* indexVar '+indexVar );
        
        if (indexVar >= 0 && paymentList.isEmpty() == False ) {
            
            paymentWrapperList.remove(indexVar);
            paymentList.remove(indexVar);
        }
        autoPaymentAdjustments();
        system.debug('******* paymentList'+paymentList);
    }

    public Void addNewSettlementPayment() {
        
        system.debug('***** RecordType'+recordType);
        
        for (nu_dse__Payment__c payment : [SELECT Name, nu_dse__Admin_Fee__c, nu_dse__Transaction_Status__c, RecordTypeId,
                                           nu_dse__Processor_Fee__c, Processor__c, nu_dse__Monthly_Third_Party_Fees__c, 
                                           nu_dse__Payment_Type__c, IsAttorney__c,Due_Date__c, 
                                           nu_dse__Offer__c, nu_dse__Transaction_Method__c, nu_dse__Program__c 
                                           FROM nu_dse__Payment__c WHERE 
                                           nu_dse__Offer__c =:ApexPages.currentPage().getParameters().get('id') AND 
                                           RecordType.DeveloperName =:recordType Limit 1]) {
            
            nu_dse__Payment__c paymentInstance = payment.clone(false, true, false, false);
            paymentInstance.nu_dse__Schedule_Date__c = System.today();
            paymentInstance.nu_dse__Amount__c = 0;
            paymentInstance.nu_dse__Transaction_Status__c = 'Pending';
            if (recordType == 'Fee') {
                paymentInstance.nu_dse__Payment_Type__c = 'Fee Withdrawal';
            } else {
                paymentInstance.nu_dse__Payment_Type__c = 'Withdrawal';
            }
            system.debug('paymentInstance--->'+paymentInstance );
            
            PaymentWrapper paymentWrap = new PaymentWrapper();
            Datetime myDT = paymentInstance.nu_dse__Schedule_Date__c.AddDays(1);
            paymentWrap.scheduledDate = myDT.format('yyyy-MM-dd');
            paymentWrapperList.add(paymentWrap);
            this.paymentList.add(paymentInstance);
        }
    }
    
    public void SavePayments() {
        
        
        if ((autoAdjustmentSettlmentamount == offerAmount && this.isFeeApplicable == false) 
            || (this.isFeeApplicable == true && autoAdjustmentSettlmentamount == offerAmount && autoAdjustmentFeeamount == offerFeeAmount)) {
        
            try {
            
                this.isError = false;
                List<nu_dse__Payment__c> upsertPayment = new List<nu_dse__Payment__c>();
                if (paymentList.isEmpty() == False) {
                    
                    Integer i = 0;
                    for (nu_dse__Payment__c payment : paymentList) {
                        
                        if ((payment.nu_dse__Schedule_Date__c < system.today() && payment.Id == null) || payment.nu_dse__Schedule_Date__c > payment.Due_Date__c  ) {
                            
                            this.isError = true;
                        }else if(payment.Due_Date__c == null){
                            this.isErrorduedate = true;
                        } 
                        upsertPayment.add(payment);
                    }
                    if (isError == True) {
                        
                        this.errorMessage = 'The Scheduled Date Cannot be greater than Due date';
                    }else if(isErrorduedate == true){
                         this.errorMessage = 'Due date cannot be updated to blank';                             
                    } else {
                        
                        upsert upsertPayment;
                        this.isSucess = true;
                        this.errorMessage = 'Payments updated Successfully';
                    }
                }
            } catch (Exception e) {
            
                this.isError = true;
                this.errorMessage = e.getMessage();
            }
        } else {
            
            this.errorMessage = '';
            if ((autoAdjustmentSettlmentamount > offerAmount) 
                && (this.isFeeApplicable == true &&  autoAdjustmentFeeamount > offerFeeAmount)){
                
                this.isSucess = false;
                this.isError = true;
                this.errorMessage += 'Total Settlement Amount and Total Fee Amount cannot be greater than the Offer Amount and Program Fee. ';
            } else if (autoAdjustmentSettlmentamount > offerAmount) {
        
                this.isSucess = false;
                this.isError = true;
                this.errorMessage += 'Total Settlement Amount cannot be greater than the Offer Amount. ';
            } else if (this.isFeeApplicable == true &&  autoAdjustmentFeeamount > offerFeeAmount) {
                
                this.isSucess = false;
                this.isError = true;
                this.errorMessage += 'Total Fee Amount cannot be greater than the Program Fee. ';
            }
            if ((autoAdjustmentSettlmentamount < offerAmount) && (this.isFeeApplicable == true && autoAdjustmentFeeamount < offerFeeAmount)) {
                
                this.isSucess = false;
                this.isError = true;
                this.errorMessage += 'Total Settlement Amount and Total Fee Amount cannot be less than the Offer Amount and Program Fee. ';
            } else if (autoAdjustmentSettlmentamount < offerAmount) {
            
                this.isSucess = false;
                this.isError = true;
                this.errorMessage += 'Total Settlement Amount cannot be less than the Offer Amount. ';
            } else if (this.isFeeApplicable == true && autoAdjustmentFeeamount < offerFeeAmount){
                
                this.isSucess = false;
                this.isError = true;
                this.errorMessage += 'Total Fee Amount cannot be less than the Program Fee. ';
            }
        }
    }
    
    public void updateScheduleDate() { 
        
        string scheduleDate = String.isBlank(ApexPages.currentPage().getParameters().get('scheduledate')) ? '' : ApexPages.currentPage().getParameters().get('scheduledate');
        Integer index = 0;
        
        if (ApexPages.currentPage().getParameters().get('index') != null) {
            
            index = Integer.ValueOf(ApexPages.currentPage().getParameters().get('index'));
        }
        
        if (index >= 0 && paymentList.isEmpty() == False && String.isNotBlank(scheduleDate)) {
            
            Datetime scheduleDateVal = Date.ValueOf(scheduleDate).AddDays(1);
            paymentWrapperList[index].scheduledDate = scheduleDateVal.format('yyyy-MM-dd');
            paymentList[index].nu_dse__Schedule_Date__c = Date.ValueOf(scheduleDate);
           
        } else if (index >= 0 && paymentList.isEmpty() == False) {
        
            paymentWrapperList[index].scheduledDate = '';
            paymentList[index].nu_dse__Schedule_Date__c = null;
        }
    }

    public void updateDueDate() { 
        system.debug('inside due date');
        string dueDate = String.isBlank(ApexPages.currentPage().getParameters().get('duedate')) ? '' : ApexPages.currentPage().getParameters().get('duedate');
        Integer index = 0;
        
        if (ApexPages.currentPage().getParameters().get('index') != null) {
            
            index = Integer.ValueOf(ApexPages.currentPage().getParameters().get('index'));
        }
        
        if (index >= 0 && paymentList.isEmpty() == False && String.isNotBlank(duedate)) {
            
            Datetime dueDateVal = Date.ValueOf(duedate).AddDays(1);
            paymentWrapperList[index].duedate = dueDateVal.format('yyyy-MM-dd');
            paymentList[index].Due_Date__c = Date.ValueOf(duedate);
           
        } else if (index >= 0 && paymentList.isEmpty() == False) {
        
            paymentWrapperList[index].duedate = '';
            paymentList[index].Due_Date__c = null;
        }
    }


    public class PaymentWrapper {
    
        public Id sobjectId { get; set; }
        public String scheduledDate { get; set; }
        public String duedate { get; set; }
        public Date dat {get;set;}
    }
}