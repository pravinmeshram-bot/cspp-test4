/***************************************
 @Class Name : PaymentTrigHandler
 @Modification History : *1.0 - added a method part of ND-345 
 ****************************************/

public class PaymentTrigHandler {
    //S20-489 starts
    public static void handleAfterInsert(Map<Id, nu_dse__Payment__c> newPymt){
        set<String> ofrIds = new Set<String>();
        if(newPymt != null && newPymt.size()>0){
            for(nu_dse__Payment__c payment: newPymt.values()){
                if(payment.nu_dse__Offer__c != null){
                    ofrIds.add(payment.nu_dse__Offer__c);
                }
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            updateLastSettlementDate(ofrIds);
        }
    }
    
    public static void handleAfterUpdate(Map<Id, nu_dse__Payment__c> newPymt, Map<Id, nu_dse__Payment__c> oldPymt){
        set<String> ofrIds = new Set<String>();
        if(newPymt != null && newPymt.size()>0){
            for(nu_dse__Payment__c payment: newPymt.values()){
                if(oldPymt.get(payment.Id).nu_dse__Schedule_Date__c != payment.nu_dse__Schedule_Date__c){
                    if(payment.nu_dse__Offer__c != null){
                        ofrIds.add(payment.nu_dse__Offer__c);
                    }
                }
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            updateLastSettlementDate(ofrIds);
        }
    }
    
    public static void handleAfterDelete(Map<Id, nu_dse__Payment__c> oldPymt){
        set<String> ofrIds = new Set<String>();
        if(oldPymt != null && oldPymt.size()>0){
            for(nu_dse__Payment__c payment: oldPymt.values()){
                if(payment.nu_dse__Offer__c != null){
                    ofrIds.add(payment.nu_dse__Offer__c);
                }
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            updateLastSettlementDate(ofrIds);
        }
    }
    
    public static void updateLastSettlementDate(set<String> ofrIds){
        map<Id, nu_dse__Offer__c> offerMap = new map<Id, nu_dse__Offer__c>();
        if(ofrIds != null && ofrIds.size()>0){
            offerMap = new map<Id, nu_dse__Offer__c>([Select Id, Name, Last_Settlement_Payment_Date__c, 
                                                      (Select Id, Name, nu_dse__Schedule_Date__c From nu_dse__Payments__r
                                                       Where nu_dse__Schedule_Date__c != Null Order By nu_dse__Schedule_Date__c)
                                                      From nu_dse__Offer__c 
                                                      Where Id IN: ofrIds]);
            if(offerMap != null && offerMap.size()>0){
                for(nu_dse__Offer__c ofr: offerMap.values()){
                    if(ofr.nu_dse__Payments__r != null && ofr.nu_dse__Payments__r.size()>0){
                        Integer lastkeyIndex=ofr.nu_dse__Payments__r.size()-1;
                        ofr.Last_Settlement_Payment_Date__c=ofr.nu_dse__Payments__r[lastkeyIndex].nu_dse__Schedule_Date__c;
                    }else{
                        ofr.Last_Settlement_Payment_Date__c=null;
                    }
                    offerMap.put(ofr.Id, ofr);
                }
            }
        }
        
        if(offerMap != null && offerMap.size()>0){
            update offerMap.values();
        }
    }
    //S20-489 ends  
    
    // ND-345 Praveen Start 
    /* @Method Name : lockPaymentsOnProgram_DNLStatus
       @Created By & Date : Praveen - 2020-04-30
       @Description : ND-347 : Lock the payments on Program DNL status
       @Modifictaion History : 
    */
    public static boolean isExecute = true;
    public static void lockPaymentsOnProgram_DNLStatus(List<nu_dse__Payment__c> newPaymentList, Boolean isInsert, Boolean isUpdate, Boolean isDelete){
    
    if(isExecute){
        Boolean ignoreValidation_Flag = [Select Attorney_Ignore_Validation__c From User Where Id = :UserInfo.getUserId()][0].Attorney_Ignore_Validation__c;
        String profileName =[Select Id, Name from Profile where Id=:UserInfo.getProfileId()].Name;
        system.debug('===profile Name==='+profileName);
        if(profileName != 'DNL Payment Processor' && profileName != 'DNL Payments Manager' && profileName != 'DNL Payments Team Member' && profileName != 'DNL Negotiations Manager' && ignoreValidation_Flag == false){
            for(nu_dse__Payment__c paymentInst : newPaymentList){
                if(paymentInst.DNL_Status__c == 'Pre-TILA Signed'){
                    //system.debug('==error===2'+paymentInst);
                    if(paymentInst.nu_dse__Transaction_Status__c != 'Tentative' && isInsert){
                        PaymentTrigHandler.isExecute = false;
                        paymentInst.addError(system.label.Payments_locked);
                    }
                    if(isUpdate || isDelete){
                        PaymentTrigHandler.isExecute = false;
                        paymentInst.addError(system.label.Payments_locked);
                    } 
                }
            }
        }
    }
    
    }
    // ND-345 Praveen End
    
    public static void populateLastPaymentDateOnProgram(List<nu_dse__Payment__c> newPayments, Map<Id, nu_dse__Payment__c> oldPaymentMap, Boolean isUpdate){
        Set<Id> programIds = new Set<Id>();
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        for (nu_dse__Payment__c newPayment: newPayments) {
            system.debug('++++isUpdate++++++'+isUpdate);
            system.debug('++++nw++++++'+newPayment.nu_dse__Schedule_Date__c);
            if (isUpdate) {
                nu_dse__Payment__c oldPayment = oldPaymentMap.get(newPayment.Id);
                if (newPayment.recordTypeId == draftRecordTypeId && newPayment.nu_dse__Schedule_Date__c != null && newPayment.nu_dse__Schedule_Date__c != oldPayment.nu_dse__Schedule_Date__c) {
                    programIds.add(newPayment.nu_dse__Program__c);
                }
            } else {
                if (newPayment.recordTypeId == draftRecordTypeId && newPayment.nu_dse__Schedule_Date__c != null) {
                    programIds.add(newPayment.nu_dse__Program__c);
                }
            }
        }
        system.debug('++++programIds++++++'+programIds);
        if (!programIds.isEmpty()) {
            Map<Id, List<nu_dse__Payment__c>> paymentsByProgramId = new Map<Id, List<nu_dse__Payment__c>>();
            for (nu_dse__Payment__c payment: [Select Id, Name, nu_dse__Schedule_Date__c, nu_dse__Program__c from nu_dse__Payment__c where recordTypeId = :draftRecordTypeId and nu_dse__Schedule_Date__c != null and nu_dse__Program__c IN :programIds order by nu_dse__Schedule_Date__c DESC]) {
                if (!paymentsByProgramId.containsKey(payment.nu_dse__Program__c)) {
                    paymentsByProgramId.put(payment.nu_dse__Program__c, new List<nu_dse__Payment__c>{payment});
                } else {
                    paymentsByProgramId.get(payment.nu_dse__Program__c).add(payment);
                }
            }
            system.debug('++++paymentsByProgramId++++++'+paymentsByProgramId);
            List<nu_dse__Program__c> programsToUpdate = new List<nu_dse__Program__c>();
            for (nu_dse__Program__c program: [Select Id, Name, Last_Payment_Date__c from nu_dse__Program__c where Id IN :paymentsByProgramId.keySet()]){
                program.Last_Payment_Date__c = paymentsByProgramId.get(program.Id)[0].nu_dse__Schedule_Date__c;
                programsToUpdate.add(program);
            }
            system.debug('++++programsToUpdate++++++'+programsToUpdate);
            if (!programsToUpdate.isEmpty()) {
                update programsToUpdate;
            }
        }
    }
}