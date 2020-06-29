public without sharing class Velocify_ProgramHandler{

    public static boolean VelocifyExecuted = false;
    
    public static void UpdateLeadStatus(List<nu_dse__Program__c> programList, Map<Id,nu_dse__Program__c> ProgramOldMap,Map<Id,nu_dse__Program__c> ProgramNewMap){
        System.debug(trigger.new);
        
        List<String> StatusList=new List<String>{'Active Client','Pending Cancellation','Client Cancelled'};
        Map<Integer,Integer> LeadStatusMap = new map<Integer,Integer>();
        
        
        List<Id> ProgramIds = new List<Id>();
        for(nu_dse__Program__c program:ProgramList){
            if(StatusList.contains(program.nu_dse__Program_Status__c) && program.nu_dse__Program_Status__c != ProgramOldMap.get(program.id).nu_dse__Program_Status__c){
                programIds.add(program.id);
            }
        }
        
        Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        if(!ProgramIds.isEmpty()){
        List<nu_dse__Payment__c> RelatedPaymentsForFrequency = [Select Id, nu_dse__Transaction_Status__c,nu_dse__Amount__c, nu_dse__Program__c, nu_dse__Schedule_Date__c from nu_dse__Payment__c  where nu_dse__Program__c =: ProgramIds AND nu_dse__Is_Good_Faith_Payment__c = false AND RecordTypeId =: DraftRecordTypeId ORDER BY nu_dse__Program__c , nu_dse__Schedule_Date__c];
        
        Map<Id,String> ProgramPaymentFrequencyMap = new map<Id,String>();
        Map<Id,List<nu_dse__Payment__c>> PaymentsProgramMap = new Map<Id,List<nu_dse__Payment__c>>();
        
        for(nu_dse__Payment__c Payment : RelatedPaymentsForFrequency){
            if(Payment.nu_dse__schedule_Date__c != null){
                if(!PaymentsProgramMap.containskey(Payment.nu_dse__Program__c)){
                    PaymentsProgramMap.put(Payment.nu_dse__Program__c,new List<nu_dse__Payment__c>());
                }
                PaymentsProgramMap.get(Payment.nu_dse__Program__c).add(payment);
            }
        }
        
        for(Id Program:PaymentsProgramMap.keySet()){
            String frequency = 'Monthly';
            if(PaymentsProgramMap.get(Program).size() >= 3){
                List<nu_dse__Payment__c> ProgramPayments = PaymentsProgramMap.get(Program);
                if(ProgramPayments.get(0).nu_dse__schedule_Date__c.Month() == ProgramPayments.get(1).nu_dse__schedule_Date__c.Month() || ProgramPayments.get(1).nu_dse__schedule_Date__c.Month() == ProgramPayments.get(2).nu_dse__schedule_Date__c.Month()){
                    frequency = 'Half Monthly';
                }
            }
            ProgramPaymentFrequencyMap.put(Program,frequency);
        }
        
        //Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        List<AggregateResult> PaymentList = [Select count(Id) myCount, nu_dse__Program__c from nu_dse__Payment__c where recordTypeId =: DraftRecordtypeId AND Payment_Status__c In ('Completed','Cleared') AND nu_dse__Program__c =: ProgramIds AND nu_dse__Is_Good_Faith_Payment__c = false Group By nu_dse__Program__c ];
        system.debug(PaymentList);
        Map<Id,Integer> ProgramPaymentMap = new Map<Id,Integer>();
        for(AggregateResult ar : PaymentList){
                ProgramPaymentMap.put((Id)ar.get('nu_dse__Program__c'),(Integer)ar.get('myCount'));
            System.debug(ProgramPaymentMap);
        }
        
        List<nu_dse__Program__c> ProgramToBeUpdated = new List<nu_dse__Program__c>();
        for(Id programId : ProgramIds){
            integer numberOfPayments = 4;
            if(ProgramPaymentFrequencyMap.containsKey(programId) && ProgramPaymentFrequencyMap.get(programId) == 'Half Monthly'){
                numberOfPayments = 8;
            }
        
            if((!ProgramPaymentMap.containsKey(programId) || ProgramPaymentMap.get(programId) < numberOfPayments )&& ProgramNewMap.get(programId).External_Id__c != null && ProgramNewMap.get(programId).External_Id__c.length()<10){
                nu_dse__Program__c p = new nu_dse__Program__c();
                p.Id = ProgramId;
                if(ProgramNewMap.get(programId).nu_dse__Program_Status__c == 'Pending Cancellation'){
                    //LeadStatusMap.put(Integer.valueOf(ProgramNewMap.get(programId).External_Id__c),18);
                    P.Velocify_Lead_Status__c='18';
                } else if(ProgramNewMap.get(programId).nu_dse__Program_Status__c == 'Client Cancelled') {
                    //LeadStatusMap.put(Integer.valueOf(ProgramNewMap.get(programId).External_Id__c),21);
                    P.Velocify_Lead_Status__c='21';
                } else if(ProgramNewMap.get(programId).nu_dse__Program_Status__c == 'Active Client' && (ProgramOldMap.get(programId).nu_dse__Program_Status__c == 'Client Cancelled' || ProgramOldMap.get(programId).nu_dse__Program_Status__c == 'Pending Cancellation' || ProgramOldMap.get(programId).nu_dse__Program_Status__c == 'NSF')) {
                    //LeadStatusMap.put(Integer.valueOf(ProgramNewMap.get(programId).External_Id__c),162);
                    P.Velocify_Lead_Status__c='162';
                }
                
                p.Velocify_Integration_Status__c = 'Initiated';
                ProgramToBeUpdated.add(p);
            }
            
        }
        System.debug(LeadStatusMap);
        if(!ProgramToBeUpdated.isEmpty()){
            //System.enqueueJob(new AsyncCallToNDSLeadStatusUpdate(LeadStatusMap));
            //LeadStatusUpdateInVelocify(LeadStatusMap);
            
            Update ProgramToBeUpdated;
            VelocifyExecuted = true;
        }
        }
    }
    
    /*public static void LeadStatusUpdateInVelocify(Map<Integer,Integer> LeadStatusMap){
        VelocifyCredentials__c credentials =  VelocifyCredentials__c.getValues('VelocifyCredentials');
        serviceLeads360Com.ClientServiceSoap  soap = new serviceLeads360Com.ClientServiceSoap();
        for(Integer LeadId : LeadStatusMap.keySet()){
        if(!test.isRunningTest())
           soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,LeadId,LeadStatusMap.get(LeadId));
           
        //  soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,876536,LeadStatusMap.get(LeadId));
        }
    }*/
    
    /*public class AsyncCallToNDSLeadStatusUpdate implements Queueable,Database.AllowsCallouts{
        Map<Integer,Integer> LeadStatusMap = new Map<Integer,Integer>();
        
        public AsyncCallToNDSLeadStatusUpdate(Map<Integer,Integer> InputMap){
            this.LeadStatusMap=inputMap;
        }
        
        public void execute(QueueableContext context) {  
            VelocifyCredentials__c credentials =  VelocifyCredentials__c.getValues('VelocifyCredentials');
            serviceLeads360Com.ClientServiceSoap  soap = new serviceLeads360Com.ClientServiceSoap();
            for(Integer LeadId : LeadStatusMap.keySet()){
            if(!test.isRunningTest())
               soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,LeadId,LeadStatusMap.get(LeadId));
               
            //  soap.ModifyLeadStatus(credentials.Username__c,credentials.Password__c,876536,LeadStatusMap.get(LeadId));
            }
        }
    
    }*/


}