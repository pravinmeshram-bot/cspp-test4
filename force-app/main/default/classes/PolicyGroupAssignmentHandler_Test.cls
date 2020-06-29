@isTest
public class PolicyGroupAssignmentHandler_Test {
    
    @isTest
    public static void programPolicyGroupMappingDebtSettlement_Test() {
        
        VelocifyLeadStatusMapping__c Customsetting1 = new VelocifyLeadStatusMapping__c();
        Customsetting1.Name='GoodFaithCleared';
        Customsetting1.Status__c = 251;
        insert Customsetting1;
        
        VelocifyLeadStatusMapping__c Customsetting2 = new VelocifyLeadStatusMapping__c();
        Customsetting2.Name='1Cleared';
        Customsetting2.Status__c = 39;
        //Customsetting2.Amount_field_Id__c = 649;
        insert Customsetting2;
        
        VelocifyCredentials__c Cred1 = new VelocifyCredentials__c();
        Cred1.UserName__c = 'test.test@test.com';
        Cred1.Password__c = 'test';
        Cred1.Name='VelocifyCredentials';
        insert Cred1;
        
        nu_dse__Data_Mapping__c dataMappingInstance = 
            TestRecordCreator.createDataMapping('PolicyGroupAssignment', null, 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance = 
            new nu_dse__Field_mapping__c (  nu_dse__Data_Mapping__c = dataMappingInstance.Id,
                                            Trust_Account_Provider__c = 'GCS',
                                            Program_Portfolio__c = 'Anchor',
                                            LDP__c = '1234',
                                            Over_30000__c = '2341',
                                            Over_35000__c = '3412',
                                            Under_30000__c = '4123',
                                            Priority_Sequence_Number__c = 1,
                                            Program_Type_30K__c = 'Anchor 2',
                                            Program_Type_35K__c = 'Anchor 2',
                                            Populate_Program_Type__c = TRUE,
                                            Policy_Type__c = 'Debt Settlement');
        insert fieldMappingInstance;
        
        nu_dse__Fee_Template__c feeTemplateInstance1 = 
            new nu_dse__Fee_Template__c(Portfolio_Name__c = 'ANCHOR', Debt_Amount__c = 'Under 30000', 
                                        nu_dse__Settlement_Pct__c = 42.00, Service_Fee_Percentage__c = 17.00,
                                        Program_Type__c = 'Anchor 2', 
                                        nu_dse__GCS_Fee_Group_Id__c = '4123', nu_dse__RAMS_Fee_Group_Id__c = '55555');
                                        
        nu_dse__Fee_Template__c feeTemplateInstance2 = 
            new nu_dse__Fee_Template__c(Portfolio_Name__c = 'ANCHOR', Debt_Amount__c = 'Over 30000', 
                                        nu_dse__Settlement_Pct__c = 42.00, Service_Fee_Percentage__c = 17.00,
                                        Program_Type__c = 'Anchor 2',
                                        nu_dse__GCS_Fee_Group_Id__c = '2341', nu_dse__RAMS_Fee_Group_Id__c = '66666');                                
                                                                 
        List<nu_dse__Fee_Template__c> feeTemplateList = new List<nu_dse__Fee_Template__c> ();
        feeTemplateList.add(feeTemplateInstance1);
        feeTemplateList.add(feeTemplateInstance2);
        insert feeTemplateList;
        
        nu_dse__Processor__c newProcessor = TestRecordCreator.createGCSProcessor();
        insert newProcessor;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolioInstance = 
            new Portfolio__c(Name = 'Anchor', Communication_Template_Email__c = 'test@test.com', Active_Status__c = True);
        insert portfolioInstance;
        
        List<nu_dse__Program__c> programInsertList = new List<nu_dse__Program__c> ();
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c(nu_dse__Account__c = accountInstance.Id, nu_dse__Processor__c = newProcessor.Id);
        programInstance.nu_dse__Fee_Template__c = feeTemplateInstance1.Id;
        programInstance.nu_dse__Total_Debt_Included__c = 14000;
        programInstance.Portfolio__c = portfolioInstance.Id; 
        programInstance.Estimated_Settlement__c = 42;
        programInstance.Settlement_Fee__c = 17;
        programInsertList.add(programInstance);
        
        nu_dse__Program__c programInstance2 = new nu_dse__Program__c(nu_dse__Processor__c = newProcessor.Id);
        programInstance2.Estimated_Settlement__c = 42;
        programInstance2.GCS_Policy_Group__c = '4123';
        programInstance2.nu_dse__Total_Debt_Included__c = 28000;
        programInstance2.Portfolio__c = portfolioInstance.Id; 
        programInstance2.Settlement_Fee__c = 17;
        programInsertList.add(programInstance2);
        
        nu_dse__Program__c programInstance4 = new nu_dse__Program__c(nu_dse__Processor__c = newProcessor.Id);
        programInstance4.nu_dse__Total_Debt_Included__c = 32000;
        programInstance4.Portfolio__c = portfolioInstance.Id; 
        programInstance4.Estimated_Settlement__c = 42;
        programInstance4.Settlement_Fee__c = 17;
        programInsertList.add(programInstance4);
        
        nu_dse__Program__c programInstance1 = new nu_dse__Program__c(nu_dse__Processor__c = newProcessor.Id);
        programInstance1.Estimated_Settlement__c = 42;
        programInstance1.GCS_Policy_Group__c = '4123';
        programInstance1.nu_dse__Total_Debt_Included__c = 48000;
        programInstance1.Portfolio__c = portfolioInstance.Id; 
        programInstance1.Settlement_Fee__c = 17;
        programInsertList.add(programInstance1);
        
        nu_dse__Program__c programInstance3 = new nu_dse__Program__c(nu_dse__Processor__c = newProcessor.Id);
        programInstance3.Portfolio__c = portfolioInstance.Id;
        programInstance3.Estimated_Settlement__c = 42;
        programInsertList.add(programInstance3);
        
        insert programInsertList;
        
        for (nu_dse__Program__c programInst : [SELECT Id, nu_dse__Fee_Template__c, GCS_Policy_Group__c, Settlement_Fee__c FROM nu_dse__Program__c]) {
            
            system.debug('programInst-->'+ programInst);
        }
        
        List<nu_dse__Program__c> programUpdateList = new List<nu_dse__Program__c>();
        
        programInstance.nu_dse__Total_Debt_Included__c = 32000;
        programInstance.DNL_Status__c = 'Lead Active' ;
        programInstance.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance);
        
        programInstance4.nu_dse__Total_Debt_Included__c = 48000;
        programInstance4.DNL_Status__c = 'Lead Active' ;
        programInstance4.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance4);
        
        programInstance2.nu_dse__Total_Debt_Included__c = 23000;
        programInstance2.DNL_Status__c = 'Lead Active' ;
        programInstance2.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance2);
        
        programInstance3.nu_dse__Total_Debt_Included__c = 11000;
        programInstance3.DNL_Status__c = 'Lead Active' ;
        programInstance3.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance3);
        
        programInstance1.nu_dse__Total_Debt_Included__c = 14000;
        programInstance1.DNL_Status__c = 'Lead Active' ;
        programInstance1.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance1);
        
        Test.startTest();
        PolicyGroupAssignmentHandler.QueueableMethodCalled = false;
        update programUpdateList;
        
        Test.stopTest();
        Map<Id, nu_dse__Program__c> oldmapForProgram = new Map<Id, nu_dse__Program__c>() ;
        for(nu_dse__Program__c oldproram: programInsertList){
            oldmapForProgram.put(oldproram.Id , oldproram) ;
        }
        programInstance.nu_dse__Total_Debt_Included__c = 32000;
        programInstance.DNL_Status__c = 'Lead Active' ;
        programInstance.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance);
        
        programInstance4.nu_dse__Total_Debt_Included__c = 48000;
        programInstance4.DNL_Status__c = 'Lead Active' ;
        programInstance4.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance4);
        
        programInstance2.nu_dse__Total_Debt_Included__c = 23000;
        programInstance2.DNL_Status__c = 'Lead Active' ;
        programInstance2.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance2);
        
        programInstance3.nu_dse__Total_Debt_Included__c = 11000;
        programInstance3.DNL_Status__c = 'Lead Active' ;
        programInstance3.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance3);
        
        programInstance1.nu_dse__Total_Debt_Included__c = 14000;
        programInstance1.DNL_Status__c = 'Lead Active' ;
        programInstance1.Program_Type__c = 'Anchor' ;
        programUpdateList.add(programInstance1);
        
        PolicyGroupAssignmentHandler.programPolicyGroupMapping(oldmapForProgram, programUpdateList) ;
        
        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Fee_Template__c, GCS_Policy_Group__c, Settlement_Fee__c  
                                                FROM nu_dse__Program__c WHERE Id = :programInstance.Id];
        
        System.debug('programList--->'+programList);
        System.assertEquals(1, programList.size());
        //System.assertEquals(programList[0].nu_dse__Fee_Template__c, feeTemplateInstance2.Id);
        //System.assertEquals('2341', programList[0].GCS_Policy_Group__c);
        //System.assertEquals(17, programList[0].Settlement_Fee__c );
        
        List<nu_dse__Program__c> program1List = [SELECT Id, nu_dse__Fee_Template__c, GCS_Policy_Group__c, Settlement_Fee__c  
                                                FROM nu_dse__Program__c WHERE Id = :programInstance3.Id];
        
        //System.assertEquals(1, program1List.size());
        //System.assertEquals('1234', program1List[0].GCS_Policy_Group__c);
        //System.assertEquals(program1List[0].nu_dse__Fee_Template__c, null);
        
    }
    
    @testSetup
    public static void dataSetup() {
        
        List<Holiday> holidays = new List<Holiday>{
            
            new Holiday(Name='Test holiday for Attorney', activitydate = System.Today().addMonths(8)),
            new Holiday(Name='Test holiday for Non Attorney', activitydate = System.Today().addMonths(6), IsRecurrence = TRUE, 
                        RecurrenceStartDate = System.Today().addMonths(6), RecurrenceType = 'RecursYearly', 
                        RecurrenceDayOfMonth = System.Today().addMonths(6).day(), RecurrenceEndDateOnly = NULL,
                        RecurrenceMonthOfYear = DateTime.newInstance(System.Today().addMonths(6), System.Time.newInstance(0, 0, 0, 0)).format('MMMMM'))
        };
        insert holidays;
    }
    
    @isTest
    public static void populatingEnrollmentDateAndStrategyCallDate_Test() {
    
        List<nu_dse__Program__c> updatedPrograms = new List<nu_dse__Program__c>();
        
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{
            
            new nu_dse__Program__c(Attorney__c = True, Import_ID__c = 'TestImportId1'),
            new nu_dse__Program__c(Attorney__c = True, Import_ID__c = 'TestImportId2'),
            new nu_dse__Program__c(nu_dse__Program_Status__c = 'Active Client'),
            new nu_dse__Program__c(nu_dse__Program_Status__c = 'Active Client')
        };
        insert programs;
        
        programs[0].nu_dse__Program_Status__c = 'Active Client';
        updatedPrograms.add(programs[0]);
        
        programs[1].nu_dse__Program_Status__c = 'Active Client';
        updatedPrograms.add(programs[1]);
        
        update updatedPrograms;
        
        List<nu_dse__Program__c> programList = [SELECT Id, Enrollment_Date__c, nu_dse__Program_Status__c, Attorney__c , Expected_Strategy_Call_Date__c  FROM nu_dse__Program__c];
        System.assertEquals(System.Today(), programList[0].Enrollment_Date__c);
    }
    
    @isTest
    public static void test_Batch_CreateStrategyCallTaskOnProgram(){
        
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{
            
            new nu_dse__Program__c(Expected_Strategy_Call_Date__c = System.Today()),
            new nu_dse__Program__c(Expected_Strategy_Call_Date__c = System.Today())
        };
        insert programs;
        
        List<nu_dse__Tradeline__c> tradelines = new List<nu_dse__Tradeline__c>{
            
            new nu_dse__Tradeline__c(nu_dse__Original_Debt__c = 30000, SFS_Current_Balance__c = 1000, 
                                     nu_dse__Original_Account_Number__c = '0000000000098765', nu_dse__Current_Stage__c = 'Settled', 
                                     nu_dse__Program__c = programs[1].Id),
            new nu_dse__Tradeline__c(nu_dse__Original_Debt__c = 30000, SFS_Current_Balance__c = 10000, 
                                     nu_dse__Original_Account_Number__c = '0000000000098765', nu_dse__Program__c = programs[0].Id)
        };
        insert tradelines;
        
        Test.startTest();
        
        Database.executeBatch(new Batch_CreateStrategyCallTaskOnProgram());
        
        Test.stopTest();
        
        //List<nu_dse__Group_Task__c> groupTasks = [SELECT Id, Subject_Picklist__c FROM nu_dse__Group_Task__c WHERE nu_dse__Related_To__c = :programs[0].Id];
        //System.assertEquals('7 month Strategy Call (TL only)', groupTasks[0].Subject_Picklist__c);
    }
    
    /*@isTest
    public static void programPolicyGroupMappingVersara_Test() {
        
        nu_dse__Data_Mapping__c dataMappingInstance = 
            TestRecordCreator.createDataMapping('PolicyGroupAssignment', null, 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance = 
            new nu_dse__Field_mapping__c (  nu_dse__Data_Mapping__c = dataMappingInstance.Id,
                                            Trust_Account_Provider__c = 'GCS',
                                            Program_Portfolio__c = 'Test Portfolio',
                                            LDP__c = '1234',
                                            Under_30000__c = '4123',
                                            Over_30000__c = '2341',
                                            Over_35000__c = '3412',
                                            Priority_Sequence_Number__c = 1,
                                            Program_Type_30K__c = 'TestPortfolio',
                                            Program_Type_35K__c = 'TestPortfolio',
                                            Populate_Program_Type__c = TRUE,
                                            Policy_Type__c = 'Versara');
        insert fieldMappingInstance;
        
        nu_dse__Fee_Template__c feeTemplateInstance1 = 
            new nu_dse__Fee_Template__c(Portfolio_Name__c = 'Test Portfolio', Debt_Amount__c = 'Under 30000', 
                                        nu_dse__Settlement_Pct__c = 42.00, Service_Fee_Percentage__c = 17.00,
                                        Program_Type__c = 'TestPortfolio', 
                                        nu_dse__GCS_Fee_Group_Id__c = '4123', nu_dse__RAMS_Fee_Group_Id__c = '55555');
                                        
        nu_dse__Fee_Template__c feeTemplateInstance2 = 
            new nu_dse__Fee_Template__c(Portfolio_Name__c = 'Test Portfolio', Debt_Amount__c = 'Over 30000', 
                                        nu_dse__Settlement_Pct__c = 42.00, Service_Fee_Percentage__c = 17.00,
                                        Program_Type__c = 'TestPortfolio',
                                        nu_dse__GCS_Fee_Group_Id__c = '2341', nu_dse__RAMS_Fee_Group_Id__c = '66666');                                
                                        
        nu_dse__Fee_Template__c feeTemplateInstance3 = 
            new nu_dse__Fee_Template__c(Portfolio_Name__c = 'Test Portfolio', Debt_Amount__c = 'Over 30000', 
                                        nu_dse__Settlement_Pct__c = 42.00, Service_Fee_Percentage__c = 17.00,
                                        Program_Type__c = 'TestPortfolio',
                                        nu_dse__GCS_Fee_Group_Id__c = '3412', nu_dse__RAMS_Fee_Group_Id__c = '4444');
                                        
                                        
        
        List<nu_dse__Fee_Template__c> feeTemplateList = new List<nu_dse__Fee_Template__c> ();
        feeTemplateList.add(feeTemplateInstance1);
        feeTemplateList.add(feeTemplateInstance2);
        feeTemplateList.add(feeTemplateInstance3);
        insert feeTemplateList;
        
        nu_dse__Processor__c newProcessor = TestRecordCreator.createGCSProcessor();
        insert newProcessor;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolioInstance = 
            new Portfolio__c(Name = 'Test Portfolio', Communication_Template_Email__c = 'test@test.com', Active_Status__c = True);
        insert portfolioInstance;
        
        List<nu_dse__Program__c> programInsertList = new List<nu_dse__Program__c> ();
        
        nu_dse__Program__c programInstance = new nu_dse__Program__c(nu_dse__Account__c = accountInstance.Id, nu_dse__Processor__c = newProcessor.Id);
        programInstance.nu_dse__Fee_Template__c = feeTemplateInstance2.Id;
        programInstance.GCS_Policy_Group__c = '2341';
        programInstance.Portfolio__c = portfolioInstance.Id; 
        programInstance.nu_dse__Total_Debt_Included__c = 31000;
        programInstance.DNL_Status__c = 'Pre-TILA Signed';
        programInstance.Estimated_Settlement__c = 42;
        programInsertList.add(programInstance);
        
        nu_dse__Program__c programInstance1 = new nu_dse__Program__c(nu_dse__Processor__c = newProcessor.Id);
        programInstance1.nu_dse__Fee_Template__c = feeTemplateInstance2.Id;
        programInstance1.GCS_Policy_Group__c = '2341';
        programInstance1.nu_dse__Total_Debt_Included__c = 32000;
        programInstance1.Portfolio__c = portfolioInstance.Id; 
        programInstance1.DNL_Status__c = 'Pre-TILA Signed';
        programInstance1.Estimated_Settlement__c = 42;
        programInsertList.add(programInstance1);
        
        insert programInsertList;
        
        for (nu_dse__Program__c programInst : [SELECT Id, nu_dse__Fee_Template__c, GCS_Policy_Group__c, Settlement_Fee__c FROM nu_dse__Program__c]) {
            
            system.debug('programInst-->'+ programInst);
        }
        
        List<nu_dse__Program__c> programUpdateList = new List<nu_dse__Program__c>();
        programInstance.nu_dse__Total_Debt_Included__c = 14000;
        programUpdateList.add(programInstance);
        
        programInstance1.nu_dse__Total_Debt_Included__c = 36000;
        programUpdateList.add(programInstance1);
        
        Test.startTest();
        
        update programUpdateList;
        
        Test.stopTest();
        
        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Fee_Template__c, GCS_Policy_Group__c, Settlement_Fee__c  
                                                FROM nu_dse__Program__c WHERE Id = :programInstance.Id];
        
        System.debug('programList--->'+programList);
        System.assertEquals(1, programList.size());
        System.assertEquals(programList[0].nu_dse__Fee_Template__c, feeTemplateList[0].Id);
        System.assertEquals('4123', programList[0].GCS_Policy_Group__c);
        System.assertEquals(17, programList[0].Settlement_Fee__c );
        
        List<nu_dse__Program__c> program1List = [SELECT Id, nu_dse__Fee_Template__c, GCS_Policy_Group__c, Settlement_Fee__c  
                                                FROM nu_dse__Program__c WHERE Id = :programInstance1.Id];
        
        System.assertEquals(1, program1List.size());
        System.assertEquals(program1List[0].nu_dse__Fee_Template__c, feeTemplateList[2].Id);
        System.assertEquals('3412', program1List[0].GCS_Policy_Group__c);
        
    }*/
}