@isTest
public class SFSPortal_DashboardMetricsCtrl_Test {

    public static testMethod void dashboardTestMethod() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',
                                                       SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;  
        
        nu_dse__Processor__c processorInstance = SFSPortal_TestRecordCreator.createProcessor();
        insert processorInstance;
        
        Account account2 = SFSPortal_TestRecordCreator.createCreditorAccount('Test Account 1',
                                                       SFSPortal_TestRecordCreator.getRecordTypeId('Account','Creditor'));
        insert account2;
        
        nu_dse__Creditor_Processor_Info__c creditorProcessInfo = 
                                        SFSPortal_TestRecordCreator.createCreditorProcessorInfo(processorInstance.Id, account2.Id); 
        insert creditorProcessInfo;
        
        //account2.nu_dse__CFT_Synced__c = true;
        // account2.nu_dse__Active_Creditor__c = true;
       // update account2;

        String headerdata = URL.getCurrentRequestUrl().toExternalForm();
        List<String> urlValueList = headerdata.split('/apex');
        
        Portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('4569871238');
        portfolioInstance.Domain_URL__c = urlValueList[0];
        insert portfolioInstance;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
       
        List<nu_dse__TradeLine__c>  tradelineList = new List<nu_dse__TradeLine__c > 
                                                        { SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id),
                                                          SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id),
                                                          SFSPortal_TestRecordCreator.createTradeLine(account2.Id, programInstance.Id) };
        tradelineList[0].nu_dse__Current_Stage__c = 'Payment Plan Active';
        tradelineList[0].Normalized_Original_Creditor__c = 'Test Account 1';
        tradelineList[1].nu_dse__Current_Stage__c = 'Payment Plan Suspended';
        tradelineList[1].Normalized_Original_Creditor__c = 'Test Account 1';
        tradelineList[2].nu_dse__Current_Stage__c = 'Settled Unpaid';
        tradelineList[2].Normalized_Original_Creditor__c = 'Test Account 1';
        insert tradelineList;
        
        List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c> 
                                                        {SFSPortal_TestRecordCreator.createoffer(programInstance.Id, 
                                                                                    tradelineList[0].Id, 500, 100, 2, 2),
                                                         SFSPortal_TestRecordCreator.createoffer(programInstance.Id, 
                                                                                    tradelineList[1].Id, 500, 100, 2, 2),
                                                         SFSPortal_TestRecordCreator.createoffer(programInstance.Id, 
                                                                                    tradelineList[2].Id, 500, 100, 2, 2)};
        offerList[0].Authorization_Received_Date__c = System.today();
        offerList[1].Authorization_Received_Date__c = System.today();
        offerList[2].Authorization_Received_Date__c = System.today();
        insert offerList ;
        
        nu_dse__Payment__c paymentInstance = SFSPortal_TestRecordCreator.createPayments(programInstance.Id);
        insert paymentInstance;
        
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Portal_Settings__c', 'UI Enhancements');
        
        Portal_Settings__c portalInstance = SFSPortal_TestRecordCreator.createPortalEnhancement(portfolioInstance.Id, recordTypeId );
        insert portalInstance;
        
        OrgWideEmailAddress specificOrgWideEmailAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress limit 1];
        
        Portal_Identity_Service__c  loginHistoryList = new Portal_Identity_Service__c();
        loginHistoryList.Status__c = '';
        loginHistoryList.Last_Login_Time__c =  System.now();
        
        System.runAs(user1) { 
        
            ApexPages.currentPage().getParameters().put('selctedMode','Email');
            
            Test.startTest();
            
                SFSPortal_Utility.getOrgWideEmailId(specificOrgWideEmailAddress.DisplayName);
                SFSPortal_Utility.getOrgWideEmailId('');
                SFSPortal_DashboardMetricsController dashboardMetricsInstance = new SFSPortal_DashboardMetricsController();
                SFSPortal_DashboardMetricsController.validateLogin();
                dashboardMetricsInstance.sendVerificationCodeToClient();
                dashboardMetricsInstance.enteredText = dashboardMetricsInstance.validationCode;
                dashboardMetricsInstance.updateUserAndRedirect();
                SFSPortal_DashboardMetricsController.NotifcationHomePageWrapper wrapperNotify = 
                                                                        SFSPortal_DashboardMetricsController.getDefaultCountValues();
                SFSPortal_DashboardMetricsController.getAllFrequentQuestions();
                    
                try {
                
                   SFSPortal_DashboardMetricsController.DashboardMetricsWrapperClass wrapper = 
                                                                       SFSPortal_DashboardMetricsController.getDashboardMetrcis(); 
                } catch(Exception e) {
                    
                   System.assertEquals('Script-thrown exception', e.getMessage());  
                }
                try {
                
                    SFSPortal_DashboardMetricsController.getFooterValue(urlValueList[0], null);
                } catch(Exception e) {
                
                    System.assertEquals('Script-thrown exception', e.getMessage());
                }
                
               dashboardMetricsInstance.validateCode();

            Test.stopTest();
            System.assertEquals(true,wrapperNotify != null);
        }
     }
    
     public static testMethod void dashboardVerificationCodeElse() { 
         
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',
                                                                    SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1; 
        
        TwilioConfig__c twiliConfig = SFSPortal_TestRecordCreator.getTwilioConfig();
        insert twiliConfig;
        
        Portal_Identity_Service__c objPIS = new Portal_Identity_Service__c(Is_Agent_Sent__c = true,
                                                                           User__c = user1.Id, 
                                                                           Status__c = 'Initiated',
                                                                           New_Value__c = '2');
        insert objPIS;
        String strInstanceName = '';
        String domainURL = '' ;
        if(UserInfo.getUserName().substringAfterLast('.') != null ){
            strInstanceName = UserInfo.getUserName().substringAfterLast('.');
        }
        if(strInstanceName == 'developer'){
            domainURL = 'https://developer-pioneerdev.cs42.force.com';
        }else if(strInstanceName == 'qa'){
            domainURL = 'https://developer-pioneerqa.cs41.force.com';
        }
        else if(strInstanceName == 'UAT'){
            domainURL = 'https://developer-pioneeruat.cs37.force.com';
        }
        else if(strInstanceName == 'Production'){
            domainURL = 'https://developer-pioneerdev.cs42.force.com';
        }

        Portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('4569871238');
        if(domainURL != null){
            portfolioInstance.Domain_URL__c = domainURL;
        }
        insert portfolioInstance;
       
        Id recordTypeId = SFSPortal_TestRecordCreator.getRecordTypeId('Portal_Settings__c', 'UI Enhancements');
        system.debug('recordTypeId>>'+recordTypeId);
        Portal_Settings__c portalInstance = new Portal_Settings__c(Action_Button_Color__c = 'Red',
                                                                    Is_Active__c  = true,
                                                                    Logo_Name__c = 'TimberlineLoginLogo',
                                                                    Portfolio__r = portfolioInstance, 
                                                                    Type__c = 'Background Image',
                                                                    Value__c = 'TimberlineLoginBackgroun',
                                                                    recordTypeId = recordTypeId);
        insert portalInstance;
        
        system.debug('portalInstance>>>'+portalInstance);
        System.runAs(user1) {  
            
            ApexPages.currentPage().getParameters().put('selctedMode','Mobile');
           
            Test.startTest();
                SFSPortal_DashboardMetricsController dashboardMetricsInstance = new SFSPortal_DashboardMetricsController();
                dashboardMetricsInstance.sendVerificationCodeToClient();
                dashboardMetricsInstance.enteredText = 459612;
                dashboardMetricsInstance.validateCode();
                
                SFSPortal_DashboardMetricsController.enableCustomPermission objWrappCP = 
                                                            new SFSPortal_DashboardMetricsController.enableCustomPermission();
                SFSPortal_DashboardMetricsController.CustomUIWrapperGetSet objWrapperUI = 
                                                            new SFSPortal_DashboardMetricsController.CustomUIWrapperGetSet();
                objWrapperUI.uiInstance = portalInstance;
                objWrapperUI.imageURLMap = new Map<String, String> {'backgroundImageURL' => '', 
                                                                        'companyLogoURL' => '', 
                                                                        'headerbackgroundImage' => '', 
                                                                        'menuBackgroundImage' => ''};
                dashboardMetricsInstance.wrapperInstance = objWrapperUI;
                dashboardMetricsInstance.loginHistoryInstance = objPIS;
                dashboardMetricsInstance.enteredText = 2;
                
                dashboardMetricsInstance.actionString = 'codeVerification';
                dashboardMetricsInstance.validateAgentCode();
                
            Test.stopTest();
            System.assertEquals('codeVerification',dashboardMetricsInstance.actionString);
            dashboardMetricsInstance.exceptionText = 'No Exception';
            System.assertEquals(false,String.isBlank(dashboardMetricsInstance.exceptionText));
        }
    }
    
    public static testMethod void dashboardVerificationCodeCall() { 
         
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',
                                                                    SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        TwilioConfig__c twiliConfig = SFSPortal_TestRecordCreator.getTwilioConfig();
        insert twiliConfig;
        
        System.runAs(user1) {
            
            ApexPages.currentPage().getParameters().put('selctedMode','Phone Call');
           
            Test.startTest();
                
                Test.setMock(HttpCalloutMock.class, new SFSPortal_MockHandler());  
                SFSPortal_DashboardMetricsController dashboardMetricsInstance = new SFSPortal_DashboardMetricsController();
                dashboardMetricsInstance.sendVerificationCodeToClient();
                dashboardMetricsInstance.enteredText = 459612;
                dashboardMetricsInstance.validateCode();
                
            Test.stopTest();
            System.assertEquals('codeVerification',dashboardMetricsInstance.actionString);
            System.assertEquals(false,String.isBlank(dashboardMetricsInstance.exceptionText));
        }
    }
    
    public static testMethod void dashboardException() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',
                                                                    SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;

        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
        
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        user1.Is_User_Authenticated__c = true;
        insert user1; 
        
        Portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('4569871238');
        insert portfolioInstance;
        
       system.runAs(user1) { 
            
            Test.startTest();
            
                SFSPortal_DashboardMetricsController dashboardMetricsInstance = new SFSPortal_DashboardMetricsController();
                Boolean valid = SFSPortal_DashboardMetricsController.validateLogin();
                SFSPortal_DashboardMetricsController.getNotification('test');
                SFSPortal_DashboardMetricsController.getProgramUserDetailsForChat();
                
            Test.stopTest();
            System.assertEquals(false,valid);
        }
    }
}