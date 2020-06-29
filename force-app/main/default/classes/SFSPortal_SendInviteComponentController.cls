/* Date : 10-10-2018
 * Author : Team IDev
 * Description : Handler for Send Invite Component
 */
public class SFSPortal_SendInviteComponentController {
    public Id recordId {get; 
        set {
            
            if(recordId == null) {
                
                recordId = value;
                init();
            }
        }
    }
    
    public Boolean isClientEmail {get; set;}
    
    public String redirectionURL {get; set;}
    
    /* public Contact contactInstance {get; set;} */
    
    public String clientName {get; set;}
    
    /* Date : 26-12-2018
     * Description : Get Set variables for the welcome member email
     * Invoked From : SFSPortal_Custom_Email_Body
     */
    public String receiving_UserId {get; 
        set {
            
            if(receiving_UserId == null) {
                
                receiving_UserId = value;
                
                populatePortfolioInstance();
            }
        }
    }  
    
    
    public String emailType_Email {get; set;}
    
    public Portfolio__c portfolioInstance_Email {get; set;}
    public User userInstance_Email {get; set;}
    public String documentURL {get; set;}
    
    
   
  
    
    public void populatePortfolioInstance() {
        system.debug('=====>receiving_UserId'+this.receiving_UserId);
   	 	 system.debug('=====>emailType_Email'+this.emailType_Email);
        
        String queryString = 'SELECT Id, contactId, Name, Contact.AccountId, Email, FirstName, Username FROM User WHERE ';
                
        if(this.emailType_Email == 'Welcome' || this.emailType_Email == 'Email Update Notification') {
        System.debug('======>emailType_Email'+emailType_Email);
            queryString += ' Id = :receiving_UserId ';
            system.debug('======>receiving_UserId'+receiving_UserId);
        } else if(this.emailType_Email == 'Forgot Password' || this.emailType_Email == 'Changed Password' || this.emailType_Email == 'Lockout Email') { 
        
            queryString += ' ContactId = :receiving_UserId ';
        }
        
        List<User> userList = Database.query(queryString);
        if (userList.isEmpty() == False) {
        
            this.userInstance_Email = userList[0];
            
            List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c FROM nu_dse__Program__c WHERE nu_dse__Account__c = :userList[0].Contact.AccountId];
            
            System.debug('***** programList-->' + programList);
            
            System.debug('***** userList[0].Contact.AccountId-->' + userList[0].Contact.AccountId);
            
            if(programList.isEmpty() == FALSE) {
            
                List<Portfolio__c> portfolioList = [SELECT Id, Name, Address__c, City__c, Dispay_Name__c, Domain_URL__c, State__c, 
                    Support_Email__c, Support_Fax_Number__c, Support_Phone_Number__c, Website__c, Zipcode__c, Logo_Document_Name__c
                    FROM Portfolio__c
                    WHERE Id =:programList[0].Portfolio__c
                ];
                
                System.debug('**** portfolioList-->' + portfolioList);
                
                if(portfolioList.isEmpty() == FALSE) {
                    
                    this.portfolioInstance_Email = portfolioList[0];
                    
                    if(String.isNotBlank(portfolioList[0].Logo_Document_Name__c) == TRUE) {
                    
                        List<Document> documentList = [SELECT Id, Name FROM Document WHERE DeveloperName = :portfolioList[0].Logo_Document_Name__c];
                        
                        if(documentList.isEmpty() == FALSE) {
                            
                            this.documentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentList[0].Id + '&oid=' + UserInfo.getOrganizationId(); 
                        }
                    }
                }
            }
        }
    }
    
  
    
    public void init() {
        
        List<Contact> contactList = new List<Contact>();
        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Account__c, nu_dse__Account__r.Name, 
            nu_dse__Account__r.nu_dse__Co_First_Name__c, nu_dse__Account__r.nu_dse__Co_Last_Name__c, 
            Portfolio__c, Portfolio__r.Domain_URL__c, Portfolio__r.Logo_Document_Name__c, Portfolio__r.Dispay_Name__c, 
            Portfolio__r.Excela_Email__c, Portfolio__r.OWD_Email_Name__c, Portfolio__r.Name, Portfolio__r.Address__c, 
            Portfolio__r.City__c, Portfolio__r.State__c, Portfolio__r.Support_Email__c, Portfolio__r.Support_Fax_Number__c, 
            Portfolio__r.Support_Phone_Number__c, Portfolio__r.Website__c, Portfolio__r.Zipcode__c 
            FROM nu_dse__Program__c 
            WHERE Id =: this.recordId AND Portfolio__c != null AND nu_dse__Account__c != null
        ];
            
        if(programList.isEmpty() == FALSE) {
            
            /*
            List<Portfolio__c> portfolioList = [SELECT Id, Domain_URL__c FROM Portfolio__c WHERE Id =: programList[0].Portfolio__c];
            if (portfolioList.isEmpty() == False && portfolioList[0].Domain_URL__c != null) { */
                
                String accountId = programList[0].nu_dse__Account__c; 
                
                /*
                List<Account> accountList = [SELECT Id, Primary_Client__c FROM Account WHERE Id =:accountId AND Primary_Client__c != null LIMIT 1];
                if (accountList != null && accountList.isEmpty() == False && !isClientEmail){
                    
                    accountId = accountList[0].Primary_Client__c;
                }
                /*if (isClientEmail) {
                    
                    condition += 'AccountId = \''+programList[0].nu_dse__Account__c+'\'';
                } else {
                                        
                    if (accountList.isEmpty() == False) {
                        
                        condition += 'AccountId = \''+accountList[0].Primary_Client__c+'\'';
                    }
                }*/
                /*
                if (String.isNotBlank(accountId)) {
                    
                    contactList = Database.query('SELECT Id, Name FROM Contact WHERE AccountId = \''+accountId+'\''); 
                }          
                */   
                
                if(isClientEmail) {
                
                    this.clientName = programList[0].nu_dse__Account__r.Name;
                } else {
                
                    this.clientName = programList[0].nu_dse__Account__r.nu_dse__Co_First_Name__c + ' ' + programList[0].nu_dse__Account__r.nu_dse__Co_Last_Name__c;
                }
                
                /*if(contactList.isEmpty() == FALSE) {
                
                    this.contactInstance = contactList[0];
                    */
                    
                    //List<Network> networkList = [SELECT Id FROM Network WHERE Name = 'PioneerDashboard'];
                
                    //if(networkList.isEmpty() == FALSE) {
                        
                        String cryptoString = '0123456789ABCDEF0123456789ABCDE0';
                        
                        //Blob cryptoKey = Crypto.generateAesKey(256);
    
                        // Generate the data to be encrypted.
                        Blob contactIdBlob = Blob.valueOf(accountId); //contactList[0].Id
                        // Encrypt the data and have Salesforce.com generate the initialization vector
                        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(cryptoString), contactIdBlob);
                        
                        // Decode the decrypted data for subsequent use
                        String encryptedDataString = EncodingUtil.base64Encode(encryptedData);
                        this.redirectionURL = programList[0].Portfolio__r.Domain_URL__c+'/s/login/SelfRegister?src=1&i=' + encryptedDataString ;// + '&c=' + (isClientEmail ? '1' : '0'); //Network.getSelfRegUrl(portfolioList[0].Domain_URL__c) + '?i=' + encryptedDataString;

                        //this.redirectionURL = programList[0].Portfolio__r.Domain_URL__c+'/s/login/SelfRegister?src=1'+ '&c=' + (isClientEmail ? '1' : '0'); //Network.getSelfRegUrl(portfolioList[0].Domain_URL__c) + '?i=' + encryptedDataString;
                        /* Adding portfolio name for sandboxes */
                        Organization companyInfo = SFSPortal_Utility.getOrgInfo();
                        if(companyInfo.IsSandbox == TRUE) {
                            this.redirectionURL = programList[0].Portfolio__r.Domain_URL__c+'/s/login/SelfRegister?src=1&portfolio=' +  programList[0].Portfolio__r.Name;
                           // this.redirectionURL += '&portfolio=' +  programList[0].Portfolio__r.Name;
                            //this.redirectionURL = programList[0].Portfolio__r.Domain_URL__c+'/s/login/SelfRegister?src=1&portfolio=' +  programList[0].Portfolio__r.Name + '&i=' + encryptedDataString;
                        }

                    //}
                //}
            //}
            
            /* Signature related code */
            this.portfolioInstance_Email = programList[0].Portfolio__r;
            
            if(String.isNotBlank(programList[0].Portfolio__r.Logo_Document_Name__c) == TRUE) {
                    
                List<Document> documentList = [SELECT Id, Name FROM Document WHERE DeveloperName = :programList[0].Portfolio__r.Logo_Document_Name__c];
                
                if(documentList.isEmpty() == FALSE) {
                    
                    this.documentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentList[0].Id + '&oid=' + UserInfo.getOrganizationId(); 
                }
            }
        }
    } 
}