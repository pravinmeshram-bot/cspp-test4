@isTest
public class Test_ManageRecordAllocation {

    public static testMethod void ManageRecordAllocationMethod(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Pre-Sales']; 
        User u1 = new User(Alias = 'sandt1', Email='standardTestuser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sandyTestuser@testorg.com',IsRoundRobinAllocationEnabled__c=true);
        insert u1;
        Test.startTest();
        ManageRecordAllocationController mra=new ManageRecordAllocationController();
        //mra.setEnableChoice();
        Test.stopTest();
    }
}