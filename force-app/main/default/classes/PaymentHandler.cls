public class PaymentHandler {
    
    public static void handle(map<id,nu_dse__Payment__c> oldPayments, Map<id,nu_dse__Payment__c> newPayments){
        
        list<id> paymentIds = new list<id>();
        list<id> nsftPaymentIds = new list<id>(); 
        System.debug('**** trigger fired ****');
        if(trigger.isupdate){
            
            Id draftId = [select id from recordType where sObjectType='nu_dse__Payment__c' and DeveloperName='Draft' limit 1].id;
            for(id pId: newPayments.keySet()){
                System.debug('New transaction status:::'+ newPayments.get(pId).get('nu_dse__transaction_status__c'));
                if((newPayments.get(pId).get('nu_dse__transaction_status__c')=='Completed'|| newPayments.get(pId).get('nu_dse__transaction_status__c')=='Cleared' ||newPayments.get(pId).get('nu_dse__transaction_status__c')=='Failed')  && (oldPayments.get(pID).get('nu_dse__transaction_status__c') != newPayments.get(pId).get('nu_dse__transaction_status__c')) && (oldPayments.get(pID).get('recordTypeId')==draftId)){
                    paymentIds.add(pId);
                    System.debug('Payment status changed. Added to paymentIds');
                }
                if((newPayments.get(pId).get('nu_dse__transaction_status__c')=='Failed')&&(oldPayments.get(pID).get('nu_dse__transaction_status__c') != newPayments.get(pId).get('nu_dse__transaction_status__c')) ){
                    nsftPaymentIds.add(pId); 
                }
            }
            
            if(paymentIds.size()>0){
                
                //modifyLeadsPayments_future(paymentIds);
                SYstem.debug('**** paymentIds' + paymentIds);
                Records_to_Process_Handler.createRecord(paymentIds,'Velocify');
                
            }
            /*else if(paymentIds.size()>0){
				modifyLeadsPayments(paymentIds);
			}*/
        }
    }
    
    public static String modifyLeadsPayments( list<id> paymentIds){
        
        Map<id,nu_dse__Payment__c> newPayments = new Map<id,nu_dse__payment__c>();
        // To collect Program and all its payments. 
        Map<id,List<nu_dse__Payment__c>> program_Payments = new Map<id,List<nu_dse__Payment__c>>(); 
        
        // To Collect Program and All its payments in order. <program,Month1,{payment1, payment2}> <program,Month2,{payment3, payment4}>
        
        Map<Id,Map<integer,list<nu_dse__Payment__c>>> programPaymentOrder = new   Map<Id,Map<integer,list<nu_dse__Payment__c>>>();
        
        List<ServiceLeads360.FieldValues> fieldValues ; 
        
        List<ServiceLeads360.Lead> leads = new List<ServiceLeads360.Lead>(); 
        // To Collect payment and its Order, <payment1Id, 1>, <payment2Id,1>, <payment3Id,2>, <payment4Id,2> for twice monthly payment 
        
        Map<Id,Integer> paymentOrder = new Map<id,Integer>();   
        
        set<id> programIds = new set<id>();
        
        Map<id,Decimal> paymentAmount = new Map<id,decimal>(); // map<paymentId, su
        
        Map<string,string> leadStatus = new Map<string,string>(); 
        
        
            for(nu_dse__Payment__c payment:[select id,nu_dse__program__c,nu_dse__Amount__c,nu_dse__Schedule_Date__c from nu_dse__Payment__c where id in: paymentIds]){
                
                programIds.add(payment.nu_dse__Program__c);
                
                newPayments.put(payment.Id,payment);
                
            }
            
            for(nu_dse__Payment__c payment: [select id,nu_dse__Amount__c,lastmodifiedDate,nu_dse__transaction_status__c,nu_dse__Program__c,nu_dse__Program__r.nu_dse__Payment_Frequency__c,nu_dse__Program__r.nu_dse__Program_length__c from nu_dse__Payment__c where nu_dse__Program__c in : programIds and recordType.Developername='Draft' and nu_dse__Amount__c != 50  order by nu_dse__schedule_Date__c]){
                
                
                if(!program_Payments.containsKey(payment.nu_dse__Program__c)){
                    
                    program_Payments.put(payment.nu_dse__Program__c, new List<nu_dse__Payment__c>());
                }
                
                if(program_Payments.containsKey(payment.nu_dse__Program__c)){
                    
                    
                    program_Payments.get(payment.nu_dse__Program__c).add(payment);
                    
                }
                
                
                
            }
        
        
        Map<id,nu_dse__Program__c> programs = new Map<id,nu_dse__Program__c>([select id,nu_dse__Payment_Frequency__c,nu_dse__Program_length__c,External_Id__c from nu_dse__Program__c where id in: programIds]);
        
        for(Id pId: program_Payments.keySet()){
            
            integer plength = 0 ;
            integer paymentFrequency = 1; 
            
            paymentFrequency = programs.get(pId).nu_dse__Payment_Frequency__c=='Monthly' ? 1:2; 
            
            plength = (integer)programs.get(pId).nu_dse__Program_length__c; 
            
            if(!programPaymentOrder.containsKey(pId)){
                
                programPaymentOrder.put(pId,new Map<integer,List<nu_dse__Payment__c>>());
                
                
            }
            integer m = 1; // m for month
            integer completed = 0;
            decimal completedAmt = 0.00; 
            for( integer p = 0 ; p< program_Payments.get(pId).size() ; p++  ){
                
                IF(program_Payments.get(pId)[p].nu_dse__Amount__c !=50){                    
                    //nu_dse__Payment__c p: program_Payments.get(pId)
                    
                    if(!programPaymentOrder.get(pId).containsKey(m)){
                        
                        programPaymentOrder.get(pId).put(m,new List<nu_dse__Payment__c>());
                    }
                    if(programPaymentOrder.get(pId).containsKey(m) ){
                        
                        programPaymentOrder.get(pId).get(m).add(program_Payments.get(pId)[p]);
                        
                    }
                    
                    paymentOrder.put(program_Payments.get(pId)[p].Id,m);
                    
                    if(  (program_Payments.get(pId)[p].nu_dse__transaction_status__c == 'Completed' || program_Payments.get(pId)[p].nu_dse__transaction_status__c == 'Cleared')){
                        
                        completed +=1; 
                        completedAmt += program_Payments.get(pId)[p].nu_dse__Amount__c; 
                        
                        paymentAmount.put(program_Payments.get(pId)[p].Id,completedAmt);
                    }
                    
                    
                    if(completed == paymentFrequency){
                        
                        m++; 
                        
                        completed =0; 
                        completedAmt =0.00;
                    }
                    
                    
                    if(m==6){
                        
                        break;
                    }
                    
                }
                
            }
            
        }
        
        for(id pId: programPaymentOrder.keySet()){
            
            String leadId = pId;  
            
            fieldValues = new  List<ServiceLeads360.FieldValues>(); 
            
            
            // payment 1: 
            System.debug('Payment order 1: '+programPaymentOrder.get(pId));
            
            if(programPaymentOrder.get(pId).containsKey(1)){ 
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(1)){
                    
                    if(newPayments.containsKey(p.Id)){
                        
                        System.debug('::::::::PAYMENT 1 IS FOUND:::'); 
                        
                        decimal pAmt = 0.00; 
                        
                        if(paymentAmount.containsKey(p.id)){
                            
                            pAmt = paymentAmount.get(p.Id); 
                            
                            fieldvalues.add(new ServiceLeads360.FieldValues('Payment 1 Amount',String.valueOf(pAmt)));
                            
                            fieldvalues.add(new ServiceLeads360.FieldValues('Payment 1 Date',String.valueOf(newPayments.get(p.Id).nu_dse__Schedule_Date__c)));
                            
                            if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                                
                                leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'39');
                                
                            }
                            
                        }
                        
                        if(p.nu_dse__transaction_status__c == 'Failed'){
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'58');
                        }
                        
                    }
                }
            }
            
            if(programPaymentOrder.get(pId).containsKey(2)){
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(2)){
                    
                    if(newPayments.containsKey(p.Id)){
                        
                        System.debug('::::::::PAYMENT 2 IS FOUND:::'); 
                        
                        decimal pAmt = 0.00; 
                        
                        if(paymentAmount.containsKey(p.id)){
                            
                            pAmt = paymentAmount.get(p.Id); 
                            fieldvalues.add(new ServiceLeads360.FieldValues('Payment 2 Amount',String.valueOf(pAmt)));
                            fieldvalues.add(new ServiceLeads360.FieldValues('Payment 2 Date',String.valueOf(newPayments.get(p.Id).nu_dse__Schedule_Date__c)));
                            
                            if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                                leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'40');
                            }
                            
                        }
                        
                        if(p.nu_dse__transaction_status__c == 'Failed'){
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'59');
                        }
                    }
                }
            }
            
            if(programPaymentOrder.get(pId).containsKey(3)){
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(3)){
                    
                    if(newPayments.containsKey(p.Id)){
                        
                        System.debug('::::::::PAYMENT 3 IS FOUND:::'); 
                        
                        
                        decimal pAmt = 0.00; 
                        
                        if(paymentAmount.containsKey(p.id)){
                            
                            pAmt = paymentAmount.get(p.Id); 
                            fieldvalues.add(new ServiceLeads360.FieldValues('Payment 3 Amount',String.valueOf(pAmt)));
                            fieldvalues.add(new ServiceLeads360.FieldValues('Payment 3 Date',String.valueOf(newPayments.get(p.Id).nu_dse__Schedule_Date__c)));
                            
                            if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                                
                                leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'79');  
                            }
                            
                        }
                        
                        if(p.nu_dse__transaction_status__c == 'Failed'){
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'38');
                        }
                    }
                }
            }
            
            if(programPaymentOrder.get(pId).containsKey(4)){
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(4)){
                    
                    if(newPayments.containsKey(p.Id)){
                        
                        System.debug('::::::::PAYMENT 4 IS FOUND:::'); 
                        
                        
                        decimal pAmt = 0.00; 
                        
                        if(paymentAmount.containsKey(p.id)){
                            
                            pAmt = paymentAmount.get(p.Id); 
                            
                            
                            
                            if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                                
                                leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'34');  
                            }
                        }
                        
                        if(p.nu_dse__transaction_status__c == 'Failed'){
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'135');
                        }
                    }
                }
            }
            System.debug('::::fieldValues'+fieldValues);
            
            
            
            if(programs.get(pId).External_Id__c !=null){
                
                leads.add(new ServiceLeads360.Lead(programs.get(pId).External_Id__c,fieldValues));
                
            }
            
        }
        
        ServiceLeads360 lead360 = new ServiceLeads360(); 
        String response = lead360.modifyLeadPayments(leads);
        
        if(leadStatus.size()>0){
            lead360.modifyLeadStatus(leadStatus);
        }
        
        return response;
    }
    
    
    public static String modifyLeadsPayments2( list<id> paymentIds){
        
        
        Map<id,nu_dse__Payment__c> newPayments = new Map<id,nu_dse__payment__c>();
        // To collect Program and all its payments. 
        Map<id,List<nu_dse__Payment__c>> program_Payments = new Map<id,List<nu_dse__Payment__c>>(); 
        
        // To Collect Program and All its payments in order. <program,Month1,{payment1, payment2}> <program,Month2,{payment3, payment4}>
        
        Map<Id,Map<integer,list<nu_dse__Payment__c>>> programPaymentOrder = new   Map<Id,Map<integer,list<nu_dse__Payment__c>>>();
        
        List<ServiceLeads360.FieldValues> fieldValues ; 
        
        List<ServiceLeads360.Lead> leads = new List<ServiceLeads360.Lead>(); 
        // To Collect payment and its Order, <payment1Id, 1>, <payment2Id,1>, <payment3Id,2>, <payment4Id,2> for twice monthly payment 
        
        Map<Id,Integer> paymentOrder = new Map<id,Integer>();   
        
        set<id> programIds = new set<id>();
        
        Map<id,Decimal> paymentAmount = new Map<id,decimal>(); // map<paymentId, su
        
        Map<string,string> leadStatus = new Map<string,string>(); 
        
        for(nu_dse__Payment__c payment:[select id,nu_dse__program__c,nu_dse__Amount__c,nu_dse__Schedule_Date__c from nu_dse__Payment__c where id in: paymentIds]){
            
            programIds.add(payment.nu_dse__Program__c);
            
            newPayments.put(payment.Id,payment);
            
        }
        
        for(nu_dse__Payment__c payment: [select id,nu_dse__Amount__c,nu_dse__Schedule_Date__c,lastmodifiedDate,nu_dse__transaction_status__c,nu_dse__Program__c,nu_dse__Program__r.nu_dse__Payment_Frequency__c,nu_dse__Program__r.nu_dse__Program_length__c from nu_dse__Payment__c where nu_dse__Program__c in : programIds and recordType.Developername='Draft' and nu_dse__Amount__c != 50   order by nu_dse__schedule_Date__c]){
            
            
            if(!program_Payments.containsKey(payment.nu_dse__Program__c)){
                
                program_Payments.put(payment.nu_dse__Program__c, new List<nu_dse__Payment__c>());
            }
            
            if(program_Payments.containsKey(payment.nu_dse__Program__c)){
                
                
                program_Payments.get(payment.nu_dse__Program__c).add(payment);
                
            }
            
            
            
        }
        
        
        Map<id,nu_dse__Program__c> programs = new Map<id,nu_dse__Program__c>([select id,nu_dse__Payment_Frequency__c,nu_dse__Program_length__c,External_Id__c from nu_dse__Program__c where id in: programIds]);
        
        for(Id pId: program_Payments.keySet()){
            
            integer plength = 0 ;
            integer paymentFrequency = 1; 
            
            paymentFrequency = programs.get(pId).nu_dse__Payment_Frequency__c=='Monthly' ? 1:2; 
            
            plength = (integer)programs.get(pId).nu_dse__Program_length__c; 
            
            if(!programPaymentOrder.containsKey(pId)){
                
                programPaymentOrder.put(pId,new Map<integer,List<nu_dse__Payment__c>>());
                
                
            }
            integer m = 1; // m for month
            integer completed = 0;
            decimal completedAmt = 0.00; 
            for( integer p = 0 ; p< program_Payments.get(pId).size() ; p++  ){
                
                
                
                //nu_dse__Payment__c p: program_Payments.get(pId)
                
                if(!programPaymentOrder.get(pId).containsKey(m)){
                    
                    programPaymentOrder.get(pId).put(m,new List<nu_dse__Payment__c>());
                }
                if(programPaymentOrder.get(pId).containsKey(m)){
                    
                    programPaymentOrder.get(pId).get(m).add(program_Payments.get(pId)[p]);
                    
                }
                
                paymentOrder.put(program_Payments.get(pId)[p].Id,m);
                
                if( program_Payments.get(pId)[p].nu_dse__transaction_status__c == 'Completed' || program_Payments.get(pId)[p].nu_dse__transaction_status__c == 'Cleared'){
                    
                    completed +=1; 
                    completedAmt += program_Payments.get(pId)[p].nu_dse__Amount__c; 
                    
                    paymentAmount.put(program_Payments.get(pId)[p].Id,completedAmt);
                }
                
                
                
                
                
                if(completed == paymentFrequency){
                    
                    m++; 
                    
                    completed =0; 
                    completedAmt =0.00;
                }
                
                
                if(m==5){
                    
                    break;
                }
                
            }
            
        }
        
        for(id pId: programPaymentOrder.keySet()){
            
            String leadId = pId;  
            
            fieldValues = new  List<ServiceLeads360.FieldValues>(); 
            
            
            
            // payment 1: 
            System.debug('Payment order 1: '+programPaymentOrder.get(pId));
            System.debug('Payment order 2:'+ programPaymentOrder.get(pId).get(2));
            System.debug('ProgrampaymentOrder size:'+ programPaymentOrder.keySet().size());
            
            ServiceLeads360.FieldValues paymentAmountField ;  
            ServiceLeads360.FieldValues paymentDateField ;  
            
            if(programPaymentOrder.get(pId).containsKey(1)){ 
                
                
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(1)){
                    
                    
                    
                    decimal pAmt = 0.00; 
                    
                    if(paymentAmount.containsKey(p.id) && (p.nu_dse__transaction_status__c=='Completed'||p.nu_dse__transaction_status__c=='Cleared')){
                        
                        pAmt = paymentAmount.get(p.Id); 
                        
                        System.debug('::::::::PAYMENT 1 IS FOUND:::');
                        
                        paymentAmountField = new ServiceLeads360.FieldValues('Payment 1 Amount',String.valueOf(pAmt)); 
                        
                        paymentDateField = new ServiceLeads360.FieldValues('Payment 1 Date',String.valueOf(p.nu_dse__Schedule_Date__c));
                        
                        if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'39');
                            
                        }
                        
                    }
                    
                    if(p.nu_dse__transaction_status__c == 'Failed'){
                        
                        leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'58');
                    }
                    
                }
            }
            
            if(programPaymentOrder.get(pId).containsKey(2)){
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(2)){
                    
                    System.debug('programPaymentOrder'+programPaymentOrder.get(pId).get(2));
                    
                    
                    decimal pAmt = 0.00; 
                    
                    if(paymentAmount.containsKey(p.id) && (p.nu_dse__transaction_status__c=='Completed'||p.nu_dse__transaction_status__c=='Cleared') ){
                        
                        pAmt = paymentAmount.get(p.Id); 
                        
                        System.debug('::::::::PAYMENT 2 IS FOUND:::'); 
                        paymentAmountField = new ServiceLeads360.FieldValues('Payment 2 Amount',String.valueOf(pAmt));
                        paymentDateField = new ServiceLeads360.FieldValues('Payment 2 Date',String.valueOf(p.nu_dse__Schedule_Date__c));
                        
                        
                        if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'40');
                        }
                        
                    }
                    
                    if(p.nu_dse__transaction_status__c == 'Failed'){
                        
                        leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'59');
                    }
                    
                }
            }
            
            if(programPaymentOrder.get(pId).containsKey(3)){
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(3)){
                    
                    
                    
                    
                    
                    decimal pAmt = 0.00; 
                    
                    if(paymentAmount.containsKey(p.id) && ((p.nu_dse__transaction_status__c=='Completed'||p.nu_dse__transaction_status__c=='Cleared'))){
                        
                        pAmt = paymentAmount.get(p.Id); 
                        
                        System.debug('::::::::PAYMENT 3 IS FOUND:::'); 
                        paymentAmountField = new ServiceLeads360.FieldValues('Payment 3 Amount',String.valueOf(pAmt));
                        paymentDateField = new ServiceLeads360.FieldValues('Payment 3 Date',String.valueOf(p.nu_dse__Schedule_Date__c));
                        
                        if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'79');  
                        }
                        
                    }
                    
                    if(p.nu_dse__transaction_status__c == 'Failed'){
                        
                        leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'38');
                    }
                    
                }
            }
            
            if(programPaymentOrder.get(pId).containsKey(4)){
                for(nu_dse__Payment__c p: programPaymentOrder.get(pId).get(4)){
                    
                    
                    
                    decimal pAmt = 0.00; 
                    
                    System.debug('Payment '+ p);
                    
                    if(paymentAmount.containsKey(p.id) && (p.nu_dse__transaction_status__c=='Completed'||p.nu_dse__transaction_status__c=='Cleared')){
                        
                        pAmt = paymentAmount.get(p.Id); 
                        
                        
                        
                        if(programs.containsKey(pId) && programs.get(pId).External_Id__c !=null){
                            
                            System.debug('::::::::PAYMENT 4 IS FOUND:::'); 
                            
                            
                            leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'34'); 
                            paymentAmountField = null; 
                            paymentDateField = null;
                        }
                    }
                    
                    if(p.nu_dse__transaction_status__c == 'Failed'){
                        
                        leadStatus.put(string.valueOf(programs.get(pId).External_Id__c),'135');
                    }
                    
                }
            }
            
            
            if (paymentAmountField != null) {
                
                fieldvalues.add(paymentAmountField);
            }
            if (paymentDateField != null) {
                
                fieldValues.add(paymentDateField);
            }
            
            System.debug('::::fieldValues'+fieldValues);
            
            
            
            if(programs.get(pId).External_Id__c !=null){
                
                leads.add(new ServiceLeads360.Lead(programs.get(pId).External_Id__c,fieldValues));
                
            }
            
        }
        
        ServiceLeads360 lead360 = new ServiceLeads360(); 
        String response = lead360.modifyLeadPayments(leads);
        
        if(leadStatus.size()>0){
            lead360.modifyLeadStatus(leadStatus);
        }
        
        return response;
    }
    
    //S20-489 starts
   /* public static void updateLastSettlementDate(Map<Id, nu_dse__Payment__c> newPymt ){
        map<Id, nu_dse__Offer__c> offerMap = new map<Id, nu_dse__Offer__c>();
        set<String> ofrIds = new Set<String>();
        
        if(newPymt != null && newPymt.size()>0){
            for(nu_dse__Payment__c payment: newPymt.values()){
                if(payment.nu_dse__Offer__c != Null){
                    offerMap.put(payment.nu_dse__Offer__c, new nu_dse__Offer__c(Id=payment.nu_dse__Offer__c, Last_Settlement_Payment_Date__c=payment.nu_dse__Schedule_Date__c));
                }
            } 
        }
        
        if(offerMap != null && offerMap.size()>0){
            update offerMap.values();
        }
    }*/
    //S20-489 ends
    
}