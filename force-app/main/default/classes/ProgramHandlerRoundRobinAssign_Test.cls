@isTest
public class ProgramHandlerRoundRobinAssign_Test {
    
    @testSetup
    public static void TestSetup() {
    
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'nu_dse__Program__c');
        insert q1;
        
        User user1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             Attorney_Admin__c = false,
             FirstName = 'First',
             LastName = 'last',
             Email = 'puser000@test.com',
             Username = 'puser000@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        
        insert user1;
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = UserInfo.getUserId();
        member.GroupId = g1.Id;
        
        insert member;
        
        GroupMember member1 = new GroupMember();
        member1.UserOrGroupId = user1.Id;
        member1.GroupId = g1.Id;
        
        insert member1;
    }

    static testMethod void testProgramHandlerRoundRobinAssign_Success() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Timberline';
        program.ClientEmail__c = 'test@test.com';
        insert program;
                
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Failure() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.ClientEmail__c = 'test@test.com';
        program.Program_Type__c = 'Timberline';
        insert program;
                
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name 1';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
        
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
           
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            System.assertEquals(true, String.isBlank(programList[0].Retention_Rep__c));  
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_PIONEER() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'PIONEER';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Anchor() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Anchor';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Bedrock() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Bedrock';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Boulder() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Boulder';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_CALF() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'CALF';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Canyon() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Canyon';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_CarolinaLegalServices() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Carolina Legal Services';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_GreatLakes() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'GREAT LAKES';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Harbor() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Harbor';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Heartland() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Heartland';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Lighthouse() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Lighthouse';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Rockwell() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Rockwell';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Stonepoint() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Stonepoint';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Summit() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Summit';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Royal() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Royal';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
    static testMethod void testProgramHandlerRoundRobinAssign_Whitestone() {
        
        List<user> userList = [SELECT ID FROM User WHERE Email = 'puser000@test.com'];
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Program__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Portfolio__c portfolioInst = new Portfolio__c();
        portfolioInst.Name = 'Whitestone';
        portfolioInst.Active_Status__c = True;
        insert portfolioInst;
        
        nu_dse__Program__c program = TestRecordCreator.createProgram(null, null, 'No Account');
        program.recordTypeId = recordTypeMap.get('Debt Settlement').getRecordTypeId();
        program.nu_dse__Program_Status__c = 'NSF';
        program.Program_Type__c = 'Whitestone';
        program.ClientEmail__c = 'test@test.com';
        program.Portfolio__c = portfolioInst.Id;
        
        insert program;
        
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Rep Assignment Data';
        rentention.Queue_Name__c  = 'group name';
        rentention.User_Number__c = 2;
        insert rentention;
        
        System.runAs(userList[0]) { 
            
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            program.nu_dse__Program_Status__c = 'Pending Cancellation';
            
            Test.startTest();
                
                update program;
                
            Test.stopTest();  
            //List<nu_dse__Program__c> programList = [SELECT Id, Retention_Rep__c FROM nu_dse__Program__c WHERE Id =:program.Id ];
            //System.assertEquals(userList[0].Id, programList[0].Retention_Rep__c); 
        }
    }
    
}