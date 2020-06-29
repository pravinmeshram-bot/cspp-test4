trigger programTrigger_RoundRobinAssignment on nu_dse__Program__c (before update) {
    
    if (trigger.isBefore == True && trigger.isUpdate == True) {
    
        ProgramHandlerRoundRobinAssign.roundRobinAssignment(trigger.new, trigger.oldMap);
    }
}