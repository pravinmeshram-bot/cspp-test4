@isTest
public class TaskHandler_CreateNoteForDispTask_Test {

    static testMethod void createNotes_Test() {
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        
        insert acc;
        
        Task testTask = new Task();
        testTask.Subject = 'Test Subject';
        testTask.Description = 'Description to Notes';
        testTask.IsNote__c = true;
        testTask.WhatId = acc.Id;
        
        insert testTask;
        
        List<Note> notes = [SELECT Id, Title, Body, ParentId FROM Note WHERE ParentId = :testTask.WhatId]; 
        
        System.assert(notes.size() > 0);
        System.assertEquals(testTask.Subject, notes[0].Title);
        System.assertEquals(testTask.Description, notes[0].Body);
        System.assertEquals(testTask.WhatId, notes[0].ParentId);
    }

}