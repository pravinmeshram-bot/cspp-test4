// Trigger to Close the SFS case under the Tradeline if one payment is successfully completed to offer under Tradeline
trigger paymentTrigger_CloseSFSCase on nu_dse__Payment__c (after insert, after update) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    
        PaymentHandler_CloseSFSCase.closeSFSCaseOnStlmntCmplt(Trigger.OldMap, Trigger.new);
    }
    
    
     /*start: Converting process builder(Cancel tasks once NSF payment is completed or makeup payment created) to Code - To fix CPU time out error by Praveen - 04.03.2020 */
    if(Trigger.isAfter && Trigger.isupdate){
    PaymentHandler_CloseSFSCase.cancelTasksOnPaymentStatusUpdate(Trigger.NewMap , Trigger.OldMap);
    }
    // End
}