@isTest
public class Batch_ExecutePaymentFlows_Test {

    @testsetup static void setupTestData() {
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{           
            new nu_dse__Program__c(
                nu_dse__Total_Debt__c = 10000
            )
        };
        
        insert programs;

        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();

        List<nu_dse__Payment__c> payments = new List<nu_dse__Payment__c>{           
            new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 100, 
                nu_dse__Schedule_Date__c = System.today().addDays(5), 
                RecordTypeId = draftRecordTypeId, 
                nu_dse__Transaction_Status__c = 'Failed', 
                nu_dse__Is_Makeup_Payment_Created__c = true, 
                nu_dse__Dont_Consider__c = true,
                Active_NSF_Tasks_Available__c = true
            ), new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 200, 
                nu_dse__Schedule_Date__c = System.today().addDays(6), 
                NSF_Date__c = System.today().addDays(5),
                nu_dse__Is_Makeup_Payment_Created__c = true, 
                nu_dse__Dont_Consider__c = true,
                Active_NSF_Tasks_Available__c = false
            ), new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 300, 
                nu_dse__Schedule_Date__c = System.today().addDays(7),
                RecordTypeId = draftRecordTypeId,
                nu_dse__Transaction_Status__c = 'Scheduled'
            )
        };
        insert payments;
        
        List<nu_dse__Payment__c> feePayments = new List<nu_dse__Payment__c>{           
            new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 100, 
                nu_dse__Schedule_Date__c = System.today().addDays(5), 
                RecordTypeId = feeRecordTypeId, 
                nu_dse__Transaction_Status__c = 'Cancelled', 
                nu_dse__Advance_Payment__c = payments[2].Id
            )};
            
        insert feePayments;
        
        Task nsfTask = new Task();
        nsfTask.WhatId = payments[0].Id;
        nsfTask.Status = 'Not Started';
        
        insert nsfTask;
        
        Process_Builder_Batch__c processBuilderInst = Process_Builder_Batch__c.getInstance();
         
        //processBuilderInst.NSF_Task_Creation_While_Payment_Failed__c = true;
        processBuilderInst.Close_Task_If_Make_Up_Payment_Created__c = true;
        processBuilderInst.Program_Status_Reactivate_Fees__c = true;
        
        insert processBuilderInst;
    }

    @isTest
    static void testBatchExecution(){
                        
        Test.startTest();                   
        Database.executeBatch(new Batch_ExecutePaymentFlows() , 50);      
        Test.stopTest();
    }
            
    @isTest
    static void testCloseNSFTask(){
    
        Process_Builder_Batch__c processBuilderInst = Process_Builder_Batch__c.getInstance();
        //processBuilderInst.NSF_Task_Creation_While_Payment_Failed__c = false;
        processBuilderInst.Close_Task_If_Make_Up_Payment_Created__c = true;
        processBuilderInst.Program_Status_Reactivate_Fees__c = false;
        
        update processBuilderInst;
        
        Test.startTest();                   
        Database.executeBatch(new Batch_ExecutePaymentFlows() , 50);      
        Test.stopTest();        
    }    
    
    @isTest
    static void testProgramStatusreactivate(){
    
        Process_Builder_Batch__c processBuilderInst = Process_Builder_Batch__c.getInstance();
        //processBuilderInst.NSF_Task_Creation_While_Payment_Failed__c = false;
        processBuilderInst.Close_Task_If_Make_Up_Payment_Created__c = false;
        processBuilderInst.Program_Status_Reactivate_Fees__c = true;
        
        update processBuilderInst;
        
        Test.startTest();                   
        Database.executeBatch(new Batch_ExecutePaymentFlows() , 50);      
        Test.stopTest();                
    } 
   
    @isTest
    static void testNSFTaskCreation(){
    
        Process_Builder_Batch__c processBuilderInst = Process_Builder_Batch__c.getInstance();
        
        //processBuilderInst.NSF_Task_Creation_While_Payment_Failed__c = true;
        processBuilderInst.Close_Task_If_Make_Up_Payment_Created__c = false;
        processBuilderInst.Program_Status_Reactivate_Fees__c = false;
        
        update processBuilderInst;
        
        Test.startTest();                   
        Database.executeBatch(new Batch_ExecutePaymentFlows() , 50);      
        Test.stopTest();
    } 
}