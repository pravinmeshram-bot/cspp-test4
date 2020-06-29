global class Attorney_GetNotesScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {
    	Attorney_NotesUtility.getAttorneyNotes_Future();
    	scheduleNextJobs();
    }

	private void scheduleNextJobs(){
		Attorney_Notes_API_Config__c config = [Select Id, Endpoint__c, Resource__c, Username__c, Password__c, Timestamp_Duration__c, API_Batch_Size__c, Last_Timestamp__c from Attorney_Notes_API_Config__c limit 1];
        Datetime nextRunTime = System.now().addMinutes(Integer.valueOf(config.Timestamp_Duration__c));
        String cronString = '' + nextRunTime.second() + ' ' +
        						nextRunTime.minute() + ' ' +
        						nextRunTime.hour() + ' ' +
        						nextRunTime.day() + ' ' +
        						nextRunTime.month() + ' ? ' + nextRunTime.year();
        System.schedule('GetAttorneyNotes-'+nextRunTime,  cronString, new Attorney_GetNotesScheduler());
	}
}