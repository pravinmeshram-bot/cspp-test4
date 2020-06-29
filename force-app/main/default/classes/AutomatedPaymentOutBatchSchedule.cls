/**
 * Name         :       AutomatedPaymentOutBatchSchedule
 * Date         :       10/03/2019
 * Author       :       Amit Goyal
 * Description  :       Created for S20-396
*/

global class AutomatedPaymentOutBatchSchedule implements Schedulable{
    public static String sched = '0 00 05 * * ?';  //Every Day at Midnight 

    global static String scheduleMe() {
        AutomatedPaymentOutBatchSchedule ctrl = new AutomatedPaymentOutBatchSchedule();
        return System.schedule('My batch Job', sched, ctrl);
    }

    global void execute(SchedulableContext sc) {
    	list<SFDC_AIMMS_Config__mdt> configs = [Select Id, MasterLabel, Current_Stage__c, Portfolio_Name__c, Batch_Size__c,
                                                Record_Type__c, Status__c, Apply_Schedule_Date_Flag__c, Apply_LastModifiedDate_Flag__c 
                                                From SFDC_AIMMS_Config__mdt 
                                                Where MasterLabel = 'Payments Out'];
        Integer batchSize=1;
        if(configs != null && configs.size()>0){
            if(configs[0].Batch_Size__c != null && configs[0].Batch_Size__c>0){
                batchSize=Integer.valueOf(configs[0].Batch_Size__c);
            }
        }
        
        AutomatedPaymentOutBatchCtrl pob = new AutomatedPaymentOutBatchCtrl();
        ID batchprocessid = Database.executeBatch(pob, batchSize);
    }
}