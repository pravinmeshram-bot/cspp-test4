@isTest
public class Offer_ApprovalScreenCtrl_Test {
    
    /*@testSetup static void testSetup() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
    }*/
    
    @isTest static void testMethod1() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef);       
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        
        
        offerApprove.Approve();
        Test.stopTest();
    }
    
    @isTest static void testMethod2() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        //nu_dse__Offer__c offerInstance = new nu_dse__Offer__c();
        //offerInstance = [SELECT Id, nu_dse__Status__c, Source_of_Payment__c, Manager_decline_reason__c, Tradeline_Litigation_Status__c FROM nu_dse__Offer__c LIMIT 1];
        offer.nu_dse__Status__c = 'In-House Attorney Denied';
        offer.Manager_decline_reason__c = 'Math error';
        offer.Source_of_Payment__c = 'PSA';
        offer.Tradeline_Litigation_Status__c = 'Lit'; 
        update offer;  
        
        Offer_ApprovalScreenCtrl offerApproval = new Offer_ApprovalScreenCtrl();
        offerApproval.showActions = true;
        offerApproval.dataSetup();
        offerApproval.Cancel();
        offerApproval.reject();
        offerApproval.Approve();  
        Test.stopTest();         
    }
    
    @isTest static void testMethod3() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        Offer_ApprovalScreenCtrl offerApproval = new Offer_ApprovalScreenCtrl();
        offerApproval.dataSetup();
        offerApproval.Cancel();
        offerApproval.reject();
        offerApproval.Approve();  
        Test.stopTest();   
    }
    
    @isTest static void testMethod4() {
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        insert programInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;

        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        tradeline.SFS_Current_Balance__c = 1;
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.nu_dse__Status__c = null;        
        offerInstance.Manager_decline_reason__c = null;
        insert offerInstance;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offerInstance.Id);
        Test.setCurrentPage(pageRef); 
        
        Offer_ApprovalScreenCtrl offerApproval = new Offer_ApprovalScreenCtrl();
        offerApproval.dataSetup();
        offerApproval.showActions = true;
        offerApproval.reject();
        Test.stopTest();
    }
    
    @isTest static void testMethod5() {
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        insert programInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        tradeline.SFS_Current_Balance__c = 1;
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.nu_dse__Status__c = 'Management Review';
        offerInstance.Source_of_Payment__c = 'PSA';
        offerInstance.Tradeline_Litigation_Status__c = 'Lit'; 
        insert offerInstance;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offerInstance.Id);
        Test.setCurrentPage(pageRef);
        
        Offer_ApprovalScreenCtrl offerApproval = new Offer_ApprovalScreenCtrl();
        offerApproval.dataSetup();
        offerApproval.showActions = true;
        
        offerApproval.Approve();
        System.debug('google');
        Test.stopTest();   
    }
    
    //AttorneyStep1
    @isTest static void testRejectionAttorneyStep1() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        //record.nu_dse__Status__c = 'In-House Attorney Review';
        //record.Attorney_Settlement_Approval_Status__c='None';
        //update record;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef);       
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='In-House Attorney Review';
        //offerApprove.ofr.Portfolio_Name__c = 'Harbor';
        offerApprove.ofr.Attorney_Settlement_Approval_Status__c = 'None';
        
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //AttorneyStep2
    @isTest static void testRejectionAttorneyStep2() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;

        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //AttorneyStep3
    @isTest static void testRejectionAttorneyStep3() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='Authorization and Letter Received';
        offerApprove.ofr.Attorney_Settlement_Approval_Status__c='Obtain Authorization Approved';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //AttorneyStep4
    @isTest static void testRejectionAttorneyStep4() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='To Payment Processing';
        offerApprove.ofr.Attorney_Settlement_Approval_Status__c='Negotiations Associate Review Approved';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //TimberLineStep1
    @isTest static void testRejectionTimberLineStep1() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
          
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='Management Review';
        offerApprove.ofr.Timberline_Settlement_Approval_Status__c='None';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //TimberLineStep2
    @isTest static void testRejectionTimberLineStep2() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='Pending Client Approval';
        offerApprove.ofr.Timberline_Settlement_Approval_Status__c='Management Review Approved';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    
    //TimberLineStep3
    @isTest static void testRejectionTimberLineStep3() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
         offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='Authorization and Letter Received';
        offerApprove.ofr.Timberline_Settlement_Approval_Status__c='Obtain Authorization Approved';
       
        offerApprove.Reject();
        Test.stopTest();
    }
    //TimberLineStep4
    @isTest static void testRejectionTimberLineStep4() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        offerApprove.dataSetup();
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='To Payment Processing';
        offerApprove.ofr.Timberline_Settlement_Approval_Status__c='Negotiations Associate Review Approved';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //DNLStep1
   /* @isTest static void testRejectionDNLStep1() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        Test.startTest();
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        
        offerApprove.dataSetup();
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.Manager_Approved__c=false;
        offerApprove.ofr.nu_dse__Status__c='DNL Manager Review';
        offerApprove.ofr.DNL_Negotiations_Approval_Status__c = 'None';
        offerApprove.ofr.Timberline_Settlement_Approval_Status__c = 'None';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //DNLStep2
    @isTest static void testRejectionDNLStep2() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        Test.startTest();
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        
        offerApprove.dataSetup();
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.Authorization_Received__c=true;
        offerApprove.ofr.Letter_Uploaded__c=true;
        offerApprove.ofr.DNL_Negotiations_Approval_Status__c = 'In-House Attorney Review Approved';
        
        offerApprove.Reject();
        Test.stopTest();
    }
    //DNLStep3
    @isTest static void testRejectionDNLStep3() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        Test.startTest();
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        offerApprove.dataSetup();
        offerApprove.Approve();
        
        offerApprove.dataSetup();
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.Is_Negotiation_Manager_Approved__c=true;
        offerApprove.ofr.DNL_Negotiations_Approval_Status__c = 'Negotiations Associate Review Approved';
        
        offerApprove.Reject();
        Test.stopTest();
    }*/
    
    
    //AttorneyStep11
    @isTest static void testRejectionAttorneyStep11() {
        nu_dse__Processor__c processorInstance = New nu_dse__Processor__c(Name = 'RAM - Harbor', nu_dse__Type__c = 'RAMS');
        insert processorInstance;
        
        Account accountInstance = TestRecordCreator.createAccount(TestRecordCreator.getRecordTypeId('Account', 'Client'));     
        insert accountInstance;
        
        Portfolio__c portfolio = new Portfolio__c(Name='Royal', Communication_Template_Email__c='test@test.com', Active_Status__c=true);
        insert portfolio;
        
        nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c =true;
        testProgram.Import_ID__c='1234';
        testProgram.nu_dse__Account__c = accountInstance.Id;
        testProgram.Portfolio__c=portfolio.Id;
        testProgram.nu_dse__Program_Status__c='Active Client';
        testProgram.nu_dse__Processor__c=processorInstance.Id;
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        tradeline.Applicant_Type__c='Applicant';
        tradeline.nu_dse__Original_Account_Number__c='8494';
        tradeline.nu_dse__Current_Stage__c='Authorization and Letter Received';
        insert tradeline;
        
        nu_dse__Offer__c offer = new nu_dse__Offer__c();
        offer.nu_dse__TradeLine__c = tradeline.Id; 
        offer.nu_dse__Program__c = testProgram.Id;
        offer.nu_dse__Status__c = 'In-House Attorney Review';
        offer.Source_of_Payment__c='PSA';
        offer.Tradeline_Litigation_Status__c='Lit';
        offer.Latest_Offer__c=true;
        insert offer;
        //record.nu_dse__Status__c = 'In-House Attorney Review';
        //record.Attorney_Settlement_Approval_Status__c='None';
        //update record;
        
        Test.startTest();
        
        PageReference pageRef = Page.Offer_ApprovalScreen;
        pageRef.getParameters().put('recId', offer.Id);
        Test.setCurrentPage(pageRef);       
        
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        Offer_ApprovalScreenCtrl offerApprove = new Offer_ApprovalScreenCtrl(sc);
        
        offerApprove.ofr.Rejection_Reason__c='Authorization Error';
        offerApprove.ofr.nu_dse__Status__c='In-House Attorney Review';
        
        offerApprove.ofr.Attorney_Settlement_Approval_Status__c = 'None';
        
        offerApprove.dataSetup();
        offerApprove.Reject();
        Test.stopTest();
    }
    
    
}