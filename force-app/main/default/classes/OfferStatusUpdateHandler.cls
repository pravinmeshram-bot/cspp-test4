public class OfferStatusUpdateHandler {

    public static void updateOfferStatus(List<nu_dse__Offer__c> newOfferList, Map<Id, nu_dse__Offer__c> oldOfferMap) {
    
        try {
            
            //This process will be executed only if the current user is not an attorney user
            if (newOfferList != null && newOfferList.isEmpty() == False ) {
            
                List<nu_dse__Offer__c> offersToUpdateList = new List<nu_dse__Offer__c>();
                List<nu_dse__Tradeline__c> tradelinesToUpsertList = new List<nu_dse__Tradeline__c>();
                List<nu_dse__Offer__c> offersToProcessList = new List<nu_dse__Offer__c>();
                
                Set<Id> offerStatusChangedIdSet = new Set<Id>();
                Set<Id> offerSettlementStatusChangedIdSet = new Set<Id>();
                
                Map<Id, Id> tradelineIdRecentOfferIdMap = new Map<Id, Id>();
                Map<String, Map<String, String>> fieldMappingMap = new Map<String, Map<String, String>>();
                
                for (nu_dse__Offer__c offerRec : newOfferList) {
                
                    if (offerRec.IsAttorney__c == True && StatusMappingStaticSetClass_nds.processedOfferIdSet.contains(offerRec.Id) == False
                            && (Trigger.isInsert || (Trigger.isUpdate && (offerRec.nu_dse__Status__c != oldOfferMap.get(offerRec.Id).nu_dse__Status__c
                            || offerRec.Settlement_Status__c != oldOfferMap.get(offerRec.Id).Settlement_Status__c)))) {
                    
                        //If multiple offer comes for a single tradeline, we have to take the recently updated tradeline
                        tradelineIdRecentOfferIdMap.put(offerRec.nu_dse__Tradeline__c, offerRec.Id);
                        offersToProcessList.add(offerRec);
                        
                        //Static set to restrict the offers to be processed recursively
                        StatusMappingStaticSetClass_nds.processedOfferIdSet.add(offerRec.Id);
                        
                        if (Trigger.isInsert) {
                        
                            offerStatusChangedIdSet.add(offerRec.Id);
                            
                            //If Attorney_Admin__c is false, status field values will be copied over to the settlement status field
                            
                            /* if (StatusMappingStaticSetClass_nds.getUser().Attorney_Admin__c == True) {
                            
                               offerStatusChangedIdSet.add(offerRec.Id);
                           
                            } else {   //If NDS is true, Settlement status field values will be copied over to the status field
         
                                 offerSettlementStatusChangedIdSet.add(offerRec.Id);
                            }*/
                        } else if (Trigger.isUpdate) {
                        
                            if (offerRec.nu_dse__Status__c != oldOfferMap.get(offerRec.Id).nu_dse__Status__c) {
                        
                                offerStatusChangedIdSet.add(offerRec.Id);
                            
                            } 
                            /*else if (offerRec.Settlement_Status__c != oldOfferMap.get(offerRec.Id).Settlement_Status__c) {
                            
                                offerSettlementStatusChangedIdSet.add(offerRec.Id);
                            }*/
                        }
                    }
                }  
                system.debug('offersToProcessList-->'+offersToProcessList); 
                system.debug('offerStatusChangedIdSet-->'+offerStatusChangedIdSet);  
                system.debug('offerSettlementStatusChangedIdSet-->'+offerSettlementStatusChangedIdSet);   
                
                if (tradelineIdRecentOfferIdMap.isEmpty() == False) {
                
                    //DataMapping we are supporting for this process
                    Set<String> dataMappingNameSet = new Set<String> {'nds_OfferSettlementStatusToOfferStatus', 
                            'nds_OfferSettlementStatusToTradelineCurrentStage', 'nds_OfferSettlementStatusToTradelineSettlementStatus',
                            'nds_OfferStatusToOfferSettlementStatus', 'nds_OfferStatusToTradelineCurrentStage',
                            'nds_OfferStatusToTradelineSettlementStatus'};
                    
                    for (nu_dse__Field_mapping__c fieldMappingRec : [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Target_Field__c,
                                                                        nu_dse__Data_Mapping__r.Name FROM nu_dse__Field_mapping__c
                                                                        WHERE nu_dse__Data_Mapping__r.Name IN :dataMappingNameSet]) {
                    
                        if (fieldMappingMap.containsKey(fieldMappingRec.nu_dse__Data_Mapping__r.Name) == False) {
                        
                            fieldMappingMap.put(fieldMappingRec.nu_dse__Data_Mapping__r.Name, new Map<String, String>());
                        }
                        fieldMappingMap.get(fieldMappingRec.nu_dse__Data_Mapping__r.Name).put(fieldMappingRec.nu_dse__Source_Field__c, 
                                    fieldMappingRec.nu_dse__Target_Field__c);
                    }
                    system.debug('fieldMappingMap--->'+fieldMappingMap);
                    
                    for (nu_dse__Offer__c offerRec : offersToProcessList) {
                    
                        if (tradelineIdRecentOfferIdMap.containsKey(offerRec.nu_dse__Tradeline__c)
                             && offerRec.Id == tradelineIdRecentOfferIdMap.get(offerRec.nu_dse__Tradeline__c)) {
                        
                            //If Offer status is updated, below block will be executed
                            if (offerStatusChangedIdSet.contains(offerRec.Id)) {
                            
                                //Assigning values to the offer settlement status
                                if (fieldMappingMap.containsKey('nds_OfferStatusToOfferSettlementStatus') 
                                        && fieldMappingMap.get('nds_OfferStatusToOfferSettlementStatus').containsKey(offerRec.nu_dse__Status__c)
                                        && offerRec.Settlement_Status__c != fieldMappingMap.get('nds_OfferStatusToOfferSettlementStatus').get(offerRec.nu_dse__Status__c)) {
                                    
                                    nu_dse__Offer__c offerRecToUpdate = new nu_dse__Offer__c(Id = offerRec.Id);
                                    offerRecToUpdate.put('Settlement_Status__c', fieldMappingMap.get('nds_OfferStatusToOfferSettlementStatus').get(offerRec.nu_dse__Status__c));
                                    offersToUpdateList.add(offerRecToUpdate);
                                }
                                
                                if ((fieldMappingMap.containsKey('nds_OfferStatusToTradelineSettlementStatus')
                                        && fieldMappingMap.get('nds_OfferStatusToTradelineSettlementStatus').containsKey(offerRec.nu_dse__Status__c))
                                        || (fieldMappingMap.containsKey('nds_OfferStatusToTradelineCurrentStage')
                                        && fieldMappingMap.get('nds_OfferStatusToTradelineCurrentStage').containsKey(offerRec.nu_dse__Status__c))) {
                                
                                    nu_dse__Tradeline__c tradelineRecToUpdate = new nu_dse__Tradeline__c(Id = offerRec.nu_dse__Tradeline__c);
                                    
                                    //Assigning values to the tradeline settlement status 
                                    if (fieldMappingMap.containsKey('nds_OfferStatusToTradelineSettlementStatus')
                                            && fieldMappingMap.get('nds_OfferStatusToTradelineSettlementStatus').containsKey(offerRec.nu_dse__Status__c)) {
                                    
                                        tradelineRecToUpdate.put('Settlement_Status__c', 
                                                fieldMappingMap.get('nds_OfferStatusToTradelineSettlementStatus').get(offerRec.nu_dse__Status__c));
                                    }
                                    
                                    //Assigning values to the tradeline tradeline current stage
                                    if (fieldMappingMap.containsKey('nds_OfferStatusToTradelineCurrentStage')
                                            && fieldMappingMap.get('nds_OfferStatusToTradelineCurrentStage').containsKey(offerRec.nu_dse__Status__c)) {
                                    
                                        tradelineRecToUpdate.put('nu_dse__Current_Stage__c', 
                                                fieldMappingMap.get('nds_OfferStatusToTradelineCurrentStage').get(offerRec.nu_dse__Status__c));
                                    }
                                    
                                    tradelinesToUpsertList.add(tradelineRecToUpdate);
                                }
                            }
                            
                            //If Offer settlement status is updated, below block will be executed
                            if (offerSettlementStatusChangedIdSet.contains(offerRec.Id)) {
                            
                                //Assigning values to the offer status
                                if (fieldMappingMap.containsKey('nds_OfferSettlementStatusToOfferStatus') 
                                        && fieldMappingMap.get('nds_OfferSettlementStatusToOfferStatus').containsKey(offerRec.Settlement_Status__c)
                                        && offerRec.nu_dse__Status__c != fieldMappingMap.get('nds_OfferSettlementStatusToOfferStatus').get(offerRec.Settlement_Status__c)) {
                                    
                                    nu_dse__Offer__c offerRecToUpdate = new nu_dse__Offer__c(Id = offerRec.Id);
                                    offerRecToUpdate.put('nu_dse__Status__c', fieldMappingMap.get('nds_OfferSettlementStatusToOfferStatus').get(offerRec.Settlement_Status__c));
                                    offersToUpdateList.add(offerRecToUpdate);
                                }
                                
                                if ((fieldMappingMap.containsKey('nds_OfferSettlementStatusToTradelineSettlementStatus')
                                        && fieldMappingMap.get('nds_OfferSettlementStatusToTradelineSettlementStatus').containsKey(offerRec.Settlement_Status__c))
                                        || (fieldMappingMap.containsKey('nds_OfferSettlementStatusToTradelineCurrentStage')
                                        && fieldMappingMap.get('nds_OfferSettlementStatusToTradelineCurrentStage').containsKey(offerRec.Settlement_Status__c))) {
                                
                                    nu_dse__Tradeline__c tradelineRecToUpdate = new nu_dse__Tradeline__c(Id = offerRec.nu_dse__Tradeline__c);
                                    
                                    //Assigning values to the tradeline settlement status 
                                    if (fieldMappingMap.containsKey('nds_OfferSettlementStatusToTradelineSettlementStatus')
                                            && fieldMappingMap.get('nds_OfferSettlementStatusToTradelineSettlementStatus').containsKey(offerRec.Settlement_Status__c)) {
                                    
                                        tradelineRecToUpdate.put('Settlement_Status__c', 
                                                    fieldMappingMap.get('nds_OfferSettlementStatusToTradelineSettlementStatus').get(offerRec.Settlement_Status__c));
                                    }
                                    
                                    //Assigning values to the tradeline tradeline current stage
                                    if (fieldMappingMap.containsKey('nds_OfferSettlementStatusToTradelineCurrentStage')
                                            && fieldMappingMap.get('nds_OfferSettlementStatusToTradelineCurrentStage').containsKey(offerRec.Settlement_Status__c)) {
                                    
                                        tradelineRecToUpdate.put('nu_dse__Current_Stage__c', 
                                                    fieldMappingMap.get('nds_OfferSettlementStatusToTradelineCurrentStage').get(offerRec.Settlement_Status__c));
                                    }
                                    
                                    tradelinesToUpsertList.add(tradelineRecToUpdate);
                                }
                            }
                        }
                    }
                    system.debug('tradelinesToUpsertList--->'+tradelinesToUpsertList);
                    system.debug('offersToUpdateList--->'+offersToUpdateList);
                    
                    List<nu_dse__Error_Log__c> errLogList = new List<nu_dse__Error_Log__c>();
                    
                    if (offersToUpdateList.isEmpty() == False) {
                    
                        //Update the offers
                        Database.SaveResult[] offerUpdateResultList = Database.update(offersToUpdateList, false);
                        
                        //Error handling
                        if (offerUpdateResultList.isEmpty() == False) {
                            
                            for (Database.SaveResult sr : offerUpdateResultList) {
                            
                                if (sr.isSuccess() == False) {
                                
                                    String errMsg = '';
                                    
                                    for(Database.Error err : sr.getErrors()) {
                                    
                                        errMsg += err.getMessage() + '; ';
                                    }
                                    
                                    nu_dse__Error_Log__c errLog = createErrorLog(errMsg, 'OfferStatusUpdateHandler-OfferDML', '');                                
                                    errLogList.add(errLog);
                                }
                            }
                        }
                    }
                    
                    if (tradelinesToUpsertList.isEmpty() == False) {
                    
                        //Update the tradelines
                        Database.SaveResult[] tradelineUpdateResultList = Database.update(tradelinesToUpsertList, false);
                        
                        //Error handling
                        if (tradelineUpdateResultList.isEmpty() == False) {
                            
                            for (Database.SaveResult sr : tradelineUpdateResultList) {
                            
                                if (sr.isSuccess() == False) {
                                
                                    String errMsg = '';
                                    
                                    for(Database.Error err : sr.getErrors()) {
                                    
                                        errMsg += err.getMessage() + '; ';
                                    }
                                    
                                    nu_dse__Error_Log__c errLog = createErrorLog(errMsg, 'OfferStatusUpdateHandler-TradelineDML', '');                                
                                    errLogList.add(errLog);
                                }
                            }
                        }
                    }
                    
                    //Inserting error logs
                    if (errLogList.isEmpty() == False) {
                    
                        insert errLogList;
                    }
                }
            }
        } catch (Exception e) {
        
             //Creating error logs if the exception occurs
             nu_dse__Error_Log__c errorLogInst = createErrorLog(e.getMessage(), 'OfferStatusUpdateHandler.updateOfferStatus',
                         e.getStackTraceString());
             
             insert errorLogInst;
        }
    }
    
    public static nu_dse__Error_Log__c createErrorLog(String message, String classMethod, String stackTrace) {
    
        nu_dse__Error_Log__c errorLogInst = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = classMethod,
                         nu_dse__Message__c = message,  nu_dse__Stack_Trace__c = stackTrace,
                         nu_dse__User_Context__c = UserInfo.getUserName());
         
        return errorLogInst;
    }
}