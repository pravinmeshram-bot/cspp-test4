global class SFSPortal_LightningForgotPasswordCtrl {

    public SFSPortal_LightningForgotPasswordCtrl() {

    }

    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        System.debug('**** forgot password');
        try {
            
            if(String.isNotBlank(username) == TRUE) {
            
                List<User> userList = [SELECT Id, Name FROM User WHERE Username = :username AND isActive = TRUE];
                
                if(userList.isEmpty() == FALSE) {
                
                    Site.forgotPassword(username); //, 'Communities_Forgot_Password_Email'
                    ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                    if(!Site.isValidUsername(username)) {
                        return Label.Site.invalid_email;
                    }
                    
                    if(String.isNotBlank(Site.getErrorMessage()) == TRUE) {
                    
                        return Site.getErrorMessage();
                    }
                    
                    //aura.redirect(checkEmailRef);
                    return null;
                } else {
                
                    throw new CustomException('Invalid username');
                }
            } else {
            
                throw new CustomException('Username cannot be blank');
            }
        }
        catch (Exception ex) {
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_LightningLoginFormController.login', 
                null, ex.getMessage(), ex.getStackTraceString()
            );
            */
            return ex.getMessage();
        }
    }
    //Added by Haarati to check if user has access to use forgot password functionality 
    @AuraEnabled
    public static String checkUserAccess(String username, String domain, String portfolioName, String checkEmailUrl) {
        
        try {
        
            if (String.isNotBlank(username) &&  String.isNotBlank(domain)) {
                
                Id accountId;
                Organization companyInfo = SFSPortal_Utility.getOrgInfo();
                List<User> userList = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE username =:username AND ContactId != null AND Contact.AccountId != null ORDER BY LastModifiedDate DESC LIMIT 1];
                
                if (userList != null && userList.isEmpty() == False) {
                    accountId = userList[0].Contact.AccountId;
            
                    System.debug('domain '+ domain);
                    Account acc =  [SELECT Portfolio_Name__c from Account Where id =: accountId];
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c,Portfolio__r.Name, Portfolio__r.Domain_URL__c, nu_dse__Program_Status__c
                                                            FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__c =:accountId AND Portfolio__c != null AND Portfolio__r.Domain_URL__c != null 
                                                            ORDER BY LastModifiedDate DESC LIMIT 1];
                    system.debug('programList--->'+programList);
                    if (programList != null && programList.isEmpty() == False) {
                    
                        Id mobileAppInfoId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Mobile Domain Info');
                        String query = 'SELECT Id, Mobile_Domain_URL__c, Portfolio_Group__c, Mobile_App_Name__c FROM Portal_Settings__c '
                                        + ' WHERE RecordTypeId =: mobileAppInfoId AND Is_Active__c = TRUE';
                        
                        if(companyInfo.IsSandbox == TRUE && String.isNotBlank(portfolioName) ) {
                        
                            query += ' AND Mobile_App_Name__c = :portfolioName AND Mobile_Domain_URL__c =: domain ';
                        } else {
                        
                            query += ' AND Mobile_Domain_URL__c = :domain ';
                        }
                        List<Portal_Settings__c> mobilePortalSettingsList = Database.query(query+' ORDER BY Lastmodifieddate DESC LIMIT 1');
                        /*                        
                        // check eligibility to login from this domain
                         list<string> chosenPortfolioList=new list<string>();
                         list<Portal_Settings__c> mobilePortalSettingsList = [SELECT Id, Mobile_Domain_URL__c, Portfolio_Group__c
                                                                   FROM Portal_Settings__c 
                                                                   WHERE RecordTypeId = :SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Mobile Domain Info') AND 
                                                                   Mobile_Domain_URL__c=:domain 
                                                                   ORDER BY createdDate DESC]; 
                       System.debug('mobilePortalSettings--->'+mobilePortalSettingsList + 'portfolio domain:' +programList[0].Portfolio__r.Domain_URL__c );
                        
                        if (mobilePortalSettingsList != null && !mobilePortalSettingsList.isEmpty())
                               {
                                 chosenPortfolioList = mobilePortalSettingsList[0].Portfolio_Group__c.split(';');
                                 System.debug('chosenPortfolioList--->'+chosenPortfolioList +' domain-->'+domain );
                                }
                        */
                        if (programList[0].Portfolio__r.Domain_URL__c == domain || (mobilePortalSettingsList != null && mobilePortalSettingsList.isEMpty() == False && 
                                mobilePortalSettingsList[0].Portfolio_Group__c != null && mobilePortalSettingsList[0].Portfolio_Group__c.contains(programList[0].Portfolio__r.Name))) {
                            
                            Site.forgotPassword(username); 
                            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                            if (!Site.isValidUsername(username)) {
                            
                                return Label.Site.invalid_email;
                            }
                            
                            if (String.isNotBlank(Site.getErrorMessage()) == TRUE) {
                            
                                return Site.getErrorMessage();
                            }
                           
                        } else {                        
                            return 'No access to this domain';
                        }
                   }
                } else {
                
                    throw new CustomException('Invalid username');
                }
            } else if (String.isNotBlank(username) == TRUE) {
                
                throw new CustomException('Username cannot be blank');
            }
        } catch (Exception ex) {
          
            return ex.getMessage();
        }
        return null;
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
}