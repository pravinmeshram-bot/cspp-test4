global class Attorney_CalculateFuturePaymentSchedular implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Attorney_CalculateFuturePaymentBatch(),100);
    }

}