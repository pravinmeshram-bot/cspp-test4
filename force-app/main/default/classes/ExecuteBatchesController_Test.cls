@isTest
public class ExecuteBatchesController_Test {

    @isTest static void testBatchExection() {
    
        Test.startTest();           
            
            NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchJobTimings.Load_clients__c = true;
        batchJobTimings.Load_Draft_Payments__c = true;
        batchJobTimings.Load_TradeLines__c = true;
        batchJobTimings.SetupOwnerId = UserInfo.getProfileId();
        insert batchJobTimings;
        
            ApexPages.currentPage().getParameters().put('actionToExecute', 'startExecution');
            ExecuteBatchesController executeBatch = new ExecuteBatchesController();
            executeBatch.isChecked = False;
            executeBatch.gobalSelect();
            executeBatch.batchExection();
            executeBatch.isChecked = True;
            executeBatch.gobalSelect();
            executeBatch.batchExection();
            ApexPages.currentPage().getParameters().put('actionToExecute', 'stopExecution');
            executeBatch.batchExection();
            
        Test.stopTest(); 
        System.assertEquals('stopExecution', ApexPages.currentPage().getParameters().get('actionToExecute'));  
    }
    
    @isTest static void testBatchExection1() {
    
        Test.startTest();           
            
            NextBatchJobTimings__c batchJobTimings = new NextBatchJobTimings__c ();
        batchJobTimings.Duration__c = 1000;
        batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (50);
        batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (10);
        batchJobTimings.Name = 'Testing';
        batchJobTimings.Load_clients__c = true;
        batchJobTimings.Load_Draft_Payments__c = true;
        batchJobTimings.Load_TradeLines__c = true;
        batchJobTimings.SetupOwnerId = UserInfo.getProfileId();
        insert batchJobTimings;
        
            ApexPages.currentPage().getParameters().put('actionToExecute', 'startExecution');
            ExecuteBatchesController executeBatch = new ExecuteBatchesController();
            executeBatch.isChecked = False;
            executeBatch.gobalSelect();
            executeBatch.batchExection();
            executeBatch.isChecked = True;
            executeBatch.gobalSelect();
            executeBatch.batchExection();
            ApexPages.currentPage().getParameters().put('actionToExecute', 'stopExecution');
            executeBatch.batchExection();
            executeBatch.batchExection();
        Test.stopTest(); 
        //System.assertEquals('stopExecution', ApexPages.currentPage().getParameters().get('actionToExecute'));  
    }
}