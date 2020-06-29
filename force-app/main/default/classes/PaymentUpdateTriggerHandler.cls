public class PaymentUpdateTriggerHandler {

    public static void updatePaymentAsDontOverride(List<nu_dse__Payment__c> newPaymentList, Map<Id,nu_dse__Payment__c> oldPaymentMap) {
    
        if (newPaymentList  != null && newPaymentList.isEmpty() == FALSE && oldPaymentMap != null && oldPaymentMap.isEmpty() == FALSE) {
        
            Id recTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            
            if (recTypeId != null) {
            
                for (nu_dse__Payment__c payment : newPaymentList) {
                
                    if(payment.RecordTypeId == recTypeId && (payment.nu_dse__Retainer_Fee__c != oldPaymentMap.get(payment.Id).nu_dse__Retainer_Fee__c || payment.nu_dse__Service_Fee__c != oldPaymentMap.get(payment.Id).nu_dse__Service_Fee__c)) {
                    
                        payment.nu_dse__Dont_Override__c = true;
                    }
                }
            }
            
        }
        
    }
}