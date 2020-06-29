/*
    Description : To execute the Email communication notification batch
*/

global with sharing class ScheduleCommunicationNotificationEmail implements Schedulable {
    
    global Integer batchSize = 5;
    
    public void execute(SchedulableContext SC) {
        
        system.debug('batchSize-->'+batchSize);
        Database.executeBatch(new Batch_CommunicationNotificationByEmail(), batchSize);
    }
}