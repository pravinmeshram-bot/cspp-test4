/* Date : 08-10-2018
 * Author : Team IDev
 * Description : Handler for Community User Detail component
 */
public class SFSPortal_CommunityUserDetailController {
    
    /* To update Portal Identity Service's status as verified if the email is verified*/
    public static void updateEmailAddress() {
        
        try {
        
            if (ApexPages.currentPage().getParameters().ContainsKey('UniqueId') != null) {
                 
                 system.debug('UniqueId---->'+ApexPages.currentPage().getParameters().get('UniqueId'));
                 Portal_Identity_Service__c portalIdentityService = [SELECT Id, New_Value__c FROM Portal_Identity_Service__c 
                     WHERE RecordTypeId = :SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification')
                     AND Unique_Identifier__c = :ApexPages.currentPage().getParameters().get('UniqueId')
                     AND Status__c = 'Processing' Limit 1
                 ];  
                 system.debug('portalIdentityService---->'+portalIdentityService);                                                        
                 if (portalIdentityService != null ) {
                     
                     portalIdentityService.Status__c = 'Verified';
                     update portalIdentityService;
                     system.debug('portalIdentityService---->'+portalIdentityService);  
                 }
             }
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* To get current User Instance and Portal Identity Service's status for current email and phone's record status*/
    @AuraEnabled
    public static UserWrapper getCurrentUser() {
        
        Map<String, String> portalIndentityServiceMap = new Map<String, String>();
        try {
            UserWrapper userWrapper = new UserWrapper();
            userWrapper.userInstance = [SELECT Id, Name, FirstName, LastName, Street, City, State, State__c, PostalCode, Email, 
                MobilePhone, FullPhotoURL, ContactId, UserName
                FROM User WHERE Id = :userinfo.getUserId() Limit 1
            ];
                                                            
            Schema.DescribeSObjectResult objDescribe = User.getSObjectType().getDescribe(); 
            for (Schema.PicklistEntry state : objDescribe.fields.getMap().get('State__c').getDescribe().getPickListValues()) { 
                
                userWrapper.statePicklistValueList.add(state.getValue()); 
            }
            system.debug('userWrapper.userInstance---->'+userWrapper.userInstance);                                                
            if (userWrapper.userInstance != null) {
                
                for (Portal_Identity_Service__c portalIdentityService : [SELECT Id , Old_Value__c, New_Value__c, Status__c 
                    FROM Portal_Identity_Service__c 
                    WHERE RecordTypeId = :SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification') 
                    AND User__c =: userWrapper.userInstance.Id 
                    AND (Old_Value__c =: userWrapper.userInstance.MobilePhone OR Old_Value__c =: userWrapper.userInstance.Email)
                    ORDER BY LastModifiedDate DESC LIMIT 10
                ]) {
                                                                     
                    if (portalIndentityServiceMap.ContainsKey(portalIdentityService.Old_Value__c) == False) {
                        
                        portalIndentityServiceMap.put(portalIdentityService.Old_Value__c, portalIdentityService.Status__c);
                    }                                                     
                }        
                
                if (portalIndentityServiceMap.ContainsKey(userWrapper.userInstance.Email)) {
                    
                    userWrapper.emailVerificationStatus = portalIndentityServiceMap.get(userWrapper.userInstance.Email);
                }    
            }
            system.debug('userWrapper---->'+userWrapper); 
            return userWrapper;  
                          
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*To get random number*/
    @AuraEnabled
    public static String getRandomNumber() {
        
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        return EncodingUtil.convertToHex(hash).substring(0, 9);
    }
    
    /*To upload user profile image*/
    @AuraEnabled
    public static userWrapper uploadImage(Id documentId) {
        
        try {
            
            UserWrapper userWrapper = new UserWrapper();
            ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(null, userinfo.getUserId(), documentId, null);
            return getCurrentUser();
        } catch (Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* To Update Phone Number*/
    @AuraEnabled
    public static userWrapper updatePhoneNumber(String phoneNumber, User userInstance) {
        
        try {
            
            if (String.isNotBlank(phoneNumber) && userInstance.Id != null) {
                
                List<Portal_Identity_Service__c> portalIdentityServiceList = [SELECT Id, New_Value__c FROM Portal_Identity_Service__c 
                     WHERE RecordTypeId = :SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification')
                     AND User__c = :userInstance.Id AND Type__c = 'Mobile' AND New_Value__c = :phoneNumber
                     AND Old_Value__c = :userInstance.MobilePhone AND Status__c = 'Processing' Limit 1
                 ];  
                 
                 system.debug('portalIdentityServiceList --->'+portalIdentityServiceList );
                 
                if (portalIdentityServiceList.isEmpty() == False) {
                    
                    portalIdentityServiceList[0].Status__c = 'Verified';
                    update portalIdentityServiceList;
                     
                    User updateUser = new User(Id = userInstance.Id);
                    updateUser.MobilePhone = phoneNumber;
                    update updateUser;
                    
                    Contact ContactInstance = new Contact(Id = userInstance.ContactId);
                    ContactInstance.MobilePhone = phoneNumber;    
                    update ContactInstance;
                }                
                return getCurrentUser();
            }
            return null;
        } catch (Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /* To reset password */
    @AuraEnabled
    public static boolean resetpassword(User userInstance) {
        
        System.debug('**** userInstance-->' + userInstance);
        
        if (userInstance != null) {
            
            //System.resetPassword(userInstance.Id, true);
            System.ResetPasswordResult resetPasswordResult;
            if(!Test.isRunningTest()){
                
                resetPasswordResult = System.resetPassword(userInstance.Id, false);
            }
            System.debug('***** resetPasswordResult -->' + resetPasswordResult);
            
            List<EmailTemplate> emailTemplateList = [Select Id FROM EmailTemplate WHERE DeveloperName = 'Communities_Changed_Password_Email' LIMIT 1];
            
            if(emailTemplateList.isEmpty() == FALSE) {
                
                //emailInstance.setTemplateID(emailTemplateList[0].Id);
                
                
                Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                
                Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                
                if(accountIdMap != null && accountIdMap.containsKey('userAccountId') == TRUE) {
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c, Portfolio__r.Logo_Document_Name__c, 
                        Portfolio__r.Dispay_Name__c, Portfolio__r.Excela_Email__c, Portfolio__r.OWD_Email_Name__c, Portfolio__r.Name, 
                        Portfolio__r.Address__c, Portfolio__r.City__c, Portfolio__r.Domain_URL__c, Portfolio__r.State__c, 
                        Portfolio__r.Support_Email__c, Portfolio__r.Support_Fax_Number__c, Portfolio__r.Support_Phone_Number__c, 
                        Portfolio__r.Website__c, Portfolio__r.Zipcode__c, nu_dse__Account__c
                        FROM nu_dse__Program__c
                        WHERE nu_dse__Account__c = :accountIdMap.get('userAccountId') AND Portfolio__c != null 
                    ];
                    
                    Messaging.SingleEmailMessage templateBody = new Messaging.SingleEmailMessage();
                    if(!Test.isRunningTest()){
                    
                        templateBody = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, userInstance.ContactId, null);
                    }                
                    System.debug('***** testMessageBody-->' + templateBody);
                    
                    System.debug('***** testMessageBody-->' + templateBody.getHTMLBody());
                    
                    //emailInstance.setTargetObjectId(userInstance.ContactId);
                    
                    emailInstance.setToAddresses(new String[]{userInstance.Email});
                    
                    String subjectToSend = 'Password Reset Request';
                    emailInstance.setSubject(subjectToSend);
                    
                    /* Getting org wide email address based on the diplay name */
                    if(programList.isEmpty() == FALSE && String.isNotBlank(programList[0].Portfolio__r.OWD_Email_Name__c) == TRUE)  {

                        String existingBody = '';                        
                        if (resetPasswordResult != null && templateBody != null) {
                            existingBody = templateBody.getHTMLBody().replace(
                                '<a class="resetLink" href="', ('<a href="' + programList[0].Portfolio__r.Domain_Url__c + '/s/login?un=' 
                                              + userInstance.UserName + '&pw=' + resetPasswordResult.getPassword())
                            );
                        }
                        
                        //emailInstance.setHTMLBody(existingBody + SFSPortal_Utility.getEmailSignature(programList[0].Portfolio__r) );
                        
                        emailInstance.setHTMLBody(existingBody);
                        
                        Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(programList[0].Portfolio__r.OWD_Email_Name__c);
                        
                        if(owdEmailId != null) {
                        
                            emailInstance.setOrgWideEmailAddressId(owdEmailId);
                        }
                    }
                    
                    System.debug('**** emailInstance-->' + emailInstance);
                    
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                    
                    List<EmailMessage> emailMessageList = [SELECT Id FROM EmailMessage WHERE subject LIKE :subjectToSend ORDER BY CreatedDate DESC LIMIT 1];
                    
                    if(mailResultList[0].isSuccess() == TRUE && programList.isEmpty() == FALSE && emailMessageList.isEmpty() == FALSE) {
                        
                        EmailMessage emailMessageToUpdate = new EmailMessage(Id = emailMessageList[0].Id, 
                            Related_Account__c = programList[0].nu_dse__Account__c, Decision_Source__c = 'Portal', Action_Performed__c = 'Reset Password'
                        );
                        update emailMessageToUpdate;
                        
                        return true;
                    }
                }
            }
            
            
        }
        return false;
    }
    
    /* To update user*/
    @AuraEnabled
    public static Boolean updatePhoneUser(User userInstance, User newUserInstance) {
        
        try {
            
            List<Portal_Identity_Service__c> portalIdentityServiceList = new List<Portal_Identity_Service__c>();
            
            if (String.isNotBlank(newUserInstance.MobilePhone) == TRUE && userInstance.MobilePhone != newUserInstance.MobilePhone) {
                            
                Portal_Identity_Service__c portalIdentityService = new Portal_Identity_Service__c();
                portalIdentityService.New_Value__c = newUserInstance.MobilePhone;
                portalIdentityService.Old_Value__c = userInstance.MobilePhone;
                portalIdentityService.User__c = userInstance.Id;
                portalIdentityService.Status__c = 'Processing';
                portalIdentityService.Type__c = 'Mobile';
                portalIdentityService.RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification');
                portalIdentityServiceList.add(portalIdentityService);
            }
            System.debug('**** newUserInstance-->' + newUserInstance);
            if (portalIdentityServiceList.isEmpty() == False) {
                
                insert portalIdentityServiceList;
                system.debug('portalIdentityServiceList--->'+portalIdentityServiceList);
                return true;
            }
        } catch (Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    /* To update user*/
    @AuraEnabled
    public static userWrapper updateUser(User userInstance, User newUserInstance) {
        
        String errorMsg = '';
        UserWrapper userWrapper = new UserWrapper();
        try {
        
            if (userInstance != null && newUserInstance != null) {
                
                system.debug('userInstance--->'+userInstance);
                system.debug('newUserInstance--->'+newUserInstance);
                List<Portal_Identity_Service__c>  portalIdentityServiceList = new List<Portal_Identity_Service__c>();
                Set<Id> contactId = new Set<Id>();
                
                if (String.isNotBlank(newUserInstance.Email) == TRUE) {
                    
                    system.debug('%%%%%%--->'+newUserInstance.Email);
                    
                    String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
                    Pattern MyPattern = Pattern.compile(emailRegex);
                    Matcher MyMatcher = MyPattern.matcher(newUserInstance.Email);      
                    if (!MyMatcher.matches()) {
                        
                        errorMsg += ' Enter Valid Email Address';
                    }
                    
                    if (String.isBlank(errorMsg)) {
                        
                        if ((userInstance.PostalCode != newUserInstance.PostalCode || userInstance.Street != newUserInstance.Street || 
                                            userInstance.City != newUserInstance.City || userInstance.State != newUserInstance.State__c )
                                            && newUserInstance.ContactId != null) {
                            
                            Portal_Identity_Service__c portalIdentityService = new Portal_Identity_Service__c();
                            portalIdentityService.New_Value__c = newUserInstance.Street+', '+newUserInstance.City+ ', ' +newUserInstance.State__c+ '-'+newUserInstance.PostalCode;
                            portalIdentityService.Old_Value__c = userInstance.Street+', '+userInstance.City+ ', ' +userInstance.State__c+ '-'+userInstance.PostalCode;
                            portalIdentityService.User__c = userInstance.Id;
                            portalIdentityService.Status__c = 'Verified';
                            portalIdentityService.Type__c = 'Address';
                            portalIdentityService.RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification');
                            portalIdentityServiceList.add(portalIdentityService);
                            
                            Contact ContactInstance = new Contact(Id = newUserInstance.ContactId);
                            ContactInstance.MailingStreet = newUserInstance.Street;
                            ContactInstance.MailingCity = newUserInstance.City;
                            ContactInstance.MailingState = newUserInstance.State;
                            ContactInstance.MailingPostalCode = newUserInstance.PostalCode;
                            update ContactInstance;
                        }
                        system.debug('errorMsg--->'+errorMsg);
                        system.debug('userInstance.Email--->'+userInstance.Email);
                        system.debug('newUserInstance.Email--->'+newUserInstance.Email);
                        if (userInstance.Email != newUserInstance.Email) {
                            
                            system.debug('#####--->');
                            Portal_Identity_Service__c portalIdentityService = new Portal_Identity_Service__c();
                            portalIdentityService.New_Value__c = newUserInstance.Email;
                            portalIdentityService.Old_Value__c = userInstance.Email;
                            portalIdentityService.User__c = userInstance.Id;
                            portalIdentityService.Status__c = 'Initiated';
                            portalIdentityService.Type__c = 'Email';
                            portalIdentityService.Unique_Identifier__c = getRandomNumber();
                            portalIdentityService.RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification');
                            
                            if (portalIdentityService.Unique_Identifier__c != null) {
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setToAddresses(new List<String>{newUserInstance.Email});
                                String subjectToSend = 'Verify Your Email Address';
                                mail.setSubject(subjectToSend);
                                
                                Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                
                                if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
                                    
                                    if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                                        
                                        List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c, Portfolio__r.Logo_Document_Name__c, 
                                            Portfolio__r.Email_Verification_Site_URL__c, Portfolio__r.Dispay_Name__c, 
                                            Portfolio__r.Excela_Email__c, Portfolio__r.OWD_Email_Name__c, Portfolio__r.Name, 
                                            Portfolio__r.Address__c, Portfolio__r.City__c, Portfolio__r.Domain_URL__c, 
                                            Portfolio__r.State__c, Portfolio__r.Support_Email__c, Portfolio__r.Support_Fax_Number__c, 
                                            Portfolio__r.Support_Phone_Number__c, Portfolio__r.Website__c, Portfolio__r.Zipcode__c
                                            FROM nu_dse__Program__c WHERE nu_dse__Account__c = :accountIdMap.get('primaryAccountId') 
                                            AND Portfolio__c != null
                                        ];
                                        if (programList!= null && programList.isEmpty() == False) {
                                            
                                            if(programList[0].Portfolio__r.Email_Verification_Site_URL__c != null) {
                                            
                                                string body = '<p>Hi '+userInstance.Name+', <br/> <br/> Click <span style="color:#7fba5c;font-weight:bold;"><a href="'
                                                              +programList[0].Portfolio__r.Email_Verification_Site_URL__c+'/CommunityUserDetail?UniqueId='
                                                              +portalIdentityService.Unique_Identifier__c+'">here</a></span> to Verify Your Email Address.<br /></p>'; 
                                                
                                                mail.setHtmlBody(body + SFSPortal_Utility.getEmailSignature(programList[0].Portfolio__r));
                                                
                                                /* Getting org wide email address based on the diplay name */
                                                if(String.isNotBlank(programList[0].Portfolio__r.OWD_Email_Name__c) == TRUE) {
                    
                                                    Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(programList[0].Portfolio__r.OWD_Email_Name__c);
                        
                                                    if(owdEmailId != null) {
                                                    
                                                        mail.setOrgWideEmailAddressId(owdEmailId);
                                                    }
                                                }
                                                
                                            } else {
                                                
                                                throw new CustomException('Required information is not populated in portfolio. Please contact system admin.');
                                            }
                                        }
                                    }
                                }                                                            
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                                
                                List<EmailMessage> emailMessageList = [SELECT Id FROM EmailMessage WHERE subject LIKE :subjectToSend ORDER BY CreatedDate DESC LIMIT 1];
                      
                                if (results[0].success && accountIdMap.ContainsKey('primaryAccountId') == True 
                                    && accountIdMap.get('primaryAccountId') != null && emailMessageList.isEmpty() == FALSE) {
                                    portalIdentityService.Status__c = 'Processing';
                                    
                                    EmailMessage emailMessageToUpdate = new EmailMessage(Id = emailMessageList[0].Id, 
                                        Related_Account__c = accountIdMap.get('primaryAccountId'), Decision_Source__c = 'Portal', Action_Performed__c = 'Email Change'
                                    );
                                    
                                    update emailMessageToUpdate;
                                    
                                }
                            }
                            portalIdentityServiceList.add(portalIdentityService);
                            newUserInstance.Email = userInstance.Email;
                        }
                        
                        System.debug('***** newUserInstance.MobilePhone-->' + newUserInstance.MobilePhone);
                        
                        if (String.isNotBlank(newUserInstance.MobilePhone) == TRUE && userInstance.MobilePhone != newUserInstance.MobilePhone) {
                            
                            Portal_Identity_Service__c portalIdentityService = new Portal_Identity_Service__c();
                            portalIdentityService.New_Value__c = newUserInstance.MobilePhone;
                            portalIdentityService.Old_Value__c = userInstance.MobilePhone;
                            portalIdentityService.User__c = userInstance.Id;
                            portalIdentityService.Status__c = 'Processing';
                            portalIdentityService.Type__c = 'Mobile';
                            portalIdentityService.RecordTypeId = SFSPortal_Utility.getRecordTypeId('Portal_Identity_Service__c', 'Identity Verification');
                            portalIdentityServiceList.add(portalIdentityService);
                            newUserInstance.MobilePhone = userInstance.MobilePhone;
                        }
                        
                        System.debug('**** newUserInstance-->' + newUserInstance);
                        
                        if (portalIdentityServiceList.isEmpty() == False) {
                            
                            insert portalIdentityServiceList;
                            system.debug('portalIdentityServiceList--->'+portalIdentityServiceList);
                        }
                        update newUserInstance;
                        userWrapper = getCurrentUser();
                    } else {
                    
                        throw new CustomException(errorMsg);
                    }
                } else {
                
                    throw new CustomException('Email address cannot be blank.');
                }
            }
        } catch (Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return userWrapper;
    }
    
    public class UserWrapper {
        
        @AuraEnabled
        public User userInstance;
        
        @AuraEnabled
        public List<String> statePicklistValueList;
        
        @AuraEnabled
        public String phoneVerificationStatus;
        
        @AuraEnabled
        public String emailVerificationStatus;
        
        public UserWrapper() {
        
            this.statePicklistValueList = new List<String>();
            this.userInstance = new User();
            this.phoneVerificationStatus = '';
            this.emailVerificationStatus = '';
        }
    }    
}