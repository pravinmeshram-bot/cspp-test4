@isTest
public class Schedule_PauseAccountReviewFlows_Test{

    @isTest
    public static void executeScheduler() {
        
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1); 
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year(); 
            system.schedule('Test ScheduledBatchClass', CRON_EXP, new Schedule_PauseAccountReviewFlows());
        Test.stopTest();
    }
}