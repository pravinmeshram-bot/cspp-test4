trigger Attorney_FinancialProfileTrigger on nu_dse__Financial_Profile__c (after Update) {
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_FinancialProfileTrigger'];
    if(TriggerFlag.isActive__c && Trigger.New[0].IsAttorney__c){
        Attorney_FinancialProfileHandler.CreateOrUpdateNDSFinancialProfile(trigger.new, trigger.Oldmap);    
    }
}