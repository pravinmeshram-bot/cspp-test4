/* Date : 22-10-2018
 * Author : Team IDev
 * Description : Handles to update the offer status
 */
public with sharing class SFSPortal_OfferListController {
    
    /* Date : 22-10-2018
     * Description : Method to get Offer Info of the current user
     * Invoked From : doInit Method in approvalDetail lightning component 
     */
    @AuraEnabled
    public static DefaultWrapper getOfferInfo(String offerId) {
    
        DefaultWrapper defaultWrap = new DefaultWrapper();
        for(Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Offer__c.fieldSets.Pending_Approval_Detail_View.getFields()) {
            
            defaultWrap.detailFields.add(fieldMember.getFieldPath());
        }
        defaultWrap.offerList = [SELECT Id, Name, Is_Terms_Conditions_Checked__c, nu_dse__Program__r.Portfolio__r.Offer_Disclaimer__c, 
                                 Tradeline_Litigation_Status__c, Source_of_Payment__c 
                                 FROM nu_dse__Offer__c WHERE Id =:offerId];
        
        return defaultWrap;
    }
    
    
    /* Date : 22-10-2018
     * Description : Method to get Offer Info of the current user
     * Invoked From : doInit Method in offerList lightning component 
     */
    @AuraEnabled
    public static DefaultWrapper getOfferList(Boolean isDefault) {
        
        List<String> listViewFields = new List<String>();
        
        DefaultWrapper defaultWrap = new DefaultWrapper();
        defaultWrap.isOfferListVisible = FeatureManagement.checkPermission('Offer_List');
        defaultWrap.isOfferDecision = FeatureManagement.checkPermission('Offer_Decision');
        
        if (defaultWrap.isOfferListVisible == true || Test.isRunningTest()) {
        
            Map<String, Schema.SObjectField> fieldMap = nu_dse__Offer__c.sObjectType.getDescribe().fields.getMap();       
    
            Id accountId;
            
            for (Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Offer__c.fieldSets.Pending_Approval_Detail_View.getFields()) {
                
                defaultWrap.detailFields.add(fieldMember.getFieldPath());
            }
                       
            for (Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Offer__c.fieldSets.Pending_Approvals_List_View.getFields()) {
                
                
                Schema.DescribeFieldResult child = fieldMap.get(fieldMember.getFieldPath()).getDescribe();
                String relationName = child.getRelationshipName();
                
                if((String.valueOf(fieldMember.getType())).toLowercase() == 'reference') {
                
                    defaultWrap.listFields.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),relationName));
                    listViewFields.add(relationName +'.Name');
                    
                } else {
                    defaultWrap.listFields.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),''));
                    listViewFields.add(fieldMember.getFieldPath());
                }
            }
            
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            
            if (accountIdMap != null && accountIdMap.isEmpty() == False) {            
                
                if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                    
                    accountId = accountIdMap.get('primaryAccountId');
                    
                    if (accountId != null && listViewFields.isEmpty() == False) {
                        
                        List<nu_dse__Program__c> programList = [SELECT Id, Name, Portfolio__c, Portfolio__r.Support_Phone_Number__c, Portfolio__r.Dispay_Name__c
                                                                FROM nu_dse__Program__c WHERE nu_dse__Account__c =:accountId AND Portfolio__c != null ];
                                                                
                        if (programList != null && programList.isEmpty() == False) {
                            
                            defaultWrap.program = programList[0];
                        }
                        String query = 'SELECT Id, Name, Available_for_Client_Review__c, Original_Balance__c, nu_dse__Offer_Amount__c, nu_dse__First_Payment_Date__c, '
                                        + 'SFSPortal_Original_Creditor__c, Current_Balance__c, Tradeline_Litigation_Status__c, Source_of_Payment__c, Created_Date_Time__c ';
                                        
                        for (String field : listViewFields) {
                            
                            if (field != 'Name' && field != 'Available_for_Client_Review__c' && field != 'Original_Balance__c' &&
                                field != 'nu_dse__Offer_Amount__c' && field != 'nu_dse__First_Payment_Date__c' && 
                                field != 'SFSPortal_Original_Creditor__c' && field != 'Current_Balance__c' &&
                                field != 'Tradeline_Litigation_Status__c' && field != 'Source_of_Payment__c') {
                                
                                query += ', '+field;
                            }
                        }
                        query += ' FROM nu_dse__Offer__c WHERE nu_dse__Program__c != null AND nu_dse__Program__r.nu_dse__Account__c != null';
                        
                        //Date nextMonthDate = System.today().addMonths(1).toStartOfMonth();
                        
                        Date next60Days = System.today().addDays(60);
                        query += ' AND nu_dse__Program__r.nu_dse__Account__c = :accountId AND Authorization_Received__c = FALSE ';
                                 // + ' AND Source_of_Payment__c = \''+'PSA'+'\' AND Tradeline_Litigation_Status__c = \''+'Non Lit'+'\' '; 
                                 // AND nu_dse__Status__c =\''+'Pending Client Approval'+'\' ';
                        
                        if (defaultWrap.program.Portfolio__r.Dispay_Name__c == 'Timberline Financial') {
                            
                            query += ' AND nu_dse__Status__c = \''+'Management Approved'+'\' ';
                        } else if (defaultWrap.program.Portfolio__r.Dispay_Name__c == 'Royal Legal Group') {
                            
                            query += ' AND nu_dse__Status__c = \''+'In-House Attorney Approved'+'\' ';
                        } else if ((defaultWrap.program.Portfolio__r.Dispay_Name__c != 'Timberline Financial') && 
                                                (defaultWrap.program.Portfolio__r.Dispay_Name__c != 'Royal Legal Group')) {
                            
                            query += ' AND nu_dse__Status__c = \''+'Pending Creditor Approval'+'\' ';
                        }
                        
                        query += ' AND CreatedDate >= TODAY ';
                        
                        for (nu_dse__Offer__c offer : Database.query (query)) {
                            
                            Integer diffDate = system.today().daysBetween(offer.nu_dse__First_Payment_Date__c);
                            
                            if (diffDate > 2 ) {
                                
                                defaultWrap.offerList.add(offer);
                            }
                        }
                        //query += '  AND nu_dse__First_Payment_Date__c >= TODAY AND nu_dse__First_Payment_Date__c <= :next60Days';
                        //query += '  AND nu_dse__First_Payment_Date__c < :nextMonthDate ';
                        //AND nu_dse__First_Payment_Date__c > TODAY
                        //defaultWrap.offerList = Database.query (query);
                        //defaultWrap.offerList = Database.query (query+ ' AND nu_dse__Program__r.nu_dse__Account__c = :accountId AND nu_dse__Status__c =\''+'Pending Client Approval'+'\'');
                    }
                }
            }
        }
        return defaultWrap;
    }
    
    /* Date : 22-10-2018
     * Description : Method to update offer status
     * Invoked From : updateStatus Method in approvalDetail lightning component 
     */
    @AuraEnabled
    public static void updateOfferStatus(nu_dse__Offer__c offerInstance) {
 
        try {
        
            if (offerInstance != null) {
                
                offerInstance.Authorization_Received__c = True;
                
                offerInstance.Authorization_Received_Date__c = System.now();
                
                offerInstance.Decision_Source__c = 'Portal';
                
                offerInstance.Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' 
                                                    + (offerInstance.nu_dse__Status__c == 'Client Approved' ? 'accepted on' : 'declined on') + String.valueOf(System.now());
                
                if(offerInstance.nu_dse__Status__c == 'Client Approved') {
                
                    //offerInstance.Decision_Source__c = 'Portal';
                    if(Test.isRunningTest() == FALSE) {
                    
                        offerInstance.Portal_User_Ip_Address__c = Auth.SessionManagement.getCurrentSession().get('SourceIp');
                    }
                }
                
                update offerInstance;
                
                List<nu_dse__Offer__c > offerListTosendEmail = [SELECT Id, Name, nu_dse__Program__c, nu_dse__Status__c, Offer_Created_By__c, 
                                                        nu_dse__Program__r.Portfolio__c, Offer_Created_By_Email__c, Offer_Created_By__r.Name
                                                        FROM nu_dse__Offer__c 
                                                        WHERE Id =: offerInstance.Id AND Offer_Created_By__c != NULL 
                                                        AND Offer_Created_By_Email__c != NULL
                                                        AND nu_dse__Program__r.Portfolio__c != NULL];
                
                system.debug('*********offerListTosendEmail'+ offerListTosendEmail);    
                
                if(offerListTosendEmail.isEmpty() == FALSE && offerListTosendEmail[0].Offer_Created_By_Email__c != null)  {
                    
                    system.debug('*********'+ offerListTosendEmail[0].Offer_Created_By_Email__c);
                    
                    List<Portfolio__c> portfolioList = [SELECT Id, Name, Domain_URL__c, Dispay_Name__c, Address__c, City__c, State__c, 
                        Zipcode__c, Support_Fax_Number__c, Support_Email__c, Support_Phone_Number__c, Website__c, OWD_Email_Name__c, 
                        Logo_Document_Name__c
                        FROM Portfolio__c WHERE Id = :offerListTosendEmail[0].nu_dse__Program__r.Portfolio__c
                    ];
                        
                    Messaging.SingleEmailMessage emailInstance = new Messaging.SingleEmailMessage();
                    Messaging.SingleEmailMessage templateBody = new Messaging.SingleEmailMessage();
                    emailInstance.setToAddresses(new String[]{offerListTosendEmail[0].Offer_Created_By_Email__c});
                    String subjectToSend = 'Client has decided on their offer via the Portal';
                    
                    if(String.isNotBlank(portfolioList[0].OWD_Email_Name__c) == TRUE) {
                               
                        Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(portfolioList[0].OWD_Email_Name__c);
                    
                        if(owdEmailId != null) {
                        
                            emailInstance.setOrgWideEmailAddressId(owdEmailId);
                        }
                    }
                    String htmlbody = 'Hello ' + offerListTosendEmail[0].Offer_Created_By__r.Name + ', <br /> <br/> '+UserInfo.getFirstName()+' has '
                               + (offerListTosendEmail[0].nu_dse__Status__c == 'Client Approved' ? 'accepted' : 'declined') +' the '+offerListTosendEmail[0].Name
                               +'. Please review the offer for further details. <br /> <br />'+ SFSPortal_Utility.getEmailSignature(portfolioList[0]);
                                
                    emailInstance.setHTMLBody(htmlbody);
                    emailInstance.setSubject(subjectToSend);
                    Messaging.SendEmailResult[] mailResultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailInstance });
                }
                /*
                                    
                    if (resetPasswordResult != null && templateBody != null) {
                        existingBody = templateBody.getHTMLBody().replace(
                            '<a class="resetLink" href="', ('<a href="' + programList[0].Portfolio__r.Domain_Url__c + '/s/login?un=' 
                                          + userInstance.UserName + '&pw=' + resetPasswordResult.getPassword())
                        );
                    }
                    emailInstance.setHTMLBody(existingBody);
                    Id owdEmailId = SFSPortal_Utility.getOrgWideEmailId(programList[0].Portfolio__r.OWD_Email_Name__c);
                    if(owdEmailId != null) {
                        emailInstance.setOrgWideEmailAddressId(owdEmailId);
                    }
                }*/
               
                
                List<nu_dse__Offer__c> offerList = [SELECT Id, nu_dse__Program__c, nu_dse__Status__c, createdById 
                                                    FROM nu_dse__Offer__c 
                                                    WHERE Id =: offerInstance.Id AND nu_dse__Status__c = 'Client Approved'];
                                                    
                if (offerList != null && offerList.isEmpty() == False) {
                    
                    Task taskInstance = new Task();
                    taskInstance.Subject = 'Client Approved';
                    taskInstance.ActivityDate = System.today().AddDays(2);
                    taskInstance.WhatId = offerList[0].Id;
                    taskInstance.CreatedById = offerList[0].createdById;
                    taskInstance.Status = 'Not Started';
                    taskInstance.priority = 'High';
                    insert taskInstance;
                    system.debug('taskInstance--->'+taskInstance);
                }
                
                List<Task> taskListToComplete = [SELECT Id FROM TASK WHERE WhatId = :offerInstance.Id
                    AND Subject = 'Obtain Client Auth' AND Status != 'Completed'
                    ORDER BY LastModifiedDate DESC LIMIT 1
                ];
                
                if(taskListToComplete.isEmpty() == FALSE) {
                    
                    taskListToComplete[0].Status = 'Completed';
                    taskListToComplete[0].Completed_By__c = Userinfo.getUserId();
                    taskListToComplete[0].Completed_Date__c = System.now();
                    System.debug('**** before update -->');
                    update taskListToComplete[0];
                    System.debug('**** after update -->');
                }
            }
        } catch(Exception e) {
            
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_OfferListController.updateOfferStatus', 
                offerInstance.Id, e.getMessage(), e.getStackTraceString()
            );
            */
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class DefaultWrapper {
        
        @AuraEnabled
        public List<String> detailFields = new List<String>();
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> listFields = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        @AuraEnabled
        public nu_dse__Program__c program = new nu_dse__Program__c();
        
        @AuraEnabled
        public Boolean isOfferListVisible = True;
        
        @AuraEnabled
        public Boolean isOfferDecision = True;
    }      
}