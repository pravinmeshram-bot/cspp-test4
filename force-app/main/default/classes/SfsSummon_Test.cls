@isTest
public class SfsSummon_Test {
    
    @testSetup
    public static void SfsSummonData_test(){
        
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        insert acc;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        Account acct = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert acct;
        
         nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct.Id, pgm.Id);
        tl.SFS_Current_Balance__c = 5000.00 ;
        insert tl;
        
    }
    
    public static testmethod void testinsert(){
        list<nu_dse__Tradeline__c> ndtl = [Select Id From nu_dse__Tradeline__c Where nu_dse__Current_Stage__c='New'];
        Summon__c opp = new Summon__c(Status__c='Review Legal File', Tradeline__c =ndtl[0].Id);        
       
        Test.startTest();
        insert opp;
        Test.stopTest();
        
    }
    public static testmethod void testUpdate(){
        list<nu_dse__Tradeline__c> ndtl = [Select Id From nu_dse__Tradeline__c Where nu_dse__Current_Stage__c='New'];
        Summon__c opp = new Summon__c(Status__c='Review Legal File', Tradeline__c =ndtl[0].Id);
        insert opp;
       
        Test.startTest();
        opp.Status__c='	Pending Response';
        Update opp;
        Test.stopTest();
        
    }
    
    
     public static testmethod void testDelete(){
        list<nu_dse__Tradeline__c> ndtl = [Select Id From nu_dse__Tradeline__c Where nu_dse__Current_Stage__c='New'];
        Summon__c opp = new Summon__c(Status__c='Review Legal File', Tradeline__c =ndtl[0].Id);
        insert opp;
       
        Test.startTest();
        delete opp;
        Test.stopTest();
    }
    
    public static testmethod void testUndelete(){
        list<nu_dse__Tradeline__c> ndtl = [Select Id From nu_dse__Tradeline__c Where nu_dse__Current_Stage__c='New'];
        Summon__c opp = new Summon__c(Status__c='Review Legal File', Tradeline__c =ndtl[0].Id);
        insert opp;
        delete opp;
        
        Test.startTest();
        Undelete opp;
        Test.stopTest();
    }
    
    

}