/* Date : 24-10-2018
 * Author : Team IDev
 */
global class SFSPortal_Utility {
    
    /* Date : 24-10-2018
    * Description : Method to get accountId from User
    */
    public static Map<String, Id> getAccountIdFromCurrentUser () {
        
        Map<String, Id> accountIdMap = new Map<String, Id>();
        List<User> userList = [SELECT Id, contactId, Name, Contact.AccountId FROM User WHERE Id =: userinfo.getUserId() AND Contact.AccountId != null LIMIT 1];
        //List<User> userList = [SELECT Id, contactId, Name, Contact.AccountId FROM User WHERE Id = '005m0000004JdwE' AND Contact.AccountId != null LIMIT 1];
        if (userList != null && userList.isEmpty() == False) {
            
            accountIdMap.put('userAccountId', userList[0].Contact.AccountId);
            accountIdMap.put('primaryAccountId', userList[0].Contact.AccountId);
            /*List<Account> accountList = [SELECT Id, Primary_Client__c FROM Account WHERE Id =: userList[0].Contact.AccountId LIMIT 1];
            if (accountList != null && accountList.isEmpty() == False) {
                
                if (accountList[0].Primary_Client__c != null) {
                    
                    accountIdMap.put('primaryAccountId', accountList[0].Primary_Client__c);
                } else {
                    
                    accountIdMap.put('primaryAccountId', accountList[0].Id);
                } 
            }*/
        }
        return accountIdMap;
    }
    
    /* Date : 24-10-2018
    * Description : Method to get recordTypeId by using object api name and record Type name
    */
    public static Id getRecordTypeId (String objectApi, String recordTypeName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectApi).getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        Id recordTypeId;
        
        if (recordTypeMap.containsKey(recordTypeName)) {
            
            recordTypeId = recordTypeMap.get(recordTypeName).getRecordTypeId();
            System.debug('**recordTypeId'+recordTypeId);
        }
        
        return recordTypeId;
    }
    
    /* Date : 03-01-2019
     * Description : Method to return the org wide email address Id
     * Params : OWD_Email_Name__c From portfolio
     */
    public static Id getOrgWideEmailId(String owdEmailName) {
        
        if(String.isNotBlank(owdEmailName) == TRUE ) {
        
            List<OrgWideEmailAddress> emailAddressList = [SELECT Id FROM OrgWideEmailAddress 
                WHERE DisplayName = :owdEmailName /* AND IsAllowAllProfiles = FALSE */
                ORDER BY LastModifiedDate DESC LIMIT 1
            ];
            
            if(emailAddressList.isEmpty() == FALSE) {
            
                return emailAddressList[0].Id;
            }
        }
        
        return null;
    }
    
    /* Date : 03-01-2019
     * Description : Method to construct the email signature
     * Params : Portfolio instance
     */
    public static String getEmailSignature(Portfolio__c portfolioInstance) {
    
        if(portfolioInstance != null) {
            
            String signature = '<br /><br /> Thank you, <br />'
                            + portfolioInstance.Dispay_Name__c + ' Client Services <br /><br />';
            
            if(String.isNotBlank(portfolioInstance.Logo_Document_Name__c) == TRUE) {
                    
                List<Document> documentList = [SELECT Id, Name FROM Document WHERE DeveloperName = :portfolioInstance.Logo_Document_Name__c];
                
                if(documentList.isEmpty() == FALSE) {
                    
                    String url = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentList[0].Id + '&oid=' + UserInfo.getOrganizationId(); 
                    
                    signature += '<br /> <img src="' + url + '" alt="No Image" style="height:8rem;width:10rem;" /> <br /><br />';
                    
                }
            }
            
           signature += portfolioInstance.Dispay_Name__c + ' <br />'
                + portfolioInstance.Address__c + ' <br /> ' 
                + portfolioInstance.City__c + ', ' + portfolioInstance.State__c + ' ' + portfolioInstance.Zipcode__c + ' <br />'
                + 'Number: ' + portfolioInstance.Support_Phone_Number__c + ' <br />' 
                + 'Fax: ' + portfolioInstance.Support_Fax_Number__c + ' <br />' 
                + '<a href="mailto:' + portfolioInstance.Support_Email__c + '">' + portfolioInstance.Support_Email__c + '</a> <br />' 
                + '<a href="' + portfolioInstance.Website__c + '">' + portfolioInstance.Website__c + '</a> <br />' 
            ;   
               
            return signature; 
        }
        return '';
    }
    
    /* Date : 03-01-2019
     * Description : Method to construct the email signature
     * Params : Portfolio instance
     */
    public static Organization getOrgInfo() {
        
        List<Organization> organizationList = [SELECT Id, Name, IsSandbox From Organization WHERE Id = :UserInfo.getOrganizationId()];
        if(organizationList.isEmpty() == FALSE) {
        
            return organizationList[0];
        }
        
        return null;
    }
    
    /*
    public static void createErrorLogs(String className, String errorRecordId, String message, String stackTrace) {
        
        
        nu_dse__Error_Log__c errorLogInstance = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = className, 
            nu_dse__Error_Causing_Record_Id__c = errorRecordId,
            nu_dse__Message__c = message,
            nu_dse__Stack_Trace__c = stackTrace,
            nu_dse__User_Context__c = UserInfo.getUserId()
        );
       
        
        insert errorLogInstance;
    }
    */
    /* Date : 01-10-2019
     * Description : Method to get Object Name based on given Id
     */
     public static String getsObjectName(Id recordId) {
        
        system.debug('recordId--->'+recordId);
        if (recordId != null) {
            
            system.debug('recordId--->'+recordId.getSObjectType().getDescribe().getName());
            return recordId.getSObjectType().getDescribe().getName();
        } else {
        
            return null;
        }
    }
    
}