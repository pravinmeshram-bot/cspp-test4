/* Date : 05-10-2018
* Author : Team IDev
* Description : Handler for Dashboard Metrics component
*/
public class SFSPortal_DashboardMetricsController {
    
    /* Date : 03-11-2018
	* Description : Get Set variables for the loginflow page
	* Invoked From : LoginFlow2FAPage
	*/
    
    public Integer validationCode {get; set;}
    
    public String actionString {get; set;}
    
    public Integer enteredText {get; set;}
    
    public String exceptionText {get; set;}
    
    public User userInstance {get; set;}
    
    public DateTime sentTime {get; set;}
    
    Public nu_dse__Program__c programInstance {get; set;}
    public static nu_dse__Program__c programInstanceForChat {get; set;}
    public static user userInstanceForChat {get; set;}
    
    public CustomUIWrapperGetSet wrapperInstance {get; set;}
    
    public Portal_Identity_Service__c loginHistoryInstance {get; set;}
    public Portal_Identity_Service__c identityVerificationInstance {get; set;}
    
    public SFSPortal_DashboardMetricsController() {
        
        this.actionString = 'modeSelection';
        List<User> userList = [SELECT Id, contact.AccountId, Name, FirstName, LastName, MobilePhone, Email, 
                               PortalUserEmail__c, PortalUserMobile__c 
                               FROM User 
                               WHERE Id = :UserInfo.getUserId() AND contact.AccountId != null];
        
        if(userList.isEmpty() == FALSE) {
            
            this.userInstance = userList[0];
            userInstanceForChat =  userList[0];
            List<nu_dse__Program__c> programList = [ SELECT Id, Name, nu_dse__Account__c, Portfolio__c, 
                                                    nu_dse__Program_Status__c,Enrollment_Date__c, 
                                                    nu_dse__Total_Debt__c,nu_dse__Total_Debt_Included__c, 
                                                    nu_dse__Account__r.Demo_User__c 
                                                    FROM nu_dse__Program__c 
                                                    WHERE nu_dse__Account__c =: userList[0].contact.AccountId];
            if(programList.isEmpty() == False) {
                
                this.programInstance = programList[0];
                programInstanceForChat = programList[0];
            }
        }
        
        String headerdata = URL.getCurrentRequestUrl().toExternalForm(); 
        List<String> urlValueList = headerdata.split('/apex');//String.valueOf(Apexpages.currentPage().getUrl()).split('/');
        
        // Get the URL for the current request.
        if(urlValueList != null && urlValueList.isEmpty() == FALSE) {
            
            String url =  urlValueList[0];//headerdata + '/Dashboard';// + urlValueList[1];
            CustomUIWrapper wrapper = getCustomPortalUIValues(url, null);
            
            this.wrapperInstance = new CustomUIWrapperGetSet();
            this.wrapperInstance.uiInstance = new Portal_Settings__c();
            this.wrapperInstance.imageURLMap = new Map<String, String> {'backgroundImageURL' => '', 
                'companyLogoURL' => '', 
                'headerbackgroundImage' => '', 
                'menuBackgroundImage' => ''};
                    this.wrapperInstance.uiInstance = wrapper.uiInstance;
            this.wrapperInstance.imageURLMap.put('companyLogoURL', 
                                                 wrapper.companyLogoURL != null ? wrapper.companyLogoURL : '');
            this.wrapperInstance.imageURLMap.put('backgroundImageURL', 
                                                 wrapper.backgroundImageURL != null ? wrapper.backgroundImageURL : '');
            this.wrapperInstance.imageURLMap.put('headerbackgroundImage', 
                                                 wrapper.headerbackgroundImage != null ? wrapper.headerbackgroundImage : '');
            this.wrapperInstance.imageURLMap.put('menuBackgroundImage', 
                                                 wrapper.menuBackgroundImage != null ? wrapper.menuBackgroundImage : '');
        }
    }
    
    @RemoteAction
    public static String getNotification(String accountName) {
        return 'Hellooooo'; 
    }
    
    @AuraEnabled
    public static ProgramUserInstanceWrapper getProgramUserDetailsForChat(){
        ProgramUserInstanceWrapper puiw = new ProgramUserInstanceWrapper();
        puiw.programInstance = programInstanceForChat;
        puiw.userInstance = userInstanceForChat;
        System.debug('programInstanceForChat ' + puiw);
        return puiw;
    }
    
    /* Date : 05-11-2018
	* Description : if user is not authenticated then session will be loged out
	* Invoked From : doinit from toastNotification component
	*/
    @AuraEnabled
    public static boolean validateLogin() {
        
        List<User> userList = [SELECT Id, Is_User_Authenticated__c, contactId, contact.AccountId, 
                               contact.Account.Demo_User__c 
                               FROM User 
                               WHERE Id = :UserInfo.getUserId() AND Is_User_Authenticated__c = False AND ContactId != null
                               AND contact.AccountId != null AND contact.Account.Demo_User__c = False ];
        
        if (userList.isEmpty() == False) {
            
            return true;
        }
        return false;
    }
    
    /* Date : 03-11-2018
	* Description : Method to send the verification code to the email or mobile phone based on selected mode
	* Invoked From : LoginFlow2FAPage VF Page
	*/
    public void sendVerificationCodeToClient() {
        
        String selectedMode = ApexPages.currentPage().getParameters().get('selctedMode');
        
        if (String.isNotBlank(selectedMode) == TRUE) {
            
            this.exceptionText = '';
            this.enteredText = null;
            if(selectedMode == 'agentSentCodeVerification') {
                
                this.actionString = 'agentSentCodeVerification';
            } else {
                
                this.validationCode = Integer.valueOf(getRandomNumber(6));
                
                if(selectedMode == 'Email') {
                    
                    nu_dse__Program__c programInstance1 = this.programInstance;
                    
                    if(this.programInstance.Portfolio__c != null) {
                        
                        List<Portfolio__c> portfolioList = [SELECT Id, Name, Domain_URL__c, Dispay_Name__c, Address__c, 
                                                            City__c, State__c,  Zipcode__c, Support_Fax_Number__c, 
                                                            Support_Email__c, Support_Phone_Number__c, Website__c, 
                                                            OWD_Email_Name__c, Logo_Document_Name__c
                                                            FROM Portfolio__c WHERE Id = :this.programInstance.Portfolio__c
                                                           ];
                        
                        if(portfolioList.isEmpty() == FALSE) {
                            
                            Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                            emailInstance.setToAddresses(new String[]{this.userInstance.Email});
                            emailInstance.setBCCAddresses(new List<String>{'jtighe@stratfs.com','acarroll@stratfs.com'});
                            String subjectToSend = 'Your ' + portfolioList[0].Dispay_Name__c + ' Portal verification code.';
                            emailInstance.setSubject(subjectToSend);
                            
                            String htmlbody = 'Hello ' + UserInfo.getName() + ', <br />'
                                + '<br/>Your verification code is <span style="color:maroon">' 
                                + this.validationCode + '</span> <br /> <br />'
                                + SFSPortal_Utility.getEmailSignature(portfolioList[0]);
                            emailInstance.setHTMLBody(htmlbody); 
                            
                            /* Getting org wide email address based on the diplay name */
                            if(String.isNotBlank(portfolioList[0].OWD_Email_Name__c) == TRUE) {
                                
                                Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(portfolioList[0].OWD_Email_Name__c);
                                if(owdEmailId != null) {
                                    
                                    emailInstance.setOrgWideEmailAddressId(owdEmailId);
                                }
                            }
                            Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(
                                new Messaging.SingleEmailMessage[] { emailInstance });
                            List<EmailMessage> emailMessageList = [SELECT Id 
                                                                   FROM EmailMessage 
                                                                   WHERE subject LIKE :subjectToSend 
                                                                   ORDER BY CreatedDate DESC LIMIT 1];
                            if(mailResultList[0].isSuccess() == true && emailMessageList.isEmpty() == FALSE) {
                                
                                EmailMessage emailMessageToUpdate = new EmailMessage(Id = emailMessageList[0].Id, 
                                                                                     Related_Account__c = this.programInstance.nu_dse__Account__c, 
                                                                                     Decision_Source__c = 'Portal', Action_Performed__c = '2FA Email By Client'
                                                                                    );
                                update emailMessageToUpdate;
                            }
                            
                        } else {
                            
                            throw new CustomException('Required fields are not populated in program.' 
                                                      + 'Please contact system admin.');
                        }
                    } else {
                        
                        throw new CustomException('Required fields are not populated in program.' 
                                                  + 'Please contact system admin.');
                    }
                } else if(selectedMode == 'Mobile' || selectedMode == 'Phone Call') {
                    
                    this.identityVerificationInstance = new Portal_Identity_Service__c(User__c = UserInfo.getUserId(), 
                                                                                       Status__c = 'Initiated', 
                                                                                       RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification')
                                                                                      );
                    if(selectedMode == 'Mobile') {
                        
                        String textMessage = 'Hello, ' + this.validationCode + ' is your code to confirm your identity.';
                        nu_dse.TwilioMessage messageInstance = nu_dse.TwilioCommunications.sendSMS(
                            this.userInstance.MobilePhone, textMessage);
                        this.identityVerificationInstance.Description__c = textMessage + '<br /> <b> To Mobile: </b> ' 
                            + this.userInstance.MobilePhone;
                        this.identityVerificationInstance.Type__c = 'SMS';
                    } else if(selectedMode == 'Phone Call') {
                        
                        try {
                            
                            SFSPortal_PortalDetailsController.sendCallToClient(
                                this.userInstance.MobilePhone, this.validationCode);
                        } catch(Exception e) {
                            
                            this.exceptionText = e.getMessage();
                        }
                        String textMessage = 'Hello, ' + this.validationCode + ' is your code to confirm your identity.';
                        this.identityVerificationInstance.Description__c = textMessage + '<br /> <b> To Mobile: </b> ' 
                            + this.userInstance.MobilePhone;
                        this.identityVerificationInstance.Type__c = 'Phone Call';
                    }
                    /* Inserting identity verification record with mobile or email */
                    insert this.identityVerificationInstance;
                }
                this.sentTime = System.now();
                this.actionString = 'codeVerification';
            }
        }
    }
    
    /* Date : 27-02-2019
	* Description : Method to validate the verifaction code sent by agent and entered by user
	* Invoked From : LoginFlow2FAPage VF Page
	*/
    
    public PageReference validateAgentCode() {
        
        if(this.enteredText != null) {
            
            this.exceptionText = '';
            DateTime validateTime = System.now();
            
            List<Portal_Identity_Service__c>portalIdentityList = [ SELECT Id, New_Value__c, CreatedDate 
                                                                  FROM Portal_Identity_Service__c 
                                                                  WHERE User__c = :Userinfo.getUserId() 
                                                                  AND Is_Agent_Sent__c = TRUE 
                                                                  AND Status__c = 'Initiated' AND New_Value__c != null
                                                                  ORDER BY LastModifiedDate DESC LIMIT 1
                                                                 ];
            
            if(portalIdentityList.isEmpty() == FALSE) {
                
                Long minutes = (validateTime.getTime() - (portalIdentityList[0].CreatedDate).getTime())/ 60000 ;
                
                if (minutes >= 10) {
                    
                    this.exceptionText = 'Verification code is expired. Click Resend to send again.'; 
                } else {
                    
                    if(Integer.valueOf(portalIdentityList[0].New_Value__c) == Integer.valueOf(this.enteredText)) {
                        
                        String sourceIp = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
                        
                        Portal_Identity_Service__c identityService = new Portal_Identity_Service__c(
                            Id = portalIdentityList[0].Id,
                            Status__c = 'Verified'
                        );
                        update identityService;
                        
                        //* Updating login history record 
                        this.loginHistoryInstance.Status__c = 'Success';
                        update this.loginHistoryInstance;
                        
                        User userInstance = new User(Id = UserInfo.getUserId(), Is_User_Authenticated__c = TRUE);
                        update userInstance; 
                        system.debug('test--'+this.wrapperInstance);
                        PageReference pg = new PageReference(this.wrapperInstance.uiInstance.Portfolio__r.Domain_URL__c);
                        pg.setRedirect(true);
                        
                        return pg;
                    } else {
                        
                        this.exceptionText = 'Incorrect Code. Please Try Again.';
                    }
                } 
            } else {
                
                this.exceptionText = 'Please contact system admin.';
            }
        } else {
            
            this.exceptionText = 'Please provide verification code';
        }
        
        return null;
    }
    
    /* Date : 03-11-2018
	* Description : Method to validate the verifaction code entered and sent
	* Invoked From : LoginFlow2FAPage VF Page
	*/
    public PageReference validateCode() {
        
        if(this.enteredText != null) {
            
            this.exceptionText = '';
            DateTime validateTime = System.now();
            Long minutes = (validateTime.getTime() - (this.sentTime ).getTime())/ 60000 ;
            if (minutes >= 60) {
                
                this.exceptionText = 'Verification code is expired. Click Resend to send again.'; 
            } else {
                
                if (Integer.valueOf(this.validationCode) == Integer.valueOf(this.enteredText)) {
                    
                    String sourceIp = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
                    
                    /* Updating identity verification record with status verified for sms only*/
                    if(this.identityVerificationInstance != null && this.identityVerificationInstance.Id != null) {
                        
                        this.identityVerificationInstance.Status__c = 'Verified';
                        update this.identityVerificationInstance;
                    }
                    
                    /* Updating login history record */
                    this.loginHistoryInstance.Status__c = 'Success';
                    update this.loginHistoryInstance;
                    
                    User userInstance = new User(Id = UserInfo.getUserId(), Is_User_Authenticated__c = TRUE);
                    update userInstance; 
                    
                    if (String.isNotBlank(this.wrapperInstance.uiInstance.Portfolio__r.Domain_URL__c)) {
                        
                        PageReference pg = new PageReference(this.wrapperInstance.uiInstance.Portfolio__r.Domain_URL__c);
                        pg.setRedirect(true);
                        return pg;
                    } else if (String.isNotBlank(this.wrapperInstance.uiInstance.Mobile_Domain_URL__c)) {
                        
                        PageReference pg = new PageReference(this.wrapperInstance.uiInstance.Mobile_Domain_URL__c);
                        pg.setRedirect(true);
                        return pg;
                    }                   
                } else {
                    
                    this.exceptionText = 'Incorrect Code. Please Try Again.';
                }
            }
        } else {
            
            this.exceptionText = 'Please provide verification code';
        }
        
        return null;
    }
    
    public static String getRandomNumber(Integer length) {
        
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, length);
        system.debug('Random Number-' + randomNumber);
        return randomNumber;
    }
    
    /* Date : 03-11-2018
	* Description : Method to validate the verifaction code entered and sent
	* Invoked From : LoginFlow2FAPage VF Page
	*/
    public PageReference updateUserAndRedirect() {
        
        Boolean isTrustedIP = FALSE;
        
        String sourceIp = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        
        /* If login history not having any records, assigning isTrustedIp as FALSE
		* If login history having any records, if atleast one record source ip is matched with logged in user's 
		* source ip assining isTrusted as true or else by default it will be flase
		*/
        
        this.loginHistoryInstance = new Portal_Identity_Service__c();
        
        List<Portal_Identity_Service__c>loginHistoryList = [ SELECT Id, Status__c, Last_Login_Time__c 
                                                            FROM Portal_Identity_Service__c 
                                                            WHERE RecordTypeId = :
                                                            SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c',
                                                                                              'Login History') AND User__c = :UserInfo.getUserId() 
                                                            AND Ip_Address__c = :sourceIp
                                                           ];
        
        if(loginHistoryList.isEmpty() == FALSE) {
            
            for(Portal_Identity_Service__c loginInstance : loginHistoryList) {
                
                this.loginHistoryInstance = loginInstance.clone();
                this.loginHistoryInstance.Id = loginInstance.Id;
                this.loginHistoryInstance.Last_Login_Time__c = System.now();
                
                if(loginInstance.Last_Login_Time__c.date().daysbetween(System.today()) < 30 
                   && loginInstance.Status__c == 'Success') {
                       
                       isTrustedIp = TRUE;
                   } else {
                       
                       this.loginHistoryInstance.Status__c = 'Initiated';
                   } 
                
                break;
            }
            
        } else {
            /* If there were no records with user and ip address */
            this.loginHistoryInstance = new Portal_Identity_Service__c(
                Ip_Address__c = sourceIp, Last_Login_Time__c = System.now(), User__c = UserInfo.getUserId(), 
                Status__c = 'Initiated',
                RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Login History')
            );
        }
        
        if (isTrustedIP == FALSE &&  this.programInstance.nu_dse__Account__r.Demo_User__c != True) {
            
            User userInstance = new User(Id = UserInfo.getUserId(), Is_User_Authenticated__c = FALSE);
            update userInstance;   
            
            upsert this.loginHistoryInstance;
        } else {
            
            User userInstance = new User(Id = UserInfo.getUserId(), Is_User_Authenticated__c = TRUE);
            update userInstance;
            
            this.loginHistoryInstance.Status__c = 'Success';
            upsert this.loginHistoryInstance;
            
            if (String.isNotBlank(this.wrapperInstance.uiInstance.Portfolio__r.Domain_URL__c)) {
                
                PageReference urlRedirect = new Pagereference(this.wrapperInstance.uiInstance.Portfolio__r.Domain_URL__c);
                urlRedirect.setRedirect(true);
                return urlRedirect;
            } else if (String.isNotBlank(this.wrapperInstance.uiInstance.Mobile_Domain_URL__c)){
                
                PageReference urlRedirect = new Pagereference(this.wrapperInstance.uiInstance.Mobile_Domain_URL__c);
                urlRedirect.setRedirect(true);
                return urlRedirect;
            }
        }
        return null;
    }
    
    /* 
	*  Date : 05-10-2018
	*  Description : Method to get the portal status, background and font color based on the logged in user from 
		Dashboard_Metrics__c object
	*  Invoked From : dashboardMetrics lightning component
	*/
    @AuraEnabled
    public static DashboardMetricsWrapperClass getDashboardMetrcis() {
        
        DashboardMetricsWrapperClass dashboardWrapperInstance = new DashboardMetricsWrapperClass();
        dashboardWrapperInstance.customPermission = FeatureManagement.checkPermission('Debt_Overview'); 
        
        if (dashboardWrapperInstance.customPermission) {
            
            try {
                
                Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                
                if(accountIdMap != null && accountIdMap.isEmpty() == False) {
                    
                    if (accountIdMap.ContainsKey('primaryAccountId') == True 
                        && accountIdMap.get('primaryAccountId') != null) {
                            
                            Id accountId = accountIdMap.get('primaryAccountId');
                            
                            if (accountId != null) {
                                
                                Id dashboardRecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Dashboard');
                                Map<String, Portal_Settings__c> portalSettingMap = new Map<String, Portal_Settings__c>();
                                
                                List<nu_dse__Program__c> programList = [SELECT Id, Name,nu_dse__Account__c, 
                                                                        nu_dse__Program_Status__c, 
                                                                        nu_dse__Total_Debt_Included__c, 
                                                                        Portfolio__c,Enrollment_Date__c ,
                                                                        nu_dse__Total_Debt__c
                                                                        FROM nu_dse__Program__c 
                                                                        WHERE nu_dse__Account__c = :accountId];
                                if(programList.isEmpty() == FALSE) {
                                    
                                    dashboardWrapperInstance.adhocPaymentObj.setMinAndMaxDate = new Map<String, Date> {
                                        'MinDate' => system.today().toStartofWeek().daysBetween(system.today()) == 5 ? 
                                            system.today().AddDays(5) : 
                                        system.today().toStartofWeek().daysBetween(system.today()) == 6 ? 
                                            system.today().AddDays(4) : system.today().AddDays(3) , 
                                                'MaxDate' => system.today().AddDays(60)
                                                };
                                                    
                                                    dashboardWrapperInstance.adhocPaymentObj.editPaymentFieldsList.add(
                                                        new SFSPortal_TradelineListController.FieldSetMemberWrapper(true,'date',
                                                                                                                    'Date','Ad_Hoc_Date__c',''));
                                    
                                    for (Schema.FieldSetMember fieldMember : 
                                         Schema.SObjectType.nu_dse__Group_Task__c.fieldSets.Adhoc_Payment_Fields.getFields()) {
                                             
                                             if (fieldMember.getFieldPath() != 'Ad_Hoc_Date__c') {
                                                 
                                                 dashboardWrapperInstance.adhocPaymentObj.editPaymentFieldsList.add(
                                                     new SFSPortal_TradelineListController.FieldSetMemberWrapper(
                                                         fieldMember.getRequired() || fieldMember.getDbRequired(),
                                                         String.valueOf(fieldMember.getType()).toLowercase(),
                                                         fieldMember.getLabel(), fieldMember.getFieldPath(),''));
                                             }
                                         }
                                    
                                    for (Schema.FieldSetMember fieldMember : 
                                         Schema.SObjectType.nu_dse__Group_Task__c.fieldSets.New_Bank_Account_Request.getFields()) {
                                             
                                             if (fieldMember.getFieldPath() != 'SFSPortal_Account_Number__c' 
                                                 && fieldMember.getFieldPath() != 'SFSPortal_Re_Enter_Account_Number__c'
                                                 && fieldMember.getFieldPath() != 'SFSPortal_Routing_Number__c' 
                                                 && fieldMember.getFieldPath() != 'SFSPortal_Bank_Name__c') {
                                                     
                                                     dashboardWrapperInstance.adhocPaymentObj.editBankInfoFieldsList.add( 
                                                         new SFSPortal_TradelineListController.FieldSetMemberWrapper(
                                                             fieldMember.getRequired() || fieldMember.getDbRequired(),
                                                             String.valueOf(fieldMember.getType()).toLowercase(),
                                                             fieldMember.getLabel(),fieldMember.getFieldPath(), ''));
                                                 }
                                         }
                                    
                                    Integer totalCreditors = 0;
                                    Integer enrolledCreditors = 0;
                                    Integer resolvedCreditors = 0;
                                    Decimal totalDebt = 0;
                                    Decimal totalResolvedDebt = 0;
                                    Decimal enrolledDebt = 0;
                                    for(nu_dse__TradeLine__c tradeLineObj : [SELECT Id, nu_dse__Original_Debt__c, 
                                                                             nu_dse__Include_In_The_Program__c, 
                                                                             SFS_Current_Stage__c,
                                                                             nu_dse__Current_Balance__c, 
                                                                             Current_Stage_Portal__c, 
                                                                             SFS_Current_Balance__c
                                                                             FROM nu_dse__TradeLine__c
                                                                             WHERE nu_dse__Program__c =: programList[0].Id]) {
                                                                                 
                                                                                 if (tradeLineObj.Current_Stage_Portal__c != 'Removed from Program' 
                                                                                     && tradeLineObj.Current_Stage_Portal__c != 'Pending Enrollment') {
                                                                                         
                                                                                         enrolledCreditors++;
                                                                                         enrolledDebt += tradeLineObj.nu_dse__Original_Debt__c != null 
                                                                                             ? tradeLineObj.nu_dse__Original_Debt__c : 0;
                                                                                         
                                                                                         if (tradeLineObj.SFS_Current_Stage__c == 'Pre-Settlement') {
                                                                                             
                                                                                             totalDebt += tradeLineObj.nu_dse__Original_Debt__c != null 
                                                                                                 ? tradeLineObj.nu_dse__Original_Debt__c : 0;
                                                                                             
                                                                                         } else if (tradeLineObj.SFS_Current_Stage__c == 'Offer Pending Approval' 
                                                                                                    || tradeLineObj.SFS_Current_Stage__c == 'Offer Under Review'
                                                                                                    || tradeLineObj.Current_Stage_Portal__c == 'Payment Plan Active' 
                                                                                                    || tradeLineObj.Current_Stage_Portal__c == 'Debt Settled'
                                                                                                    || tradeLineObj.Current_Stage_Portal__c == 'Payment Plan Suspended') {
                                                                                                        
                                                                                                        totalDebt += tradeLineObj.SFS_Current_Balance__c != null 
                                                                                                            ? tradeLineObj.SFS_Current_Balance__c : 0;
                                                                                                    } else if (tradeLineObj.SFS_Current_Stage__c == 'Removed from Program' 
                                                                                                               || tradeLineObj.SFS_Current_Stage__c == 'Pending Enrollment') {
                                                                                                                   
                                                                                                                   totalDebt += 0;
                                                                                                               }
                                                                                     }
                                                                                 if (tradeLineObj.Current_Stage_Portal__c == 'Debt Settled') {
                                                                                     
                                                                                     totalResolvedDebt += tradeLineObj.SFS_Current_Balance__c != null 
                                                                                         ? tradeLineObj.SFS_Current_Balance__c : 0;
                                                                                     
                                                                                     resolvedCreditors++;
                                                                                 }                                                                                 
                                                                             }
                                    
                                    dashboardWrapperInstance.accountOverviewWrapper.programStartDate = 
                                        programList[0].Enrollment_Date__c;
                                    dashboardWrapperInstance.accountOverviewWrapper.adjustedDebt = totalDebt;
                                    dashboardWrapperInstance.accountOverviewWrapper.enrolledDebt = enrolledDebt;
                                    dashboardWrapperInstance.accountOverviewWrapper.resolvedDebt = totalResolvedDebt;
                                    dashboardWrapperInstance.accountOverviewWrapper.enrolledCreditors = enrolledCreditors;
                                    dashboardWrapperInstance.accountOverviewWrapper.resolvedCreditors = resolvedCreditors;
                                    
                                    for (Portal_Settings__c portalSetting : [SELECT Type__c, Background_Color__c, 
                                                                             Text_Color__c, Is_Active__c 
                                                                             FROM Portal_Settings__c
                                                                             WHERE Portfolio__c != null 
                                                                             AND Is_Active__c = true 
                                                                             AND recordTypeId =: dashboardRecordTypeId 
                                                                             AND Portfolio__c  =:programList[0].Portfolio__c 
                                                                             AND Type__c != null
                                                                             ORDER BY LastModifiedDate ]) {
                                                                                 
                                                                                 if (portalSettingMap.ContainsKey(portalSetting.Type__c) == False) {
                                                                                     
                                                                                     portalSettingMap.put(portalSetting.Type__c, portalSetting);
                                                                                 }
                                                                             }
                                    
                                    List<nu_dse__Payment__c> paymentList = [SELECT Id, nu_dse__Schedule_Date__c, 
                                                                            nu_dse__Total_Amount__c
                                                                            FROM nu_dse__Payment__c
                                                                            WHERE nu_dse__Program__c = :programList[0].Id 
                                                                            AND RecordType.DeveloperName = 'Draft'
                                                                            AND nu_dse__Transaction_Status__c IN ('In Progress', 
                                                                                                                  'Pending', 'Scheduled')
                                                                            AND nu_dse__Schedule_Date__c >= TODAY
                                                                            ORDER BY nu_dse__Schedule_Date__c 
                                                                            LIMIT 1];
                                    
                                    String nextScheduleDate, nextPaymentAmount;
                                    if (paymentList.isEmpty() == FALSE) {
                                        
                                        nextScheduleDate = paymentList[0].nu_dse__Schedule_Date__c != null 
                                            ? String.valueOf(paymentList[0].nu_dse__Schedule_Date__c) : '';
                                        nextPaymentAmount = paymentList[0].nu_dse__Total_Amount__c != null 
                                            ? String.valueOf(paymentList[0].nu_dse__Total_Amount__c) : '0.00';
                                    }
                                    // Next Draft Amount
                                    dashboardWrapperInstance.dashBoardMetricsList.add( 
                                        new DashboardMetrics(portalSettingMap.containsKey('Next Draft Amount') 
                                                             && portalSettingMap.get('Next Draft Amount').Background_Color__c != null ? 
                                                             portalSettingMap.get('Next Draft Amount').Background_Color__c : 
                                                             '#b36315', 'utility:info', 'Next Draft Amount',
                                                             portalSettingMap.containsKey('Next Draft Amount') 
                                                             && portalSettingMap.get('Next Draft Amount').Text_Color__c != null ? 
                                                             portalSettingMap.get('Next Draft Amount').Text_Color__c : 'white', 
                                                             nextPaymentAmount)
                                    );
                                    
                                    // Next Draft Date
                                    dashboardWrapperInstance.dashBoardMetricsList.add( 
                                        new DashboardMetrics(portalSettingMap.containsKey('Next Draft Date') 
                                                             && portalSettingMap.get('Next Draft Date').Background_Color__c != null 
                                                             ? portalSettingMap.get('Next Draft Date').Background_Color__c 
                                                             : '#598417','utility:monthlyview', 'Next Draft Date', 
                                                             portalSettingMap.containsKey('Next Draft Date') 
                                                             && portalSettingMap.get('Next Draft Date').Text_Color__c != null ? 
                                                             portalSettingMap.get('Next Draft Date').Text_Color__c : 'white', 
                                                             nextScheduleDate)
                                    );
                                }
                            }
                        }
                    dashboardWrapperInstance.userName = userinfo.getName();
                }
                return dashboardWrapperInstance; 
            } catch(Exception e) {
                
                throw new AuraHandledException(e.getMessage());
            }
        } else { 
            
            return null;
        }
    }
    
    /* Date : 12-10-2018
	* Description : Method to get the all css required fields from the Portal_Settings__c object based on the domain url
	* Invoked From : dashboardMetrics lightning component 
	*/
    @AuraEnabled
    public static CustomUIWrapper getCustomPortalUIValues(String domainURL, String portfolioName) {
        
        system.debug('domainURL--->'+domainURL);
        CustomUIWrapper wrapperInstance = new CustomUIWrapper();
        Organization companyInfo = SFSPortal_Utility.getOrgInfo();
        String programId;
        Id portfolioId;
        
        try {
            
            wrapperInstance.isEnabledChat = FeatureManagement.checkPermission('Chat');
            wrapperInstance.isAddNewDebt =  FeatureManagement.checkPermission('Add_New_Debt');
            wrapperInstance.isDocuments = FeatureManagement.checkPermission('Documents');
            wrapperInstance.isFAQ =  FeatureManagement.checkPermission('FAQ');
            wrapperInstance.isMyProfile = FeatureManagement.checkPermission('My_Profile');
            wrapperInstance.isContactUs =  FeatureManagement.checkPermission('Contact_Us');
            wrapperInstance.isReferAFriend =  FeatureManagement.checkPermission('Refer_a_Friend');
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            
            if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
                
                if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                    
                    Id accountId = accountIdMap.get('primaryAccountId');
                    
                    if (accountId != null) {
                        
                        List<nu_dse__Program__c> programList = [SELECT Id, Name, nu_dse__Account__c, 
                                                                nu_dse__Account__r.FirstName, 
                                                                nu_dse__Account__r.LastName, Portfolio__c, 
                                                                nu_dse__Program_Status__c, 
                                                                Portfolio__r.Name, Portfolio__r.Logo_Name__c,Portfolio__r.Logo_Name_Small__c 
                                                                FROM nu_dse__Program__c 
                                                                WHERE nu_dse__Account__c =: accountId 
                                                                AND Portfolio__c != null]; 
                        
                        // wrapperInstance.HeaderLogoURL = programList[0].Portfolio__r.Logo_Name__c;
                        
                        if (programList != null && programList.isEmpty() == False) {
                        
                        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                             FROM StaticResource 
                                                             WHERE Name = :programList[0].Portfolio__r.Logo_Name_Small__c LIMIT 1];
                        
                        if(resourceList.isEmpty() == FALSE) {
                                                         
                                wrapperInstance.HeaderSmallLogoURL = '/resource/' 
                                    + resourceList[0].SystemModStamp.getTime() + '/' 
                                    + resourceList[0].Name; 
                            }
                        }
 
                         if (programList != null && programList.isEmpty() == False) {
                        
                        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                             FROM StaticResource 
                                                             WHERE Name = :programList[0].Portfolio__r.Logo_Name__c LIMIT 1];
                        
                        if(resourceList.isEmpty() == FALSE) {
                                                         
                                wrapperInstance.HeaderLogoURL = '/resource/' 
                                    + resourceList[0].SystemModStamp.getTime() + '/' 
                                    + resourceList[0].Name; 
                            }
                        }
                        if (programList != null && programList.isEmpty() == False) {
                            
                            String query = 'SELECT Id, NSF_payment_18_Digit__c FROM Task WHERE Clients_task__c = true AND' 
                                + ' WhatId = \''+ programList[0].Id +'\' AND Status = \''+'Not Started'+'\''
                                + ' AND Call_Type__c = \''+'NSF'+'\' ORDER BY  LastModifiedDate DESC LIMIT 1';
                            
                            
                            if (programList[0].nu_dse__Program_Status__c == 'UnResponsive NSF') {
                                
                                wrapperInstance.isInCriticalStage = true;
                                List<Task> nsfTaskList = Database.query(query);
                                if (nsfTaskList.isEmpty() == False) {
                                    
                                    wrapperInstance.taskList = nsfTaskList;
                                }
                            }
                            portfolioId = programList[0].Portfolio__c;
                            
                            programId=programList[0].Name;
                        }
                    }
                }
            }
            
            if (portfolioId != null || String.isNotBlank(domainURL) == TRUE) {
                
                Boolean isMobileApp = False;
                
                system.debug('isMobileApp --->'+isMobileApp );
                String query = 'SELECT Action_Button_Color__c, Logo_Name__c,Logo_Name_small__c, Portfolio__c, '
                    + 'Portfolio__r.Domain_URL__c, Portfolio__r.Support_Email__c, '
                    + 'Type__c, Value__c, Landing_Background_Image__c, Menu_Background_Image__c, '
                    + 'Portfolio__r.Name, Menu_Background_Color__c, ' 
                    + 'Landing_Background_Color__c, Portfolio__r.Support_Phone_Number__c, '
                    + 'Footer_Background_Color__c, Footer_Text_Color__c, '
                    + 'Portfolio__r.ReferralBaseURL__c, Portfolio__r.ReferralProgramidentifier__c, '
                    + 'Mobile_Domain_URL__c FROM Portal_Settings__c WHERE Is_Active__c = TRUE';
                
                Id mobileAppInfoId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Mobile Domain Info');
                query += ' AND ((recordTypeId =: mobileAppInfoId ';
                
                if (String.isNotBlank(portfolioId)) {
                    
                    query += ' AND Mobile_Domain_URL__c =: domainURL) '; 
                    //' AND Portfolio_Group__c includes ( \''+portfolioName+'\') AND Mobile_Domain_URL__c =: domainURL)';
                } else  {
                    
                    /* Checking sandbox or production and invoking portfolio querying logic based on param */
                    if(companyInfo.IsSandbox == TRUE && String.isNotBlank(portfolioName) ) {
                        
                        query += ' AND Mobile_App_Name__c = :portfolioName AND Mobile_Domain_URL__c =: domainURL) ';
                    } else {
                        
                        query += ' AND Mobile_Domain_URL__c = :domainURL) ';
                    }
                }
                
                Id uiEnhancementId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'UI Enhancements');       
                query += '  OR (Portfolio__c != null AND recordTypeId =: uiEnhancementId';
                
                if (String.isNotBlank(portfolioId)) {
                    
                    query += ' AND Portfolio__c =: portfolioId)';
                } else {
                    
                    /* Checking sandbox or production and invoking portfolio querying logic based on param */
                    if(companyInfo.IsSandbox == TRUE) {
                        
                        query += ' AND Portfolio__r.Name =: portfolioName) ';
                    } else {
                        
                        query += ' AND Portfolio__r.Domain_URL__c =: domainURL)';
                    }
                }
                system.debug('query--->'+query);
                
                List<Portal_Settings__c>portalUIList = Database.query(query +') ORDER BY Lastmodifieddate DESC LIMIT 1');
                
                system.debug('portalUIList--->'+portalUIList);
                
                if (portalUIList.isEmpty() == FALSE) {
                    
                    wrapperInstance.uiInstance = portalUIList[0];
                    wrapperInstance.isNotMobileDomain = portalUIList[0].Mobile_Domain_URL__c == null ? true : false;
                    wrapperInstance.isMobileDomain = portalUIList[0].Mobile_Domain_URL__c != null ? true : false;
                   // String customDomainURL1 = (wrapperInstance.uiInstance != null) ? portalUIList[0].Mobile_Domain_URL__c 
                     //   : portalUIList[0].Portfolio__r.Domain_URL__c;
                    String customDomainURL = wrapperInstance.isMobileDomain ? portalUIList[0].Mobile_Domain_URL__c 
                        : portalUIList[0].Portfolio__r.Domain_URL__c;
                    
                    if(portalUIList[0].Logo_Name__c != null) {
                        
                        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                             FROM StaticResource 
                                                             WHERE Name = :portalUIList[0].Logo_Name__c LIMIT 1];
                        
                        if(resourceList.isEmpty() == FALSE) {
                            
                            wrapperInstance.companyLogoURL = customDomainURL + '/resource/' 
                                + resourceList[0].SystemModStamp.getTime() 
                                + '/' + resourceList[0].Name; 
                        }
                    } 
                    if(portalUIList[0].Logo_Name_small__c != null) {
                        
                        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                             FROM StaticResource 
                                                             WHERE Name = :portalUIList[0].Logo_Name_small__c LIMIT 1];
                        
                        if(resourceList.isEmpty() == FALSE) {
                            
                            wrapperInstance.companyLogoSmallURL = customDomainURL + '/resource/' 
                                + resourceList[0].SystemModStamp.getTime() + '/' 
                                + resourceList[0].Name; 
                        }
                    }
                    
                    if(!portalUIList.isEmpty()) {
                        
                        String baseURL = portalUIList[0].Portfolio__r.ReferralBaseURL__c;
                        String programidentifier = portalUIList[0].Portfolio__r.ReferralProgramidentifier__c;
                        String userFirstName = UserInfo.getFirstName();
                        String userLastName = UserInfo.getLastName();
                        String userEmail = UserInfo.getUserEmail();
                        //String programID = programList[0].Name;
                        if(!String.isBlank(baseURL)){
                            String finalReferralURL = baseURL + '?programidentifier=' + programidentifier 
                                + '&firstname=' + userFirstName + '&lastname=' + userLastName 
                                + '&email=' + userEmail + '&externalidentifier=' + programID
                                + '&utm_source=Portal';
                            wrapperInstance.referralUrl = finalReferralURL;
                        }
                    }
                    if(portalUIList[0].Type__c == 'Background Image' && portalUIList[0].Value__c != null) {
                        
                        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp 
                                                            FROM StaticResource 
                                                            WHERE Name = :portalUIList[0].Value__c 
                                                            LIMIT 1];
                        
                        if(resourceList.isEmpty() == FALSE) {
                            
                            wrapperInstance.backgroundImageURL = customDomainURL + '/resource/' 
                                + resourceList[0].SystemModStamp.getTime() + '/' 
                                + resourceList[0].Name; 
                        }
                    }
                    
                    if(String.isBlank(portalUIList[0].Landing_Background_Color__c) == TRUE 
                       && portalUIList[0].Landing_Background_Image__c != null) {
                           
                           List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp 
                                                               FROM StaticResource 
                                                               WHERE Name = :portalUIList[0].Landing_Background_Image__c 
                                                               LIMIT 1];
                           
                           if(resourceList.isEmpty() == FALSE) {
                               
                               wrapperInstance.headerbackgroundImage = customDomainURL + '/resource/' 
                                   + resourceList[0].SystemModStamp.getTime() + '/' 
                                   + resourceList[0].Name; 
                           }
                       }
                    
                    if(String.isBlank(portalUIList[0].Menu_Background_Color__c) == TRUE 
                       && portalUIList[0].Menu_Background_Image__c != null) {
                           
                           List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp 
                                                               FROM StaticResource 
                                                               WHERE Name = :portalUIList[0].Menu_Background_Image__c 
                                                               LIMIT 1];
                           

                           if(resourceList.isEmpty() == FALSE) {
                               
                               wrapperInstance.menuBackgroundImage = customDomainURL + '/resource/' 
                                   + resourceList[0].SystemModStamp.getTime() + '/' 
                                   + resourceList[0].Name; 
                           }
                       }
                    
                    List<User> userList = [SELECT Id, Name, LastName, FirstName, Display_Chat__c 
                                           FROM User 
                                           WHERE Id = :UserInfo.getUserId()];
                    
                    if(userList.isEmpty() == FALSE) {
                        
                        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                             FROM StaticResource 
                                                             WHERE Name = 'SFSPortal_ProfileIcon' LIMIT 1];
                        
                        
                        if(resourceList.isEmpty() == FALSE) {
                            
                            wrapperInstance.profileIconURL = customDomainURL + '/resource/' 
                                + resourceList[0].SystemModStamp.getTime() + '/' 
                                + resourceList[0].Name; 
                        }
                        
                        List<StaticResource> resourceListShow = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                                 FROM StaticResource 
                                                                 WHERE Name = 'SFSPortal_Profile_White_Icon' 
                                                                 LIMIT 1];
                        
                        if(resourceListShow.isEmpty() == FALSE){
                            
                            wrapperInstance.profileIconURL_Show = customDomainURL + '/resource/' 
                                + resourceListShow[0].SystemModStamp.getTime() + '/' 
                                + resourceListShow[0].Name; 
                        }
                        
                        List<StaticResource> iconResourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                                                 FROM StaticResource WHERE 
                                                                 Name = 'SFSPortal_ChatIcon' 
                                                                 LIMIT 1];
                       
                        if(iconResourceList.isEmpty() == FALSE){
                            
                            wrapperInstance.chatIconURL = customDomainURL + '/resource/' 
                                + resourceList[0].SystemModStamp.getTime() + '/' 
                                + iconResourceList[0].Name; 
                        }
                        wrapperInstance.userInstance = userList[0];                      
                        wrapperInstance.isDisplayChatEnabled = userList[0].Display_Chat__c;
                    }
                } 
            }
        } catch(Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        }
        wrapperInstance.currentUserType = UserInfo.getUserType();
        wrapperInstance.isSandbox = companyInfo.isSandbox;
        return wrapperInstance;
    }
    
    /* Date : 29-10-2018
	* Description : Method to get the count of pending tasks and pending approvals
	* Invoked From : notificationHomePage lightning component 
	*/
    @AuraEnabled
    public static NotifcationHomePageWrapper getDefaultCountValues() {
        
        NotifcationHomePageWrapper wrapper = new NotifcationHomePageWrapper();
        Id accountId;
        Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
        
        if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
            
            if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                
                accountId = accountIdMap.get('primaryAccountId');
                
                if (accountId != null) {
                    
                    List<nu_dse__Program__c> programList = [SELECT Id FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__c =: accountId ]; 
                    
                    if (programList != null && programList.isEmpty() == False) {
                        
                        Date today = system.today();
                        DateTime fromDate = DateTime.newInstance(today.AddDays(-120).year(), 
                                                                 today.AddDays(-120).month(), today.AddDays(-120).day(), 0, 0, 0);
                        DateTime toDate = DateTime.newInstance(today.year(), 
                                                               today.month(), today.day(), 23, 59, 59);
                        wrapper.pendingTasksCount = [SELECT Count() FROM Task 
                                                     WHERE Clients_task__c = true AND createdDate >=:fromDate 
                                                     AND createdDate <= :toDate AND WhatId =: programList[0].Id];
                        
                        wrapper.pendingApprovalsCount = [SELECT Count() FROM nu_dse__Offer__c 
                                                         WHERE nu_dse__Program__c = :programList[0].Id 
                                                         AND nu_dse__Status__c = 'Pending Client Approval'];
                    }
                }
            }
        }
        return wrapper;
    }
    
    /* Date : 08-11-2018
	* Description : Method to get the value for footer
	* Invoked From : doInit from portalFooter lightning component 
	*/
    @AuraEnabled
    public static footerWrapper getFooterValue(String domainURL, String portfolioName) {
        
        footerWrapper footerWrapperInstance = new footerWrapper();
        
        Organization companyInfo = SFSPortal_Utility.getOrgInfo();
        
        try {
            
            if(String.isNotBlank(domainURL) == TRUE) {
                
                Id uiEnhancementId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'UI Enhancements');
                Id latestNewsId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Latest News');
                Id footerRecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Footer Links');
                Id portfolioId;
                String programId;
                
                footerWrapperInstance.currentUserType = UserInfo.getUserType();
                
                String filterCondition = '';
                
                if(footerWrapperInstance.currentUserType == 'Guest') {
                    
                    if(companyInfo.IsSandbox == TRUE) {
                        
                        filterCondition += ' AND Portfolio__r.Name =:portfolioName';
                    } else {
                        
                        filterCondition += ' AND Portfolio__r.Domain_URL__c =:domainURL ';
                    }
                    
                } else {
                    
                    Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                    
                    if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
                        
                        if (accountIdMap.ContainsKey('primaryAccountId') == True 
                            && accountIdMap.get('primaryAccountId') != null) {
                                
                                Id accountId = accountIdMap.get('primaryAccountId');
                                
                                if (accountId != null) {
                                    
                                    List<nu_dse__Program__c> programList = [SELECT Id,Name, Portfolio__c 
                                                                            FROM nu_dse__Program__c 
                                                                            WHERE nu_dse__Account__c =: accountId 
                                                                            AND Portfolio__c != null]; 
                                    
                                    if (programList != null && programList.isEmpty() == False) {
                                        
                                        portfolioId = programList[0].Portfolio__c;
                                        programId= programList[0].Name;
                                    }
                                }
                            }
                    }
                    
                    filterCondition += ' AND Portfolio__c =  :portfolioId';
                }
                
                footerWrapperInstance.footerLinkList = Database.query(
                    'SELECT Article_Label__c, Article_URL__c, Is_Active__c FROM Portal_Settings__c '
                    + ' WHERE Is_Active__c = true AND recordTypeId =: footerRecordTypeId '
                    + filterCondition
                    + ' ORDER BY LastModifiedDate DESC '
                );
                
                List<Portal_Settings__c> portalUIList = Database.query(
                    'SELECT Action_Button_Color__c, Logo_Name__c, Portfolio__c, Type__c, Value__c,' 
                    + 'Portfolio__r.Support_Email__c, '
                    + 'Portfolio__r.Name, Portfolio__r.About_Us__c, Portfolio__r.Blog__c,'
                    + 'Portfolio__r.Debt_Relief_Options__c, '
                    + 'Portfolio__r.FAQ__c, Portfolio__r.Footer_Contact_Content__c, Portfolio__r.Footer_Name__c, '
                    + 'Portfolio__r.Footer_Portfolio_Content__c, Portfolio__r.Press__c, Portfolio__r.Submit_Feedback__c, '
                    + 'Portfolio__r.Support_Fax_Number__c, Portfolio__r.Support_Phone_Number__c, '
                    + 'Portfolio__r.Terms_of_Use__c, Portfolio__r.Contact_Us__c, '
                    + 'Portfolio__r.Privacy_Policy__c, Portfolio__r.Business_Hours__c, Portfolio__r.Domain_URL__c, '
                    + 'Portfolio__r.Address__c, Portfolio__r.City__c, '
                    + 'Portfolio__r.State__c, Portfolio__r.Zipcode__c, Footer_Background_Color__c, Footer_Text_Color__c, '
                    + 'Portfolio__r.Facebook_URL__c, Portfolio__r.Linkedin_URL__c,Portfolio__r.ReferralBaseURL__c,'
                    + 'Portfolio__r.ReferralProgramidentifier__c '
                    + 'FROM Portal_Settings__c '
                    + 'WHERE recordTypeId =: uiEnhancementId AND Portfolio__c != null AND Is_Active__c = TRUE '
                    + filterCondition
                    + ' ORDER BY LastModifiedDate DESC' 
                );
                
                if(portalUIList.isEmpty() == FALSE) {
                    
                    String baseURL = portalUIList[0].Portfolio__r.ReferralBaseURL__c;
                    String programidentifier = portalUIList[0].Portfolio__r.ReferralProgramidentifier__c;
                    String userFirstName = UserInfo.getFirstName();
                    String userLastName = UserInfo.getLastName();
                    String userEmail = UserInfo.getUserEmail();
                    
                    if(!String.isBlank(baseURL)){
                        String finalReferralURL = baseURL + '?programidentifier=' + programidentifier 
                            + '&firstname=' + userFirstName + '&lastname=' + userLastName 
                            + '&email=' + userEmail + '&externalidentifier=' + programID
                            + '&utm_source=Portal';
                        footerWrapperInstance.referralUrl = finalReferralURL;
                    }
                    
                    footerWrapperInstance.portfolioInstance = portalUIList[0];
                    
                    if(portalUIList[0].Logo_Name__c != null) {
                        
                        List<StaticResource> resourceList = [ SELECT Name, NamespacePrefix, SystemModStamp 
                                                             FROM StaticResource 
                                                             WHERE Name = :portalUIList[0].Logo_Name__c LIMIT 1];
                        
                        if(resourceList.isEmpty() == FALSE){
                            
                            footerWrapperInstance.companyLogoURL =  portalUIList[0].Portfolio__r.Domain_URL__c + '/resource/' 
                                + resourceList[0].SystemModStamp.getTime() + '/' 
                                + resourceList[0].Name; 
                        }
                    }
                }
            }
        } catch(Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        }  
        return footerWrapperInstance;
    }
    
    /* Date : 21-11-2018
	* Description : Method to get the Question and Answer
	* Invoked From : doInit from frequentlyAskedQuestion lightning component 
	*/
    @AuraEnabled
    public static List<Portal_Settings__c> getAllFrequentQuestions() {
        
        Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
        
        if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
            
            if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                
                Id accountId = accountIdMap.get('primaryAccountId');
                
                if (accountId != null) {
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c,nu_dse__Account__c 
                                                            FROM nu_dse__Program__c WHERE nu_dse__Account__c =: accountId ]; 
                    
                    if (programList != null && programList.isEmpty() == False) {
                        
                        Id faqRecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Frequently Asked Question');       
                        
                        if (faqRecordTypeId != null) {
                            
                            return [SELECT Question__c, Answer__c FROM Portal_Settings__c 
                                    WHERE recordTypeId =: faqRecordTypeId AND Is_Active__c = TRUE 
                                    AND Portfolio__c =: programList[0].Portfolio__c]; 
                        }    
                    }
                }
            }
        }               
        return null;
    }  
    
    public class NotifcationHomePageWrapper {
        
        @AuraEnabled
        public Integer pendingTasksCount = 0;
        
        @AuraEnabled
        public Integer pendingApprovalsCount = 0;
    }
    
    public class footerWrapper {
        
        @AuraEnabled
        public Portal_Settings__c portfolioInstance;
        
        @AuraEnabled
        public List<Portal_Settings__c> latestNewsPortalSettingsList = new List<Portal_Settings__c>();
        
        @AuraEnabled
        public String companyLogoURL;
        
        @AuraEnabled
        public String currentUserType;
        
        @AuraEnabled
        public List<Portal_Settings__c> footerLinkList = new List<Portal_Settings__c>();
        
        @AuraEnabled
        public String ReferralUrl;
    }
    
    public class CustomUIWrapper {
        
        @AuraEnabled
        public Boolean IsDesktop; 
        
        @AuraEnabled
        public Portal_Settings__c uiInstance = new Portal_Settings__c();
        
        @AuraEnabled
        public String companyLogoURL;
        
        @AuraEnabled
        public String HeaderLogoURL;
        
        @AuraEnabled
        public String HeaderSmallLogoURL;
        
        @AuraEnabled
        public String companyLogoSmallURL;
        
        @AuraEnabled
        public String backgroundImageURL;
        
        @AuraEnabled
        public String profileIconURL;
        
        @AuraEnabled
        public String profileIconURL_Show;
        
        @AuraEnabled
        public String chatIconURL;
        
        @AuraEnabled
        public User userInstance = new User();
        
        @AuraEnabled
        public String headerbackgroundImage;
        
        @AuraEnabled
        public String menuBackgroundImage;
        
        @AuraEnabled
        public String currentUserType;
        
        @AuraEnabled
        public Boolean isInCriticalStage = false;
        
        @AuraEnabled
        public List<Task> taskList = new List<Task>();
        
        @AuraEnabled
        public Boolean isDisplayChatEnabled = FALSE;
        
        @AuraEnabled
        public Boolean isMobileDomain = FALSE;
        
        @AuraEnabled
        public Boolean isNotMobileDomain = FALSE;
        
        @AuraEnabled
        public Boolean isSandbox = FALSE;
        
        @AuraEnabled
        public Boolean isEnabledChat = FALSE;
        
        @AuraEnabled
        public Boolean isAddNewDebt = FALSE;
        
        @AuraEnabled
        public Boolean isDocuments = FALSE;
        
        @AuraEnabled
        public Boolean isContactUs = FALSE;
        
        @AuraEnabled
        public Boolean isFAQ = FALSE;
        
        @AuraEnabled
        public Boolean isMyProfile = FALSE;
        
        @AuraEnabled
        public Boolean isReferAFriend = FALSE;
        
        @AuraEnabled
        public String ReferralUrl;
    }
    
    public class  enableCustomPermission {
        
        @AuraEnabled
        public Boolean isInCriticalStage = false;
        
        @AuraEnabled
        public Boolean isDisplayChatEnabled = FALSE;
        
        @AuraEnabled
        public Boolean isMobileDomain = FALSE;
        
        @AuraEnabled
        public Boolean isNotMobileDomain = FALSE;
        
        @AuraEnabled
        public Boolean isSandbox = FALSE;
        
        @AuraEnabled
        public Boolean isEnabledChat = FALSE;
        
        @AuraEnabled
        public Boolean isAddNewDebt = FALSE;
        
        @AuraEnabled
        public Boolean isDocuments = FALSE;
        
        @AuraEnabled
        public Boolean isContactUs = FALSE;
        
        @AuraEnabled
        public Boolean isFAQ = FALSE;
        
        @AuraEnabled
        public Boolean isMyProfile = FALSE;
        
        @AuraEnabled
        public Boolean isReferAFriend = FALSE;
    }
    
    public class DashboardMetrics {
        
        @AuraEnabled
        public String backgroundColor; 
        
        @AuraEnabled
        public String dashboardIcon; 
        
        @AuraEnabled
        public String dashboardType;  
        
        @AuraEnabled
        public String fontColor;   
        
        @AuraEnabled
        public String portalStatus;       
        
        public DashboardMetrics(String backgroundColorStr,String dashboardIconStr, String dashboardTypeStr, 
                                String fontColorStr, String portalStatusStr) {
                                    
        	this.backgroundColor = backgroundColorStr;
            this.dashboardIcon = dashboardIconStr;
            this.dashboardType = dashboardTypeStr;
            this.fontColor = fontColorStr;
            this.portalStatus = portalStatusStr;
		}                                       
    }
    
    public class AccountOverviewWrapperClass {
        
        /*@AuraEnabled
		public String programStatus; */
        
        @AuraEnabled
        public Date programStartDate;
        
        @AuraEnabled
        public Decimal enrolledDebt;
        
        @AuraEnabled
        public Decimal adjustedDebt;
        
        @AuraEnabled
        public Decimal currentDebt;
        
        @AuraEnabled
        public Decimal resolvedDebt;
        
        @AuraEnabled
        public Integer enrolledCreditors;
        
        @AuraEnabled
        public Integer resolvedCreditors;
        
        @AuraEnabled
        public Integer totalCreditors;
        
        @AuraEnabled
        public Boolean isInCriticalStage = false;
        
        @AuraEnabled
        public Boolean congratsMessage = false;
        
    }
    
    public class adhocPaymentWrapper {
        
        @AuraEnabled
        public Id activeBankAccount;
        
        @AuraEnabled
        public Map<String, Date> setMinAndMaxDate = new Map<String, Date>();
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> editPaymentFieldsList = 
            new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> editBankInfoFieldsList = 
            new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
    }
    
    public class DashboardMetricsWrapperClass {
        
        @AuraEnabled
        public List<DashboardMetrics> dashBoardMetricsList = new List<DashboardMetrics>();
        
        @AuraEnabled
        public String userName;  
        
        @AuraEnabled
        public Boolean customPermission;  
        
        @AuraEnabled
        public AccountOverviewWrapperClass accountOverviewWrapper = new AccountOverviewWrapperClass(); 
        
        @AuraEnabled
        public adhocPaymentWrapper adhocPaymentObj = new adhocPaymentWrapper ();
        
    }
    
    public class CustomUIWrapperGetSet {
        
        public Portal_Settings__c uiInstance {get; set;}
        
        public Map<String, String> imageURLMap {get; set;}
    }
    
    public class ProgramUserInstanceWrapper {
        
        @AuraEnabled    
        Public  nu_dse__Program__c programInstance {get; set;}
        
        @AuraEnabled
        public  User userInstance {get; set;}
    }
}