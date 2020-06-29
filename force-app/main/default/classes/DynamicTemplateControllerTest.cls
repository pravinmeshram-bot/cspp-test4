@isTest
public class DynamicTemplateControllerTest {
    
    static testMethod void testDynamicTemplate() {
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'CA';
        acc.PersonEmail = 'test@test.com';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
        insert acc;
        
        nu_dse__Program__c p = new nu_dse__Program__c();
        p.nu_dse__Account__c = acc.id;
        p.Import_ID__c = '1234';
        insert p;
        
        Lead l = new Lead();
        l.NDS_File_Number__c = '1234';
        l.lastName = 'test';
        l.Cash_in_Dedicated_Account__c = 1234;
        l.Addnl_Months_with_Loan__c = 1234;
        l.Loan_Amount__c = 1234;
        l.Loan_Term__c = 123;
        l.Status = 'DNL New Lead';
        l.Sub_Status__c = 'New Lead';
        l.Origination_Fee__c = 200;
        l.Unpaid_Program_Fees__c = 200;
        l.Account__c = acc.Id;
        l.Program_Name__c = p.Id;
        insert l;
        
        Prizm_LeadTriggerHandler.isTriggerExecuted = false;
        
        l.Status = 'DNL Not Interested';
        l.Sub_Status__c = 'No Email';
        Update l;
        
        
        DynamicTemplateController d= new DynamicTemplateController();
        d.LeadId = l.Id;
        d.AccountId =l.Account__c;
        d.UserId = UserInfo.getUserId();
        d.ProgramId = l.Program_Name__c;
        //d.PortfolioId = l.Program_Name__r.Portfolio__c;
        d.vfTemplateName = 'Lead_On_Time_Payment_Notification';
        string emailBody = null;
        string subject = null;
        
        if(d.getTemplateContent().contains('::Split::'))
        {
            List<string> emailcontent = d.getTemplateContent().split('::Split::');
            subject = emailcontent[0];
            emailBody = emailcontent[1];
        }
        
        System.assertNotEquals(null, subject);
        System.assertNotEquals(null, emailBody);
    }

    
}