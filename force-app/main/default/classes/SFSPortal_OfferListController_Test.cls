@isTest 
public class SFSPortal_OfferListController_Test {

    public static testMethod void offerListMethod() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor');
        
        Account account2 = new Account(Name = 'Test',RecordTypeId = recordTypeId);
        insert account2;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
        
        nu_dse__TradeLine__c tradeInstance = SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id);
        tradeInstance.nu_dse__Original_Creditor__c = account2.Id;
        tradeInstance.SFS_Current_Balance__c = 500;
        insert tradeInstance;
        
        nu_dse__Offer__c offerInstance = SFSPortal_TestRecordCreator.createoffer(programInstance.Id, tradeInstance.Id, 100, 50, 5, 5);
        offerInstance.Offer_Created_By__c = user1.Id;
        offerInstance.Tradeline_Litigation_Status__c = 'Non Lit';
        insert offerInstance;
        
        offerInstance.nu_dse__Status__c = 'Client Approved';
        
        Test.startTest();
        
        Task taskinstance = SFSPortal_TestRecordCreator.createTask(offerInstance.Id);
        taskinstance.Subject = 'Obtain Client Auth';
        insert taskinstance;
        
        System.runAs(user1) { 
            
            SFSPortal_OfferListController.DefaultWrapper wrapper = SFSPortal_OfferListController.getOfferInfo(offerInstance.Id);
            SFSPortal_OfferListController.DefaultWrapper wrapper2 = SFSPortal_OfferListController.getOfferList(true);
            
            try {
                
                SFSPortal_OfferListController.updateOfferStatus(offerInstance);
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            offerInstance.nu_dse__Status__c = 'Client Declined';
            
            try {
                
                SFSPortal_OfferListController.updateOfferStatus(offerInstance);
            } catch(Exception e) {
            
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
                
            system.assertEquals(true, wrapper!=null);
            system.assertEquals(true, wrapper2!=null);
        }
        
        offerInstance.nu_dse__Status__c = 'Client Approved';
        
        try {
                    
            SFSPortal_OfferListController.updateOfferStatus(offerInstance);
            
        } catch(Exception e) {
        
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();           
    }
}