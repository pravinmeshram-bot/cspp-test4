@isTest 
public class TaskTabCtrlTest {
	@TestSetup private static void testData(){
        list<User> users = [Select Id, Name From User Where UserPermissionsKnowledgeUser=true limit 1];
        if(users != null && users.size()>0){
            try{
                System.runAs(users[0]){
                    Id payment_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
                    Id clientServices_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Client Services').getRecordTypeId();
                    
                    list<SOP__kav> sopList = new list<SOP__kav>();
                    sopList.add(new SOP__kav(RecordTypeId=payment_RTId,UrlName='testurl', Title='Test Payment'));
                    sopList.add(new SOP__kav(RecordTypeId=clientServices_RTId,UrlName='testurl1', Title='Test Client Services'));
                    insert sopList;
                }
            }catch(Exception e){
                system.debug('### Exception: '+e.getMessage());
            }
        }
    }
    
    public static testmethod void testConstructor(){
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Task());
    	TaskTabCtrl ctrl = new TaskTabCtrl(stdCtrl);
        ctrl.titleStr='Test';
        ctrl.searchTasks();
        ApexPages.CurrentPage().getParameters().put('sortBy', 'title');
        ctrl.sortActivities();
        ctrl.sortActivities();
        ApexPages.CurrentPage().getParameters().put('sortBy', 'dueDate');
        ctrl.sortActivities();
        ctrl.sortActivities();
        ApexPages.CurrentPage().getParameters().put('sortBy', 'status');
        ctrl.sortActivities();
        ctrl.sortActivities();
        Test.stopTest();
    }
}