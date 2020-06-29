@isTest
public class Test_CreateLendingTask {
 @isTest
    public Static void TestMethod1(){
    	
       //Create user which relate to Negotiator queue
       Group groupDetail = [select Id, Name from Group where Type = 'Queue' AND NAME = 'DNL Negotiatiators' Limit 1];
        //list<User> user1=[SELECT id, name, username, isActive FROM user WHERE id IN (SELECT userOrGroupId FROM groupmember WHERE groupId = :groupDetail.Id)];
        nu_dse__Group_Task__c t = new nu_dse__Group_Task__c();
        //t.WhatId = O.Id;
        t.nu_dse__Subject__c='DNL Neg Test';
        t.nu_dse__Status__c = 'In Progress';
        t.nu_dse__ActivityDate__c = Date.today()+1;
        t.Subject_Picklist__c ='DNL Negotiations Review Request';
        t.Priority__c = 'High';
        t.OwnerId = groupDetail.Id;
        insert t;
        
        
       CreateLendingTask.CreateTasks();
      
    }
}