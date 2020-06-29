@isTest
public class GetStatusList_Test {
    
   @isTest static void testGetStatusList() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        insert program; 
        
        Test.startTest();
        List<String> str = GetStatusList.doGet();
        Test.stopTest(); 
        
        Set<String> strSet = new Set<String>(str);
        List<nu_dse__Program__c> docList = [SELECT Array_Status__c FROM nu_dse__Program__c WHERE Id =:program.Id];
        System.assertEquals(True, strSet.Contains(docList[0].Array_Status__c));   
    }
}