@isTest
public class IVRScoreRollupCalculationTest {
    
    @testsetup 
    public static void setupTestData() {
        
        IVR_Configuration__c ivrConfig = new IVR_Configuration__c();
        ivrConfig.Description__c ='Test';
        ivrConfig.Is_Active__c =true;
        ivrConfig.IVR_Scoring_Table_Field__c ='Settlement_Auth_Score__c';
        ivrConfig.Logic_Definition__c ='Test';
        ivrConfig.Point_Value__c =50;
        ivrConfig.Technical_Definition__c ='Select Id from nu_dse__Program__c';
        insert ivrConfig;
    }
    
    static testMethod void runIVRBatch_Test()
    {
        Test.startTest();
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account' ,'Client');
        
        Account accStr = TestRecordCreator.createAccount(clientRecordTypeId );  
        accStr.PersonHomePhone = '7854123652';   
        accStr.Phone = null;
        insert accStr;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Communication_Template_Email__c = 'salesforcehelp@stratfs.com';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.Portfolio__c = portfolio.Id;
        insert prgm;
        
        IVRScoreRollupCalculationBatch b = new IVRScoreRollupCalculationBatch('');
        Database.executeBatch(b,200);
        Test.stopTest();
        
        IVR_Scoring__c score = [Select Id,Settlement_Auth_Score__c,Check_In_Call_Score__c,Total_Score__c from IVR_Scoring__c];
        System.assertEquals(50,  score.Settlement_Auth_Score__c);
        System.assertEquals(50,  score.Total_Score__c);
        System.assertEquals(0,  score.Check_In_Call_Score__c);
        
    }

}