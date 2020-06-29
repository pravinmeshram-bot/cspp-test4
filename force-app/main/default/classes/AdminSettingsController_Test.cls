@isTest 
public class AdminSettingsController_Test {
     static testMethod void accountAndProgram() 
     {
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
        Test.StartTest(); 
            PageReference pageRef = Page.healthtabpage; 
            pageRef.getParameters().put('pid', String.valueOf(programInstance.Id));
            Test.setCurrentPage(pageRef);
            AdminSettingsController testAccPlan = new AdminSettingsController();
            testAccPlan.inviteClientAndCoClient();  
        Test.StopTest();
     }

     
}