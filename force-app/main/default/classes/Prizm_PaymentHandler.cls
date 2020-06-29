public class Prizm_PaymentHandler{

    public Static Boolean PrizmTriggerExceuted = false;
    
    public static void Prizm_UpdateLeadFields(List<nu_dse__Payment__c> PaymentList,Map<Id,nu_dse__Payment__c> PaymentsNewMap){    
        
        if(!PrizmTriggerExceuted){
            Id DraftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            
            //Map<Id,String> LeadStatusMap = new Map<Id,String>();
            
            List<Id> LeadIds = new List<Id>();
            List<Id> CancelledLead = new List<Id>();
            for(nu_dse__Payment__c Payment : PaymentList){
                /*System.debug('*****'+Payment);
                if(Payment.nu_dse__Transaction_Status__c == 'Cleared' && Payment.RecordTypeId == DraftRecordTypeId && Payment.lead__c != null ){
                    LeadIds.add(Payment.Lead__c);
                    System.debug('*****Payment.Lead__c'+Payment.Lead__c);
                } */
                if(Payment.Lead__c != null && (Payment.nu_dse__Transaction_Status__c == 'Cancelled' || Payment.nu_dse__Transaction_Status__c == 'Skipped' || Payment.nu_dse__Transaction_Status__c == 'Failed') && Payment.RecordTypeId == DraftRecordTypeId  ){
                    CancelledLead.add(Payment.Lead__c);
                    //LeadStatusMap.(Lead.)
                    System.debug('*****Payment.Lead__c'+Payment.Lead__c);
                }
            }
            
            /*Map<Id,nu_dse__Payment__c> LeadPaymentsMap = new Map<Id,nu_dse__Payment__c>();
            List<Lead> LeadList = new List<Lead>();
            
            if(!LeadIds.isEmpty()){
                LeadList = [Select Id, Max_Scheduled_Date__c, last_draft__c from Lead where Id =: LeadIds];
                List<nu_dse__Payment__c> RelatedPaymentList = [Select nu_dse__Total_Amount__c,nu_dse__Transaction_Status__c,Id,Lead__c,nu_dse__Schedule_Date__c, RecordTypeId from nu_dse__Payment__c where Lead__c =: LeadIds AND nu_dse__Transaction_Status__c ='Cleared' AND Id not in: PaymentsNewMap.keySet()];
                
                for(nu_dse__Payment__c payment : RelatedPaymentList){
                    if(!LeadPaymentsMap.containsKey(payment.Lead__c)){
                        LeadPaymentsMap.put(payment.Lead__c,Payment);
                    }else if(LeadPaymentsMap.containsKey(payment.Lead__c) && LeadPaymentsMap.get(payment.Lead__c).nu_dse__Schedule_Date__c < Payment.nu_dse__Schedule_Date__c ){
                        LeadPaymentsMap.put(payment.Lead__c,Payment);
                    }
                }
            }
            System.debug('******'+LeadPaymentsMap);
            
            Map<Id, Lead> LeadMap = new Map<Id,Lead>(LeadList);
            Map<Id,Lead> LeadsTobeUpdated = new Map<Id,Lead>();
            
            for(nu_dse__Payment__c Payment : PaymentList){
                if(Payment.nu_dse__Transaction_Status__c == 'Cleared' && Payment.RecordTypeId == DraftRecordTypeId && LeadMap.containsKey(Payment.Lead__c)){
                    System.debug('****inside for if');
                    
                    Lead l = new Lead();
                    if(LeadMap.containsKey(Payment.Lead__c)){
                        l.Id = LeadMap.get(Payment.Lead__c).Id;
                        l.Max_Scheduled_Date__c = LeadMap.get(Payment.Lead__c).Max_Scheduled_Date__c ;
                        l.Last_Draft__c = LeadMap.get(Payment.Lead__c).Last_Draft__c ;
                    }
                    
                    if(LeadPaymentsMap.containsKey(Payment.Lead__c) && LeadPaymentsMap.get(payment.Lead__c).nu_dse__Schedule_Date__c > Payment.nu_dse__Schedule_Date__c ){
                        
                        l.Max_Scheduled_Date__c = LeadPaymentsMap.get(payment.Lead__c).nu_dse__Schedule_Date__c;
                        l.Last_Draft__c = LeadPaymentsMap.get(payment.Lead__c).nu_dse__Total_Amount__c;
                        
                    }
                    
                    else if(l.Max_Scheduled_Date__c < Payment.nu_dse__Schedule_Date__c || l.Max_Scheduled_Date__c == null){
                        l.Max_Scheduled_Date__c = Payment.nu_dse__Schedule_Date__c;
                        l.Last_Draft__c = Payment.nu_dse__Total_Amount__c;
                        
                    }
                    System.debug('****'+l.Last_draft__c);
                    
                    System.debug('****'+LeadMap.get(Payment.Lead__c).Last_Draft__c);
                    if(LeadMap.get(Payment.Lead__c).Last_Draft__c != l.Last_Draft__c){
                        LeadMap.put(Payment.Lead__c, l);
                        LeadsTobeUpdated.put(l.id,l);
                    }
                    PrizmTriggerExceuted = true;
                }
            
            
            }
            if(!LeadsTobeUpdated.values().isEmpty()){
                Update LeadsTobeUpdated.values();  
            }*/
            System.debug('****'+CancelledLead);
            if(!CancelledLead.isEmpty()){
                List<Lead> CancelledLeadList = [Select Id, Status, Sub_Status__c from Lead where Id=:CancelledLead ];
                
                for(Lead l : CancelledLeadList){
                    L.Status = 'DNL Ineligible';
                    L.Sub_Status__c = 'Skip';
                    PrizmTriggerExceuted = true;
                }
                Update CancelledLeadList;
                PrizmTriggerExceuted = true;
            }
        }
        //for()  
    }
    
    public Static void Prizm_UpdateOpportunities(){
        System.debug('*******opportunity update');
        List<nu_dse__Payment__c> PaymentList = (List<nu_dse__Payment__c>)Trigger.new;
        Map<Id,nu_dse__Payment__c> PaymentOldMap = (Map<Id,nu_dse__Payment__c>)Trigger.oldMap;
        
        List<Id> OpportunityIds = new List<Id>();
        Map<Id,String> OpportunityStageMap = new Map<Id,String>();
        for(nu_dse__Payment__c Payment : PaymentList){
            if((Trigger.isInsert || Payment.nu_dse__Transaction_Status__c != PaymentOldMap.get(Payment.Id).nu_dse__Transaction_Status__c) && (Payment.nu_dse__Transaction_Status__c == 'Failed' || Payment.nu_dse__Transaction_Status__c == 'Skipped') && Payment.Opportunity__c != null){
                OpportunityIds.add(Payment.Opportunity__c);
                OpportunityStageMap.put(Payment.Opportunity__c,Payment.nu_dse__Transaction_Status__c);
            }
        }
        System.debug('*******opportunity update'+OpportunityStageMap);
        if(!OpportunityIds.isEmpty()){
            List<Opportunity> OpportunityList = [Select Id,StageName from Opportunity where Id=: OpportunityIds];
            OpportunityWrapper OppWrapList = new OpportunityWrapper();
            
            for(Opportunity opp : OpportunityList){
                if(opp.StageName != 'Closed Lost'){
                opp.StageName = 'Closed Lost';
                OppWrapList.OpportunityIds.add(opp.Id);
                }
                PrizmTriggerExceuted = true;
            }
            System.debug('*******opportunity update'+OpportunityList);
            //PrizmTriggerExceuted = true;
            Update OpportunityList;
            if(OppWrapList.OpportunityIds.size()>0){
                UpdateOpportunityStatus(JSON.serialize(OppWrapList));
            }
        }
    }
    
    public Class OpportunityWrapper{
        
         
        public List<Id> opportunityIds;
        
        public OpportunityWrapper(){
            opportunityIds = new List<Id>(); 
        }
    }
    
    @future(callout = true)
    public static void UpdateOpportunityStatus(String OpportunityList){
        String accessToken = '';
        if(!test.isRunningTest()){
            SendOpportunityAccountUsingRestApi acc1= new SendOpportunityAccountUsingRestApi();
            accessToken=acc1.ReturnAccessToken(acc1);
        }
        System.debug(accessToken+'###0012');
        System.debug(OpportunityList);
        if(accessToken!=null){
        
            RestIntegrationInformation__mdt restIntegration = [select MasterLabel,System_Endpoint__c,AccesstokenURL__c,authurl__c,Client_Secret__c,Consumer_Key__c,Password__c,Username__c From RestIntegrationInformation__mdt];
            String endPoint = restIntegration.System_Endpoint__c+'/UpdateOpprtunityStage '; 
            //String jsonstr= getOppDataJSON(oppLst);
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Authorization','Bearer ' + accessToken);
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(OpportunityList);
            req2.setMethod('POST');
            req2.setEndpoint(endPoint);
            if(!test.isRunningTest()){
                HttpResponse res2=h2.send(req2);
                System.debug(res2+'###1203createresp');
            }
            
        }
    }

}