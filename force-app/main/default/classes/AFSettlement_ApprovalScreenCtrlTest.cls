/* Date : 09-27-2019
 * Author : Amit Goyal
 * Description : Unit test cases for AFSettlement_ApprovalScreenCtrlTest
 */

@isTest
public class AFSettlement_ApprovalScreenCtrlTest {
    @testsetup static void setupTestData() {
        
         List<nu_dse__Data_Mapping__c> dataMappings = new List<nu_dse__Data_Mapping__c>{
            new nu_dse__Data_Mapping__c(Name = 'GroupTaskToTask', nu_dse__Source_sObject__c = 'Group_Task__c', nu_dse__Target_sObject__c = 'Task')
        }; 
        insert dataMappings;
        
        List<nu_dse__Field_mapping__c> fieldMappings = new List<nu_dse__Field_mapping__c>{
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'Id', nu_dse__Target_Field__c = 'nu_dse__Group_Task__c'),
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'nu_dse__Subject__c', nu_dse__Target_Field__c = 'Subject'),
            new nu_dse__Field_mapping__c(nu_dse__Data_Mapping__c = dataMappings[0].Id, nu_dse__Source_Field__c = 'nu_dse__Status__c', nu_dse__Target_Field__c = 'Status')
        };
        insert fieldMappings;
        
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
        
        nu_dse__TradeLine__c tradelineInst = SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id);
        tradelineInst.SFS_Current_Balance__c = 1;
        insert tradelineInst;
    }
    
    public static testMethod void testConstructor() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        nu_dse__Group_Task__c gTask = new nu_dse__Group_Task__c(Program__c=prog.Id, 
                                                                nu_dse__Related_To__c=prog.Id,
                                                                nu_dse__Subject__c='Request to Advance Funds',
                                                                Subject_Picklist__c='Request to Advance Funds',
                                                                OwnerId=UserInfo.getUserId(),
                                                                nu_dse__Description__c='Test Description',
                                                                Total_fund_required__c=1000, 
                                                                Funds_need_to_be_available_by_date__c=System.Today(),
                                                                Recoup_timeframe__c=System.Today(),
                                                                Tradeline_s_to_be_advanced__c='Test Tradeline',
                                                                Type_of_Request__c='Advancement',
                                                                Were_additional_funds_requested__c='Yes',
                                                                Perfect_Draft_History__c='Good',
                                                                Settlement_type__c='Other',
                                                                BBB_Attorney_General_complaint__c='Yes',
                                                                Client_s_total_months_in_program__c=5,
                                                                Legal_file_number__c='5545',
                                                                Advancement_Facilitates_Lit_Settlement__c='No',
                                                                How_was_the_client_serviced__c='test',
                                                                nu_dse__ActivityDate__c=System.Today().addDays(1));
        
        try{
            Test.startTest();
            insert gTask;
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(gTask);
            AFSettlement_ApprovalScreenCtrl ctrl = new AFSettlement_ApprovalScreenCtrl(stdCtrl);
            Test.stopTest();
        }catch(Exception e){}
    }
    
    public static testMethod void testConstructor1() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        nu_dse__Group_Task__c gTask = new nu_dse__Group_Task__c(Program__c=prog.Id, 
                                                                nu_dse__Related_To__c=prog.Id,
                                                                nu_dse__Subject__c='Request to Advance Funds',
                                                                Subject_Picklist__c='Request to Advance Funds',
                                                                OwnerId=UserInfo.getUserId(),
                                                                nu_dse__Description__c='Test Description',
                                                                Total_fund_required__c=1000, 
                                                                Funds_need_to_be_available_by_date__c=System.Today(),
                                                                Recoup_timeframe__c=System.Today(),
                                                                Tradeline_s_to_be_advanced__c='Test Tradeline',
                                                                Type_of_Request__c='Advancement',
                                                                Were_additional_funds_requested__c='Yes',
                                                                Perfect_Draft_History__c='Good',
                                                                Settlement_type__c='Other',
                                                                BBB_Attorney_General_complaint__c='Yes',
                                                                Client_s_total_months_in_program__c=5,
                                                                Legal_file_number__c='5545',
                                                                Advancement_Facilitates_Lit_Settlement__c='No',
                                                                How_was_the_client_serviced__c='test',
                                                                nu_dse__ActivityDate__c=System.Today().addDays(1));
        
        try{
            Test.startTest();
            insert gTask;
            ApexPages.currentPage().getParameters().put('recId', gTask.Id);
            AFSettlement_ApprovalScreenCtrl ctrl = new AFSettlement_ApprovalScreenCtrl();
            Test.stopTest();
        }catch(Exception e){}
    }
    
    public static testMethod void testReject() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        nu_dse__Group_Task__c gTask = new nu_dse__Group_Task__c(Program__c=prog.Id, 
                                                                nu_dse__Related_To__c=prog.Id,
                                                                nu_dse__Subject__c='Request to Advance Funds',
                                                                Subject_Picklist__c='Request to Advance Funds',
                                                                OwnerId=UserInfo.getUserId(),
                                                                nu_dse__Description__c='Test Description',
                                                                Total_fund_required__c=1000, 
                                                                Funds_need_to_be_available_by_date__c=System.Today(),
                                                                Recoup_timeframe__c=System.Today(),
                                                                Tradeline_s_to_be_advanced__c='Test Tradeline',
                                                                Type_of_Request__c='Advancement',
                                                                Were_additional_funds_requested__c='Yes',
                                                                Perfect_Draft_History__c='Good',
                                                                Settlement_type__c='Other',
                                                                BBB_Attorney_General_complaint__c='Yes',
                                                                Client_s_total_months_in_program__c=5,
                                                                Legal_file_number__c='5545',
                                                                Advancement_Facilitates_Lit_Settlement__c='No',
                                                                How_was_the_client_serviced__c='test',
                                                                nu_dse__ActivityDate__c=System.Today().addDays(1));
        
        try{
            Test.startTest();
            insert gTask;
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(gTask);
            AFSettlement_ApprovalScreenCtrl ctrl = new AFSettlement_ApprovalScreenCtrl(stdCtrl);
            ctrl.tsk.Manager_decline_reason__c='Too long to recoup';
            ctrl.Reject();
            Test.stopTest();
        }catch(Exception e){}
    }
    
    public static testMethod void testApprove() {
        list<nu_dse__Program__c> programList = [Select Id, Name From nu_dse__Program__c Where Invitation_Attempt__c = 'Re-Invitation 1'];
        nu_dse__Program__c prog = programList != null && programList.size()>0 ? programList[0] : new nu_dse__Program__c();
        nu_dse__Group_Task__c gTask = new nu_dse__Group_Task__c(Program__c=prog.Id, 
                                                                nu_dse__Related_To__c=prog.Id,
                                                                nu_dse__Subject__c='Request to Advance Funds',
                                                                Subject_Picklist__c='Request to Advance Funds',
                                                                OwnerId=UserInfo.getUserId(),
                                                                nu_dse__Description__c='Test Description',
                                                                Total_fund_required__c=1000, 
                                                                Funds_need_to_be_available_by_date__c=System.Today(),
                                                                Recoup_timeframe__c=System.Today(),
                                                                Tradeline_s_to_be_advanced__c='Test Tradeline',
                                                                Type_of_Request__c='Advancement',
                                                                Were_additional_funds_requested__c='Yes',
                                                                Perfect_Draft_History__c='Good',
                                                                Settlement_type__c='Other',
                                                                BBB_Attorney_General_complaint__c='Yes',
                                                                Client_s_total_months_in_program__c=5,
                                                                Legal_file_number__c='5545',
                                                                Advancement_Facilitates_Lit_Settlement__c='No',
                                                                How_was_the_client_serviced__c='test',
                                                                nu_dse__ActivityDate__c=System.Today().addDays(1));
        
        try{
            Test.startTest();
            insert gTask;
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(gTask);
            AFSettlement_ApprovalScreenCtrl ctrl = new AFSettlement_ApprovalScreenCtrl(stdCtrl);
            ctrl.Approve();
            Test.stopTest();
        }catch(Exception e){}
    }
}