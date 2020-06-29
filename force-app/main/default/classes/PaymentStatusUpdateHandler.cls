/**
 * @File Name          : PaymentStatusUpdateHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/23/2019, 2:26:42 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    10/23/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class PaymentStatusUpdateHandler {
    
    public static Set<String> datamapNameSet = new set<String>{'nds_TransactionStatusToPaymentStatus', 
           'nds_PaymentStatusToTransactionStatus', 'nds_TransactionMethodToPaymentType', 'nds_PaymentTypeToTransactionMethod'};
    
    /*public static void updateStatusForFields(List<nu_dse__Payment__c> newPaymentList, Map<Id, nu_dse__Payment__c> paymentOldMap) {
        
        List<nu_dse__Payment__c> paymentForUpdateList = new List<nu_dse__Payment__c>();
        Map<String, Map<String, String>> dataMapNameAndItsFieldMapping = new Map<String, Map<String, String>>();
        
        try {
            
            User isAttorneyUser = StatusMappingStaticSetClass_nds.getUser();
            Boolean Is_NDS = isAttorneyUser.Attorney_Admin__c;
            
            //Check whether the user is not an attorney user...
            if (newPaymentList != null && newPaymentList.isEmpty() == False ) {
                
                //static boolean to avoid querying repeatedly..
                if (StatusMappingStaticSetClass_nds.staticDataMapInitialized == False) {
                    //DailyReportupload__c.getAll();
                    List<nu_dse__Field_mapping__c> fieldMappingList = [SELECT Id, nu_dse__Source_Field__c, nu_dse__Target_Field__c, nu_dse__Data_Mapping__r.Name FROM nu_dse__Field_mapping__c
                                                                               WHERE nu_dse__Data_Mapping__r.Name IN :datamapNameSet ];
                    StatusMappingStaticSetClass_nds.staticDataMapInitialized = True;
                    
                    //Constructing a Map for holding Datamap and its fieldMapping values...
                    if (fieldMappingList.isEmpty() == False) {
                        
                        for (nu_dse__Field_mapping__c fieldMapInstance :fieldMappingList) {
                            
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
                
                System.debug('dataMapNameAndItsFieldMapping-->'+dataMapNameAndItsFieldMapping);
                
                if (dataMapNameAndItsFieldMapping.isEmpty() == False) {
                    
                    for (nu_dse__Payment__c paymentInstance : newPaymentList) {
                        System.debug('*PaymentInstanceInLoop-->'+paymentInstance);
                        //Prevent updating the payment's status which is already updated (Using static Id set)...
                        //payment's IsAttorney checkbox is checked in order to update its status...
                        if (StatusMappingStaticSetClass_nds.processedPaymentIdSet.contains(paymentInstance.Id) == False 
                            && paymentInstance.IsAttorney__c == True) {
                            
                            if (Trigger.isInsert == True) { //For Insert trigger
                                
                                nu_dse__Payment__c paymentInstTemp = new nu_dse__Payment__c();
                                paymentInstTemp.Id = paymentInstance.Id;
                                Boolean isPaymentUpdated = False;
                                
                                //Updating Payment_Status__c field based on nu_dse__Transaction_Status__c, if Is_NDS__c is false...
                                if (Is_NDS == False && dataMapNameAndItsFieldMapping.containsKey('nds_TransactionStatusToPaymentStatus') == True 
                                    && dataMapNameAndItsFieldMapping.get('nds_TransactionStatusToPaymentStatus').containsKey(paymentInstance.nu_dse__Transaction_Status__c) == True
                                    && paymentInstance.Payment_Status__c != 
                                        dataMapNameAndItsFieldMapping.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c)) {
                                    
                                    paymentInstTemp.Payment_Status__c = dataMapNameAndItsFieldMapping.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c);
                                    isPaymentUpdated = True;
                                    
                                }  
                                
                                //Updating nu_dse__Transaction_Status__c field based on Payment_Status__c, if Is_NDS__c is true...
                                if (Is_NDS == True && dataMapNameAndItsFieldMapping.containsKey('nds_PaymentStatusToTransactionStatus') == True 
                                    && dataMapNameAndItsFieldMapping.get('nds_PaymentStatusToTransactionStatus').containsKey(paymentInstance.Payment_Status__c) == True
                                    && paymentInstance.nu_dse__Transaction_Status__c != 
                                        dataMapNameAndItsFieldMapping.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c)) {
                                    
                                    paymentInstTemp.nu_dse__Transaction_Status__c = dataMapNameAndItsFieldMapping.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c);
                                    isPaymentUpdated = True;
                                }
                                
                                //Updating NDS_Payment_Type__c field based on nu_dse__Transaction_Method__c, if Is_NDS__c is false...
                                if (Is_NDS == False && dataMapNameAndItsFieldMapping.containsKey('nds_TransactionMethodToPaymentType') == True 
                                    && dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').containsKey(paymentInstance.nu_dse__Transaction_Method__c) == True
                                    && paymentInstance.NDS_Payment_Type__c != 
                                        dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c)) {
                                    
                                    paymentInstTemp.NDS_Payment_Type__c = dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c);
                                    isPaymentUpdated = True;
                                    
                                } 
                                
                                //Updating nu_dse__Transaction_Method__c field based on NDS_Payment_Type__c, if Is_NDS__c is true...
                                if (Is_NDS == True && dataMapNameAndItsFieldMapping.containsKey('nds_PaymentTypeToTransactionMethod') == True 
                                            && dataMapNameAndItsFieldMapping.get('nds_PaymentTypeToTransactionMethod').containsKey(paymentInstance.NDS_Payment_Type__c) == True
                                            && paymentInstance.nu_dse__Transaction_Method__c != 
                                                dataMapNameAndItsFieldMapping.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c)) {
                                                    
                                    paymentInstTemp.nu_dse__Transaction_Method__c = dataMapNameAndItsFieldMapping.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c);
                                    isPaymentUpdated = True;
                                }
                                
                                if (isPaymentUpdated == True) {
                                    
                                    System.debug('paymentForUpdateList-->'+paymentForUpdateList);
                                    paymentForUpdateList.add(paymentInstTemp);
                                    StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id); //Adding pymnt Id to static set...
                                }
                                
                            } else if (Trigger.isUpdate == True) { //For Update trigger
                                 
                                //Checking whether the nu_dse__Transaction_Status__c is changed or not, and update Payment_Status__c field...
                                if (paymentInstance.nu_dse__Transaction_Status__c != paymentOldMap.get(paymentInstance.Id).nu_dse__Transaction_Status__c) {
                                    
                                    if (dataMapNameAndItsFieldMapping.containsKey('nds_TransactionStatusToPaymentStatus') == True 
                                        && dataMapNameAndItsFieldMapping.get('nds_TransactionStatusToPaymentStatus').containsKey(paymentInstance.nu_dse__Transaction_Status__c) == True
                                        && paymentInstance.Payment_Status__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c)) {
                                        
                                        //Since it is before Update simpliy added to the instance...
                                        paymentInstance.Payment_Status__c = dataMapNameAndItsFieldMapping.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c);
                                        StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                    }
                                    
                                    //Checking whether the Payment_Status__c is changed or not, and update nu_dse__Transaction_Status__c field...
                                } else if (paymentInstance.Payment_Status__c != paymentOldMap.get(paymentInstance.Id).Payment_Status__c) {
                                    
                                    if (dataMapNameAndItsFieldMapping.containsKey('nds_PaymentStatusToTransactionStatus') == True 
                                        && dataMapNameAndItsFieldMapping.get('nds_PaymentStatusToTransactionStatus').containsKey(paymentInstance.Payment_Status__c) == True
                                        && paymentInstance.nu_dse__Transaction_Status__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c)) {
                                        
                                        paymentInstance.nu_dse__Transaction_Status__c = dataMapNameAndItsFieldMapping.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c);
                                        StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                    }
                                }
                                
                                //Checking whether the nu_dse__Transaction_Method__c is changed or not, and update NDS_Payment_Type__c field...
                                if (paymentInstance.nu_dse__Transaction_Method__c != paymentOldMap.get(paymentInstance.Id).nu_dse__Transaction_Method__c) {
                                    
                                    if (dataMapNameAndItsFieldMapping.containsKey('nds_TransactionMethodToPaymentType') == True 
                                        && dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').containsKey(paymentInstance.nu_dse__Transaction_Method__c) == True
                                        && paymentInstance.NDS_Payment_Type__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c)) {
                                        
                                        paymentInstance.NDS_Payment_Type__c = dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c);
                                        StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                    }
                                
                                    //Checking whether the NDS_Payment_Type__c is changed or not, and update nu_dse__Transaction_Method__c field...
                                } else if (paymentInstance.NDS_Payment_Type__c != paymentOldMap.get(paymentInstance.Id).NDS_Payment_Type__c) {
                                    
                                    if (dataMapNameAndItsFieldMapping.containsKey('nds_PaymentTypeToTransactionMethod') == True 
                                        && dataMapNameAndItsFieldMapping.get('nds_PaymentTypeToTransactionMethod').containsKey(paymentInstance.NDS_Payment_Type__c) == True
                                        && paymentInstance.nu_dse__Transaction_Method__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c)) {
                                                
                                        paymentInstance.nu_dse__Transaction_Method__c = dataMapNameAndItsFieldMapping.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c);
                                        StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                    }
                                }
                            }
                        }
                        
                        System.debug('**UpdatedPaymentList-->'+newPaymentList);
                    }
                    
                    List<nu_dse__Error_Log__c> errLogList = new List<nu_dse__Error_Log__c>();
                    
                    if (Trigger.isInsert == True && paymentForUpdateList.isEmpty() == False) {
                        
                        //Update the payment
                        Database.SaveResult[] paymentUpdateResultList = Database.update(paymentForUpdateList, false);
                        
                        //Error handling
                        if (paymentUpdateResultList.isEmpty() == False) {
                            
                            for (Database.SaveResult sr : paymentUpdateResultList) {
                                
                                System.debug('*saveResult-->'+sr);
                                
                                if (sr.isSuccess() == False) {
                                    
                                    String errMsg = '';
                                    
                                    for(Database.Error err : sr.getErrors()) {
                                        
                                        errMsg += err.getMessage() + '; ';
                                    }
                                    
                                    nu_dse__Error_Log__c errLog = createErrorLog(errMsg, 'PaymentStatusUpdateHandler-PaymentDML', '');                                
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
                             
            nu_dse__Error_Log__c errorLogInst = createErrorLog(e.getMessage(), 'PaymentStatusUpdateHandler.updateStatusForFields',
                                                         e.getStackTraceString());
            insert errorLogInst;
        }
    }*/
    
    public static nu_dse__Error_Log__c createErrorLog(String message, String classMethod, String stackTrace) {
    
        nu_dse__Error_Log__c errorLogInst = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = classMethod,
                         nu_dse__Message__c = message,  nu_dse__Stack_Trace__c = stackTrace,
                         nu_dse__User_Context__c = UserInfo.getUserName());
         
        return errorLogInst;
    }
    
    public static void updateStatusForFieldsAdmin(List<nu_dse__Payment__c> newPaymentList, Map<Id, nu_dse__Payment__c> paymentOldMap) {
        List<nu_dse__Payment__c> paymentForUpdateList = new List<nu_dse__Payment__c>();
        Map<String, Map<String, String>> dataMapNameAndItsFieldMapping = new Map<String, Map<String, String>>();
        Boolean apiUser = Attorney_StaticVariableUtility.apiUser;
        try {
            if (newPaymentList != null && newPaymentList.isEmpty() == False ) {
            
                Map<String,Map<String,String>> PaymentStatusFinalMap = new Map<String,Map<String,String>>();
                if (StatusMappingStaticSetClass_nds.staticDataMapInitialized == False) {
                    Map<String,PaymentStatusMapping__c> PaymentStatusMappingList = PaymentStatusMapping__c.getAll();
                    
                    
                    for(PaymentStatusMapping__c PaymentMap: PaymentStatusMappingList.values()){
                        if(!PaymentStatusFinalMap.containsKey(PaymentMap.Type__c)){
                            PaymentStatusFinalMap.put(PaymentMap.Type__c,new Map<String,String>());
                        }
                        PaymentStatusFinalMap.get(PaymentMap.Type__c).put(PaymentMap.Source_Field__c,PaymentMap.Target_Field__c);
                    }
                    StatusMappingStaticSetClass_nds.staticDataMap = PaymentStatusFinalMap;
                    StatusMappingStaticSetClass_nds.staticDataMapInitialized = true;
                } else {
                    PaymentStatusFinalMap = StatusMappingStaticSetClass_nds.staticDataMap;
                }
                
                if (PaymentStatusFinalMap.isEmpty() == False) {
                    for (nu_dse__Payment__c paymentInstance : newPaymentList) {
                        if (StatusMappingStaticSetClass_nds.processedPaymentIdSet.contains(paymentInstance.Id) == False 
                            && paymentInstance.IsAttorney__c == True) {
                                if (Trigger.isInsert == True) {  
                                    
                                    nu_dse__Payment__c paymentInstTemp = new nu_dse__Payment__c();
                                    paymentInstTemp.Id = paymentInstance.Id;
                                    Boolean isPaymentUpdated = False;
                                    
                                    //Updating nu_dse__Transaction_Status__c field based on Payment_Status__c, if Is_NDS__c is true...
                                    if (ApiUser && PaymentStatusFinalMap.containsKey('nds_PaymentStatusToTransactionStatus') == True 
                                        && PaymentStatusFinalMap.get('nds_PaymentStatusToTransactionStatus').containsKey(paymentInstance.Payment_Status__c) == True
                                        && paymentInstance.nu_dse__Transaction_Status__c != PaymentStatusFinalMap.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c)) {
                                        
                                        paymentInstTemp.nu_dse__Transaction_Status__c = PaymentStatusFinalMap.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c);
                                        isPaymentUpdated = True;
                                    }
                                    
                                    //Updating nu_dse__Transaction_Method__c field based on NDS_Payment_Type__c, if Is_NDS__c is true...
                                    if (ApiUser && PaymentStatusFinalMap.containsKey('nds_PaymentTypeToTransactionMethod') == True 
                                                && PaymentStatusFinalMap.get('nds_PaymentTypeToTransactionMethod').containsKey(paymentInstance.NDS_Payment_Type__c) == True
                                                && paymentInstance.nu_dse__Transaction_Method__c != 
                                                    PaymentStatusFinalMap.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c)) {
                                                        
                                        paymentInstTemp.nu_dse__Transaction_Method__c = PaymentStatusFinalMap.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c);
                                        isPaymentUpdated = True;
                                    }
                                    
                                    if (!ApiUser && PaymentStatusFinalMap.containsKey('nds_TransactionStatusToPaymentStatus') == True 
                                        && PaymentStatusFinalMap.get('nds_TransactionStatusToPaymentStatus').containsKey(paymentInstance.nu_dse__Transaction_Status__c) == True
                                        && paymentInstance.Payment_Status__c != PaymentStatusFinalMap.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c)) {
                                        
                                        paymentInstTemp.Payment_Status__c = PaymentStatusFinalMap.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c);
                                        isPaymentUpdated = True;
                                        
                                    }
                                    
                                    //Updating NDS_Payment_Type__c field based on nu_dse__Transaction_Method__c, if Is_NDS__c is false...
                                    if (!ApiUser && PaymentStatusFinalMap.containsKey('nds_TransactionMethodToPaymentType') == True 
                                        && PaymentStatusFinalMap.get('nds_TransactionMethodToPaymentType').containsKey(paymentInstance.nu_dse__Transaction_Method__c) == True
                                        && paymentInstance.NDS_Payment_Type__c != 
                                            dataMapNameAndItsFieldMapping.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c)) {
                                        
                                        paymentInstTemp.NDS_Payment_Type__c = PaymentStatusFinalMap.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c);
                                        isPaymentUpdated = True;
                                        
                                    }
                                    
                                    if (isPaymentUpdated == True) {
                                        
                                        System.debug('paymentForUpdateList-->'+paymentForUpdateList);
                                        paymentForUpdateList.add(paymentInstTemp);
                                        StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id); //Adding pymnt Id to static set...
                                    }
                                } else if(Trigger.isUpdate) {
                                    //Checking whether the nu_dse__Transaction_Status__c is changed or not, and update Payment_Status__c field...
                                    if (paymentInstance.nu_dse__Transaction_Status__c != paymentOldMap.get(paymentInstance.Id).nu_dse__Transaction_Status__c || (paymentInstance.Payment_Status__c == null && paymentInstance.nu_dse__Transaction_Status__c != null)) {
                                        
                                        if (PaymentStatusFinalMap.containsKey('nds_TransactionStatusToPaymentStatus') == True 
                                            && PaymentStatusFinalMap.get('nds_TransactionStatusToPaymentStatus').containsKey(paymentInstance.nu_dse__Transaction_Status__c) == True
                                            && paymentInstance.Payment_Status__c != 
                                                PaymentStatusFinalMap.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c)) {
                                            
                                            //Since it is before Update simpliy added to the instance...
                                            paymentInstance.Payment_Status__c = PaymentStatusFinalMap.get('nds_TransactionStatusToPaymentStatus').get(paymentInstance.nu_dse__Transaction_Status__c);
                                            StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                        }
                                        
                                        //Checking whether the Payment_Status__c is changed or not, and update nu_dse__Transaction_Status__c field...
                                    } else if (paymentInstance.Payment_Status__c != paymentOldMap.get(paymentInstance.Id).Payment_Status__c || (PaymentInstance.Payment_Status__c != null && PaymentInstance.nu_dse__Transaction_Status__c == null)) {
                                        
                                        if (PaymentStatusFinalMap.containsKey('nds_PaymentStatusToTransactionStatus') == True 
                                            && PaymentStatusFinalMap.get('nds_PaymentStatusToTransactionStatus').containsKey(paymentInstance.Payment_Status__c) == True
                                            && paymentInstance.nu_dse__Transaction_Status__c != PaymentStatusFinalMap.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c)) {
                                            
                                            paymentInstance.nu_dse__Transaction_Status__c = PaymentStatusFinalMap.get('nds_PaymentStatusToTransactionStatus').get(paymentInstance.Payment_Status__c);
                                            StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                        }
                                    }
                                    
                                    //Checking whether the nu_dse__Transaction_Method__c is changed or not, and update NDS_Payment_Type__c field...
                                    if (paymentInstance.nu_dse__Transaction_Method__c != paymentOldMap.get(paymentInstance.Id).nu_dse__Transaction_Method__c) {
                                        
                                        if (PaymentStatusFinalMap.containsKey('nds_TransactionMethodToPaymentType') == True 
                                            && PaymentStatusFinalMap.get('nds_TransactionMethodToPaymentType').containsKey(paymentInstance.nu_dse__Transaction_Method__c) == True
                                            && paymentInstance.NDS_Payment_Type__c != PaymentStatusFinalMap.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c)) {
                                            
                                            paymentInstance.NDS_Payment_Type__c = PaymentStatusFinalMap.get('nds_TransactionMethodToPaymentType').get(paymentInstance.nu_dse__Transaction_Method__c);
                                            StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                        }
                                    
                                        //Checking whether the NDS_Payment_Type__c is changed or not, and update nu_dse__Transaction_Method__c field...
                                    } else if (paymentInstance.NDS_Payment_Type__c != paymentOldMap.get(paymentInstance.Id).NDS_Payment_Type__c) {
                                        
                                        if (PaymentStatusFinalMap.containsKey('nds_PaymentTypeToTransactionMethod') == True 
                                            && PaymentStatusFinalMap.get('nds_PaymentTypeToTransactionMethod').containsKey(paymentInstance.NDS_Payment_Type__c) == True
                                            && paymentInstance.nu_dse__Transaction_Method__c != PaymentStatusFinalMap.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c)) {
                                                    
                                            paymentInstance.nu_dse__Transaction_Method__c = PaymentStatusFinalMap.get('nds_PaymentTypeToTransactionMethod').get(paymentInstance.NDS_Payment_Type__c);
                                            StatusMappingStaticSetClass_nds.processedPaymentIdSet.add(paymentInstance.Id);
                                        }
                                    }
                                }
                        }
                    }
                    
                    List<nu_dse__Error_Log__c> errLogList = new List<nu_dse__Error_Log__c>();
                    
                    if (Trigger.isInsert == True && paymentForUpdateList.isEmpty() == False) {
                        
                        //Update the payment
                        Database.SaveResult[] paymentUpdateResultList = Database.update(paymentForUpdateList, false);
                        
                        //Error handling
                        if (paymentUpdateResultList.isEmpty() == False) {
                            
                            for (Database.SaveResult sr : paymentUpdateResultList) {
                                
                                System.debug('*saveResult-->'+sr);
                                
                                if (sr.isSuccess() == False) {
                                    
                                    String errMsg = '';
                                    
                                    for(Database.Error err : sr.getErrors()) {
                                        
                                        errMsg += err.getMessage() + '; ';
                                    }
                                    
                                    nu_dse__Error_Log__c errLog = createErrorLog(errMsg, 'PaymentStatusUpdateHandler-PaymentDML', '');                                
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
        } catch(Exception e){
            nu_dse__Error_Log__c errorLogInst = createErrorLog(e.getMessage(), 'PaymentStatusUpdateHandler.updateStatusForFields',
                                                         e.getStackTraceString());
            insert errorLogInst;
        }
    }
}