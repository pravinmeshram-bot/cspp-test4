public class Velocify_ProgrampushScheduler  implements Schedulable{
    public void execute(SchedulableContext sc) {
        List<nu_dse__Program__c> ProgramList = [Select Id from nu_dse__Program__c where Velocify_Integration_Status__c = 'Initiated'];
        Time timeNow = System.now().Time();
        if(!ProgramList.isEmpty()){
            Database.executeBatch(new Velocify_PushProgramBatch(),1);
        }
        Map<String,VelocifyCredentials__c> credList = VelocifyCredentials__c.getAll();
        VelocifyCredentials__c cred = credList.get('VelocifyCredentials');
        DateTime now  = DateTime.now();
        DateTime nextRunTime;
        String cronString = '';
        System.debug('*******'+timeNow);
        System.debug('********'+ timeNow.hour());
        if(timeNow.hour() >= 12 && timeNow.hour()< 14 && cred.Skip_at_12_to_2__c){
            nextRunTime = now.addMinutes(Integer.ValueOf(cred.Interval__c));
            cronString = '' + '0' + ' ' + '0' + ' ' + 
                '14' + ' ' + nextRunTime.day() + ' ' + 
                nextRunTime.month() + ' ? ' + nextRunTime.year();             
        } else {
            
            nextRunTime = now.addMinutes(Integer.ValueOf(cred.Interval__c));
            cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
                nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        }
        System.schedule(Velocify_ProgrampushScheduler.class.getName() + '-' + now.format(), cronString, new Velocify_ProgrampushScheduler());
    }
}