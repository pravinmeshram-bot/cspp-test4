@isTest
public class ChangeClientStatus_Test {
    
   @isTest static void testChangeClientStatus() {
        
        Id clientRecTypeId;
        List<String> clientIdList = new List<String>();
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account();
        acc1.nu_dse__client_number__c = 111222;
        acc1.nu_dse__Co_First_Name__c = 'TestCo';
        acc1.nu_dse__Client_Status__c = 'New Client';
        acc1.FirstName = 'Test';
        acc1.LastName = 'Test Record';
        acc1.RecordTypeId = clientRecTypeId; 
        acc1.Phone = '1231231232'; 
        accList.add(acc1);
        insert accList;
    
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37727';
        program.nu_dse__Account__c = accList[0].Id;
        insert program; 
        List<Account> newAcc = [SELECT id, Box_Folder_Name__c FROM Account WHERE FirstName='Test'];
 
        for(Account acc : newAcc) {
            clientIdList.add(acc.Box_Folder_Name__c);
        }
       
        Test.startTest();
            ChangeClientStatus.Response newResponse = ChangeClientStatus.doPost(clientIdList, '37721', 'Test Document Name');
        Test.stopTest();
        
        List<nu_dse__Program__c> newPro = [SELECT Array_Status__c FROM nu_dse__Program__c WHERE External_Id__c='Test_CreateTaskData'];
        System.assertEquals(newPro[0].Array_Status__c, '37721');
   }
    @isTest static void testChangeClientStatusFailed() {
        List<String> clientIdList = new List<String>{'CL-1234'};
        try
        {
            Test.startTest();
                ChangeClientStatus.Response newResponse = ChangeClientStatus.doPost(clientIdList , '37721', 'Test Document Name');
            Test.stopTest();        
        }catch (exception e)
        {
            System.assertEquals(e.getMessage(),'Record Id Not Found');

        }
        
        
   }
}