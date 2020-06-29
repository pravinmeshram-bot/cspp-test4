global with sharing class Batch_PopulateStrategyCallDateOnProgram implements Database.Batchable<sObject> {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
       String query = 'SELECT Id, Enrollment_Date__c, Attorney__c FROM nu_dse__Program__c ' +
                       ' WHERE Enrollment_Date__c != null AND Expected_Strategy_Call_Date__c = null';
       
       system.debug('query--->'+query);
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Program__c> programList) {
       
        List<nu_dse__Program__c> programUpdateList = new List<nu_dse__Program__c> ();
        Map<String, Holiday> holidayMap = Holidays.getHolidaysMap();
        
        for (nu_dse__Program__c programInst :programList) {
            
            Date attorneyStrategyDate;
            Date nonAttorneyStrategyDate;
            
            nu_dse__Program__c programInstance = new nu_dse__Program__c ();
            programInstance.Id = programInst.Id;
            
            //For Attorney programs add 8 months else add 6months..
            if (programInst.Attorney__c == True) {
                
                attorneyStrategyDate = PolicyGroupAssignmentHandler.getPreviousWorkingDay(holidayMap, programInst.Enrollment_Date__c.addMonths(8), True, True);
                programInstance.Expected_Strategy_Call_Date__c = attorneyStrategyDate;
                
            } else {
            
                nonAttorneyStrategyDate = PolicyGroupAssignmentHandler.getPreviousWorkingDay(holidayMap, programInst.Enrollment_Date__c.addMonths(6), True, True);
                programInstance.Expected_Strategy_Call_Date__c = nonAttorneyStrategyDate;
            }
            programUpdateList.add(programInstance);
        }
        
        update programUpdateList;
    }
    
    
    global void finish(Database.BatchableContext BC) {
    
        
    }   
}