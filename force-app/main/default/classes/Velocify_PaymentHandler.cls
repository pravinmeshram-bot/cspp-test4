/*
Velocify Integration Changes
Date : 10/29/2018
Functionality : Push payment status to velocify lead whenever it completes or fails.
JIRA Story : NMI - 187
Author : Mayur Agrawal
//test
*/

public without sharing Class Velocify_PaymentHandler {
    
    //flag for recursion
    public static boolean VelocifyExecuted = false;
    
    public static void updatePaymentDetailsInVelocify(Map<Id,nu_dse__Payment__c> paymentNewMap,Map<Id,nu_dse__Payment__c> paymentOldMap){
        
        //System.debug('**** Velocify Payment Handler');
        List<Id> ProgramId = new List<Id>();
        List<Id> PaymentIds = new List<Id>();
        List<LeadFieldWrapper> LeadFieldWrapperList = new List<LeadFieldWrapper>();
        List<Id> GoodFaithPaymentIds =  new List<Id>();
        
        //Map<Id,List<nu_dse__Payment__c>> ProgramUpdatedPaymentMap = new Map<Id,List<nu_dse__Payment__c>>();
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        for(nu_dse__Payment__c Payment : PaymentNewMap.values()){
            if((Trigger.isInsert || Payment.nu_dse__Transaction_Status__c != paymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c) && (Payment.nu_dse__Transaction_Status__c== 'Cleared' || Payment.nu_dse__Transaction_Status__c== 'Failed' || Payment.nu_dse__Transaction_Status__c == 'Completed') && Payment.nu_dse__Is_Good_Faith_Payment__c == false && Payment.RecordTypeId == DraftRecordTypeId && Payment.nu_dse__Amount__c != null && Payment.nu_dse__Type__c !='ADHOC'){
                ProgramId.add(Payment.nu_dse__Program__c);
                PaymentIds.add(Payment.Id);
                //ProgramUpdatedPaymentMap(Payment.nu_dse__Program__c,Payment);
            }
            //Good Faith Payments
            if((Trigger.isInsert || Payment.nu_dse__Transaction_Status__c != paymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c) && Payment.nu_dse__Is_Good_Faith_Payment__c && Payment.nu_dse__Amount__c == 50 && Payment.RecordTypeId == DraftRecordTypeId){
                /*if(Payment.nu_dse__Transaction_Status__c == 'Cleared' || Payment.nu_dse__Transaction_Status__c == 'Completed')
                    LeadFieldWrapperList.add(new LeadFieldWrapper('GoodFaithCleared',null,null,null,Integer.valueOf(payment.nu_dse__Program__r.External_Id__c)));
                if(Payment.nu_dse__Transaction_Status__c == 'Failed')
                    LeadFieldWrapperList.add(new LeadFieldWrapper('GoodFaithFailed',null,null,null,Integer.valueOf(payment.nu_dse__Program__r.External_Id__c)));'*/
                GoodFaithPaymentIds.add(Payment.id);
            }
        }
        System.debug('******'+PaymentIds); //SFDC Assistance - Single Monthly works when this is not commented.
        //System.debug('*** Good Faith Payment'+GoodFaithPaymentIds);
        
        //Process Good Faith Payments
        if(!GoodFaithPaymentIds.isEmpty()){
            List<nu_dse__Payment__c> GoodFaithPayments = [Select Id, nu_dse__Program__r.External_Id__c,nu_dse__Transaction_Status__c from nu_dse__Payment__c where Id =: GoodFaithPaymentIds ];
            for(nu_dse__Payment__c Payment : GoodFaithPayments){
                if(Payment.nu_dse__Program__r.External_Id__c != null){
                    if(Payment.nu_dse__Transaction_Status__c == 'Cleared' || Payment.nu_dse__Transaction_Status__c == 'Completed')
                        LeadFieldWrapperList.add(new LeadFieldWrapper(true,'Cleared',Integer.valueOf(payment.nu_dse__Program__r.External_Id__c)));
                    if(Payment.nu_dse__Transaction_Status__c == 'Failed')
                        LeadFieldWrapperList.add(new LeadFieldWrapper(true,'Failed',Integer.valueOf(payment.nu_dse__Program__r.External_Id__c)));
                }
            }
        }
        
        //SYstem.debug('**** List of records'+LeadFieldWrapperList);
        if(!ProgramId.isEmpty()){
        
        List<nu_dse__Payment__c> RelatedPaymentsForFrequency = [Select Id, nu_dse__Transaction_Status__c,nu_dse__Amount__c, nu_dse__Program__c, nu_dse__Schedule_Date__c from nu_dse__Payment__c  where nu_dse__Program__c =: ProgramId AND nu_dse__Is_Good_Faith_Payment__c = false AND RecordTypeId =: DraftRecordTypeId AND nu_dse__Type__c != 'ADHOC' ORDER BY nu_dse__Program__c , nu_dse__Schedule_Date__c];
        
        Map<Id,nu_dse__Payment__c> AllPaymentMap = new Map<Id,nu_dse__Payment__c>(RelatedPaymentsForFrequency);
        
        //Map<Id,String> ProgramPaymentFrequencyMap = new map<Id,String>();
        //Map<Id,List<nu_dse__Payment__c>> PaymentsProgramMap = new Map<Id,List<nu_dse__Payment__c>>();
        
        Map<Id,List<nu_dse__Payment__c>> ProgramClearedMap = new Map<Id,List<nu_dse__Payment__c>>();
        Map<Id,Integer> ProgramFailedMap = new Map<Id,Integer>();
        
        Map<Id,List<Id>> ProgramClearedIdsMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> ProgramFailedIdsMap = new Map<Id,List<Id>>();
        
        //Find frequency of payments, i.e. Monthly or Bimonthly
        for(nu_dse__Payment__c Payment : RelatedPaymentsForFrequency){
            /*if(Payment.nu_dse__schedule_Date__c != null){
                if(!PaymentsProgramMap.containskey(Payment.nu_dse__Program__c)){
                    PaymentsProgramMap.put(Payment.nu_dse__Program__c,new List<nu_dse__Payment__c>());
                }
                PaymentsProgramMap.get(Payment.nu_dse__Program__c).add(payment);
            }*/
            //System.debug(PaymentIds);
            //System.debug(Payment.Id);
            //System.debug(PaymentIds.contains(Payment.Id));
            //if(!PaymentIds.contains(Payment.Id)){
                if(Payment.nu_dse__Transaction_Status__c == 'Failed'){
                    if(!PaymentIds.contains(Payment.Id)){
                        if(!ProgramFailedMap.containsKey(Payment.nu_dse__Program__c)){
                            ProgramFailedMap.put(Payment.nu_dse__Program__c,0);
                        }
                        ProgramFailedMap.put(Payment.nu_dse__Program__c,ProgramFailedMap.get(Payment.nu_dse__Program__c)+1);
                    }
                    if(PaymentIds.contains(Payment.Id)){
                        if(!ProgramFailedIdsMap.containsKey(Payment.nu_dse__Program__c)){
                            ProgramFailedIdsMap.put(Payment.nu_dse__Program__c,new List<Id>());
                        }
                        ProgramFailedIdsMap.get(Payment.nu_dse__Program__c).add(Payment.Id);
                    }
                } 
                if(Payment.nu_dse__Transaction_Status__c == 'Cleared' || Payment.nu_dse__Transaction_Status__c == 'Completed'){
                    if(!PaymentIds.contains(Payment.Id)){
                        ProgramFailedMap.remove(Payment.nu_dse__Program__c);
                        if(!ProgramClearedMap.containsKey(Payment.nu_dse__Program__c)){
                            ProgramClearedMap.put(Payment.nu_dse__Program__c,new List<nu_dse__Payment__c>());
                        }
                        ProgramClearedMap.get(Payment.nu_dse__Program__c).add(Payment);
                    }
                    if(PaymentIds.contains(Payment.Id)){
                        ProgramFailedIdsMap.remove(Payment.nu_dse__Program__c);
                        if(!ProgramClearedIdsMap.containsKey(Payment.nu_dse__Program__c)){
                            ProgramClearedIdsMap.put(Payment.nu_dse__Program__c,new List<Id>());
                        }
                        ProgramClearedIdsMap.get(Payment.nu_dse__Program__c).add(Payment.Id);
                    }
                }
            //}
        }
        
        System.debug('****'+ProgramClearedMap);
        System.debug('****'+ProgramFailedMap);
        //System.debug('****'+PaymentsProgramMap);
        
        System.debug('*****' + ProgramClearedIdsMap);
        System.debug('*****' + ProgramFailedIdsMap);
        
        /*for(Id Program:PaymentsProgramMap.keySet()){
            String frequency = 'Monthly';
            if(PaymentsProgramMap.get(Program).size() >= 3){
                List<nu_dse__Payment__c> ProgramPayments = PaymentsProgramMap.get(Program);
                if(ProgramPayments.get(0).nu_dse__schedule_Date__c.Month() == ProgramPayments.get(1).nu_dse__schedule_Date__c.Month() || ProgramPayments.get(1).nu_dse__schedule_Date__c.Month() == ProgramPayments.get(2).nu_dse__schedule_Date__c.Month()){
                    frequency = 'Half Monthly';
                }
            }
            ProgramPaymentFrequencyMap.put(Program,frequency);
        }
        System.debug('****'+ProgramPaymentFrequencyMap);*/
        
        //Process completed or failed payments.
        for(nu_dse__Payment__c payment: [Select nu_dse__Program__r.External_Id__c,nu_dse__Program__r.nu_dse__Payment_Frequency__c,nu_dse__Amount__c,Id,nu_dse__Transaction_Status__c,nu_dse__Program__c, nu_dse__Schedule_Date__c from nu_dse__Payment__c where Id =: PaymentIds AND RecordTypeId =: DraftRecordTypeId AND nu_dse__Type__c != 'ADHOC' ORDER BY nu_dse__schedule_Date__c]){
            System.debug('****'+Payment.nu_dse__Program__r.External_Id__c);
            if(Payment.nu_dse__Program__r.External_Id__c != null && Payment.nu_dse__Program__r.External_Id__c.length()<10){
                Integer paymentNumber = 1;
                Date PaymentDate = Payment.nu_dse__Schedule_Date__c;
                String status = Payment.nu_dse__Transaction_Status__c;
                
                if(status == 'Completed'){
                    status = 'Cleared';
                }
                
                Decimal Amount = Payment.nu_dse__Amount__c;
                Integer clearedPayments = 0;
                if(ProgramClearedMap.containsKey(Payment.nu_dse__Program__c)){
                    clearedPayments = ProgramClearedMap.get(Payment.nu_dse__Program__c).size();
                    
                    
                }
                if(ProgramClearedIdsMap.containsKey(Payment.nu_dse__Program__c)){
                        List<Id> PaymentClearedList = ProgramClearedIdsMap.get(Payment.nu_dse__Program__c);
                        
                        System.debug('****'+PaymentClearedList);
                        if(PaymentClearedList.contains(Payment.id)){
                            System.debug('****'+PaymentClearedList.indexOf(Payment.id));
                            clearedPayments += PaymentClearedList.indexOf(Payment.id);
                        } else {
                            clearedPayments += PaymentClearedList.size();
                        }
                        System.debug('*****'+ClearedPayments);
                    }
                
                PaymentNumber = clearedPayments + 1;
                System.debug(PaymentNumber);
                if(Payment.nu_dse__Transaction_Status__c == 'Failed' && ProgramFailedMap.containsKey(Payment.nu_dse__Program__c)){
                    paymentNumber = paymentNumber + ProgramFailedMap.get(Payment.nu_dse__Program__c);
                    
                    //Status = 'Failed';
                }
                
                    if(Payment.nu_dse__Transaction_Status__c == 'Failed' && ProgramFailedIdsMap.containsKey(Payment.nu_dse__Program__c)){
                        List<Id> PaymentFailedList = ProgramFailedIdsMap.get(Payment.nu_dse__Program__c);
                        
                        //System.debug('****'+PaymentFailedList);
                        if(PaymentFailedList.contains(Payment.id)){
                            PaymentNumber += PaymentFailedList.indexOf(Payment.id);
                        }
                    }
                
                //if(ProgramPaymentFrequencyMap.containsKey(Payment.nu_dse__Program__c) && ProgramPaymentFrequencyMap.get(Payment.nu_dse__Program__c) == 'Half Monthly'){
                System.debug('*****'+ Payment.nu_dse__Program__r.nu_dse__Payment_Frequency__c);
                if(Payment.nu_dse__Program__r.nu_dse__Payment_Frequency__c == 'Twice Monthly'){
                    Integer temp = PaymentNumber;
                    paymentNumber = Integer.valueOf(Math.ceil(PaymentNumber/2));
                    System.debug(temp);
                    System.debug(paymentNumber);
                    if(Math.mod(temp,2)==0 && Payment.nu_dse__Transaction_Status__c != 'Failed' && (ProgramClearedIdsMap.containsKey(Payment.nu_dse__Program__c) || ProgramClearedMap.containsKey(Payment.nu_dse__Program__c))){
                        List<Id> PaymentClearedList = new List<Id>();
                        if(ProgramClearedMap.containsKey(Payment.nu_dse__Program__c)){
                            for(nu_dse__Payment__c p : ProgramClearedMap.get(Payment.nu_dse__Program__c)){
                                PaymentClearedList.add(p.Id);
                            }
                            
                            //PaymentClearedList.addAll(ProgramClearedMap.get(Payment.nu_dse__Program__c));
                        }
                        if(ProgramClearedIdsMap.containsKey(Payment.nu_dse__Program__c)){
                            PaymentClearedList.addAll(ProgramClearedIdsMap.get(Payment.nu_dse__Program__c));
                        }
                        System.debug('****'+PaymentClearedList);   //SFDC Assistance - Twice Monthly works when this is not commented.
                        //List<Id> PaymentClearedList = ProgramClearedIdsMap.get(Payment.nu_dse__Program__c);
                        Id IdOfPayment = PaymentClearedList.get(PaymentClearedList.indexOf(Payment.id) - 1);
                        System.debug('*****'+IdOfPayment);
                        //Integer LastIndex = ProgramClearedMap.get(Payment.nu_dse__Program__c).size()-1;
                        if(PaymentNewMap.containsKey(IdOfPayment) && PaymentNewMap.get(IdOfPayment).nu_dse__Amount__c != null){
                            amount = amount + PaymentNewMap.get(IdOfPayment).nu_dse__Amount__c;
                            System.debug('*****'+amount);
                        } else if(AllPaymentMap.containsKey(IdOfPayment) && AllPaymentMap.get(IdOfPayment).nu_dse__Amount__c != null){
                            System.debug('*****'+amount);
                            System.debug('*****'+AllPaymentMap.get(IdOfPayment).nu_dse__Amount__c);
                            amount = amount + AllPaymentMap.get(IdOfPayment).nu_dse__Amount__c;
                            System.debug('*****'+amount);
                        } 
                    }
                    else if(Math.mod(temp,2)!=0){
                        paymentNumber ++;
                    }
                    
                }
                /*if(Payment.nu_dse__Transaction_Status__c == 'Failed' && paymentNumber > 4){
                    paymentNumber = 4;
                }*/
                System.debug('*****'+Status+ paymentNumber+PaymentDate+Amount+Integer.valueOf(payment.nu_dse__Program__r.External_Id__c));
                if(PaymentNumber <= 4)
                LeadFieldWrapperList.add(new LeadFieldWrapper(Status, paymentNumber,PaymentDate,Amount,Integer.valueOf(payment.nu_dse__Program__r.External_Id__c)));
                  
                  
                System.debug('*****LeadWrapper'+LeadFieldWrapperList);
            }
        }
        }
        System.debug('*****LeadWrapper'+LeadFieldWrapperList);
        if(LeadFieldWrapperList.size()>0){
            System.enqueueJob(new AsyncCallToNDSLeadFieldUpdate(LeadFieldWrapperList));
            velocifyExecuted = true;
        }
       
    }
    
    //Defining a wrapper to hold all the output values. Which will be sent to velocify.
    public class LeadFieldWrapper{
        String Status;
        Integer PaymentNumber;
        Date ScheduledDate;
        Decimal Amount;
        Integer LeadId;
        Boolean isGoodFaith = false;
        public LeadFieldWrapper(String Status1,Integer PaymentNumber1,Date ScheduledDate1,Decimal Amount1,Integer LeadId1){
            Status = Status1;
            PaymentNumber = PaymentNumber1;
            ScheduledDate = ScheduledDate1;
            Amount = Amount1;
            LeadId = LeadId1;
        }
        public LeadFieldWrapper (Boolean isGoodFaith1, String Status1, Integer LeadId1){
            Status = Status1;
            isGoodFaith = isGoodFaith1;
            LeadId = LeadId1;
        }
    }
    
    //Assynchronous method to make webservice callouts.
    public class AsyncCallToNDSLeadFieldUpdate implements Queueable,Database.AllowsCallouts{
        
        List<LeadFieldWrapper> LeadFieldWrapperList = new List<LeadFieldWrapper>();
        
        public AsyncCallToNDSLeadFieldUpdate(List<LeadFieldWrapper> LeadFieldWrapperList1){
            LeadFieldWrapperList = LeadFieldWrapperList1;
        }
        
        public void execute(QueueableContext context) { 
            VelocifyCredentials__c credentials =  VelocifyCredentials__c.getValues('VelocifyCredentials');
            serviceLeads360Com.ClientServiceSoap  soap = new serviceLeads360Com.ClientServiceSoap();
            //if(!Test.isRunningTest()){
            for(LeadFieldWrapper Lfw : LeadFieldWrapperList){
                if(lfw.PaymentNumber<= 4 && !lfw.isGoodFaith && !Test.isRunningTest()){
                    system.debug(lfw.PaymentNumber+lfw.Status);
                    VelocifyLeadStatusMapping__c mapping= VelocifyLeadStatusMapping__c.getValues(lfw.PaymentNumber+lfw.Status);
                    System.debug(mapping+'876536');
                    if(mapping.Amount_field_Id__c != null){
                       //   soap.ModifyLeadField(credentials.Username__c,credentials.Password__c,lfw.LeadId,Integer.valueOf(mapping.Amount_field_Id__c),string.valueOf(lfw.Amount));
                        soap.ModifyLeadField(credentials.Username__c,credentials.Password__c,876536,Integer.valueOf(mapping.Amount_field_Id__c),string.valueOf(lfw.Amount));
                    }
                    if(mapping.Date_field_Id__c != null){
                      //  soap.ModifyLeadField(credentials.Username__c,credentials.Password__c,lfw.LeadId,Integer.valueOf(mapping.Date_field_Id__c),string.valueOf(lfw.ScheduledDate));
                        soap.ModifyLeadField(credentials.Username__c,credentials.Password__c,876536,Integer.valueOf(mapping.Date_field_Id__c),string.valueOf(lfw.ScheduledDate));
                    }
                    if(mapping.Status__c!= null){
                      //   soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,lfw.LeadId,Integer.valueOf(mapping.status__c));
                        soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,876536,Integer.valueOf(mapping.status__c));
                    }
                } else if(lfw.isGoodFaith && !Test.isRunningTest()){
                    VelocifyLeadStatusMapping__c mapping= VelocifyLeadStatusMapping__c.getValues('GoodFaith'+lfw.Status);
                  //   soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,lfw.LeadId,Integer.valueOf(mapping.status__c));
                    soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,876536,Integer.valueOf(mapping.status__c));
                }
                
            }
        }
        
    }
    
}