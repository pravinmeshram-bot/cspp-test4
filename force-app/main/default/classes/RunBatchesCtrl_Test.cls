@isTest
public class RunBatchesCtrl_Test {
    
    @isTest
    public static void executeSmsBatchTest() {
        
        Test.startTest();
        
        RunBatchesCtrl.executeSmsBatch();
        
        Database.executeBatch(new nu_dse.Batch_CommunicationNotificationBySMS(), 1);
        
        RunBatchesCtrl.executeSmsBatch();
        
        Test.stopTest();
        
        System.Assert(ApexPages.getMessages().isEmpty() == False);
        System.AssertEquals('SMS Batch is already running!', ApexPages.getMessages()[0].getSummary());
        
    }
    
    @isTest
    public static void executeEmailBatchTest() {
        
        Test.startTest();
        
        RunBatchesCtrl.executeEmailBatch();
        
        Database.executeBatch(new nu_dse.Batch_CommunicationNotificationByEmail(), 1);
        
        RunBatchesCtrl.executeEmailBatch();
        
        Test.stopTest();
        
        System.Assert(ApexPages.getMessages().isEmpty() == False);
        System.AssertEquals('Email Batch is already running!', ApexPages.getMessages()[0].getSummary());
    }
    
    @isTest
    public static void executeVBBatchTest() {
        
        Test.startTest();
        
        RunBatchesCtrl.executeVBBatch();
        
        Database.executeBatch(new nu_dse.Batch_CommunicationNotificationByVoiceBC(), 1);
        
        RunBatchesCtrl.executeVBBatch();
        
        Test.stopTest();
        
        System.Assert(ApexPages.getMessages().isEmpty() == False);
        System.AssertEquals('Voice Broad Cast Batch is already running!', ApexPages.getMessages()[0].getSummary());
    }
}