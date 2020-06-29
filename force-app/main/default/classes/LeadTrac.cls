public class LeadTrac {

    public static String xNameSpace = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static String cliNameSpace = 'http://leadtrac.net/client';
    
    public static Map<String, Map<String, String>> fieldMappingForCreateUpdateClientsMap = new Map<String, Map<String, String>>();
    public static List<String> datamappingNameList = new List<String> {'AccountToLeadTrac', 'ProgramToLeadTrac','BankAccountToLeadTrac'};
    public static String userName;
    public static String password;
    public static String endpoint;
    public static String campaignId;
    
    public static void createOrUpdateClient(List<CreateUpdateClients> createUpdateClientWrapList) {
    
        List<nu_dse__Error_Log__c> errorlogsToInsertList = new List<nu_dse__Error_Log__c>();
        List<Account> accountsToUpdateList = new List<Account>();
        Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();
        Map<Id, nu_dse__Error_Log__c> accountIdErrorLogMap = new Map<Id, nu_dse__Error_Log__c>();
        String acctKeyPrefix = Account.sobjecttype.getDescribe().getKeyPrefix();
        
        Account accountRecord = new Account();
        nu_dse__Program__c programRecord = new nu_dse__Program__c();
        nu_dse__bank_Account__c bankAccount = new Nu_dse__bank_Account__c(); 
        
        String childElement = 'CreateOrUpdateClientResponse', subChildElement = 'CreateOrUpdateClientResult';
        
        if (createUpdateClientWrapList != null && createUpdateClientWrapList.isEmpty() == False) {
            
            try { 
            
                if (String.isBlank(username) || String.isBlank(password) || String.isBlank(endpoint) || String.isBlank(campaignId)) {
                
                    getCredentials();
                }
                
                if (String.isNotBlank(username) && String.isNotBlank(password) && String.isNotBlank(endpoint)
                        && String.isNotBlank(campaignId)) {
                
                    for (nu_dse__Field_mapping__c fieldMapping : [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Target_Field__c, nu_dse__setDefaultValue__c, 
                                                                    nu_dse__Is_Required__c, nu_dse__Default_Value__c, nu_dse__Data_Mapping__c, 
                                                                    nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c FROM nu_dse__Field_mapping__c 
                                                                    WHERE nu_dse__Data_Mapping__r.Name IN :datamappingNameList
                                                                    AND nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c != null]) {
                    
                        if (fieldMappingForCreateUpdateClientsMap.containsKey(fieldMapping.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c) == False) {
                        
                            fieldMappingForCreateUpdateClientsMap.put(fieldMapping.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c, new Map<String, String>());
                        }
                        fieldMappingForCreateUpdateClientsMap.get(fieldMapping.nu_dse__Data_Mapping__r.nu_dse__Source_sObject__c).put(fieldMapping.nu_dse__Source_Field__c, fieldMapping.nu_dse__Target_Field__c);
                    }
                    system.debug('fieldMappingForCreateUpdateClientsMap-->'+fieldMappingForCreateUpdateClientsMap);
                    
                    for (CreateUpdateClients createUpdateClientInstance : createUpdateClientWrapList) {
                    
                        try {
                        
                            accountRecord = createUpdateClientInstance.acctRec;
                            programRecord = createUpdateClientInstance.programRec;
                            bankAccount = createUpdateClientInstance.bankAccount;
                            
                            Dom.Document doc = new Dom.Document();
                            
                            Dom.XmlNode envelope = doc.createRootElement('Envelope', xNameSpace, 'x');
                            
                            envelope.setNamespace('x', xNameSpace);
                            envelope.setNamespace('cli', cliNameSpace);
                            
                            Dom.XmlNode header =  envelope.addChildElement('Header', xNameSpace, 'x');
                            
                            Dom.XmlNode body =  envelope.addChildElement('Body', xNameSpace, 'x');
                            
                            Dom.XmlNode createOrUpdateClientXml = body.addChildElement('CreateOrUpdateClient', cliNameSpace, 'cli');
                            createOrUpdateClientXml.addChildElement('userName', cliNameSpace, 'cli').addTextNode(username);
                            createOrUpdateClientXml.addChildElement('password', cliNameSpace, 'cli').addTextNode(password);
                            createOrUpdateClientXml.addChildElement('campaignId', cliNameSpace, 'cli').addTextNode(campaignId);
                        
                            Dom.XmlNode propertyListXml = createOrUpdateClientXml.addChildElement('propertyList', cliNameSpace, 'cli');
                            
                            for (String fiedMappingKey : fieldMappingForCreateUpdateClientsMap.keySet()) {
                                
                                Map<String, String> fieldMappingMap = new Map<String, String>(fieldMappingForCreateUpdateClientsMap.get(fiedMappingKey));
                                
                                if (fieldMappingMap.isEmpty() == False) {
                                
                                    for (String fieldNameVal : fieldMappingMap.keySet()) {
                                    
                                        String fieldValue;
                                        String nodeName = String.valueOf(fieldMappingMap.get(fieldNameVal));
                                        
                                        if (fiedMappingKey == 'Account' && accountRecord != null) {
                                        
                                            fieldValue = String.valueOf(accountRecord.get(fieldNameVal));
                                            
                                        } else if (fiedMappingKey == 'nu_dse__Program__c' && programRecord !=null ) {
                                        
                                            fieldValue = String.valueOf(programRecord.get(fieldNameVal));
                                            
                                        } else if(fiedMappingKey == 'nu_dse__Bank_Account__c' && bankAccount !=null){
                                            
                                           
                                            fieldValue = String.valueOf(bankAccount.get(fieldNameVal));
                                                
                                            
                                        }
                                        System.debug('Field Name and Value **:'+nodeName +' '+ fieldValue);
                                        
                                        if (String.isNotBlank(nodeName) && String.isNotBlank(fieldValue)) {
                                              Dom.XmlNode clientPropertyXml = propertyListXml.addChildElement('ClientProperty', cliNameSpace, 'cli');
    
                                            clientPropertyXml.addChildElement('Name', cliNameSpace, 'cli').addTextNode(nodeName);
                                            clientPropertyXml.addChildElement('Value', cliNameSpace, 'cli').addTextNode(fieldValue);
                                        }
                                    }
                                }
                            }
                            System.debug('******* doc in create ***** ' + doc.toXMLString());
                            HttpRequest req = new HttpRequest();
                            req.setEndpoint(endpoint);
                            req.setMethod('POST');
                            req.setHeader('SOAPAction', 'http://leadtrac.net/client/CreateOrUpdateClient');
                            req.setHeader('Content-Type','text/xml;charset=UTF-8');
                            
                            System.debug('***** req **** ' + req);
                            
                            req.setBodyDocument(doc);
                            req.setTimeout(100000);
                            
                            Http http = new Http();
                            HttpResponse res = http.send(req);
                            String responseString = res.getBody();
                            system.debug('Status--->'+res.getStatus());
                            system.debug('body----->'+responseString);
                            
                            if (String.isNotBlank(responseString)) {
                    
                                Dom.Document docResult = new Dom.Document();
                                docResult.load(responseString);
                                
                                Dom.XMLNode envelopeResult = docResult.getRootElement();
                                system.debug('envelopeResult-->'+envelopeResult);
                                
                                Dom.XMLNode bodyResult;
                                List<Dom.XMLNode> childElementsList;
                                
                                if(envelopeResult.getChildElements() != null && envelopeResult.getChildElements().isEmpty() == False) {
                                    
                                    bodyResult = envelopeResult.getChildElements()[0];
                                    system.debug('bodyResult-->'+bodyResult);
                                    
                                    if (bodyResult != null && bodyResult.getChildElements() != null && bodyResult.getChildElements().isEmpty() == False) {     
                                            
                                        Dom.XMLNode child = bodyResult.getChildElements()[0];
                                                
                                        if (child.getName() == childElement) {
                            
                                            for(Dom.XMLNode childElements : child.getChildElements()) {
                                    
                                                if(String.isNotBlank(childElements.getName()) && childElements.getName() == subChildElement
                                                        && childElements.getText() != null) {
                                                    
                                                    String responseMsg = childElements.getText();
                                                    String leadTracId = responseMsg.substringAfter('SUCCESS:').subStringBefore(': ');
                                                    String warningMsg = responseMsg.substringAfter('SUCCESS:').subStringAfter(': ');
                                                    
                                                    if (String.isNotBlank(leadTracId)) {
                                                    
                                                        Account acctToUpdate = new Account(Id = accountRecord.Id);
                                                        acctToUpdate.External_Lead_Trac_Id__c = leadTracId;
                                                        acctToUpdate.Is_Synced_Lead_Trac__c = True;
                                                        accountsToUpdateList.add(acctToUpdate);
                                                        accountsToUpdateMap.put(acctToUpdate.Id, acctToUpdate);
                                                    }
                                                    
                                                    if (String.isNotBlank(warningMsg)) {
                                                        
                                                        nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'LeadTrac.createOrUpdateClient', 
                                                                                            nu_dse__Message__c = warningMsg, nu_dse__User_Context__c = UserInfo.getName(),
                                                                                            nu_dse__Error_Causing_Record_Id__c = accountRecord.Id);
                                                        accountIdErrorLogMap.put(accountRecord.Id, errorlog);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } 
                        } catch(Exception e) {
                        
                            nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'LeadTrac.createOrUpdateClient', 
                                    nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), 
                                    nu_dse__User_Context__c = UserInfo.getName());
                            
                            accountIdErrorLogMap.put(accountRecord.Id, errorlog);
                        }
                    }
                    
                    if (accountIdErrorLogMap.isEmpty() == False) {
                    
                        insert accountIdErrorLogMap.values();
                        
                        for (nu_dse__Error_Log__c errLog : accountIdErrorLogMap.values()) {
                        
                            Id acctId = errLog.nu_dse__Error_Causing_Record_Id__c;
                            
                            if (acctId != null && String.valueOf(acctId).startsWith(acctKeyPrefix)) {
                            
                                Account acctToUpdate = new Account();
                                
                                if (accountsToUpdateMap.containsKey(acctId)) {
                                
                                    acctToUpdate = accountsToUpdateMap.get(acctId);
                                    
                                } else {
                                
                                    acctToUpdate = new Account(Id = acctId);
                                }
                                acctToUpdate.nu_dse__Processor_Error__c = errLog.Id;
                                accountsToUpdateMap.put(acctToUpdate.Id, acctToUpdate);
                            }
                        }
                    }
                        
                    system.debug('accountsToUpdateList-->'+accountsToUpdateList);
                    if (accountsToUpdateList.isEmpty() == False) {
                    
                        update accountsToUpdateList;
                    }
                }
            } catch(Exception e) {
                
                nu_dse__Error_Log__c errorlog = new nu_dse__Error_Log__c(nu_dse__Class_Method__c = 'GCSProcessor.getClients', 
                        nu_dse__Message__c = e.getMessage(), nu_dse__Stack_Trace__c = e.getStackTraceString(), 
                        nu_dse__User_Context__c = UserInfo.getName());
                
                insert errorlog;
            }
        }    
    }
    
    public static void getCredentials() {
    
        LeadTrac_Settings__c leadTrac = LeadTrac_Settings__c.getInstance();
        userName = leadTrac.Username__c;
        password = leadTrac.Password__c;
        endpoint = leadTrac.Endpoint__c;
        campaignId = leadTrac.Campaign_Id__c;
    }
    
    public class CreateUpdateClients {
    
        public Account acctRec;
        public nu_dse__Program__c programRec;
        public nu_dse__Bank_Account__c bankAccount; 
    }
}