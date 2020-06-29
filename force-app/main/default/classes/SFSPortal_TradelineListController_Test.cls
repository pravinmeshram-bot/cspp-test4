@isTest
public class SFSPortal_TradelineListController_Test {

    public static testMethod void tradeLineMethod() {
       
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Account account2 = SFSPortal_TestRecordCreator.createCreditorAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor'));
        insert account2;
        //update for CSPP-375
       // account2.nu_dse__CFT_Synced__c = true;
       // account2.nu_dse__Active_Creditor__c = true;
       // update account2;
        
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        List<nu_dse__TradeLine__c>  tradelineList = new List<nu_dse__TradeLine__c > {SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id),
                                                                                    SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id),
                                                                                    SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id)};
        
        tradelineList[0].nu_dse__Current_Stage__c = 'Payment Plan Active';
        tradelineList[0].Normalized_Original_Creditor__c = 'Test Account 1';
        tradelineList[1].nu_dse__Current_Stage__c = 'Payment Plan Suspended';
        tradelineList[1].Normalized_Original_Creditor__c = 'Test Account 1';
        tradelineList[2].nu_dse__Current_Stage__c = 'Settled Unpaid';
        tradelineList[2].Normalized_Original_Creditor__c = 'Test Account 1';
        insert tradelineList;
        
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c> {SFSPortal_TestRecordCreator.createoffer(programInstance.Id, tradelineList[0].Id, 500, 100, 2, 2),
                                                                       SFSPortal_TestRecordCreator.createoffer(programInstance.Id, tradelineList[1].Id, 500, 100, 2, 2),
                                                                       SFSPortal_TestRecordCreator.createoffer(programInstance.Id, tradelineList[2].Id, 500, 100, 2, 2)};
        offerList[0].Authorization_Received_Date__c = System.today();
        offerList[1].Authorization_Received_Date__c = System.today();
        offerList[2].Authorization_Received_Date__c = System.today();
        insert offerList ;
        
        offerList[0].nu_dse__Status__c = 'Payment Plan Active';
        offerList[1].nu_dse__Status__c = 'Payment Plan Active';
        offerList[2].nu_dse__Status__c = 'Canceled';
        update offerList;
        
        tradelineList[0].nu_dse__Current_Stage__c = 'Settled';
        tradelineList[1].nu_dse__Current_Stage__c = 'Payment Plan Active';
        tradelineList[2].nu_dse__Current_Stage__c = 'Removed from Program';
        update tradelineList;
        
        Id settlmentRecodTypeId = SFSPortal_Utility.getRecordTypeId('nu_dse__Payment__c', 'Settlement'); 
        
        nu_dse__Payment__c payment1 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment1.nu_dse__Transaction_Status__c = 'Pending'; 
        payment1.nu_dse__Schedule_Date__c = System.today();
        payment1.recordTypeId = settlmentRecodTypeId ;
        payment1.nu_dse__Offer__c = offerList[0].Id;
        insert payment1;
        
        nu_dse__Payment__c payment2 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment2.nu_dse__Schedule_Date__c = System.today();
        payment2.recordTypeId = settlmentRecodTypeId ;
        payment2.nu_dse__Transaction_Status__c = 'Pending';
        payment2.nu_dse__Dont_Consider__c = false;  
        payment2.nu_dse__Offer__c = offerList[1].Id;
        insert payment2;
        
        nu_dse__Payment__c payment3 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment3.nu_dse__Schedule_Date__c = System.today();
        payment3.recordTypeId = settlmentRecodTypeId ;
        payment3.nu_dse__Transaction_Status__c = 'Pending';
        payment3.nu_dse__Dont_Consider__c = false;  
        payment3.nu_dse__Offer__c = offerList[2].Id;
        insert payment3;
        
        ContentVersion contentVersionInstance = SFSPortal_TestRecordCreator.createContentVersion();
        insert contentVersionInstance;
        
        List<ContentVersion> contentVersionList  = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInstance.Id];
        ContentDocumentLink contentLink = SFSPortal_TestRecordCreator.createContentDocumentLink(contentVersionList[0].ContentDocumentId,account1.Id);
        insert contentLink;
            
        System.runAs(user1) { 
                     
            Test.startTest();
                
                nu_dse__Group_Task__c receipt = SFSPortal_TradelineListController.getGroupTaskInstance();
                receipt.Creditor_Name__c = 'test creditor';
                receipt.Creditor_Balance__c = 45;
                receipt.nu_dse__Subject__c ='Trade Line';
                receipt.nu_dse__Related_To__c = programInstance.Id;
                SFSPortal_TradelineListController.saveReceipt(receipt);
                
                nu_dse__Group_Task__c groupTaskInstance = [SELECT Id FROM nu_dse__Group_Task__c where id=:receipt.id];
                
                try {                    
                    
                    SFSPortal_TradelineListController.getTradelineInstance(receipt.Id);                    
                } catch(Exception e) {
        
                    system.assert(e.getMessage() != null);
                }                   
                try {                    
                    
                    SFSPortal_TradelineListController.deleteRecord(groupTaskInstance.Id);                    
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                SFSPortal_TradelineListController.TradelineListWrapper wrapper = SFSPortal_TradelineListController.getDefaultValues();
                SFSPortal_TradelineListController.TradelineListWrapper wrapper1 = SFSPortal_TradelineListController.getDefault();
                try {                    
                
                    SFSPortal_TradelineListController.deleteDocument(contentLink.contentDocumentId);        
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
             
            Test.stopTest();
            system.assertEquals(true, wrapper!=null);
        }
    }
    
    public static testMethod void exceptionMethod() {
          
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
            
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        insert programInstance;
        
        nu_dse__Group_Task__c receipt = new nu_dse__Group_Task__c(Creditor_Name__c = 'test creditor', Creditor_Balance__c = 45);
         
        Test.startTest();
        
            System.runAs(user1) {
               try {
               
                   SFSPortal_TradelineListController.saveReceipt(receipt);
               } catch(Exception e) {
               
                   system.assertEquals('Script-thrown exception', e.getMessage());
               }
            }
        Test.stopTest();
   
   } 
   public static testMethod void searchMethod() {
        
         List<Creditor_Standardization__c> creditorStandard = new List<Creditor_Standardization__c>{
            new Creditor_Standardization__c(Name = 'testCreditor1',Creditor_Name__c = 'creditor1',Category__c = 'Citibank'),
            new Creditor_Standardization__c(Name = 'testCreditor2',Creditor_Name__c = 'creditor2',Category__c = 'Citibank')
        };
        insert creditorStandard;
        
        Test.startTest();
            try {
                SFSPortal_CustomLookupController.getSearchResult('te', 'Creditor_Standardization__c','Category__c,Creditor_Name__c','');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            try {
                
                SFSPortal_CustomLookupController.getSearchResult('te', 'Contact','Name','');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            try {
                
                SFSPortal_CustomLookupController.getSearchResult('te', 'Contact','Name','WHERE Name != null');
            } catch(Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        Test.stopTest();
    }
}