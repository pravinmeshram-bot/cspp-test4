/**
 * Name			:		DelRAMPaymentsBatchSchedule
 * Date			:		11/20/2019
 * Author		:		Amit Goyal
 * Description	:		Created for S20-433
*/

global class DelRAMPaymentsBatchSchedule implements Schedulable{
	public static String sched = '0 00 05 * * ?';  //Every Day at Midnight 

    global static String scheduleMe() {
        DelRAMPaymentsBatchSchedule ctrl = new DelRAMPaymentsBatchSchedule();
        return System.schedule('My batch Job', sched, ctrl);
    }

    global void execute(SchedulableContext sc) {
        DelRAMPaymentsBatchCtrl pob = new DelRAMPaymentsBatchCtrl();
        ID batchprocessid = Database.executeBatch(pob, 50);           
    }
}