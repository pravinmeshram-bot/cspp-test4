/* 
    * Date : 24-10-2018
    * Author : Team IDev
    * Description : Handles to get task 
 */
public class SFSPortal_ADHOCPaymentController {
    
    /* Date : 24-10-2018
     * Description : Method to save the group task
     * Invoked From : saveGroupTask Method in ADHOCPayment,dashboardMetrics lightning component 
     */
    @AuraEnabled
    public static void saveRecord(nu_dse__Group_Task__c newGroupTaskInstance, String objectInfo) { //, nu_dse__Bank_Account__c bankInstance, String objectInfo) {
        
        system.debug('newGroupTaskInstance-->'+newGroupTaskInstance);
        system.debug('objectInfo-->'+objectInfo);
        try {
            
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            Id accountId;
            if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
                
                if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                    
                    accountId = accountIdMap.get('primaryAccountId');
                    List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Account__c, DraftVariance__c FROM nu_dse__Program__c WHERE nu_dse__Account__c =: accountId]; 
                    List<Group> groupList = [select Id from Group where Type = 'Queue' AND DeveloperName = 'Payment_Processing' LIMIT 1];

                    if(programList.isEmpty() == False && String.isNotBlank(objectInfo)) {
                        
                        if (groupList != null && groupList.isEmpty() == False) {
                        
                            newGroupTaskInstance.ownerId = groupList[0].Id;
                        }
                        newGroupTaskInstance.program__c = programList[0].Id;
                        newGroupTaskInstance.nu_dse__Related_To__c = programList[0].Id;
                        newGroupTaskInstance.nu_dse__ActivityDate__c = System.today().addDays(1);
                        newGroupTaskInstance.nu_dse__Status__c = 'Not Started';
                        
                        /* Populating Decision Source and Made By */
                        newGroupTaskInstance.Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + String.valueOf(System.now());
                        newGroupTaskInstance.Decision_Source__c = 'Portal';
                        
                        if (objectInfo == 'Payment') {                            
                            
                            newGroupTaskInstance.Send_for_E_Sign_Adhoc__c = true;
                            newGroupTaskInstance.nu_dse__Subject__c = 'Request to add additional funds';
                            newGroupTaskInstance.Subject_Picklist__c = 'Draft Amount Adjustment';
                        } else if (objectInfo == 'Bank') {
                            
                            /*bankInstance.nu_dse__Status__c = 'Inactive';
                            bankInstance.nu_dse__Program__c = programList[0].Id;
                            bankInstance.Send_for_E_Sign_Adhoc__c = true;
                            insert bankInstance;
                            */
                            
                            /*Initiating the documnt if the draft varaince is less than 5% */
                            if(programList[0].DraftVariance__c < 5) {
                            
                                newGroupTaskInstance.Send_For_E_Sign_Bank_Info__c = true;
                            }else {
                                newGroupTaskInstance.nu_dse__Description__c = 'Request from portal, generate a paper ACH and send to client';
                            }
                            newGroupTaskInstance.nu_dse__Subject__c = 'Request to update bank info';
                            newGroupTaskInstance.Subject_Picklist__c = 'Change Bank Info';
                            
                        }
                        insert newGroupTaskInstance;
                    }
                }
            }
        } catch(Exception e) {
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_ADHOCPaymentController.saveRecord', 
                null, e.getMessage() + ' while creating ' + objectInfo, e.getStackTraceString()
            );
            */
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Date : 25-10-2018
     * Description : Method to get the payments and fieldsets
     * Invoked From : doInit Method in ADHOCPayment,dashboardMetrics lightning component 
     */
    @AuraEnabled
    public static ADHOCPaymentWrapper getDefaultValue(Map<String, String> filterMap, Boolean isDoInit, Boolean isFilter) {
        
        try {
        
            ADHOCPaymentWrapper adhocPayment = new ADHOCPaymentWrapper();
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            List<String> statusFieldsToDisplay = new List<String>{'Failed','Cancelled'};
            Id accountId;
            adhocPayment.addFunds = FeatureManagement.checkPermission('Add_Funds');
            adhocPayment.addNewBankAccount = FeatureManagement.checkPermission('Add_New_Bank_Account');
            
            if(accountIdMap.isEmpty() == False) {            
                
                if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                    
                    accountId = accountIdMap.get('primaryAccountId');
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, DraftVariance__c FROM nu_dse__Program__c WHERE nu_dse__Account__c =: accountId]; 
                    
                    if (programList != null && programList.isEmpty() == False) {
                        
                        adhocPayment.draftVariancePercent = programList[0].DraftVariance__c;
                        
                        Id programId = programList[0].Id;
                        
                        system.debug('programId--->'+programId);
                        
                        if (isDoInit) {
                            
                            adhocPayment.editPaymentFieldsList.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(true,'date','Date','Ad_Hoc_Date__c',''));
                            
                            for(Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Group_Task__c.fieldSets.Adhoc_Payment_Fields.getFields()) {
                                
                                if (fieldMember.getFieldPath() != 'Ad_Hoc_Date__c') {
                                    
                                    adhocPayment.editPaymentFieldsList.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),String.valueOf(fieldMember.getType()).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),''));
                                }
                            }
                            
                            //adhocPayment.pastPaymentCount = [SELECT Count() FROM nu_dse__Payment__c WHERE nu_dse__Program__c =:programId AND nu_dse__Schedule_Date__c < TODAY];
                            
                            //adhocPayment.futurePaymentCount = [SELECT Count() FROM nu_dse__Payment__c WHERE nu_dse__Program__c =:programId AND nu_dse__Schedule_Date__c >= TODAY];
                            
                            for(Schema.PicklistEntry pickListVal : nu_dse__Payment__c.nu_dse__Transaction_Status__c.getDescribe().getPicklistValues()) {
            
                                adhocPayment.paymentStatusList.add(pickListVal.getValue());
                            }
                            
                            /*
                            // Adding static fields for bank account
                            adhocPayment.editBankInfoFieldsList = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>{
                                new SFSPortal_TradelineListController.FieldSetMemberWrapper(true, 'string', 'Account Number', 'SFSPortal_Account_Number__c', ''),
                                new SFSPortal_TradelineListController.FieldSetMemberWrapper(true, 'string', 'Re-Enter Account Number', 'SFSPortal_Re_Enter_Account_Number__c', ''),
                                new SFSPortal_TradelineListController.FieldSetMemberWrapper(true, 'string', 'Routing Number', 'SFSPortal_Routing_Number__c', '')
                            };
                            */
                            
                            for(Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Group_Task__c.fieldSets.New_Bank_Account_Request.getFields()) {
                                
                                if(fieldMember.getFieldPath() != 'SFSPortal_Account_Number__c' 
                                    && fieldMember.getFieldPath() != 'SFSPortal_Re_Enter_Account_Number__c'
                                        && fieldMember.getFieldPath() != 'SFSPortal_Routing_Number__c'
                                            && fieldMember.getFieldPath() != 'SFSPortal_Bank_Name__c') {
                                
                                    adhocPayment.editBankInfoFieldsList.add(
                                        new SFSPortal_TradelineListController.FieldSetMemberWrapper(
                                            fieldMember.getRequired() || fieldMember.getDbRequired(),
                                            String.valueOf(fieldMember.getType()).toLowercase(),
                                            fieldMember.getLabel(),fieldMember.getFieldPath(), ''
                                        )
                                    );
                                }
                            }
                            
                            List<nu_dse__Bank_Account__c> bankAccountList = [SELECT ID FROM nu_dse__Bank_Account__c WHERE nu_dse__Program__c =:programId /* AND nu_dse__Status__c = 'Active' */];
                            if (bankAccountList != null && bankAccountList.isEmpty() == False) {
                                
                                adhocPayment.activeBankAccount = bankAccountList[0].Id;
                            }       
                            adhocPayment.setMinAndMaxDate = new Map<String, Date> {
                                'MinDate' => system.today().toStartofWeek().daysBetween(system.today()) == 5 ? system.today().AddDays(5) 
                                    : system.today().toStartofWeek().daysBetween(system.today()) == 6 ? system.today().AddDays(4) : system.today().AddDays(3) , 
                                'MaxDate' => system.today().AddDays(60)
                            };
                        }
                        
                        String query = 'SELECT Id';
                        Map<String, Schema.SObjectField> fieldMap = nu_dse__Payment__c.sObjectType.getDescribe().fields.getMap();                      
                        for(Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Payment__c.fieldSets.Payment_List_View.getFields()) {
                                                            
                            Schema.DescribeFieldResult child = fieldMap.get(fieldMember.getFieldPath()).getDescribe();
                            String relationName = child.getRelationshipName();
                            if((String.valueOf(fieldMember.getType())).toLowercase() == 'reference') {
                            
                                if (isDoInit) {
                    
                                    adhocPayment.columnList.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),relationName));
                                }
                                query += ','+ relationName +'.Name'; 
                            } else {
                            
                                if (isDoInit) {
                                
                                    adhocPayment.columnList.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),''));
                                }
                                query += ',' + fieldMember.getFieldPath();
                            }    
                        }
                        //query += ' FROM nu_dse__Payment__c WHERE nu_dse__Program__c =:programId AND (nu_dse__Schedule_Date__c >= TODAY  OR nu_dse__Transaction_Status__c IN :statusFieldsToDisplay )';
                        
                        Id draftRecordTypeId = SFSPortal_Utility.getRecordTypeId('nu_dse__Payment__c', 'Draft');
                        
                        query += ' FROM nu_dse__Payment__c WHERE nu_dse__Program__c =:programId AND RecordTypeId = :draftRecordTypeId ';
                        
                        String conditionalQuery = ' ORDER BY nu_dse__Schedule_Date__c ';
                        
                        if (filterMap != null && filterMap.isEmpty() == False) {
                            
                            /*
                            if (filterMap.ContainsKey('paymentStatus') && String.isNotBlank(filterMap.get('paymentStatus'))) {
                                
                                conditionalQuery += ' AND nu_dse__Transaction_Status__c =\''+filterMap.get('paymentStatus')+'\' ';
                            }
                            if (isFilter) {
                            
                                adhocPayment.totalPaymentCount = Database.countQuery('SELECT Count() FROM nu_dse__Payment__c WHERE nu_dse__Program__c =:programId ' +conditionalQuery);
                            }
                            
                            if (filterMap.ContainsKey('offset') && String.isNotBlank(filterMap.get('offset'))) {
                            
                                conditionalQuery += ' ORDER BY nu_dse__Schedule_Date__c ASC LIMIT 20 OFFSET '+filterMap.get('offset');
                            }
                            */
                        }
                        
                        system.debug('query--->'+query);
                        adhocPayment.pastPaymentList = Database.query( query + ' AND nu_dse__Schedule_Date__c < TODAY ' + conditionalQuery);
                        
                        adhocPayment.futurePaymentList = Database.query( query + ' AND nu_dse__Schedule_Date__c >= TODAY' + conditionalQuery);
                        return adhocPayment;
                    }
                }
            }
            
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    /* Date : 23-10-2018
     * Description : Method to get the all draft payments based on the passed month
     * Invoked From : doInit method in miniCalendar lightning component 
     */
     /*
    @AuraEnabled
    public static List<nu_dse__Payment__c> getDraftPayments(Integer month, Integer year) { //, String taskId) {
        
        try {
        
            if(month != null && year != null) {
                
                Map<String, Id> accountIdMap = Utility.getAccountIdFromCurrentUser();
                
                if(accountIdMap.containsKey('primaryAccountId') == TRUE) {
                    
                    Id accountId = accountIdMap.get('primaryAccountId');
                    Date startDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(system.today().day())).toStartOfMonth();
                    
                    Date endDate = startDate.addMonths(13).addDays(-1);
                    startDate = startDate.addMonths(-12);
                    
                    System.debug('****** accountId-->' + accountId);
                    System.debug('**** startDate-->' + startDate);
                    System.debug('**** endDate-->' + endDate);
                    
                    String query = 'SELECT Id, nu_dse__Schedule_Date__c, nu_dse__Amount__c, nu_dse__Transaction_Status__c FROM nu_dse__Payment__c WHERE ';
                                   
                    /*if (String.isNotBlank(taskId)) {
                        
                        List<Task> taskList = [SELECT Id, NSF_Payment__c FROM TASK WHERE ID =:taskId AND NSF_Payment__c != null LIMIT 1];
                        if (taskList != null && taskList.isEmpty() == False ) {
                            
                            query += ' Id = \''+taskList[0].NSF_Payment__c+'\'';
                        }
                    } else {*/
                        
                        /* un comment if you un comment the method 
                        query += ' nu_dse__Program__r.nu_dse__Account__c = :accountId AND RecordType.DeveloperName =  \''+'Draft'+'\' AND '+
                                ' (nu_dse__Schedule_Date__c >= THIS_MONTH OR nu_dse__Transaction_Status__c IN (\''+'Cancelled'+'\', \''+'Failed'+'\')) ORDER BY nu_dse__Schedule_Date__c ASC';
                       */
                   // }
                    /* un comment if you un comment the method 
                    return Database.query( query );     
                    */        
                    /*return [SELECT Id, nu_dse__Schedule_Date__c, nu_dse__Amount__c, nu_dse__Transaction_Status__c FROM nu_dse__Payment__c 
                            WHERE nu_dse__Program__r.nu_dse__Account__c = :accountId AND RecordType.DeveloperName = 'Draft'
                            AND (nu_dse__Schedule_Date__c >= THIS_MONTH OR nu_dse__Transaction_Status__c IN ('Cancelled', 'Failed')) ORDER BY nu_dse__Schedule_Date__c ASC];*/
                            
                            /*(nu_dse__Schedule_Date__c >= :startDate AND nu_dse__Schedule_Date__c <= :endDate)*/
                /* un comment if you un comment the method 
                }
            }
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    */
    
    /* Date : 31-10-2018
     * Description : Method to insert a grouptask instance 
     * Invoked From : ShowModal Method in adhocPayment lightning component 
     */
    @AuraEnabled
    public static nu_dse__Group_Task__c getGroupTaskInstance() {
    
        nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c(nu_dse__Subject__c ='New AdHoc Payment Request');
        insert groupTaskInstance;
        return groupTaskInstance;
    }
    
    /* Date : 31-10-2018
     * Description : Method to delete the document of given documentId
     * Invoked From : onDelete Method in adhocPayment lightning component 
     */
    @AuraEnabled
    public static void deleteDocument(String documentId) {
      
      SFSPortal_ContactUsController.deleteDocument(documentId);
    }
    
    /* Date : 31-10-2018
     * Description : Method to delete the groupTask record of cancel request
     * Invoked From : deletePayment Method in adhocPayment lightning component 
     */
    @AuraEnabled
    public static void deletePaymentRecord(String groupTaskId) {
        SFSPortal_TradelineListController.deleteRecord(groupTaskId);
    }
    
    /* Date : 31-10-2018
     * Description : Method to delete the document of given documentId
     * Invoked From : onDelete Method in adhocPayment lightning component 
     */
    @AuraEnabled
    public static boolean createMakeupPaymentForFailurePayment(String selectedDate, String paymentId) {
        
        try {
        
            if (String.isNotBlank(selectedDate) && String.isNotBlank(paymentId)) {
                
                paymentId = Id.valueOf(paymentId);
                
                List<nu_dse__Payment__c> paymentList = [SELECT Id, nu_dse__Amount__c, nu_dse__Program__c, nu_dse__Payment_Type__c, nu_dse__Service_Fee__c, nu_dse__Retainer_Fee__c,
                                                        nu_dse__Monthly_Maintenance_Fee__c, nu_dse__Processor_Fee__c, nu_dse__Monthly_Third_Party_Fees__c, nu_dse__Monthly_Other_Fee__c,
                                                        nu_dse__Transaction_Method__c    
                                                        FROM nu_dse__Payment__c 
                                                        WHERE Id=:paymentId LIMIT 1];
                
                if (paymentList != null && paymentList.isEmpty() == False) {
                    
                    List<nu_dse__Payment__c> paymentToUpsertList = new List<nu_dse__Payment__c>();
                    
                    nu_dse__Payment__c payment = paymentList[0].clone(false, false, false, false);
                    payment.nu_dse__Advance_Payment__c = paymentList[0].Id;
                    payment.nu_dse__Transaction_Status__c = 'Pending';
                    payment.nu_dse__Schedule_Date__c = Date.ValueOf(selectedDate);
                    
                    /* Populating Decision Source and Made By */
                    payment.Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + String.valueOf(System.now());
                    payment.Decision_Source__c = 'Portal';
                    
                    paymentToUpsertList.add(payment);
                    
                    nu_dse__Payment__c payment1 = new nu_dse__Payment__c(Id = paymentList[0].Id);
                    payment1.nu_dse__Dont_Consider__c = true;
                    payment1.nu_dse__Is_Makeup_Payment_Created__c = TRUE;
                    
                    paymentToUpsertList.add(payment1);
                    
                    if (paymentToUpsertList != null && paymentToUpsertList.isEmpty() == False) {
                        
                        system.debug('paymentToUpsertList----->'+paymentToUpsertList);
                        upsert paymentToUpsertList;
                    }
                    
                    List<Task> taskList = [SELECT Id, NSF_payment_18_Digit__c FROM Task WHERE WhatId = :paymentList[0].nu_dse__Program__c AND  NSF_payment_18_Digit__c =:paymentId LIMIT 1];
                    
                    System.debug('**** taskList-->' + taskList);
                    
                    if (taskList != null && taskList.isEmpty() == False) {
                        
                        Task taskInstance = new Task(Id = taskList[0].Id);
                        taskInstance.Status = 'Completed';
                        
                        taskInstance.Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + String.valueOf(System.now());
                        taskInstance.Decision_Source__c = 'Portal';
                        
                        system.debug('taskInstance----->'+taskInstance);
                        update taskInstance;    
                    }
                    
                    
                    Integer nsfPaymentCount = [SELECT Count() FROM nu_dse__Payment__c WHERE nu_dse__Program__c =: paymentList[0].nu_dse__Program__c
                        AND RecordTypeId = :SFSPortal_Utility.getRecordTypeId('nu_dse__Payment__c', 'Draft') 
                        AND nu_dse__Transaction_Status__c IN ('Failed') AND nu_dse__Dont_Consider__c = FALSE
                    ];
                    
                    if(nsfPaymentCount == 0) {
                        
                        nu_dse__Program__c programInstance = new nu_dse__Program__c(Id = paymentList[0].nu_dse__Program__c, nu_dse__Program_Status__c = 'Active Client');
                        update programInstance;
                    } 
                        
                    return true;
                } 
            }
        } catch(Exception e) {
            
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_LightningSelfRegisterCtrl.selfRegister', 
                null, e.getMessage(), e.getStackTraceString()
            );
            */
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    
    /* Date : 09-11-2018
     * Description : Method to get the payments 
     * Invoked From : doInit Method in reschedulePayments lightning component 
     */
    @AuraEnabled
    public static ReschedulePaymentWrapper getReschedulePayment(String paymentId) {
        
        ReschedulePaymentWrapper reschedulePayment = new ReschedulePaymentWrapper();
        
        try {
            
            Map<String, Schema.SObjectField> fieldMap = nu_dse__Payment__c.sObjectType.getDescribe().fields.getMap();
            
            /* Un comment if help text logic is uncommented
            for(Schema.SObjectField fieldAPI : fieldMap.values()) {
            
                reschedulePayment.helpTextMap.put(String.valueOf(fieldAPI), fieldAPI.getDescribe().getInlineHelpText() != null ? fieldAPI.getDescribe().getInlineHelpText() : '');
            }
            */
            
            Id draftRecordId = SFSPortal_Utility.getRecordTypeId('nu_dse__Payment__c', 'Draft');       
            if (String.isNotBlank(paymentId)) {
                
                system.debug('paymentId--->'+paymentId);
                
                List<nu_dse__Payment__c> paymentList = [SELECT Id, Name, nu_dse__Schedule_Date__c, nu_dse__Amount__c, nu_dse__Transaction_Status__c, nu_dse__Program__c, 
                                                        nu_dse__Is_Makeup_Payment_Created__c, nu_dse__Program__r.nu_dse__Payment_Frequency__c, nu_dse__Program__r.Portfolio__c
                                                        FROM nu_dse__Payment__c 
                                                        WHERE Id = :paymentId AND nu_dse__Dont_Consider__c = FALSE LIMIT 1];
                                                        
                system.debug('paymentList--->'+paymentList);          
                                              
                if (paymentList != null && paymentList.isEmpty() == False) {
                    
                    List< Portfolio__c> portfoilioList = [SELECT Id, Support_Phone_Number__c FROM Portfolio__c WHERE Id =: paymentList[0].nu_dse__Program__r.Portfolio__c ];
                    
                    if (paymentList[0].nu_dse__Transaction_Status__c != 'Cancelled' && paymentList[0].nu_dse__Transaction_Status__c != 'Failed') {
                        
                        String errorMessage = 'This payment cannot be rescheduled, as additional information is needed. Please call ';
                                
                        if (portfoilioList.isEmpty() == False) {
                            
                            errorMessage += portfoilioList[0].Support_Phone_Number__c;
                        } else {
                            
                            errorMessage += '8003453456';
                        }
                        
                        errorMessage += ' to discuss.';
                        
                        throw new CustomException(errorMessage);
                    }
                    if (paymentList[0].nu_dse__Is_Makeup_Payment_Created__c == TRUE) {
                        
                        throw new CustomException('This payment is already Rescheduled.');
                    }
                    reschedulePayment.id = paymentList[0].Id;
                    reschedulePayment.name = paymentList[0].Name;
                    reschedulePayment.scheduleDate = paymentList[0].nu_dse__Schedule_Date__c;
                    reschedulePayment.minDate = System.today().addDays(3); //paymentList[0].nu_dse__Schedule_Date__c.AddDays(2);
                    reschedulePayment.amount = paymentList[0].nu_dse__Amount__c;
                    reschedulePayment.transactionStatus = paymentList[0].nu_dse__Transaction_Status__c;
                    
                    system.debug('reschedulePayment--->'+reschedulePayment); 
                    
                    if (reschedulePayment.transactionStatus == 'Cancelled' || reschedulePayment.transactionStatus == 'Failed') {
                        
                        List<nu_dse__Payment__c> nextDraftPayment = [SELECT Id, nu_dse__Schedule_Date__c
                                                                     FROM nu_dse__Payment__c 
                                                                     WHERE nu_dse__Schedule_Date__c > :reschedulePayment.minDate 
                                                                     AND Id != :paymentId AND recordTypeId =:draftRecordId AND nu_dse__Dont_Consider__c = false
                                                                     AND nu_dse__Program__c =: paymentList[0].nu_dse__Program__c AND nu_dse__Transaction_Status__c IN ('Pending', 'In Progress')
                                                                     ORDER BY nu_dse__Schedule_Date__c ASC LIMIT 2];
                        
                        system.debug('nextDraftPayment--->'+nextDraftPayment); 
                                                                     
                        if (nextDraftPayment != null && nextDraftPayment.isEmpty() == False) {
                            
                            if (paymentList[0].nu_dse__Program__r.nu_dse__Payment_Frequency__c == 'Twice Monthly') {
                                
                                if (nextDraftPayment[0] != null && nextDraftPayment[1] != null) {
                                
                                    reschedulePayment.maxDate = nextDraftPayment[1].nu_dse__Schedule_Date__c.AddDays(-1);
                                } else {
                                    
                                    reschedulePayment.maxDate = nextDraftPayment[0].nu_dse__Schedule_Date__c.AddDays(-1);
                                }
                            } else {
                                
                                reschedulePayment.maxDate = nextDraftPayment[0].nu_dse__Schedule_Date__c.AddDays(-1);
                            }
                            system.debug('reschedulePayment--->'+reschedulePayment); 
                            system.debug('daysBetween--->'+reschedulePayment.minDate.daysBetween(reschedulePayment.maxDate)); 
                            if (reschedulePayment.minDate.daysBetween(reschedulePayment.maxDate) <= 1) {
                                
                                reschedulePayment.errorMessage = 'This payment cannot be rescheduled, as additional information is needed. Please call ';
                                
                                if (portfoilioList.isEmpty() == False) {
                                    
                                    reschedulePayment.errorMessage += portfoilioList[0].Support_Phone_Number__c;
                                } else {
                                    
                                    reschedulePayment.errorMessage += '8003453456';
                                }
                                reschedulePayment.errorMessage += ' to discuss.';
                                
                                /*
                                SFSPortal_Utility.createErrorLogs('SFSPortal_ADHOCPaymentController.getReschedulePayment', 
                                    reschedulePayment.Id, reschedulePayment.errorMessage, null
                                );
                                */
                            }
                        }
                    }
                    
                    /* Adding bank account masked number */
                    
                    List<nu_dse__Bank_Account__c> bankAccountList = [SELECT Bank_Account_Number_4digits__c FROM nu_dse__Bank_Account__c WHERE nu_dse__Program__c =:paymentList[0].nu_dse__Program__c /* AND nu_dse__Status__c = 'Active' */];
                    if (bankAccountList != null && bankAccountList.isEmpty() == False) {
                        
                        reschedulePayment.helpTextMap.put('masked_bank_account_number', bankAccountList[0].Bank_Account_Number_4digits__c);
                    }  
                    
                    return reschedulePayment;
                } else {
                    
                    throw new CustomException('No payment Found.');
                }
            }
        } catch(Exception e) {
        
            system.debug('getMessage--->'+e.getMessage()); 
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_LightningSelfRegisterCtrl.selfRegister', 
                paymentId, e.getMessage(), e.getStackTraceString()
            ); */
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static RoutingResponse getRoutingBankDetails(String routingNumber) {
    
        String calloutUrl = 'https://www.routingnumbers.info/api/data.json?rn=' + routingNumber;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(calloutUrl);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
        RoutingResponse response = (RoutingResponse) JSON.deserialize(res.getBody(), RoutingResponse.class);
        return response;
    }
    
    public class RoutingResponse {
        @AuraEnabled public String message;
        @AuraEnabled public String code;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zip;
        @AuraEnabled public String telephone;
        @AuraEnabled public String customer_name;
    }
    
    public class ReschedulePaymentWrapper {
        
        @AuraEnabled
        public String id;
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public Date scheduleDate;
        
        @AuraEnabled
        public Decimal amount;
        
        @AuraEnabled
        public String transactionStatus;
        
        @AuraEnabled
        public Date minDate;
        
        @AuraEnabled
        public Date maxDate;
        
        @AuraEnabled
        public String errorMessage;
        
        @AuraEnabled
        public Map<String,String> helpTextMap = new Map<String,String>();
        
    }
    public class ADHOCPaymentWrapper {
    
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> columnList = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public List<nu_dse__Payment__c> pastPaymentList = new List<nu_dse__Payment__c>();
        
        @AuraEnabled
        public List<nu_dse__Payment__c> futurePaymentList = new List<nu_dse__Payment__c>();
        
        @AuraEnabled
        public List<String> paymentStatusList = new List<String>();
        
        @AuraEnabled
        public Integer pastPaymentCount = 0;
        
        @AuraEnabled
        public Map<String, Date> setMinAndMaxDate = new Map<String, Date>();
        
        @AuraEnabled
        public Integer futurePaymentCount = 0;
        
        @AuraEnabled
        public Id activeBankAccount;
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> editPaymentFieldsList = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> editBankInfoFieldsList = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public Decimal draftVariancePercent = 0.00;
        
        @AuraEnabled
        public Boolean addFunds = False;
        
        @AuraEnabled
        public Boolean addNewBankAccount = False;
    }
}