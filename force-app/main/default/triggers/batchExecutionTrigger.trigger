trigger batchExecutionTrigger on Batch_Execution__c (after insert, before update, after update) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && Trigger.new.size() == 1) {
    
        BatchExecutionHandler.initateScheduler(Trigger.new, Trigger.oldMap, Trigger.isInsert);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
    
        BatchExecutionHandler.abortScheduler(Trigger.new, Trigger.oldMap);
    }
}