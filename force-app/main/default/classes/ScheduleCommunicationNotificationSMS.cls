/*
    Description : To execute the SMS communication notification batch
*/

global with sharing class ScheduleCommunicationNotificationSMS implements Schedulable {
    
    global Integer batchSize = 5;
    
    public void execute(SchedulableContext SC) {
        
        system.debug('batchSize-->'+batchSize);
        Database.executeBatch(new Batch_CommunicationNotificationBySMS(), batchSize);
    }
}