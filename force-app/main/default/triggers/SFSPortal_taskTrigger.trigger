trigger SFSPortal_taskTrigger on Task(after insert, after update) {

    if ( trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        
        SFSPortal_TaskHandler.sendNotification(trigger.new, trigger.oldMap);    
    }
}