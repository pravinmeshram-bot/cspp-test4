@isTest
public class SummonHandler_Test {

    @TestSetup
    static void litigationSummonOwnerAssignment_Test() {
    
        List<Group> groupList = new List<Group>{
            new Group(Name='Lit Negotiators', Type='Queue')
        };
        insert groupList;
        
        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User userInstance = new User(
             ProfileId = profileList.size()>0 ? profileList[0].Id : null,
             Attorney_Admin__c = false,
             FirstName = 'Test',
             LastName = 'User',
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
        insert userInstance;
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = userInstance.Id;
        member.GroupId = groupList[0].Id;
        insert member;
        
        /*
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Summon Assignment Data';
        rentention.Queue_Name__c  = 'Lit Negotiators';
        rentention.User_Number__c = 1;
        insert rentention;
        */
               
    }    
    
    @isTest
    static void testMethod1(){
        
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
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
        acct.Phone = '1231231233';
        insert acct;
        
        //List<Group> groupList = new List<Group>{
            //new Group(Name='Lit Support Management', Type='Queue')
        //};
        //insert groupList;
        
        //List<Summon_PortfolioOrState__mdt> portfolioStateList = new List<Summon_PortfolioOrState__mdt>{
            
            //new Summon_PortfolioOrState__mdt(Label = 'NY'),
            //new Summon_PortfolioOrState__mdt(Label = 'Royal')
        //};
       // CustomMetadataGenerator.queryStrResultMap.put('SELECT Id, Label FROM StopTaskCreationInDisposition__mdt WHERE Active__c = True', JSON.serialize(portfolioStateList));
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct.Id, pgm.Id);
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        //List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        //List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        
        Summon__c sc =new Summon__c();
        sc.Tradeline__c = tl.Id;
        insert sc;
        
        //if(!cases.isEmpty()){
            //sc = cases.get(0);
            sc.Hot_Potato__c = 'With Pre-Lit';
            Update sc;
            
            sc.Hot_Potato__c = 'With Inbound Lit Support (Rejected)';
            Update sc;
        //}
        Test.stopTest();
    }
    
    
    @isTest
    static void portfolioOrState_Test() {
        
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.personMailingState = 'AZ';
        acc.Phone = '1231231233';
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
        
        //List<Group> groupList = new List<Group>{
            //new Group(Name='Lit Support Management', Type='Queue')
        //};
        //insert groupList;
        
        //Keep this for back up..
        //List<Summon_PortfolioOrState__mdt> portfolioStateList = new List<Summon_PortfolioOrState__mdt>{
            
            //new Summon_PortfolioOrState__mdt(Label = 'NY'),
            //new Summon_PortfolioOrState__mdt(Label = 'Royal')
        //};
        //CustomMetadataGenerator.queryStrResultMap.put('SELECT Id, Label FROM StopTaskCreationInDisposition__mdt WHERE Active__c = True', JSON.serialize(portfolioStateList));
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct.Id, pgm.Id);
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
    }
    
    @isTest
    static void creditor_Test1() {
        
        List<Account> accountList = new List<Account>();
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        accountList.add(acc);
        
        Account acct1 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct1.Name = 'American Express';
        acct1.Phone = '1231231233';
        accountList.add(acct1);
        
        Account acct2 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct2.Name = 'Cannon Law Firm';
        acct2.Phone = '1231231233';
        accountList.add(acct2);
        
        insert accountList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        List<Creditor_Standardization__c> creditorStandardList = new List<Creditor_Standardization__c>();
        
        Creditor_Standardization__c creditorStandardizationInstance1 = new Creditor_Standardization__c ();
        creditorStandardizationInstance1.Name = 'Cannon Law Firm';
        creditorStandardizationInstance1.Creditor_Name__c = 'Cannon Law Firm';
        
        Creditor_Standardization__c creditorStandardizationInstance2 = new Creditor_Standardization__c ();
        creditorStandardizationInstance2.Name = 'American Express';
        creditorStandardizationInstance2.Creditor_Name__c = 'American Express';
        
        creditorStandardList.add(creditorStandardizationInstance1);
        creditorStandardList.add(creditorStandardizationInstance2);
        
        insert creditorStandardList;
        
        //List<Group> groupList = new List<Group>{
            //new Group(Name='Lit Support Management', Type='Queue')
        //};
        //insert groupList;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        tl.Normalized_Original_Creditor__c = 'American Express';
        //tl.Normalized_Current_Creditor__c = 'Cannon Law Firm';
        tl.nu_dse__New_Creditor__c = acct2.Id;
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        //System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void creditor_Test2() {
        
        List<Account> accountList = new List<Account>();
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        accountList.add(acc);
        
        Account acct1 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct1.Name = 'Mariners Finance';
        acct1.Phone = '1231231233';
        accountList.add(acct1);
        
        Account acct2 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct2.Name = 'Amex';
        acct2.Phone = '1231231233';
        accountList.add(acct2);
        
        insert accountList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        List<Creditor_Standardization__c> creditorStandardList = new List<Creditor_Standardization__c>();
        
        Creditor_Standardization__c creditorStandardizationInstance1 = new Creditor_Standardization__c ();
        creditorStandardizationInstance1.Name = 'Mariners Finance';
        creditorStandardizationInstance1.Creditor_Name__c = 'Mariners Finance';
        
        Creditor_Standardization__c creditorStandardizationInstance2 = new Creditor_Standardization__c ();
        creditorStandardizationInstance2.Name = 'Amex';
        creditorStandardizationInstance2.Creditor_Name__c = 'Amex';
        
        creditorStandardList.add(creditorStandardizationInstance1);
        creditorStandardList.add(creditorStandardizationInstance2);
        
        insert creditorStandardList;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        tl.Normalized_Original_Creditor__c = 'Mariners Finance';
        //tl.Normalized_Current_Creditor__c = 'Mariner Finance';
        tl.nu_dse__New_Creditor__c = acct2.Id;
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void creditor_Test3() {
        
        List<Account> accountList = new List<Account>();
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        accountList.add(acc);
        
        Account acct1 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct1.Name = 'Amex';
        acct1.Phone = '1231231233';
        accountList.add(acct1);
        
        Account acct2 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct2.Name = 'Smith Debnam Narron Drake Saintsing & Myers';
        acct2.Phone = '1231231233';
        accountList.add(acct2);
        
        insert accountList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        List<Creditor_Standardization__c> creditorStandardList = new List<Creditor_Standardization__c>();
        
        Creditor_Standardization__c creditorStandardizationInstance1 = new Creditor_Standardization__c ();
        creditorStandardizationInstance1.Name = 'Smith Debnam Narron Drake Saintsing & Myers';
        creditorStandardizationInstance1.Creditor_Name__c = 'Smith Debnam Narron Drake Saintsing & Myers';
        
        Creditor_Standardization__c creditorStandardizationInstance2 = new Creditor_Standardization__c ();
        creditorStandardizationInstance2.Name = 'Amex';
        creditorStandardizationInstance2.Creditor_Name__c = 'Amex';
        
        creditorStandardList.add(creditorStandardizationInstance1);
        creditorStandardList.add(creditorStandardizationInstance2);
        
        insert creditorStandardList;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        //tl.nu_dse__Original_Creditor__c = '';
        //tl.Normalized_Current_Creditor__c = 'Cannon Law Firm';
        tl.nu_dse__New_Creditor__c = acct2.Id;
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        //System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void minimumResponseDate_Test() {
        
        Integer minimumResponseDays = integer.valueOf(Label.Summon_Minimum_Response_Days);
        
        List<Account> accountList = new List<Account>();
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        accountList.add(acc);
        
        Account acct1 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct1.Name = 'Testing';
        acct1.Phone = '1231231233';
        accountList.add(acct1);
        
        insert accountList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        tl.Excela_Response_Date__c = System.today().addDays(minimumResponseDays-1);
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        System.debug('ResponseDate-->'+[SELECT Id, Response_Date__c FROM nu_dse__Tradeline__c].Response_Date__c);
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void checkDate_Test() {
        
        Integer checkDateNew = integer.valueOf(Label.Summon_CheckDate);
        
        List<Account> accountList = new List<Account>();
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        accountList.add(acc);
        
        Account acct1 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct1.Name = 'Testing';
        acct1.Phone = '1231231233';
        accountList.add(acct1);
        
        insert accountList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        tl.Excela_Response_Date__c = System.today().addDays(checkDateNew);
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        System.debug('ResponseDate-->'+[SELECT Id, Response_Date__c FROM nu_dse__Tradeline__c].Response_Date__c);
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
        
    }
    
    //checkingLitigationStageForAssigningLitSupport
    @isTest
    static void assingOwnerBasedOnPrevTradelineLitStage_Test() {
        
        Integer checkDateNew = integer.valueOf(Label.Summon_CheckDate);
        Integer minimumResponseDays = integer.valueOf(Label.Summon_Minimum_Response_Days);
        
        List<Account> accountList = new List<Account>();
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        accountList.add(acc);
        
        Account acct1 = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct1.Name = 'Testing';
        acct1.Phone = '1231231233';
        accountList.add(acct1);
        
        insert accountList;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Royal';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        List<nu_dse__TradeLine__c> tradelineList = new List<nu_dse__TradeLine__c>();
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        tl.Excela_Response_Date__c = (minimumResponseDays >= checkDateNew)? System.today().addDays(minimumResponseDays+2):System.today().addDays(checkDateNew+2);
        tl.SFS_Current_Balance__c = 10000;
        tradelineList.add(tl);
        
        nu_dse__TradeLine__c t2 = TestRecordCreator.createTradeLine(acct1.Id, pgm.Id);
        t2.Assign_Litigation_Support_Management__c = True;
        t2.SFS_Current_Balance__c = 10000;
        tradelineList.add(t2);
        
        insert tradelineList;
        
        Test.startTest();
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        List<Group> groupList = [SELECT Id FROM Group WHERE (Type = 'Queue' AND DeveloperNAME = 'Lit_Support_Management')];
        
        List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        System.assertEquals(1, cases.size());
        System.assertEquals(groupList[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
    }
    
    @isTest
    static void roundRobin_Test() {
        
        String checkDate = Label.Summon_CheckDate;
               
        Retention_Rep_Assignment__c rentention = new Retention_Rep_Assignment__c();
        rentention.Name = 'Summon Assignment Data';
        rentention.Queue_Name__c  = 'Lit Negotiators';
        rentention.User_Number__c = 1;
        insert rentention;
        
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        insert acc;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        Account acct = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct.Phone = '1231231233';
        insert acct;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct.Id, pgm.Id);
        tl.Excela_Response_Date__c = System.Today().adddays(Integer.valueOf(checkDate)+3);
        tl.SFS_Current_Balance__c = 10000;
        insert tl;
        
        Test.startTest(); 
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        //List<Summon__c> cases = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        //System.assertEquals(1, cases.size());
        //System.assertEquals(userInstance[0].Id, cases[0].OwnerId);
        
        Test.stopTest();
    }
    
    
    @isTest
    static void previousSFSOwnerAssignBeforeRoundRobin_Test() {
        
        String checkDate = Label.Summon_CheckDate;
        
        Account acc = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));
        acc.Phone = '1231231233';
        insert acc;
        
        Portfolio__c portfolio = TestRecordCreator.createPortfolio('234232342332');
        portfolio.Name = 'Timberline';
        portfolio.Active_Status__c = True;
        insert portfolio;
        
        nu_dse__Program__c pgm = TestRecordCreator.createProgram();
        pgm.nu_dse__Account__c = acc.Id;
        pgm.Portfolio__c = portfolio.Id;
        insert pgm;
        
        Account acct = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        acct.Phone = '1231231233';
        insert acct;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acct.Id, pgm.Id);
        tl.Excela_Response_Date__c = System.Today().adddays(Integer.valueOf(checkDate)+3);
        tl.SFS_Current_Balance__c = 10000;
        
        nu_dse__TradeLine__c t2 = TestRecordCreator.createTradeLine(acct.Id, pgm.Id);
        t2.Excela_Response_Date__c = System.Today().adddays(Integer.valueOf(checkDate)+3);
        t2.SFS_Current_Balance__c = 10000;
        
        List<nu_dse__TradeLine__c> tradelineList = new List<nu_dse__TradeLine__c> ();
        tradelineList.add(tl);
        tradelineList.add(t2);
        
        insert tradelineList;
        
        Summon__c summonInstance = new Summon__c();
        
        summonInstance.Program__c = pgm.Id;
        summonInstance.Subject__c = 'New Legal File';
        summonInstance.Tradeline__c = t2.Id;
        insert summonInstance;
        
        Test.startTest(); 
        
        tl.Litigation_Stage__c = 'Summons';
        update tl;
        
        Test.stopTest();
        
        List<Summon__c> case1 = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Tradeline__c = :tl.Id];
        List<Summon__c> case2 = [SELECT Id, Name, OwnerId FROM Summon__c WHERE Id = :summonInstance.Id];
        
        System.assertEquals(case2[0].OwnerId, case1[0].OwnerId);
        
    }
    
    //s20-463 start
   /*public static testmethod void testDelete(){
        list<nu_dse__Tradeline__c> ndtl = [Select Id From nu_dse__Tradeline__c Where nu_dse__Current_Stage__c='New'];
        insert ndtl;
        Summon__c opp = new Summon__c(Status__c='Review Legal File', Tradeline__c =ndtl[0].Id);
        insert opp;
       
        Test.startTest();
        delete opp;
        Test.stopTest();
    }
    
    public static testmethod void testUndelete(){
        list<nu_dse__Tradeline__c> ndtl = [Select Id From nu_dse__Tradeline__c Where nu_dse__Current_Stage__c='New'];
        insert ndtl;
        
        Summon__c opp = new Summon__c(Status__c='Review Legal File', Tradeline__c =ndtl[0].Id);
        insert opp;
        delete opp;
        
        Test.startTest();
        Undelete opp;
        Test.stopTest();
    }*/
    //s20-463 ends
}