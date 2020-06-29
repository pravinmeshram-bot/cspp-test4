@isTest
public class GroupTaskHandler_Test {

    @isTest
    public static void insertGroupTask_Test(){
        
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
        
        Group queue = new Group();
        queue.Name = 'Negotiations Associate';
        insert queue;
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram();
        programList.add(programInstance);
        insert programList;
        List<nu_dse__Program__c> programListChecker = new List<nu_dse__Program__c>([SELECT Id, OwnerId FROM nu_dse__Program__c WHERE Id = :programList[0].Id]);
        List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>();
        nu_dse__Group_Task__c groupTask = new nu_dse__Group_Task__c();
        groupTask.nu_dse__Subject__c = 'New Negotiation';
        groupTask.nu_dse__Related_To__c = programInstance.Id;
        groupTask.OwnerId = queue.Id;
        System.debug('programListChecker[0].OwnerId-->'+programListChecker[0].OwnerId);
        System.debug('groupTask.nu_dse__Related_To__c-->'+groupTask.nu_dse__Related_To__c);
        System.debug('queue.Id-->'+queue.Id);
        groupTaskList.add(groupTask);
        insert groupTaskList;
        
        List<nu_dse__Group_Task__c> taskChecker = new List<nu_dse__Group_Task__c>([SELECT Id, OwnerId FROM nu_dse__Group_Task__c WHERE ID IN :groupTaskList]);
        System.assertEquals(programListChecker[0].OwnerId, taskChecker[0].OwnerId);
    }
}