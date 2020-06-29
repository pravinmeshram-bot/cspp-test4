/* Date : 09-27-2019
 * Author : Amit Goyal
 * Description : Unit test cases for SFSPortal_AFSettlementCtrl
 */

@isTest
public class SFSPortal_AFSettlementCtrlTest {
	@testsetup static void setupTestData() {
        
        List<Account> accountList = new List<Account>();
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.Phone = '1231231231';
        account1.nu_dse__Home_Phone__c = null;
        
        accountList.add(account1);
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor');
        
        Account account2 = new Account(Name = 'Test',RecordTypeId = recordTypeId);
        account1.Phone = '1231231231';
        accountList.add(account2);
        
        insert accountList;
        
        List<OrgWideEmailAddress> OrgWideEmailInst = [SELECT Id, DisplayName FROM OrgWideEmailAddress LIMIT 1];
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Name = 'Canyon';
        
        if (OrgWideEmailInst.isEmpty() == False) {
            
            portfolioInstance.OWD_Email_Name__c = OrgWideEmailInst[0].DisplayName;
        }
        
        insert portfolioInstance;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.Invitation_Attempt__c = 'Re-Invitation 1';
        insert programInstance;
        
        Account accInstance = [SELECT Id, PersonContactId FROM Account WHERE Id = :account1.Id];
        
        /*nu_dse__Group_Task__c  gtInstance = SFSPortal_TestRecordCreator.groupTaskInstance(programInstance.Id, 'Request to add a new tradeline');
        nu_dse__Group_Task__c  bankGTInstance = SFSPortal_TestRecordCreator.groupTaskInstance(programInstance.Id, 'Request to update bank info');
        
        List<nu_dse__Group_Task__c> groupTaskList = new List<nu_dse__Group_Task__c>();
        groupTaskList.add(gtInstance);
        groupTaskList.add(bankGTInstance);
        
        insert groupTaskList;*/
        
        nu_dse__TradeLine__c tradelineInst = SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id);
        tradelineInst.SFS_Current_Balance__c = 1;
        insert tradelineInst;
    }
    
    public static testMethod void testConstructor() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        Test.startTest();
        	SFSPortal_AFSettlementCtrl ctrl = new SFSPortal_AFSettlementCtrl();
        	ctrl.programId=String.valueOf(prog.Id);
        	ctrl.init();
        Test.stopTest();
    }
    
    public static testMethod void testSubmit() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        Test.startTest();
        SFSPortal_AFSettlementCtrl ctrl = new SFSPortal_AFSettlementCtrl();
        ctrl.programId=String.valueOf(prog.Id);
        ctrl.init();
        ctrl.isFeeAdvancement=true;
        ctrl.tsk.Total_fund_required__c=1000;
        ctrl.tsk.Funds_need_to_be_available_by_date__c=System.Today();
        ctrl.tsk.Recoup_timeframe__c=System.Today();
        ctrl.selectedTradelines.add(ctrl.tradelines[0].getValue());
        ctrl.tsk.Type_of_Request__c='Advancement';
        ctrl.tsk.Were_additional_funds_requested__c='Yes';
        ctrl.tsk.Perfect_Draft_History__c='Good';
        ctrl.tsk.Settlement_type__c='Other';
        ctrl.tsk.BBB_Attorney_General_complaint__c='Yes';
        ctrl.tsk.Client_s_total_months_in_program__c=5;
        ctrl.tsk.Legal_file_number__c='5545';
        ctrl.tsk.Advancement_Facilitates_Lit_Settlement__c='No';
        ctrl.tsk.How_was_the_client_serviced__c='test';
        try{
            ctrl.submitAdvFundSettlement();
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public static testMethod void testSubmit1() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        Test.startTest();
        SFSPortal_AFSettlementCtrl ctrl = new SFSPortal_AFSettlementCtrl();
        ctrl.programId=String.valueOf(prog.Id);
        ctrl.init();
        ctrl.isFeeAdvancement=true;
        ctrl.tsk.Total_fund_required__c=100;
        ctrl.tsk.Funds_need_to_be_available_by_date__c=System.Today();
        ctrl.tsk.Recoup_timeframe__c=System.Today();
        ctrl.selectedTradelines.add(ctrl.tradelines[0].getValue());
        ctrl.tsk.Type_of_Request__c='Advancement';
        ctrl.tsk.Were_additional_funds_requested__c='Yes';
        ctrl.tsk.Perfect_Draft_History__c='Good';
        ctrl.tsk.Settlement_type__c='Other';
        ctrl.tsk.BBB_Attorney_General_complaint__c='Yes';
        ctrl.tsk.Client_s_total_months_in_program__c=5;
        ctrl.tsk.Legal_file_number__c='5545';
        ctrl.tsk.Advancement_Facilitates_Lit_Settlement__c='No';
        ctrl.tsk.How_was_the_client_serviced__c='test';
        try{
            ctrl.submitAdvFundSettlement();
        }catch(Exception e){}
        Test.stopTest();
    }
    
    public static testMethod void testResetRequest() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        Test.startTest();
        SFSPortal_AFSettlementCtrl ctrl = new SFSPortal_AFSettlementCtrl();
        ctrl.programId=String.valueOf(prog.Id);
        ctrl.init();
        ctrl.isFeeAdvancement=true;
        ctrl.tsk.Total_fund_required__c=1000;
        ctrl.tsk.Funds_need_to_be_available_by_date__c=System.Today();
        ctrl.tsk.Recoup_timeframe__c=System.Today();
        ctrl.selectedTradelines.add(ctrl.tradelines[0].getValue());
        ctrl.tsk.Type_of_Request__c='Advancement';
        ctrl.tsk.Were_additional_funds_requested__c='Yes';
        ctrl.tsk.Perfect_Draft_History__c='Good';
        ctrl.tsk.Settlement_type__c='Other';
        ctrl.tsk.BBB_Attorney_General_complaint__c='Yes';
        ctrl.tsk.Client_s_total_months_in_program__c=5;
        ctrl.tsk.Legal_file_number__c='5545';
        ctrl.tsk.Advancement_Facilitates_Lit_Settlement__c='No';
        ctrl.tsk.How_was_the_client_serviced__c='test';
        try{
            ctrl.resetRequest();
        }catch(Exception e){}
    }
}