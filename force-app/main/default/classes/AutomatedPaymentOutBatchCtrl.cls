/**
* Name         :       AutomatedPaymentOutBatchCtrl
* Date         :       10/03/2019
* Author       :       Amit Goyal
* Description  :       Created for S20-396
*/
global class AutomatedPaymentOutBatchCtrl implements Database.Batchable<sObject>{
    public Decimal processorTransactionalFee=0;
    public Decimal processorTransactionalFeeRam=0;
    public SFDC_AIMMS_Config__mdt config = new SFDC_AIMMS_Config__mdt();
    list<String> currentStages = new list<String>();
    public AutomatedPaymentOutBatchCtrl(){
        list<SFDC_AIMMS_Config__mdt> configs = [Select Id, MasterLabel, Current_Stage__c, Portfolio_Name__c, Program_Names__c,
                                                Record_Type__c, Status__c, Apply_Schedule_Date_Flag__c, Apply_LastModifiedDate_Flag__c, 
                                                Processor_Transactional_Fee__c,processor_Transactional_Fee_RAM__c From SFDC_AIMMS_Config__mdt 
                                                Where MasterLabel = 'Payments Out'];
        system.debug('### configs: '+configs.size());
        if(configs != null && configs.size()>0){
            config=configs[0];
            if(config.Current_Stage__c != null && config.Current_Stage__c.trim().length()>0){
                currentStages = config.Current_Stage__c.split(',');
            }
            system.debug('### currentStages: '+currentStages.size());
            
            if(config.Processor_Transactional_Fee__c != null){
                processorTransactionalFee=Double.valueOf(config.Processor_Transactional_Fee__c);
            }
            if(config.processor_Transactional_Fee_RAM__c != null){
                processorTransactionalFeeRam=Double.valueOf(config.processor_Transactional_Fee_RAM__c);
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('### Batch Start');
        /*list<SFDC_AIMMS_Config__mdt> configs = [Select Id, MasterLabel, Current_Stage__c, Portfolio_Name__c, Program_Names__c,
Record_Type__c, Status__c, Apply_Schedule_Date_Flag__c, Apply_LastModifiedDate_Flag__c, 
Processor_Transactional_Fee__c From SFDC_AIMMS_Config__mdt 
Where MasterLabel = 'Payments Out'];
system.debug('### configs: '+configs.size());*/
        //if(configs != null && configs.size()>0){
        /*config=configs[0];
if(config.Processor_Transactional_Fee__c != null){
processorTransactionalFee=Double.valueOf(config.Processor_Transactional_Fee__c);
}*/
        if(config != null){
            list<String> programNames = new list<String>();
            list<String> statuses = new list<String>();
            list<String> portfolioNames = new list<String>();
            
            if(config.Status__c != null && config.Status__c.trim().length()>0){
                statuses = config.Status__c.split(',');
            }
            system.debug('### statuses: '+statuses.size());
            if(config.Portfolio_Name__c != null && config.Portfolio_Name__c.trim().length()>0){
                portfolioNames = config.Portfolio_Name__c.split(',');
            }
            system.debug('### portfolioNames: '+portfolioNames.size());
            
            if(config.Program_Names__c != null && config.Program_Names__c.trim().length()>0){
                if(config.Program_Names__c.contains(',')){
                    programNames = config.Program_Names__c.split(',');
                }else{
                    programNames.add(config.Program_Names__c);
                }
            }
            system.debug('### programNames: '+programNames.size());
            String soqlStr = 'Select Id, Name, nu_dse__Program_Status__c, Portfolio_Name__c,';
            soqlStr += ' nu_dse__Processor__c, nu_dse__Processor__r.Name';
            soqlStr += ' From nu_dse__Program__c';
            soqlStr += ' Where nu_dse__Program_Status__c IN: statuses';
            soqlStr += ' AND Portfolio_Name__c IN: portfolioNames';
            
            if(programNames != null && programNames.size()>0){
                soqlStr += ' AND Name IN: programNames';
                
            }
             system.debug('### soqlStr: '+soqlStr);
            return Database.getQueryLocator(soqlStr);
        }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope)
    {
        system.debug('### scope: '+scope.size());
        Map<String, Integer> pmtCountToScheduleDateMap = new Map<String, Integer> () ;
        map<String, map<Date, list<nu_dse__Payment__c>>> offerPaymentsMap = new map<String, map<Date, list<nu_dse__Payment__c>>>();
        if(scope != null && scope.size()>0){
            set<String> programIds = new set<String>();
            for(nu_dse__Program__c prog: scope){
                programIds.add(prog.Id);
            }
            
            Id settlementRTId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Payment__c','Settlement');
            Id FeeRTId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Payment__c','Fee');
            Date todayStr=System.Today();
            DateTime paymentTime = System.Now().addHours(-24);
            
            String soqlPaymentStr='Select Id, Name, nu_dse__Offer__c, nu_dse__Schedule_Date__c,';
            soqlPaymentStr+=' nu_dse__Amount__c,Latest_Offer__c,Source_of_Payment__c,nu_dse__Payment_Type__c,RecordType.Name, nu_dse__Program__c, nu_dse__Program__r.Name, Current_Stage__c';
            soqlPaymentStr+=' From nu_dse__Payment__c';
            soqlPaymentStr+=' Where nu_dse__Program__c IN: programIds';
            soqlPaymentStr+=' AND ((RecordTypeId=:settlementRTId AND Current_Stage__c NOT IN: currentStages AND nu_dse__Offer__r.Latest_Offer__c = true ) OR ( RecordTypeId=:FeeRTId AND nu_dse__Payment_Type__c = \'Fee Withdrawal\') )';
            soqlPaymentStr+=' AND nu_dse__Transaction_Status__c != \'Cancelled\'';
            // soqlPaymentStr+=' AND Current_Stage__c NOT IN: currentStages';
            // soqlPaymentStr+=' AND nu_dse__Offer__r.Latest_Offer__c = true';
            if(config.Apply_Schedule_Date_Flag__c == true && config.Apply_LastModifiedDate_Flag__c == true){
                soqlPaymentStr += ' AND (nu_dse__Schedule_Date__c >=: todayStr OR (nu_dse__Schedule_Date__c >=: todayStr AND LastModifiedDate >=: paymentTime))';
            }
            if(config.Apply_Schedule_Date_Flag__c == true && config.Apply_LastModifiedDate_Flag__c == false){
                soqlPaymentStr += ' AND nu_dse__Schedule_Date__c >=: todayStr';
            }
            if(config.Apply_Schedule_Date_Flag__c == false && config.Apply_LastModifiedDate_Flag__c == true){
                soqlPaymentStr += ' AND LastModifiedDate >=: paymentTime';
            }
            soqlPaymentStr+=' Order By nu_dse__Schedule_Date__c';
            system.debug('### soqlPaymentStr: '+soqlPaymentStr);
            list<nu_dse__Payment__c> pList=Database.Query(soqlPaymentStr);
            system.debug('### pList: '+pList.size());
            for(nu_dse__Payment__c p: pList){
                map<Date, list<nu_dse__Payment__c>> result=offerPaymentsMap.get(p.nu_dse__Program__c);
                if(result==null){
                    result=new map<Date, list<nu_dse__Payment__c>>();
                }
                
                if(p.nu_dse__Schedule_Date__c != null){
                    if(result.containsKey(p.nu_dse__Schedule_Date__c)){
                        list<nu_dse__Payment__c> result1 = result.get(p.nu_dse__Schedule_Date__c);
                        result1.add(p);
                        result.put(p.nu_dse__Schedule_Date__c, result1);
                    }else{
                        result.put(p.nu_dse__Schedule_Date__c, new list<nu_dse__Payment__c>{p});
                    }
                }
                offerPaymentsMap.put(p.nu_dse__Program__c, result);
                system.debug(p.RecordType.name);   
                Integer pmtCountDec = 1 ;
                system.debug(pmtCountDec+'Beforesumit'+p.nu_dse__Schedule_Date__c+'recordtype'+p.RecordType.name);
                if(pmtCountToScheduleDateMap.get(string.valueof(p.nu_dse__Schedule_Date__c)+p.nu_dse__Program__c+p.RecordType.name) != null) {
                    pmtCountDec += pmtCountToScheduleDateMap.get(string.valueof(p.nu_dse__Schedule_Date__c)+p.nu_dse__Program__c+p.RecordType.name) ;
                }
                pmtCountToScheduleDateMap.put(string.valueof(p.nu_dse__Schedule_Date__c)+p.nu_dse__Program__c+p.RecordType.name,pmtCountDec)  ;
                system.debug(pmtCountDec+'aftersumit'+p.nu_dse__Schedule_Date__c+'record type '+p.RecordType.name);
            }
            
            
            system.debug('### offerPaymentsMap: '+offerPaymentsMap.size());
            list<ProgramPaymentModal> ppmList = new list<ProgramPaymentModal>();
            map<Id, Program_Payment_Out_In__c> ppSettlementMap = new map<Id, Program_Payment_Out_In__c>();
            set<Date> scheduleDates = new set<Date>();
            
            // Process the payments with programs
            for(nu_dse__Program__c prog: scope){
                if(offerPaymentsMap.containsKey(prog.Id)){
                    
                    map<Date, list<nu_dse__Payment__c>> offerPayments = offerPaymentsMap.get(prog.Id);
                    system.debug('### offerPayments: '+offerPayments.size());
                    
                    if(offerPayments != null && offerPayments.size()>0){
                        for(Date sd: offerPayments.keyset()){
                            Decimal setAmount = 0;
                            Decimal feeAmount = 0;
                            String paymenttype;
                            Boolean latestoffer = false;
                            set<string> recordtype = new set<string>();
                            string sourceofpayment;
                            list<nu_dse__Payment__c> pmts = offerPayments.get(sd);
                            Map <String,Decimal> recAmount = new  Map <String,Decimal>();
                            Map <String,String> distRecordType = new  Map <String,string>();
                            for(nu_dse__Payment__c p: pmts){
                                if(p.nu_dse__Amount__c != null ){
                                    if(recAmount.get(string.valueof(sd)+prog.id+p.RecordType.name) !=null && p.RecordType.name == 'Fee' ){
                                        feeAmount = recAmount.get(string.valueof(sd)+prog.id+p.RecordType.name);
                                    }
                                     if(recAmount.get(string.valueof(sd)+prog.id+p.RecordType.name) !=null && p.RecordType.name != 'Fee'){
                                        setAmount = recAmount.get(string.valueof(sd)+prog.id+p.RecordType.name);
                                    }
                                    
                                    if(p.RecordType.name == 'Fee'){
                                        
                                        feeAmount+=p.nu_dse__Amount__c;
                                        recAmount.put(string.valueof(sd)+prog.id+p.RecordType.name,feeAmount);
                                    }else{
                                        setAmount+=p.nu_dse__Amount__c;
                                        recAmount.put(string.valueof(sd)+prog.id+p.RecordType.name,setAmount);
                                    }
                                    
                                    
                                    system.debug('after'+recAmount);
                                    paymenttype=p.nu_dse__Payment_Type__c;
                                    recordtype.add(p.RecordType.Name);
                                    distRecordType.put(string.valueof(sd)+prog.id+p.RecordType.name,p.RecordType.name);
                                    latestoffer=p.Latest_Offer__c;
                                    sourceofpayment=p.Source_of_Payment__c;
                                    system.debug('after'+recordtype);
                                }
                            }
                            scheduleDates.add(sd);
                            for(string drectyp : recordtype)
                            {
                                Integer pmtCnt = (pmtCountToScheduleDateMap.get(string.valueof(sd)+prog.id+drectyp) != null) ? pmtCountToScheduleDateMap.get(string.valueof(sd)+prog.id+drectyp) : pmts.size() ;
                                decimal amt = (recAmount.get(string.valueof(sd)+prog.id+drectyp) != null ) ? recAmount.get(string.valueof(sd)+prog.id+drectyp) : 0 ; 
                                system.debug(pmtCnt+'sumit'+sd+'record type'+drectyp);
                                system.debug('check all values'+prog.Id+'->'+prog.Name+'->'+prog.nu_dse__Processor__r.Name+'->'+sd+'->'+amt.setScale(2)+'->'+pmtCnt+'->'+processorTransactionalFee+'->'+paymenttype+'->'+latestoffer+'->'+drectyp+'->'+sourceofpayment);
                                ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, prog.nu_dse__Processor__r.Name, sd, amt.setScale(2), pmtCnt , processorTransactionalFee,processorTransactionalFeeRam,paymenttype,latestoffer,drectyp,sourceofpayment));
                                
                            }
                        }
                    }
                }else{
                    //ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, null, 0));
                }
            }
            
            system.debug('### ppmList: '+ppmList.size());
            if(ppmList != null && ppmList.size()>0){
                // Store data in Program_Payment_Out_In__c object
                Id ppOutRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Settlement');
                Id feesOutRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Fee');
                list<Program_Payment_Out_In__c> ppSettlementList = new list<Program_Payment_Out_In__c>();
                map<String, Program_Payment_Out_In__c> ppoMap = new map<String, Program_Payment_Out_In__c>();
                map<String, decimal> CountPmt = new map<String, decimal>();
                
                list<Program_Payment_Out_In__c> ppoList = [Select Id, Name, PROGRAM_UUID__c, SCHEDULED_DATE__c,PMT_Count__c From Program_Payment_Out_In__c 
                                                           Where PROGRAM_UUID__c IN: programIds];
                // AND SCHEDULED_DATE__c IN: scheduleDates
                if(ppoList != null && ppoList.size()>0){
                    for(Program_Payment_Out_In__c ppo: ppoList){
                        system.debug('ppo data'+ppo);
                        if(ppo.SCHEDULED_DATE__c!=null){
                            if(CountPmt.containskey(ppo.PROGRAM_UUID__c+'~'+ppo.SCHEDULED_DATE__c))
                            {
                                decimal count = CountPmt.get(ppo.PROGRAM_UUID__c+'~'+ppo.SCHEDULED_DATE__c);
                                count += ppo.PMT_COUNT__c;
                                CountPmt.put(ppo.PROGRAM_UUID__c+'~'+ppo.SCHEDULED_DATE__c,count);
                            }else{
                                CountPmt.put(ppo.PROGRAM_UUID__c+'~'+ppo.SCHEDULED_DATE__c,ppo.PMT_Count__c);
                            }
                            ppoMap.put(ppo.PROGRAM_UUID__c+'~'+ppo.SCHEDULED_DATE__c, ppo);
                        }
                    }
                }
                
                
                for(ProgramPaymentModal ppm: ppmList){
                    if(!ppoMap.containsKey(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE)){
                        System.debug('program to be run while update'+ppm.PROGRAM_UUID);
                        
                        //   decimal cntpmt = (CountPmt.get(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE) != null)? CountPmt.get(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE):ppm.PMT_COUNT;
                        string outRecId = (ppm.recordtype == 'Fee')?feesOutRTId:ppOutRTId;
                        system.debug('recordid'+ppm.recordtype);
                        system.debug('programe name'+ppm.PROGRAM_NUM);
                        ppSettlementList.add(new Program_Payment_Out_In__c(RecordTypeId=outRecId,
                                                                           PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                           PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                           PMT_PROCESSOR__c=ppm.PMT_PROCESSOR,
                                                                           SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                           AMOUNT__c=ppm.AMOUNT,
                                                                           PMT_COUNT__c=ppm.PMT_COUNT,
                                                                           FINAL_AMOUNT__c=ppm.FINAL_AMOUNT,
                                                                           Payment_Type__c=ppm.Payment_Type,
                                                                           Latest_Offer__c =ppm.Latest_Offer,
                                                                           Source_of_Payment__c = ppm.sourceofpayment));
                    }else{
                        Program_Payment_Out_In__c resultPPO = ppoMap.get(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE);
                        if(resultPPO != null){
                            //  decimal cntpmt = (CountPmt.get(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE) != null)? CountPmt.get(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE):ppm.PMT_COUNT;
                            string outRecId = (ppm.recordtype == 'Fee')?feesOutRTId:ppOutRTId;
                            system.debug('recordidupdate'+ppm.recordtype);
                            system.debug('program record'+ppm.PROGRAM_NUM);
                            Program_Payment_Out_In__c resultPPO1 = new Program_Payment_Out_In__c(Id=resultPPO.Id, RecordTypeId=outRecId,
                                                                                                 PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                                                 PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                                                 PMT_PROCESSOR__c=ppm.PMT_PROCESSOR,
                                                                                                 SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                                                 AMOUNT__c=ppm.AMOUNT,
                                                                                                 PMT_COUNT__c=ppm.PMT_COUNT,
                                                                                                 FINAL_AMOUNT__c=ppm.FINAL_AMOUNT,
                                                                                                 Payment_Type__c=ppm.Payment_Type,
                                                                                                 Latest_Offer__c=ppm.Latest_Offer,
                                                                                                 Source_of_Payment__c = ppm.sourceofpayment
                                                                                                );
                            ppSettlementMap.put(resultPPO1.Id, resultPPO1);
                            
                        }
                    }
                }
                
                system.debug('### ppSettlementList: '+ppSettlementList.size());
                if(ppSettlementList != null && ppSettlementList.size()>0){
                    upsert ppSettlementList;
                }
                
                if(ppSettlementMap != null && ppSettlementMap.size()>0){
                    update ppSettlementMap.values();
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    // ND-320 Changes made by sumit verma.
    
    public class ProgramPaymentModal{
        public String PROGRAM_UUID;
        public String PROGRAM_NUM;
        public String PMT_PROCESSOR;
        public Date SCHEDULED_DATE;
        public Decimal AMOUNT;
        public Integer PMT_COUNT;
        public Decimal FINAL_AMOUNT;
        public Decimal ProcessorTransactionalFee;
        public Decimal ProcessorTransactionalFeeRam;
        public String Payment_Type;
        public Boolean Latest_Offer;
        public string recordtype;
        public string sourceofpayment;
        public ProgramPaymentModal(String PROGRAM_UUID, String PROGRAM_NUM, String PMT_PROCESSOR, Date SCHEDULED_DATE, Decimal AMOUNT, Integer PMT_COUNT, Decimal processorTransactionalFee ,Decimal processorTransactionalFeeRam,String Payment_Type,Boolean Latest_Offer,string recordtype,string sourceofpayment){
            this.PROGRAM_UUID=PROGRAM_UUID;
            this.PROGRAM_NUM=PROGRAM_NUM;
            this.PMT_PROCESSOR=PMT_PROCESSOR;
            this.SCHEDULED_DATE=SCHEDULED_DATE;
            this.AMOUNT=AMOUNT;
            this.Payment_Type=Payment_Type;
            this.PMT_COUNT=PMT_COUNT;
            this.Latest_Offer=Latest_Offer;
            this.recordtype=recordtype;
            this.sourceofpayment=sourceofpayment;
            Decimal ptfAmount=0;
            Decimal ptfAmountRam=0;
            
            if(processorTransactionalFee != null && processorTransactionalFee == 14.95 ){
                this.ProcessorTransactionalFee=processorTransactionalFee;
                ptfAmount=processorTransactionalFee*PMT_COUNT;
                //AMOUNT= PMT_COUNT*processorTransactionalFee+AMOUNT; 
                System.debug('value of processor GCS/CFT'+this.ProcessorTransactionalFee);
            }
            
            if(processorTransactionalFeeRam != null && processorTransactionalFeeRam == 10.00 ){
                this.ProcessorTransactionalFeeRam=processorTransactionalFeeRam;
                ptfAmountRam=processorTransactionalFeeRam*PMT_COUNT;
                //AMOUNT= PMT_COUNT*processorTransactionalFee+AMOUNT;
                System.debug('value of processor RAM'+this.ProcessorTransactionalFeeRam);
            }
            
            if(AMOUNT != null){
                this.FINAL_AMOUNT=AMOUNT;
            }else{
                this.FINAL_AMOUNT=0;
            }
            System.debug('AMOUNT'+AMOUNT);
            System.debug(' finale AMOUNT'+this.FINAL_AMOUNT);
            if((ptfAmount != null || ptfAmountRam != null) && this.PMT_PROCESSOR != null ){
                
                if(this.PMT_PROCESSOR.contains('GCS') || this.PMT_PROCESSOR.contains('CFT')){
                    
                    System.debug('value of processor '+this.PMT_PROCESSOR);
                    this.FINAL_AMOUNT=this.FINAL_AMOUNT+ptfAmount;
                    system.debug('this.FINAL_AMOUNT'+this.FINAL_AMOUNT);
                }else{
                    System.debug('value of RAM'+this.PMT_PROCESSOR);
                    this.FINAL_AMOUNT=this.FINAL_AMOUNT+ptfAmountRam;
                    system.debug('this.FINAL_AMOUNT'+this.FINAL_AMOUNT);
                    
                }
            }
        }
    }
}