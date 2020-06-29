/**
 * Name      :    DelRAMPaymentsBatchCtrl
 * Date      :    11/21/2019
 * Author    :    Amit Goyal
 * Description  :    Created for S20-433
*/

global class DelRAMPaymentsBatchCtrl implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Id draftRTId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id feeRTId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        list<String> transStatus = new list<String>{'Completed', 'Cleared', 'Failed', 'Cancelled'};
        String soqlStr = 'Select Id, Name From nu_dse__Payment__c';
        soqlStr += ' Where RecordTypeId =: feeRTId';
        soqlStr += ' AND nu_dse__Advance_Payment__r.RecordTypeId =: draftRTId';
        soqlStr += ' AND nu_dse__Advance_Payment__r.Processor__c like \'RAM%\'';
        soqlStr += ' AND nu_dse__Advance_Payment__r.nu_dse__Transaction_Status__c IN: transStatus';
        system.debug('### soqlStr: '+soqlStr);
        return Database.getQueryLocator(soqlStr);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Payment__c> feePayments)
    {
        system.debug('### feePayments size: '+feePayments.size());
        if(feePayments != null && feePayments.size()>0){
            delete feePayments;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}