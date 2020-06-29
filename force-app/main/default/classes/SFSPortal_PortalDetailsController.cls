/* Date : 27-02-2019
 * Author : Team IDev
 * Description : Handler for Dashboard Metrics component
 */
public class SFSPortal_PortalDetailsController {

    public nu_dse__Program__c programInstance {get; set;}
    public User userInstance {get; set;}
    public Boolean renderVerificationModal {get; set;}
    public Id networkId {get; set;}
    
    public List<PortalDetailSection> portalDetailSectionWrapperList {get; set;}
    public String programId {get;
        set {
            
            if(programId == null) {
                
                programId = value;
                init();
            }
        }
    }
    
    public void init() {
        
        this.portalDetailSectionWrapperList = new List<PortalDetailSection>();
        this.renderVerificationModal = FALSE;
        System.debug('**** this.recordId-->' + this.programId);
        if(String.isNotBlank(this.programId) == TRUE) {
            
            List<Network> networkList = [SELECT Id, Name, EmailSenderName FROM Network WHERE Name LIKE '%Client%'];
            
            if (networkList != null && networkList.isEmpty() == False) {
                
                this.networkId = networkList[0].Id;
            }
            List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Account__c, nu_dse__Account__r.PersonContactId, 
                Client_Portal_User_Id__c, Invite_Client__c, Portfolio__c, Invite_Sent_Date__c, Invitation_Attempt__c, 
                ClientEmail__c, Portfolio__r.OWD_Email_Name__c FROM nu_dse__Program__c WHERE Id = :this.programId];
            
            System.debug('*** programList--> ' + programList);
            
            if(programList.isEmpty() == FALSE) {
                
                this.programInstance = programList[0];
                
                if(programList[0].nu_dse__Account__r.PersonContactId != null) {
                    
                    
                    List<User> userList = [SELECT Id, Name, LastLoginDate, Email, Source_Type__c, CreatedDate, PortalUserEmail__c, PortalUserMobile__c, MobilePhone, LastPasswordChangeDate 
                        FROM User WHERE ContactId = :programList[0].nu_dse__Account__r.PersonContactId];
                    if(userList.isEmpty() == FALSE) {
                        
                        this.userInstance = userList[0];
                    }
                    
                }
                
                System.debug('**** this.userInstance-->' + this.userInstance);
                
                System.debug('**** account-->' + programList[0].nu_dse__Account__c);
                
                /* group tasks */
                List<nu_dse__Group_Task__c> groupTaskList = [SELECT Id, Name, nu_dse__Subject__c, CreatedDate 
                    FROM nu_dse__Group_Task__c WHERE nu_dse__Related_To__c = :this.programInstance.Id AND Decision_Source__c = 'Portal'
                    ORDER BY CreatedDate DESC
                ];
                
                if(groupTaskList.isEmpty() == FALSE) {
                
                    PortalDetailSection sectionInstance = new PortalDetailSection();
                    sectionInstance.sectionName = 'Group Tasks';
                    sectionInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                    
                    for(nu_dse__Group_Task__c groupTask : groupTaskList) {
                    
                        sectionInstance.portalDetailWrapperList.add(new PortalDetailWrapper(groupTask.nu_dse__Subject__c, groupTask.CreatedDate, groupTask.Id, groupTask.Name));
                    }
                    
                    this.portalDetailSectionWrapperList.add(sectionInstance);
                }
                /* End of group tasks */
                
                /* Offers */
                if(this.userInstance != null && this.userInstance.Id != null) {
                
                    List<nu_dse__Offer__c> offerList = [SELECT Id, Name, CreatedDate, nu_dse__Status__c FROM nu_dse__Offer__c 
                        WHERE nu_dse__Program__c = :this.programInstance.Id AND LastModifiedById = :this.userInstance.Id
                        ORDER BY CreatedDate DESC
                    ];
                    
                    if(offerList.isEmpty() == FALSE) {
                    
                        PortalDetailSection sectionInstance = new PortalDetailSection();
                        sectionInstance.sectionName = 'Offers';
                        sectionInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                        
                        for(nu_dse__Offer__c offerInstance : offerList) {
                            
                            String subject = 'Client Declined';
                            if(offerInstance.nu_dse__Status__c == 'Client Approved') {
                            
                                subject = 'Client Accepted';
                            } 
                            
                            sectionInstance.portalDetailWrapperList.add(new PortalDetailWrapper(subject, offerInstance.CreatedDate, offerInstance.Id, offerInstance.Name));
                        }
                        
                        this.portalDetailSectionWrapperList.add(sectionInstance);
                    }
                }
                /* End of Offers */
                
                /* Payments */
                
                List<nu_dse__Payment__c> paymentList = [SELECT Id, Name, CreatedDate FROM nu_dse__Payment__c 
                    WHERE nu_dse__Program__c = :this.programInstance.Id AND Decision_Source__c = 'Portal'
                    ORDER BY CreatedDate DESC
                ];
                
                if(paymentList.isEmpty() == FALSE) {
                
                    PortalDetailSection sectionInstance = new PortalDetailSection();
                    sectionInstance.sectionName = 'Payments';
                    sectionInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                    
                    for(nu_dse__Payment__c payment : paymentList) {
                    
                        sectionInstance.portalDetailWrapperList.add(new PortalDetailWrapper('Client Rescheduled the payment', payment.CreatedDate, payment.Id, payment.Name));
                    }
                    
                    this.portalDetailSectionWrapperList.add(sectionInstance);
                }
                
                /* End Of Payments */
                
                /* Email Messages */
                List<EmailMessage> emailMessageList = [SELECT Id, Subject, CreatedDate, Action_Performed__c, ToAddress FROM EmailMessage 
                    WHERE Related_Account__c = :programList[0].nu_dse__Account__c AND Decision_Source__c = 'Portal'
                    ORDER BY CreatedDate DESC
                ];
                
                System.debug('**** emailMessageList-->' + emailMessageList);
                
                if(emailMessageList.isEmpty() == FALSE) {
                    
                    Map<String, List<PortalDetailWrapper>> wrapperList = new Map<String, List<PortalDetailWrapper>>();
                    
                    for(EmailMessage emailMsg : emailMessageList) {
                        
                        if(emailMsg.Action_Performed__c != null && emailMsg.Action_Performed__c != 'Email Change') {
                            
                            String actionPerformed = emailMsg.Action_Performed__c;
                            
                            String subject = emailMsg.Subject;
                            
                            if(emailMsg.Action_Performed__c == '2FA Email By Client' || emailMsg.Action_Performed__c == '2FA Email By Agent') {
                            
                                actionPerformed = '2FA Emails';
                                
                                subject = '2FA Email with code has been sent to ' + emailMsg.ToAddress;
                                
                                if(emailMsg.Action_Performed__c == '2FA Email By Agent') {
                                
                                    subject += ' by agent';
                                }
                            }
                            
                            if(wrapperList.containsKey(actionPerformed) == FALSE) {
                            
                                wrapperList.put(actionPerformed, new List<PortalDetailWrapper> {
                                    new PortalDetailWrapper(subject, emailMsg.CreatedDate, '', '')
                                });
                            } else {
                                
                                wrapperList.get(actionPerformed).add(
                                    new PortalDetailWrapper(subject, emailMsg.CreatedDate, '', '')
                                );
                            }
                        }
                    }
                    
                    
                    for(String sectionName : wrapperList.keySet()) {
                    
                        PortalDetailSection sectionInstance = new PortalDetailSection();
                        sectionInstance.sectionName = sectionName;
                        sectionInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                        sectionInstance.portalDetailWrapperList.addAll(wrapperList.get(sectionName));
                        
                        this.portalDetailSectionWrapperList.add(sectionInstance);
                    }
                }
                
                /* End Of Email Messages */
                
                
                if(this.userInstance != null && this.userInstance.Id != null) {
                
                    List<Portal_Identity_Service__c> portalIdentityList = [SELECT Id, Name, RecordType.DeveloperName, Type__c, 
                        Unique_Identifier__c, CreatedDate, New_Value__c, Old_Value__c, Ip_Address__c, Is_Agent_Sent__c, Status__c 
                        FROM Portal_Identity_Service__c 
                        WHERE User__c = :this.userInstance.Id ORDER BY RecordTypeId];
                    
                    if(portalIdentityList.isEmpty() == FALSE) {
                        
                        PortalDetailSection sectionInstance = new PortalDetailSection();
                        sectionInstance.sectionName = 'Email Changes';
                        sectionInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                        
                        PortalDetailSection verificationInstance = new PortalDetailSection();
                        verificationInstance.sectionName = '2FA SMS';
                        verificationInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                        
                        PortalDetailSection loginInstance = new PortalDetailSection();
                        loginInstance.sectionName = 'Login History';
                        loginInstance.portalDetailWrapperList = new List<PortalDetailWrapper>();
                        
                        Boolean isVerificationHavingRecords = FALSE, isEmailHavingRecords = FALSE, isLoginHavingRecords = FALSE;
                        
                        
                        for(Portal_Identity_Service__c identityInstance : portalIdentityList) {
                            
                            if(identityInstance.Unique_Identifier__c != null) {
                            
                                isEmailHavingRecords = TRUE;
                                
                                String subject = 'Change Email Request From ' + identityInstance.Old_Value__c + ' to ' + identityInstance.New_Value__c;
                                
                                if(identityInstance.Status__c == 'Verified') {
                                
                                    subject = 'Changed Email From ' + identityInstance.Old_Value__c + ' to ' + identityInstance.New_Value__c;
                                } 
                                
                                sectionInstance.portalDetailWrapperList.add(new PortalDetailWrapper(subject, identityInstance.CreatedDate, identityInstance.Id, identityInstance.Name));
                            } else if(identityInstance.RecordType.DeveloperName == 'Login_History') {
                                
                                isLoginHavingRecords = TRUE;
                                String subject = 'Tried to Log in with ' + identityInstance.Ip_Address__c;
                                if(identityInstance.Status__c == 'Success') {
                                    
                                    subject = 'Successfully Logged in with ' + identityInstance.Ip_Address__c;
                                } 
                                
                                loginInstance.portalDetailWrapperList.add(new PortalDetailWrapper(subject, identityInstance.CreatedDate, identityInstance.Id, identityInstance.Name));
                            } else {
                            
                                isVerificationHavingRecords = TRUE;
                                
                                String subject = '2FA ' + identityInstance.Type__c + ' with code has been sent to ';
                                
                                if(identityInstance.Type__c == 'Email') {
                                
                                    subject += this.userInstance.Email;
                                } else if(identityInstance.Type__c == 'SMS') {
                                
                                    subject += this.userInstance.MobilePhone;
                                }
                                
                                if(identityInstance.Is_Agent_Sent__c == TRUE) {
                                
                                    subject += ' by agent';
                                }
                            
                                verificationInstance.portalDetailWrapperList.add(new PortalDetailWrapper(subject, identityInstance.CreatedDate, identityInstance.Id, identityInstance.Name));
                            }
                        }
                        
                        
                        if(isVerificationHavingRecords) {
                        
                            this.portalDetailSectionWrapperList.add(verificationInstance);
                        }
                        
                        if(isLoginHavingRecords) {
                        
                            this.portalDetailSectionWrapperList.add(loginInstance);
                        }
                        
                        if(isEmailHavingRecords) {
                            
                            this.portalDetailSectionWrapperList.add(sectionInstance);
                        }
                    }
                }
            }
        }
    }
    
    /*public PageReference redirectToLoginCommunity() {
        
        List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
        methods.add(Auth.VerificationMethod.EMAIL);
        
        List<Portfolio__c> portfolioList = [SELECT Id, Domain_URL__c
                                            FROM Portfolio__c WHERE Id = :this.programInstance.Portfolio__c];
        system.debug('portfolioList--->'+portfolioList);
        system.debug('Client_Portal_User_Id--->'+this.programInstance.Client_Portal_User_Id__c);
        List<Network> networkList = [SELECT Id, Name, EmailSenderName FROM Network WHERE Name LIKE '%Client%'];
        PageReference orderPage = new PageReference('/servlet/servlet.su?oid='+UserInfo.getOrganizationId()+'&retURL='+this.programInstance.nu_dse__Account__c+'&sunetworkuserid='+this.programInstance.Client_Portal_User_Id__c+'&sunetworkid='+networkList[0].Id);
        orderPage.setRedirect(true);
        return orderPage;
    }*/
    
    public void sendReInvitationToClient() {
    
        try {
        
            if(this.programInstance != null && String.isNotBlank(this.programInstance.ClientEmail__c) == TRUE) {
            
                nu_dse__Program__c programToUpdate = new nu_dse__Program__c(Id = this.programInstance.Id);
                
                List<EmailTemplate> emailTemplateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Send_Invite_Email_Template'];
                
                if(emailTemplateList.isEmpty() == FALSE) {
                    
                    Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                    //emailInstance.setSubject('Reminder for registration');
                    emailInstance.setTemplateId(emailTemplateList[0].Id);
                    emailInstance.setSaveAsActivity(false);
                    emailInstance.setTreatTargetObjectAsRecipient(false);
                    emailInstance.setTargetObjectId(this.programInstance.nu_dse__Account__r.PersonContactId);// Any contact or User id of your record
                    emailInstance.setToAddresses(new List<String>{this.programInstance.ClientEmail__c}); 
                    
                    /* Getting org wide email address based on the diplay name */
                    if(String.isNotBlank(this.programInstance.Portfolio__r.OWD_Email_Name__c) == TRUE) {
                       
                        Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(this.programInstance.Portfolio__r.OWD_Email_Name__c);
                    
                        if(owdEmailId != null) {
                        
                            emailInstance.setOrgWideEmailAddressId(owdEmailId);
                        }
                    }
                    
                    emailInstance.setWhatId(this.programInstance.Id);
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                    
                    System.debug('**** mailResultList-->' + mailResultList);
                    
                    if(mailResultList[0].isSuccess() == TRUE) { 
                     
                        String reInvitationStatus = 'Re-Invitation 1';
                        if(String.isNotBlank(this.programInstance.Invitation_Attempt__c) == TRUE) {
                        
                            Integer lastInviteCount = Integer.valueOf(this.programInstance.Invitation_Attempt__c.substringAfter(' '));
                            reInvitationStatus = 'Re-Invitation ' + ( lastInviteCount + 1);
                        }
                        
                        programToUpdate.Invitation_Attempt__c = reInvitationStatus;
                        programToUpdate.Re_Invited_Date__c = System.now().date();
                        
                        update programToUpdate;
                    }
                }
            } else {
            
                throw new CustomException('Client Email is not populated in program');
            }
            
        } catch(Exception e) {
        
            
        }
    }
    
    public void sendVerificationCodeToClient() {
    
        String selectedMode = ApexPages.currentPage().getParameters().get('selctedMode');
        system.debug('selectedMode---->'+selectedMode);
        if (String.isNotBlank(selectedMode) == TRUE) {
        
            Integer validationCode = Integer.valueOf(SFSPortal_DashboardMetricsController.getRandomNumber(6));
            
            if(selectedMode == 'Email') {
                
                if(this.programInstance.Portfolio__c != null) {
                
                    List<Portfolio__c> portfolioList = [SELECT Id, Name, Domain_URL__c, Dispay_Name__c, Address__c, City__c, State__c, 
                        Zipcode__c, Support_Fax_Number__c, Support_Email__c, Support_Phone_Number__c, Website__c, OWD_Email_Name__c, 
                        Logo_Document_Name__c
                        FROM Portfolio__c WHERE Id = :this.programInstance.Portfolio__c
                    ];
                    
                    if(portfolioList.isEmpty() == FALSE) 
                    {
                    
                        Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                        emailInstance.setToAddresses(new String[]{this.userInstance.Email});
                        
                        //emailInstance.setBCCAddresses(new List<String>{'jtighe@stratfs.com','acarroll@stratfs.com'});
                        
                        
                        String subjectToSend = 'Your ' + portfolioList[0].Dispay_Name__c + ' Portal verification code.';
                        
                        emailInstance.setSubject(subjectToSend);
                        
                        String htmlbody = 'Hello ' + this.userInstance.Name + ', <br />'
                            + '<br/>Your verification code is <span style="color:maroon">' + validationCode + '</span> <br /> <br />'
                            + SFSPortal_Utility.getEmailSignature(portfolioList[0]);
                        
                        emailInstance.setHTMLBody(htmlbody); 
                        
                        /* Getting org wide email address based on the diplay name */
                        if(String.isNotBlank(portfolioList[0].OWD_Email_Name__c) == TRUE) {
                           
                            Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(portfolioList[0].OWD_Email_Name__c);
                        
                            if(owdEmailId != null) {
                            
                                emailInstance.setOrgWideEmailAddressId(owdEmailId);
                            }
                        }
                                 
                        Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                        
                        List<EmailMessage> emailMessageList = [SELECT Id FROM EmailMessage WHERE subject LIKE :subjectToSend ORDER BY CreatedDate DESC LIMIT 1];
                        
                        System.debug('**** mailResultList-->' + mailResultList);
                        
                        System.debug('**** emailMessageList-->' + emailMessageList);
                        
                        
                        
                        if(mailResultList[0].isSuccess() == true && emailMessageList.isEmpty() == FALSE) {
                            
                            EmailMessage emailMessageToUpdate = new EmailMessage(Id = emailMessageList[0].Id, 
                                Related_Account__c = this.programInstance.nu_dse__Account__c, Decision_Source__c = 'Portal', Action_Performed__c = '2FA Email By Agent'
                            );
                            
                            System.debug('**** emailMessageToUpdate-->' + emailMessageToUpdate);
                            
                            update emailMessageToUpdate;
                            
                            Portal_Identity_Service__c identityVerificationInstance = new Portal_Identity_Service__c(User__c = this.userInstance.Id, 
                                Status__c = 'Initiated', RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification'),
                                Is_Agent_Sent__c = TRUE, New_Value__c = String.valueOf(validationCode)
                            );
                            
                            identityVerificationInstance.Description__c = htmlbody;
                            identityVerificationInstance.Type__c = 'Email';
                            
                            insert identityVerificationInstance;
                        }
                        
                    } else {
                    
                        throw new CustomException('Required fields are not populated in program. Please contact system admin.');
                    }
                } else {
                    
                    throw new CustomException('Required fields are not populated in program. Please contact system admin.');
                }
            } else if(selectedMode == 'Mobile' || selectedMode == 'Phone Call') {
                
                Portal_Identity_Service__c identityVerificationInstance = new Portal_Identity_Service__c(User__c = this.userInstance.Id, 
                    Status__c = 'Initiated', RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification'),
                    Is_Agent_Sent__c = TRUE, New_Value__c = String.valueOf(validationCode)
                );
                
                if(selectedMode == 'Mobile') {
                
                    String textMessage = 'Hello, ' + validationCode + ' is your code to confirm your identity.';
            
                    nu_dse.TwilioMessage messageInstance = nu_dse.TwilioCommunications.sendSMS(this.userInstance.MobilePhone, textMessage);
                    
                    identityVerificationInstance.Description__c = textMessage + '<br /> <b> To Mobile: </b> ' + this.userInstance.MobilePhone;
                    identityVerificationInstance.Type__c = 'SMS';
                    
                    System.debug('***** messageInstance-->' + messageInstance);
                } else if(selectedMode == 'Phone Call') {
                
                    String textMessage = 'Hello, ' + validationCode + ' is your code to confirm your identity.';
                    
                }
                
                System.debug('**** identityVerificationInstance-->' + identityVerificationInstance);
            
                /* Insertig identity verification record with mobile or email */
                insert identityVerificationInstance;
            }
            
            
            this.renderVerificationModal = FALSE;
            
            init();
        }
    }
    
    public void showHideVerificationModal() {
    
        this.renderVerificationModal = !this.renderVerificationModal;
    }
    
    /* Date : 01-03-2019
     * Description : To send the verification code call to client
     * Invoked From : LoginFlow2FAPage
     */
    
    public static Boolean sendCallToClient(String tonumber, Integer customCode) {
        
        try {
           
            if(String.isNotBlank(tonumber) == TRUE && customCode != null) {
            
                HttpRequest httpRequestToSend = new HttpRequest();
                
                TwilioConfig__c twilioConfig = TwilioConfig__c.getInstance();
                
                if(twilioConfig != null && String.isNotBlank(twilioConfig.AccountSid__c) == TRUE 
                    && String.isNotBlank(twilioConfig.ApplicationSid__c) == TRUE && String.isNotBlank(twilioConfig.AuthToken__c) == TRUE) {
                
                    String endpointURL = 'https://verify.twilio.com/v2/Services/' + twilioConfig.ApplicationSid__c + '/Verifications';
                    
                    //String endpointURL = 'https://api.authy.com/protected/json/phones/verification/start?via=call&country_code=1&code_length=6&phone_number=' + tonumber + '&custom_code=456783';
                    
                    httpRequestToSend.setEndpoint(endpointURL);
                    httpRequestToSend.setMethod('POST');
                    httpRequestToSend.setTimeout(120000);
                    
                    //httpRequestToSend.setHeader('Authorization',  'Basic QUNjOTY2NjQ0NGM4Y2QyYzc3YzEyYzQ0YzQwMWU4OWQ2MjpTdHJhdGVnaWNmaW5hbmNlMTIz');
                    
                    httpRequestToSend.setHeader('Authorization',  'Basic ' + EncodingUtil.base64Encode(Blob.valueof(twilioConfig.AccountSid__c + ':' + twilioConfig.AuthToken__c)));
                    
                    System.debug('***** customCode-->' + customCode);
                    
                    String bodyStringToSend = 'To=' + EncodingUtil.urlEncode('+', 'UTF-8') + '1' + tonumber
                        + '&Channel=call'
                        + '&CustomCode=' + customCode
                    ;
                    
                    
                    //String bodyStringToSend = 'To=%2B115105099760&Channel=call&CustomCode=123456';
                    
                    httpRequestToSend.setBody(bodyStringToSend);
                    
                    
                    Http http = new Http();   
                    HttpResponse httpResponse = http.send(httpRequestToSend);  
                    
                    System.debug('***** httpResponse-->' + httpResponse);
                    
                    System.debug('***** httpResponse-->' + httpResponse.getStatusCode());
                    
                    
                    if(httpResponse.getStatusCode() == 201) {
                        
                        return true;
                    } else {
                    
                        throw new CalloutException(httpResponse.getBody());  
                    }
                } else {
                    
                    throw new CustomException('Twilio settings were not configured');
                }
            }
        } catch(Exception e) {
        
            throw new CustomException(e.getMessage());
        }
        
        return null;
    }
    
    
    /* Date : 01-03-2019
     * Description : To send the verification code call to client
     * Invoked From : LoginFlow2FAPage
     */
    /* 
    public static String validateEnteredCode(String tonumber, String enteredText) {
        
        try {
        
            if(String.isNotBlank(tonumber) == TRUE && String.isNotBlank(enteredText) == TRUE) {
            
                HttpRequest httpRequestToSend = new HttpRequest();
                
                String endpointURL = 'https://api.authy.com/protected/json/phones/verification/check?country_code=1&phone_number=' + tonumber +'&verification_code=' + enteredText;
                
                httpRequestToSend.setEndpoint(endpointURL);
                httpRequestToSend.setMethod('GET');
                httpRequestToSend.setTimeout(120000);
                
                httpRequestToSend.setHeader('X-Authy-API-Key', 'H8WYOby52YZ12J0Koo3BJsTM4DZMwbIs');
                
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequestToSend);  
                
                if(httpResponse.getStatusCode() == 200) {
                    
                    String response =  JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()));
                    
                    Map<String, String> responseMap = (Map<String, String>) JSON.deserialize(response, Map<String, String>.class);
                    
                    System.debug('***** responseMap-->' + responseMap);
                    
                    if(responseMap.containsKey('')) {
                    
                        return '';
                    }
                    
                } else {
                
                    throw new CalloutException(httpResponse.getBody());  
                }
            }
        } catch(Exception e) {
        
            throw new CustomException(e.getMessage());
        }
        
        return null;
    }
    */
    
    public class PortalDetailSection {
    
        public String sectionName {get; set;}
        public List<PortalDetailWrapper> portalDetailWrapperList {get; set;}
    }
    
    public class PortalDetailWrapper {
    
        public String actionMessage {get; set;}
        public DateTime createdDate {get; set;}
        public String recordUrl {get; set;}
        public String name {get; set;}
        
        public PortalDetailWrapper(String message, DateTime createdDate, String recordId, String name) {
        
            this.actionMessage = message;
            this.createdDate = createdDate;
            this.recordUrl = recordId;
            this.name = name;
        }
    }
}