@isTest
public class Batch_EmailToCaseOwnerAssignment_Test {
    
    @testSetup 
    static void testSetupMethod() {
        
        Email_to_Case_Owner_assignment__mdt emailToCaseAssignmentInstance = [SELECT Id, Case_Limit__c, Source_Queue__c, Target_Queue__c 
                                                                                FROM Email_to_Case_Owner_assignment__mdt 
                                                                                WHERE MasterLabel = 'Email to Case Owner assignment' 
                                                                                AND Case_Limit__c > 0 AND Source_Queue__c != null 
                                                                                AND Target_Queue__c != null];
        
        Group EmailtoCaseQueue = [SELECT Id FROM GROUP WHERE Name = :emailToCaseAssignmentInstance.Source_Queue__c];
        
        List<Case> caseList = new List<Case>();
        
        for (Integer i=0; i<10; i++) {
            
            Case caseInstance = new Case();
            caseInstance.ownerId = EmailtoCaseQueue.Id;
            caseInstance.Status = 'New';
            caseList.add(caseInstance);
            
        }
        insert caseList;
                
    }
    
    @isTest 
    static void testMethod1() {
        
        Test.startTest();
        
        Batch_EmailToCaseOwnerAssignment inst = new Batch_EmailToCaseOwnerAssignment();
        Database.executeBatch(inst);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testMethod2() {
        
        List<Case> caseList = [SELECT Id FROM Case LIMIT 5];
        
        Test.startTest();
        
        Batch_EmailToCaseOwnerAssignment inst = new Batch_EmailToCaseOwnerAssignment();
        
        for (Case caseInst :caseList) {
            
            inst.caseIdSet.add(caseInst.Id);
        }
        Database.executeBatch(inst);
        
        Test.stopTest();
    }
    
    @isTest
    static void testSchedularClass() {
        
        Schedule_EmailToCaseOwnerAssignment schedulerInst = new  Schedule_EmailToCaseOwnerAssignment();
        schedulerInst.batchSize = 51;
        String sch = '0 0 * * * ?'; 
        
        Test.startTest();
        
        system.schedule('Test scheduler run', sch, schedulerInst);
        
        Test.stopTest();
        
    }
}