@isTest
public class Test_testVFClass2 {
    
     private static testMethod void te4(){
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
                
        nu_dse__Group_Task__c gt2 = new nu_dse__Group_Task__c();
        gt2.nu_dse__Subject__c = 'Mark Account as Settled';
        gt2.nu_dse__ActivityDate__c = System.today();
        gt2.nu_dse__Type__c = 'Email';
        gt2.nu_dse__Description__c = 'Test Group Task 1';
        gt2.nu_dse__Status__c = 'Completed';
     	gt2.nu_dse__Related_To__c = programInstance.id; 
         gt2.Subject_Picklist__c = 'Follow Up - Negotiation';
         
          if(gt2 !=null )
          {
         
            
                   insert gt2;
                 //  system.debug('line 81'+gt2[0].id);
             
             }
      //  insert gt2;
        
        testVFClass2 tvc = new testVFClass2();
        testVFClass2.getGroupTaskHistory(programInstance.id);
       
    }
 @isTest public static void testGetData(){
     	
     	Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
     
     
        List<StopTaskCreationInDisposition__mdt>  stopTaskCreationInDispositionList = [SELECT Id, Label, Task_Status_to_Delete__c FROM StopTaskCreationInDisposition__mdt WHERE Active__c = True];
        
       
     
        task t = new task();
        t.Subject = stopTaskCreationInDispositionList[0].Label;
        t.ActivityDate = System.today();
        t.Status = 'In Progress';
        t.Priority = 'High';
        t.Description = 'Test Task';
     	t.WhatId = programInstance.id; 
      if(t !=null )
          {
         
            
                   insert t;
                 //  system.debug('line 81'+gt2[0].id);
             
             }
      //  insert t; 
     
        nu_dse__Group_Task__c gt1 = new nu_dse__Group_Task__c();
        gt1.nu_dse__Subject__c = ': Follow Up';
        gt1.nu_dse__ActivityDate__c = System.today();
        gt1.nu_dse__Type__c = 'Email';
        gt1.nu_dse__Description__c = 'Test Group Task 1';
        gt1.nu_dse__Status__c = 'In Progress';
     	gt1.nu_dse__Related_To__c = programInstance.id;
     gt1.Subject_Picklist__c = 'Follow Up - Negotiation';
        insert gt1; 

    
     
        nu_dse__Group_Task__c gt2 = new nu_dse__Group_Task__c();
        gt2.nu_dse__Subject__c = 'Test';
        gt2.nu_dse__ActivityDate__c = System.today();
        gt2.nu_dse__Type__c = 'Email';
        gt2.nu_dse__Description__c = 'Test Group Task 1';
        gt2.nu_dse__Status__c = 'In Progress';
     	gt2.nu_dse__Related_To__c = programInstance.id; 
        insert gt2;
        
        
        
        Event ev = new Event();
        ev.Subject = 'Test Eve';
        ev.ActivityDate = System.today();
        ev.StartDateTime = System.today()+1;
        ev.EndDateTime = System.today() + 3;
        ev.Description = 'Test Description';
        ev.IsNote__c = True;
     	ev.WhatId = programInstance.id;
        insert ev;
     
     	Event ev1 = new Event();
        ev1.Subject = 'Test Eve';
        ev1.ActivityDate = System.today();
        ev1.StartDateTime = System.today()+1;
        ev1.EndDateTime = System.today() + 3;
        ev1.Description = 'Test Description';
        ev1.IsNote__c = False;
     	ev1.WhatId = programInstance.id;
        insert ev1;

        
      
    
        
        Test.startTest();
     PageReference pageRef1 = Page.ActivityTabNew5_2;
     Test.setCurrentPage(pageRef1);
     // put the lead id as a parameter
     ApexPages.currentPage().getParameters().put('recordId',programInstance.id);
       testVFClass2 tvc = new testVFClass2();
     
          testVFClass2.getGroupTask(String.valueOf(programInstance.Id));
     nu_dse__Group_Task__c gt12 = new nu_dse__Group_Task__c();
        gt12.nu_dse__Subject__c = ': Follow Up';
        gt12.nu_dse__ActivityDate__c = System.today();
        gt12.nu_dse__Type__c = 'Email';
        gt12.nu_dse__Description__c = 'Test Group Task 1';
        gt12.nu_dse__Status__c = 'Completed';
     	gt12.nu_dse__Related_To__c = programInstance.id;
        insert gt12;
     
     
   //  PageReference pageRef12 = Page.ActivityTabNew5_2;
     //Test.setCurrentPage(pageRef12);
     
        tvc.getdata();
        tvc.GetGroupTaskInfo();
        testVFClass2.readFieldSet('nu_dse__CreateGroupTask','nu_dse__Group_Task__c');
     
		// View/Edit Task
        tvc.TaskId = t.id;
        tvc.dynamicqueryTask();
        tvc.dynamicqueryEvent();
      	tvc.scheduleTask();
        tvc.viewTask();
        tvc.EditTask();
     	tvc.saveTaskModal();
     	tvc.cancelTaskModal();
        
        // View/Edit Group Task
        testVFClass2.groupTaskId = gt1.id;
        tvc.dynamicqueryGroupTask();
     	tvc.CreateGroupTask();
        tvc.viewGroupTask();
        tvc.EditGroupTask();
     	tvc.saveGroupTaskModal();
     tvc.closeTask();
     tvc.refreshNotesApex();
     
        
        //View/Edit Event
        tvc.EventId = ev.id;
     	tvc.scheduleEvent();
        tvc.viewEvent();
        tvc.EditEvent();
     	tvc.canceleventModal();
        tvc.saveeventModal();
     
        tvc.CreateGroupTask();
        tvc.cancelGroupTaskModal();
        tvc.scheduleTask();
     	tvc.createGroupTask = gt1;
     	tvc.saveGroupTaskModal();
        tvc.cancelTaskModal();
        
        tvc.canceleventModal();
        tvc.CreateNote();
      	tvc.Titles = 'test_Title';
        tvc.Bd  = 'test_body';
     	tvc.CreateNotesSave();
        tvc.cancelNotes();
     	tvc.Refresh();
     
      
     
      /*   PageReference pageRef = Page.ActivityTabNew5_2; 
         pageRef.getParameters().put('recordId', String.valueOf(programInstance.Id));
         Test.setCurrentPage(pageRef);*/
        
        testVFClass2.getGroupTask(String.valueOf(programInstance.Id));
     	testVFClass2.getGroupTaskHistory(String.valueOf(programInstance.Id));
     	testVFClass2.getOpenTask(String.valueOf(programInstance.Id));
     	//testVFClass2.getOpenTaskHistory(String.valueOf(programInstance.Id));
     	testVFClass2.getOpenEvent(String.valueOf(programInstance.Id));
     	testVFClass2.getEventHistory(String.valueOf(programInstance.Id));
     	testVFClass2.getGTInfo(gt1.Id); 
     testVFClass2.OpenNotesWrapper obj=new testVFClass2.OpenNotesWrapper();
     obj.ActivityDate = null;
     obj.Description = null;
     obj.Priority = null;
     obj.Status = '';
     obj.Subject = '';
     obj.Id = '';
     obj.CreatedBy = 'Test';
     obj.CreatedDate = Null;
     obj.Owner = 'test';
     obj.LastModifiedDate = Null;
     testVFClass2.GroupTaskHistoryWrapper objw = new testVFClass2.GroupTaskHistoryWrapper();
     objw.Id = Null;
     objw.NDSAssigned = null;
     objw.NDSCreatedBy = null;
     objw.NUDSEActivityDate = null;
     objw.NUDSEDescription =null;
     objw.NUDSEStatus = null;
     objw.NUDSESubject = null;
     objw.NUDSEType = null;
     objw.OwnerName = Null;
     
     testVFClass2.getOpenNotes(gt1.id);
     testVFClass2.GroupTaskWrapper taskWrap = new testVFClass2.GroupTaskWrapper();
 		Test.stopTest(); 
     
    
     
 }
   
         private static testMethod void te2(){
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
        
        PageReference pageRef1 = Page.ActivityTabNew5_2;
        Test.setCurrentPage(pageRef1);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('recordId',programInstance.id);
        
        task t1 = new task();
        t1.Subject = 'Test';
        t1.ActivityDate = System.today();
        t1.Status = 'In Progress';
        t1.Priority = 'High';
        t1.Description = 'Test Task';
        t1.WhatId = programInstance.id; 
        t1.IsNote__c = true;
             
              if(t1 !=null )
          {
        insert t1;
          }
        
        
        Event ev1 = new Event();
        ev1.Subject = 'Test Eve';
        ev1.ActivityDate = System.today();
        ev1.StartDateTime = System.today().addDays(-1);
        ev1.EndDateTime = System.today() + 2;
        ev1.Description = 'Test Description';
        ev1.IsNote__c = true;
     	ev1.WhatId = programInstance.id;
        insert ev1;
        nu_dse__Group_Task__c gt2 = new nu_dse__Group_Task__c();
        gt2.nu_dse__Subject__c = 'Test';
        gt2.nu_dse__ActivityDate__c = System.today();
        gt2.nu_dse__Type__c = 'Email';
        gt2.nu_dse__Description__c = 'Test Group Task 1';
        gt2.nu_dse__Status__c = 'In Progress';
     	gt2.nu_dse__Related_To__c = programInstance.id; 
             gt2.Subject_Picklist__c = 'Follow Up - Negotiation';
        insert gt2;
        
        testVFClass2 tvc = new testVFClass2();
        testVFClass2.getGroupTask(programInstance.id);
       
    }
       private static testMethod void te1(){
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
        
        PageReference pageRef1 = Page.ActivityTabNew5_2;
        Test.setCurrentPage(pageRef1);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('recordId',programInstance.id);
        
        task t1 = new task();
        t1.Subject = 'Test';
        t1.ActivityDate = System.today();
        t1.Status = 'In Progress';
        t1.Priority = 'High';
        t1.Description = 'Test Task';
        t1.WhatId = programInstance.id; 
        t1.IsNote__c = true;
        insert t1;
        
        
        Event ev1 = new Event();
        ev1.Subject = 'Test Eve';
        ev1.ActivityDate = System.today();
        ev1.StartDateTime = System.today().addDays(-1);
        ev1.EndDateTime = System.today() + 2;
        ev1.Description = 'Test Description';
        ev1.IsNote__c = true;
     	ev1.WhatId = programInstance.id;
        insert ev1;
        
        testVFClass2 tvc = new testVFClass2();
        testVFClass2.getOpenNotes(programInstance.id);
       
    }
      private static testMethod void testgetOpenTaskHistory(){
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
        
        PageReference pageRef1 = Page.ActivityTabNew5_2;
        Test.setCurrentPage(pageRef1);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('recordId',programInstance.id);
        
        task t1 = new task();
        t1.Subject = 'Test';
        t1.ActivityDate = System.today();
        t1.Status = 'Completed';
        t1.Priority = 'High';
        t1.Description = 'Test Task';
        t1.WhatId = programInstance.id; 
        t1.IsNote__c = true;
        insert t1;
        
          
        testVFClass2 tvc = new testVFClass2();
        testVFClass2.getOpenTaskHistory(programInstance.id);
        
    }
    private static testMethod void te(){
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
        
        PageReference pageRef1 = Page.ActivityTabNew5_2;
        Test.setCurrentPage(pageRef1);
        // put the lead id as a parameter
        ApexPages.currentPage().getParameters().put('recordId',programInstance.id);
        
        task t1 = new task();
        t1.Subject = 'Test';
        t1.ActivityDate = System.today();
        t1.Status = 'Completed';
        t1.Priority = 'High';
        t1.Description = 'Test Task';
        t1.WhatId = programInstance.id; 
        t1.IsNote__c = true;
        insert t1;
        
         // testVFClass2.GTHistoryWrapper test1= new testVFClass2.GTHistoryWrapper(new nu_dse__group_task__history());
        testVFClass2.GTAttachment att = new testVFClass2.GTAttachment();
        testVFClass2.GTInfoWrapper info = new testVFClass2.GTInfoWrapper();
        testVFClass2 tvc = new testVFClass2();
        testVFClass2.getOpenTaskHistory(programInstance.id);
        testVFClass2.getNotestHistory(programInstance.id);
      
    // testVFClass2.dummyMethod();   
    }
}