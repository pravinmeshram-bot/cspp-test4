@isTest
public class BatchSyncTaskbasedOnGroupTask_Test {

    @isTest
    static void testSyncTaskbasedOnGroupTask(){
        
        List<nu_dse__Group_Task__c> groupTasks = new List<nu_dse__Group_Task__c>{            
            new nu_dse__Group_Task__c(nu_dse__Status__c = 'Completed', nu_dse__Subject__c = 'Test Subject')
        };        
        insert groupTasks;
        
        List<Task> tasks = new List<Task>{
            new Task(nu_dse__Group_Task__c = groupTasks[0].Id, Status = 'Not Started')
        };
        insert tasks;
        
        Test.startTest();                   
            Database.executeBatch(new BatchSyncTaskbasedOnGroupTask() , 50);      
        Test.stopTest(); 
        
        List<Task> taskList = [SELECT Id, Status, nu_dse__Group_Task__c FROM Task]; 
        
        System.assertEquals(1, taskList.size());
        System.assertEquals('Completed', taskList[0].Status);
        
    }
     
}