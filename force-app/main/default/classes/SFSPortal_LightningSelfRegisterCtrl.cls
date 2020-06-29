global without sharing class SFSPortal_LightningSelfRegisterCtrl {
    
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @AuraEnabled 
    public static AccountWrapper getAccountInfo(String parsedAccountId, Boolean isClientEmail) {
    
        AccountWrapper accountWrapper = new AccountWrapper();
        try {
            
            Blob encryptedDataString = EncodingUtil.base64Decode(parsedAccountId);
            String cryptoString = '0123456789ABCDEF0123456789ABCDE0';
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', Blob.ValueOf(cryptoString), encryptedDataString);
            string accountId = decryptedData.toString();
            
            if (String.isNotBlank(accountId)) {
                
                for (nu_dse__Program__c programInstance : [SELECT Id, Portfolio__c, nu_dse__Account__c, nu_dse__Account__r.FirstName, nu_dse__Account__r.LastName, 
                                                           nu_dse__Account__r.PersonBirthdate, nu_dse__Account__r.SSN_last_4__c, nu_dse__Account__r.PersonEmail, 
                                                           Portfolio__r.Profile_Name__c, nu_dse__Account__r.Phone, nu_dse__Account__r.Personmailingcountry,
                                                           nu_dse__Account__r.PersonMailingStreet, nu_dse__Account__r.PersonMailingCity, 
                                                           nu_dse__Account__r.PersonMailingPostalCode, nu_dse__Account__r.PersonMailingState
                                                           FROM nu_dse__Program__c 
                                                           WHERE nu_dse__Account__c =: accountId
                                                           ORDER BY LastModifiedDate DESC LIMIT 1]) {                                                                                                       
                    
                    accountWrapper.programId = programInstance.Id;
                    accountWrapper.accountId = programInstance.nu_dse__Account__c;
                    
                    if (programInstance.Portfolio__c != null && programInstance.Portfolio__r.Profile_Name__c != null) {
                        
                        accountWrapper.profileName = programInstance.Portfolio__r.Profile_Name__c;
                    }
                    if (isClientEmail) {
                        
                        accountWrapper.lastname = programInstance.nu_dse__Account__r.LastName;
                        accountWrapper.firstname = programInstance.nu_dse__Account__r.FirstName;
                        accountWrapper.email = programInstance.nu_dse__Account__r.PersonEmail;
                        accountWrapper.dob = programInstance.nu_dse__Account__r.PersonBirthdate;
                        accountWrapper.accountPhone = programInstance.nu_dse__Account__r.Phone; 
                        accountWrapper.isClient = true;
                        
                    }                
                }
                return accountWrapper;
            }
        } catch (Exception ex) {
            
            throw new AuraHandledException(ex.getMessage());   
        }    
        return accountWrapper;
    }
    
    @AuraEnabled
    public static defaultWrapper getdefault(String parsedAccountId, Boolean isClientEmail) {
        
        defaultWrapper defaultWrapper = new defaultWrapper();
        
        List<User> userList = [SELECT Id, Name FROM User WHERE id =: userInfo.getUserId() AND IsPortalEnabled = True ];
        if (userList != null && userList.isEmpty() == False) {
            
            defaultWrapper.userInstance = userList[0];
        } else if (String.isNotBlank(parsedAccountId)) {
            
            defaultWrapper.accountWrapper  = getAccountInfo(parsedAccountId, isClientEmail);
        }
        return  defaultWrapper;
    }
    @AuraEnabled
    public static AccountWrapper findTheRelatedAccount(String email ,String dob, String ssn, String domain, String portfolioName) {
        
         try {
            
            system.debug('*****');
            Organization companyInfo = SFSPortal_Utility.getOrgInfo();
            AccountWrapper acctWrapper = new AccountWrapper();
            Date birthday;
            String errorMessage = '';
            
            if (String.isNotBlank(dob)) {
        
                birthday = Date.ValueOf(dob);
            }
            if (String.isBlank(email)) {
                
                errorMessage += 'Email is required. <br/>';
            }
            if (birthday == null) {
                        
                errorMessage += 'Date Of Birth is required. <br/>';
            }
            if ((ssn == null || String.isBlank(ssn))) {
            
                errorMessage += 'Last 4 digit of SSN is required. <br/>';  
            }
            if (String.isNotBlank(ssn) && ssn.length() <= 3) {
                
                errorMessage += 'Last 4 digit of SSN must be 4 digits. <br/>';  
            }
            
            system.debug('*****errorMessage'+errorMessage);
            if (String.isNotBlank(errorMessage)) {
                
                throw new CustomException(errorMessage);
            }   
            if (String.isNotBlank(ssn)) {
            
                ssn = '*****'+ssn;
            } 
            
            system.debug('*****birthday '+birthday);
            
            system.debug('*****ssn '+ssn);
                        
            Map<String, Portal_Settings__c> mobileDoimainWithPortalSettingMap = new Map<String, Portal_Settings__c>();
            
            if (String.isNotBlank(domain)) {
                
                Id mobileAppInfoId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Mobile Domain Info');
                
                if (companyInfo.IsSandbox == TRUE && String.isNotBlank(portfolioName)) {
                    
                    portfolioName = portfolioName.replace('+', ' ');
                }
 
                for (Portal_Settings__c portalSetting : [SELECT Id, Mobile_Domain_URL__c, Portfolio_Group__c, Mobile_App_Name__c 
                                                         FROM Portal_Settings__c 
                                                         WHERE Mobile_Domain_URL__c = :domain AND Is_Active__c = TRUE 
                                                         AND recordTypeId =: mobileAppInfoId ORDER BY Lastmodifieddate DESC]) { 
                    
                    mobileDoimainWithPortalSettingMap.put(portalSetting.Mobile_Domain_URL__c, portalSetting );
                }
            }
            
            
            if (birthday != null && ssn != null && String.isNotBlank(ssn)) {
                
                Boolean isAccountFound = FALSE;
                for(nu_dse__Program__c programInstance : [SELECT Id, Portfolio__c, Portfolio__r.Name, Portfolio__r.Domain_URL__c, Portfolio__r.Support_Phone_Number__c, 
                    Portfolio__r.Support_Email__c, Portfolio__r.Profile_Name__c, nu_dse__Program_Status__c, nu_dse__Account__c, nu_dse__Account__r.IsCustomerPortal,
                    nu_dse__Account__r.FirstName, nu_dse__Account__r.LastName, nu_dse__Account__r.PersonBirthdate, nu_dse__Account__r.Phone, 
                    nu_dse__Account__r.SSN_last_4__c, nu_dse__Account__r.PersonEmail, nu_dse__Account__r.Personmailingcountry, 
                    nu_dse__Account__r.PersonMailingStreet, nu_dse__Account__r.PersonMailingCity, nu_dse__Account__r.PersonMailingPostalCode, 
                    nu_dse__Account__r.PersonMailingState
                    FROM nu_dse__Program__c 
                    WHERE nu_dse__Account__r.PersonBirthdate =: birthday AND nu_dse__Account__r.SSN_last_4__c =: ssn AND nu_dse__Account__r.PersonEmail =: email  
                    ORDER BY LastModifiedDate DESC 
                ]) {
                
                    isAccountFound = TRUE;
                    
                    if(String.isNotBlank(domain) && (domain == programInstance.Portfolio__r.Domain_URL__c ||
                         (mobileDoimainWithPortalSettingMap.isEmpty() == False && mobileDoimainWithPortalSettingMap.containsKey(domain) 
                             && (mobileDoimainWithPortalSettingMap.get(domain).Portfolio_Group__c != null 
                             && mobileDoimainWithPortalSettingMap.get(domain).Portfolio_Group__c.contains(programInstance.Portfolio__r.Name) 
                             && (companyInfo.IsSandbox == FALSE || (companyInfo.IsSandbox == TRUE && mobileDoimainWithPortalSettingMap.get(domain).Mobile_App_Name__c != null 
                                   && mobileDoimainWithPortalSettingMap.get(domain).Mobile_App_Name__c == portfolioName)))))) {
                    
                        if(programInstance.nu_dse__Account__r.IsCustomerPortal) {
                            
                            throw new CustomException('You have already registered to the portal, please login.');
                        }
                        
                        if (programInstance.nu_dse__Program_Status__c == 'Client Cancelled' || programInstance.nu_dse__Program_Status__c == 'Graduated Program'
                            || programInstance.nu_dse__Program_Status__c == 'Completed Program' || programInstance.nu_dse__Program_Status__c == 'Not Qualified') {
                            
                            throw new CustomException('You dont have access to portal. Please contact customer service.');
                        }
                        
                        acctWrapper.accountId = programInstance.nu_dse__Account__r.Id;
                        acctWrapper.lastname = programInstance.nu_dse__Account__r.LastName;
                        acctWrapper.firstname = programInstance.nu_dse__Account__r.FirstName;
                        acctWrapper.email = programInstance.nu_dse__Account__r.PersonEmail;
                        acctWrapper.dob = programInstance.nu_dse__Account__r.PersonBirthdate;
                        acctWrapper.accountPhone = programInstance.nu_dse__Account__r.Phone; 
                        acctWrapper.isClient = true;
                        acctWrapper.supportNumber = programInstance.Portfolio__r.Support_Phone_Number__c;
                        acctWrapper.supportEmail = programInstance.Portfolio__r.Support_Email__c;
                        acctWrapper.profileName = programInstance.Portfolio__r.Profile_Name__c;
                        acctWrapper.programId = programInstance.Id;
                        acctWrapper.country = programInstance.nu_dse__Account__r.Personmailingcountry != null ? programInstance.nu_dse__Account__r.Personmailingcountry : '';
                        acctWrapper.street = programInstance.nu_dse__Account__r.PersonMailingStreet != null ? programInstance.nu_dse__Account__r.PersonMailingStreet : '';
                        acctWrapper.city = programInstance.nu_dse__Account__r.PersonMailingCity != null ? programInstance.nu_dse__Account__r.PersonMailingCity : '';
                        acctWrapper.postalCode = programInstance.nu_dse__Account__r.PersonMailingPostalCode != null ? programInstance.nu_dse__Account__r.PersonMailingPostalCode : '';
                        acctWrapper.state = programInstance.nu_dse__Account__r.PersonMailingState != null ? programInstance.nu_dse__Account__r.PersonMailingState : '';
                        return acctWrapper;
                    } 
                }
                
                if(isAccountFound == FALSE) {
                
                    throw new CustomException('We cannot locate the record based on the information.');
                } else if(acctWrapper.accountId == null) {
                    
                    throw new CustomException('Navigate to right portal to register your account.');
                }
                
            }
        } catch(Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        } 
        
        return null;
    }
    
    @AuraEnabled
    public static String selfRegister (String password, String confirmPassword, String username, String accountWrapper, String startUrl, String regConfirmUrl) {
       
        String domainStartUrl = startUrl;
        System.debug('====>DomainUrl'+domainStartUrl);
        Savepoint sp = null;
        
        Map<Integer, String> sourceMap = new Map<Integer, String>{1 => 'Email Announcements', 2 => 'Email Newsletter', 3 => 'Text',
            4 => 'Portal Link'
        };
        Map<Integer, String> sourceMap2fa = new Map<Integer, String>{
            4 => 'Portal Link'
        };
        try {
        
            sp = Database.setSavepoint();
            Map<String, Account> accountMap = new Map<String, Account>();
            Id accountId;
            String errorMessage = '';
            
            AccountWrapper accWrapper = (AccountWrapper)JSON.deserialize(accountWrapper, AccountWrapper.class);
            
            if (String.isBlank(password)) {
            
                errorMessage += 'password is required. <br/>';
            }
            if (String.isBlank(confirmPassword)) {
                        
                errorMessage += 'Confirm Password is required. <br/>';
            }
            if (String.isBlank(username)) {
                        
                errorMessage += 'Username is required. <br/>';
            }
            if (String.isNotBlank(errorMessage)) {
                
                throw new CustomException(errorMessage);
            }   
            if (!isValidPassword(password, confirmPassword)) {
                        
                throw new CustomException(Label.site.passwords_dont_match); 
            }
                
            accountId = accWrapper.accountId;
                 
            if (String.isBlank(errorMessage)) {
                
                User userInstance = new User();
                if (accWrapper.profileName != null) {
                    
                    List<Profile> profileList = [SELECT Id FROM Profile WHERE Name =: accWrapper.profileName  ];
                    if (profileList != null && profileList.isEmpty() == False ) {
                        
                        userInstance.ProfileId = profileList[0].Id;
                    }
                }
                
                System.debug('**** accWrapper-->' + accWrapper);
                
                userInstance.Username = username;
                userInstance.put('Email',accWrapper.email);
                userInstance.FirstName = accWrapper.firstname;
                userInstance.LastName = accWrapper.lastname;
                userInstance.MobilePhone = accWrapper.accountPhone;
                userInstance.Street = accWrapper.street;
                userInstance.City = accWrapper.city ;
                userInstance.State = accWrapper.state ;
                userInstance.PostalCode = accWrapper.postalCode ;
                userInstance.Country = accWrapper.country ;
                
                String networkId = Network.getNetworkId();
                
                if(String.isNotBlank(accWrapper.sourceType) == TRUE) {
                
                    Integer userSource = Integer.valueOf(accWrapper.sourceType);
                    if(sourceMap.containsKey(userSource) == TRUE) {
                    
                        userInstance.Source_Type__c = sourceMap.get(userSource);
                    }
                }
                if (String.isNotBlank(accWrapper.campaignId) == TRUE) {
                    
                    userInstance.Campaign_Id__c = accWrapper.campaignId;
                }
                system.debug('New User---->'+userInstance.Source_Type__c);
                
                // If using site to host the community the user should not hit s1 after logging in from mobile.
                if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                    userInstance.put('UserPreferencesHideS1BrowserUI',true);
                }
                
                String nickname = ((accWrapper.firstname != null && accWrapper.firstname.length() > 0) ? accWrapper.firstname.substring(0,1) : '' ) + accWrapper.lastname.substring(0,1);
                nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                userInstance.put('CommunityNickname', nickname);
                
                //validate password
                validatePassword(userInstance, password, confirmPassword); 
                
                system.debug('New User---->'+userInstance);
                system.debug('accountId---->'+accountId);
                // lastName is a required field on user, but if it isn't specified, we'll default it to the username
                String userId = Site.createExternalUser(userInstance, accountId, password);
                // create a fake userId for test.
                if (Test.isRunningTest()) { 
                
                    userId = 'fakeUserId';           
                }
                if (userId != null) { 
                    
                    if (accWrapper != null && String.isNotBlank(accWrapper.programId)) {
                        
                        nu_dse__Program__c program = new nu_dse__Program__c(Id = accWrapper.programId);
                        //program.put(accWrapper.isClient ? 'Client_Portal_User_Id__c' : 'Co_Client_Portal_User_Id__c' , userId);
                        program.Client_Portal_User_Id__c = userId;
                        update program;
                    } 
                   //new code for 2fa
                    if(String.isNotBlank(accWrapper.sourceType) == TRUE) {
                        
                        Integer userSource2fa = Integer.valueOf(accWrapper.sourceType);
                        
                        if (password != null && password.length() > 1) {
                            startUrl = '/apex/LoginFlow2FAPage';
                            if(sourceMap2fa.containsKey(userSource2fa) == TRUE){
                                ApexPages.PageReference lgn = Site.login(Username, password, startUrl);  
                                lgn.getParameters().put('directLogin' , 'directLogin') ;
                                if (!Test.isRunningTest()) {
                                    aura.redirect(lgn);
                                }
                            }else{
                                ApexPages.PageReference lgn = Site.login(Username, password, domainStartUrl); 
                                lgn.getParameters().put('directLogin' , 'directLogin') ;
                                if (!Test.isRunningTest()) {
                                    aura.redirect(lgn);
                                }
                            }
                        }
                    } else {
                        
                        ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                        if (!Test.isRunningTest()) {
                            
                            aura.redirect(confirmRef);
                        }
                    }       
                }          
            }
        } catch (Exception e) {
            
            Database.rollback(sp);
            system.debug('e--->'+e.getMessage());
            
            System.debug('***** e.getMessage()-->' + e.getMessage());
            
            String exceptionMessage = e.getMessage();
            if(String.isNotBlank(exceptionMessage) == TRUE && exceptionMessage.contains('User already exists') == TRUE) {
                
                exceptionMessage = 'Username already exists, we were unable to register you at this time.Please contact support team.';
            }
            
            throw new AuraHandledException(exceptionMessage);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, Object> fieldDetail = new Map<String, Object>();
                fieldDetail.put('dbRequired', f.getDBRequired());
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', f.getRequired());
                fieldDetail.put('type', f.getType());
                fieldDetail.put('value', '');   // client will populate
                extraFields.add(fieldDetail);
            }}}
        return extraFields;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }  
    
    public class defaultWrapper {
        
        @AuraEnabled
        public User userInstance;
        
        @AuraEnabled
        public AccountWrapper accountWrapper;
    }
   
   
    public class ContactWrapper {
        
        @AuraEnabled
        public String firstName;
        
        @AuraEnabled
        public String lastName;
        
        @AuraEnabled
        public String email;
    } 
    
    public class AccountWrapper {
        
        @AuraEnabled
        public String firstName;
        
        @AuraEnabled
        public String lastName;
        
        @AuraEnabled
        public String email;
        
        @AuraEnabled
        public Date dob;
        
        @AuraEnabled
        public String country;
        
        @AuraEnabled
        public String state;
        
        @AuraEnabled
        public String city;
        
        @AuraEnabled
        public String street;
        
        @AuraEnabled
        public String postalCode;
        
        @AuraEnabled
        public String ssn;
        
        @AuraEnabled
        public String supportEmail;
       
        @AuraEnabled
        public String supportNumber;
        
        @AuraEnabled
        public String accountId;
        
        @AuraEnabled
        public String profileName;
        
        @AuraEnabled
        public String programId;
        
        @AuraEnabled
        public Boolean isClient;
        
        @AuraEnabled
        public String userName;
        
        @AuraEnabled
        public String sourceType;
        
        @AuraEnabled
        public String campaignId;
        
        @AuraEnabled
        public String accountPhone;
    } 
}