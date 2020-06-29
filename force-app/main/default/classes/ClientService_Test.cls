@isTest
public class ClientService_Test {

    public static String accountSObj = Account.sObjectType.getDescribe().getName();
    
    static testMethod void testClientService() {
        
        List<String> clientIdList = new List<String>();
        List<Decimal> dec = new List<Decimal>();
        dec.add(785412678);
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        List<RecordType> accRectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Client' AND 
                       SObjectType =: accountSObj AND isActive = True];
                       
        Account accObj = new Account();
        
        if (!accRectypeList.isEmpty()) {
        
            accObj.FirstName = 'test ';
            accObj.LastName = 'Record';
            accObj.nu_dse__client_number__c = 785412678;
            accObj.RecordTypeId = accRectypeList[0].Id;
        }
        insert accObj;
        
        nu_dse__Program__c pgm= new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accObj.id;
        pgm.Array_Status__c = '39856';
        insert pgm;
        
        List<Account> newAcc = [SELECT id, clientNumber__c FROM Account WHERE FirstName='test'];
 
        for(Account acc : newAcc) {
            clientIdList.add(acc.clientNumber__c);
        }
        
        Test.startTest();
            
          // List<ClientService.Client> client = ClientService.getClients(dec);  
           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
           req.requestURI = '/services/apexrest/ClientService';
           req.httpMethod = 'GET';
           RestContext.request = req;
           RestContext.response = res;
           List<ClientService.Client> clientIns = new List<ClientService.Client>();
           clientIns = ClientService.getAllClients();
           List<ClientService.Client> clientIns2 = ClientService.getClients(clientIdList);
                    
        Test.stopTest();  
        
        //System.assertEquals('785412678', client[0].ClientNumber);   
       // System.assertEquals('39856', client[0].CurrentStatus);   
    }
}