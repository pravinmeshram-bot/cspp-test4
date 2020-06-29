/**
 * Name      :    AutomatedPaymentInBatchCtrl
 * Date      :    10/03/2019
 * Author    :    Amit Goyal
 * Description  :    Created for S20-397
*/

global class AutomatedPaymentInBatchCtrl  implements Database.Batchable<sObject>{
    SFDC_AIMMS_Config__mdt config = new SFDC_AIMMS_Config__mdt();
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        list<SFDC_AIMMS_Config__mdt> configs = [Select Id, MasterLabel, Current_Stage__c, Portfolio_Name__c, 
                                                Record_Type__c, Status__c, Apply_Schedule_Date_Flag__c, Apply_LastModifiedDate_Flag__c 
                                                From SFDC_AIMMS_Config__mdt 
                                                Where MasterLabel = 'Payments In'];
        if(configs != null && configs.size()>0){
            config=configs[0];
            
            list<String> statuses = new list<String>();
            list<String> portfolioNames = new list<String>();
            
            if(config.Status__c != null && config.Status__c.trim().length()>0){
                statuses = config.Status__c.split(',');
            }
            
            if(config.Portfolio_Name__c != null && config.Portfolio_Name__c.trim().length()>0){
                portfolioNames = config.Portfolio_Name__c.split(',');
            }
            
            
            String soqlStr = 'Select Id, Name, nu_dse__Program_Status__c, Portfolio_Name__c';
            soqlStr += ' From nu_dse__Program__c';
            soqlStr += ' Where nu_dse__Program_Status__c IN: statuses';
            soqlStr += ' AND Portfolio_Name__c IN: portfolioNames';
            soqlStr += ' AND Test_Program__c = false';
            system.debug('### soqlStr: '+soqlStr);
            return Database.getQueryLocator(soqlStr);
        }
        return null;
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Program__c> scope)
    {
        //map<Id, nu_dse__Payment__c> removePayments = new map<Id, nu_dse__Payment__c>();
        map<String, map<Date, list<nu_dse__Payment__c>>> offerPaymentsMap = new map<String, map<Date, list<nu_dse__Payment__c>>>();
        if(scope != null && scope.size()>0){
            set<String> programIds = new set<String>();
            for(nu_dse__Program__c prog: scope){
                programIds.add(prog.Id);
            }
            
            Id draftRTId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Payment__c','Draft');
            Date todayStr=System.Today();
            DateTime paymentTime = System.Now().addHours(-24);
            String soqlPaymentStr='Select Id, Name, nu_dse__Offer__c, nu_dse__Schedule_Date__c,';
            soqlPaymentStr+=' nu_dse__Amount__c,nu_dse__Transaction_Status__c, nu_dse__Program__c, nu_dse__Program__r.Name, Program_Status__c';
            soqlPaymentStr+=' From nu_dse__Payment__c';
            soqlPaymentStr+=' Where nu_dse__Program__c IN: programIds';
            soqlPaymentStr+=' AND RecordTypeId=:draftRTId';
           // soqlPaymentStr+=' AND nu_dse__Transaction_Status__c != \'Cancelled\'';
            if(config.Apply_Schedule_Date_Flag__c == true && config.Apply_LastModifiedDate_Flag__c == true){
                soqlPaymentStr += ' AND (nu_dse__Schedule_Date__c >=: todayStr OR (nu_dse__Schedule_Date__c >=: todayStr AND LastModifiedDate >=: paymentTime))';
            }else if(config.Apply_Schedule_Date_Flag__c == true){
                soqlPaymentStr += ' AND nu_dse__Schedule_Date__c >=: todayStr';
            }else if(config.Apply_LastModifiedDate_Flag__c == true){
                soqlPaymentStr += ' AND LastModifiedDate >=: paymentTime';
            }
            soqlPaymentStr+=' Order By nu_dse__Schedule_Date__c';
            
            list<nu_dse__Payment__c> pList=Database.Query(soqlPaymentStr);
            for(nu_dse__Payment__c p: pList){
                map<Date, list<nu_dse__Payment__c>> result=offerPaymentsMap.get(p.nu_dse__Program__c);
                if(result==null){
                    result=new map<Date, list<nu_dse__Payment__c>>();
                }
                
                //if(p.Program_Status__c != 'Client Cancelled'){
                    if(p.nu_dse__Schedule_Date__c != null){
                        if(result.containsKey(p.nu_dse__Schedule_Date__c)){
                            list<nu_dse__Payment__c> result1 = result.get(p.nu_dse__Schedule_Date__c);
                            result1.add(p);
                            result.put(p.nu_dse__Schedule_Date__c, result1);
                            offerPaymentsMap.put(p.nu_dse__Program__c, result);
                        }else{
                            result.put(p.nu_dse__Schedule_Date__c, new list<nu_dse__Payment__c>{p});
                            offerPaymentsMap.put(p.nu_dse__Program__c, result);
                        }
                    }else{
                        // If we need to process payments without schedule date
                        
                    }
                //}else{
                    //removePayments.put(p.Id, p);
                //}
            }
            
            list<ProgramPaymentModal> ppmList = new list<ProgramPaymentModal>();
            map<Id, Program_Payment_Out_In__c> ppSettlementMap = new map<Id, Program_Payment_Out_In__c>();
            set<Date> scheduleDates = new set<Date>();
            
            // Process the payments with programs
            for(nu_dse__Program__c prog: scope){
                if(offerPaymentsMap.containsKey(prog.Id)){
                    map<Date, list<nu_dse__Payment__c>> offerPayments = offerPaymentsMap.get(prog.Id);
                    if(offerPayments != null && offerPayments.size()>0){
                        for(Date sd: offerPayments.keyset()){
                            Decimal amount = 0;
                            String TransactionStatus;
                            list<nu_dse__Payment__c> pmts = offerPayments.get(sd);
                            for(nu_dse__Payment__c p: pmts){
                                if(p.nu_dse__Amount__c != null){
                                    amount+=p.nu_dse__Amount__c;
                                    TransactionStatus=p.nu_dse__Transaction_Status__c;
                                }
                            }
                            scheduleDates.add(sd);
                            ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, sd, amount.setScale(2),TransactionStatus));
                        }
                    }
                }else{
                    ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, null, 0,''));
                }
            }
            
            if(ppmList != null && ppmList.size()>0){
                // Store data in Program_Payment_Out_In__c object
                Id ppOutRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Draft');
                list<Program_Payment_Out_In__c> ppSettlementList = new list<Program_Payment_Out_In__c>();
                map<String, Program_Payment_Out_In__c> ppoMap = new map<String, Program_Payment_Out_In__c>();
                
                list<Program_Payment_Out_In__c> ppoList = [Select Id, Name, PROGRAM_UUID__c, SCHEDULED_DATE__c From Program_Payment_Out_In__c 
                                                           Where PROGRAM_UUID__c IN: programIds];
                //AND SCHEDULED_DATE__c IN: scheduleDates
                if(ppoList != null && ppoList.size()>0){
                    for(Program_Payment_Out_In__c ppo: ppoList){
                        if(ppo.SCHEDULED_DATE__c==null){
                            ppoMap.put(ppo.PROGRAM_UUID__c, ppo);
                        }else{
                            ppoMap.put(ppo.PROGRAM_UUID__c+'~'+ppo.SCHEDULED_DATE__c, ppo);
                        }
                    }
                }
                
                for(ProgramPaymentModal ppm: ppmList){
                    if(ppm.SCHEDULED_DATE == null){
                        if(!ppoMap.containsKey(ppm.PROGRAM_UUID)){
                            ppSettlementList.add(new Program_Payment_Out_In__c(RecordTypeId=ppOutRTId,
                                                                               PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                               PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                               SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                               AMOUNT__c=ppm.AMOUNT,
                                                                              Transaction_Status__c=ppm.TRANSACTIONSTATUS));
                        }else{
                            Program_Payment_Out_In__c resultPPO = ppoMap.get(ppm.PROGRAM_UUID);
                            if(resultPPO != null){
                                Program_Payment_Out_In__c resultPPO1 = new Program_Payment_Out_In__c(Id=resultPPO.Id, RecordTypeId=ppOutRTId,
                                                                                                     PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                                                     PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                                                     SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                                                     AMOUNT__c=ppm.AMOUNT,
                                                                                                     Transaction_Status__c=ppm.TRANSACTIONSTATUS);
                                ppSettlementMap.put(resultPPO1.Id, resultPPO1);
                            }
                        }
                    }else{
                        if(!ppoMap.containsKey(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE)){
                            ppSettlementList.add(new Program_Payment_Out_In__c(RecordTypeId=ppOutRTId,
                                                                               PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                               PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                               SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                               AMOUNT__c=ppm.AMOUNT,
                                                                               Transaction_Status__c=ppm.TRANSACTIONSTATUS));
                        }else{
                            Program_Payment_Out_In__c resultPPO = ppoMap.get(ppm.PROGRAM_UUID+'~'+ppm.SCHEDULED_DATE);
                            if(resultPPO != null){
                                Program_Payment_Out_In__c resultPPO1 = new Program_Payment_Out_In__c(Id=resultPPO.Id, RecordTypeId=ppOutRTId,
                                                                                                     PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                                                     PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                                                     SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                                                     AMOUNT__c=ppm.AMOUNT,
                                                                                                     Transaction_Status__c=ppm.TRANSACTIONSTATUS);
                                ppSettlementMap.put(resultPPO1.Id, resultPPO1);
                            }
                        }
                    }
                    
                    
                }
                
                if(ppSettlementList != null && ppSettlementList.size()>0){
                    upsert ppSettlementList;
                }
                
                if(ppSettlementMap != null && ppSettlementMap.size()>0){
                    update ppSettlementMap.values();
                }
                
                /*if(removePayments != null && removePayments.size()>0){
                    list<nu_dse__Payment__c> delPayments = new list<nu_dse__Payment__c>();
                    //Id draftRTId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
                    //Id settlementRTId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
                    
                    // Delete payment in/out records
                }*/
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    public class ProgramPaymentModal{
        public String PROGRAM_UUID {get; set;}
        public String PROGRAM_NUM {get; set;}
        public Date SCHEDULED_DATE {get; set;}
        public Decimal AMOUNT {get; set;}
        public String TRANSACTIONSTATUS {get; set;}
        public ProgramPaymentModal(String PROGRAM_UUID, String PROGRAM_NUM, Date SCHEDULED_DATE, Decimal AMOUNT,String TRANSACTIONSTATUS){
            this.PROGRAM_UUID=PROGRAM_UUID;
            this.PROGRAM_NUM=PROGRAM_NUM;
            this.SCHEDULED_DATE=SCHEDULED_DATE;
            this.AMOUNT=AMOUNT;
            this.TRANSACTIONSTATUS=TRANSACTIONSTATUS;
        }
    }
}