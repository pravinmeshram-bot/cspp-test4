@isTest
public class GetUpdatedClients_Test  {
    
   @isTest static void testGetUpdatedClients() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        Id clientRecTypeId;
        String message;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Account acc = new Account();
        acc.nu_dse__client_number__c = 111222;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        insert acc;
               
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program; 
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.params.put('startDate', String.ValueOf(system.today()));
        req.params.put('endDate', String.ValueOf(system.today().addDays(1)));
        RestContext.request = req;
        RestContext.response = res;
        
        RestRequest req1 = RestContext.request;

        String startD = req1.params.get('startDate');
        
        Test.startTest();
        List<GetUpdatedClients.Client> client = GetUpdatedClients.doPOST(system.today(), system.today().addDays(1));
        System.debug(':::Client::'+client);
        List<GetUpdatedClients.Client> client1 =  GetUpdatedClients.doGet();
        System.debug(':::Client1::'+client1);
        Test.stopTest();  
        
        //List<Account> accList = [SELECT Auto_client_number__c FROM Account WHERE Id =:acc.Id];
        
        List<nu_dse__Program__c> programList = [SELECT Array_Status__c, Name FROM nu_dse__Program__c WHERE Id =:program.Id];
        //System.assertEquals(programList[0].Array_Status__c, client1[0].CurrentStatus);  
        //System.assertEquals(programList[0].Name, client[0].ClientNumber);  
    }
}