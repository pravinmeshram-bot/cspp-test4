@isTest
public class ProgramHandler_Test {

    @testsetup
    public static void testData(){
    
        Id clientID = [Select id from RecordType where sObjectType='Account' and  DeveloperName='Client' and ispersonType=true limit 1].Id;
        Id draftId = [select id from RecordType where sObjectType='nu_dse__Payment__C' and developerName='Draft' limit 1 ].id;
        
        Velocify_Settings__c settings = TestRecordCreator.createVelocifySettings();         
        insert settings; 
        
        nu_dse__Data_Mapping__c datamapping = TestRecordCreator.createDataMapping('Salesforce','Velocify','VelocifyLead');       
        insert datamapping; 
        
        nu_dse__Data_Mapping__c datamapping2 = TestRecordCreator.createDataMapping('Salesforce','Velocify','VelocifyLeadPayments');        
        insert datamapping2; 
        
        nu_dse__Field_mapping__c fieldMapping = TestRecordCreator.createFieldMapping(datamapping.id,'nu_dse__First_Name__c','119');
        
        nu_dse__Field_mapping__c fieldMapping2 = TestRecordCreator.createFieldMapping(datamapping.id,'nu_dse__Last_name__c','120');
        
        nu_dse__Field_mapping__c fieldMapping3 = TestRecordCreator.createFieldMapping(datamapping.id,'nu_dse__Program_Length__c','136');
        
        nu_dse__Field_mapping__c fieldMapping4 = TestRecordCreator.createFieldMapping(datamapping2.id,'Payment 1 Date','119');
        
        nu_dse__Field_mapping__c fieldMapping5 = TestRecordCreator.createFieldMapping(datamapping2.id,'Payment 1 Amount','120');
        
        nu_dse__Field_mapping__c fieldMapping6 = TestRecordCreator.createFieldMapping(datamapping2.id,'Debt Submitted Changed Amount','136');

        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>(); 
        
        fieldMappingList.add(fieldMapping);
        fieldMappingList.add(fieldMapping2);
        fieldMappingList.add(fieldMapping3);
        fieldMappingList.add(fieldMapping4);
        fieldMappingList.add(fieldMapping5);
        fieldMappingList.add(fieldMapping6);
        
        insert fieldMappingList; 
        
        nu_dse__Processor__C processor = TestRecordCreator.createProcessor('GCS');
        processor.nu_dse__Type__c = 'GCS';
        insert processor; 
        
        Account a = TestRecordCreator.createAccount('TestLN', clientId );
        a.Phone = '9879879877';        
        insert a; 
        
        nu_dse__Program__c p = TestRecordCreator.createProgram(a.ID, processor.id);
        p.nu_dse__Payment_Frequency__c = 'Monthly'; 
        p.DNL_Status__c = 'NONE';
        p.Draft_Plan_ID__c = '6997142';
        insert p; 
        
    /*    nu_dse__Payment__c p1 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId, null);
              
        nu_dse__Payment__C p2 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
        
        nu_dse__Payment__C p3 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
        
        nu_dse__Payment__c p4 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId, null);
        
        nu_dse__Payment__C p5 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
        
        nu_dse__Payment__C p6 = TestRecordCreator.createPayment(p.id, 'Pending', 'Deposit', draftId,null);
        
        List<nu_dse__Payment__C> payments = new List<nu_dse__Payment__C>();
        
        payments.add(p1);
        payments.add(p2);
        payments.add(p3);
        payments.add(p4);
        payments.add(p5);
        payments.add(p6);
        System.test.startTest();       
        insert payments; 
        System.test.stopTest(); */
    }
    
    public static testmethod void test1(){
        
        nu_dse__Program__C program = [select id,nu_dse__Total_Debt_Included__c from nu_dse__Program__C limit 1];
        
        program.nu_dse__Total_Debt_Included__c = 10000.00; 
        program.External_Id__c = '56789';
        
        System.test.startTest();
        update program; 
        
        List<nu_dse__Payment__C> payments = [select id,nu_dse__Transaction_Status__c from nu_dse__Payment__C ];
        List<nu_dse__Payment__C> updatedPayments = new list<nu_dse__Payment__C>(); 
        
        for(nu_dse__Payment__C p: payments){
            
            p.nu_dse__Transaction_Status__c = 'Completed';
            
            updatedPayments.add(p);
        }
        update updatedPayments; 
        System.test.stopTest();
    }
    
    public static testmethod void cancelledPrograms(){
        
        User user1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
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
            LocaleSidKey = 'en_US',
            attorney_admin__c = true
        );
        insert user1;
        
        System.runAs(user1) {
        
            LeadTracCredentials__c ltc = new LeadTracCredentials__c();
            ltc.Name = 'LeadTrackCredentials';
            ltc.ClientEndPointURL__c = 'http://sandbox.leadtrac.net/2.18/Client.asmxtest';
            ltc.DebtEndPointURL__c = 'http://sandbox.leadtrac.net/2.18/Debt.asmxtest';
            ltc.Password__c = 'PasswordTest';
            ltc.UserName__c = 'dev_teamtest';
            ltc.PaymentEndPointURL__c = 'http://sandbox.leadtrac.net/2.18/Servicing.asmxtest';
            insert ltc;
            
                    
            nu_dse__Program__C program = [select id,nu_dse__Total_Debt_Included__c from nu_dse__Program__C limit 1];
            
            program.Attorney__c = TRUE;
            program.nu_dse__Program_Status__c = 'Cancelled';
            program.External_Id__c = '56789';
            program.nds_Cancellation_Reason__c = 'Loss of employment';
            update program; 
            
            List<nu_dse__Payment__C> payments = [select id,nu_dse__Transaction_Status__c from nu_dse__Payment__C ];
            List<nu_dse__Payment__C> updatedPayments = new list<nu_dse__Payment__C>(); 
            
            for(nu_dse__Payment__C p: payments){
                
                p.nu_dse__Transaction_Status__c = 'Completed';
                updatedPayments.add(p);
            }
            
            update updatedPayments; 
        }        
    }
    
    public static testmethod void renegotiableFlag(){
    
        nu_dse__Data_Mapping__c dataMappingInstance = TestRecordCreator.createDataMapping('FeeTemplateAssignment-PreTILA_signed', null, 'nu_dse__Program__c');
        insert dataMappingInstance;
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c (nu_dse__Data_Mapping__c = dataMappingInstance.Id,
                                                                                       Program_Type__c = 'Test Portfolio',
                                                                                       Trust_Account_Provider__c = 'GCS',
                                                                                       Program_Portfolio__c = 'Test Portfolio',
                                                                                       Amount_Category__c = 'Under 30000',
                                                                                       Original_Policy_Group_Id__c = '45678',
                                                                                       New_Policy_Group_Id__c = '45678');
        insert fieldMappingInstance1;
        
        nu_dse__Fee_Template__c feeTemp= new nu_dse__Fee_Template__c(Portfolio_Name__c = 'Test Portfolio', 
                                                                     Debt_Amount__c = 'Under 30000', 
                                                                     Program_Type__c = 'Test Portfolio',
                                                                     nu_dse__Settlement_Pct__c = 50.00, 
                                                                     Service_Fee_Percentage__c = 11.00,
                                                                     nu_dse__GCS_Fee_Group_Id__c = '45678', 
                                                                     nu_dse__RAMS_Fee_Group_Id__c = '66666');
        insert feeTemp;                                         
       
        
        nu_dse__Program__C program = [select id,nu_dse__Total_Debt_Included__c, nu_dse__Account__c,DNL_Status__c,nu_dse__Fee_Template__c   from nu_dse__Program__C limit 1];
        program.nu_dse__Fee_Template__c = feeTemp.Id;
        program.nu_dse__Total_Debt_Included__c = 10000.00; 
        program.External_Id__c = '56789';
        
        Account acct = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert acct; 
       
        nu_dse__TradeLine__c tradelineInst = TestRecordCreator.createTradeLine(acct.Id, program.Id);
        insert tradelineInst;
        
        nu_dse__Offer__c offerInst = TestRecordCreator.createOffer(program.Id, tradelineInst.Id, 100, 100, 5, 5);
        offerInst.Tradeline_Litigation_Status__c = 'Lit';
        offerInst.nu_dse__Status__c = 'DNL Manager Review';
        insert offerInst;
        
        System.test.startTest();
        
        //program.DNL_Status__c = 'Pre-TILA Signed';
        update program; 
        
        List<nu_dse__Payment__C> payments = [select id,nu_dse__Transaction_Status__c from nu_dse__Payment__C ];
        List<nu_dse__Payment__C> updatedPayments = new list<nu_dse__Payment__C>(); 
        
        for(nu_dse__Payment__C p: payments){
            
            p.nu_dse__Transaction_Status__c = 'Completed';
            
            updatedPayments.add(p);
        }
        update updatedPayments; 
        
        System.test.stopTest();
    }
    
       // ND-305 and ND-306 Start
   public static testMethod void test_updateTradeLineNegotiator(){
   
    nu_dse__Program__c testProgram = new nu_dse__Program__c();
        testProgram.Attorney__c = false;
        
        insert testProgram;
        
        nu_dse__Tradeline__c tradeline = new nu_dse__Tradeline__c(); 
        tradeline.nu_dse__Current_Balance__c = 10000;
        tradeline.nu_dse__Original_Debt__c = 10000;
        tradeline.SFS_Current_Balance__c = 10000;
        tradeline.nu_dse__Program__c = testProgram.Id;
        
        insert tradeline;
        
        testProgram.Negotiator__c = UserInfo.getUserId();
        update testProgram;
        
   }
   
   public static testMethod void test_updateTradeLineChargeOfDate(){
   
   
    nu_dse__Program__c testProgram1 = new nu_dse__Program__c();
        testProgram1.Attorney__c = false;
        
        insert testProgram1;
        
        nu_dse__Tradeline__c tradeline1 = new nu_dse__Tradeline__c(); 
        tradeline1.nu_dse__Current_Balance__c = 10000;
        tradeline1.nu_dse__Original_Debt__c = 10000;
        tradeline1.SFS_Current_Balance__c = 10000;
        tradeline1.nu_dse__Program__c = testProgram1.Id;
        
        insert tradeline1;
        
        
        testProgram1.Enrollment_Date__c = date.today();
        update testProgram1;
        
   }
   
   public static testMethod void test_updateProgramStatus(){
   
   
    nu_dse__Program__c testProgram1 = new nu_dse__Program__c();
        testProgram1.Attorney__c = false;
        testProgram1.nu_dse__Program_Status__c = 'UnResponsive NSF';
        insert testProgram1;
        
        nu_dse__Tradeline__c tradeline1 = new nu_dse__Tradeline__c(); 
        tradeline1.nu_dse__Current_Balance__c = 10000;
        tradeline1.nu_dse__Original_Debt__c = 10000;
        tradeline1.SFS_Current_Balance__c = 10000;
        tradeline1.nu_dse__Program__c = testProgram1.Id;
        
        insert tradeline1;
        
        
        testProgram1.nu_dse__Program_Status__c = 'Client Cancelled';
        testProgram1.nds_Cancellation_Reason__c = 'Program Affordability';
        update testProgram1;
        
   }
   // ND-307
   public static testmethod void test_retentionEmailSplitPerPortfolio(){
   
   List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        List<OrgWideEmailAddress> OrgWideEmailInst = [SELECT Id, DisplayName FROM OrgWideEmailAddress LIMIT 1];
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Name = 'Canyon';
        portfolioInstance.Dispay_Name__c = 'Canyon Legal Group LLC';
        
        if (OrgWideEmailInst.isEmpty() == False) {
            
            portfolioInstance.OWD_Email_Name__c = OrgWideEmailInst[0].DisplayName;
        }
        
        insert portfolioInstance;
        
        // system.debug('====test==='+portfolioInstance);
   
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.Phone = '1231231231';
        account1.nu_dse__Home_Phone__c = null;
        account1.Portfolio__c = portfolioInstance.id;
        
        insert account1;
       
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor');
        
        
   
        Contact con = [select id from Contact where accountid =: account1.Id];
        
        Id prgmRecordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Program__c','Attorney');
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.Invitation_Attempt__c = 'Re-Invitation 1';
        programInstance.nu_dse__Program_Status__c = 'UnResponsive NSF';
        programInstance.RecordTypeId = prgmRecordTypeId ;
        insert programInstance;
        
        //system.debug('====test==='+programInstance);
        
        system.runAs(nonAttorneyUser){
        programInstance.nu_dse__Program_Status__c = 'Client Cancelled';
        programInstance.nds_Cancellation_Reason__c = 'Program Affordability';
        update programInstance;
        }
        
        ProgramTriggerHandler.createTask(Date.today(), 'High', 'Completed', 'Retention email sent', programInstance.id , false);
        ProgramTriggerHandler.sendRetentionEmail(programInstance.id , null , programInstance.ClientEmail__c , con.id, OrgWideEmailInst[0].id);
        
   }
   // End
   
   // ND-332 
   
   public static testMethod void test_portfolioBasedReferToBK(){
   List<Profile> profileList = [select id, name from Profile where name ='Standard User' or name = 'System Administrator'];
        
        List<User> userList = new List<User>();
        
        User nonAttorneyUser = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8',
                                  lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
                                  profileid = profileList[0].Id, timezonesidkey='America/Los_Angeles', 
                                  username='OfferStatusUpdateTrigger_Testuser1@testorg.com', Attorney_Admin__c = False);
        
        insert nonAttorneyUser;
        
        List<OrgWideEmailAddress> OrgWideEmailInst = [SELECT Id, DisplayName FROM OrgWideEmailAddress LIMIT 1];
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        portfolioInstance.Name = 'Canyon';
        portfolioInstance.Dispay_Name__c = 'Canyon Legal Group LLC';
        
        if (OrgWideEmailInst.isEmpty() == False) {
            
            portfolioInstance.OWD_Email_Name__c = OrgWideEmailInst[0].DisplayName;
        }
        
        insert portfolioInstance;
        
        // system.debug('====test==='+portfolioInstance);
   
        
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        account1.PersonBirthdate = system.today().AddDays(-10000);
        account1.nu_dse__SSN__c = '254789658';
        account1.PersonEmail = 'test@test.com';
        account1.Phone = '1231231231';
        account1.nu_dse__Home_Phone__c = null;
        account1.Portfolio__c = portfolioInstance.id;
        
        insert account1;
       
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor');
        
        
   
        Contact con = [select id from Contact where accountid =: account1.Id];
        
        Id prgmRecordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Program__c','Attorney');
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        programInstance.Invitation_Attempt__c = 'Re-Invitation 1';
        programInstance.nu_dse__Program_Status__c = 'UnResponsive NSF';
        programInstance.nu_dse__Last_Disposition__c = 'test';
        programInstance.RecordTypeId = prgmRecordTypeId ;
        insert programInstance;
        
        //system.debug('====test==='+programInstance);
        
        system.runAs(nonAttorneyUser){
        programInstance.nu_dse__Last_Disposition__c = 'Refer to BK';
        update programInstance;
        }
   }
    
}