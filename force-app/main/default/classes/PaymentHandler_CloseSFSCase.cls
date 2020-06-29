public class PaymentHandler_CloseSFSCase {

    
    
    static Set<Id> processedPaymentIds = new Set<Id>();
    
    public static void closeSFSCaseOnStlmntCmplt(Map<Id, nu_dse__Payment__c> oldMap, List<nu_dse__Payment__c> newList) {
    
        
        List<Summon__c> casesTobeUpdated = new List<Summon__c>();
        Set<Id> tradeLineIdSet = new Set<Id>();
        Set<Id> offerIdSet = new Set<Id>();
        Id settlementRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
                
        for (nu_dse__Payment__c newPayment: newList) {
        
            if (newPayment.RecordTypeId == settlementRecordTypeId && (Trigger.isUpdate && processedPaymentIds.contains(newPayment.Id) == false && 
                (oldMap.get(newPayment.Id).nu_dse__Transaction_Status__c != 'Completed' || oldMap.get(newPayment.Id).nu_dse__Transaction_Status__c != 'Cleared')) && 
                (newPayment.nu_dse__Transaction_Status__c == 'Completed') || (newPayment.nu_dse__Transaction_Status__c == 'Cleared')) {
            
                if (String.isNotBlank(newPayment.nu_dse__Offer__c)) {
                    
                    offerIdSet.add(newPayment.nu_dse__Offer__c);
                }
            }
        }
        
        if (offerIdSet.isEmpty() == false) {
        
            for (nu_dse__Offer__c offer: [SELECT Id, nu_dse__Tradeline__c FROM nu_dse__Offer__c WHERE Id IN :offerIdSet]) {
                
                tradeLineIdSet.add(offer.nu_dse__Tradeline__c);
            }
            
            for (Summon__c sfscase : [SELECT Id, Case_Status__c FROM Summon__c WHERE Tradeline__c IN :tradeLineIdSet AND Case_Status__c != 'Completed']) {
            
                sfscase.Case_Status__c = 'Completed';
                casesTobeUpdated.add(sfsCase);
            }
            update casesTobeUpdated;
        }
        
    }
    
    
    /* Start ND-295 : Converting process builder(Cancel tasks once NSF payment is completed or makeup payment created) logic to Code - To fix CPU timeout error by Praveen - 04.03.2020 */
    public static boolean isExecute = true;
    public static void cancelTasksOnPaymentStatusUpdate(Map<Id, nu_dse__Payment__c> newMap, Map<id, nu_dse__Payment__c> oldMap){
        
        if(isExecute){
        system.debug('===entered method===');

        list<id> updatedPymntIds = new list<id>();
        list<task> updateTaskList = new list<task>();
        
        for(string str : newMap.keyset()){
            if(((newMap.get(str).nu_dse__Is_Makeup_Payment_Created__c != oldMap.get(str).nu_dse__Is_Makeup_Payment_Created__c) && newMap.get(str).nu_dse__Is_Makeup_Payment_Created__c && newMap.get(str).nu_dse__Transaction_Status__c == 'Failed') 
            || ((newMap.get(str).nu_dse__Transaction_Status__c != oldMap.get(str).nu_dse__Transaction_Status__c)& oldMap.get(str).nu_dse__Transaction_Status__c == 'Failed' & newMap.get(str).nu_dse__Transaction_Status__c == 'Completed')){
                
            updatedPymntIds.add(str);   
                
            }
        }
            system.debug('===updated pymnt ids ==='+updatedPymntIds);
            try{
            if(!updatedPymntIds.isEmpty()){
            for(task tsk : [select id, ActivityDate, status from task where whatId IN: updatedPymntIds and ActivityDate >= today and status != 'completed']){
                   tsk.status = 'canceled';
                   updateTaskList.add(tsk);
                
            }
            }
            system.debug('===updated task recds ==='+updateTaskList);
            
            if(!updateTaskList.isEmpty()){ 
            update updateTaskList;
            isExecute = false;
            }
            }catch(exception ex){
            system.debug('===exception==='+ex.getMessage());
            }
            }
        }
    
    // End

}