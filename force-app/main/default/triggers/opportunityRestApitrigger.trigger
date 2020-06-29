trigger opportunityRestApitrigger on Opportunity (after insert, before insert) {

    if(Trigger.isBefore){
        SendOpportunityAccountUsingRestApi.OpportunityBeforeInsert();
    }
    
    if(Trigger.isAfter){
        SendOpportunityAccountUsingRestApi.CopyTradelinePaymentsFromLead(trigger.new);
        SendOpportunityAccountUsingRestApi.getOppDataJSON(trigger.newMap.keySet());
    }
}