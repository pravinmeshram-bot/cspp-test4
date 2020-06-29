global class Batch_CreateCreditorProcessorInfo implements Database.Batchable<sObject> { 
    
    public List<nu_dse__Processor__c> processorList;
    public Set<Id> processorIdSet;
    
    public Batch_CreateCreditorProcessorInfo (Set<Id> processorIdSet) {
        
        processorList = [SELECT Id, Name, nu_dse__Type__c FROM nu_dse__Processor__c];
        this.processorIdSet = new Set<Id>();
        this.processorIdSet.addAll(processorIdSet);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
                    
        String accountQuery = '';  
          
        Id creditRecordTypeId = getSobjectRecordTypeId('Account', 'Creditor');
            
        if(creditRecordTypeId != null) {      
    
            accountQuery += 'SELECT Id, Name, RecordTypeId, nu_dse__GCS_Payee_Id__c, nu_dse__GCS_Synced__c, nu_dse__GCS_Payee_Address_Id__c,' +
                            +' nu_dse__RAMS_Payee_Id__c, nu_dse__RAMS_Payee_Address_Id__c, nu_dse__RAMS_Synced__c,'+
                            +' nu_dse__CFT_Payee_Id__c, nu_dse__CFT_Payee_Address_Id__c, nu_dse__CFT_Synced__c FROM Account'+  
                            +' WHERE RecordTypeId =\'' + creditRecordTypeId + '\'';
        
        } else {
            
            accountQuery += 'SELECT Id, Name, RecordTypeId FROM Account LIMIT 0';
            
            nu_dse__Error_Log__c errorlog = createErrorLog('Batch_CreateCreditorProcessorInfo',
                                                                 'Creditor' + 'Record Type is not available in account.', null, null);
            insert errorLog; 
                              
        }
        System.debug('accountQuery-->'+accountQuery);     
        return Database.getQueryLocator(accountQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> scope) {   
    
        List<nu_dse__Creditor_Processor_Info__c> creditorProcessorToInsertList = new List<nu_dse__Creditor_Processor_Info__c>(); 
        Map<Id, Map<Id, nu_dse__Creditor_Processor_Info__c>> creditorAccountMap = new Map<Id, Map<Id, nu_dse__Creditor_Processor_Info__c>>();         
        
        try { 
            
            for(nu_dse__Creditor_Processor_Info__c creditInstance : [SELECT Id, Name, nu_dse__Account__c, nu_dse__Processor__c  FROM nu_dse__Creditor_Processor_Info__c WHERE nu_dse__Account__c IN :scope] ) {
                
                if(processorList.isEmpty() == False) {
        
                    for(nu_dse__Processor__c prosInstance : processorList) {
                        
                        if(creditorAccountMap.containsKey(creditInstance.nu_dse__Account__c) == False) {
                        
                            creditorAccountMap.put(creditInstance.nu_dse__Account__c,new Map<Id, nu_dse__Creditor_Processor_Info__c> {});
                        } 
                        
                        if(creditInstance.nu_dse__Processor__c == prosInstance.Id) {     
                                          
                            creditorAccountMap.get(creditInstance.nu_dse__Account__c).put(prosInstance.Id , creditInstance);     
                        }                   
                    }     
                }
            }           
                
            for(Account accInstance : scope) { 
                
                if(processorList.isEmpty() == False) {           
                
                    for(nu_dse__Processor__c prosInstance : processorList) {                     
                        
                        if((creditorAccountMap.containsKey(accInstance.Id) == True && creditorAccountMap.get(accInstance.Id).containsKey(prosInstance.Id) == False) 
                        
                        || (creditorAccountMap.containsKey(accInstance.Id) == False)) {                           
                                
                            nu_dse__Creditor_Processor_Info__c insertCreditor = new nu_dse__Creditor_Processor_Info__c(); 
                            insertCreditor.nu_dse__Account__c = accInstance.Id;
                            insertCreditor.nu_dse__Processor__c = prosInstance.Id;      
                            
                            if(processorIdSet.contains(prosInstance.Id) == True && accInstance.get('nu_dse__' + prosInstance.nu_dse__Type__c + '_Payee_Id__c') != null) {          
                        
                                insertCreditor.nu_dse__Payee_Address_Id__c = String.Valueof(accInstance.get('nu_dse__' + prosInstance.nu_dse__Type__c + '_Payee_Address_Id__c'));
                                insertCreditor.nu_dse__Payee_Id__c  = String.Valueof(accInstance.get('nu_dse__' + prosInstance.nu_dse__Type__c + '_Payee_Id__c'));        
                                                                                     
                            }                            
                            creditorProcessorToInsertList.add(insertCreditor);                                                       
                        }
                    }
                }
            }            
                                   
            if(creditorProcessorToInsertList.isEmpty() == False) {
                
                insert creditorProcessorToInsertList;
            }              
                
        } catch(Exception e) {
                
            nu_dse__Error_Log__c errLog = new nu_dse__Error_Log__c(nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(),
                        nu_dse__User_Context__c = userInfo.getName(), nu_dse__Class_Method__c = 'Batch_CreateCreditorProcessorInfo');
            
            insert errLog;
        }            
    }
    
    public void finish(Database.BatchableContext BC) {        
        
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
    
}