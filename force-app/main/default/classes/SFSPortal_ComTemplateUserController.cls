public class SFSPortal_ComTemplateUserController {
    
    /* Date : 11-13-2019
* Description : Get Set variables for the maintenace page
* Invoked From : InMaintenance Page
*/
   
    
    public Portfolio__c portfolioInstance {get; set;}
    
    public Portfolio__c portfolioInstance_Email {get; set;}
    
    public String documentURL {get; set;}
    
    public Portal_Settings__c uiInstance {get; set;}
    
    public Map<String, String> imageURLMap {get; set;}
    
    public String userEmailInstance {get; set;}
    
    public Id programId {get;set;}
    
    public Id contactId {get; set;}
    
    public static Id accId {get;set;}
    
    public String orgEmail {get; set;}
    
    public User u{get; set;}
    
    public List<OrgWideEmailAddress> oweaList{get;set;}
    
    public List<Portal_Settings__c> latestNewsList {get; set;}
    
    public List<Portal_Settings__c> footerLinkList {get; set;}
    
    public String passwordString {get; set;}
    public String confirmPasswordString {get; set;}
    public String exceptionText {get; set;}
    
    
    public void populatePortfolioInstance() {
        
        try {
            
            Organization orgInfo = SFSPortal_Utility.getOrgInfo();
            
            this.imageURLMap = new Map<String, String>{'backgroundImageURL' => '', 'companyLogoURL' => '', 'headerbackgroundImage' => '', 'menuBackgroundImage' => ''};                    
                    
                    Id portfolioId;
                    String portfolioQueryString = '', latestNewsQuery = '', portfolioURL = '';
                    
                        Map<String, Id> userAndAccountMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                        
                        System.debug('**** userAndAccountMap-->'+ userAndAccountMap);
                        
                        if(userAndAccountMap != null && userAndAccountMap.containsKey('primaryAccountId') == TRUE) {
                            
                            List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c, nu_dse__Account__r.PersonEmail,Portfolio__r.OWD_Email_Name__c FROM nu_dse__Program__c WHERE nu_dse__Account__c = :userAndAccountMap.get('primaryAccountId')];
                            
                            if(programList.isEmpty() == FALSE) {
                                portfolioId = programList[0].Portfolio__c;
                            
                                userEmailInstance = programList[0].nu_dse__Account__r.PersonEmail;
                                
                                programId = programList[0].Id;
                                
                                accId = programList[0].nu_dse__Account__r.Id;
                                
                                u = [select id, accountId, contactId from User where accountId =: accId];
                                
                                orgEmail = programList[0].Portfolio__r.OWD_Email_Name__c;
                                
                                oweaList = [select Id, IsAllowAllProfiles, DisplayName, Address FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE AND DisplayName =:orgEmail LIMIT 1];
                                
                                List<Portfolio__c> portfolioList = [SELECT Id, Name, Address__c, City__c, Dispay_Name__c, Domain_URL__c, State__c, 
                                                                    Support_Email__c, Support_Fax_Number__c, Support_Phone_Number__c, Website__c, Zipcode__c, Logo_Document_Name__c
                                                                    FROM Portfolio__c
                                                                    WHERE Id =:programList[0].Portfolio__c
                                                                   ];
                                
                                System.debug('**** portfolioList-->' + portfolioList);
                                
                                if(portfolioList.isEmpty() == FALSE) {
                                    
                                    this.portfolioInstance_Email = portfolioList[0];
                                    system.debug('----->portfolioInstance_Email'+portfolioInstance_Email);
                                    if(String.isNotBlank(portfolioList[0].Logo_Document_Name__c) == TRUE) {
                                        
                                        List<Document> documentList = [SELECT Id, Name FROM Document WHERE DeveloperName = :portfolioList[0].Logo_Document_Name__c];
                                        
                                        if(documentList.isEmpty() == FALSE) {
                                            
                                            this.documentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentList[0].Id + '&oid=' + UserInfo.getOrganizationId(); 
                                        }
                                    }
                                }
                            }
                          
                            //
                            
                            if(programList.isEmpty() == FALSE) {
                                
                                portfolioQueryString += ' Id = :portfolioId ';
                                latestNewsQuery += ' AND Portfolio__c = :portfolioId ';
                            }
                        }
                        
                  
                        
                        SYstem.debug('**** url from-->' + URL.getSalesforceBaseUrl().toExternalForm());
                        
                        /* Checking sandbox or production and invoking portfolio querying logic based on param */
                        if(orgInfo.IsSandbox == TRUE) {
                            
                            portfolioURL = ApexPages.currentPage().getParameters().get('portfolio');
                            portfolioQueryString += ' Name = :portfolioURL ';
                            latestNewsQuery += ' AND Portfolio__r.Name = :portfolioURL ';
                        } else {
                            
                            portfolioURL = URL.getSalesforceBaseUrl().toExternalForm();
                            portfolioQueryString += ' Domain_URL__c = :portfolioURL ';
                            latestNewsQuery += ' AND Portfolio__r.Domain_URL__c = :portfolioURL ';
                        }
                    
                    
                    System.debug('**** portfolioQueryString-->' + portfolioQueryString);
                    
                    System.debug('**** latestNewsQuery-->' + latestNewsQuery);
                    
                    if(String.isNotBlank(portfolioQueryString) == TRUE && String.isNotBlank(latestNewsQuery) == TRUE) {
                        
                        List<Portfolio__c> portfolioList = Database.query('SELECT Id, Name, Domain_URL__c, Dispay_Name__c, Address__c, City__c, State__c, '
                                                                          + 'Zipcode__c, Support_Fax_Number__c, Support_Email__c, Support_Phone_Number__c, Website__c, OWD_Email_Name__c, '
                                                                          + 'Logo_Document_Name__c, About_Us__c, Blog__c, Debt_Relief_Options__c, FAQ__c, Footer_Contact_Content__c, Footer_Name__c, '
                                                                          + 'Footer_Portfolio_Content__c, Press__c, Submit_Feedback__c, Terms_of_Use__c, Contact_Us__c, Privacy_Policy__c, Business_Hours__c, Facebook_URL__c, Linkedin_URL__c ' 
                                                                          + 'FROM Portfolio__c WHERE '  + portfolioQueryString
                                                                         );
                        
                        if(portfolioList.isEmpty() == FALSE) {
                            
                            this.portfolioInstance = portfolioList[0];
                            
                            SFSPortal_DashboardMetricsController.CustomUIWrapper wrapper = SFSPortal_DashboardMetricsController.getCustomPortalUIValues(portfolioList[0].Domain_URL__c, portfolioURL);
                            
                            System.debug('**** wrapper-->' + wrapper);
                            
                            this.uiInstance = wrapper.uiInstance;
                            
                            
                            this.imageURLMap.put('companyLogoURL', wrapper.companyLogoURL != null ? wrapper.companyLogoURL : '');
                            this.imageURLMap.put('backgroundImageURL', wrapper.backgroundImageURL != null ? wrapper.backgroundImageURL : '');
                            this.imageURLMap.put('headerbackgroundImage', wrapper.headerbackgroundImage != null ? wrapper.headerbackgroundImage : '');
                            this.imageURLMap.put('menuBackgroundImage', wrapper.menuBackgroundImage != null ? wrapper.menuBackgroundImage : '');
                            
                           
                        }
                    }
                
        } catch(Exception e) {
            
            this.exceptionText = e.getMessage();
            //throw new CustomException(e.getMessage());
        }
    }
    
    public PageReference changeUsername() {
        
        this.exceptionText = '';
        try {
                    //Update Username Notification Email
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    if (oweaList != null && oweaList.isEmpty()==false) {
                        message.setOrgWideEmailAddressId(oweaList[0].Id);
                        System.debug('OrgWideEmailAddress@@@'+oweaList[0].Id);
                    } 
                        message.toAddresses = new String[] {userEmailInstance};
                        message.subject = 'Your Username is updated';
                      
                        String body='';
                        body += '<body><html>';
                        body += '</br> </br>' + 'Hello,<br />'; 
                        body += '</br> </br>' + u.Username + ' '; 
                        body += '<br /><br />As requested, your password for the' + ' ' +portfolioInstance_Email.Dispay_Name__c + ' ' + 'Client Portal has been changed.<br />';
                        body += '<br /><br /> Do not reply to this message. If you need additional assistance or did not make this request, please';
                        body += '<br />contact us at' + ' ' + portfolioInstance_Email.Support_Phone_Number__c+'.';
                        body += '<br/><br/><br/><br/>';
                        body += 'Thank You,<br/><br/>'; 
                        body += portfolioInstance_Email.Dispay_Name__c + ' ' + 'Client Services';  
                        body += '<br />  <img src=" ' + documentURL + '" style="width:11rem !important;height:6rem !important;" alt="No Image Available"/>';
                        body += '<br />' + portfolioInstance_Email.Dispay_Name__c + ' ';
                        body += '<br />' + portfolioInstance_Email.Address__c + ' ';
                        body += '<br />'+portfolioInstance_Email.City__c + ',' + portfolioInstance_Email.State__c + ' ' + portfolioInstance_Email.Zipcode__c + ' ';
                        body += '<br /> Toll Free Number:' + portfolioInstance_Email.Support_Phone_Number__c + ' ';
                        body += '<br /> Fax:' + portfolioInstance_Email.Support_Fax_Number__c + ' '; 
                        body += '<br /> <a href="' + portfolioInstance_Email.Support_Email__c + '">' + portfolioInstance_Email.Support_Email__c + ' </a>' ;
                        body += '<br /> <a href="' + portfolioInstance_Email.Website__c + '">' + portfolioInstance_Email.Website__c + '</a>';
                        body +=  '</body></html>';
                        
                        message.setHtmlBody(body);
                        Messaging.SingleEmailMessage[] messages = 
                            new List<Messaging.SingleEmailMessage> {message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        if (results[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: '
                                         + results[0].errors[0].message);
                        }
                    
        } catch(Exception e) {
            
            System.debug('**** message' + e.getMessage());
            this.exceptionText = e.getMessage();
        }
        
        return null;
    }

}