public class SFSPortal_TradelineListController {
    
    /* Date : 10-10-2018
* Description : Method to create the groupTask record
* Invoked From : onSave Method in tradelineList lightning component 
*/
    @AuraEnabled
    public static void saveReceipt(nu_dse__Group_Task__c newReceipt) {
        
        try {
            
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            String accountId;
            
            if(accountIdMap != null && accountIdMap.isEmpty() == False) {            
                
                if (accountIdMap.ContainsKey('primaryAccountId') == True 
                    && accountIdMap.get('primaryAccountId') != null) {
                        
                        accountId = accountIdMap.get('primaryAccountId');
                        List<nu_dse__Program__c> programList = [SELECT Id, nu_dse__Account__c FROM nu_dse__Program__c 
                                                                WHERE nu_dse__Account__c =: accountId]; 
                        List<Group> groupList = [SELECT Id 
                                                 FROM Group where Type = 'Queue' 
                                                 AND DeveloperName = 'Payment_Processing' 
                                                 LIMIT 1];
                        if(newReceipt != null && programList.isEmpty() == False) {
                            
                            if (groupList != null && groupList.isEmpty() == False) {
                                
                                newReceipt.ownerId = groupList[0].Id;
                            }
                            newReceipt.Program__c = programList[0].Id;
                            newReceipt.nu_dse__Related_To__c = programList[0].Id;
                            newReceipt.nu_dse__ActivityDate__c = System.today().addDays(1);
                            newReceipt.Orphan_Created_From_Portfolio__c = FALSE;
                            /* Populating decision made by decision source */
                            newReceipt.Decision_Made_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() 
                                + ' ' + String.valueOf(System.now());
                            newReceipt.Decision_Source__c = 'Portal';
                            update newReceipt;
                        }
                    }
            }
            
        } catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            system.debug(e.getMessage());
        }
        
    }
    
    /* Date : 10-10-2018
* Description : Method to delete the groupTask record of cancel request
* Invoked From : onDelete Method in tradelineList lightning component 
*/
    
    @AuraEnabled
    public static void deleteRecord(String groupTaskId) {
        
        try {
            if(groupTaskId != null) {
                
                nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c(Id = groupTaskId);
                delete groupTaskInstance; 
            }
            
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Date : 21-12-2018
* Description : Method to insert the new tradeline if id is not exist, returns the field list
* Invoked From : doInit Method in newTradeline lightning component 
*/
    
    @AuraEnabled
    public static NewTradelineWrapper getTradelineInstance(String groupTaskId) {
        
        NewTradelineWrapper wrapper = new NewTradelineWrapper();
        
        try {
            
            if(String.isNotBlank(groupTaskId) == TRUE) {
                
                wrapper.groupTaskInstance = new nu_dse__Group_Task__c(Id = groupTaskId);
            } else {
                
                wrapper.groupTaskInstance = getGroupTaskInstance();
            }
            
            for(Schema.FieldSetMember fieldMember : 
                Schema.SObjectType.nu_dse__Group_Task__c.fieldSets.New_Group_Task_In_Community.getFields()) {
                    
                    wrapper.fieldSetMemberList.add(
                        new FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),
                                                  (String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),
                                                  fieldMember.getFieldPath(),''
                                                 )
                    );
                }
            
        } catch(Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        }
        
        return wrapper;
    }
    
    /* Date : 22-10-2018
* Description : Method to get the row and column of table
* Invoked From : doInit Method in tradelineList lightning component 
*/
    
    @AuraEnabled
    public static TradelineListWrapper getDefaultValues() {
        
        TradelineListWrapper wrapper = new TradelineListWrapper();
        wrapper.isTradelineListVisible = FeatureManagement.checkPermission('Tradeline_List');
        wrapper.isAddNewDebt = FeatureManagement.checkPermission('Add_New_Debt');
        
        if (wrapper.isTradelineListVisible) {
            
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            if (accountIdMap.isEmpty() == False && accountIdMap.ContainsKey('primaryAccountId') == True 
                && accountIdMap.get('primaryAccountId') != null) {
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c, Portfolio__r.Domain_URL__c 
                                                            FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__c =: accountIdMap.get('primaryAccountId')]; 
                    
                    for (Schema.FieldSetMember fieldMember : 
                         Schema.SObjectType.nu_dse__Group_Task__c.fieldSets.New_Group_Task_In_Community.getFields()) {
                             
                             wrapper.fieldSetMemberList.add(new FieldSetMemberWrapper(fieldMember.getRequired() || 
                                                                                      fieldMember.getDbRequired(),
                                                                                      (String.valueOf(fieldMember.getType())).toLowercase(),
                                                                                      fieldMember.getLabel(), fieldMember.getFieldPath(),'')
                                                           );
                         }    
                    
                    if (programList != null && programList.isEmpty() == False) {
                        
                        Map<Id, tradelineListWrap> tradelineListWrapMap = new Map<Id, tradelineListWrap> ();
                        Map<String, List<String>> cardNameMap = new Map<String, List<String>>();
                        Map<String, SFSPortal_TradelineList__mdt> tradelineListMetaMap = 
                                                                                new Map<String, SFSPortal_TradelineList__mdt>();
                        for (SFSPortal_TradelineList__mdt tradeline : [SELECT Id, MasterLabel, Status_Color_Code__c, Type__c, 
                                                                       Starting_Credit_Card_Number__c, Card_Name__c
                                                                       FROM SFSPortal_TradelineList__mdt]) {
                           
                           if (tradeline.Type__c == 'Credit Card' && tradeline.Card_Name__c != null 
                               && tradeline.MasterLabel != null && programList[0].Portfolio__c != null 
                               && programList[0].Portfolio__r.Domain_URL__c != null) {
                                   
                               if (cardNameMap.ContainsKey(tradeline.Card_Name__c) == False) {
                                   
                                   cardNameMap.put(tradeline.Card_Name__c, new List<String>());
                               }
                               cardNameMap.get(tradeline.Card_Name__c).add(tradeline.MasterLabel);
                           } else if (tradeline.Type__c == 'Status Color' && tradeline.MasterLabel != null) {
                               
                               tradelineListMetaMap.put(tradeline.MasterLabel.toLowerCase(), tradeline);
                           }
                       }
                        system.debug('cardNameMap---->'+cardNameMap);
                        system.debug('tradelineListMetaMap---->'+tradelineListMetaMap);
                        
                        Map<String, String> credit_CardMap = new Map<String, String>();
                        
                        if (cardNameMap.isEmpty() == False) {
                            
                            for (StaticResource resource : [SELECT Name, NamespacePrefix, SystemModStamp 
                                                            FROM StaticResource 
                                                            WHERE Name IN :cardNameMap.Keyset()]) {
                                                                
                                if (cardNameMap.ContainsKey(resource.Name)) {
                                    
                                    for (String cardName : cardNameMap.get(resource.Name)) {
                                        
                                        credit_CardMap.put(cardName.toLowerCase(), programList[0].Portfolio__r.Domain_URL__c 
                                                           + '/resource/' + resource.SystemModStamp.getTime() 
                                                           + '/' + resource.Name); 
                                    }
                                }                            
                            }
                        }
                        
                        system.debug('credit_CardMap---->'+credit_CardMap);
                        
                        set<Id> tradelineIdSet = new Set<Id>();
                        
                        for ( nu_dse__TradeLine__c tradeline : [ SELECT Id, Name, Current_Stage_Portal__c, 
                                                                    ( SELECT Id, nu_dse__Status__c, nu_dse__Offer_Amount__c 
                                                                      FROM nu_dse__Offers__r 
                                                                      WHERE Latest_Offer__c = true 
                                                                    ), 
                                                                SFS_Current_Balance__c, nu_dse__Original_Creditor__c, 
                                                                nu_dse__Original_Creditor__r.Name,
                                                                nu_dse__Original_Creditor__r.Normalized_Creditor__c,
                                                                Normalized_Original_Creditor__c, nu_dse__Original_Debt__c, 
                                                                SFS_Current_Stage__c, SFSPortal_Original_Creditor__c,
                                                                nds_Original_Creditor_Name__c ,
                                                                nu_dse__Sales_Creditor_Name__c,
                                                                Normalized_Current_Creditor__c,
                                                                nds_Current_Creditor_Name__c
                                                                FROM nu_dse__TradeLine__c
                                                                WHERE nu_dse__Program__c =:programList[0].Id 
                                                                AND nu_dse__Include_In_The_Program__c = True ]) {
                                                                    
                            tradelineListWrap tradelineStr = new tradelineListWrap ();
                            tradelineStr.tradelineId = tradeline.Id;
                            /*tradelineStr.originalDebtOwner = String.isNotBlank(tradeline.nu_dse__Original_Creditor__c) 
                            && String.isNotBlank(tradeline.nu_dse__Original_Creditor__r.Name) 
                            ? tradeline.nu_dse__Original_Creditor__r.Name : '';
                            */ 
                            tradelineStr.originalDebtOwner = String.isNotBlank(tradeline.nds_Original_Creditor_Name__c) 
                            ? tradeline.nds_Original_Creditor_Name__c : tradeline.nu_dse__Sales_Creditor_Name__c;                                          
                                                                    
                            tradelineStr.accountNumber = '(...' +(tradeline.SFSPortal_Original_Creditor__c.substringAfterLast('-'))+')';
                            tradelineStr.status = String.isNotblank(tradeline.SFS_Current_Stage__c) 
                                            ? tradeline.SFS_Current_Stage__c :  String.isNotblank(tradeline.Current_Stage_Portal__c) 
                                            ? tradeline.Current_Stage_Portal__c : 'Pre-Settlement';
                                        
                            if (tradeline.Normalized_Original_Creditor__c != null 
                                && credit_CardMap.containsKey(tradeline.Normalized_Original_Creditor__c.toLowerCase())
                                && credit_CardMap.get(tradeline.Normalized_Original_Creditor__c.toLowerCase()) != null) {
                                    
                                tradelineStr.creditCardName = credit_CardMap.get(tradeline.Normalized_Original_Creditor__c.toLowerCase());
                            } else if (credit_CardMap.containsKey('default') && credit_CardMap.get('default') != null) {
                                
                                tradelineStr.creditCardName = credit_CardMap.get('default');
                            }
                            if (String.isNotBlank(tradelineStr.status) && tradelineListMetaMap.containsKey(tradelineStr.status.toLowerCase()) 
                                && tradelineListMetaMap.get(tradelineStr.status.toLowerCase()) != null ) {
                                    
                                if (tradelineListMetaMap.get(tradelineStr.status.toLowerCase()).Status_Color_Code__c != null) {
                                    
                                    tradelineStr.statusColor = tradelineListMetaMap.get(tradelineStr.status.toLowerCase()).Status_Color_Code__c;
                                }
                            }
                            if (tradeline.SFS_Current_Stage__c == 'Pre-Settlement' 
                                || tradeline.SFS_Current_Stage__c == 'In Litigation' 
                                || tradeline.Current_Stage_Portal__c == 'In Litigation' 
                                || tradeline.Current_Stage_Portal__c == 'Pending Enrollment'
                                || tradeline.Current_Stage_Portal__c == 'Payment Plan Suspended' 
                                || tradeline.Current_Stage_Portal__c == 'Removed from Program') {
                                    
                                    tradelineStr.debtBalance = tradeline.nu_dse__Original_Debt__c != null ? tradeline.nu_dse__Original_Debt__c : 0;
                                    
                            } else if (tradeline.SFS_Current_Stage__c == 'Offer Pending Approval' 
                                       || tradeline.SFS_Current_Stage__c == 'Offer Under Review'
                                       || tradeline.Current_Stage_Portal__c == 'Payment Plan Active' 
                                       || tradeline.Current_Stage_Portal__c == 'Debt Settled') {
                                           
                                tradelineStr.debtBalance = tradeline.SFS_Current_Balance__c != null ? tradeline.SFS_Current_Balance__c : 0;
                                tradelineStr.settlementBalance = 0;
                                List <nu_dse__Offer__c> offerList = tradeline.nu_dse__Offers__r;
                                if (offerList != null && offerList.isEmpty() == False) {
                                   
                                    for (nu_dse__Offer__c offer : offerList) {
                                       
                                        tradelineStr.settlementBalance += offer.nu_dse__Offer_Amount__c != null ? offer.nu_dse__Offer_Amount__c : 0 ;
                                       
                                        if (offer.nu_dse__Status__c  == 'Accepted' || offer.nu_dse__Status__c == 'Payment Plan - Active') {
                                           
                                            tradelineStr.hasOffer = true;
                                        }
                                        tradelineIdSet.add(tradeline.Id);
                                    }
                                }
                            }
                            tradelineListWrapMap.put(tradeline.Id, tradelineStr);
                        }                        
                        if (tradelineIdSet.isEmpty() == False && tradelineListWrapMap.isEmpty() == False) {
                            
                            Id settlmentRecodTypeId = SFSPortal_Utility.getRecordTypeId('nu_dse__Payment__c', 'Settlement');
                            
                            for (nu_dse__Payment__c payment: [SELECT id, nu_dse__Schedule_Date__c, nu_dse__Amount__c, 
                                                              nu_dse__Offer__c, nu_dse__Offer__r.nu_dse__TradeLine__c
                                                              FROM nu_dse__Payment__c
                                                              WHERE nu_dse__Offer__c != null 
                                                              AND nu_dse__Offer__r.nu_dse__TradeLine__c IN :tradelineIdSet 
                                                              AND nu_dse__Offer__r.Latest_Offer__c = true
                                                              AND recordtypeId = :settlmentRecodTypeId 
                                                              AND nu_dse__Schedule_Date__c <= TODAY
                                                              ORDER BY Createddate]) {
                                                                  
                                if (tradelineListWrapMap.ContainsKey(payment.nu_dse__Offer__r.nu_dse__TradeLine__c) 
                                    && tradelineListWrapMap.get(payment.nu_dse__Offer__r.nu_dse__TradeLine__c) != null) {
                                
                                    tradelineListWrap tradelineStr = tradelineListWrapMap.get(payment.nu_dse__Offer__r.nu_dse__TradeLine__c);
                                    tradelineStr.settlementBalance -= payment.nu_dse__Amount__c;
                                    tradelineListWrapMap.put(payment.nu_dse__Offer__r.nu_dse__TradeLine__c, tradelineStr);
                                }
                            }
                        }
                        
                        if (tradelineListWrapMap.isEmpty() == False) {
                            
                            wrapper.tradeLineWrapList.addAll(tradelineListWrapMap.Values());
                        }
                    }
                }
        }
        return wrapper;
    }
    
    /* Date : 24-10-2018
    * Description : Method to delete the document of given documentId
    * Invoked From : onDeleteUploadFile Method in tradelineList lightning component 
    */
    @AuraEnabled
    public static void deleteDocument(String documentId) {
        
        try {
            
            SFSPortal_ContactUsController.deleteDocument(documentId);
        } catch(Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /* Date : 24-10-2018
    * Description : Method to insert a grouptask instance 
    * Invoked From : ShowNewDeptModal Method in tradelineList lightning component 
    */
    @AuraEnabled
    public static nu_dse__Group_Task__c getGroupTaskInstance() {
        
        try {
            
            nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c(
                nu_dse__Subject__c = 'Request to add a new tradeline',
                Orphan_Created_From_Portfolio__c = TRUE,
                Subject_Picklist__c = 'Add/Remove Debts',
                nu_dse__Description__c = 'See the Attachments Tab below to review statements'                                                                
            );
            insert groupTaskInstance;
            return groupTaskInstance;
        } catch(Exception e) {
            
            
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /* Date : 22-10-2018
    * Description : Method to get the row and column of table
    * Invoked From : doInit Method in tradelineList lightning component 
    */
    
    @AuraEnabled
    public static TradelineListWrapper getDefault() {
        
        TradelineListWrapper wrapper = new TradelineListWrapper();
        
        Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
        if (accountIdMap.isEmpty() == False && accountIdMap.ContainsKey('primaryAccountId') == True 
            && accountIdMap.get('primaryAccountId') != null) {
                
                List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c, Portfolio__r.Domain_URL__c 
                                                        FROM nu_dse__Program__c 
                                                        WHERE nu_dse__Account__c =: accountIdMap.get('primaryAccountId')]; 
                
                if (programList != null && programList.isEmpty() == False) {
                    
                    Map<Id, tradelineListWrap> tradelineListWrapMap = new Map<Id, tradelineListWrap> ();
                    Map<Id, Id> offerIdWithTradelineIdMap = new Map<Id, Id> ();
                    set<Id> tradelineIdSet = new Set<Id>();
                    Map<String, List<String>> cardNameMap = new Map<String, List<String>>();
                    Map<String, SFSPortal_TradelineList__mdt> tradelineListMetaMap = new Map<String, SFSPortal_TradelineList__mdt>();
                    Map<String, String> credit_CardMap = new Map<String, String>();
                    
                    for (SFSPortal_TradelineList__mdt tradeline : [SELECT Id, MasterLabel, Status_Color_Code__c, Type__c, 
                                                                   Starting_Credit_Card_Number__c, Card_Name__c, 
                                                                   Status_Definitions__c 
                                                                   FROM SFSPortal_TradelineList__mdt]) {
                                                                       
                        if (tradeline.Type__c == 'Credit Card' && tradeline.Card_Name__c != null 
                        && tradeline.MasterLabel != null  && programList[0].Portfolio__c != null 
                        && programList[0].Portfolio__r.Domain_URL__c != null) {
                        
                            if (cardNameMap.ContainsKey(tradeline.Card_Name__c) == False) {
                            
                                cardNameMap.put(tradeline.Card_Name__c, new List<String>());
                            }
                        cardNameMap.get(tradeline.Card_Name__c).add(tradeline.MasterLabel);
                        } else if (tradeline.Type__c == 'Status Color' && tradeline.MasterLabel != null) {
                            
                            tradelineListMetaMap.put(tradeline.MasterLabel.toLowerCase(), tradeline);
                        }
                    }
                    
                    if (cardNameMap.isEmpty() == False) {
                        
                        for (StaticResource resource : [SELECT Name, NamespacePrefix, SystemModStamp 
                                                        FROM StaticResource 
                                                        WHERE Name IN :cardNameMap.Keyset()]) {
                                                            
                            if (cardNameMap.ContainsKey(resource.Name)) {
                                
                                for (String cardName : cardNameMap.get(resource.Name)) {
                                    
                                    credit_CardMap.put(cardName.toLowerCase(), programList[0].Portfolio__r.Domain_URL__c + '/resource/' 
                                                       + resource.SystemModStamp.getTime() + '/' + resource.Name); 
                                }
                            }                            
                        }
                    }
                    
                    for ( nu_dse__TradeLine__c tradeline : [ SELECT Id, Name, Current_Stage_Portal__c, nu_dse__Original_Debt__c, nu_dse__New_Creditor__c, nu_dse__New_Creditor__r.Name,
                                                            ( SELECT Id, nu_dse__Status__c, nu_dse__Offer_Amount__c, 
                                                             createdDate, Current_Balance__c, 
                                                             Authorization_Received_Date__c
                                                             FROM nu_dse__Offers__r 
                                                             WHERE Latest_Offer__c = true 
                                                            ), 
                                                            SFS_Current_Stage__c, SFSPortal_Original_Creditor__c, 
                                                            SFS_Current_Balance__c, createdDate, 
                                                            Normalized_Original_Creditor__c,
                                                            nds_Original_Creditor_Name__c ,
                                                            nu_dse__Sales_Creditor_Name__c,
                                                            Normalized_Current_Creditor__c,
                                                            nds_Current_Creditor_Name__c,
                                                            nu_dse__Original_Creditor__c , nu_dse__Original_Creditor__r.Name, 
                                                            nu_dse__Original_Creditor__r.Normalized_Creditor__c
                                                            FROM nu_dse__TradeLine__c
                                                            WHERE nu_dse__Program__c =:programList[0].Id 
                                                            AND nu_dse__Include_In_The_Program__c = True ]) {
                                                                
                        tradelineListWrap tradelineStr = new tradelineListWrap ();
                        
                        tradelineStr.tradelineId = tradeline.Id;
                        tradelineStr.accountNumber = '(...'+(tradeline.SFSPortal_Original_Creditor__c.substringAfterLast('-'))
                            +')';
                        tradelineStr.enrolledDebt = tradeline.nu_dse__Original_Debt__c != null 
                            ? tradeline.nu_dse__Original_Debt__c : 0;
                        /*tradelineStr.currentDebtOwner = String.isNotBlank(tradeline.nu_dse__New_Creditor__c) 
                            && String.isNotBlank(tradeline.nu_dse__New_Creditor__r.Name) 
                            ? tradeline.nu_dse__New_Creditor__r.Name : '';*/
                                                                
                         tradelineStr.currentDebtOwner = String.isNotBlank(tradeline.Normalized_Current_Creditor__c) 
                            ? tradeline.Normalized_Current_Creditor__c : tradeline.nds_Current_Creditor_Name__c;
                                                                
                       /* tradelineStr.originalDebtOwner = String.isNotBlank(tradeline.nu_dse__Original_Creditor__c) 
                            && String.isNotBlank(tradeline.nu_dse__Original_Creditor__r.Name) 
                            ? tradeline.nu_dse__Original_Creditor__r.Name : '';*/
                       
                        tradelineStr.originalDebtOwner = String.isNotBlank(tradeline.nds_Original_Creditor_Name__c) 
                            ? tradeline.nds_Original_Creditor_Name__c : tradeline.nu_dse__Sales_Creditor_Name__c;                                        
                        
                        tradelineStr.status = String.isNotblank(tradeline.SFS_Current_Stage__c) 
                            ? tradeline.SFS_Current_Stage__c : 
                        String.isNotblank(tradeline.Current_Stage_Portal__c) 
                            ? tradeline.Current_Stage_Portal__c : 'Pre-Settlement';
                        
                        if ( tradeline.Normalized_Original_Creditor__c != null 
                            && credit_CardMap.containsKey(tradeline.Normalized_Original_Creditor__c.toLowerCase()) 
                            && credit_CardMap.get(tradeline.Normalized_Original_Creditor__c.toLowerCase()) != null) {
                                
                                tradelineStr.creditCardName = credit_CardMap.get(tradeline.Normalized_Original_Creditor__c.toLowerCase());
                            } else if (credit_CardMap.containsKey('default') && credit_CardMap.get('default') != null) {
                                
                                tradelineStr.creditCardName = credit_CardMap.get('default');
                            }
                        
                        if (String.isNotBlank(tradelineStr.status.toLowerCase()) && tradelineListMetaMap.containsKey(tradelineStr.status.toLowerCase()) 
                            && tradelineListMetaMap.get(tradelineStr.status.toLowerCase()) != null ) {
                                
                                if (tradelineListMetaMap.get(tradelineStr.status.toLowerCase()).Status_Color_Code__c != null) {
                                    
                                    tradelineStr.statusColor = tradelineListMetaMap.get(tradelineStr.status.toLowerCase()).Status_Color_Code__c;
                                }
                                if (tradelineListMetaMap.get(tradelineStr.status.toLowerCase()).Status_Definitions__c != null) {
                                    
                                    tradelineStr.statusDefinition = 
                                        tradelineListMetaMap.get(tradelineStr.status.toLowerCase()).Status_Definitions__c;
                                } else {
                                    
                                    tradelineStr.statusDefinition = '<b>Your offer was ' + tradelineStr.status +'.</b>';
                                }
                            }
                        
                        if (tradeline.SFS_Current_Stage__c == 'Pre-Settlement' 
                            || tradeline.SFS_Current_Stage__c == 'In Litigation' 
                            || tradeline.Current_Stage_Portal__c == 'In Litigation' 
                            || tradeline.Current_Stage_Portal__c == 'Pending Enrollment'
                            || tradeline.Current_Stage_Portal__c == 'Payment Plan Suspended' 
                            || tradeline.Current_Stage_Portal__c == 'Removed from Program') {
                                
                                tradelineStr.debtBalance = tradeline.nu_dse__Original_Debt__c != null 
                                    ? tradeline.nu_dse__Original_Debt__c : 0;
                                
                        } else if (tradeline.SFS_Current_Stage__c == 'Offer Pending Approval' 
                                   || tradeline.SFS_Current_Stage__c == 'Offer Under Review'
                                   || tradeline.Current_Stage_Portal__c == 'Payment Plan Active' 
                                   || tradeline.Current_Stage_Portal__c == 'Debt Settled') {
                                           
                           tradelineStr.debtBalance = tradeline.SFS_Current_Balance__c != null 
                               ? tradeline.SFS_Current_Balance__c : 0;
                           tradelineStr.settlementBalance = 0;
                           List <nu_dse__Offer__c> offerList = tradeline.nu_dse__Offers__r;
                           tradelineStr.debtSettled = (tradeline.Current_Stage_Portal__c == 'Debt Settled');
                           if (offerList != null && offerList.isEmpty() == False) {
                                               
                               tradelineStr.tradeLineHistoryWrapList.add(
                                   new accountHistoryWrapper ('Tradeline Created', 
                                                              Date.ValueOf(tradeline.CreatedDate),
                                                              'Debt Enrolled', 
                                                              tradeline.nu_dse__Original_Debt__c != null 
                                                              ? tradeline.nu_dse__Original_Debt__c : 0));
                               
                               for (nu_dse__Offer__c offer : offerList) {
                                   
                                   if (offer.nu_dse__Status__c == 'Accepted') {
                                       
                                       tradelineStr.offerAcceptedAmount = offer.nu_dse__Offer_Amount__c != null 
                                           ? offer.nu_dse__Offer_Amount__c : 0;
                                   }
                                   tradelineStr.offerMap.put(offer.Id, offer);
                                   offerIdWithTradelineIdMap.put(offer.Id, tradeline.Id);
                                   tradelineStr.tradeLineHistoryWrapList.add(
                                       new accountHistoryWrapper ('Offer Created', 
                                                                  Date.ValueOf(offer.CreatedDate),
                                                                  'Adjusted Balance', 
                                                                  offer.Current_Balance__c != null 
                                                                  ? offer.Current_Balance__c : 0));
                                   
                                   tradelineStr.tradeLineHistoryWrapList.add(
                                       new accountHistoryWrapper ('Offer Created', 
                                                                  Date.ValueOf(offer.CreatedDate),
                                                                  'Offer Received', 
                                                                  offer.nu_dse__Offer_Amount__c != null 
                                                                  ? offer.nu_dse__Offer_Amount__c : 0));    
                                   
                                   tradelineStr.settlementBalance += offer.nu_dse__Offer_Amount__c != null 
                                       ? offer.nu_dse__Offer_Amount__c : 0 ;
                                   
                                   if (offer.nu_dse__Status__c  == 'Accepted' 
                                       || offer.nu_dse__Status__c == 'Payment Plan - Active') {
                                           
                                           tradelineStr.hasOffer = true;
                                   }
                                   if (offer.Authorization_Received_Date__c != null) {
                                       
                                       tradelineStr.tradeLineHistoryWrapList.add(
                                           new accountHistoryWrapper ('Offer Authorization Received', 
                                                                      Date.ValueOf(offer.Authorization_Received_Date__c),
                                                                      'Offer Accepted', 
                                                                      offer.nu_dse__Offer_Amount__c != null 
                                                                      ? offer.nu_dse__Offer_Amount__c : 0));   
                                   }
                                   tradelineIdSet.add(tradeline.Id);
                               }
                            }
                        }
                        tradelineListWrapMap.put(tradeline.Id, tradelineStr);
                    }
                    
                    if (tradelineIdSet.isEmpty() == False && tradelineListWrapMap.isEmpty() == False) {
                        
                        Id settlmentRecodTypeId = SFSPortal_Utility.getRecordTypeId('nu_dse__Payment__c', 'Settlement');
                        
                        for (nu_dse__Payment__c payment: [SELECT id, nu_dse__Schedule_Date__c, nu_dse__Amount__c, 
                                                          nu_dse__Offer__c, nu_dse__Offer__r.nu_dse__TradeLine__c
                                                          FROM nu_dse__Payment__c
                                                          WHERE nu_dse__Offer__c != null 
                                                          AND nu_dse__Offer__r.nu_dse__TradeLine__c IN :tradelineIdSet 
                                                          AND nu_dse__Offer__r.Latest_Offer__c = true
                                                          AND recordtypeId = :settlmentRecodTypeId 
                                                          AND nu_dse__Schedule_Date__c <= TODAY
                                                          ORDER BY Createddate]) {
                                                              
                          if (tradelineListWrapMap.ContainsKey(payment.nu_dse__Offer__r.nu_dse__TradeLine__c) 
                              && tradelineListWrapMap.get(payment.nu_dse__Offer__r.nu_dse__TradeLine__c) != null) {
                                  
                                  tradelineListWrap tradelineStr = tradelineListWrapMap.get(
                                      payment.nu_dse__Offer__r.nu_dse__TradeLine__c);
                                  tradelineStr.tradeLineHistoryWrapList.add(
                                      new accountHistoryWrapper ('Settlement Payment', 
                                                                 Date.ValueOf(payment.nu_dse__Schedule_Date__c),
                                                                 'Settlement Payment', 
                                                                 payment.nu_dse__Amount__c != null 
                                                                 ? payment.nu_dse__Amount__c : 0));   
                                if (payment.nu_dse__Schedule_Date__c <= System.Today()) {
                                      
                                    tradelineStr.settlementBalance -= payment.nu_dse__Amount__c;
                                }
                                tradelineListWrapMap.put(payment.nu_dse__Offer__r.nu_dse__TradeLine__c, tradelineStr);
                            }
                        }
                        if (offerIdWithTradelineIdMap.isEmpty() == False) {
                            
                            for (nu_dse__Offer__History  offer : [SELECT ParentId, OldValue, NewValue, Field, CreatedDate 
                                                                  FROM nu_dse__Offer__History 
                                                                  WHERE parentId = :offerIdWithTradelineIdMap.Keyset() 
                                                                  AND Field = 'nu_dse__Status__c']) {
                                                                      
                                if (offerIdWithTradelineIdMap.ContainsKey(offer.parentId) 
                                    && offerIdWithTradelineIdMap.get(offer.parentId) != null
                                    &&  tradelineListWrapMap.ContainsKey(offerIdWithTradelineIdMap.get(offer.parentId)) 
                                    && tradelineListWrapMap.get(offerIdWithTradelineIdMap.get(offer.parentId)) != null) {
                                
                                    tradelineListWrap tradelineStr = tradelineListWrapMap.get(
                                    offerIdWithTradelineIdMap.get(offer.parentId));
                                    
                                    if (offer.NewValue == 'Payment Plan Active') {
                                    
                                        tradelineStr.tradeLineHistoryWrapList.add( new accountHistoryWrapper ('Payment Plan Suspended', 
                                                                    Date.ValueOf(offer.CreatedDate),
                                                                    'Offer Approved', 
                                                                    tradelineStr.offerMap.get(offer.parentId).nu_dse__Offer_Amount__c));  
                                    } else if (offer.NewValue == 'Canceled') {
                                    
                                        tradelineStr.tradeLineHistoryWrapList.add( new accountHistoryWrapper ('Offer Cancelled', 
                                                                    Date.ValueOf(offer.CreatedDate),
                                                                    'Offer Approved', 
                                                                    tradelineStr.offerMap.get(offer.parentId).nu_dse__Offer_Amount__c));  
                                                                    tradelineStr.tradeLineHistoryWrapList.add(
                                                                    new accountHistoryWrapper ('Offer Cancelled', 
                                                                    Date.ValueOf(offer.CreatedDate),
                                                                    'Adjusted Balance', tradelineStr.enrolledDebt));  
                                    }
                                    
                                    tradelineListWrapMap.put(offerIdWithTradelineIdMap.get(offer.parentId), tradelineStr);
                                }
                            }
                            for (nu_dse__TradeLine__History  tradeline : [SELECT ParentId, OldValue, NewValue, 
                                                                          Field, CreatedDate 
                                                                          FROM nu_dse__TradeLine__History 
                                                                          WHERE parentId = :tradelineIdSet 
                                                                          AND Field = 'nu_dse__Current_Stage__c']) {
                                                                              
                                if (tradelineListWrapMap.ContainsKey(tradeline.parentId) 
                                      && tradelineListWrapMap.get(tradeline.parentId) != null) {
                                          
                                    tradelineListWrap tradelineStr = tradelineListWrapMap.get(tradeline.parentId);
                                    if (tradeline.NewValue == 'Payment Plan Active') {
                                              
                                        tradelineStr.tradeLineHistoryWrapList.add(new accountHistoryWrapper ('Payment Plan Active', 
                                                                             Date.ValueOf(tradeline.CreatedDate),
                                                                             'Offer Approved', 
                                                                             tradelineStr.offerAcceptedAmount));
                                    } else if (tradeline.NewValue == 'Settled') {
                                              
                                        tradelineStr.tradeLineHistoryWrapList.add(new accountHistoryWrapper ('Tradeline Settled', 
                                                                             Date.ValueOf(tradeline.CreatedDate),
                                                                             'Settled', 0));  
                                    } else if (tradeline.NewValue == 'Removed from Program') {
                                              
                                        tradelineStr.tradeLineHistoryWrapList.add(new accountHistoryWrapper ('Removed From Program', 
                                                                             Date.ValueOf(tradeline.CreatedDate),
                                                                             'Removed from Program', 
                                                                             tradelineStr.settlementBalance));  
                                    } else if (tradeline.OldValue == 'Payment Plan Suspended' && tradeline.NewValue == 'Client Defaulted') {
                                                         
                                        tradelineStr.tradeLineHistoryWrapList.add( new accountHistoryWrapper ('Payment Plan Suspended', 
                                                                                        Date.ValueOf(tradeline.CreatedDate),
                                                                                        'Settlement Payment Failed', 
                                                                                        tradelineStr.offerAcceptedAmount ));  
                                    }
                                    tradelineListWrapMap.put(tradeline.parentId, tradelineStr);
                                }
                            }
                        }
                    }
                    if (tradelineListWrapMap.isEmpty() == False) {
                        
                        wrapper.tradeLineWrapList.addAll(tradelineListWrapMap.Values());
                    }
                }
            }
        return wrapper;
    }
    
    public class paymentListWrapper {
        @AuraEnabled
        public Integer totalRecordCount;
        
        @AuraEnabled
        public List<nu_dse__Payment__c> paymentList = new List<nu_dse__Payment__c>();
    }
    
    public class FieldSetMemberWrapper{
        
        @AuraEnabled
        public Boolean isRequired;    
        
        @AuraEnabled
        public String fieldType;      
        
        @AuraEnabled
        public String fieldLabel;      
        
        @AuraEnabled
        public String fieldAPIName;   
        
        @AuraEnabled
        public String fieldRelationshipName;
        
        public FieldSetMemberWrapper(Boolean isRequired, String fieldType, String fieldLabel,
                                     String fieldAPIName, String fieldRelationshipName) {
                                         
            this.isRequired = isRequired;
            this.fieldType = fieldType;
            this.fieldLabel = fieldLabel;
            this.fieldAPIName = fieldAPIName;
            this.fieldRelationshipName = fieldRelationshipName;
        }
    }
    
    public class NewTradelineWrapper {
        
        @AuraEnabled
        public List<FieldSetMemberWrapper> fieldSetMemberList = new List<FieldSetMemberWrapper>();
        
        @AuraEnabled
        public nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c();
    }
    
    public class TradelineListWrapper {
        
        @AuraEnabled
        public Boolean isTradelineListVisible = True;
        
        @AuraEnabled
        public Boolean isAddNewDebt = False;
        
        @AuraEnabled
        public List<tradelineListWrap> tradeLineWrapList = new List<tradelineListWrap>();
        
        @AuraEnabled
        public List<FieldSetMemberWrapper> fieldSetMemberList = new List<FieldSetMemberWrapper>();
        
    }
    
    public class tradelineListWrap {
        
        @AuraEnabled
        public Boolean hasOffer = False;    
        
        @AuraEnabled
        public String tradelineId; 
        
        @AuraEnabled
        public String accountNumber;
        
        @AuraEnabled
        public String status;    
        
        @AuraEnabled
        public String statusColor;    
        
        @AuraEnabled
        public String statusDefinition;    
        
        @AuraEnabled
        public String creditCardName;    
        
        @AuraEnabled
        public String currentDebtOwner; 
        
        @AuraEnabled
        public String ndsCurrentDebtOwner; 
        
        @AuraEnabled
        public String originalDebtOwner; 
        
        @AuraEnabled
        public decimal debtBalance = 0;
        
        @AuraEnabled
        public decimal enrolledDebt = 0;
        
        @AuraEnabled
        public decimal settlementBalance;
        
        @AuraEnabled
        public Boolean debtSettled;
        
        @AuraEnabled
        public decimal offerAmount = 0;
        
        @AuraEnabled
        public decimal offerAcceptedAmount = 0;
        
        @AuraEnabled
        public decimal originalBalance = 0;
        
        @AuraEnabled
        public List<accountHistoryWrapper> tradeLineHistoryWrapList = new List<accountHistoryWrapper>();
        
        @AuraEnabled
        public Map<Id, nu_dse__Offer__c> offerMap = new Map<Id, nu_dse__Offer__c>();
    }
    
    public class accountHistoryWrapper {
        
        @AuraEnabled
        public String eventFromSalesforce;
        
        @AuraEnabled
        public String action; 
        
        @AuraEnabled
        public decimal amount = 0;
        
        @AuraEnabled
        public Date accountHistoryDate;    
        
        public accountHistoryWrapper (String eventName, Date accountHistoryDate, String action, Decimal amount) {
            
            this.eventFromSalesforce = eventName;
            this.accountHistoryDate = accountHistoryDate;
            this.action = action;
            this.amount = amount;
        }
    }
}