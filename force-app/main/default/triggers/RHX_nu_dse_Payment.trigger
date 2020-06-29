trigger RHX_nu_dse_Payment on nu_dse__Payment__c
    (after delete, after insert, after undelete, after update, before delete) {
    //Added by Mayur for ND-281 to be able to deactivate this trigger in production.
     AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'RHX_nu_dse_Payment'];
    if(TriggerFlag.isActive__c){
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
     if(rollClass != null) {
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        if (trigger.isAfter) {
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'nu_dse__Payment__c'}, null);
        }
    }
}
}