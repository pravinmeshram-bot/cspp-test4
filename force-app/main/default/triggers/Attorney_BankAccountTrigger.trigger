trigger Attorney_BankAccountTrigger on nu_dse__Bank_Account__c (after Update) {
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_BankAccountTrigger'];
    if(TriggerFlag.isActive__c && Trigger.New[0].IsAttorney__c){
        Attorney_BankAccountHandler.CreateOrUpdateNDSBankAccount(trigger.new, trigger.Oldmap);    
    }
}