@isTest
public class UploadSettlementLetter_Test {
    
    @testSetup
    static void setupData() {
        
        Id clientRecTypeId;
        Id creditorRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        if(acctRecTypeMap.containsKey('Creditor')) {
            
            creditorRecTypeId = acctRecTypeMap.get('Creditor').getRecordTypeId();
        }
                       
        Account acc = new Account();
        
        if (clientRecTypeId != null) {
        
            acc.FirstName = 'Test Account ';
            acc.LastName = 'Record';
            acc.RecordTypeId = clientRecTypeId; 
            acc.Phone = '0987654321';
        }
        insert acc;
        
        Account creditorAcc = new Account();
        
        creditorAcc.FirstName = 'Test Account 1';
        creditorAcc.LastName = 'Record';
        creditorAcc.RecordTypeId = clientRecTypeId; 
        creditorAcc.Phone = '0987654321';
        
        
       // insert creditorAcc;
        
        nu_dse__Program__c pgm= new nu_dse__Program__c(nu_dse__Account__c = acc.id, Array_Status__c = '39856');
        insert pgm;
        
        nu_dse__TradeLine__c t1 = new nu_dse__TradeLine__c (nu_dse__Original_Debt__c=50000, nu_dse__Program__c=pgm.Id);
        //t1.nu_dse__Original_Creditor__c = creditorAcc.Id;
        t1.SFS_Current_Balance__c = 1;
        insert t1;
        
        nu_dse__Offer__c off = new nu_dse__Offer__c(nu_dse__TradeLine__c = t1.Id, Tradeline_Litigation_Status__c='Lit', Latest_Offer__c=True);
        insert off;
               
    }
    
    @isTest
    static void uploadSettlementTest() {
        
        String response;
        Account accIns = [SELECT Id, Box_Folder_Name__c FROM Account LIMIT 1];
        String offId = String.valueOf([SELECT Id FROM nu_dse__Offer__c LIMIT 1].Id);
        
        Date currentDate = System.today();
        String todayDate = currentDate.month() + '/' + currentDate.day() + '/' + currentDate.year();
        
        List<nu_dse__Tradeline__c> tradelineList = [SELECT Id, Name FROM nu_dse__Tradeline__c LIMIT 1];
        
        String tradelineName = 'Test Tradeline Name';
        
        if (tradelineList.isEmpty() == False) {
            
            tradelineName = tradelineList[0].Name;
        }
        
        Test.startTest();
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/ClientService';
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response = res;
            List<UploadSettlementLetter.Tradeline> tradelines = new List<UploadSettlementLetter.Tradeline>();
            tradelines = UploadSettlementLetter.getLatestOffers();            
            System.assertEquals(1, tradelines.size());
            System.assertEquals('Record', tradelines[0].lastName);
            
            response = UploadSettlementLetter.getSettlementLetters(accIns.Box_Folder_Name__c , '47725', String.valueOf(offId) , tradelineName, 'False', 'TestDocumentName', 'Test Creditor', '100', 'Summons', todayDate, '100','100');                            
            System.assertEquals('Letter Upload Failed !!!', response);
            System.assertEquals(1, [SELECT Id FROM nu_dse__Error_Log__c].size());
            System.assertEquals(2, [SELECT Id FROM Summon__c].size());
            
            response = UploadSettlementLetter.getSettlementLetters(accIns.Box_Folder_Name__c , '37725', String.valueOf(offId), tradelineName, 'False', 'TestDocumentName', 'Test Creditor', '100', 'Summons', todayDate, '100','100');                          
         //   System.assertEquals('Array Status and Letter Uploaded were Updated Successfully. And Tradeline Updated Successfully.', response);
System.assertEquals('Array Status and Letter Uploaded were Updated Successfully. And Tradeline Updated Successfully.Array Status Updated Successfully.', response);
            response = UploadSettlementLetter.getSettlementLetters(accIns.Box_Folder_Name__c , '37725',tradelineName, '' , '', 'TestDocumentName', 'Test Creditor', '100', 'Summons', todayDate, '100','100');                          
            System.assertEquals('Array Status Updated Successfully.', response);

            response = UploadSettlementLetter.getSettlementLetters('23457' , '37725', String.valueOf(offId) , tradelineName, 'False', 'TestDocumentName', 'Test Creditor', '100', 'Summons', todayDate, '100','100');                          
            System.assertEquals('Client does not exist with 23457 !!!', response);

            response = UploadSettlementLetter.getSettlementLetters('' , '', String.valueOf(offId), tradelineName, 'False', 'TestDocumentName', 'Test Creditor', '100', 'Summons', todayDate, '100','100');                          
            System.assertEquals('Client number or array status cannot be empty!!!', response);
            
        Test.stopTest();
        
    }
}