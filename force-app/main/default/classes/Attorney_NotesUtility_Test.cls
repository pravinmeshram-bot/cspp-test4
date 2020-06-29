/*
* Class to Test Attorney Notes Utility by invoking mock response class
*/
@isTest
public with sharing class Attorney_NotesUtility_Test {
    
    
    //Test with configuration
    public static testmethod void testNotesUtility(){
    	Attorney_Notes_API_Config__c config = new Attorney_Notes_API_Config__c();
    	config.Endpoint__c = 'https://push.leadtrac.net';
    	config.Resource__c = '/api/report/17ab78cb-d3ab-4919-8ebf-0c8884be9850';
    	config.Username__c = 'dev_team';
    	config.Password__c = 'Pass@1234';
    	config.Timestamp_Duration__c = 2;
    	config.API_Batch_Size__c = 2000;
    	config.Last_Timestamp__c = DateTime.parse('01/01/2019 12:00 AM');
    	
    	insert config;  
    	
    	Test.startTest();
    	// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new Attorney_NotesUtility_MockResponse());
    	
    	Attorney_NotesUtility.getAttorneyNotes_Future();
    	Test.stopTest();
    	Attorney_NotesUtility notesUtility = new Attorney_NotesUtility();
    }
    
    //Test class for exceptions
    public static testmethod void testNotesUtilityWithException(){
    	Attorney_Notes_API_Config__c config = new Attorney_Notes_API_Config__c();
    	config.Endpoint__c = 'https://push.leadtrac.net';
    	config.Resource__c = '/api/report/17ab78cb-d3ab-4919-8ebf-0c8884be9850';
    	config.Username__c = 'dev_team';
    	config.Password__c = 'Pass@1234';
    	config.Timestamp_Duration__c = 2;
    	config.API_Batch_Size__c = 2000;
    	config.Last_Timestamp__c = DateTime.parse('01/01/2019 12:00 AM');
    	
    	insert config;  
    	
    	// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new Attorney_NotesUtility_MockResponse());
    	
    	Attorney_NotesUtility.getAttorneyNotes();
    }
    
    //Test class for exceptions
    public static testmethod void testNotesUtilitySchedule(){
    	Attorney_Notes_API_Config__c config = new Attorney_Notes_API_Config__c();
    	config.Endpoint__c = 'https://push.leadtrac.net';
    	config.Resource__c = '/api/report/17ab78cb-d3ab-4919-8ebf-0c8884be9850';
    	config.Username__c = 'dev_team';
    	config.Password__c = 'Pass@1234';
    	config.Timestamp_Duration__c = 2;
    	config.API_Batch_Size__c = 2000;
    	config.Last_Timestamp__c = DateTime.parse('01/01/2019 12:00 AM');
    	
    	insert config;  
    	
    	// Set mock callout class
        Test.setMock(HttpCalloutMock.class, new Attorney_NotesUtility_MockResponse());
    	
    	Test.startTest();
    	
    	//Schedule Attorney Notes class
		Datetime nextRunTime = System.now().addMinutes(2);
        system.debug('##nextRunTime:'+nextRunTime);
        String cronString = '' + nextRunTime.second() + ' ' +
        						nextRunTime.minute() + ' ' +
        						nextRunTime.hour() + ' ' +
        						 '20 ' +
        						nextRunTime.month() + ' ? ' + nextRunTime.year();
        system.debug('##cronString:'+cronString);
        System.schedule('GetAttorney-'+nextRunTime,  cronString, new Attorney_GetNotesScheduler());
    	
    	
    	Test.stopTest();
    }
}