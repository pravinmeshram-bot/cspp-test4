@isTest
public class SOPTriggerTest {
    public static testmethod void testInsert(){
        //list<User> users = [Select Id, Name From User Where UserPermissionsKnowledgeUser=true limit 1];
        list<User> users = [Select id, name, UserPermissionsKnowledgeUser from User where id=: UserInfo.getUserId()];
        System.debug('user=>'+users[0].UserPermissionsKnowledgeUser);
        if(users != null && users.size()>0){
            Test.startTest();
           // try{
                System.runAs(users[0]){
                    Id payment_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
                    Id clientServices_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Client Services').getRecordTypeId();
                    
                    list<SOP__kav> sopList = new list<SOP__kav>();
                    sopList.add(new SOP__kav(RecordTypeId=payment_RTId,UrlName='testurl', Title='Test Payment'));
                    sopList.add(new SOP__kav(RecordTypeId=clientServices_RTId,UrlName='testurl1', Title='Test Client Services'));
                    insert sopList;
                }
           // }catch(Exception e){
            //    system.debug('### Exception: '+e.getMessage());
           // }
            Test.stopTest();
        }
    }
    
    public static testmethod void testPublish(){
       
        //list<User> users = [Select Id, Name From User Where UserPermissionsKnowledgeUser=true limit 1];
        list<User> users = [Select id, name, UserPermissionsKnowledgeUser from User where id=: UserInfo.getUserId()];
        System.debug('user=>'+users[0].UserPermissionsKnowledgeUser);
        if(users != null && users.size()>0){
            Test.startTest();
           // try{
                System.runAs(users[0]){
                    Id payment_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
                    Id clientServices_RTId = Schema.SObjectType.SOP__kav.getRecordTypeInfosByName().get('Client Services').getRecordTypeId();
                    
                    list<SOP__kav> sopList = new list<SOP__kav>();
                    sopList.add(new SOP__kav(RecordTypeId=payment_RTId,UrlName='testurl', Title='Test Payment'));
                    sopList.add(new SOP__kav(RecordTypeId=clientServices_RTId,UrlName='testurl1', Title='Test Client Services'));
                    insert sopList;
                    
                    sopList[0].Title='Test Payment1';
                    update sopList[0];
                }
         //   }catch(Exception e){
           //     system.debug('### Exception: '+e.getMessage());
           // }
            Test.stopTest();
        }
    }
}