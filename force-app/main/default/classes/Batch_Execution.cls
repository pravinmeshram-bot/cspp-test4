global class Batch_Execution implements Database.Batchable<sObject>, Database.stateful {

    Map<String, String> sourceDestinationFieldMap = new Map<String, String>();
    Map<String, Map<String, String>> fieldMappingMap = new Map<String, Map<String, String>>();
    Set<Id> sobjectIdSet = new Set<Id>();
    Id batchExecutionId;
    String targetObject, sourceObject;
    
    public Batch_Execution(Id batchExecutionIdVal) {
    
        batchExecutionId = batchExecutionIdVal;
        
        fieldMappingMap.put('Task', new Map<String, String>{'nu_dse__Prospect__c' => 'whatId', 'nu_dse__Program__c' => 'whatId'});
        fieldMappingMap.put('nu_dse__Offer__c', new Map<String, String>{'nu_dse__Prospect__c' => 'nu_dse__Program__r.Prospect_Id__c', 'nu_dse__Program__c' => 'nu_dse__Program__c'});
        fieldMappingMap.put('nu_dse__Payment__c', new Map<String, String>{'nu_dse__Prospect__c' => 'nu_dse__Program__r.Prospect_Id__c', 'nu_dse__Program__c' => 'nu_dse__Program__c'});
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        Batch_Execution__c batchExceutionRec;
        String query = '';
        
        try {
        
            if (batchExecutionId != null) {
            
                List<Batch_Execution__c> batchExecutionList = [SELECT Id, Name, Data_Mapping__c, Filter_Criteria__c,
                                                                   Data_Mapping__r.nu_dse__Source_sObject__c,
                                                                   Data_Mapping__r.nu_dse__Target_sObject__c 
                                                                   FROM Batch_Execution__c WHERE Id = :batchExecutionId
                                                                   AND Data_Mapping__c != null AND Data_Mapping__r.nu_dse__Source_sObject__c != null
                                                                   AND Data_Mapping__r.nu_dse__Target_sObject__c != null];
                
                if (batchExecutionList != null && batchExecutionList.isEmpty() == False) {
                
                    batchExceutionRec = batchExecutionList[0];
                    targetObject = batchExecutionList[0].Data_Mapping__r.nu_dse__Target_sObject__c;
                    sourceObject = batchExecutionList[0].Data_Mapping__r.nu_dse__Source_sObject__c;
                }
                
                if (batchExceutionRec != null) {
            
                    String queryFields = '';
                    
                    for (nu_dse__Field_mapping__c fieldMapping : [SELECT Id, nu_dse__Source_Field__c, nu_dse__Target_Field__c FROM nu_dse__Field_mapping__c
                                                                     WHERE nu_dse__Data_Mapping__c = :batchExceutionRec.Data_Mapping__c]) {
                    
                        sourceDestinationFieldMap.put(fieldMapping.nu_dse__Source_Field__c, fieldMapping.nu_dse__Target_Field__c);
                        queryFields += fieldMapping.nu_dse__Source_Field__c + ', ';
                    }
                    if (sourceDestinationFieldMap.isEmpty() == False && new Set<String>(sourceDestinationFieldMap.values()).contains('Id') == False) {
                    
                        String sourceField, targetField = 'Id';
                        
                        if (fieldMappingMap.containsKey(sourceObject) && fieldMappingMap.get(sourceObject).containsKey(targetObject)) {
                        
                            sourceField = fieldMappingMap.get(sourceObject).get(targetObject);
                            
                            if (String.isNotBlank(sourceField)) {
                            
                                if (sourceDestinationFieldMap.containsKey(sourceField) == False) {
                                    queryFields += sourceField + ', ';
                                }
                                
                                sourceDestinationFieldMap.put(sourceField, targetField);
                            }
                        }
                    }
                    queryFields = queryFields.removeEnd(', ');
                    query += 'SELECT ' + queryFields + ' FROM ' + batchExceutionRec.Data_Mapping__r.nu_dse__Source_sObject__c +
                             ' WHERE ' + batchExceutionRec.Filter_Criteria__c;
                    system.debug('query-->'+query);
                }
            }
        } catch(Exception e) {
        
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_Execution.Start', 
                                                nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), 
                                                nu_dse__User_Context__c = UserInfo.getName());
            insert errorLog;
        }
        
        if (String.isBlank(query)) {
        
            query = 'SELECT Id FROM nu_dse__Offer__c LIMIT 0';
        } 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    
        List<sObject> sObjectToUpdateList = new List<sObject>();
        try {
        
            for (sObject sObjSource : scope) {
            
                Schema.SObjectType newSObj = Schema.getGlobalDescribe().get(targetObject);
                sObject sObjTarget = newSObj.newSObject();
                
                for (String sourceField : sourceDestinationFieldMap.keySet()) {
                
                    String targetField = sourceDestinationFieldMap.get(sourceField);
                    sObjTarget.put(targetField, sObjSource.get(sourceField));
                    
                }
                
                Id sObjTargetId = (Id)sObjTarget.get('Id');
                
                if (sObjTargetId != null && sobjectIdSet.contains(sObjTargetId) == False) {
                    
                    sObjectToUpdateList.add(sObjTarget);
                    sobjectIdSet.add(sObjTargetId);
                }
            }
            
            if (sObjectToUpdateList.isEmpty() == False) {
            
                update sObjectToUpdateList;
            }
        } catch(Exception e) {
        
            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'Batch_Execution.Execute', 
                                                nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), 
                                                nu_dse__User_Context__c = UserInfo.getName());
            insert errorLog;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    
    }
}