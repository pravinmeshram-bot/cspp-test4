public class TradelineStatusUpdateHandler {
    
    public static Set<String> datamapNameSet = new set<String>{'nds_AccountStatusToLitDefStage', 'nds_LitDefStageToAccountStatus'};
    
    public static void updateTradelineStatus(List<nu_dse__Tradeline__c> newTradelineList, Map<Id, nu_dse__Tradeline__c> tradelineOldMap) {
        
        List<nu_dse__Tradeline__c> tradelineForUpdateList = new List<nu_dse__Tradeline__c>();
        Map<String, Map<String, String>> dataMapNameAndItsFieldMapping = new Map<String, Map<String, String>>();
        
        try {
            
            //Check whether the user is not an attorney user...
            if (newTradelineList != null && newTradelineList.isEmpty() == False ) {
                
                //static boolean to avoid querying repeatedly..
                if (StatusMappingStaticSetClass_nds.tradelinestaticDataMapInitialized == False) {
                    
                    List<nu_dse__Field_mapping__c> fieldMappingList = [SELECT Id, nu_dse__Source_Field__c, nu_dse__Target_Field__c, nu_dse__Data_Mapping__r.Name FROM nu_dse__Field_mapping__c
                                                                               WHERE nu_dse__Data_Mapping__r.Name IN :datamapNameSet ];
                    
                    StatusMappingStaticSetClass_nds.tradelinestaticDataMapInitialized = True;
                    
                    //Constructing a Map for holding Datamap and its fieldMapping values...
                    if (fieldMappingList.isEmpty() == False) {
                        
                        for (nu_dse__Field_mapping__c fieldMapInstance : fieldMappingList) {
                            
                            if (dataMapNameAndItsFieldMapping.containsKey(fieldMapInstance.nu_dse__Data_Mapping__r.Name) == False) {
                                
                                dataMapNameAndItsFieldMapping.put(fieldMapInstance.nu_dse__Data_Mapping__r.Name, new Map<String, String>());
                            }
                            dataMapNameAndItsFieldMapping.get(fieldMapInstance.nu_dse__Data_Mapping__r.Name).put(fieldMapInstance.nu_dse__Source_Field__c, fieldMapInstance.nu_dse__Target_Field__c);
                        }
                    }
                    //Storing the map in static map to avoid generating repeatedly...
                    StatusMappingStaticSetClass_nds.staticDataMap = dataMapNameAndItsFieldMapping;
                
                } else {
                    
                    dataMapNameAndItsFieldMapping = StatusMappingStaticSetClass_nds.staticDataMap;
                }
                
                if (dataMapNameAndItsFieldMapping.isEmpty() == False) {
                    
                    for (nu_dse__Tradeline__c tradelineInstance : newTradelineList) {
                        
                        //Prevent updating the tradeline's status which is already updated (Using static Id set)...
                        //tradeline's IsAttorney checkbox is checked in order to update its status...
                        if (StatusMappingStaticSetClass_nds.processedtradelineIdSet.contains(tradelineInstance.Id) == False 
                            && tradelineInstance.IsAttorney__c == True) {
                            
                            if (Trigger.isInsert == True) { //For Insert trigger
                                
                                nu_dse__Tradeline__c tradelineInstTemp = new nu_dse__Tradeline__c();
                                tradelineInstTemp.Id = tradelineInstance.Id;
                                Boolean istradelineUpdated = False;
                                
                                //Updating Lit_Def_Stage__c field based on Account_Status__c, if Attorney_Admin__c is false...
                                if (StatusMappingStaticSetClass_nds.getUser().Attorney_Admin__c == TRUE && dataMapNameAndItsFieldMapping.containsKey('nds_AccountStatusToLitDefStage') == True 
                                    && dataMapNameAndItsFieldMapping.get('nds_AccountStatusToLitDefStage').containsKey(tradelineInstance.Account_Status__c) == True
                                    && tradelineInstance.Lit_Def_Stage__c != 
                                        dataMapNameAndItsFieldMapping.get('nds_AccountStatusToLitDefStage').get(tradelineInstance.Account_Status__c)) {
                                    
                                    tradelineInstTemp.Lit_Def_Stage__c = dataMapNameAndItsFieldMapping.get('nds_AccountStatusToLitDefStage').get(tradelineInstance.Account_Status__c);
                                    istradelineUpdated = True;
                                }  
                                
                                //Updating Account_Status__c field based on Lit_Def_Stage__c, if Attorney_Admin__c is true...
                                if (StatusMappingStaticSetClass_nds.getUser().Attorney_Admin__c == FALSE && dataMapNameAndItsFieldMapping.containsKey('nds_LitDefStageToAccountStatus') == True 
                                    && dataMapNameAndItsFieldMapping.get('nds_LitDefStageToAccountStatus').containsKey(tradelineInstance.Lit_Def_Stage__c) == True
                                    && tradelineInstance.Account_Status__c != 
                                        dataMapNameAndItsFieldMapping.get('nds_LitDefStageToAccountStatus').get(tradelineInstance.Lit_Def_Stage__c)) {
                                    
                                    tradelineInstTemp.Account_Status__c = dataMapNameAndItsFieldMapping.get('nds_LitDefStageToAccountStatus').get(tradelineInstance.Lit_Def_Stage__c);
                                    istradelineUpdated = True;
                                }
                                
                                if (istradelineUpdated == True) {
                                    
                                    tradelineForUpdateList.add(tradelineInstTemp);
                                    StatusMappingStaticSetClass_nds.processedtradelineIdSet.add(tradelineInstance.Id); //Adding pymnt Id to static set...
                                }
                                
                            } else if (Trigger.isUpdate == True) { //For Update trigger
                                 
                                //Checking whether the Account_Status__c is changed or not, and update Lit_Def_Stage__c field...
                                if (tradelineInstance.Account_Status__c != tradelineOldMap.get(tradelineInstance.Id).Account_Status__c) {
                                    
                                    if (dataMapNameAndItsFieldMapping.containsKey('nds_AccountStatusToLitDefStage') == True 
                                        && dataMapNameAndItsFieldMapping.get('nds_AccountStatusToLitDefStage').containsKey(tradelineInstance.Account_Status__c) == True
                                        && tradelineInstance.Lit_Def_Stage__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_AccountStatusToLitDefStage').get(tradelineInstance.Account_Status__c)) {
                                        
                                        //Since it is before Update simpliy added to the instance...
                                        tradelineInstance.Lit_Def_Stage__c = dataMapNameAndItsFieldMapping.get('nds_AccountStatusToLitDefStage').get(tradelineInstance.Account_Status__c);
                                        StatusMappingStaticSetClass_nds.processedtradelineIdSet.add(tradelineInstance.Id);
                                    }
                                    
                                    //Checking whether the Lit_Def_Stage__c is changed or not, and update Account_Status__c field...
                                } else if (tradelineInstance.Lit_Def_Stage__c != tradelineOldMap.get(tradelineInstance.Id).Lit_Def_Stage__c) {
                                    
                                    if (dataMapNameAndItsFieldMapping.containsKey('nds_LitDefStageToAccountStatus') == True 
                                        && dataMapNameAndItsFieldMapping.get('nds_LitDefStageToAccountStatus').containsKey(tradelineInstance.Lit_Def_Stage__c) == True
                                        && tradelineInstance.Account_Status__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_LitDefStageToAccountStatus').get(tradelineInstance.Lit_Def_Stage__c)) {
                                        
                                        tradelineInstance.Account_Status__c = dataMapNameAndItsFieldMapping.get('nds_LitDefStageToAccountStatus').get(tradelineInstance.Lit_Def_Stage__c);
                                        StatusMappingStaticSetClass_nds.processedtradelineIdSet.add(tradelineInstance.Id);
                                    }
                                }
                            }
                        }
                        
                        System.debug('**UpdatedtradelineList-->'+newTradelineList);
                    }
                    
                    List<nu_dse__Error_Log__c> errLogList = new List<nu_dse__Error_Log__c>();
                    
                    if (Trigger.isInsert == True && tradelineForUpdateList.isEmpty() == False) {
                        
                        //Update the tradeline
                        Database.SaveResult[] tradelineUpdateResultList = Database.update(tradelineForUpdateList, false);
                        
                        //Error handling
                        if (tradelineUpdateResultList.isEmpty() == False) {
                            
                            for (Database.SaveResult sr : tradelineUpdateResultList) {
                                
                                System.debug('*saveResult-->'+sr);
                                
                                if (sr.isSuccess() == False) {
                                    
                                    String errMsg = '';
                                    
                                    for(Database.Error err : sr.getErrors()) {
                                        
                                        errMsg += err.getMessage() + '; ';
                                    }
                                    
                                    nu_dse__Error_Log__c errLog = createErrorLog(errMsg, 'tradelineStatusUpdateHandler.updateTradelineStatus', '');                                
                                    errLogList.add(errLog);
                                }
                            }
                        }
                        
                        //Inserting error logs
                        if (errLogList.isEmpty() == False) {
                        
                            insert errLogList;
                        }
                    }
                }
            }
            
        } catch (Exception e) {
                             
            nu_dse__Error_Log__c errorLogInst = createErrorLog(e.getMessage(), 'tradelineStatusUpdateHandler.updateTradelineStatus',
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