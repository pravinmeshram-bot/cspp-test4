global class Batch_CreateCreditorProcessorContact implements Database.Batchable<sObject> { 

    public Map<Id, nu_dse__Processor__c> processorInstanceAndItsIdMap;
    public Set<Id> processorIdSet;
    
    public Batch_CreateCreditorProcessorContact (Set<Id> processorIdSet) {
        
        processorInstanceAndItsIdMap = new Map<Id, nu_dse__Processor__c>([SELECT Id, Name, nu_dse__Type__c FROM nu_dse__Processor__c]); 
        this.processorIdSet = new Set<Id>();
        this.processorIdSet.addAll(processorIdSet);
    }
    
    public static Id getSobjectRecordTypeId(String sObjectName, String recordTypeName) {
    
        if(String.isNotBlank(sObjectName) && String.isNotBlank(recordTypeName)) {
        
            Id sObjectRecordTypeId;
            
            Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
            Map<String, Schema.RecordTypeInfo> sObjectRecordTypeMap = sobjectResult.getRecordTypeInfosByName();
            
            if(sObjectRecordTypeMap.containsKey(recordTypeName)) {
            
                sObjectRecordTypeId = sObjectRecordTypeMap.get(recordTypeName).getRecordTypeId();
                
                return sObjectRecordTypeId;
            }
        }
        
        return null;
    }
    
    public static String getNameSpacePrefix() {
    
        String nameSpacePrefix = nu_dse__Program__c.sObjectType.getDescribe().getName().subStringBefore('Program__c');
        return nameSpacePrefix;
    }
    
    public static nu_dse__Error_Log__c createErrorLog(String classMethod, String message, String stackTrace, String errorCausingRecord) {
        
        nu_dse__Error_Log__c errorLogInstance = new nu_dse__Error_Log__c (nu_dse__Class_Method__c = classMethod, nu_dse__Message__c = message, 
                                                                        nu_dse__Stack_Trace__c = stackTrace, nu_dse__User_Context__c = userInfo.getName(),
                                                                        nu_dse__Error_Causing_Record_Id__c = errorCausingRecord);
        return errorLogInstance;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {                    
        
        Id creditRecordTypeId = getSobjectRecordTypeId('Account', 'Creditor');
        String contactQuery = '';
         
        if(creditRecordTypeId != null) {  
        
            contactQuery = 'SELECT Id, Name, AccountId, nu_dse__CFT_Payee_Contact_Id__c, ' +
                            +' nu_dse__GCS_Payee_Contact_Id__c , nu_dse__RAMS_Payee_Contact_Id__c FROM Contact'+         
                            +' WHERE Account.RecordTypeId =\'' + creditRecordTypeId + '\'';
            
            System.debug('<<-- contactQuery -->>'+contactQuery);     
        
        } else {
            
            contactQuery += 'SELECT Id, Name, RecordTypeId FROM Contact LIMIT 0';
            
            nu_dse__Error_Log__c errorlog = createErrorLog('Batch_CreateCreditorProcessorContact',
                                                             'Creditor' + 'Record Type is not available in Account.', null, null);
            insert errorLog; 
        }
        
        return Database.getQueryLocator(contactQuery );
    }
    public void execute(Database.BatchableContext BC, List<Contact> scope) { 
        
        List<nu_dse__Creditor_Processor_Info__c> creditorProcessorToUpdateList = new List<nu_dse__Creditor_Processor_Info__c>();
        Map<Id, Contact> accountAndItsContactMap = new Map<Id, Contact>();  
        
        try { 
            
            for(Contact contactInstance : scope) {
                
                accountAndItsContactMap.put(contactInstance.AccountId, contactInstance);
            }
            
            for(nu_dse__Creditor_Processor_Info__c creditInstance : [SELECT Id, nu_dse__Account__c, nu_dse__Processor__c  
                                                                        FROM nu_dse__Creditor_Processor_Info__c 
                                                                        WHERE nu_dse__Account__c IN :accountAndItsContactMap.keySet() 
                                                                        AND (nu_dse__Contact__c = null OR nu_dse__Payee_Contact_Id__c = null)] ) {
                
                if (accountAndItsContactMap.containsKey(creditInstance.nu_dse__Account__c) == True) {
                    
                    Contact contactInstance = accountAndItsContactMap.get(creditInstance.nu_dse__Account__c);
                    nu_dse__Creditor_Processor_Info__c creditorInstance = new nu_dse__Creditor_Processor_Info__c(); 
                    creditorInstance.Id = creditInstance.Id;
                    creditorInstance.nu_dse__Contact__c = contactInstance.Id; 
                    
                    if (processorIdSet.contains(creditInstance.nu_dse__Processor__c) == True
                         && processorInstanceAndItsIdMap.containsKey(creditInstance.nu_dse__Processor__c) == True 
                         && processorInstanceAndItsIdMap.get(creditInstance.nu_dse__Processor__c).nu_dse__Type__c != null
                         && contactInstance.get('nu_dse__' + processorInstanceAndItsIdMap.get(creditInstance.nu_dse__Processor__c).nu_dse__Type__c + '_Payee_Contact_Id__c') != null) {
                        
                        creditorInstance.nu_dse__Payee_Contact_Id__c = String.Valueof(contactInstance.get('nu_dse__' + processorInstanceAndItsIdMap.get(creditInstance.nu_dse__Processor__c).nu_dse__Type__c + '_Payee_Contact_Id__c'));
                    }
                    creditorProcessorToUpdateList.add(creditorInstance); 
                }
            }
            
            System.debug('<<-- creditorProcessorToInsertList -->>'+creditorProcessorToUpdateList.size());    
            if(creditorProcessorToUpdateList.isEmpty() == False) {
                
                update creditorProcessorToUpdateList;
            }
               
        } catch(Exception e) {
            
            nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),
                        nu_dse__User_Context__c = userInfo.getName(), nu_dse__Class_Method__c = 'Batch_CreateCreditorProcessorContact');
            
            insert errLog;

        }
    }
    
    public void finish(Database.BatchableContext BC) {        
        
    }
}