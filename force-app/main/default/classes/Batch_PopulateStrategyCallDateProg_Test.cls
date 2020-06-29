@isTest
public class Batch_PopulateStrategyCallDateProg_Test {
    
    @isTest
    public static void populateStrategyCallDate1() {
        
        nu_dse__Processor__c newProcessor = new nu_dse__Processor__c( Name = 'RAMS', nu_dse__Type__c = 'RAMS');
        insert newProcessor;
        
        String accountSObj = Account.sObjectType.getDescribe().getname();
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :'Client'
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        Account accountInstance = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, newProcessor.Id, 'Inactive');
        programInstance.Enrollment_Date__c = System.today();
        insert programInstance;
        
        Test.startTest();
            
            Batch_PopulateStrategyCallDateOnProgram inst = new  Batch_PopulateStrategyCallDateOnProgram();
            Database.executeBatch(inst);
            
        Test.stopTest();
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id, Expected_Strategy_Call_Date__c FROM nu_dse__Program__c];
        
        System.assert(programInstanceList.size() > 0);
        System.assert(programInstanceList[0].Expected_Strategy_Call_Date__c != null);
        
    }
    
    @isTest
    public static void populateStrategyCallDate2() {
        
        nu_dse__Processor__c newProcessor = new nu_dse__Processor__c( Name = 'RAMS', nu_dse__Type__c = 'RAMS');
        insert newProcessor;
        
        String accountSObj = Account.sObjectType.getDescribe().getname();
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :'Client'
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        Account accountInstance = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, newProcessor.Id, 'Inactive');
        programInstance.Enrollment_Date__c = System.today();
        programInstance.Attorney__c = True;
        programInstance.Import_ID__c = '1231233211';
        insert programInstance;
        
        Test.startTest();
            
            Batch_PopulateStrategyCallDateOnProgram inst = new  Batch_PopulateStrategyCallDateOnProgram();
            Database.executeBatch(inst);
            
        Test.stopTest();
        
        List<nu_dse__Program__c> programInstanceList = [SELECT Id, Expected_Strategy_Call_Date__c FROM nu_dse__Program__c];
        
        System.assert(programInstanceList.size() > 0);
        System.assert(programInstanceList[0].Expected_Strategy_Call_Date__c != null);
        
    }
    
    @isTest
    public static void populateStrategyCallDate3() {
        
        nu_dse__Processor__c newProcessor = new nu_dse__Processor__c( Name = 'RAMS', nu_dse__Type__c = 'RAMS');
        insert newProcessor;
        
        String accountSObj = Account.sObjectType.getDescribe().getname();
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :'Client'
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        Account accountInstance = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, newProcessor.Id, 'Inactive');
        programInstance.Enrollment_Date__c = System.today();
        programInstance.Attorney__c = True;
        programInstance.Import_ID__c = '1231233211';
        insert programInstance;
        
        Test.startTest();
            
            Schedule_CreateStrategyCallTaskOnProg inst = new  Schedule_CreateStrategyCallTaskOnProg();
            System.schedule('Schedule_CreateStrategyCall', '0 0 1 * * ? *', inst);  
            
        Test.stopTest();
        
    }
}