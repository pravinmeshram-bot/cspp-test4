public class ProgramPaymentsExportController {

    Map<String,PaymentWrapper> PaymentWrapperMap;
    Map<Date,PaymentWrapper> PaymentWrapperDateMap;
    public List<PaymentWrapper> PaymentWrapperList {get;set;} 
    public nu_dse__Program__c program{get;set;}
    public List<String> OfferNames{get;set;}
    public String ChangedMonth{get;set;}
    public List<String> CSVdata{get;set;}
    public String data{get;set;}
    public String PaymentProcessingDay{get;set;}
    public String SecondPaymentProcessingDay{get;set;}
    public Map<String,List<String>> OfferNamesMap{get;set;}
    public Map<String,List<String>> FeeOfferNamesMap{get;set;}
    public static String emailAddress {get; set;}
    public static string url{get; set;}
    public List<Integer> NumberofMonthlyDraft{get;set;}
    public Boolean isAdhocPaymentExists{get;set;}
    public Map<String,String> OfferSourceMap{get;set;}
    public String FeeKeyValues{get;set;}
    

    Static Double FinalRunningBalance;
    
    private ProgramPaymentsExportController parentClass = this;
    
    public ProgramPaymentsExportController(ApexPages.StandardController controller) {
        FeeKeyValues = '';
        NumberofMonthlyDraft = new List<Integer>();
        PaymentWrapperMap = new Map<String,PaymentWrapper>();
        PaymentWrapperDateMap = new Map<Date,PaymentWrapper>();
        PaymentWrapperList = new List<PaymentWrapper>();
        OfferNames = new List<String>();
        OfferNamesMap = new Map<String,List<String>>();
        OfferSourceMap = new Map<String,String>();
        FeeOfferNamesMap = new Map<String,List<String>>();
             isAdhocPaymentExists = false;   
        String ProgramId = ApexPages.currentPage().getParameters().get('id');
                
       Program = [Select Id, nu_dse__Payment_Frequency__c,FirstName__c,LastName__c, nu_dse__Account__r.FirstName,nu_dse__Processor__r.name, nu_dse__Processor__r.nu_dse__type__c, nu_dse__Reoccurring_Debit_Day__c, nu_dse__Twice_Monthly_Reoccuring_Day__c, nu_dse__Account__r.LastName, nu_dse__Trust_Account_Balance__c from nu_dse__Program__c where id=: ProgramId];
        
        
        
        FinalRunningBalance = Program.nu_dse__Trust_Account_Balance__c;
        Date today = Date.today();
        if(SecondPaymentProcessingDay == null && Program.nu_dse__Twice_Monthly_Reoccuring_Day__c != null){
            Date SecondPaymentProcessingDate = Date.newInstance(today.year(),today.month(),Integer.valueOf(Program.nu_dse__Twice_Monthly_Reoccuring_Day__c));
            if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'GCS' || Program.nu_dse__Processor__r.nu_dse__Type__c == 'CFT'){
                SecondPaymentProcessingDay = String.valueOf((SecondPaymentProcessingDate + 7).Day());
            } else if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS'){
                SecondPaymentProcessingDay = String.valueOf((SecondPaymentProcessingDate + 10).Day());
            } else {
                SecondPaymentProcessingDay = String.valueOf(SecondPaymentProcessingDate.Day());
            }
        }
        
        if(PaymentProcessingDay == null && Program.nu_dse__Reoccurring_Debit_Day__c != null){
            Date PaymentProcessingDate = Date.newInstance(today.year(),today.month(),Integer.valueOf(Program.nu_dse__Reoccurring_Debit_Day__c));
            if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'GCS' || Program.nu_dse__Processor__r.nu_dse__Type__c == 'CFT'){
                PaymentProcessingDay = String.valueOf((PaymentProcessingDate + 7).Day());
            } else if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS'){
                PaymentProcessingDay = String.valueOf((PaymentProcessingDate + 10).Day());
            } else {
                PaymentProcessingDay = String.valueOf(PaymentProcessingDate.Day());
            }
        }

        System.debug(ProgramId);
        Id DraftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        List<nu_dse__Payment__c> DraftPaymentList = [Select Id,nu_dse__Amount__c,nu_dse__Payment_Sequence_Number__c,nu_dse__Schedule_Date__c,nu_dse__Transaction_Status__c from nu_dse__Payment__c where nu_dse__Program__c =: ProgramId AND RecordTypeId =:DraftRecordType AND nu_dse__Schedule_Date__c >=: System.Today() ORDER BY nu_dse__Schedule_Date__c];
        System.debug(DraftPaymentList);
        
        Boolean error = false;
        for(nu_dse__Payment__c Payment: DraftPaymentList){
        Date scheduleDate = Payment.nu_dse__Schedule_Date__c;
            DateTime t = Datetime.newInstance(Payment.nu_dse__Schedule_Date__c,System.now().time());
            String month = t.format('MMM');
            String monthOfTheYear = month + ', ' + String.valueOf(t.Year()).right(2);
            System.debug(monthOftheYear);
            PaymentWrapper PayWrap;
            Integer daysInMonth = Date.daysInMonth(scheduleDate.Year(),scheduleDate.month());
            if(PaymentWrapperMap.containsKey(monthOfTheYear)){
                PayWrap = PaymentWrapperMap.get(monthOfTheYear);
            } else {
                PayWrap = new PaymentWrapper(parentClass);
                PayWrap.MonthlyDraftMap = new Map<Integer,Decimal>();
                PayWrap.numberOfMonthlyDraft = 0;
                PayWrap.month = monthOfTheYear;
                PayWrap.TotalAdhocPayment = 0;
            }
            if(Payment.nu_dse__Amount__c != null && Payment.nu_dse__Transaction_Status__c != 'Cancelled' && Payment.nu_dse__Payment_Sequence_Number__c != null){
                Decimal Amount = Payment.nu_dse__Amount__c;
                if(PayWrap.numberOfMonthlyDraft == 0){
                    if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'GCS' || Program.nu_dse__Processor__r.nu_dse__Type__c == 'CFT'){
                        Amount = (Amount - 20).setScale(2);
                    } else if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS'){
                        Amount = (Amount - 10).setScale(2);
                    } else {
                        Amount = Amount.setScale(2);
                    }
                }
                PayWrap.MonthlyDraftMap.put(PayWrap.numberOfMonthlyDraft,Amount.setScale(2));
                PayWrap.numberOfMonthlyDraft ++;
            } else if(Payment.nu_dse__Amount__c != null && Payment.nu_dse__Transaction_Status__c != 'Cancelled' && Payment.nu_dse__Payment_Sequence_Number__c == null){
                PayWrap.TotalAdhocPayment += Payment.nu_dse__Amount__c;
                isAdhocPaymentExists = true;
            }
            else {
                PayWrap.MonthlyDraftMap.put(PayWrap.numberOfMonthlyDraft,0.0);
                PayWrap.numberOfMonthlyDraft ++;
            }
            
            
            /*if(Payment.nu_dse__Schedule_Date__c.Day() == Program.nu_dse__Twice_Monthly_Reoccuring_Day__c || (Payment.nu_dse__Schedule_Date__c.Day() == daysInMonth && Program.nu_dse__Twice_Monthly_Reoccuring_Day__c >= daysInMonth)){
                if(Payment.nu_dse__Amount__c != null && Payment.nu_dse__Transaction_Status__c != 'Cancelled'){
                    PayWrap.SecondMonthlyDraft = Payment.nu_dse__Amount__c.setScale(2);
                }
                else {
                    PayWrap.SecondMonthlyDraft = 0.0;
                }
            } 
                /*if(SecondPaymentProcessingDay == null && Payment.nu_dse__Schedule_Date__c != null){
                    if(Program.nu_dse__Processor__r.name == 'GCS' || Program.nu_dse__Processor__r.name == 'CFT'){
                        SecondPaymentProcessingDay = String.valueOf(Payment.nu_dse__Schedule_Date__c.AddDays(7).Day());
                    } else if(Program.nu_dse__Processor__r.name == 'RAMS'){
                        SecondPaymentProcessingDay = String.valueOf(Payment.nu_dse__Schedule_Date__c.AddDays(10).Day());
                    } else {
                        SecondPaymentProcessingDay = String.valueOf(Payment.nu_dse__Schedule_Date__c.Day());
                    }
                }*/
               
                /*if(PaymentProcessingDay == null && Payment.nu_dse__Schedule_Date__c != null){
                    if(SecondPaymentProcessingDay == null && Payment.nu_dse__Schedule_Date__c != null){
                        if(Program.nu_dse__Processor__r.name == 'GCS' || Program.nu_dse__Processor__r.name == 'CFT'){
                            PaymentProcessingDay = String.valueOf(Payment.nu_dse__Schedule_Date__c.AddDays(7).Day());
                        } else if(Program.nu_dse__Processor__r.name == 'RAMS'){
                            PaymentProcessingDay = String.valueOf(Payment.nu_dse__Schedule_Date__c.AddDays(10).Day());
                        } else {
                            PaymentProcessingDay = String.valueOf(Payment.nu_dse__Schedule_Date__c.Day());
                        }
                    }
                }*/
          /*   if(Payment.nu_dse__Schedule_Date__c.Day() == Program.nu_dse__Reoccurring_Debit_Day__c || (Payment.nu_dse__Schedule_Date__c.Day() == daysInMonth && Program.nu_dse__Reoccurring_Debit_Day__c >= daysInMonth)){ 
                if(Payment.nu_dse__Amount__c != null && Payment.nu_dse__Transaction_Status__c != 'Cancelled'){
                    if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'GCS' || Program.nu_dse__Processor__r.nu_dse__Type__c == 'CFT'){
                        PayWrap.MonthlyDraft = (Payment.nu_dse__Amount__c - 20).setScale(2);
                    } else if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS'){
                        PayWrap.MonthlyDraft = (Payment.nu_dse__Amount__c - 10).setScale(2);
                    } else {
                        PayWrap.MonthlyDraft = Payment.nu_dse__Amount__c.setScale(2);
                    }
                } else {
                    PayWrap.MonthlyDraft = 0.0;
                }
            } else {
                error = true;
            }
            */
            if(!numberOfMonthlyDraft.contains(PayWrap.numberOfMonthlyDraft - 1) && PayWrap.numberOfMonthlyDraft > 0){
                numberOfMonthlyDraft.add(PayWrap.numberOfMonthlyDraft - 1);
            }
            
            if(error){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'There are some payments having scheduled date different than First Debit Day or Twice Monthly Debit Day'));
            }
            PaymentWrapperMap.put(monthOfTheYear,PayWrap);
            PaymentWrapperDateMap.put(Date.newInstance(Payment.nu_dse__Schedule_Date__c.Year(),Payment.nu_dse__Schedule_Date__c.month(),1),PayWrap);
            
        }
        
        System.debug(PaymentWrapperDateMap);
        
        Id SettlementRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        Id FeeRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
       // List<String> StatusList = new List<String>{'In-House Attorney Approved','Accepted','To Payment Processing','Payment Plan - Active'};
        List<String> StatusList = new List<String>{'Payment Plan Active','Payment Plan - Active'};
        
            List<nu_dse__Offer__c> OfferList = [Select Id,Source_of_Payment__c, Name, nu_dse__Status__c, nu_dse__TradeLine__r.Name,nu_dse__TradeLine__r.nu_dse__Current_Stage__c, (Select Id, Name, nu_dse__Transaction_Status__c, nu_dse__Total_Amount__c,nu_dse__Amount__c, nu_dse__Schedule_Date__c,RecordTypeId from nu_dse__Payments__r where (RecordTypeId =: SettlementRecordType OR RecordTypeId =: FeeRecordType) AND nu_dse__Schedule_Date__c >=: System.Today() ORDER BY nu_dse__Schedule_Date__c) from nu_dse__Offer__c where nu_dse__Program__c =:ProgramId AND nu_dse__TradeLine__r.nu_dse__Current_Stage__c =: StatusList AND Latest_Offer__c = true];
        
        System.debug('Offer List '+OfferList);
        for(nu_dse__Offer__c Offer:OfferList){
            if(Offer.nu_dse__Payments__r != null && !Offer.nu_dse__Payments__r.isEmpty()){
                OfferNames.add(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c);
                if(!OfferNamesMap.containsKey(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c)){
                    List<String> headers = new List<String>();
                    headers.add(Offer.nu_dse__TradeLine__r.Name);
                    headers.add(Offer.Name);
                    headers.add(Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c);
                    //headers.add(Offer.Source_Of_Payment__c);
                    OfferNamesMap.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,headers);
                    if(Offer.Source_Of_Payment__c != null)
                        OfferSourceMap.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,Offer.Source_Of_Payment__c);
                    else
                        OfferSourceMap.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,'');
                }
                System.debug(Offer.nu_dse__Payments__r);
                for(nu_dse__Payment__c Payment:Offer.nu_dse__Payments__r){
                    PaymentWrapper PayWrap;
                    if(Payment.RecordTypeId == SettlementRecordType){
                        DateTime t = Datetime.newInstance(Payment.nu_dse__Schedule_Date__c,System.now().time());
                        String month = t.format('MMM');
                        String monthOfTheYear = month + ', ' + String.valueOf(t.Year()).right(2);
                        System.debug(monthOftheYear);
                        if(PaymentWrapperMap.containsKey(monthOfTheYear)){
                            PayWrap = PaymentWrapperMap.get(monthOfTheYear);
                        } else {
                            PayWrap = new PaymentWrapper(parentClass);
                            PayWrap.month = monthOfTheYear;
                        }
                        if(PayWrap.SettlementOfferAmounts == null){ 
                            PayWrap.SettlementOfferAmounts = new Map<String,Double>();
                        }
                        if(Payment.nu_dse__Amount__c != null && Payment.nu_dse__Transaction_Status__c != 'Cancelled'){
                            if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'GCS' || Program.nu_dse__Processor__r.nu_dse__Type__c == 'CFT'){
                                PayWrap.SettlementOfferAmounts.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,Payment.nu_dse__Amount__c + 14.95);
                            } else if(Program.nu_dse__Processor__r.nu_dse__Type__c == 'RAMS'){
                                PayWrap.SettlementOfferAmounts.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,Payment.nu_dse__Amount__c + 10);
                            } else {
                                PayWrap.SettlementOfferAmounts.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,Payment.nu_dse__Amount__c);
                            }
                        } else {
                            PayWrap.SettlementOfferAmounts.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,0.0);
                        }
                    } else if(Payment.RecordTypeId == FeeRecordType){
                        DateTime t = Datetime.newInstance(Payment.nu_dse__Schedule_Date__c,System.now().time());
                        String month = t.format('MMM');
                        String monthOfTheYear = month + ', ' + String.valueOf(t.Year()).right(2);
                        System.debug(monthOftheYear);
                        if(PaymentWrapperMap.containsKey(monthOfTheYear)){
                            PayWrap = PaymentWrapperMap.get(monthOfTheYear);
                        } else {
                            PayWrap = new PaymentWrapper(parentClass);
                            PayWrap.month = monthOfTheYear;
                        }
                        if(PayWrap.FeeOfferAmounts == null){ 
                            PayWrap.FeeOfferAmounts = new Map<String,Double>();
                        }
                        if(Payment.nu_dse__Amount__c != null && Payment.nu_dse__Transaction_Status__c != 'Cancelled'){
                            PayWrap.FeeOfferAmounts.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,Payment.nu_dse__Amount__c);
                        } else {
                            PayWrap.FeeOfferAmounts.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,0.0);
                        }
                        
                        if(!FeeOfferNamesMap.containsKey(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c)){
                            List<String> headers = new List<String>();
                            headers.add(Offer.nu_dse__TradeLine__r.Name);
                            headers.add(Offer.Name);
                            headers.add(Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c);
                            //headers.add(Offer.Source_Of_Payment__c);
                            if(Payment.RecordTypeId == FeeRecordType){
                                FeeOfferNamesMap.put(Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c,headers);
                                FeeKeyValues += Offer.nu_dse__TradeLine__r.Name+'\n'+ Offer.name +'\n'+Offer.nu_dse__TradeLine__r.nu_dse__Current_Stage__c +',';
                            }
                        } 
                    }  
                    
                    System.debug(PayWrap.SettlementOfferAmounts);
                    PaymentWrapperMap.put(PayWrap.month,PayWrap);
                    PaymentWrapperDateMap.put(Date.newInstance(Payment.nu_dse__Schedule_Date__c.Year(),Payment.nu_dse__Schedule_Date__c.month(),1),PayWrap);
                    
                } 
            }   
        }
        PaymentWrapperList.addAll(ProgramPaymentsExportController.getSortedMap(PaymentWrapperDateMap));
        
        System.debug(FeeOfferNamesMap);
        
        getData();
        
    }
    
    public static List<PaymentWrapper> getSortedMap(Map<Date,PaymentWrapper> PaymentWrapperMap){
        
        Set<Date> MapKeys = PaymentWrapperMap.keySet();
        List<Date> MapKeyList = new List<Date>(MapKeys);
        MapKeyList.sort();
        List<PaymentWrapper> PaymentWrapperSortedList = new List<PaymentWrapper>();
        for(Date d: MapKeyList){
            PaymentWrapperSortedList.add(PaymentWrapperMap.get(d));
        }
        
        return PaymentWrapperSortedList;
    }
   public PageReference refresh() {    
    PageReference pg = new PageReference('/apex/ProgramPaymentsExport');
    pg.setRedirect(true);
    return pg;
}
    public class paymentWrapper{
        
        public Integer numberOfMonthlyDraft{get;set;}
        public Map<Integer,Decimal> MonthlyDraftMap{get;set;}
        public String Month{get;set;}
        public Double MonthlyDraft{get;set;}
        public Double SecondMonthlyDraft{get;set;}
        public Double AdditionalDaft{get;set;}
        public Double NewSettlement{get;set;}
        List<Double> SettlementAmounts{get;set;}
        public Decimal TotalAdhocPayment{get;set;}
        public Map<String, Double> SettlementOfferAmounts{get;set;}
        public Map<String, Double> FeeOfferAmounts{get;set;}
        public Decimal RunningBalance;
        public Decimal AvailableFunds;
        public String keyValues;
        public String FeeKeyValues;
        public ProgramPaymentsExportController contr;
        //Double
        
        public paymentWrapper(ProgramPaymentsExportController contr){
            this.contr = contr;
            MonthlyDraftMap = new Map<Integer,Decimal>();
            numberOfMonthlyDraft = 0;
        }
        
        public Decimal getRunningBalance(){
            Decimal Balance; 
            
            if(FinalRunningBalance != null)
                Balance = FinalRunningBalance;
            else
                Balance = 0;
            
            /*if(MonthlyDraft != null)
            Balance += MonthlyDraft; 
            
            if(SecondMonthlyDraft != null)
            Balance += SecondMonthlyDraft;*/
            
            for(Decimal draft:MonthlyDraftMap.values()){
                if(draft != null){
                    Balance += Draft;
                }
            }
            
            if(totalAdhocPayment != null){
                Balance += totalAdhocPayment;
            }
            
            if(AdditionalDaft != null)
            Balance += AdditionalDaft;
            
            if(NewSettlement != null)
            Balance -= NewSettlement;
            
            if(SettlementOfferAmounts != null){
                for(Double settlements: SettlementOfferAmounts.values()){
                    
                    Balance -= settlements;
                }
            }
            
            if(FeeOfferAmounts != null){
                for(Double fees: FeeOfferAmounts.values()){
                    
                    Balance -= fees;
                }
            }
            
            FinalRunningBalance = Balance;
            //contr.getData();
            return Balance.setScale(2);
        }
        
        public Decimal getAvailableFunds(){
            Decimal Balance = 0;
            
            /*if(MonthlyDraft != null)
            Balance += MonthlyDraft; 
            
            if(SecondMonthlyDraft != null)
            Balance += SecondMonthlyDraft;*/
            
            for(Decimal draft:MonthlyDraftMap.values()){
                if(draft != null){
                    Balance += Draft;
                }
            }
            
            if(totalAdhocPayment != null){
                Balance += totalAdhocPayment;
            }
            
            if(AdditionalDaft != null)
            Balance += AdditionalDaft;
            
            if(NewSettlement != null)
            Balance -= NewSettlement;
            
            if(SettlementOfferAmounts != null){
                for(Double settlements: SettlementOfferAmounts.values()){
                    
                    Balance -= settlements;
                }
            }
            
            if(FeeOfferAmounts != null){
                for(Double fees: FeeOfferAmounts.values()){
                    
                    Balance -= fees;
                }
            }
            //contr.getData();
            return Balance.setScale(2);
        }
        
        public String getKeyValues(){
            String keyValues = '';
            if(SettlementOfferAmounts != null)
            keyValues = String.join(new List<String>(SettlementOfferAmounts.keyset()), ',');
            
            return keyValues;
        }
        
        public String getFeeKeyValues(){
            String FeekeyValues = '';
            if(FeeOfferAmounts != null)
            FeekeyValues = String.join(new List<String>(FeeOfferAmounts.keyset()), ',');
            
            return FeekeyValues;
        }
    }
    
    public pageReference additionalDraft(){
        System.debug(changedMonth);
        FinalRunningBalance = Program.nu_dse__Trust_Account_Balance__c;
        //PaymentWrapper PayWrap = PaymentWrapperMap.get(changedMonth);
        //PayWrap.
        getData();
        return null;
    }
    
    //@RemoteAction
    public void getData(){
        FinalRunningBalance = Program.nu_dse__Trust_Account_Balance__c;
        String file = '';
        file = 'Month,';
        
        for(Integer i=0; i<numberOfMonthlyDraft.size(); i++){
            file += 'Monthly Draft ' + (i+1) +',';
        }
        
        if(isAdhocPaymentExists)
            file += 'Adhoc Payments,';
        
        file += 'Additional Draft,New Settlement,';
        
        if(!offerNames.isEmpty()){
            for(String OfferName: OfferNames){
                String OfferName1 = OfferName + '\n'+OfferSourceMap.get(OfferName);
                file += OfferName1.escapeCSV() + ',';
                
                System.debug(FeeOfferNamesMap);
                if(FeeOfferNamesMap.containsKey(Offername)){
                    System.debug('FeeName');
                    String FeeName = OfferName+ '\n' +'Fee';
                    file += FeeName.escapeCSV() + ',';
                }
            }
        }
        
        file +='Running Balance,Funds Available from Monthly Draft';
        
        List<String> fileLines = new List<String>();
        fileLines.add(file);
        
        Decimal FinalBalance = Program.nu_dse__Trust_Account_Balance__c;
        for(PaymentWrapper PayWrap: PaymentWrapperList){
            String fileLine = PayWrap.month.escapeCSV();
            //if(PayWrap.MonthlyDraft != null)
            //    fileLine += ',' + PayWrap.MonthlyDraft;
            //if(PayWrap.SecondMonthlyDraft != null)
            //fileLine += ',' + PayWrap.SecondMonthlyDraft;
            
            for(Integer key: PayWrap.MonthlyDraftMap.keySet()){
                fileLine += ',' + PayWrap.MonthlyDraftMap.get(key);
            }
            System.debug(PayWrap.MonthlyDraftMap.size());
            if(PayWrap.MonthlyDraftMap != null && PayWrap.MonthlyDraftMap.size()<numberOfMonthlyDraft.size()){
                System.debug('here');
                for(integer i=PayWrap.MonthlyDraftMap.size();i<numberOfMonthlyDraft.size();i++){
                    fileLine += ',';
                    System.debug('here 1');
                }
            }
            
            if(isAdhocPaymentExists){
                fileLine +=','+PayWrap.totalAdhocPayment;
            } else {
               // fileLine += ',';
                
                System.debug('here 2');
            }
            
            fileLine += ',' + PayWrap.AdditionalDaft;
            fileLine += ',' + PayWrap.NewSettlement;
            for(String offerName: OfferNames){
                fileLine += ',';
                if(PayWrap.SettlementOfferAmounts != null && PayWrap.SettlementOfferAmounts.containsKey(offerName)){
                     fileLine += PayWrap.SettlementOfferAmounts.get(offerName);
                }
                if(PayWrap.FeeOfferAmounts != null && PayWrap.FeeOfferAmounts.containsKey(offerName)){
                     fileLine += ','+PayWrap.FeeOfferAmounts.get(offerName);
                } else if((PayWrap.FeeOfferAmounts == null || PayWrap.FeeOfferAmounts.isEmpty() || (!PayWrap.FeeOfferAmounts.containsKey(offerName) && FeeOfferNamesMap.containsKey(Offername)))  && FeeOfferNamesMap.containsKey(offerName)){
                    fileLine += ',';
                }
            }
            
            Decimal RunningBalance;
            if(FinalBalance != null)
            RunningBalance = FinalBalance;
            else
            RunningBalance = 0;
            Decimal AvailableFunds = 0;
            
            /*if(PayWrap.MonthlyDraft != null)
            RunningBalance += PayWrap.MonthlyDraft; 
            
            if(PayWrap.SecondMonthlyDraft != null)
            RunningBalance += PayWrap.SecondMonthlyDraft;*/
            if(PayWrap.MonthlyDraftMap != null){
                for(Decimal draft:PayWrap.MonthlyDraftMap.values()){
                    if(draft != null){
                        RunningBalance += Draft;
                    }
                }
            }
            
            if(PayWrap.TotalAdhocPayment != null){
                RunningBalance += PayWrap.TotalAdhocPayment;
            }
            
            if(PayWrap.AdditionalDaft != null)
            RunningBalance += PayWrap.AdditionalDaft;
            
            if(PayWrap.NewSettlement != null)
            RunningBalance -= PayWrap.NewSettlement;
            
            if(PayWrap.SettlementOfferAmounts != null){
                for(Double settlements: PayWrap.SettlementOfferAmounts.values()){
                    
                    RunningBalance -= settlements;
                }
            }
            
            if(PayWrap.FeeOfferAmounts != null){
                for(Double fees: PayWrap.FeeOfferAmounts.values()){
                    
                    RunningBalance -= fees;
                }
            }
            
            fileLine += ',' + RunningBalance;
            if(FinalBalance != null)
            fileLine += ',' + (RunningBalance - FinalBalance);
            else
            fileLine += ',' + RunningBalance;
            fileLines.add(fileLine);
            FinalBalance = RunningBalance;
        }
        
        file += String.join(fileLines,'\n');
        System.debug(file);
        CSVdata = filelines;
        data = JSON.serialize(fileLines);
        //return null;
    }
     
    public PageReference Cancel(){
        return new PageReference('/'+Program.Id + '?nooverride=1');
    }
    
    public static void copyAttorney(){
        String toAddress = ProgramPaymentsExportController.emailAddress;
        String labeltest = 'abc';/// label.EscrowSheetDomian;
        
        System.debug('Email --> '+toAddress);
        String url = 'http://';
     //   Site site = [SELECT GuestUserId, Name,MasterLabel, Subdomain, UrlPathPrefix FROM Site WHERE Name = 'EscrowSheetShare'];
       // System.debug('Site'+site);
        Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization];
        System.debug('org'+org);
        
    //  ProgramPaymentsExportController.sfurll = labeltest + 'stratfs.' + org.InstanceName.toLowerCase() + '.force.com';  
      //  ProgramPaymentsExportController.Returnid = ApexPages.currentPage().getParameters().get('id');
        if(org.InstanceName == 'CS42' || org.InstanceName == 'CS27'){
            //String labeltest = label.EscrowSheetDomian;
            url += labeltest + 'stratfs.' + org.InstanceName.toLowerCase() + '.force.com/ProgramPaymentsExport?id=' + ApexPages.currentPage().getParameters().get('id');
        }else{
            url += 'stratfs.' + org.InstanceName.toLowerCase() + '.force.com/ProgramPaymentsExport?id=' + ApexPages.currentPage().getParameters().get('id');
        } 
        System.debug('url'+url);
           
        
       
         
        // TO Send mail to Attorney
        /*
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses =(new String[]{''});
        message.optOutPolicy = 'FILTER';
        message.subject = 'Subject Test Message';
        message.plainTextBody = 'This is the message body.';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
      */
      
    }
  //  public static void doInIt(){
    //    System.debug('Inside doinit');
      //  String labelSite = Label.EscrowSheetDomianForSite;
       // String labelNotForSite = Label.EscrowSheetDomainNotForSite;
        //String profileName =[Select Id, Name from Profile where Id=:UserInfo.getProfileId()].Name;
        //System.debug('Profile Name  '+profileName);
        
        //if(profileName == 'EscrowSheetShare Profile' ){
          //  ProgramPaymentsExportController.url = labelSite + ApexPages.currentPage().getParameters().get('id');
        //}else{
          //  ProgramPaymentsExportController.url = labelNotForSite + ApexPages.currentPage().getParameters().get('id');
       // }
        
       // Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization];
        //Id profileId = UserInfo.getProfileId();
        
        //String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
       //  if((org.InstanceName == 'CS42' || org.InstanceName == 'CS27') && profileName == 'EscrowSheetShare Profile' ){
        //  ProgramPaymentsExportController.url = 'https://' + labeltest + 'stratfs.' + org.InstanceName.toLowerCase() + '.force.com/ProgramPaymentsExport?id=' + ApexPages.currentPage().getParameters().get('id');
     //   }else if(profileName == 'EscrowSheetShare Profile' && org.InstanceName != 'CS42' && org.InstanceName != 'CS27'){
        //  ProgramPaymentsExportController.url = 'stratfs.' + org.InstanceName.toLowerCase() + '.force.com/ProgramPaymentsExport?id=' + ApexPages.currentPage().getParameters().get('id');
      //  }else if(profileName != 'EscrowSheetShare Profile'){
           // ProgramPaymentsExportController.url = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/ProgramPaymentsExport?id='+ ApexPages.currentPage().getParameters().get('id');
            
        //}
                    
    //}
    
   
    
}