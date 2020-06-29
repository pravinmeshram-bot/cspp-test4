/* Date : 01-11-2018
 * Author : Team IDev
 */
@isTest
public class SFSPortal_ClientsTaskController_Test {
    
    @testSetup 
    public static void setup() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        User user2 = user1;
        user2.Email = 'test@test.com';
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        nu_dse__Payment__c paymentInstance = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        insert paymentInstance;
        
        nu_dse__Payment__c paymentInstance1 = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        insert paymentInstance1;
        
        nu_dse__Payment__c advanceInstance = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        advanceInstance.nu_dse__Advance_Payment__c = paymentInstance1.Id;
        advanceInstance.nu_dse__Is_Makeup_Payment_Created__c = TRUE;
        insert advanceInstance;
        
        Id pendingTaskInfoId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Pending Tasks Info');
        
        Portal_Settings__c portalSetting = SFSPortal_TestRecordCreator.createPortalSettingForTaskInfo (portfolioInstance.Id, pendingTaskInfoId, 'Strategy Calls');
        insert portalSetting;
        
        List<Task> tasksList = new List<Task>{SFSPortal_TestRecordCreator.createTask(programInstance.Id), 
                                              SFSPortal_TestRecordCreator.createTask(programInstance.Id), 
                                              SFSPortal_TestRecordCreator.createTask(programInstance.Id)};
        
        Task taskInstance = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance.Clients_task__c = True;
        taskInstance.Status = 'Not Started';
        taskInstance.Call_Type__c = 'NSF';
        taskInstance.NSF_Payment__c = paymentInstance.Id;
        tasksList.add(taskInstance);
        
        Task taskInstance1 = SFSPortal_TestRecordCreator.createTask(programInstance.Id);
        taskInstance1.Clients_task__c = True;
        taskInstance1.Status = 'Not Started';
        taskInstance1.Call_Type__c = 'NSF';
        taskInstance1.NSF_Payment__c = paymentInstance1.Id;
        tasksList.add(taskInstance1);
        
        insert tasksList;
        
    }
    public static testMethod void testClientsTask() {
    
        Id proflieId = [select id from profile where name='Customer Community User'].id;
         
        List<User> userList = [SELECT Id, profileId FROM USER WHERE UserName = 'tester@noemail.com' AND profileId =:proflieId ];
        
        List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c];
        
        List<Task> taskList = [SELECT Id, WhatId FROM Task];
        system.debug('taskList:::***'+taskList);
        
        SFSPortal_ClientsTaskController.DefaultTaskWrapper defaultTask = new SFSPortal_ClientsTaskController.DefaultTaskWrapper();
        
        System.runAs(userList[0]) { 
            Test.startTest();
        
                try {                    
                    
                    defaultTask = SFSPortal_ClientsTaskController.getTaskList();
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {                    
                    system.debug('id:::::'+taskList[0].Id);
                    SFSPortal_ClientsTaskController.ViewInfoWrapper wrapper = SFSPortal_ClientsTaskController.getViewInfo(taskList[0].Id,'Strategy Calls');
                    System.debug('***** wrapper-->' + wrapper);
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
            Test.stopTest();
            system.assertEquals(true, defaultTask != null); 
        }
    }
    
    public static testMethod void testClientsTask1() {
        
        try {  
        
            List<Task> taskList = [SELECT Id, WhatId FROM Task];
            system.debug('taskList:::***'+taskList);
            if(taskList.isEmpty() == FALSE) {
            
                SFSPortal_ClientsTaskController.ViewInfoWrapper wrapper = SFSPortal_ClientsTaskController.getViewInfo(String.valueOf(taskList[0].Id), 'Strategy Calls');
                SFSPortal_ClientsTaskController.ViewInfoWrapper wrapper1 = SFSPortal_ClientsTaskController.getViewInfo(String.valueOf(taskList[0].Id), 'Calls');
                System.debug('***** wrapper-->' + wrapper);
            }
        } catch(Exception e) {
        
            system.assert(e.getMessage() != null);
        }
    }
}