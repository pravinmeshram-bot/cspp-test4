public class AutomatedPaymentOutCtrl {
    public list<ProgramPaymentModal> ppmList {get; set;}
    public list<PaymentCountModal> pcmList {get; set;}
    public AutomatedPaymentOutCtrl(){
        ppmList = new list<ProgramPaymentModal>();
        pcmList = new list<PaymentCountModal>();
        SFDC_AIMMS_Config__mdt config = new SFDC_AIMMS_Config__mdt();
        list<String> currentStages = new list<String>();
        list<SFDC_AIMMS_Config__mdt> configs = [Select Id, MasterLabel, Current_Stage__c, Portfolio_Name__c, Program_Names__c,
                                                Record_Type__c, Status__c, Apply_Schedule_Date_Flag__c, Apply_LastModifiedDate_Flag__c 
                                                From SFDC_AIMMS_Config__mdt 
                                                Where MasterLabel = 'Payments Out'];
        if(configs != null && configs.size()>0){
            config=configs[0];
            
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
            if(config.Current_Stage__c != null && config.Current_Stage__c.trim().length()>0){
                currentStages = config.Current_Stage__c.split(',');
            }
            system.debug('### currentStages: '+currentStages.size());
            if(config.Program_Names__c != null && config.Program_Names__c.trim().length()>0){
                if(config.Program_Names__c.contains(',')){
                	programNames = config.Program_Names__c.split(',');
                }else{
                    programNames.add(config.Program_Names__c);
                }
            }
            
            system.debug('### programNames: '+programNames.size());
            String soqlStr = 'Select Id, Name, nu_dse__Program_Status__c, Portfolio_Name__c';
            soqlStr += ' From nu_dse__Program__c';
            soqlStr += ' Where nu_dse__Program_Status__c IN: statuses';
            soqlStr += ' AND Portfolio_Name__c IN: portfolioNames';
            if(programNames != null && programNames.size()>0){
                soqlStr += ' AND Name IN: programNames';
            }
            soqlStr += ' limit 100';
            system.debug('### soqlStr: '+soqlStr);
            list<nu_dse__Program__c> progList = Database.Query(soqlStr);
            map<String, map<Date, list<nu_dse__Payment__c>>> offerPaymentsMap = new map<String, map<Date, list<nu_dse__Payment__c>>>();
            set<String> programIds = new set<String>();
            for(nu_dse__Program__c prog: progList){
                programIds.add(prog.Id);
            }
            
            Id settlementRTId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Payment__c','Settlement');
            Date todayStr=System.Today();
            DateTime paymentTime = System.Now().addHours(-24);
            String soqlPaymentStr='Select Id, Name, nu_dse__Offer__c, nu_dse__Schedule_Date__c,';
            soqlPaymentStr+=' nu_dse__Total_Amount__c, nu_dse__Program__c, nu_dse__Program__r.Name, Current_Stage__c';
            soqlPaymentStr+=' From nu_dse__Payment__c';
            soqlPaymentStr+=' Where nu_dse__Program__c IN: programIds';
            soqlPaymentStr+=' AND RecordTypeId=:settlementRTId';
            soqlPaymentStr+=' AND nu_dse__Transaction_Status__c != \'Cancelled\'';
            soqlPaymentStr+=' AND Current_Stage__c NOT IN: currentStages';
            soqlPaymentStr+=' AND nu_dse__Offer__r.Latest_Offer__c = true';
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
            }
            
            system.debug('### offerPaymentsMap: '+offerPaymentsMap.size());
            ppmList = new list<ProgramPaymentModal>();
            map<Id, Program_Payment_Out_In__c> ppSettlementMap = new map<Id, Program_Payment_Out_In__c>();
            set<Date> scheduleDates = new set<Date>();
            map<String, Integer> programPaymentMap = new map<String, Integer>();
            // Process the payments with programs
            for(nu_dse__Program__c prog: progList){
                if(offerPaymentsMap.containsKey(prog.Id)){
                    map<Date, list<nu_dse__Payment__c>> offerPayments = offerPaymentsMap.get(prog.Id);
                    system.debug('### offerPayments: '+offerPayments.size());
                    if(offerPayments != null && offerPayments.size()>0){
                        for(Date sd: offerPayments.keyset()){
                            Decimal amount = 0;
                            list<nu_dse__Payment__c> pmts = offerPayments.get(sd);
                            for(nu_dse__Payment__c p: pmts){
                                if(p.nu_dse__Total_Amount__c != null){
                                    amount+=p.nu_dse__Total_Amount__c;
                                }
                            }
                            scheduleDates.add(sd);
                            Integer pc=programPaymentMap.get(prog.Id+'~'+prog.Name);
                            if(pc==null){
                                pc=0;
                            }
                            pc+=1;
                            programPaymentMap.put(prog.Id+'~'+prog.Name,pc);
                            ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, sd, amount.setScale(2)));
                        }
                    }
                }
            }
            
            /*Id ppOutRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Settlement');
            map<String, Integer> ppoMap = new map<String, Integer>();
            list<Program_Payment_Out_In__c> ppoList = [Select Id, Name, PROGRAM_UUID__c, SCHEDULED_DATE__c From Program_Payment_Out_In__c 
                                                       Where PROGRAM_UUID__c IN: programIds];
            // AND SCHEDULED_DATE__c IN: scheduleDates
            if(ppoList != null && ppoList.size()>0){
                for(Program_Payment_Out_In__c ppo: ppoList){
                    Integer piocount=ppoMap.get(ppo.PROGRAM_UUID__c);
                    if(piocount==null){
                        piocount=0;
                    }
                    piocount+=1;
                    ppoMap.put(ppo.PROGRAM_UUID__c, piocount);
                }
            }*/
            
            for(String key: programPaymentMap.keyset()){
                list<String> vList=key.split('~');
                pcmList.add(new PaymentCountModal(vList[0], vList[1], programPaymentMap.get(key), 0));
                //ppoMap.get(vList[0])
            }
        }
    }
    
    public class PaymentCountModal {
        public String PROGRAM_UUID {get; set;}
        public String PROGRAM_NUM {get; set;}
        public Integer paymentCount {get; set;}
        public Integer progIOCount {get; set;}
        
        public PaymentCountModal(String PROGRAM_UUID, String PROGRAM_NUM, Integer paymentCount, Integer progIOCount){
			this.PROGRAM_UUID=PROGRAM_UUID;
            this.PROGRAM_NUM=PROGRAM_NUM;
            this.paymentCount=paymentCount;
            this.progIOCount=progIOCount;
        }
    }
    
    public class ProgramPaymentModal{
        public String PROGRAM_UUID {get; set;}
        public String PROGRAM_NUM {get; set;}
        public Date SCHEDULED_DATE {get; set;}
        public Decimal AMOUNT {get; set;}
        public ProgramPaymentModal(String PROGRAM_UUID, String PROGRAM_NUM, Date SCHEDULED_DATE, Decimal AMOUNT){
			this.PROGRAM_UUID=PROGRAM_UUID;
            this.PROGRAM_NUM=PROGRAM_NUM;
            this.SCHEDULED_DATE=SCHEDULED_DATE;
            this.AMOUNT=AMOUNT;
        }
    }
}