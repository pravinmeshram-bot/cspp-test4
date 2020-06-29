@isTest
public class GetDebts_Test {
    
   @isTest static void testGetDebts() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        Id clientRecTypeId;
        
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
        
        nu_dse__TradeLine__c tradeLine = new nu_dse__TradeLine__c();
        tradeLine.nu_dse__Account__c = acc.Id;    
        tradeLine.nu_dse__Minimum_Payment_Amount__c = 200;
        tradeLine.nu_dse__Last_Payment_Date__c = system.today()+3; 
        tradeLine.nu_dse__Original_Debt__c = 123;
        insert tradeLine;
        
        Test.startTest();
            List<GetDebts.Debt> newDebt = GetDebts.doPost(acc.clientNumber__c);
        Test.stopTest();
        
        List<nu_dse__TradeLine__c> newTrade = [SELECT Name FROM nu_dse__TradeLine__c];
        System.assertEquals(newDebt[0].debtName, newTrade[0].Name);
   }

}