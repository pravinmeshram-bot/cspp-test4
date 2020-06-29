/* Date : 01-11-2018
 * Author : Team IDev
 */
@isTest
public class SFSPortal_ADHOCPaymentController_Test {
    
    @testSetup 
    public static void setup() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        User user2 = user1;
        user2.Email = 'test@test.com';
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.nu_dse__Payment_Frequency__c = 'Twice Monthly';
        insert programInstance;
        
        nu_dse__Bank_Account__c bankInstance = SFSPortal_TestRecordCreator.createBankAccount(programInstance.Id);
        insert bankInstance;
        
        Id draftRecordId = SFSPortal_utility.getRecordTypeId('nu_dse__Payment__c', 'Draft'); 
        
        nu_dse__Payment__c payment1 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment1.nu_dse__Transaction_Status__c = 'Cancelled'; 
        payment1.nu_dse__Schedule_Date__c = System.today();
        insert payment1;
        
        nu_dse__Payment__c payment2 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment2.nu_dse__Schedule_Date__c = System.today().AddDays(2);
        payment2.recordTypeId = draftRecordId ;
        payment2.nu_dse__Transaction_Status__c = 'Pending';
        payment2.nu_dse__Dont_Consider__c = false;   
        insert payment2;
        
        nu_dse__Payment__c payment3 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment3.nu_dse__Schedule_Date__c = System.today().AddDays(3);
        payment3.recordTypeId = draftRecordId ;
        payment3.nu_dse__Transaction_Status__c = 'Pending';
        payment3.nu_dse__Dont_Consider__c = false;   
        insert payment3;
        
        Task taskInstance = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance.NSF_Payment__c = payment3.Id;
        insert taskInstance;
    }
    
    /*
    public static testMethod void testMinicalandar() {
        
        Id proflieId = [select id from profile where name='Customer Community User'].id;
         
        List<User> user1List = [SELECT Id, profileId FROM USER WHERE profileId =:proflieId ];
        System.runAs(user1List[0]) { 
            Test.startTest();
            
                List<nu_dse__Payment__c> paymentList = ADHOCPaymentController.getDraftPayments(system.today().month(), system.today().year());
                system.assertEquals(False, paymentList.isEmpty());
            Test.stopTest(); 
        }
    }
    */
    
    public static testMethod void testADHOCPayment() {
        
        Id proflieId = [select id from profile where name='Customer Community User'].id;
        List<User> user1List = [SELECT Id, profileId FROM USER WHERE profileId =:proflieId AND UserName = 'tester@noemail.com'];
        
        List<Account> accountList = [SELECT ID FROM Account];
        List<nu_dse__Bank_Account__c> bankList = [SELECT Id FROM nu_dse__Bank_Account__c];
        
        nu_dse__Payment__c cancelPayment = [SELECT Id FROM nu_dse__Payment__c WHERE nu_dse__Transaction_Status__c = 'Cancelled' LIMIT 1];
        List<nu_dse__Payment__c> pendingPayment = [SELECT Id, nu_dse__Schedule_Date__c, recordTypeId, nu_dse__Dont_Consider__c, nu_dse__Transaction_Status__c FROM nu_dse__Payment__c WHERE nu_dse__Transaction_Status__c = 'Pending']; 
        
        ContentVersion contentVersionInstance = SFSPortal_TestRecordCreator.createContentVersion();
        insert contentVersionInstance;
        
        List<ContentVersion> contentVersionList  = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInstance.Id];
        ContentDocumentLink contentLink = SFSPortal_TestRecordCreator.createContentDocumentLink(contentVersionList[0].ContentDocumentId,accountList[0].Id);
        insert contentLink;
        
        System.runAs(user1List[0]) { 
            Test.startTest();
            
                SFSPortal_ADHOCPaymentController.getDefaultValue(new Map<String, String>{'offset' => '0', 'paymentStatus'=>'Pending'}, true, true);
                
                try {                    
                    
                    nu_dse__Group_Task__c groupTask = SFSPortal_ADHOCPaymentController.getGroupTaskInstance();
                    SFSPortal_ADHOCPaymentController.saveRecord(groupTask,'Bank');  
                               
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                
                try {                    
                    
                    nu_dse__Group_Task__c groupTask = SFSPortal_ADHOCPaymentController.getGroupTaskInstance();
                    SFSPortal_ADHOCPaymentController.saveRecord(groupTask, 'Payment');
                    
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                
                try {                    
                    
                    nu_dse__Group_Task__c groupTask = SFSPortal_ADHOCPaymentController.getGroupTaskInstance();
                    SFSPortal_ADHOCPaymentController.saveRecord(new nu_dse__Group_Task__c(), 'Payment');
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                
                nu_dse__Group_Task__c groupTask = SFSPortal_ADHOCPaymentController.getGroupTaskInstance();
                
                try {
                    
                    SFSPortal_ADHOCPaymentController.deletePaymentRecord(groupTask.Id);
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {
                    
                    SFSPortal_ADHOCPaymentController.deleteDocument(contentLink.ContentDocumentId);
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                
                try {
                                       
                    SFSPortal_ADHOCPaymentController.getReschedulePayment(cancelPayment.Id);
                } catch(Exception e) {
                    
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {
                                       
                    SFSPortal_ADHOCPaymentController.createMakeupPaymentForFailurePayment(String.valueOf(System.today()), pendingPayment[0].Id);
                } catch(Exception e) {
                    
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                
            Test.stopTest(); 
            //List<nu_dse__Group_Task__c> paymentgroupTask = [SELECT Id FROM nu_dse__Group_Task__c WHERE Send_for_E_Sign_Adhoc__c = true];
            //system.assertEquals(false, paymentgroupTask.isEmpty());
            //List<nu_dse__Group_Task__c> bankgroupTask = [SELECT Id FROM nu_dse__Group_Task__c WHERE Send_For_E_Sign_Bank_Info__c = true];
            //system.assertEquals(false, bankgroupTask.isEmpty());
        }
    }
    
}