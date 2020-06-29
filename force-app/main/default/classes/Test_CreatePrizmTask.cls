@isTest
public class Test_CreatePrizmTask {
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
        t.Status = 'Completed';
        t.ActivityDate = Date.today()+1;
        t.Due_Date_Time__c = System.now();
        t.Priority = 'High';  //Priority
        t.OwnerId = UserInfo.getUserId();
        insert t;
        
        try{
            CreatePrizmTasks.CreateTasks();
        } 
        catch(Exception e){
            system.debug('MEssage'+e.getMessage());
        }
      
    }

}