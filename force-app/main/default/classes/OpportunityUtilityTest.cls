@isTest
public class OpportunityUtilityTest {
    
    @isTest
    public Static void testSendEmail(){
         
        Account acc = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        acc.PersonBirthdate = system.today().AddDays(-10000);
        acc.nu_dse__SSN__c = '254789658';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        
        Opportunity opp = new Opportunity(Name='test opportunity', StageName='Close Won', CloseDate=date.today(),AccountId = acc.Id);
        insert opp;
        
        OrgWideEmailAddress[] addresses = [SELECT Id,address FROM OrgWideEmailAddress LIMIT 1];
        
        string result = OpportunityUtility.sendEmail(opp.id,addresses[0].address);
        
        System.assertEquals('Email Sent Successfully!', result);
        
    }
    
    
}