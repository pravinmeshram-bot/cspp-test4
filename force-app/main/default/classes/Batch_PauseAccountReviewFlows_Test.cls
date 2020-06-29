@isTest
public class Batch_PauseAccountReviewFlows_Test {

    @testsetup static void setupTestData() {

        Portfolio__c portfolio = TestRecordCreator.createPortfolio();
        portfolio.Name = 'Timberline';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Processor__c processor = TestRecordCreator.createProcessor();
        insert processor;

    
        String recordTypeNameEquToClient = 'Client';
        String accountSObj = Account.sObjectType.getDescribe().getName();
        
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                WHERE DeveloperName = :recordTypeNameEquToClient 
                                                                AND SObjectType = :accountSObj
                                                                AND isActive = True]);
                                                                    
        Account accStr = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr.PersonHomePhone = '7854123652';   
        accStr.Phone = null;
        
        Account accStr2 = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr2.Phone = '7854123652';
        
        Account accStr3 = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr3.PersonHomePhone = null;   
        accStr3.Phone = null;
        accStr3.PersonMobilePhone = '7854123652';
        
        Account accStr4 = TestRecordCreator.createAccount(recordTypeList[0].Id);  
        accStr4.Phone = '9876543215';
        
        List<Account> accList = new List<Account> ();
        accList.add(accStr);
        accList.add(accStr2);
        accList.add(accStr3);
        accList.add(accStr4);

        insert accList;
        
        Id debtRecordTypeId = Schema.SObjectType.nu_dse__Program__c.getRecordTypeInfosByDeveloperName().get('Debt_Management').getRecordTypeId();
                
        nu_dse__Program__c prgm = TestRecordCreator.createProgram();
        prgm.nu_dse__Account__c = accStr.Id;
        prgm.nu_dse__Processor__c = processor.Id;
        prgm.RUN_PROCESSES_ON_IMPORT__c = True;
        prgm.ACRs_Scheduled__c = False;
        prgm.Portfolio__c = portfolio.Id;
        prgm.nu_dse__Program_Status__c = 'Active Client';
        prgm.nu_dse__Processor_Status__c = 'No Account';
        prgm.RecordTypeId = debtRecordTypeId;
        
        nu_dse__Program__c prgm2 = TestRecordCreator.createProgram();
        prgm2.nu_dse__Account__c = accStr2.Id;
        prgm2.nu_dse__Processor__c = processor.Id;
        prgm2.Portfolio__c = portfolio.Id;
        prgm2.RUN_PROCESSES_ON_IMPORT__c = True;
        prgm2.nu_dse__Program_Length__c = 60; 
        prgm2.YR2_ACRs_Scheduled__c = False;
        prgm2.nu_dse__Program_Status__c = 'Active Client';
        prgm2.nu_dse__Processor_Status__c = 'No Account';
        prgm2.RecordTypeId = debtRecordTypeId;
                
        nu_dse__Program__c prgm3 = TestRecordCreator.createProgram();
        prgm3.nu_dse__Account__c = accStr3.Id;
        prgm3.nu_dse__Processor__c = processor.Id;
        prgm3.Portfolio__c = portfolio.Id;
        prgm3.nu_dse__Program_Status__c = 'Active Client';
        prgm3.nu_dse__Processor_Status__c = 'No Account';
        
        nu_dse__Program__c prgm4 = TestRecordCreator.createProgram();
        prgm4.nu_dse__Account__c = accStr4.Id;
        prgm4.nu_dse__Processor__c = processor.Id;
        prgm4.Portfolio__c = portfolio.Id;
        prgm4.RUN_PROCESSES_ON_IMPORT__c = True;
        prgm4.nu_dse__Program_Length__c = 72; 
        prgm4.YR2_ACRs_Scheduled__c = False;
        prgm4.Pause_Account_Review__c = True;
        prgm4.nu_dse__Program_Status__c = 'Active Client';
        prgm4.nu_dse__Processor_Status__c = 'No Account';
        prgm4.RecordTypeId = debtRecordTypeId;

        
        List<nu_dse__Program__c> progList = new List<nu_dse__Program__c> ();
        progList.add(prgm);
        progList.add(prgm2);
        progList.add(prgm3);
        progList.add(prgm4);

        insert progList;
        
    }
    
    
    @isTest
    static void testBatchExecution(){
                        
        Test.startTest();          
        
        List<Process_For_Portfolio__mdt> portfolios = new List<Process_For_Portfolio__mdt>{
            new Process_For_Portfolio__mdt(
                    Label = 'Timberline'
            )
        };
        CustomMetadataGenerator.queryStrResultMap.put('SELECT Id, Label FROM Process_For_Portfolio__mdt', JSON.serialize(portfolios));
        
        Database.executeBatch(new Batch_PauseAccountReviewFlows() , 50);      
        Test.stopTest();
    }
}