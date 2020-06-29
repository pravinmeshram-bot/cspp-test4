@isTest
public class ProcessEmailToCasesTest {
	@testSetup
    static void setupTestData(){
    	Account acc = new Account(Name='Test Account');
        insert acc;
        
        Contact con = new Contact(LastName='Test Contact', Email='test@test.com', AccountId=acc.Id);
        insert con;
        
        Case cs = new Case(Subject='test case for email S20-270', ContactId=con.Id, AccountId=acc.Id, Status='New', 
                           Origin='Email', Priority='Medium', Description='test parent');
        insert cs;
        
        cs.Status='Closed';
        update cs;
    }
    
    public static testmethod void testChildCaseCreation(){
        list<Account> accList = [Select Id, Name From Account Where Name = 'Test Account' limit 1];
        list<Contact> conList = [Select Id, Name From Contact Where LastName = 'Test Contact' limit 1];
        list<Case> caseList = [Select Id, Subject, CaseNumber From Case Where Subject='test case for email S20-270' limit 1];
        Case cs = new Case(Subject='Re: Sandbox: Strategic Financial Solutions Case # '+caseList[0].CaseNumber+': '+caseList[0].Subject, 
                           Case_Created_Origin__c='agoyal@mindzcloud.com',
                           SuppliedEmail='test@test.com', Status='New', Origin='Email', Priority='Medium', 
                           Description='test parent',
                           ContactId=conList[0].Id, AccountId=accList[0].Id);
        Test.startTest();
        insert cs;
        ProcessEmailToCases.processCases(new list<Id>{cs.Id});
        Test.stopTest();
        list<Case> result = [Select Id, Child_Case__c, ParentId From Case Where Id=: cs.Id];
        //system.assertEquals(true, result[0].Child_Case__c);
        //system.assert(result[0].ParentId != null, 'parent should not be blank');
    }
}