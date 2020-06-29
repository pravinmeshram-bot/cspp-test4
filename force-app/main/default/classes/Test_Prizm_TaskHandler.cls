@isTest
public class Test_Prizm_TaskHandler {

    @isTest
    public Static void TestMethod1(){
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'CA';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        acc.Attorney__c = true;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
        insert acc;
        
        nu_dse__Program__c p = new nu_dse__Program__c();
        p.nu_dse__Account__c = acc.id;
        p.Import_ID__c = '1234';
        p.Attorney__c = true;
        p.Draft_Plan_ID__c = '1234';
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
        insert l;
        
        LeadStatusMapping__c ls = new LeadStatusMapping__c();
        ls.Name = 'Not Available';
		ls.Sub_Status__c = 'Not Available';
        ls.Status_List__c = 'DNL Call Attempt 1,DNL Call Attempt 2,DNL Call Attempt 3,DNL Call Attempt 4,DNL Call Attempt 5,DNL Call Attempt 6,DNL Call Attempt 7,DNL Call Attempt 8,DNL Call Attempt 9,DNL Call Attempt 10';
		insert ls;
        
        Task t = new Task();
        t.Subject = 'Test';
        t.WhoId = l.Id;
        
        t.Due_Date_Time__c = System.now();
        t.Status='Completed';
        t.Call_Result__c = 'Not Available';
        insert t;
        
    }
    
    @isTest
    public Static void TestMethod2(){
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.NDS_File_Number__c = '1234';
        acc.PersonMailingState = 'CA';
        acc.nu_dse__SSN__c = 'ABBHBD6876';
        acc.Attorney__c = true;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Attorney Client').getRecordTypeId();
        insert acc;
        
        Opportunity o = new Opportunity();
        o.Amount = 1000;
        o.Additional_months_with_loan__c = 12;
        o.Name = 'Test Test';
        o.CloseDate = Date.today()+1;
        //o.Applicant_State__c = 'Joint';
        o.AccountId = acc.Id;
        o.StageName = 'DNL-Prospecting';
        insert o;
    
        Task t = new Task();
        t.WhatId = O.Id;
        t.Status = 'Not Started';
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('DNL Task').getRecordTypeId();
        t.ActivityDate = Date.today();
        t.Description = 'Test Description';
        t.Due_Date_Time__c = System.now();
        t.Priority = 'Normal';
        t.OwnerId = UserInfo.getUserId();
        insert t;
        Task t1=[Select id,ActivityDate,Description,RecordTypeId from Task Where id=:t.Id];
        t1.ActivityDate=Date.today()+1;
        t1.Description='New Updated Task';
        Update t1;
        
    }
    
}