/*
    Description : To execute the Voice Broadcast communication notification batch
*/

global with sharing class ScheduleCommunicationNotificationVoiceBC implements Schedulable {
    
    global Integer batchSize = 5;
    
    public void execute(SchedulableContext SC) {
        
        system.debug('batchSize-->'+batchSize);
        Database.executeBatch(new Batch_CommunicationNotificationByVoiceBC(), batchSize);
    }
}