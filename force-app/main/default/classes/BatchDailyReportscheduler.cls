global class BatchDailyReportscheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        BatchDailyReport b = new BatchDailyReport(); 
        database.executebatch(b,200);
    }
}