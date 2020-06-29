/* Date : 14-03-2019
 * Author : Team IDev
 * Description : Unit test cases for SFSPortal_CommunityTemplateController
 */
@isTest
public class SFSPortal_CommunityTemplateCtrl_Test {
    
    public static testMethod void initTest() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        insert account1;
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        Account accInstance = [SELECT Id, PersonContactId FROM Account WHERE Id = :account1.Id];
        
        User userInstance = SFSPortal_TestRecordCreator.createCommunityUser(accInstance.PersonContactId);
        insert userInstance;
                            
        OrgWideEmailAddress orgEmail = [select Id, IsAllowAllProfiles, DisplayName, Address FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE LIMIT 1];
                            
        
        Test.startTest();
            
            System.runAs(userInstance) {
                
                SFSPortal_CommunityTemplateController controllerInst = new SFSPortal_CommunityTemplateController();
                controllerInst.actionString = 'ChangePassword';
               // System.assertEquals(controllerInst.uiInstance != null, true);
                
                SFSPortal_CommunityTemplateController controllerInst1 = new SFSPortal_CommunityTemplateController();
                controllerInst1.actionString = 'InMaintenance';
                //System.assertEquals(controllerInst1.uiInstance != null, true);
                
                try {
                
                    controllerInst.passwordString = 'Test 1234';
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Confirm password cannot be blank');
                }
                
                try {
                
                    controllerInst.confirmPasswordString = 'Test 1234';
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Password cannot be blank');
                }
                
                try {
                
                    controllerInst.passwordString = 'Test 1234';
                    controllerInst.confirmPasswordString = 'TEst 123';
                    
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Password and confirm password should match');
                }
                
                try {
                
                    controllerInst.passwordString = 'Test 1234';
                    controllerInst.confirmPasswordString = 'Test 1234';
                    
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Password and confirm password should match');
                }
            }
            
        Test.stopTest(); 
    }

     public static testMethod void initTest1() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        insert account1;
        
        portfolio__c portfolioInstance1 = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance1.Active_Status__c = true;
        insert portfolioInstance1 ;
        
        nu_dse__Program__c programInstance1 = SFSPortal_TestRecordCreator.createProgram(null, null);
        programInstance1.Portfolio__c = portfolioInstance1.Id;
        insert programInstance1;
        
        Account accInstance = [SELECT Id, PersonContactId FROM Account WHERE Id = :account1.Id];
        
        User userInstance1 = SFSPortal_TestRecordCreator.createCommunityUser(accInstance.PersonContactId);
        insert userInstance1;
        
        Test.startTest();
            
            System.runAs(userInstance1) {
                
                SFSPortal_CommunityTemplateController controllerInst = new SFSPortal_CommunityTemplateController();
                controllerInst.actionString = 'ChangePassword';
                
                try {
                
                    controllerInst.passwordString = 'Test 1234';
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Confirm password cannot be blank');
                }
                
                try {
                
                    controllerInst.confirmPasswordString = 'Test 1234';
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Password cannot be blank');
                }
                
                try {
                
                    controllerInst.passwordString = 'Test 1234';
                    controllerInst.confirmPasswordString = 'TEst 123';
                    
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Password and confirm password should match');
                }
                
                try {
                
                    controllerInst.passwordString = 'Test 1234';
                    controllerInst.confirmPasswordString = 'Test 1234';
                    
                    controllerInst.changeUserPasssword();
                } catch(Exception e) {
                
                    System.assertEquals(e.getMessage(), 'Password and confirm password should match');
                }
            }
            
        Test.stopTest(); 
     }
}