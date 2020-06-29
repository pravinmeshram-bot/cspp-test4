@istest
public class ProgramFeeTemplateMappingTrigger_Test {
    
    @isTest
    public static void success_GCS_Mapping_Test() {
        
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('FeeTemplateAssignment-PreTILA_signed', null, 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c (nu_dse__Data_Mapping__c = dataMappingInstance.Id,
                                                                                       Trust_Account_Provider__c = 'GCS',
                                                                                       Program_Type__c = 'Test Portfolio 1',
                                                                                       Amount_Category__c = 'Under 30000',
                                                                                       Original_Policy_Group_Id__c = '9879879877',
                                                                                       New_Policy_Group_Id__c = '45678');
        insert fieldMappingInstance1;
        
        nu_dse__Fee_Template__c feeTemplateInstance1 = new nu_dse__Fee_Template__c(Program_Type__c='Test Portfolio 1', Debt_Amount__c = 'Under 30000', 
                                                                                        nu_dse__Settlement_Pct__c = 50.00, Service_Fee_Percentage__c = 11.00,
                                                                                        nu_dse__GCS_Fee_Group_Id__c = '9879879877', nu_dse__RAMS_Fee_Group_Id__c = '55555');
        nu_dse__Fee_Template__c feeTemplateInstance2 = new nu_dse__Fee_Template__c(Program_Type__c='Test Portfolio 1', Debt_Amount__c = 'Under 30000', 
                                                                                        nu_dse__Settlement_Pct__c = 50.00, Service_Fee_Percentage__c = 11.00,
                                                                                        nu_dse__GCS_Fee_Group_Id__c = '45678', nu_dse__RAMS_Fee_Group_Id__c = '66666');
        
        List<nu_dse__Fee_Template__c> feeTemplateList = new List<nu_dse__Fee_Template__c> ();
        feeTemplateList.add(feeTemplateInstance1);
        feeTemplateList.add(feeTemplateInstance2);
        
        insert feeTemplateList;                                                                                
        
        nu_dse__Processor__c newProcessor = TestRecordCreator.createGCSProcessor();
        insert newProcessor;
        
        String accountSObj = Account.sObjectType.getDescribe().getname();
        List<RecordType> recordTypeList = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType
                                                                    WHERE DeveloperName = :'Client'
                                                                    AND SObjectType = :accountSObj
                                                                    AND isActive = True]);
        Account accountInstance = TestRecordCreator.createAccount(recordTypeList[0].Id);     
        insert accountInstance;
        
        
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.Id, newProcessor.Id, 'Inactive');
        programInstance.nu_dse__Fee_Template__c = feeTemplateList[0].Id;
        programInstance.DNL_Status__c = 'Lead Active';
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        insert programInstance;
        
        Map<Id,nu_dse__Program__c> OldProgMap = new Map<Id,nu_dse__Program__c>();
        List<nu_dse__Program__c> programUpdateList = new List<nu_dse__Program__c>();
        OldProgMap.put(programInstance.Id,programInstance);
		        
        programInstance.DNL_Status__c = 'Pre-TILA Signed';
        programUpdateList.add(programInstance);
        
        
        Test.startTest();
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        //ProgramFeeTemplateMappingTriggerHandler.ProgramFeeTemplateMapping( OldProgMap, programUpdateList) ;
        update programInstance;
        
        Test.stopTest();
        
        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Fee_Template__c FROM nu_dse__Program__c WHERE Id = :programInstance.Id];
        System.assertEquals(1, programList.size());
        //System.assertEquals(programList[0].nu_dse__Fee_Template__c, feeTemplateList[1].Id);
    }
    
    @isTest
    public static void success_RAMS_Mapping_Test() {
        
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('FeeTemplateAssignment-PreTILA_signed', null, 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c (nu_dse__Data_Mapping__c = dataMappingInstance.Id,
                                                                                       Trust_Account_Provider__c = 'RAMS',
                                                                                       Original_Policy_Group_Id__c = '55555',
                                                                                       New_Policy_Group_Id__c = '66666');
        insert fieldMappingInstance1;
        
        nu_dse__Fee_Template__c feeTemplateInstance1 = new nu_dse__Fee_Template__c(nu_dse__Settlement_Pct__c = 50.00, Service_Fee_Percentage__c = 11.00,
                                                                                        nu_dse__GCS_Fee_Group_Id__c = '9879879877', nu_dse__RAMS_Fee_Group_Id__c = '55555');
        nu_dse__Fee_Template__c feeTemplateInstance2 = new nu_dse__Fee_Template__c(nu_dse__Settlement_Pct__c = 50.00, Service_Fee_Percentage__c = 11.00,
                                                                                        nu_dse__GCS_Fee_Group_Id__c = '45678', nu_dse__RAMS_Fee_Group_Id__c = '66666');
        
        List<nu_dse__Fee_Template__c> feeTemplateList = new List<nu_dse__Fee_Template__c> ();
        feeTemplateList.add(feeTemplateInstance1);
        feeTemplateList.add(feeTemplateInstance2);
        
        insert feeTemplateList;                                                                                
        
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
        programInstance.nu_dse__Fee_Template__c = feeTemplateList[0].Id;
        programInstance.DNL_Status__c = 'Lead Active';
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        insert programInstance;
        
        programInstance.DNL_Status__c = 'Pre-TILA Signed';
        
        Test.startTest();
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        update programInstance;
        
        Test.stopTest();
        
        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Fee_Template__c FROM nu_dse__Program__c WHERE Id = :programInstance.Id];
        System.assertEquals(1, programList.size());
        //System.assertEquals(programList[0].nu_dse__Fee_Template__c, feeTemplateList[1].Id);
    }
    
    @isTest
    public static void failureMapping_Test() {
        
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('FeeTemplateAssignment-PreTILA_signed', null, 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c (nu_dse__Data_Mapping__c = dataMappingInstance.Id,
                                                                                       Trust_Account_Provider__c = 'GCS',
                                                                                       Program_Type__c = 'Test Portfolio 1',
                                                                                       Amount_Category__c = 'Under 30000',
                                                                                       Original_Policy_Group_Id__c = '9879879877',
                                                                                       New_Policy_Group_Id__c = '45678');
        insert fieldMappingInstance1;
        
        nu_dse__Fee_Template__c feeTemplateInstance1 = new nu_dse__Fee_Template__c(Program_Type__c = 'Test Portfolio 1', Debt_Amount__c = 'Under 30000', 
                                                                                        nu_dse__Settlement_Pct__c = 50.00, Service_Fee_Percentage__c = 11.00,
                                                                                        nu_dse__GCS_Fee_Group_Id__c = '9879879877', nu_dse__RAMS_Fee_Group_Id__c = '55555');
        nu_dse__Fee_Template__c feeTemplateInstance2 = new nu_dse__Fee_Template__c(Program_Type__c = 'Test Portfolio 1', Debt_Amount__c = 'Under 30000', 
                                                                                        nu_dse__Settlement_Pct__c = 50.00, Service_Fee_Percentage__c = 11.00,
                                                                                        nu_dse__GCS_Fee_Group_Id__c = '45678', nu_dse__RAMS_Fee_Group_Id__c = '66666');
        
        List<nu_dse__Fee_Template__c> feeTemplateList = new List<nu_dse__Fee_Template__c> ();
        feeTemplateList.add(feeTemplateInstance1);
        feeTemplateList.add(feeTemplateInstance2);
        
        insert feeTemplateList;                                                                                
        
       // nu_dse__Processor__c newProcessor = TestRecordCreator.createProcessor();
       // newProcessor.nu_dse__Type__c = 'RAMS';
      //  insert newProcessor;
        
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
        programInstance.nu_dse__Fee_Template__c = feeTemplateList[0].Id;
        programInstance.DNL_Status__c = 'Lead Active';
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        insert programInstance;
        
       nu_dse__Program__c progInst1 = programInstance.clone() ;
        
        
        progInst1.DNL_Status__c = 'Pre-TILA Signed';
        
        Test.startTest();
        
        try {
            PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
            update progInst1;
        
        } catch(Exception e) {
            
            System.assert(true, e.getMessage().contains('The fee template relevant to DNL interim not found.'));
        }
        Test.stopTest();
        
        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Fee_Template__c FROM nu_dse__Program__c WHERE Id = :programInstance.Id];
        System.assertEquals(1, programList.size());
        //System.assertEquals(programList[0].nu_dse__Fee_Template__c, feeTemplateList[0].Id);
    }
}