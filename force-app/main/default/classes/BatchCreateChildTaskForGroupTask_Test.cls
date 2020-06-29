@isTest
public class BatchCreateChildTaskForGroupTask_Test {

    @isTest
    static void testCreateChildTaskForGroupTask(){
        
        List<nu_dse__Data_Mapping__c> dataMappings = new List<nu_dse__Data_Mapping__c>{
            new nu_dse__Data_Mapping__c(Name = 'GroupTaskToTask', nu_dse__Source_sObject__c = 'Group_Task__c', nu_dse__Target_sObject__c = 'Task')
        }; 
        insert dataMappings;
        
        List<nu_dse__Field_mapping__c> fieldMappings = new List<nu_dse__Field_mapping__c>{
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'Id', nu_dse__Target_Field__c = 'nu_dse__Group_Task__c'),
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'nu_dse__Subject__c', nu_dse__Target_Field__c = 'Subject'),
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'nu_dse__Status__c', nu_dse__Target_Field__c = 'Status')
        };
        insert fieldMappings;                                                                                      
        
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{           
            new nu_dse__Program__c(
                NDS_CREATED_DATE__c = System.Today().AddDays(-200), 
                RUN_PROCESSES_ON_IMPORT__c = False,
                Run_First_Year_Workflow__c = False,
                Attorney__c = True
            )
        };
        insert programs;
        
        List<nu_dse__Group_Task__c> groupTasks = new List<nu_dse__Group_Task__c>{            
            new nu_dse__Group_Task__c(nu_dse__Status__c = 'Not Started', nu_dse__Subject__c = 'Test Subject', nu_dse__Related_To__c = programs[0].Id),
            new nu_dse__Group_Task__c(nu_dse__Status__c = 'Deferred', nu_dse__Subject__c = 'Test Subject 1', nu_dse__Related_To__c = programs[0].Id)
        };        
        insert groupTasks;
        
        List<Task> tasks = [SELECT Id, Status, Subject, nu_dse__Group_Task__c FROM Task]; 
        
        delete tasks;
        
        Test.startTest();                   
            Database.executeBatch(new BatchCreateChildTaskForGroupTask() , 50);      
        Test.stopTest();
        
        List<Task> taskList = [SELECT Id, Status, Subject, nu_dse__Group_Task__c FROM Task]; 
        //System.assertEquals(True, taskList.size()>0);
        
    }
}