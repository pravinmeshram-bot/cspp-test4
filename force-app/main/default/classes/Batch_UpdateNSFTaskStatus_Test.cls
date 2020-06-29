@isTest
public class Batch_UpdateNSFTaskStatus_Test {

    static testMethod void testUpdateNSFTaskStatus() {
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram();
        programInstance.nu_dse__Payment_Frequency__c = 'Twice Monthly';
        insert programInstance;
        
        nu_dse__Program__c programInstance1 = SFSPortal_TestRecordCreator.createProgram();
        programInstance1.nu_dse__Payment_Frequency__c = 'Monthly';
        insert programInstance1;
        
        Id draftRecordId = SFSPortal_utility.getRecordTypeId('nu_dse__Payment__c', 'Draft'); 
        
        List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c payment1 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment1.nu_dse__Transaction_Status__c = 'Cancelled'; 
        payment1.nu_dse__Schedule_Date__c = System.today();
        payment1.nu_dse__Dont_Consider__c = True;
        payment1.nu_dse__Is_Makeup_Payment_Created__c = True;
        paymentList.add(payment1);
        
        nu_dse__Payment__c payment2 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment2.nu_dse__Schedule_Date__c = System.today().AddDays(2);
        payment2.recordTypeId = draftRecordId ;
        payment2.nu_dse__Transaction_Status__c = 'Cancelled';
        payment2.nu_dse__Dont_Consider__c = True;
        payment2.nu_dse__Is_Makeup_Payment_Created__c = True;
        paymentList.add(payment2);
        
        nu_dse__Payment__c payment3 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment3.nu_dse__Schedule_Date__c = System.today().AddDays(3);
        payment3.recordTypeId = draftRecordId ;
        payment3.nu_dse__Transaction_Status__c = 'Cancelled';
        payment3.nu_dse__Dont_Consider__c = True;
        payment3.nu_dse__Is_Makeup_Payment_Created__c = True;   
        paymentList.add(payment3);
        
        nu_dse__Payment__c payment7 = SFSPortal_TestRecordCreator.createPayments(programInstance1.Id);
        payment7.nu_dse__Transaction_Status__c = 'Cancelled'; 
        payment7.nu_dse__Schedule_Date__c = System.today();
        payment7.nu_dse__Dont_Consider__c = True;
        payment7.nu_dse__Is_Makeup_Payment_Created__c = True;
        paymentList.add(payment7);
        
        insert paymentList;
        
        List<nu_dse__Payment__c> childPaymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c payment4 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment4.nu_dse__Schedule_Date__c = System.today();
        payment4.nu_dse__Advance_Payment__c = paymentList[0].Id;
        childPaymentList.add(payment4);
        
        nu_dse__Payment__c payment5 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment5.nu_dse__Schedule_Date__c = System.today();
        payment5.nu_dse__Advance_Payment__c = paymentList[1].Id;
        childPaymentList.add(payment5);
        
        nu_dse__Payment__c payment6 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        payment6.nu_dse__Schedule_Date__c = System.today();
        payment6.nu_dse__Advance_Payment__c = paymentList[2].Id;
        childPaymentList.add(payment6);
        
        insert childPaymentList;
        
        List<Task> taskList = new List<Task>();
        
        Task taskInstance = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance.NSF_Payment__c = payment3.Id;
        taskInstance.Call_Type__c = 'NSF';
        taskInstance.Status = 'Not Started';
        taskList.add(taskInstance);
        
        Task taskInstance2 = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance2.NSF_Payment__c = payment2.Id;
        taskInstance2.Call_Type__c = 'NSF';
        taskInstance2.Status = 'Not Started';
        taskList.add(taskInstance2);
        
        Task taskInstance1 = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance1.NSF_Payment__c = payment1.Id;
        taskInstance1.Call_Type__c = 'NSF';
        taskInstance1.Status = 'Not Started';
        taskList.add(taskInstance1);
        
        Task taskInstance3 = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance3.NSF_Payment__c = String.ValueOf(payment1.Id).substring(0, 15);
        taskInstance3.Call_Type__c = 'NSF';
        taskInstance3.Status = 'Not Started';
        taskList.add(taskInstance3);
        
        Task taskInstance4 = SFSPortal_TestRecordCreator.createTask(programInstance1.Id);
        taskInstance4.NSF_Payment__c = payment7.Id;
        taskInstance4.Call_Type__c = 'NSF';
        taskInstance4.Status = 'Not Started';
        taskList.add(taskInstance4);
        
        insert taskList;
        
        Test.startTest();
            
            Database.executeBatch(new Batch_UpdateNSFTaskStatus());
            
            Database.executeBatch(new Batch_UpdateNSFTaskStatus(new Set<Id>{programInstance1.Id}));
            
        Test.stopTest();  
        
        List<Task> taskResultList = [SELECT Id, Status FROM Task WHERE WhatId =:programInstance.Id AND Status = 'Completed'];
        System.assertEquals(4, taskResultList.size());  
        
        List<Task> taskResultList1 = [SELECT Id, Status FROM Task WHERE WhatId =:programInstance1.Id AND Status = 'Completed'];
        System.assertEquals(1, taskResultList1.size());  
        
    }
}