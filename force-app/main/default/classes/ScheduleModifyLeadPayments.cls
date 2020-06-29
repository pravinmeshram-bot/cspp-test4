global class ScheduleModifyLeadPayments implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        
        Database.executeBatch(new Batch_ModifyLeadPayments(), 1);
    }
}