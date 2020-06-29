@isTest
public class CaseResponseCtrl_Test {
    
    @isTest
    public static void storeResponse_TestAccepted() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'Accepted');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        List<Summon__C> summonList = [SELECT Id, Accepted__c FROM Summon__C WHERE Id = :summonInstance.Id LIMIT 1];
        
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals(True, summonList[0].Accepted__c);
    }
    
    @isTest
    public static void storeResponse_TestRejected() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'Rejected');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        List<Summon__C> summonList = [SELECT Id, Rejected__c FROM Summon__C WHERE Id = :summonInstance.Id LIMIT 1];
        
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals(True, summonList[0].Rejected__c);
    }
    
    @isTest
    public static void storeResponse_TestPrtlyAccepted() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'PrtlyAccepted');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        List<Summon__C> summonList = [SELECT Id, Partially_Accepted__c FROM Summon__C WHERE Id = :summonInstance.Id LIMIT 1];
        
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals(True, summonList[0].Partially_Accepted__c);
    }
    
    @isTest
    public static void storeResponse_TestEmail2Accepted() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'Email2Accepted');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        List<Summon__C> summonList = [SELECT Id, Email2_Accepted__c FROM Summon__C WHERE Id = :summonInstance.Id LIMIT 1];
        
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals(True, summonList[0].Email2_Accepted__c);
    }
    
    @isTest
    public static void storeResponse_TestEmail2Rejected() {
        
        Summon__c summonInstance = new Summon__c();
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'Email2Rejected');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        List<Summon__C> summonList = [SELECT Id, Email2_Rejected__c FROM Summon__C WHERE Id = :summonInstance.Id LIMIT 1];
        
        System.assertEquals(True, summonList.size() > 0);
        System.assertEquals(True, summonList[0].Email2_Rejected__c);
    }
    
    @isTest
    public static void storeResponse_TestAlreadyAccepted() {
        
        Summon__c summonInstance = new Summon__c();
        summonInstance.Accepted__c = True;
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'Email2Rejected');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        System.assertEquals(True, caseResponseInstance.showAlreadyAcceptedPanel);
    }
    
    @isTest
    public static void storeResponse_TestAlreadyRejected() {
        
        Summon__c summonInstance = new Summon__c();
        summonInstance.Rejected__c = True;
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', 'Email2Rejected');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        System.assertEquals(True, caseResponseInstance.showAlreadyRejectedPanel);
    }
    
    @isTest
    public static void storeResponse_TestAlreadyPartiallyAccepted() {
        
        Summon__c summonInstance = new Summon__c();
        summonInstance.Partially_Accepted__c = True;
        insert summonInstance;
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('recId', summonInstance.Id);
        ApexPages.currentPage().getParameters().put('caseResp', '');
        CaseResponseCtrl caseResponseInstance = new CaseResponseCtrl();
        caseResponseInstance.storeResponse();
        
        Test.stopTest();
        
        System.assertEquals(True, caseResponseInstance.showAlreadyPartiallyAcceptedPanel);
    }
}